// Edge Function: fecho-mensal
// Fecha automaticamente o mês do Em Dia a partir do relatório financeiro da Google Play.
// Nunca inventa números: se o extrato ou as colunas não estiverem disponíveis, grava o fecho
// como sem_extrato/por_rever e deixa os valores desconhecidos a null.
import { unzipSync } from 'npm:fflate@0.8.2'
import { json, preflight } from '../_shared/cors.ts'
import { clienteAdmin, lerSegredo } from '../_shared/segredos.ts'
import { obterAccessTokenGoogle, type ServiceAccountGoogle } from '../_shared/google_oauth.ts'
import {
  calcularGooglePlay,
  fimMesIso,
  folhaDeRosto,
  inicioMes,
  mesAnteriorLisboa,
  REGRAS_CALCULO,
  type EstadoFecho,
  type ResumoFecho,
} from './_core.ts'

const BUCKET_FECHO = 'fecho-mensal'
const SCOPE_GCS = 'https://www.googleapis.com/auth/devstorage.read_only'

interface PedidoFecho {
  app?: string
  mes?: string
}

interface FicheiroGcs {
  name: string
}

function validarMes(mes: string): boolean {
  return /^\d{4}-\d{2}$/.test(mes)
}

async function autenticar(req: Request, admin: ReturnType<typeof clienteAdmin>): Promise<boolean> {
  const segredoRecebido = req.headers.get('x-cron-secret')
  if (segredoRecebido) {
    const segredoEsperado = await lerSegredo('cron_secret', admin)
    if (segredoEsperado && segredoRecebido === segredoEsperado) return true
  }
  const auth = req.headers.get('Authorization') ?? ''
  const serviceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  return Boolean(serviceRole && auth === `Bearer ${serviceRole}`)
}

async function listarFicheirosGcs(bucket: string, prefixo: string, token: string): Promise<FicheiroGcs[]> {
  const url = new URL(`https://storage.googleapis.com/storage/v1/b/${encodeURIComponent(bucket)}/o`)
  url.searchParams.set('prefix', prefixo)
  url.searchParams.set('fields', 'items(name)')
  const resp = await fetch(url, { headers: { Authorization: `Bearer ${token}` } })
  const corpo = await resp.json().catch(() => ({}))
  if (!resp.ok) throw new Error(`falha ao listar bucket Google (${resp.status}): ${JSON.stringify(corpo)}`)
  return Array.isArray(corpo.items) ? corpo.items : []
}

async function descarregarGcs(bucket: string, nome: string, token: string): Promise<Uint8Array> {
  const url = `https://storage.googleapis.com/storage/v1/b/${encodeURIComponent(bucket)}/o/${encodeURIComponent(nome)}?alt=media`
  const resp = await fetch(url, { headers: { Authorization: `Bearer ${token}` } })
  if (!resp.ok) throw new Error(`falha ao descarregar ${nome} (${resp.status})`)
  return new Uint8Array(await resp.arrayBuffer())
}

function extrairCsvDeZip(zip: Uint8Array): string[] {
  const ficheiros = unzipSync(zip)
  const decoder = new TextDecoder('utf-8')
  return Object.entries(ficheiros)
    .filter(([nome]) => nome.toLowerCase().endsWith('.csv'))
    .map(([, bytes]) => decoder.decode(bytes))
}

async function contarAssinaturasAtivas(admin: ReturnType<typeof clienteAdmin>, mes: string): Promise<number> {
  const fim = fimMesIso(mes)
  const { count, error } = await admin
    .from('assinaturas')
    .select('id', { count: 'exact', head: true })
    .eq('estado', 'ativa')
    .lte('comecou_em', fim)
    .or(`terminou_em.is.null,terminou_em.gt.${fim}`)
  if (error) throw new Error(`falha ao contar assinaturas ativas: ${error.message}`)
  return count ?? 0
}

async function uploadTexto(admin: ReturnType<typeof clienteAdmin>, caminho: string, conteudo: string, contentType: string): Promise<string> {
  const { error } = await admin.storage.from(BUCKET_FECHO).upload(
    caminho,
    new Blob([conteudo], { type: contentType }),
    { contentType, upsert: true },
  )
  if (error) throw new Error(`falha ao gravar ${caminho}: ${error.message}`)
  return caminho
}

async function gravarFecho(admin: ReturnType<typeof clienteAdmin>, resumo: ResumoFecho): Promise<void> {
  const { error } = await admin.from('fechos_mensais').upsert({
    app: resumo.app,
    mes: inicioMes(resumo.mes),
    moeda: resumo.moeda,
    bruto: resumo.bruto,
    comissao: resumo.comissao,
    iva: resumo.iva,
    reembolsos: resumo.reembolsos,
    liquido: resumo.liquido,
    transacoes: resumo.transacoes,
    assinaturas_ativas: resumo.assinaturas_ativas,
    ficheiros: resumo.ficheiros,
    estado: resumo.estado,
    motivo: resumo.motivo,
    criado_em: new Date().toISOString(),
  }, { onConflict: 'app,mes' })
  if (error) throw new Error(`falha ao gravar fechos_mensais: ${error.message}`)
}

