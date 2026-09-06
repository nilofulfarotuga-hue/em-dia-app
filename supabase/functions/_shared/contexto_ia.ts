// Lógica partilhada do assistente "Em Dia": deteção da variante, contexto para o modelo
// (regras legais, escalões, guias, perfil, rendimentos, obrigações, carros), instrução de
// sistema e registo em conversas_ia. Usada por ia-responder (chat) e suporte-auto (suporte).
import type { SupabaseClient } from 'jsr:@supabase/supabase-js@2'
import { chamarGemini, type GeminiErro } from './gemini.ts'

export type Variante = 'pt' | 'br'
export type ModoIA = 'chat' | 'suporte'

export const FRASE_SEM_REGRA = 'Não tenho essa regra confirmada.'
export const RODAPE_FIXO = 'Informação geral, não substitui contabilista.'

// Marcas do português do Brasil: se o texto tiver uma, respondemos em 'br'.
const MARCAS_BR: RegExp[] = [
  /\bvocê\b/i, /\btá\b/i, /\bcelular\b/i, /\bônibus\b/i, /\baposentadoria\b/i,
  /\bcê\b/i, /\bpra\s/i, /\bné\b/i, /\btô\b/i, /\bINSS\b/, /\bCPF\b/,
]

export function detetarVariante(texto: string, padrao: Variante): Variante {
  if (MARCAS_BR.some((r) => r.test(texto))) return 'br'
  return padrao === 'br' ? 'br' : 'pt'
}

// Primeiro dia do mês corrente em Lisboa, como instante ISO (para contar perguntas do mês).
export function inicioMesLisboaISO(): string {
  const agora = new Date()
  const ymd = new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Lisbon', year: 'numeric', month: '2-digit', day: '2-digit' }).format(agora)
  const [y, m] = ymd.split('-')
  // Meia-noite de Lisboa: em UTC é 00:00 (inverno) ou 23:00 do dia anterior (verão).
  const candidato = new Date(`${y}-${m}-01T00:00:00Z`)
  const horaLisboa = Number(new Intl.DateTimeFormat('en-GB', { timeZone: 'Europe/Lisbon', hour: '2-digit', hour12: false }).format(candidato))
  if (horaLisboa === 1) candidato.setUTCHours(candidato.getUTCHours() - 1)
  return candidato.toISOString()
}

function fmt(v: unknown): string {
  if (v === null || v === undefined) return ''
  if (typeof v === 'object') return JSON.stringify(v)
  return String(v)
}

// Soma N meses ao 1.º dia do mês de uma data (AAAA-MM-DD) → AAAA-MM-DD.
export function fimIsencao(dataAbertura: string | null, meses: number): string | null {
  if (!dataAbertura) return null
  const d = new Date(`${dataAbertura.slice(0, 7)}-01T00:00:00Z`)
  if (isNaN(d.getTime())) return null
  d.setUTCMonth(d.getUTCMonth() + meses)
  return d.toISOString().slice(0, 10)
}

export interface Contexto {
  texto: string
  regras: Record<string, { valor_num: number | null; valor_txt: string | null; valor_json: unknown; confianca: string }>
  variantePerfil: Variante
}

