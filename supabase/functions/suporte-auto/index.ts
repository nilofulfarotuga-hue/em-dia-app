// Edge Function suporte-auto — abre tickets de suporte e responde sozinha quando pode.
// POST { tipo: 'duvida'|'bug'|'reembolso'|'outro', assunto, descricao, logs? } com JWT.
// 'reembolso' → resposta fixa (Google Play) e fecha · 'duvida' → IA em modo suporte
// · 'bug' → guarda logs, aberto · escalar_humano por palavras sensíveis (+ e-mail via Resend se houver chave).
// 200 { ticket_id, resposta, escalado }.
import { json, preflight } from '../_shared/cors.ts'
import { clienteAdmin, clienteUtilizador, lerSegredo } from '../_shared/segredos.ts'
import { responderComIA } from '../_shared/contexto_ia.ts'

const TIPOS = ['duvida', 'bug', 'reembolso', 'outro']
const EMAIL_EQUIPA = 'nilofulfarotuga@gmail.com'

const RESPOSTA_REEMBOLSO = [
  'Os reembolsos e cancelamentos da assinatura do Em Dia são tratados diretamente na Google Play, não na app.',
  'Para cancelar: abre a Google Play → menu da tua conta → Pagamentos e subscrições → Subscrições → Em Dia → Cancelar.',
  'Para pedir reembolso: em play.google.com, "Pedir reembolso", na compra em causa (a Google decide em 48 horas).',
  'Depois de cancelares, continuas com o plano até ao fim do período já pago.',
  'Próximo passo: abre a Google Play e faz o pedido lá; se a Google recusar, responde a este ticket com o n.º do pedido.',
].join('\n')

// Palavras que obrigam a passar para um humano.
const SENSIVEIS_SEMPRE = [/\badvogad[oa]s?\b/i, /\bAIMA\b/, /\bprocesso\b/i, /\btribunal\b/i]
const SENSIVEIS_DINHEIRO = [/\bdinheiro\b/i, /\bcobraram\b/i, /\bpagamento\b/i, /\bcart[ãa]o\b/i]

function motivoEscala(tipo: string, texto: string): string | null {
  const s = SENSIVEIS_SEMPRE.find((r) => r.test(texto))
  if (s) return `menciona termo sensível (${texto.match(s)![0]})`
  if (tipo === 'reembolso' || tipo === 'bug') {
    const d = SENSIVEIS_DINHEIRO.find((r) => r.test(texto))
    if (d) return `${tipo} com menção a dinheiro (${texto.match(d)![0]})`
  }
  return null
}

