// Edge Function: validar-compra-play
// Valida uma compra de assinatura do Google Play (Billing) junto da Play Developer API,
// grava/atualiza a linha em public.assinaturas e ajusta profiles.plano.
//
// POST { produto_id, token_compra } com JWT do utilizador.
// Respostas: 200 { estado, plano, renova_em } | 400 | 401 | 409 | 502 | 503 { erro: 'sem_play_service_account' }
import { createClient } from 'jsr:@supabase/supabase-js@2';
import { obterAccessTokenGoogle, type ServiceAccountGoogle } from '../_shared/google_oauth.ts';

const PACKAGE_ANDROID = 'pt.emdia.app';
const PRODUTOS_VALIDOS = ['pro_mensal', 'pro_anual', 'familia_mensal', 'familia_anual'] as const;
const SCOPE_PLAY = 'https://www.googleapis.com/auth/androidpublisher';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-cron-secret',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function json(corpo: unknown, status = 200): Response {
  return new Response(JSON.stringify(corpo), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json; charset=utf-8' },
  });
}

// deno-lint-ignore no-explicit-any
type Admin = any;

/** Lê um segredo: primeiro do ambiente, depois do Vault (public.ler_segredo, só service role). */
async function lerSegredo(admin: Admin, nome: string): Promise<string | null> {
  const env = Deno.env.get(nome.toUpperCase());
  if (env && env.trim() !== '') return env;
  const { data, error } = await admin.rpc('ler_segredo', { nome });
  if (error) {
    console.error('ler_segredo falhou', nome, error.message);
    return null;
  }
  return typeof data === 'string' && data.trim() !== '' ? data : null;
}

