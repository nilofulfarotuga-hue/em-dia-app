// Autenticação OAuth2 com uma service account Google (JWT RS256 assinado com jose).
// Reutilizável: Play Developer API (validar-compra-play) e FCM (avisos-cron).
//
// Uso:
//   const sa = JSON.parse(await lerSegredo('play_service_account'));
//   const token = await obterAccessTokenGoogle(sa, ['https://www.googleapis.com/auth/androidpublisher']);
import { SignJWT, importPKCS8 } from 'npm:jose@5';

/** Campos mínimos do JSON de uma service account Google. */
export interface ServiceAccountGoogle {
  client_email: string;
  private_key: string;
  token_uri?: string;
}

// Cache em memória por (email + scopes) para não pedir um token novo a cada chamada
const cache = new Map<string, { token: string; expira: number }>();

/**
 * Troca um JWT assinado com a private_key da service account por um access_token OAuth2.
 * Lança Error com mensagem em português se a troca falhar.
 */
export async function obterAccessTokenGoogle(
  sa: ServiceAccountGoogle,
  scopes: string[],
): Promise<string> {
  if (!sa?.client_email || !sa?.private_key) {
    throw new Error('service account inválida: faltam client_email ou private_key');
  }
  const chave = `${sa.client_email}|${scopes.join(' ')}`;
  const agora = Math.floor(Date.now() / 1000);
  const emCache = cache.get(chave);
  if (emCache && emCache.expira - 60 > agora) return emCache.token;

  const tokenUri = sa.token_uri ?? 'https://oauth2.googleapis.com/token';
  // O JSON da Google pode trazer a chave com "\n" literais; garantimos quebras de linha reais
  const pem = sa.private_key.replace(/\\n/g, '\n');
  const privateKey = await importPKCS8(pem, 'RS256');

  const assertion = await new SignJWT({ scope: scopes.join(' ') })
    .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
    .setIssuer(sa.client_email)
    .setSubject(sa.client_email)
    .setAudience(tokenUri)
    .setIssuedAt(agora)
    .setExpirationTime(agora + 3600)
    .sign(privateKey);

  const resp = await fetch(tokenUri, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  const corpo = await resp.json().catch(() => ({}));
  if (!resp.ok || !corpo.access_token) {
    throw new Error(`falha ao obter token Google (${resp.status}): ${JSON.stringify(corpo)}`);
  }
  cache.set(chave, { token: corpo.access_token, expira: agora + (corpo.expires_in ?? 3600) });
  return corpo.access_token as string;
}
