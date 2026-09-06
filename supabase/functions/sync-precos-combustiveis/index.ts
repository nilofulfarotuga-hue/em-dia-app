// Edge Function: sync-precos-combustiveis
//
// Vai buscar os preços de combustível ao portal oficial da DGEG. **Escrito e
// provado, mas DESLIGADO** — e o motivo não é técnico, é legal.
//
// O portal diz, com todas as letras, que "é proibida a sua utilização para
// fins comerciais", e tem um processo formal ("Partilha de Informação") com
// uma minuta que tem de ser assinada e enviada por e-mail à DGEG. O Em Dia
// cobra 3,49 €/mês: é uma app comercial. Sem essa assinatura isto não pode
// alimentar a app, por muito que a API esteja aberta.
//
// Por isso esta função tem dois modos, e quem manda é o interruptor
// `feature_flags.precos_combustivel`:
//
//   DESLIGADO (hoje) → **corrida em seco**: vai buscar, conta o que veio,
//                      escreve o número no registo, e NÃO GUARDA UM ÚNICO
//                      PREÇO. Serve para provar que o robô funciona sem usar
//                      comercialmente aquilo que ainda não é nosso.
//   LIGADO           → guarda os postos e os preços nas tabelas.
//
// A API não precisa de chave nem de cookie. `qtdPorPagina` aceita 99999 e
// devolve o país todo de uma vez — não é preciso andar distrito a distrito.
import { json, preflight } from '../_shared/cors.ts'
import { clienteAdmin, clienteUtilizador, lerSegredo } from '../_shared/segredos.ts'

const API = 'https://precoscombustiveis.dgeg.gov.pt/api/PrecoComb/PesquisarPostos?qtdPorPagina=99999&pagina=1'
const FLAG = 'precos_combustivel'
// Travão de queda, como no leitor do PDF do IMT: se vier muito menos do que o
// habitual, não é o país a fechar bombas — é o download a falhar.
const MINIMO_LINHAS = 5000

interface LinhaDgeg {
  Id: number
  Nome?: string
  Marca?: string
  TipoPosto?: string
  Distrito?: string
  Municipio?: string
  Localidade?: string
  Morada?: string
  CodPostal?: string
  Latitude?: number
  Longitude?: number
  Combustivel?: string
  Preco?: string
  DataAtualizacao?: string
}

/** "0,840 €" → 0.84. Devolve null quando não dá para ler. */
function preco(texto: string | undefined): number | null {
  if (!texto) return null
  const n = Number(texto.replace('€', '').replace(/\s/g, '').replace(',', '.'))
  return Number.isFinite(n) && n > 0 ? n : null
}

