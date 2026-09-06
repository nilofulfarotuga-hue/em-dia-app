// Edge Function: vigia-ligacoes
//
// Uma vez por semana, vai ver se os endereços do Estado que a app usa ainda
// existem. Chamada pelo pg_cron com o mesmo `x-cron-secret` do avisos-cron, ou
// por um admin com `{ forcar: true }`.
//
// PORQUE É QUE ISTO NÃO É UM PING:
//
// Está provado que o Portal das Finanças devolve **302 para o login** mesmo
// para caminhos inventados (`/recibos/portal/xxxx-nao-existe-zzz`), e que a
// Segurança Social devolve **200** para `/ptss/pssd/menu/xpto-nao-existe`.
// Um vigia que olhe para o código HTTP fica verde para sempre num link morto —
// é o mesmo falso positivo que deixou um robô do Bora a devolver 200 durante
// oito dias enquanto falhava por dentro.
//
// O que funciona: descarregar o **mapa do site** da AT, que é HTML servido
// pelo servidor (não é JavaScript), tirar de lá todos os `<a href>`, e ver se
// os nossos continuam lá.
//
// DUAS TRAVAS DE SANIDADE, e são o mais importante deste ficheiro: se o mapa
// vier com menos de 300 KB ou com menos de 200 ligações, **não é o Estado que
// mudou — é o descarregamento que falhou.** Nesse caso não se alarma, não se
// desliga nada, e regista-se `saltado = true`. Um vigia que grita quando a
// rede falha ensina toda a gente a ignorá-lo.
//
// A Segurança Social não tem vigia automático possível (a área com sessão é
// gerada por sessão e o login tem reCAPTCHA). Fica revisão humana trimestral,
// alinhada com os prazos: janeiro, abril, julho e outubro.
import { json, preflight } from '../_shared/cors.ts'
import { clienteAdmin, clienteUtilizador, lerSegredo } from '../_shared/segredos.ts'

const MAPA = 'https://sitfiscal.portaldasfinancas.gov.pt/geral/siteMap'
const MINIMO_BYTES = 300_000
const MINIMO_LIGACOES = 200
const AGENTE = 'EmDia/1.0 (vigia dos enderecos do Estado)'

/** Tira todos os href de um HTML, sem depender de nenhuma biblioteca. */
function ligacoesDe(html: string): string[] {
  const achadas: string[] = []
  const re = /href\s*=\s*["']([^"']+)["']/gi
  let m: RegExpExecArray | null
  while ((m = re.exec(html)) !== null) achadas.push(m[1])
  return achadas
}

/** Compara pelo caminho, não pelo endereço todo: o domínio muda de sub-portal. */
function caminhoDe(url: string): string {
  try {
    return new URL(url, 'https://sitfiscal.portaldasfinancas.gov.pt').pathname.replace(/\/+$/, '')
  } catch {
    return url
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return preflight()
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido' }, 405)

  const admin = clienteAdmin()

  // ---------- autenticação: o cron ou um admin ----------
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

  // ---------- as nossas ligações ----------
  const { data: nossas, error: erroLer } = await admin
    .from('ligacoes_estado')
    .select('chave, url, entidade, ativa')
    .eq('entidade', 'financas')
    .eq('ativa', true)
  if (erroLer) return json({ erro: 'leitura', detalhe: erroLer.message }, 500)

  // ---------- o mapa do site ----------
  let html = ''
  let erroRede: string | null = null
  try {
    const r = await fetch(MAPA, { headers: { 'User-Agent': AGENTE } })
    if (!r.ok) erroRede = `mapa devolveu ${r.status}`
    else html = await r.text()
  } catch (e) {
    erroRede = (e as Error).message
  }

  const bytes = new TextEncoder().encode(html).length
  const doMapa = ligacoesDe(html)

  // ---------- as travas ----------
  if (erroRede || bytes < MINIMO_BYTES || doMapa.length < MINIMO_LIGACOES) {
    const nota = erroRede
      ? `Não deu para ir buscar o mapa: ${erroRede}. Não se conclui nada.`
      : `O mapa veio pequeno demais (${bytes} bytes, ${doMapa.length} ligações). ` +
        `Isto é o descarregamento a falhar, não o Estado a mudar — não se alarma.`
    await admin.from('ligacoes_estado_vigia').insert({
      mapa_bytes: bytes, mapa_ligacoes: doMapa.length, verificadas: 0,
      em_falta: [], saltado: true, nota,
    })
    return json({ saltado: true, nota, mapa_bytes: bytes, mapa_ligacoes: doMapa.length })
  }

  // ---------- a comparação ----------
  const caminhosDoMapa = new Set(doMapa.map(caminhoDe))
  const emFalta: string[] = []
  for (const l of nossas ?? []) {
    if (!caminhosDoMapa.has(caminhoDe(l.url))) emFalta.push(l.chave)
  }

  const nota = emFalta.length === 0
    ? 'Todos os endereços das Finanças continuam no mapa do site.'
    : `Sumiram do mapa do site: ${emFalta.join(', ')}. ` +
      `Ver à mão antes de mexer — o mapa também muda de forma, e um endereço ` +
      `pode ter mudado de sítio sem ter morrido.`

  await admin.from('ligacoes_estado_vigia').insert({
    mapa_bytes: bytes, mapa_ligacoes: doMapa.length,
    verificadas: nossas?.length ?? 0, em_falta: emFalta, saltado: false, nota,
  })

  return json({
    autenticado,
    mapa_bytes: bytes,
    mapa_ligacoes: doMapa.length,
    verificadas: nossas?.length ?? 0,
    em_falta: emFalta,
    nota,
  })
})