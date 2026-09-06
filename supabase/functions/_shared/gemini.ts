// Chamada REST à API Gemini (generativelanguage v1beta) — sem SDK, só fetch.
// Modelo por env GEMINI_MODEL (default 'gemini-2.5-flash'). Temperatura 0.2.
// Chave: Deno.env.get('GEMINI_API_KEY') || Vault 'gemini_api_key'. Sem chave → { erro: 'sem_gemini_api_key' }.
import type { SupabaseClient } from 'jsr:@supabase/supabase-js@2'
import { lerSegredo } from './segredos.ts'

export type ParteGemini =
  | { text: string }
  | { inlineData: { mimeType: string; data: string } }

export interface GeminiOk {
  ok: true
  texto: string
  modelo: string
  tokensEntrada: number
  tokensSaida: number
  cortada?: boolean         // finishReason MAX_TOKENS: a resposta veio incompleta
}

export interface GeminiErro {
  ok: false
  status: number            // código HTTP a devolver ao cliente
  erro: string              // 'sem_gemini_api_key' | 'gemini_indisponivel' | 'gemini_erro'
  detalhe?: string
  mensagem: string          // texto em PT-PT para o utilizador
}

export type GeminiResultado = GeminiOk | GeminiErro

/** Roda de modelos para quando a quota diária de um esgota (429). */
export const RODA_MODELOS = [
  'gemini-flash-latest', 'gemini-3.7-flash', 'gemini-3.6-flash', 'gemini-3.5-flash',
  'gemini-flash-lite-latest', 'gemini-3.5-flash-lite', 'gemini-3.1-flash-lite', 'gemini-2.5-flash-lite',
]

export function modeloGemini(): string {
  // gemini-2.5-flash deixou de existir para contas novas (404 provado 2026-09-06 01:20);
  // 'gemini-flash-latest' resolve para o Flash atual (3.8 em setembro de 2026).
  return Deno.env.get('GEMINI_MODEL')?.trim() || 'gemini-flash-latest'
}

export async function chamarGemini(
  opts: {
    system: string
    partes: ParteGemini[]
    jsonMode?: boolean
    maxTokens?: number
    admin?: SupabaseClient
  },
): Promise<GeminiResultado> {
  const chave = await lerSegredo('gemini_api_key', opts.admin)
  if (!chave) {
    return {
      ok: false,
      status: 503,
      erro: 'sem_gemini_api_key',
      mensagem: 'O assistente ainda não está ligado: falta a chave da Gemini no Vault (gemini_api_key). Tenta mais tarde.',
    }
  }

  const corpo: Record<string, unknown> = {
    systemInstruction: { parts: [{ text: opts.system }] },
    contents: [{ role: 'user', parts: opts.partes }],
    generationConfig: {
      temperature: 0.2,
      // Os Flash 3.x "pensam" antes de responder e o raciocínio conta para o teto: com 1024/2048
      // a resposta chegava cortada a meio da frase (provado 04:25). 4096 + orçamento de raciocínio curto.
      maxOutputTokens: opts.maxTokens ?? 4096,
      thinkingConfig: { thinkingBudget: 512 },
      ...(opts.jsonMode ? { responseMimeType: 'application/json' } : {}),
    },
  }

  // Free tier = 20 pedidos/dia POR MODELO (quotaId GenerateRequestsPerDayPerProjectPerModel-FreeTier,
  // provado 2026-09-06 04:10). Em 429 passa-se ao modelo seguinte da roda em vez de falhar:
  // cada modelo tem a sua quota. Com faturação ativa a roda quase nunca sai do primeiro.
  const roda = [modeloGemini(), ...RODA_MODELOS.filter((m) => m !== modeloGemini())]
  let modelo = roda[0]
  let resp: Response | null = null
  let textoBruto = ''
  for (const candidato of roda) {
    modelo = candidato
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${modelo}:generateContent`
    try {
      resp = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'x-goog-api-key': chave },
        body: JSON.stringify(corpo),
      })
    } catch (e) {
      return {
        ok: false, status: 503, erro: 'gemini_indisponivel',
        detalhe: String((e as Error)?.message ?? e),
        mensagem: 'Não consegui falar com o assistente agora. Tenta daqui a pouco.',
      }
    }
    textoBruto = await resp.text()
    if (resp.status === 429 || (resp.status === 404 && /not found|no longer available/i.test(textoBruto))) {
      continue // quota deste modelo esgotada (ou modelo indisponível) → próximo da roda
    }
    break
  }
  if (!resp) {
    return { ok: false, status: 503, erro: 'gemini_indisponivel', mensagem: 'O assistente está com muitos pedidos. Tenta daqui a um minuto.' }
  }
  if (resp.status === 403 || resp.status === 429) {
    return {
      ok: false, status: 503, erro: 'gemini_indisponivel',
      detalhe: `HTTP ${resp.status}: ${textoBruto.slice(0, 400)}`,
      mensagem: resp.status === 429
        ? 'O assistente está com muitos pedidos. Tenta daqui a um minuto.'
        : 'O assistente recusou o pedido (chave sem permissão). Avisámos a equipa.',
    }
  }
  if (!resp.ok) {
    return {
      ok: false, status: 502, erro: 'gemini_erro',
      detalhe: `HTTP ${resp.status}: ${textoBruto.slice(0, 400)}`,
      mensagem: 'O assistente devolveu um erro. Tenta outra vez.',
    }
  }

  let dados: any
  try { dados = JSON.parse(textoBruto) } catch {
    return { ok: false, status: 502, erro: 'gemini_erro', detalhe: 'resposta não é JSON', mensagem: 'O assistente devolveu um erro. Tenta outra vez.' }
  }
  const partes: Array<{ text?: string }> = dados?.candidates?.[0]?.content?.parts ?? []
  const texto = partes.map((p) => p.text ?? '').join('').trim()
  if (!texto) {
    const motivo = dados?.candidates?.[0]?.finishReason ?? dados?.promptFeedback?.blockReason ?? 'sem_texto'
    return { ok: false, status: 502, erro: 'gemini_erro', detalhe: `resposta vazia (${motivo})`, mensagem: 'O assistente não conseguiu responder a isto. Tenta reformular.' }
  }
  const uso = dados?.usageMetadata ?? {}
  const cortada = dados?.candidates?.[0]?.finishReason === 'MAX_TOKENS'
  return {
    ok: true,
    texto: cortada ? `${texto}\n\n(A resposta ficou incompleta — pergunta outra vez, de forma mais curta.)` : texto,
    cortada,
    modelo,
    tokensEntrada: Number(uso.promptTokenCount ?? 0),
    tokensSaida: Number(uso.candidatesTokenCount ?? 0) + Number(uso.thoughtsTokenCount ?? 0),
  }
}
