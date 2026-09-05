// Cabeçalhos CORS comuns a todas as Edge Functions do Em Dia.
export const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-cron-secret',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

// Resposta JSON com CORS já incluído.
export function json(corpo: unknown, status = 200): Response {
  return new Response(JSON.stringify(corpo), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json; charset=utf-8' },
  })
}

// Resposta ao pré-voo (OPTIONS).
export function preflight(): Response {
  return new Response('ok', { headers: CORS })
}
