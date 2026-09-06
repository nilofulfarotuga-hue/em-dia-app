// Edge Function: receber-fatura
//
// A ponta de dentro da caixa de correio das faturas (decisão D24). Quem chama é
// o Worker da Cloudflare, que recebe o e-mail e já o abriu: manda-nos o
// destinatário, o remetente, o assunto e os anexos em base64.
//
// A app NÃO pede a palavra-passe do e-mail a ninguém e não liga à API do Gmail.
// A pessoa reencaminha para o seu endereço `<nome>-<8 letras>@<dominio>` as
// faturas que já lhe chegam, e elas aparecem aqui dentro.
//
// O que esta função faz, por ordem:
//   1. confere o segredo partilhado com o Worker (Vault 'correio_secret')
//   2. descobre de quem é a caixa (profiles.caixa_local) — desconhecida = 404,
//      e o Worker devolve o e-mail a quem o mandou
//   3. guarda o primeiro anexo que serve no balde privado 'faturas'
//   4. escreve uma linha em faturas_recebidas, estado 'nova'
//
// O que esta função NÃO faz, de propósito: **não lê o documento**. A leitura por
// IA tem limite de 5 por mês no plano grátis, e gastá-lo sem a pessoa pedir era
// roubar-lhe as leituras. Quem abre a caixa na app é que carrega em "ler esta".
import { json, preflight } from '../_shared/cors.ts'
import { clienteAdmin, lerSegredo } from '../_shared/segredos.ts'

const TIPOS_QUE_SERVEM: Record<string, string> = {
  'application/pdf': 'pdf',
  'image/jpeg': 'jpg',
  'image/jpg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
}
const MAX_BYTES = 10 * 1024 * 1024   // igual ao tecto do balde

interface Anexo { nome?: string; mime?: string; base64?: string }
interface Correio {
  para?: string
  de?: string
  assunto?: string
  recebido_em?: string
  anexos?: Anexo[]
}

/** 'joao-a1b2c3d4@contas.emdia.pt' → 'joao-a1b2c3d4' (sem etiqueta +, minúsculas) */
function parteLocal(endereco: string): string {
  const so = endereco.trim().toLowerCase().replace(/^.*</, '').replace(/>.*$/, '')
  return so.split('@')[0].split('+')[0]
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return preflight()
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido' }, 405)

  const admin = clienteAdmin()

  // ---------- (1) só o Worker entra ----------
  const segredo = await lerSegredo('correio_secret', admin)
  if (!segredo) return json({ erro: 'sem_correio_secret' }, 503)
  if (req.headers.get('x-correio-secret') !== segredo) {
    return json({ erro: 'nao_autorizado' }, 401)
  }

  let c: Correio
  try { c = await req.json() } catch { return json({ erro: 'corpo_invalido' }, 400) }
  if (!c.para || !c.de) return json({ erro: 'faltam_para_ou_de' }, 400)

  // ---------- (2) de quem é esta caixa ----------
  const local = parteLocal(c.para)
  const { data: dono, error: erroDono } = await admin
    .from('profiles').select('user_id').eq('caixa_local', local).maybeSingle()
  if (erroDono) return json({ erro: 'leitura', detalhe: erroDono.message }, 500)
  if (!dono) return json({ erro: 'caixa_desconhecida', para: local }, 404)
  const uid = dono.user_id as string

  // ---------- (3) o anexo ----------
  // Só um por e-mail: as faturas vêm uma a uma, e guardar tudo enchia o balde
  // com assinaturas e logótipos.
  let caminho: string | null = null
  let nomeAnexo: string | null = null
  let bytes: number | null = null
  let erro: string | null = null

  const candidato = (c.anexos ?? []).find((a) =>
    a.base64 && a.mime && TIPOS_QUE_SERVEM[a.mime.toLowerCase()] !== undefined
  )
  if (candidato) {
    const ext = TIPOS_QUE_SERVEM[candidato.mime!.toLowerCase()]
    let cru: Uint8Array
    try {
      const bin = atob(candidato.base64!)
      cru = new Uint8Array(bin.length)
      for (let i = 0; i < bin.length; i++) cru[i] = bin.charCodeAt(i)
    } catch {
      return json({ erro: 'anexo_nao_e_base64' }, 400)
    }
    if (cru.length > MAX_BYTES) {
      erro = 'O anexo é maior do que 10 MB e não coube.'
    } else {
      nomeAnexo = (candidato.nome ?? `fatura.${ext}`).slice(0, 120)
      caminho = `${uid}/${crypto.randomUUID()}.${ext}`
      bytes = cru.length
      const { error: erroUp } = await admin.storage.from('faturas')
        .upload(caminho, cru, { contentType: candidato.mime!.toLowerCase(), upsert: false })
      if (erroUp) {
        caminho = null
        bytes = null
        erro = `Não deu para guardar o anexo: ${erroUp.message}`.slice(0, 300)
      }
    }
  } else if ((c.anexos ?? []).length > 0) {
    erro = 'O e-mail trazia anexos, mas nenhum era PDF nem foto.'
  } else {
    erro = 'O e-mail veio sem anexo. Reencaminha o original, com a fatura agarrada.'
  }

  // ---------- (4) a linha na caixa ----------
  const { data: linha, error: erroIns } = await admin
    .from('faturas_recebidas')
    .insert({
      user_id: uid,
      remetente: (c.de ?? '').slice(0, 300),
      assunto: (c.assunto ?? '').slice(0, 300) || null,
      recebido_em: c.recebido_em ?? new Date().toISOString(),
      anexo_caminho: caminho,
      anexo_nome: nomeAnexo,
      anexo_bytes: bytes,
      estado: caminho ? 'nova' : 'falhou',
      erro,
    })
    .select('id, estado')
    .single()
  if (erroIns) return json({ erro: 'gravar', detalhe: erroIns.message }, 500)

  return json({ ok: true, fatura_id: linha.id, estado: linha.estado, anexo: caminho !== null, erro })
})
