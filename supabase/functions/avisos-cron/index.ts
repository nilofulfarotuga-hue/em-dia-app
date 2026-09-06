// Edge Function: avisos-cron
// Os avisos push diários do Em Dia. O pg_cron chama-a de hora a hora (header x-cron-secret
// = Vault 'cron_secret', Authorization = anon). Só age às push_hora_lisboa (regras_legais, 9h de
// Lisboa) — ou sempre que um admin chame com { forcar: true } para testar.
//
// Fluxo: autenticar → hora de Lisboa → marcar_obrigacoes_passadas() → por utilizador calcular os
// avisos de hoje → registar em eventos_push (1 por obrigação por dia) → 1 push por utilizador
// (agrupado se houver vários) via FCM HTTP v1. Sem credenciais FCM regista 'sem_fcm'; sem tokens
// regista 'sem_token'; erro regista 'erro' + texto. Nunca inventa números: lê regras_legais.
import { json, preflight } from '../_shared/cors.ts'
import { clienteAdmin, clienteUtilizador, lerSegredo } from '../_shared/segredos.ts'
import { MENSAGENS, formatarData, formatarMoeda, nomeMes, type TipoAviso, type VariantePt } from '../_shared/mensagens.ts'
import { carregarFcm, enviarFcm } from '../_shared/fcm.ts'

const FLAG_PUSH = 'avisos_push'
const DIAS_ANTES_5 = 5           // aviso '5_dias'
const DIAS_TRIAL_AVISO = 5       // 'trial_25' = trial_ate - 5 dias (trial de 30 → dia 25)
const DIAS_REATIVACAO = 7        // 'reativacao' após 7 dias sem abrir a app
const TZ = 'Europe/Lisbon'

interface Aviso {
  tipo: TipoAviso
  obrigacao_id: string | null
  titulo: string
  corpo: string
}

