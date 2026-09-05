// Leitura de segredos: primeiro a variável de ambiente, depois o Vault (public.ler_segredo),
// sempre com o cliente service-role. Nunca inventa: se não houver, devolve null.
import { createClient, type SupabaseClient } from 'jsr:@supabase/supabase-js@2'

export function clienteAdmin(): SupabaseClient {
  return createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false } },
  )
}

// Cliente com o JWT do utilizador (respeita RLS).
export function clienteUtilizador(req: Request): SupabaseClient {
  return createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    {
      auth: { persistSession: false },
      global: { headers: { Authorization: req.headers.get('Authorization') ?? '' } },
    },
  )
}

// nome no Vault em minúsculas (ex.: 'gemini_api_key'); a env equivalente é em maiúsculas.
export async function lerSegredo(nome: string, admin?: SupabaseClient): Promise<string | null> {
  const env = Deno.env.get(nome.toUpperCase())
  if (env && env.trim() !== '') return env.trim()
  const supa = admin ?? clienteAdmin()
  const { data, error } = await supa.rpc('ler_segredo', { nome })
  if (error) {
    console.error(`ler_segredo(${nome}) falhou:`, error.message)
    return null
  }
  const v = typeof data === 'string' ? data.trim() : null
  return v && v !== '' ? v : null
}
