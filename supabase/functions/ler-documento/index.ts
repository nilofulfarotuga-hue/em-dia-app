// Edge Function ler-documento — lê uma fatura, um talão de combustível ou um
// talão com NIF, por foto ou PDF, e devolve os campos já arrumados.
//
// O Danilo escreveu: "Em cada registo de gasto ou de rendimento, o campo de
// valor é o principal e escrito à mão; ao lado fica um botão de câmara
// opcional. Ao fotografar, a IA lê e preenche sozinha: nome da loja ou
// entidade, data, valor total, e quando existirem, NIF, entidade e referência
// Multibanco. Não leias produto a produto."
//
// POST { imagem_base64, mime, tipo_esperado? } com sessão.
//   200 { leitura_id, tipo, entidade_nome, nif, data_documento, valor_total,
//         entidade_pagamento, referencia_pagamento, litros, preco_litro,
//         conta_para_irs, confianca, notas, restam_este_mes }
//   402 { cadeado: true }        — acabaram as leituras do mês no plano grátis
//   413 { erro: 'imagem_demasiado_grande' }
//   502 { erro: 'resposta_invalida' } — não deu para ler; a pessoa escreve à mão
//
// NADA é gravado como despesa ou rendimento aqui. Esta função só LÊ e guarda a
// leitura em `leituras_ocr`. Quem confirma é a pessoa, no telemóvel, depois de
// ver o que foi lido — é ela que carrega em guardar. Foi de propósito: uma
// leitura errada gravada sozinha é pior do que não ler nada.
import { json, preflight } from '../_shared/cors.ts'
import { clienteAdmin, clienteUtilizador } from '../_shared/segredos.ts'
import { chamarGemini } from '../_shared/gemini.ts'

const MIMES = ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf']
const TIPOS = ['fatura', 'combustivel', 'talao', 'extrato', 'outro']

const SYSTEM = [
  'Lês fotografias e PDFs de documentos portugueses de despesa: faturas de serviços (luz, água, gás, telemóvel, internet, seguro), talões de combustível e talões de compra.',
  'Devolve SÓ JSON, sem texto à volta, com esta forma exata:',
  '{"tipo":"fatura"|"combustivel"|"talao"|"outro","entidade_nome":texto|null,"nif":"9 dígitos"|null,"data_documento":"AAAA-MM-DD"|null,"valor_total":número|null,"entidade_pagamento":"5 dígitos"|null,"referencia_pagamento":"9 dígitos"|null,"litros":número|null,"preco_litro":número|null,"tem_nif_do_cliente":true|false,"confianca":0..1,"notas":"texto curto em português de Portugal"}',
  '',
  'REGRAS:',
  '- NÃO leias produto a produto. Só o total e os campos pedidos.',
  '- entidade_nome: o nome de quem emitiu (EDP, Galp, MEO, Continente…), como está escrito.',
  '- nif: o número de contribuinte DO CLIENTE, se aparecer no documento (9 dígitos). Se só houver o do emitente, mete null e diz nas notas.',
  '- data_documento: a data do documento, não a de vencimento. Formato AAAA-MM-DD.',
  '- valor_total: o total a pagar, em euros, número com ponto decimal, sem símbolo.',
  '- entidade_pagamento e referencia_pagamento: os números do Multibanco. A entidade tem 5 dígitos, a referência 9. Aparecem juntos numa caixa "Pagamento por referência" ou "Dados para pagamento". Se não houver, null nos dois.',
  '- litros e preco_litro: SÓ em talões de combustível. preco_litro é o preço por litro (ex.: 1.789).',
  '- tem_nif_do_cliente: true se o documento traz o número de contribuinte do cliente (isso faz a despesa contar para o IRS).',
  '- confianca: 0 a 1, quão certo estás. Se a foto está tremida ou cortada, baixa.',
  '- notas: o que viste e o que não conseguiste ler, numa ou duas frases.',
  '',
  'NUNCA INVENTES. Um campo que não se lê vai a null, com a confiança baixa e a explicação nas notas.',
  'Uma referência Multibanco com o número de dígitos errado é null, não é para arredondar nem completar.',
].join('\n')

