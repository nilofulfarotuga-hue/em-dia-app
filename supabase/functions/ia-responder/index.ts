// Edge Function ia-responder — o assistente da app.
// POST { pergunta, modo?: 'chat'|'suporte' } com JWT do utilizador.
// 401 sem sessão · 402 { limite: true, usadas, limite } quando o plano esgotou as perguntas do mês
// · 503 { erro: 'sem_gemini_api_key' } sem chave · 200 { resposta, variante, fora_das_regras, usadas, limite }.
import { json, preflight } from '../_shared/cors.ts'
import { clienteAdmin, clienteUtilizador } from '../_shared/segredos.ts'
import { inicioMesLisboaISO, responderComIA, type ModoIA } from '../_shared/contexto_ia.ts'

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return preflight()
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido', mensagem: 'Usa POST.' }, 405)

  // 1) utilizador autenticado
  const supa = clienteUtilizador(req)
  const { data: { user } } = await supa.auth.getUser()
  if (!user) return json({ erro: 'nao_autenticado', mensagem: 'Sessão inválida. Inicia sessão outra vez.' }, 401)

  // 2) corpo
  let corpo: any
  try { corpo = await req.json() } catch {
    return json({ erro: 'corpo_invalido', mensagem: 'O corpo do pedido tem de ser JSON.' }, 400)
  }
  const pergunta = typeof corpo?.pergunta === 'string' ? corpo.pergunta.trim() : ''
  if (!pergunta) return json({ erro: 'pergunta_em_falta', mensagem: 'Escreve a tua pergunta.' }, 400)
  if (pergunta.length > 2000) return json({ erro: 'pergunta_demasiado_longa', mensagem: 'A pergunta tem de ter no máximo 2000 caracteres.' }, 400)
  const modo: ModoIA = corpo?.modo === 'suporte' ? 'suporte' : 'chat'

  const admin = clienteAdmin()

  // 3) limite mensal do plano (feature_limite null = sem limite). Conta só as perguntas de chat.
  const { data: limiteData, error: eLim } = await admin.rpc('feature_limite', { uid: user.id, flag: 'ia_perguntas' })
  if (eLim) console.error('feature_limite falhou:', eLim.message)
  const limite: number | null = limiteData === null || limiteData === undefined ? null : Number(limiteData)

  const { count } = await admin.from('conversas_ia')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', user.id).eq('modo', 'chat')
    .gte('criado_em', inicioMesLisboaISO())
  const usadas = count ?? 0

  if (limite !== null && usadas >= limite) {
    return json({
      limite: true, usadas, limite_valor: limite,
      mensagem: `Já usaste as ${limite} perguntas grátis deste mês. Com o plano Pro as perguntas são ilimitadas.`,
    }, 402)
  }

  // 4) perguntar ao modelo com o contexto todo
  const r = await responderComIA(admin, user.id, pergunta, modo)
  if (!r.ok) {
    return json({ erro: r.erro, detalhe: r.detalhe, mensagem: r.mensagem }, r.status)
  }

  return json({
    resposta: r.resposta,
    variante: r.variante,
    fora_das_regras: r.fora_das_regras,
    usadas: modo === 'chat' ? usadas + 1 : usadas,
    limite,
  })
})
