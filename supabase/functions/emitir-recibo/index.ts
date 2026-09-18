// Edge Function: emitir-recibo (B2b, 2026-09-18)
//
// Emite uma FATURA-RECIBO certificada pela InvoiceXpress em nome da pessoa
// (a alternativa legal ao recibo verde do Portal das Finanças para quem usa
// um programa de faturação certificado). O documento nasce em rascunho,
// passa a «settled» (fatura-recibo = paga na hora) e fica com o PDF ligado.
//
// **Atrás do interruptor `feature_flags.faturacao_certificada`** — hoje
// desligado para todos os planos. Enquanto não houver conta InvoiceXpress
// (nome da conta + chave no Vault: `invoicexpress_account`,
// `invoicexpress_api_key`) a função responde `sem_conta` e a app nem mostra
// o botão. Nada aqui inventa números: o IVA vai isento pelo código M10
// (regime de isenção, art. 53.º CIVA) só quando a pessoa está nesse regime;
// senão vai com a taxa normal da conta.
//
// API (verificada a 18/09/2026 em invoicexpress.com/api-v2):
//   POST https://{conta}.app.invoicexpress.com/invoice_receipts.json?api_key=…
//     { "invoice_receipt": { date, due_date, client:{name, code, fiscal_id}, items:[…], tax_exemption } }
//   PUT  …/invoice_receipts/{id}/change-state.json  { "invoice_receipt": { "state": "finalized" } }
//   GET  …/api/pdf/{id}.json → { "output": { "pdfUrl" } }  (assíncrono: 202 enquanto gera)
import { json, preflight } from '../_shared/cors.ts'
import { clienteAdmin, clienteUtilizador, lerSegredo } from '../_shared/segredos.ts'

const FLAG = 'faturacao_certificada'
const CODIGO_ISENCAO_ART53 = 'M10'

interface Pedido {
  modo?: 'estado' | 'emitir'
  cliente?: { nome?: string; nif?: string; email?: string }
  descricao?: string
  valor?: number
  data?: string // yyyy-mm-dd
  isento?: boolean
  retencao?: number // 0 | 23 | 25
}

function ddmmaaaa(iso: string | undefined): string {
  const d = iso && /^\d{4}-\d{2}-\d{2}$/.test(iso) ? new Date(iso + 'T12:00:00Z') : new Date()
  const dd = String(d.getUTCDate()).padStart(2, '0')
  const mm = String(d.getUTCMonth() + 1).padStart(2, '0')
  return `${dd}/${mm}/${d.getUTCFullYear()}`
}

function nifValido(nif: string): boolean {
  if (!/^\d{9}$/.test(nif)) return false
  const n = nif.split('').map(Number)
  const soma = n.slice(0, 8).reduce((t, d, i) => t + d * (9 - i), 0)
  const resto = soma % 11
  const controlo = resto < 2 ? 0 : 11 - resto
  return controlo === n[8]
}

