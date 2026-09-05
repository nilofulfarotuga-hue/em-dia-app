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
}

export interface GeminiErro {
  ok: false
  status: number            // código HTTP a devolver ao cliente
  erro: string              // 'sem_gemini_api_key' | 'gemini_indisponivel' | 'gemini_erro'
  detalhe?: string
  mensagem: string          // texto em PT-PT para o utilizador
}

export type GeminiResultado = GeminiOk | GeminiErro

export function modeloGemini(): string {
  return Deno.env.get('GEMINI_MODEL')?.trim() || 'gemini-2.5-flash'
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

  const modelo = modeloGemini()
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${modelo}:generateContent`
  const corpo: Record<string, unknown> = {
    systemInstruction: { parts: [{ text: opts.system }] },
    contents: [{ role: 'user', parts: opts.partes }],
    generationConfig: {
      temperature: 0.2,
      maxOutputTokens: opts.maxTokens ?? 1024,
      ...(opts.jsonMode ? { responseMimeType: 'application/json' } : {}),
    },
  }

  let resp: Response
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

  const textoBruto = await resp.text()
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
  return {
    ok: true,
    texto,
    modelo,
    tokensEntrada: Number(uso.promptTokenCount ?? 0),
    tokensSaida: Number(uso.candidatesTokenCount ?? 0) + Number(uso.thoughtsTokenCount ?? 0),
  }
}
