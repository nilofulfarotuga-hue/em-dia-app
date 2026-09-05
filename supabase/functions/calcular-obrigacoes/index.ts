// Em Dia — Edge Function `calcular-obrigacoes`
//
// POST (qualquer corpo) com o JWT do utilizador. Lê o perfil, os carros ativos,
// as regras legais, os escalões de IRS e os feriados; gera TODAS as obrigações
// dos próximos 12 meses (espelho exato de lib/regras/obrigacoes.dart, via
// ../_shared/regras.ts) e faz upsert em public.obrigacoes por (user_id, chave_unica).
//
// Regras do upsert:
//  - linhas existentes mantêm estado, pago_em e comprovativo_url; só se atualizam
//    descricao, data_limite, aviso_em, valor_estimado, como_pagar, origem_regra;
//  - linhas pendentes geradas que já não existam no novo conjunto são apagadas,
//    EXCETO os tipos manuais ('multa', 'portagem', 'outro').
//
// Corpo opcional: { "hoje": "YYYY-MM-DD" } — só para testes/QA; por omissão é hoje em Lisboa.
// Resposta: { geradas, novas, atualizadas, apagadas, hoje, itens: [...] }

import { createClient } from 'jsr:@supabase/supabase-js@2';
import {
  carroDeLinha,
  dataIso,
  gerarObrigacoes,
  hojeLisboa,
  lerDia,
  obrigacaoParaLinha,
  perfilDeLinha,
  RegrasLegais,
} from '../_shared/regras.ts';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-cron-secret',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

/** Tipos que o utilizador cria à mão: nunca se apagam na regeneração. */
const TIPOS_MANUAIS = ['multa', 'portagem', 'outro'];

function json(corpo: unknown, status = 200): Response {
  return new Response(JSON.stringify(corpo), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json; charset=utf-8' },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido', mensagem: 'Usa POST.' }, 405);

  const url = Deno.env.get('SUPABASE_URL')!;
  const anon = Deno.env.get('SUPABASE_ANON_KEY')!;
  const service = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

  // 1) Quem é o utilizador (401 se não houver JWT válido)
  const auth = req.headers.get('Authorization') ?? '';
  const supaUser = createClient(url, anon, { global: { headers: { Authorization: auth } } });
  const { data: { user }, error: erroUser } = await supaUser.auth.getUser();
  if (erroUser || !user) {
    return json({ erro: 'nao_autenticado', mensagem: 'Precisas de iniciar sessão.' }, 401);
  }

  // 2) Corpo (opcional): "hoje" para QA
  let hoje = hojeLisboa();
  try {
    const corpo = await req.json();
    if (corpo && typeof corpo.hoje === 'string' && /^\d{4}-\d{2}-\d{2}/.test(corpo.hoje)) {
      hoje = lerDia(corpo.hoje);
    }
  } catch {
    // corpo vazio ou não-JSON: ignora-se
  }

  // 3) Dados (service role: as tabelas de regras são públicas, as do utilizador filtram-se por user_id)
  const admin = createClient(url, service);
  const [perfilQ, carrosQ, regrasQ, escaloesQ, feriadosQ, existentesQ] = await Promise.all([
    admin.from('profiles').select('*').eq('user_id', user.id).maybeSingle(),
    admin.from('carros').select('*').eq('user_id', user.id).eq('ativo', true),
    admin.from('regras_legais').select('*'),
    admin.from('irs_escaloes').select('*'),
    admin.from('feriados').select('data'),
    admin.from('obrigacoes').select('id, tipo, chave_unica, estado').eq('user_id', user.id),
  ]);
  for (const q of [perfilQ, carrosQ, regrasQ, escaloesQ, feriadosQ, existentesQ]) {
    if (q.error) return json({ erro: 'leitura_falhou', mensagem: q.error.message }, 500);
  }
  if (!perfilQ.data) {
    return json({ erro: 'sem_perfil', mensagem: 'Ainda não tens perfil. Termina o onboarding primeiro.' }, 404);
  }

  const regras = RegrasLegais.deTabelas(regrasQ.data ?? [], escaloesQ.data ?? [], feriadosQ.data ?? []);
  const perfil = perfilDeLinha(perfilQ.data);
  const carros = (carrosQ.data ?? []).map(carroDeLinha).filter((c) => c !== null);

  // 4) Gerar (qualquer regra legal em falta lança — responde-se 500 com a chave em falta, nunca se inventa)
  let obrigacoes;
  try {
    obrigacoes = gerarObrigacoes(perfil, carros, hoje, regras);
  } catch (e) {
    return json({ erro: 'regra_em_falta', mensagem: String((e as Error).message ?? e) }, 500);
  }

  // 5) Upsert por (user_id, chave_unica): estado/pago_em/comprovativo_url nunca são tocados
  const existentes = existentesQ.data ?? [];
  const chavesExistentes = new Set(existentes.map((e) => e.chave_unica as string));
  const linhas = obrigacoes.map((o) => obrigacaoParaLinha(o, user.id));
  let novas = 0;
  let atualizadas = 0;
  for (const l of linhas) {
    if (chavesExistentes.has(l.chave_unica as string)) atualizadas++;
    else novas++;
  }
  if (linhas.length > 0) {
    const { error } = await admin.from('obrigacoes').upsert(linhas, { onConflict: 'user_id,chave_unica' });
    if (error) return json({ erro: 'gravacao_falhou', mensagem: error.message }, 500);
  }

  // 6) Apagar pendentes geradas que já não existem (nunca as manuais)
  const chavesNovas = new Set(linhas.map((l) => l.chave_unica as string));
  const aApagar = existentes
    .filter((e) => e.estado === 'pendente' && !TIPOS_MANUAIS.includes(e.tipo as string) && !chavesNovas.has(e.chave_unica as string))
    .map((e) => e.id as string);
  let apagadas = 0;
  if (aApagar.length > 0) {
    const { error, count } = await admin.from('obrigacoes').delete({ count: 'exact' }).in('id', aApagar).eq('user_id', user.id);
    if (error) return json({ erro: 'limpeza_falhou', mensagem: error.message }, 500);
    apagadas = count ?? aApagar.length;
  }

  return json({
    geradas: obrigacoes.length,
    novas,
    atualizadas,
    apagadas,
    hoje: dataIso(hoje),
    itens: obrigacoes.map((o) => ({
      tipo: o.tipo,
      descricao: o.descricao,
      data_limite: dataIso(o.dataLimite),
      aviso_em: dataIso(o.avisoEm),
      valor_estimado: o.valorEstimado,
      origem_regra: o.origemRegra,
      como_pagar: o.comoPagar,
      chave_unica: o.chaveUnica,
      carro_id: o.carroId,
    })),
  });
});