/** "2026-08-31 15:40" → ISO. A DGEG dá hora de Lisboa, sem fuso. */
function quando(texto: string | undefined): string | null {
  if (!texto || texto.length < 16) return null
  const d = new Date(texto.replace(' ', 'T') + ':00')
  return Number.isNaN(d.getTime()) ? null : d.toISOString()
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return preflight()
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido' }, 405)

  const admin = clienteAdmin()

  let autenticado: 'cron' | 'admin' | null = null
  const segredoRecebido = req.headers.get('x-cron-secret')
  if (segredoRecebido) {
    const esperado = await lerSegredo('cron_secret', admin)
    if (esperado && segredoRecebido === esperado) autenticado = 'cron'
  }
  if (!autenticado && req.headers.get('Authorization')) {
    const supaUser = clienteUtilizador(req)
    const { data: { user } } = await supaUser.auth.getUser()
    if (user) {
      const { data: ehAdmin } = await supaUser.rpc('is_admin')
      if (ehAdmin === true) autenticado = 'admin'
    }
  }
  if (!autenticado) return json({ erro: 'nao_autorizado' }, 401)

  // ---------- o interruptor manda ----------
  const { data: flag } = await admin
    .from('feature_flags').select('free, pro, familia').eq('chave', FLAG).maybeSingle()
  const ligada = flag ? (flag.free || flag.pro || flag.familia) : false

  const comeco = Date.now()
  let linhas: LinhaDgeg[] = []
  try {
    const r = await fetch(API, {
      headers: { 'User-Agent': 'EmDia/1.0 (app dos recibos verdes)', 'Accept': 'application/json' },
    })
    if (!r.ok) throw new Error(`a DGEG devolveu ${r.status}`)
    const corpo = await r.json()
    linhas = (corpo?.resultado ?? corpo?.Resultado ?? []) as LinhaDgeg[]
  } catch (e) {
    const nota = `Não deu para ir buscar os preços: ${(e as Error).message}`
    await admin.from('precos_combustivel_sync').insert({
      linhas: 0, postos: 0, gravou: false, ms: Date.now() - comeco, nota,
    })
    return json({ erro: 'dgeg', nota }, 502)
  }

  const postos = new Map<number, LinhaDgeg>()
  for (const l of linhas) if (l?.Id != null && !postos.has(l.Id)) postos.set(l.Id, l)

  // ---------- travão de queda ----------
  if (linhas.length < MINIMO_LINHAS) {
    const nota = `Vieram só ${linhas.length} linhas (o normal são mais de 14.000). ` +
      `Isto é o download a falhar, não o país a fechar bombas — não se grava nada.`
    await admin.from('precos_combustivel_sync').insert({
      linhas: linhas.length, postos: postos.size, gravou: false, ms: Date.now() - comeco, nota,
    })
    return json({ saltado: true, nota, linhas: linhas.length, postos: postos.size })
  }

  // ---------- corrida em seco: conta e vai-se embora ----------
  if (!ligada) {
    const nota = 'Corrida em seco: a funcionalidade está desligada (precos_combustivel). ' +
      'Foi buscar e contou, e não guardou preço nenhum. Falta a autorização escrita da DGEG ' +
      '— o portal proíbe uso comercial sem ela.'
    await admin.from('precos_combustivel_sync').insert({
      linhas: linhas.length, postos: postos.size, gravou: false, ms: Date.now() - comeco, nota,
    })
    return json({
      seco: true, ligada: false, linhas: linhas.length, postos: postos.size,
      ms: Date.now() - comeco, nota,
    })
  }

  // ---------- ligada: guarda ----------
  const filas = [...postos.values()].map((p) => ({
    id: p.Id,
    nome: p.Nome ?? '—',
    marca: p.Marca ?? null,
    tipo_posto: p.TipoPosto ?? null,
    distrito: p.Distrito ?? null,
    municipio: p.Municipio ?? null,
    localidade: p.Localidade ?? null,
    morada: p.Morada ?? null,
    cod_postal: p.CodPostal ?? null,
    lat: p.Latitude ?? null,
    lng: p.Longitude ?? null,
    atualizado_em: new Date().toISOString(),
  }))
  // Aos pedaços: 3.000 postos numa só chamada rebenta o limite do PostgREST.
  const PEDACO = 500
  for (let i = 0; i < filas.length; i += PEDACO) {
    const { error } = await admin.from('postos_combustivel').upsert(filas.slice(i, i + PEDACO))
    if (error) return json({ erro: 'gravar_postos', detalhe: error.message }, 500)
  }

  const precos: Record<string, unknown>[] = []
  const vistos = new Set<string>()
  for (const l of linhas) {
    const v = preco(l.Preco)
    if (l?.Id == null || !l.Combustivel || v === null) continue
    const chave = `${l.Id}|${l.Combustivel}`
    if (vistos.has(chave)) continue   // a mesma bomba pode vir duas vezes
    vistos.add(chave)
    precos.push({
      posto_id: l.Id, combustivel: l.Combustivel, preco: v,
      visto_em: quando(l.DataAtualizacao), atualizado_em: new Date().toISOString(),
    })
  }
  for (let i = 0; i < precos.length; i += PEDACO) {
    const { error } = await admin.from('precos_combustivel').upsert(precos.slice(i, i + PEDACO))
    if (error) return json({ erro: 'gravar_precos', detalhe: error.message }, 500)
  }

  const ms = Date.now() - comeco
  await admin.from('precos_combustivel_sync').insert({
    linhas: precos.length, postos: filas.length, gravou: true, ms,
    nota: 'Guardado. A funcionalidade está ligada — confirma que a autorização da DGEG está mesmo assinada.',
  })
  return json({ ligada: true, gravou: true, postos: filas.length, precos: precos.length, ms })
})