// Monta o contexto completo que vai para o modelo. Só dados do servidor: nada é inventado.
export async function construirContexto(admin: SupabaseClient, uid: string): Promise<Contexto> {
  const anoAtual = Number(new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Lisbon', year: 'numeric' }).format(new Date()))
  const hojeLisboa = new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Lisbon', year: 'numeric', month: '2-digit', day: '2-digit' }).format(new Date())

  const [regrasQ, escaloesQ, guiasQ, perfilQ, rendQ, obrigQ, carrosQ] = await Promise.all([
    admin.from('regras_legais').select('chave,valor_num,valor_txt,valor_json,unidade,descricao,confianca,fonte_url').order('chave'),
    admin.from('irs_escaloes').select('ordem,ate,taxa,parcela_abater,confianca').eq('ano', anoAtual).order('ordem'),
    admin.from('guias').select('slug,titulo,resumo,corpo_pt').eq('publicado', true).order('ordem'),
    admin.from('profiles').select('tipo_atividade,data_abertura,regime_iva,rendimento_mensal_estimado,plano,variante_pt,tipo_rendimento,retencao_opcao').eq('user_id', uid).maybeSingle(),
    admin.from('rendimentos').select('valor_bruto,mes').eq('user_id', uid).gte('mes', `${anoAtual}-01-01`).lte('mes', `${anoAtual}-12-31`),
    admin.from('obrigacoes').select('tipo,descricao,data_limite,valor_estimado,origem_regra').eq('user_id', uid).eq('estado', 'pendente').gte('data_limite', hojeLisboa).order('data_limite').limit(10),
    admin.from('carros').select('nome,matricula,data_matricula,proxima_ipo,uso_tvde').eq('user_id', uid).eq('ativo', true),
  ])

  const regrasMap: Contexto['regras'] = {}
  const linhasRegras: string[] = []
  for (const r of (regrasQ.data ?? []) as any[]) {
    regrasMap[r.chave] = { valor_num: r.valor_num === null ? null : Number(r.valor_num), valor_txt: r.valor_txt, valor_json: r.valor_json, confianca: r.confianca }
    const valor = r.valor_num ?? r.valor_txt ?? fmt(r.valor_json)
    linhasRegras.push(`- ${r.chave} = ${fmt(valor).slice(0, 700)}${r.unidade ? ' ' + r.unidade : ''} [confianca: ${r.confianca}] — ${r.descricao}${r.fonte_url ? ' (fonte: ' + r.fonte_url + ')' : ''}`)
  }

  const linhasEscaloes = ((escaloesQ.data ?? []) as any[]).map((e) =>
    `- escalão ${e.ordem}: até ${e.ate ?? 'sem limite'} € → taxa ${(Number(e.taxa) * 100).toFixed(2)}%, parcela a abater ${e.parcela_abater} € [confianca: ${e.confianca}]`)

  const linhasGuias = ((guiasQ.data ?? []) as any[]).map((g) =>
    `### ${g.titulo} (slug: ${g.slug})\n${g.resumo ?? ''}\n${String(g.corpo_pt ?? '').slice(0, 1500)}`)

  const p = (perfilQ.data ?? {}) as any
  const mesesIsencao = regrasMap['ss_isencao_meses']?.valor_num ?? null
  const fim = mesesIsencao !== null ? fimIsencao(p.data_abertura ?? null, mesesIsencao) : null
  const somaRend = ((rendQ.data ?? []) as any[]).reduce((s, r) => s + Number(r.valor_bruto ?? 0), 0)

  const linhasObrig = ((obrigQ.data ?? []) as any[]).map((o) =>
    `- ${o.data_limite}: ${o.tipo} — ${o.descricao}${o.valor_estimado ? ' (~' + o.valor_estimado + ' €)' : ''}${o.origem_regra ? ' [regra: ' + o.origem_regra + ']' : ''}`)
  const linhasCarros = ((carrosQ.data ?? []) as any[]).map((c) =>
    `- ${c.nome ?? 'carro'} matrícula ${c.matricula}, data de matrícula ${c.data_matricula ?? 'desconhecida'}, próxima inspeção ${c.proxima_ipo ?? 'não calculada'}${c.uso_tvde ? ', usado em TVDE' : ''}`)

  const texto = [
    `HOJE (Lisboa): ${hojeLisboa}`,
    '',
    '## REGRAS LEGAIS (a única fonte de números; cita a chave entre parênteses)',
    ...linhasRegras,
    '',
    `## ESCALÕES DE IRS ${anoAtual}`,
    ...(linhasEscaloes.length ? linhasEscaloes : ['(sem escalões carregados para este ano)']),
    '',
    '## GUIAS PUBLICADOS',
    ...(linhasGuias.length ? linhasGuias : ['(ainda não há guias publicados)']),
    '',
    '## PERFIL DO UTILIZADOR',
    `- tipo_atividade: ${p.tipo_atividade ?? 'desconhecido'}`,
    `- data_abertura: ${p.data_abertura ?? 'não indicada'}`,
    `- fim da isenção de Segurança Social (1.º dia do mês de abertura + ss_isencao_meses): ${fim ?? 'não calculável (sem data de abertura)'}`,
    `- regime_iva: ${p.regime_iva ?? 'desconhecido'}`,
    `- tipo_rendimento: ${p.tipo_rendimento ?? 'servicos'}`,
    `- retencao_opcao: ${p.retencao_opcao ?? 'padrao'}`,
    `- rendimento_mensal_estimado: ${p.rendimento_mensal_estimado ?? 'não indicado'} €`,
    `- plano: ${p.plano ?? 'free'}`,
    `- rendimentos registados em ${anoAtual} (soma): ${somaRend.toFixed(2)} €`,
    '',
    '## PRÓXIMAS OBRIGAÇÕES PENDENTES (até 10)',
    ...(linhasObrig.length ? linhasObrig : ['(nenhuma pendente no calendário)']),
    '',
    '## CARROS',
    ...(linhasCarros.length ? linhasCarros : ['(sem carros registados)']),
  ].join('\n')

  return { texto, regras: regrasMap, variantePerfil: p.variante_pt === 'br' ? 'br' : 'pt' }
}

export function instrucaoSistema(variante: Variante, modo: ModoIA): string {
  const lingua = variante === 'br'
    ? 'português do Brasil (você, tá, celular)'
    : 'português de Portugal (tu, telemóvel, autocarro)'
  return [
    'És o assistente da app "Em Dia", para trabalhadores independentes a recibos verdes em Portugal.',
    `Responde SEMPRE em ${lingua}.`,
    'Explica como para uma criança de 5 anos: frases curtas, palavras simples. Se usares um termo técnico, explica-o logo entre parênteses.',
    'NUNCA inventes um número, uma taxa, uma data ou um prazo. Usa só os números que estão no CONTEXTO e, sempre que usares um, cita a chave da regra entre parênteses, por exemplo: 21,4% (ss_taxa).',
    `Se a regra necessária estiver marcada [confianca: por_confirmar] ou não existir no contexto, escreve exatamente a frase "${FRASE_SEM_REGRA}" e sugere falar com um contabilista.`,
    'Se for uma questão jurídica a sério (processos em tribunal, dívidas em execução, despedimentos, contratos), responde só o básico e diz claramente que precisa de contabilista ou advogado.',
    'Usa os dados do PERFIL, das OBRIGAÇÕES e dos CARROS do utilizador quando a pergunta for sobre a situação dele.',
    'Máximo de cerca de 180 palavras.',
    'A resposta termina SEMPRE com uma linha que começa por "Próximo passo:" com a ação concreta e o prazo (data ou regra), seguida de uma última linha exatamente igual a: ' + RODAPE_FIXO,
    modo === 'suporte'
      ? 'Estás a responder a um pedido de suporte da app: se a dúvida for sobre a app (planos, cadeados, avisos), explica com base no contexto; se for fiscal, aplica as regras acima.'
      : '',
  ].filter(Boolean).join('\n')
}

export interface RespostaIA {
  ok: true
  resposta: string
  variante: Variante
  fora_das_regras: boolean
  modelo: string
  tokens_entrada: number
  tokens_saida: number
  custo_tokens: number
  conversa_id: string | null
}

// Faz a pergunta ao modelo com todo o contexto, regista em conversas_ia e (em chat) abre
// ticket 'guia_novo' quando a resposta ficou fora das regras. Devolve o erro do Gemini tal
// como veio (503/502) para a função chamadora responder.
export async function responderComIA(
  admin: SupabaseClient,
  uid: string,
  pergunta: string,
  modo: ModoIA,
): Promise<RespostaIA | GeminiErro> {
  const ctx = await construirContexto(admin, uid)
  const variante = detetarVariante(pergunta, ctx.variantePerfil)
  const system = instrucaoSistema(variante, modo)

  const r = await chamarGemini({
    system,
    partes: [{ text: `CONTEXTO:\n${ctx.texto}\n\nPERGUNTA DO UTILIZADOR:\n${pergunta.trim()}` }],
    maxTokens: 4096,
    admin,
  })
  if (!r.ok) return r

  let resposta = r.texto.trim()
  if (!resposta.includes(RODAPE_FIXO)) resposta = `${resposta}\n${RODAPE_FIXO}`
  const foraDasRegras = resposta.includes(FRASE_SEM_REGRA)

  // custo em EUR: entrada × preço/1e6 + saída × preço/1e6 (preços em regras_legais, 'aproximado')
  const precoIn = ctx.regras['ia_custo_entrada_eur_por_milhao']?.valor_num ?? 0
  const precoOut = ctx.regras['ia_custo_saida_eur_por_milhao']?.valor_num ?? 0
  const custo = (r.tokensEntrada * precoIn) / 1e6 + (r.tokensSaida * precoOut) / 1e6

  const { data: conv, error: eConv } = await admin.from('conversas_ia').insert({
    user_id: uid,
    pergunta: pergunta.trim(),
    resposta,
    variante,
    modelo: r.modelo,
    tokens_entrada: r.tokensEntrada,
    tokens_saida: r.tokensSaida,
    custo_tokens: Number(custo.toFixed(6)),
    fora_das_regras: foraDasRegras,
    modo,
  }).select('id').single()
  if (eConv) console.error('conversas_ia insert falhou:', eConv.message)

  if (foraDasRegras && modo === 'chat') {
    const { error: eT } = await admin.from('tickets_suporte').insert({
      user_id: uid,
      tipo: 'guia_novo',
      assunto: `Pergunta sem regra confirmada: ${pergunta.trim().slice(0, 120)}`,
      descricao: pergunta.trim(),
      resposta_ia: resposta,
      estado: 'aberto',
    })
    if (eT) console.error('ticket guia_novo falhou:', eT.message)
  }

  return {
    ok: true,
    resposta,
    variante,
    fora_das_regras: foraDasRegras,
    modelo: r.modelo,
    tokens_entrada: r.tokensEntrada,
    tokens_saida: r.tokensSaida,
    custo_tokens: Number(custo.toFixed(6)),
    conversa_id: conv?.id ?? null,
  }
}