// ---------- datas em Lisboa (o horário de verão/inverno nunca engana) ----------
function agoraLisboa(): { hora: number; data: string } {
  const partes = new Intl.DateTimeFormat('en-GB', {
    timeZone: TZ, hour12: false, year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit',
  }).formatToParts(new Date())
  const p = (t: string) => partes.find((x) => x.type === t)?.value ?? '00'
  return { hora: Number(p('hour')) % 24, data: `${p('year')}-${p('month')}-${p('day')}` }
}
function dataLisboaDe(iso: string): string {
  const partes = new Intl.DateTimeFormat('en-GB', { timeZone: TZ, year: 'numeric', month: '2-digit', day: '2-digit' })
    .formatToParts(new Date(iso))
  const p = (t: string) => partes.find((x) => x.type === t)?.value ?? '00'
  return `${p('year')}-${p('month')}-${p('day')}`
}
/** soma dias a uma data 'aaaa-mm-dd' (aritmética em UTC, sem fuso) */
function somarDias(iso: string, dias: number): string {
  const d = new Date(`${iso}T00:00:00Z`)
  d.setUTCDate(d.getUTCDate() + dias)
  return d.toISOString().slice(0, 10)
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return preflight()
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido' }, 405)

  const admin = clienteAdmin()

  // ---------- (1) autenticação: segredo do cron OU admin com JWT ----------
  let autenticado: 'cron' | 'admin' | null = null
  const segredoRecebido = req.headers.get('x-cron-secret')
  if (segredoRecebido) {
    const segredoEsperado = await lerSegredo('cron_secret', admin)
    if (segredoEsperado && segredoRecebido === segredoEsperado) autenticado = 'cron'
  }
  if (!autenticado && req.headers.get('Authorization')) {
    const supaUser = clienteUtilizador(req)
    const { data: { user } } = await supaUser.auth.getUser()
    if (user) {
      const { data: ehAdmin } = await supaUser.rpc('is_admin')
      if (ehAdmin === true) autenticado = 'admin'
    }
  }
  if (!autenticado) {
    return json({ erro: 'nao_autorizado', mensagem: 'Só o cron (x-cron-secret) ou um admin podem chamar esta função.' }, 401)
  }

  let corpoPedido: { forcar?: boolean } = {}
  try { corpoPedido = await req.json() } catch { /* corpo vazio é normal (pg_cron manda {"origem":"pg_cron"}) */ }
  const forcar = corpoPedido?.forcar === true

  // ---------- regras legais (a única fonte de números) ----------
  const { data: regras, error: erroRegras } = await admin
    .from('regras_legais').select('chave, valor_num, valor_json')
    .in('chave', ['push_hora_lisboa', 'iva_isencao_aviso', 'ipo_avisos_dias'])
  if (erroRegras) return json({ erro: 'regras_legais', detalhe: erroRegras.message }, 500)
  const regra = (chave: string) => regras?.find((r) => r.chave === chave)
  const pushHora = Number(regra('push_hora_lisboa')?.valor_num)
  const ivaAviso = Number(regra('iva_isencao_aviso')?.valor_num)
  const ipoDias: number[] = Array.isArray(regra('ipo_avisos_dias')?.valor_json)
    ? (regra('ipo_avisos_dias')!.valor_json as number[]).map(Number) : []
  if (!Number.isFinite(pushHora)) return json({ erro: 'sem_regra_push_hora_lisboa' }, 500)

  // ---------- (2) hora de Lisboa ----------
  const { hora, data: hoje } = agoraLisboa()
  if (hora !== pushHora && !forcar) {
    return json({ saltado: true, hora_lisboa: hora, data_lisboa: hoje, hora_push: pushHora })
  }

  // ---------- (3) marcar como 'passado' o que venceu ----------
  const { data: passadasMarcadas, error: erroPassadas } = await admin.rpc('marcar_obrigacoes_passadas')
  if (erroPassadas) console.error('marcar_obrigacoes_passadas:', erroPassadas.message)

  // ---------- (4) dados em bloco ----------
  const hojeMais5 = somarDias(hoje, DIAS_ANTES_5)
  const datasIpo = ipoDias.map((d) => somarDias(hoje, d))
  const inicioAno = `${hoje.slice(0, 4)}-01-01`
  const inicioMes = `${hoje.slice(0, 7)}-01`
  const ha7Dias = somarDias(hoje, -DIAS_REATIVACAO)
  // Os eventos carregam-se desde a data MAIS ANTIGA entre o início do mês (vigia_iva e limite do
  // plano são "este mês") e há 7 dias (reativacao é "últimos 7 dias"). Só com o início do mês, um
  // reativacao enviado a 31 ficava invisível no dia 1-6 e repetia-se (bug encontrado na verificação).
  const inicioEventos = ha7Dias < inicioMes ? ha7Dias : inicioMes

  const [perfis, obrigs, rendimentos, eventosMes, eventosTrial31, tokensTodos] = await Promise.all([
    admin.from('profiles')
      .select('user_id, variante_pt, regime_iva, trial_ate, ultimo_acesso, plano')
      .eq('banido', false),
    // tudo o que pode gerar aviso hoje: pendentes (5 dias / hoje / ipo) e passadas
    admin.from('obrigacoes')
      .select('id, user_id, tipo, descricao, data_limite, aviso_em, valor_estimado, estado, carro_id, carros(matricula)')
      .or([
        `and(estado.eq.pendente,data_limite.eq.${hojeMais5})`,
        `and(estado.eq.pendente,aviso_em.eq.${hoje})`,
        `estado.eq.passado`,
        ...(datasIpo.length ? [`and(estado.eq.pendente,tipo.eq.ipo,data_limite.in.(${datasIpo.join(',')}))`] : []),
      ].join(',')),
    admin.from('rendimentos').select('user_id, valor_bruto').gte('mes', inicioAno),
    admin.from('eventos_push').select('user_id, tipo, dia, resultado').gte('dia', inicioEventos),
    admin.from('eventos_push').select('user_id').eq('tipo', 'trial_31'),
    admin.from('push_tokens').select('user_id, token'),
  ])
  for (const r of [perfis, obrigs, rendimentos, eventosMes, eventosTrial31, tokensTodos]) {
    if (r.error) return json({ erro: 'leitura', detalhe: r.error.message }, 500)
  }

  const somaAno = new Map<string, number>()
  for (const r of rendimentos.data ?? []) somaAno.set(r.user_id, (somaAno.get(r.user_id) ?? 0) + Number(r.valor_bruto))
  const tokensPor = new Map<string, string[]>()
  for (const t of tokensTodos.data ?? []) tokensPor.set(t.user_id, [...(tokensPor.get(t.user_id) ?? []), t.token])
  const jaTrial31 = new Set((eventosTrial31.data ?? []).map((e) => e.user_id))
  // todos os eventos carregados do utilizador (desde inicioEventos) e só os deste mês
  const eventosDoUser = (uid: string) => (eventosMes.data ?? []).filter((e) => e.user_id === uid)

  const fcm = await carregarFcm(admin)

  const totais = { utilizadores: 0, eventos_criados: 0, enviados: 0, sem_fcm: 0, sem_token: 0, limite_plano: 0, erros: 0 }
  const detalhes: Record<string, unknown>[] = []

  for (const p of perfis.data ?? []) {
    totais.utilizadores++
    const uid = p.user_id as string
    const variante: VariantePt = p.variante_pt === 'br' ? 'br' : 'pt'
    const T = MENSAGENS[variante]
    const eventos = eventosDoUser(uid)                          // desde inicioEventos (≥ 7 dias)
    const eventosMesUser = eventos.filter((e) => e.dia >= inicioMes)  // só este mês
    const jaHoje = (tipo: string) => eventos.some((e) => e.tipo === tipo && e.dia === hoje)
    const avisos: Aviso[] = []

    // obrigações
    for (const o of (obrigs.data ?? []).filter((x) => x.user_id === uid)) {
      const valor = formatarMoeda(o.valor_estimado) ?? T.valorPorConfirmar
      if (o.tipo === 'fim_isencao_ss') {
        if (o.estado === 'pendente' && o.aviso_em === hoje) {
          avisos.push({ tipo: 'fim_isencao', obrigacao_id: o.id, titulo: T.titulos.fim_isencao,
            corpo: T.pushFimIsencao(nomeMes(o.data_limite, variante), valor) })
        }
        continue
      }
      if (o.tipo === 'ipo' && o.estado === 'pendente' && datasIpo.includes(o.data_limite)) {
        // deno-lint-ignore no-explicit-any
        const carro = o.carros as any
        const matricula = (Array.isArray(carro) ? carro[0]?.matricula : carro?.matricula) ?? '—'
        avisos.push({ tipo: 'carro', obrigacao_id: o.id, titulo: T.titulos.carro,
          corpo: T.pushCarro(matricula, formatarData(o.data_limite)) })
        // uma ipo com data_limite = hoje+7 pode também cair no '5_dias'? não: 7 ≠ 5. segue.
      }
      if (o.estado === 'passado') {
        avisos.push({ tipo: 'passado', obrigacao_id: o.id, titulo: T.titulos.passado,
          corpo: T.pushPassado(formatarData(o.data_limite)) })
        continue
      }
      if (o.estado !== 'pendente') continue
      if (o.data_limite === hojeMais5) {
        avisos.push({ tipo: '5_dias', obrigacao_id: o.id, titulo: T.titulos['5_dias'], corpo: T.push5Dias(o.descricao, valor) })
      }
      if (o.aviso_em === hoje) {
        avisos.push({ tipo: 'dia', obrigacao_id: o.id, titulo: T.titulos.dia, corpo: T.pushDia(o.descricao, valor) })
      }
    }

    // vigia do IVA (só faz sentido para quem está isento pelo art. 53.º): 1 vez por mês
    const soma = somaAno.get(uid) ?? 0
    if (p.regime_iva === 'isento_53' && Number.isFinite(ivaAviso) && soma >= ivaAviso
        && !eventosMesUser.some((e) => e.tipo === 'vigia_iva')) {
      avisos.push({ tipo: 'vigia_iva', obrigacao_id: null, titulo: T.titulos.vigia_iva, corpo: T.pushVigiaIva(formatarMoeda(soma)!) })
    }

    // trial: 5 dias antes de acabar; e uma única vez depois de acabar (se não tiver plano pago)
    if (p.trial_ate) {
      const trialAte = new Date(p.trial_ate)
      const diaAviso = dataLisboaDe(new Date(trialAte.getTime() - DIAS_TRIAL_AVISO * 86400_000).toISOString())
      if (diaAviso === hoje && !jaHoje('trial_25')) {
        avisos.push({ tipo: 'trial_25', obrigacao_id: null, titulo: T.titulos.trial_25, corpo: T.pushTrial25 })
      }
      if (trialAte.getTime() < Date.now() && !jaTrial31.has(uid) && !jaHoje('trial_31')) {
        const { data: planoEfetivo } = await admin.rpc('plano_efetivo', { uid })
        if (planoEfetivo !== 'pro' && planoEfetivo !== 'familia') {
          avisos.push({ tipo: 'trial_31', obrigacao_id: null, titulo: T.titulos.trial_31, corpo: T.pushTrial31 })
        }
      }
    }

    // reativação: ≥ 7 dias sem abrir a app e sem aviso destes nos últimos 7 dias
    if (p.ultimo_acesso && dataLisboaDe(p.ultimo_acesso) <= ha7Dias
        && !eventos.some((e) => e.tipo === 'reativacao' && e.dia >= ha7Dias)) {
      avisos.push({ tipo: 'reativacao', obrigacao_id: null, titulo: T.titulos.reativacao, corpo: T.pushReativacao })
    }

    if (avisos.length === 0) continue

    // ---------- registar eventos (a unique (user_id,tipo,dia,obrigacao_id) impede repetir) ----------
    // Desde a migração 0005 a unique é NULLS NOT DISTINCT: também trava os tipos sem obrigação
    // (obrigacao_id NULL). Os filtros acima (jaHoje, vigia_iva do mês, reativacao 7 dias) continuam
    // a evitar a tentativa; a base de dados é a rede de segurança.
    const { data: inseridos, error: erroIns } = await admin
      .from('eventos_push')
      .upsert(
        avisos.map((a) => ({ user_id: uid, obrigacao_id: a.obrigacao_id, tipo: a.tipo, dia: hoje, titulo: a.titulo, corpo: a.corpo })),
        { onConflict: 'user_id,tipo,dia,obrigacao_id', ignoreDuplicates: true },
      )
      .select('id, tipo, obrigacao_id, titulo, corpo')
    if (erroIns) {
      console.error('eventos_push insert:', erroIns.message)
      totais.erros++
      detalhes.push({ user_id: uid, erro: erroIns.message })
      continue
    }
    if (!inseridos || inseridos.length === 0) continue   // tudo já enviado hoje
    totais.eventos_criados += inseridos.length
    const ids = inseridos.map((e) => e.id)

    // ---------- limite do plano (free = N avisos/mês; trial/pro/família = sem limite) ----------
    const { data: limite } = await admin.rpc('feature_limite', { uid, flag: FLAG_PUSH })
    const okEsteMes = eventosMesUser.filter((e) => e.resultado === 'ok').length
    if (limite !== null && limite !== undefined && okEsteMes >= Number(limite)) {
      await admin.from('eventos_push').update({ resultado: 'limite_plano' }).in('id', ids)
      totais.limite_plano += inseridos.length
      detalhes.push({ user_id: uid, eventos: inseridos.length, resultado: 'limite_plano', limite, ok_este_mes: okEsteMes })
      continue
    }

    // ---------- 1 push por utilizador (agrupado se houver vários) ----------
    const titulo = inseridos.length === 1 ? inseridos[0].titulo : T.varias(inseridos.length)
    const corpo = inseridos.length === 1 ? inseridos[0].corpo : inseridos.map((e) => `• ${e.corpo}`).join('\n')
    const dataPush: Record<string, string> = {
      tipo: inseridos.length === 1 ? inseridos[0].tipo : 'varios',
      obrigacao_id: inseridos.find((e) => e.obrigacao_id)?.obrigacao_id ?? '',
      n: String(inseridos.length),
    }

    const tokens = tokensPor.get(uid) ?? []
    let resultado: string
    let erro: string | null = null
    if (!fcm) {
      resultado = 'sem_fcm'
      erro = 'Sem credenciais FCM no Vault (fcm_service_account). O aviso ficou registado mas não foi enviado.'
    } else if (tokens.length === 0) {
      resultado = 'sem_token'
    } else {
      const r = await enviarFcm(fcm, tokens, titulo, corpo, dataPush)
      resultado = r.ok ? 'ok' : 'erro'
      erro = r.erro ?? null
      if (r.tokensInvalidos.length) {
        await admin.from('push_tokens').delete().in('token', r.tokensInvalidos)
      }
    }
    await admin.from('eventos_push').update({ resultado, erro, enviado_em: new Date().toISOString() }).in('id', ids)
    if (resultado === 'ok') totais.enviados += inseridos.length
    else if (resultado === 'sem_fcm') totais.sem_fcm += inseridos.length
    else if (resultado === 'sem_token') totais.sem_token += inseridos.length
    else totais.erros += inseridos.length
    detalhes.push({ user_id: uid, eventos: inseridos.length, tipos: inseridos.map((e) => e.tipo), resultado, tokens: tokens.length })
  }

  return json({
    hora_lisboa: hora,
    data_lisboa: hoje,
    forcado: forcar,
    autenticado,
    fcm_configurado: fcm !== null,
    ...totais,
    passadas_marcadas: passadasMarcadas ?? 0,
    detalhes,
  })
})