/** Mapeia o subscriptionState da Play API para o estado interno. */
function mapearEstado(subscriptionState: string | undefined): string {
  switch (subscriptionState) {
    case 'SUBSCRIPTION_STATE_ACTIVE':
    case 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD':
      return 'ativa';
    case 'SUBSCRIPTION_STATE_CANCELED':
      return 'cancelada'; // continua a dar acesso até renova_em (expiryTime)
    case 'SUBSCRIPTION_STATE_EXPIRED':
      return 'expirada';
    case 'SUBSCRIPTION_STATE_PAUSED':
      return 'pausa';
    case 'SUBSCRIPTION_STATE_PENDING':
    default:
      return 'pendente';
  }
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido', mensagem: 'Usa POST.' }, 405);

  const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
  const ANON = Deno.env.get('SUPABASE_ANON_KEY')!;
  const SERVICE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

  // 1) Utilizador autenticado (JWT da app)
  const auth = req.headers.get('Authorization') ?? '';
  const supa = createClient(SUPABASE_URL, ANON, { global: { headers: { Authorization: auth } } });
  const { data: { user } } = await supa.auth.getUser();
  if (!user) return json({ erro: 'nao_autenticado', mensagem: 'Sessão inválida. Inicia sessão outra vez.' }, 401);

  // 2) Validação de entrada
  // req.json() aceita "null", números, strings e arrays — só um objeto JSON serve aqui.
  // Sem esta guarda, `null.produto_id` rebentava com TypeError (HTTP 500) em vez de 400.
  let bruto: unknown;
  try {
    bruto = await req.json();
  } catch {
    return json({ erro: 'corpo_invalido', mensagem: 'O corpo do pedido tem de ser JSON.' }, 400);
  }
  if (bruto === null || typeof bruto !== 'object' || Array.isArray(bruto)) {
    return json({ erro: 'corpo_invalido', mensagem: 'O corpo do pedido tem de ser um objeto JSON com produto_id e token_compra.' }, 400);
  }
  const corpo = bruto as { produto_id?: unknown; token_compra?: unknown };
  const produtoId = typeof corpo.produto_id === 'string' ? corpo.produto_id.trim() : '';
  const tokenCompra = typeof corpo.token_compra === 'string' ? corpo.token_compra.trim() : '';
  if (!(PRODUTOS_VALIDOS as readonly string[]).includes(produtoId)) {
    return json({
      erro: 'produto_id_invalido',
      mensagem: `produto_id em falta ou inválido. Valores aceites: ${PRODUTOS_VALIDOS.join(', ')}.`,
    }, 400);
  }
  if (!tokenCompra) {
    return json({ erro: 'token_compra_em_falta', mensagem: 'token_compra é obrigatório.' }, 400);
  }

  const admin = createClient(SUPABASE_URL, SERVICE);

  // 3) Credenciais da Play Developer API (Vault) — sem elas, 503 claro, nunca se inventa
  const saBruto = await lerSegredo(admin, 'play_service_account');
  if (!saBruto) {
    return json({
      erro: 'sem_play_service_account',
      mensagem: 'A conta de serviço do Google Play ainda não está configurada. A validação de compras fica disponível quando a app for publicada.',
    }, 503);
  }
  let sa: ServiceAccountGoogle;
  try {
    sa = JSON.parse(saBruto);
  } catch {
    return json({ erro: 'play_service_account_invalida', mensagem: 'O segredo play_service_account não é JSON válido.' }, 503);
  }

  // 4) Token OAuth2 e consulta da assinatura na Play Developer API
  let accessToken: string;
  try {
    accessToken = await obterAccessTokenGoogle(sa, [SCOPE_PLAY]);
  } catch (e) {
    console.error('oauth google', (e as Error).message);
    return json({ erro: 'oauth_google_falhou', mensagem: 'Não foi possível autenticar junto da Google.' }, 502);
  }

  const base = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE_ANDROID}`;
  const respPlay = await fetch(`${base}/purchases/subscriptionsv2/tokens/${encodeURIComponent(tokenCompra)}`, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  const recibo = await respPlay.json().catch(() => ({}));
  if (!respPlay.ok) {
    console.error('play api', respPlay.status, JSON.stringify(recibo));
    const invalido = respPlay.status === 404 || respPlay.status === 400;
    return json(
      invalido
        ? { erro: 'token_compra_invalido', mensagem: 'A Google não reconhece este token de compra.' }
        : { erro: 'play_api_falhou', mensagem: 'A Google Play não respondeu. Tenta mais tarde.' },
      invalido ? 400 : 502,
    );
  }

  // 5) Confirmar que o recibo é mesmo do produto pedido
  const item = recibo.lineItems?.[0] ?? {};
  if (item.productId !== produtoId) {
    return json({
      erro: 'produto_nao_corresponde',
      mensagem: `O recibo é do produto "${item.productId ?? '?'}", não de "${produtoId}".`,
    }, 400);
  }

  // 6) O token não pode pertencer a outro utilizador
  const { data: existente } = await admin
    .from('assinaturas')
    .select('user_id')
    .eq('plataforma', 'play')
    .eq('token_compra', tokenCompra)
    .maybeSingle();
  if (existente && existente.user_id !== user.id) {
    return json({ erro: 'token_de_outro_utilizador', mensagem: 'Esta compra já está associada a outra conta.' }, 409);
  }

  // 7) Estado, datas, plano
  const estado = mapearEstado(recibo.subscriptionState);
  const renovaEm: string | null = item.expiryTime ?? null;
  const comecouEm: string | null = recibo.startTime ?? null;
  const planoDoProduto = produtoId.startsWith('familia') ? 'familia' : 'pro';

  const { error: erroUpsert } = await admin.from('assinaturas').upsert({
    user_id: user.id,
    produto_id: produtoId,
    plataforma: 'play',
    estado,
    token_compra: tokenCompra,
    comprovativo_play: recibo,
    comecou_em: comecouEm,
    renova_em: renovaEm,
    terminou_em: estado === 'expirada' ? (renovaEm ?? new Date().toISOString()) : null,
  }, { onConflict: 'plataforma,token_compra' });
  if (erroUpsert) {
    console.error('upsert assinaturas', erroUpsert.message);
    return json({ erro: 'gravar_falhou', mensagem: 'Não foi possível guardar a assinatura.' }, 500);
  }

  // Plano no perfil: ativa → pro/familia; expirada → free; os outros estados não mexem
  let planoFinal: string | null = null;
  if (estado === 'ativa') planoFinal = planoDoProduto;
  else if (estado === 'expirada') planoFinal = 'free';
  if (planoFinal) {
    const { error: erroPlano } = await admin.from('profiles').update({ plano: planoFinal }).eq('user_id', user.id);
    if (erroPlano) console.error('update profiles.plano', erroPlano.message);
  }

  // 8) Acknowledge se a Google ainda espera confirmação (uma falha aqui não bloqueia a resposta)
  if (recibo.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_PENDING') {
    try {
      await fetch(
        `${base}/purchases/subscriptions/${encodeURIComponent(produtoId)}/tokens/${encodeURIComponent(tokenCompra)}:acknowledge`,
        {
          method: 'POST',
          headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
          body: '{}',
        },
      );
    } catch (e) {
      console.error('acknowledge', (e as Error).message);
    }
  }

  const { data: perfil } = await admin.from('profiles').select('plano').eq('user_id', user.id).maybeSingle();
  return json({ estado, plano: perfil?.plano ?? planoFinal ?? 'free', renova_em: renovaEm });
});