async function fecharMes(admin: ReturnType<typeof clienteAdmin>, app: string, mes: string): Promise<ResumoFecho> {
  const base = `${app}/${mes}`
  const ficheiros: string[] = []
  const assinaturasAtivas = await contarAssinaturasAtivas(admin, mes)
  let resumo: ResumoFecho

  const saBruto = await lerSegredo('play_service_account', admin)
  const bucketGoogle = await lerSegredo('play_relatorios_bucket', admin)
  if (!saBruto || !bucketGoogle) {
    const motivo = `Sem extrato da Google: ${!bucketGoogle ? 'segredo play_relatorios_bucket em falta' : 'segredo play_service_account em falta'}.`
    resumo = {
      app,
      mes,
      moeda: null,
      bruto: null,
      comissao: null,
      iva: null,
      reembolsos: null,
      liquido: null,
      transacoes: 0,
      assinaturas_ativas: assinaturasAtivas,
      ficheiros,
      estado: 'sem_extrato',
      motivo,
      regras_calculo: REGRAS_CALCULO,
    }
  } else {
    let serviceAccount: ServiceAccountGoogle
    try {
      serviceAccount = JSON.parse(saBruto)
    } catch {
      throw new Error('play_service_account não é JSON válido')
    }
    const token = await obterAccessTokenGoogle(serviceAccount, [SCOPE_GCS])
    const yyyymm = mes.replace('-', '')
    const encontrados = await listarFicheirosGcs(bucketGoogle, `earnings/earnings_${yyyymm}-`, token)
    if (encontrados.length === 0) {
      resumo = {
        app,
        mes,
        moeda: null,
        bruto: null,
        comissao: null,
        iva: null,
        reembolsos: null,
        liquido: null,
        transacoes: 0,
        assinaturas_ativas: assinaturasAtivas,
        ficheiros,
        estado: 'sem_extrato',
        motivo: `Sem extrato da Google: nenhum ficheiro earnings/earnings_${yyyymm}-*.zip encontrado.`,
        regras_calculo: REGRAS_CALCULO,
      }
    } else {
      const csvs: string[] = []
      const nomes: string[] = []
      for (const f of encontrados) {
        const zip = await descarregarGcs(bucketGoogle, f.name, token)
        csvs.push(...extrairCsvDeZip(zip))
        nomes.push(f.name)
      }
      const csv = csvs.join('\n')
      if (!csv.trim()) {
        resumo = {
          app,
          mes,
          moeda: null,
          bruto: null,
          comissao: null,
          iva: null,
          reembolsos: null,
          liquido: null,
          transacoes: 0,
          assinaturas_ativas: assinaturasAtivas,
          ficheiros,
          estado: 'por_rever',
          motivo: `ZIP encontrado (${nomes.join(', ')}), mas sem CSV legível.`,
          regras_calculo: REGRAS_CALCULO,
        }
      } else {
        const caminhoExtrato = await uploadTexto(admin, `${base}/extrato-google.csv`, csv, 'text/csv')
        ficheiros.push(caminhoExtrato)
        const calculado = calcularGooglePlay(csv)
        resumo = {
          app,
          mes,
          ...calculado,
          assinaturas_ativas: assinaturasAtivas,
          ficheiros,
          motivo: calculado.motivo ?? `Extrato lido de: ${nomes.join(', ')}.`,
          regras_calculo: REGRAS_CALCULO,
        }
      }
    }
  }

  const caminhoResumo = `${base}/resumo.json`
  const caminhoFolha = `${base}/folha-de-rosto.md`
  if (!resumo.ficheiros.includes(caminhoResumo)) resumo.ficheiros.push(caminhoResumo)
  if (!resumo.ficheiros.includes(caminhoFolha)) resumo.ficheiros.push(caminhoFolha)
  const resumoJson = JSON.stringify(resumo, null, 2)
  await uploadTexto(admin, caminhoResumo, resumoJson, 'application/json')
  await uploadTexto(admin, caminhoFolha, folhaDeRosto(resumo), 'text/markdown')
  await gravarFecho(admin, resumo)
  return resumo
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return preflight()
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido', mensagem: 'Usa POST.' }, 405)

  const admin = clienteAdmin()
  if (!await autenticar(req, admin)) {
    return json({ erro: 'nao_autorizado', mensagem: 'Só o cron (x-cron-secret) ou a service role podem chamar esta função.' }, 401)
  }

  let pedido: PedidoFecho = {}
  try { pedido = await req.json() } catch { /* corpo vazio é válido */ }
  const app = pedido.app ?? 'em-dia'
  if (app !== 'em-dia') return json({ erro: 'app_nao_ligada', mensagem: 'bora ainda não ligado ao fecho mensal.' }, 400)
  const mes = pedido.mes ?? mesAnteriorLisboa()
  if (!validarMes(mes)) return json({ erro: 'mes_invalido', mensagem: 'Usa o formato AAAA-MM.' }, 400)

  try {
    const resumo = await fecharMes(admin, app, mes)
    return json(resumo)
  } catch (e) {
    const motivo = (e as Error).message
    const resumoErro: ResumoFecho = {
      app,
      mes,
      moeda: null,
      bruto: null,
      comissao: null,
      iva: null,
      reembolsos: null,
      liquido: null,
      transacoes: 0,
      assinaturas_ativas: 0,
      ficheiros: [],
      estado: 'erro' as EstadoFecho,
      motivo,
      regras_calculo: REGRAS_CALCULO,
    }
    try { await gravarFecho(admin, resumoErro) } catch (erroGravar) { console.error('gravar erro falhou', (erroGravar as Error).message) }
    return json({ erro: 'fecho_mensal_falhou', mensagem: motivo }, 500)
  }
})