async function ix(conta: string, chave: string, metodo: string, caminho: string, corpo?: unknown): Promise<Response> {
  const url = `https://${conta}.app.invoicexpress.com/${caminho}${caminho.includes('?') ? '&' : '?'}api_key=${encodeURIComponent(chave)}`
  return await fetch(url, {
    method: metodo,
    headers: { 'Content-Type': 'application/json; charset=utf-8', Accept: 'application/json' },
    body: corpo === undefined ? undefined : JSON.stringify(corpo),
  })
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return preflight()
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido' }, 405)

  const admin = clienteAdmin()
  let pedido: Pedido & { user_id?: string } = {}
  try {
    pedido = (await req.json()) as Pedido & { user_id?: string }
  } catch {
    pedido = {}
  }

  // 1) Quem é. Porta de QA como na calcular-obrigacoes: com o `x-cron-secret`
  //    certo aceita-se `user_id` no corpo (o login por API está atrás do
  //    Turnstile e não se contorna um CAPTCHA).
  const supaUser = clienteUtilizador(req)
  const { data: { user: userJwt }, error: erroUser } = await supaUser.auth.getUser()
  let user = erroUser ? null : userJwt
  if (!user) {
    const segredo = req.headers.get('x-cron-secret')
    const esperado = segredo ? await lerSegredo('cron_secret', admin) : null
    if (segredo && esperado && segredo === esperado && /^[0-9a-f-]{36}$/i.test(pedido.user_id ?? '')) {
      user = { id: pedido.user_id! } as typeof userJwt & { id: string }
    }
  }
  if (!user) return json({ erro: 'sem_sessao' }, 401)

  // 2) O interruptor (desligado para todos = desligado, mesmo em trial).
  const { data: flag } = await admin.from('feature_flags').select('free, pro, familia').eq('chave', FLAG).maybeSingle()
  const ligada = !!flag && (flag.free || flag.pro || flag.familia)
  const conta = ligada ? await lerSegredo('invoicexpress_account', admin) : null
  const chave = ligada ? await lerSegredo('invoicexpress_api_key', admin) : null
  const temConta = !!conta && !!chave

  if (pedido.modo === 'estado' || !pedido.modo) {
    return json({ ligada, tem_conta: temConta })
  }
  if (!ligada) return json({ erro: 'desligada' }, 403)
  if (!temConta) return json({ erro: 'sem_conta' }, 503)

  // 3) O plano da pessoa deixa?
  const { data: plano } = await admin.rpc('plano_efetivo', { uid: user.id })
  const planoEfetivo = typeof plano === 'string' ? plano : 'free'
  const deixa = planoEfetivo === 'trial' || (flag as Record<string, boolean>)[planoEfetivo] === true
  if (!deixa) return json({ erro: 'plano' }, 403)

  // 4) O pedido tem de estar inteiro — sem adivinhar nada.
  const nome = (pedido.cliente?.nome ?? '').trim()
  const nif = (pedido.cliente?.nif ?? '').trim()
  const descricao = (pedido.descricao ?? '').trim()
  const valor = Number(pedido.valor)
  if (nome.length < 2) return json({ erro: 'cliente_sem_nome' }, 400)
  if (nif && !nifValido(nif)) return json({ erro: 'nif_invalido' }, 400)
  if (descricao.length < 2) return json({ erro: 'sem_descricao' }, 400)
  if (!Number.isFinite(valor) || valor <= 0 || valor > 100000) return json({ erro: 'valor_invalido' }, 400)
  const retencao = [0, 23, 25].includes(Number(pedido.retencao)) ? Number(pedido.retencao) : 0

  // O regime de IVA vem do perfil (o servidor manda, não o telemóvel).
  const { data: perfil } = await admin.from('profiles').select('regime_iva, nome').eq('user_id', user.id).maybeSingle()
  const isento = pedido.isento ?? (perfil?.regime_iva === 'isento_53')

  // 5) Fica registado ANTES de falar com a InvoiceXpress, para nunca haver
  //    documento lá fora sem rasto cá dentro.
  const { data: registo, error: erroRegisto } = await admin
    .from('recibos_emitidos')
    .insert({
      user_id: user.id,
      fornecedor: 'invoicexpress',
      cliente_nome: nome,
      cliente_nif: nif || null,
      descricao,
      valor,
      data: pedido.data ?? new Date().toISOString().slice(0, 10),
      isento,
      retencao_pct: retencao,
      estado: 'a_emitir',
    })
    .select('id')
    .single()
  if (erroRegisto || !registo) return json({ erro: 'registo_falhou', detalhe: erroRegisto?.message }, 500)

  const falhar = async (motivo: string, detalhe: string, status = 502) => {
    await admin.from('recibos_emitidos').update({ estado: 'erro', erro: `${motivo}: ${detalhe}`.slice(0, 900) }).eq('id', registo.id)
    return json({ erro: motivo, detalhe: detalhe.slice(0, 300), registo_id: registo.id }, status)
  }

  try {
    // 6) Criar (rascunho).
    const documento = {
      invoice_receipt: {
        date: ddmmaaaa(pedido.data),
        due_date: ddmmaaaa(pedido.data),
        retention: String(retencao),
        ...(isento ? { tax_exemption: CODIGO_ISENCAO_ART53 } : {}),
        client: {
          name: nome,
          code: nif || `EMDIA-${nome.toLowerCase().replace(/[^a-z0-9]+/g, '-').slice(0, 30)}`,
          ...(nif ? { fiscal_id: nif } : {}),
          ...(pedido.cliente?.email ? { email: pedido.cliente.email } : {}),
          country: 'Portugal',
        },
        items: [
          {
            name: descricao.slice(0, 60),
            description: descricao,
            unit_price: valor.toFixed(2),
            quantity: '1',
            unit: 'service',
            tax: { name: isento ? 'Isento' : 'IVA23' },
          },
        ],
      },
    }
    const criado = await ix(conta!, chave!, 'POST', 'invoice_receipts.json', documento)
    const textoCriado = await criado.text()
    if (!criado.ok) return await falhar('invoicexpress_recusou', `${criado.status} ${textoCriado}`)
    let docId: number | null = null
    let numero: string | null = null
    try {
      const j = JSON.parse(textoCriado)
      const d = j.invoice_receipt ?? j.invoice ?? j
      docId = typeof d.id === 'number' ? d.id : Number(d.id)
      numero = d.inverted_sequence_number ?? d.sequence_number ?? null
    } catch {
      return await falhar('resposta_estranha', textoCriado)
    }
    if (!docId || !Number.isFinite(docId)) return await falhar('resposta_sem_id', textoCriado)
    await admin.from('recibos_emitidos').update({ documento_id: docId, numero, estado: 'rascunho' }).eq('id', registo.id)

    // 7) Fechar (fatura-recibo = paga na hora → «finalized» leva-a a settled).
    const fechado = await ix(conta!, chave!, 'PUT', `invoice_receipts/${docId}/change-state.json`, {
      invoice_receipt: { state: 'finalized' },
    })
    if (!fechado.ok) return await falhar('nao_fechou', `${fechado.status} ${await fechado.text()}`)
    // O número definitivo só existe depois de fechar.
    const lido = await ix(conta!, chave!, 'GET', `invoice_receipts/${docId}.json`)
    if (lido.ok) {
      try {
        const j = JSON.parse(await lido.text())
        const d = j.invoice_receipt ?? j
        numero = d.inverted_sequence_number ?? d.sequence_number ?? numero
      } catch { /* fica o número que havia */ }
    }

    // 8) O PDF (assíncrono: 202 enquanto gera; tenta-se 4 vezes com pausa).
    let pdfUrl: string | null = null
    for (let tentativa = 0; tentativa < 4 && !pdfUrl; tentativa++) {
      const pdf = await ix(conta!, chave!, 'GET', `api/pdf/${docId}.json`)
      if (pdf.status === 200) {
        try {
          const j = JSON.parse(await pdf.text())
          pdfUrl = j.output?.pdfUrl ?? null
        } catch { /* tenta outra vez */ }
      } else if (pdf.status !== 202) {
        break
      }
      if (!pdfUrl) await new Promise((r) => setTimeout(r, 1500))
    }

    await admin.from('recibos_emitidos').update({ estado: 'emitida', numero, pdf_url: pdfUrl, emitida_em: new Date().toISOString() }).eq('id', registo.id)
    return json({ ok: true, registo_id: registo.id, documento_id: docId, numero, pdf_url: pdfUrl })
  } catch (e) {
    return await falhar('excecao', String(e), 500)
  }
})