// E-mail para a equipa via Resend. Se o domínio emdia.pt não estiver verificado, cai para onboarding@resend.dev.
async function enviarEmailResend(chave: string, assunto: string, corpoTexto: string): Promise<{ ok: boolean; detalhe: string }> {
  const enviar = async (from: string) => {
    const resp = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${chave}` },
      body: JSON.stringify({ from, to: [EMAIL_EQUIPA], subject: assunto, text: corpoTexto }),
    })
    return { status: resp.status, texto: await resp.text() }
  }
  let r = await enviar('Em Dia <suporte@emdia.pt>')
  if ((r.status === 403 || r.status === 422) && /domain|verified|not verified/i.test(r.texto)) {
    r = await enviar('Em Dia <onboarding@resend.dev>')
  }
  return { ok: r.status >= 200 && r.status < 300, detalhe: `HTTP ${r.status}: ${r.texto.slice(0, 200)}` }
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return preflight()
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido', mensagem: 'Usa POST.' }, 405)

  const supa = clienteUtilizador(req)
  const { data: { user } } = await supa.auth.getUser()
  if (!user) return json({ erro: 'nao_autenticado', mensagem: 'Sessão inválida. Inicia sessão outra vez.' }, 401)

  let corpo: any
  try { corpo = await req.json() } catch {
    return json({ erro: 'corpo_invalido', mensagem: 'O corpo do pedido tem de ser JSON.' }, 400)
  }
  const tipo = TIPOS.includes(corpo?.tipo) ? String(corpo.tipo) : null
  const assunto = typeof corpo?.assunto === 'string' ? corpo.assunto.trim().slice(0, 200) : ''
  const descricao = typeof corpo?.descricao === 'string' ? corpo.descricao.trim().slice(0, 4000) : ''
  const logs = typeof corpo?.logs === 'string' ? corpo.logs.slice(0, 20000) : null
  if (!tipo) return json({ erro: 'tipo_invalido', mensagem: `tipo tem de ser um de: ${TIPOS.join(', ')}.` }, 400)
  if (!assunto) return json({ erro: 'assunto_em_falta', mensagem: 'Escreve o assunto.' }, 400)

  const admin = clienteAdmin()
  const textoTodo = `${assunto}\n${descricao}`
  const motivo = motivoEscala(tipo, textoTodo)
  const escalado = motivo !== null

  // 1) criar o ticket
  const { data: ticket, error: eT } = await admin.from('tickets_suporte').insert({
    user_id: user.id, tipo, assunto, descricao: descricao || null,
    logs: tipo === 'bug' ? logs : null,
    estado: 'aberto', escalar_humano: escalado, motivo_escala: motivo,
  }).select('id').single()
  if (eT || !ticket) {
    console.error('tickets_suporte insert falhou:', eT?.message)
    return json({ erro: 'gravar_falhou', mensagem: 'Não consegui registar o pedido. Tenta outra vez.' }, 500)
  }

  // 2) resposta por tipo
  let resposta = ''
  let estadoFinal = 'aberto'
  let respostaIa: string | null = null
  let erroIa: string | null = null

  if (tipo === 'reembolso') {
    resposta = RESPOSTA_REEMBOLSO
    respostaIa = resposta
    estadoFinal = escalado ? 'aberto' : 'fechado'
  } else if (tipo === 'duvida') {
    const r = await responderComIA(admin, user.id, `${assunto}\n\n${descricao}`.trim(), 'suporte')
    if (r.ok) {
      resposta = r.resposta
      respostaIa = r.resposta
    } else {
      erroIa = r.erro
      resposta = 'Registámos a tua dúvida. O assistente automático não está disponível agora, por isso uma pessoa da equipa vai responder-te.'
    }
  } else if (tipo === 'bug') {
    resposta = 'Obrigado por avisares. Guardámos o relatório e os registos da app; a equipa vai analisar e responde-te aqui.'
  } else {
    resposta = 'Recebemos o teu pedido. A equipa vai analisar e responde-te aqui.'
  }
  if (escalado) resposta += '\nEste pedido foi passado a uma pessoa da equipa.'

  const { error: eU } = await admin.from('tickets_suporte')
    .update({ estado: estadoFinal, resposta_ia: respostaIa })
    .eq('id', ticket.id)
  if (eU) console.error('tickets_suporte update falhou:', eU.message)

  // 3) escalar: e-mail à equipa se houver chave do Resend; sem chave só fica registado
  let email = 'nao_aplicavel'
  if (escalado) {
    const chave = await lerSegredo('resend_api_key', admin)
    if (!chave) {
      email = 'sem_resend_api_key'
    } else {
      const corpoEmail = [
        `Ticket ${ticket.id}`, `Utilizador: ${user.email ?? user.id}`, `Tipo: ${tipo}`, `Motivo da escala: ${motivo}`,
        '', `Assunto: ${assunto}`, '', descricao, '', logs ? `Logs:\n${logs.slice(0, 3000)}` : '',
      ].join('\n')
      const r = await enviarEmailResend(chave, `[Em Dia] Ticket escalado: ${assunto}`, corpoEmail)
      email = r.ok ? 'enviado' : `falhou (${r.detalhe})`
      if (!r.ok) console.error('Resend falhou:', r.detalhe)
    }
  }

  return json({ ticket_id: ticket.id, resposta, escalado, estado: estadoFinal, email, ...(erroIa ? { erro_ia: erroIa } : {}) })
})
