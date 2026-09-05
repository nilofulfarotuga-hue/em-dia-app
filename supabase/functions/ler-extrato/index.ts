// Edge Function ler-extrato — lê um extrato/resumo de ganhos (Uber/Bolt/Glovo) por foto.
// POST { imagem_base64, mime } com JWT. Cadeado: feature_permitida(uid,'ler_extrato_foto').
// 402 { cadeado: true } se o plano não permite · 503 { erro: 'sem_gemini_api_key' } sem chave
// · 200 { plataforma, mes, valor_bruto, confianca, notas }.
import { json, preflight } from '../_shared/cors.ts'
import { clienteAdmin, clienteUtilizador } from '../_shared/segredos.ts'
import { chamarGemini } from '../_shared/gemini.ts'

const MIMES = ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf']
const PLATAFORMAS = ['uber', 'bolt', 'glovo', 'outro']

const SYSTEM = [
  'Lês extratos ou resumos de ganhos de plataformas (Uber, Bolt, Glovo) fotografados por trabalhadores independentes em Portugal.',
  'Devolve SÓ JSON, sem texto à volta, com esta forma exata:',
  '{"plataforma":"uber"|"bolt"|"glovo"|"outro","mes":"AAAA-MM","valor_bruto":número,"confianca":0..1,"notas":"texto curto em português de Portugal"}',
  '- plataforma: a que aparece no documento; se não reconheceres, "outro".',
  '- mes: o mês a que o extrato se refere (formato AAAA-MM). Se houver várias semanas do mesmo mês, esse mês.',
  '- valor_bruto: o total de ganhos BRUTOS (antes de comissões/taxas da plataforma) em euros, número com ponto decimal, sem símbolo.',
  '- confianca: 0 a 1, quão certo estás dos valores.',
  '- notas: o que viste (ex.: "total de ganhos brutos 1234,56 €, semanas de 1 a 28 de julho") e dúvidas.',
  'Nunca inventes valores: se não se lê, põe valor_bruto 0 e confianca baixa e explica nas notas.',
].join('\n')

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return preflight()
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido', mensagem: 'Usa POST.' }, 405)

  const supa = clienteUtilizador(req)
  const { data: { user } } = await supa.auth.getUser()
  if (!user) return json({ erro: 'nao_autenticado', mensagem: 'Sessão inválida. Inicia sessão outra vez.' }, 401)

  const admin = clienteAdmin()

  // cadeado do plano
  const { data: permitida, error: ePerm } = await admin.rpc('feature_permitida', { uid: user.id, flag: 'ler_extrato_foto' })
  if (ePerm) console.error('feature_permitida falhou:', ePerm.message)
  if (permitida !== true) {
    return json({ cadeado: true, mensagem: 'Ler o extrato por foto faz parte do plano Pro. No mês grátis está aberto.' }, 402)
  }

  let corpo: any
  try { corpo = await req.json() } catch {
    return json({ erro: 'corpo_invalido', mensagem: 'O corpo do pedido tem de ser JSON.' }, 400)
  }
  const imagem = typeof corpo?.imagem_base64 === 'string' ? corpo.imagem_base64.replace(/^data:[^;]+;base64,/, '').trim() : ''
  const mime = typeof corpo?.mime === 'string' ? corpo.mime.trim().toLowerCase() : ''
  if (!imagem) return json({ erro: 'imagem_em_falta', mensagem: 'Envia a foto do extrato (imagem_base64).' }, 400)
  if (!MIMES.includes(mime)) return json({ erro: 'mime_invalido', mensagem: `Formato não suportado. Usa: ${MIMES.join(', ')}.` }, 400)
  if (imagem.length > 8_000_000) return json({ erro: 'imagem_demasiado_grande', mensagem: 'A foto é demasiado grande (máx. ~6 MB).' }, 413)

  const r = await chamarGemini({
    system: SYSTEM,
    partes: [
      { inlineData: { mimeType: mime, data: imagem } },
      { text: 'Lê este extrato e devolve só o JSON pedido.' },
    ],
    jsonMode: true,
    maxTokens: 512,
    admin,
  })
  if (!r.ok) return json({ erro: r.erro, detalhe: r.detalhe, mensagem: r.mensagem }, r.status)

  // validar o JSON devolvido
  let dados: any
  try {
    dados = JSON.parse(r.texto.replace(/^```(?:json)?\s*|\s*```$/g, ''))
  } catch {
    return json({ erro: 'resposta_invalida', detalhe: r.texto.slice(0, 300), mensagem: 'Não consegui ler o extrato. Tira a foto mais de perto e com luz.' }, 502)
  }
  const plataforma = PLATAFORMAS.includes(String(dados?.plataforma).toLowerCase()) ? String(dados.plataforma).toLowerCase() : 'outro'
  const mes = /^\d{4}-(0[1-9]|1[0-2])$/.test(String(dados?.mes ?? '')) ? String(dados.mes) : null
  const valor = Number(dados?.valor_bruto)
  const confianca = Math.max(0, Math.min(1, Number(dados?.confianca ?? 0) || 0))
  const notas = typeof dados?.notas === 'string' ? dados.notas.slice(0, 500) : ''
  if (mes === null || !isFinite(valor) || valor < 0) {
    return json({ erro: 'resposta_invalida', detalhe: JSON.stringify(dados).slice(0, 300), mensagem: 'Não consegui ler o mês ou o valor do extrato. Tenta outra foto.' }, 502)
  }
  const resultado = { plataforma, mes, valor_bruto: Number(valor.toFixed(2)), confianca: Number(confianca.toFixed(2)), notas }

  // registo (modo 'extrato'); custo com os preços de regras_legais
  const { data: precos } = await admin.from('regras_legais').select('chave,valor_num').in('chave', ['ia_custo_entrada_eur_por_milhao', 'ia_custo_saida_eur_por_milhao'])
  const preco = (k: string) => Number((precos ?? []).find((p: any) => p.chave === k)?.valor_num ?? 0)
  const custo = (r.tokensEntrada * preco('ia_custo_entrada_eur_por_milhao')) / 1e6 + (r.tokensSaida * preco('ia_custo_saida_eur_por_milhao')) / 1e6
  const { error: eConv } = await admin.from('conversas_ia').insert({
    user_id: user.id, pergunta: 'extrato', resposta: JSON.stringify(resultado), variante: 'pt',
    modelo: r.modelo, tokens_entrada: r.tokensEntrada, tokens_saida: r.tokensSaida,
    custo_tokens: Number(custo.toFixed(6)), fora_das_regras: false, modo: 'extrato',
  })
  if (eConv) console.error('conversas_ia (extrato) falhou:', eConv.message)

  return json(resultado)
})