/** Só dígitos, e só se tiver mesmo o tamanho certo. */
function digitos(v: unknown, tamanho: number): string | null {
  const s = String(v ?? '').replace(/\D/g, '')
  return s.length === tamanho ? s : null
}

function numero(v: unknown): number | null {
  // `Number(null)` é 0 e `Number('')` também. Sem esta guarda, um talão do
  // supermercado ficava gravado com "0,00 litros" e "0,000 €/litro" — que se lê
  // como uma leitura a sério de zero, e não como "isto não tem litros nenhuns".
  if (v === null || v === undefined || v === '') return null
  const n = Number(v)
  return isFinite(n) && n >= 0 ? n : null
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return preflight()
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido', mensagem: 'Usa POST.' }, 405)

  const supa = clienteUtilizador(req)
  const { data: { user } } = await supa.auth.getUser()
  if (!user) return json({ erro: 'nao_autenticado', mensagem: 'Sessão inválida. Entra outra vez.' }, 401)

  const admin = clienteAdmin()

  // ---- cadeado: 5 leituras por mês no grátis, sem limite no Pro -------------
  // O limite é do servidor, nunca do telemóvel: quem mude a hora do aparelho
  // não ganha leituras.
  const { data: permitida } = await admin.rpc('feature_permitida', { uid: user.id, flag: 'ler_foto' })
  if (permitida !== true) {
    return json({ cadeado: true, mensagem: 'Ler por foto faz parte do teu plano. No mês grátis está aberto.' }, 402)
  }
  const { data: limite } = await admin.rpc('feature_limite', { uid: user.id, flag: 'ler_foto' })
  let restam: number | null = null
  if (typeof limite === 'number') {
    const inicioDoMes = new Date()
    inicioDoMes.setUTCDate(1)
    inicioDoMes.setUTCHours(0, 0, 0, 0)
    const { count } = await admin.from('leituras_ocr')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', user.id)
      .gte('criado_em', inicioDoMes.toISOString())
    const usadas = count ?? 0
    restam = Math.max(0, limite - usadas)
    if (usadas >= limite) {
      return json({
        cadeado: true,
        usadas,
        limite,
        mensagem: `Já usaste as ${limite} leituras por foto deste mês. Escreve o valor à mão, ou passa a Pro para leituras sem limite.`,
      }, 402)
    }
  }

  // ---- o que chegou --------------------------------------------------------
  let corpo: Record<string, unknown>
  try { corpo = await req.json() } catch {
    return json({ erro: 'corpo_invalido', mensagem: 'O corpo do pedido tem de ser JSON.' }, 400)
  }
  const imagem = typeof corpo?.imagem_base64 === 'string'
    ? (corpo.imagem_base64 as string).replace(/^data:[^;]+;base64,/, '').trim() : ''
  const mime = typeof corpo?.mime === 'string' ? (corpo.mime as string).trim().toLowerCase() : ''
  const esperado = TIPOS.includes(String(corpo?.tipo_esperado ?? '')) ? String(corpo.tipo_esperado) : null

  if (!imagem) return json({ erro: 'imagem_em_falta', mensagem: 'Envia a foto do documento.' }, 400)
  if (!MIMES.includes(mime)) return json({ erro: 'mime_invalido', mensagem: `Formato não suportado. Usa: ${MIMES.join(', ')}.` }, 400)
  if (imagem.length > 8_000_000) return json({ erro: 'imagem_demasiado_grande', mensagem: 'A foto é demasiado grande. Tira outra com menos qualidade.' }, 413)

  const pedido = esperado
    ? `Isto devia ser um documento do tipo "${esperado}". Lê e devolve só o JSON pedido.`
    : 'Lê este documento e devolve só o JSON pedido.'

  const r = await chamarGemini({
    system: SYSTEM,
    partes: [{ inlineData: { mimeType: mime, data: imagem } }, { text: pedido }],
    jsonMode: true,
    maxTokens: 700,
    admin,
  })
  if (!r.ok) return json({ erro: r.erro, detalhe: r.detalhe, mensagem: r.mensagem }, r.status)

  let d: Record<string, unknown>
  try {
    d = JSON.parse(r.texto.replace(/^```(?:json)?\s*|\s*```$/g, ''))
  } catch {
    return json({
      erro: 'resposta_invalida',
      detalhe: r.texto.slice(0, 300),
      mensagem: 'Não consegui ler este documento. Escreve o valor à mão — demora menos do que tirar outra foto.',
    }, 502)
  }

  // ---- arrumar e desconfiar ------------------------------------------------
  const tipo = TIPOS.includes(String(d?.tipo)) ? String(d.tipo) : (esperado ?? 'outro')
  const dataDoc = /^\d{4}-\d{2}-\d{2}$/.test(String(d?.data_documento ?? '')) ? String(d.data_documento) : null
  const entidadePag = digitos(d?.entidade_pagamento, 5)
  const referenciaPag = digitos(d?.referencia_pagamento, 9)
  const leitura = {
    user_id: user.id,
    origem: mime === 'application/pdf' ? 'pdf' : 'foto',
    tipo_esperado: tipo === 'extrato' ? 'extrato' : tipo,
    bruto: d,
    entidade_nome: typeof d?.entidade_nome === 'string' ? (d.entidade_nome as string).slice(0, 120) : null,
    nif: digitos(d?.nif, 9),
    data_documento: dataDoc,
    valor_total: numero(d?.valor_total),
    // A entidade e a referência só valem juntas: uma sem a outra não paga nada.
    entidade_pagamento: entidadePag && referenciaPag ? entidadePag : null,
    referencia_pagamento: entidadePag && referenciaPag ? referenciaPag : null,
    litros: numero(d?.litros),
    preco_litro: numero(d?.preco_litro),
    confianca: Math.max(0, Math.min(1, Number(d?.confianca ?? 0) || 0)),
  }

  const { data: gravada, error: eGravar } = await admin.from('leituras_ocr').insert(leitura).select('id').single()
  if (eGravar) {
    console.error('leituras_ocr falhou:', eGravar.message)
    return json({ erro: 'nao_gravou', mensagem: 'Li o documento mas não consegui guardar a leitura. Tenta outra vez.' }, 500)
  }

  // custo, com os preços que estão em regras_legais
  const { data: precos } = await admin.from('regras_legais').select('chave,valor_num')
    .in('chave', ['ia_custo_entrada_eur_por_milhao', 'ia_custo_saida_eur_por_milhao'])
  const preco = (k: string) => Number((precos ?? []).find((p: { chave: string }) => p.chave === k)?.valor_num ?? 0)
  const custo = (r.tokensEntrada * preco('ia_custo_entrada_eur_por_milhao')) / 1e6
    + (r.tokensSaida * preco('ia_custo_saida_eur_por_milhao')) / 1e6
  await admin.from('conversas_ia').insert({
    user_id: user.id, pergunta: `documento:${tipo}`, resposta: JSON.stringify(leitura).slice(0, 2000),
    variante: 'pt', modelo: r.modelo, tokens_entrada: r.tokensEntrada, tokens_saida: r.tokensSaida,
    custo_tokens: Number(custo.toFixed(6)), fora_das_regras: false, modo: 'documento',
  })

  return json({
    leitura_id: gravada.id,
    tipo,
    entidade_nome: leitura.entidade_nome,
    nif: leitura.nif,
    data_documento: leitura.data_documento,
    valor_total: leitura.valor_total,
    entidade_pagamento: leitura.entidade_pagamento,
    referencia_pagamento: leitura.referencia_pagamento,
    litros: leitura.litros,
    preco_litro: leitura.preco_litro,
    // Um talão com o número de contribuinte conta para o IRS. É o que faz a
    // diferença entre "gastei" e "gastei e vou receber parte de volta".
    conta_para_irs: d?.tem_nif_do_cliente === true && leitura.nif !== null,
    confianca: leitura.confianca,
    notas: typeof d?.notas === 'string' ? (d.notas as string).slice(0, 500) : '',
    restam_este_mes: restam === null ? null : Math.max(0, restam - 1),
  })
})
