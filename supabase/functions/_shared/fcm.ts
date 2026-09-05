// Envio de notificações pelo FCM HTTP v1.
// Credenciais: Vault 'fcm_service_account' (JSON da service account do Firebase) ou env FCM_SERVICE_ACCOUNT.
// Sem credenciais → carregarFcm() devolve null e quem chama regista resultado 'sem_fcm' (não falha).
import type { SupabaseClient } from 'jsr:@supabase/supabase-js@2'
import { lerSegredo } from './segredos.ts'
import { obterAccessTokenGoogle, type ServiceAccountGoogle } from './google_oauth.ts'

const SCOPE_FCM = 'https://www.googleapis.com/auth/firebase.messaging'

export interface CredenciaisFcm extends ServiceAccountGoogle {
  project_id: string
}

/** Lê e valida a service account do Firebase. null se não existir ou for inválida. */
export async function carregarFcm(admin: SupabaseClient): Promise<CredenciaisFcm | null> {
  const bruto = await lerSegredo('fcm_service_account', admin)
  if (!bruto) return null
  try {
    const sa = JSON.parse(bruto) as CredenciaisFcm
    if (!sa.project_id || !sa.client_email || !sa.private_key) {
      console.error('fcm_service_account sem project_id/client_email/private_key')
      return null
    }
    return sa
  } catch (e) {
    console.error('fcm_service_account não é JSON válido:', (e as Error).message)
    return null
  }
}

export interface ResultadoEnvioFcm {
  ok: boolean
  /** tokens que o FCM diz já não existirem (UNREGISTERED) — apagar de push_tokens */
  tokensInvalidos: string[]
  erro?: string
}

/**
 * Envia a mesma notificação a todos os tokens de um utilizador.
 * ok = pelo menos um token aceite. Nunca lança: erros vêm em `erro`.
 */
export async function enviarFcm(
  sa: CredenciaisFcm,
  tokens: string[],
  titulo: string,
  corpo: string,
  data: Record<string, string>,
): Promise<ResultadoEnvioFcm> {
  const out: ResultadoEnvioFcm = { ok: false, tokensInvalidos: [] }
  let accessToken: string
  try {
    accessToken = await obterAccessTokenGoogle(sa, [SCOPE_FCM])
  } catch (e) {
    out.erro = `oauth: ${(e as Error).message}`.slice(0, 500)
    return out
  }
  const url = `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`
  const erros: string[] = []
  for (const token of tokens) {
    try {
      const resp = await fetch(url, {
        method: 'POST',
        headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: {
            token,
            notification: { title: titulo, body: corpo },
            data,
            android: { priority: 'high', notification: { channel_id: 'avisos' } },
          },
        }),
      })
      if (resp.ok) {
        out.ok = true
        continue
      }
      const texto = await resp.text().catch(() => '')
      // 404 UNREGISTERED / 400 INVALID_ARGUMENT com token inválido → token morto
      if (resp.status === 404 || /UNREGISTERED|not a valid FCM registration token/i.test(texto)) {
        out.tokensInvalidos.push(token)
      }
      erros.push(`${resp.status}: ${texto.slice(0, 200)}`)
    } catch (e) {
      erros.push(`rede: ${(e as Error).message}`)
    }
  }
  if (!out.ok && erros.length) out.erro = erros.join(' | ').slice(0, 500)
  return out
}
