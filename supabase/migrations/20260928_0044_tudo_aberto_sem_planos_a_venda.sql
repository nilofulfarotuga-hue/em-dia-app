-- 0044 — Sem planos à venda, ninguém tem limites nem cadeados (decisão do Danilo, 28/09/2026).
--
-- Enquanto regras_legais.planos_a_venda não for «sim», quem acabou o mês grátis e não tem
-- assinatura deixa de cair em 'free' (com limites) e passa a 'trial' (tudo aberto). Tudo o
-- resto passa por aqui: feature_permitida/feature_limite, as Edge Functions (ia-responder,
-- ler-documento, ler-extrato, emitir-recibo, avisos-cron) e a app (PlanoStore).
--
-- A lógica dos planos NÃO se apaga: trial_ate, assinaturas Pro/Família e profiles.plano
-- continuam a valer por esta ordem, e com planos_a_venda = «sim» o último caso volta a ser
-- 'free' sozinho, sem nova migração.
--
-- Cópia do antes: bkp_plano_efetivo_20260928 (definição da função, RLS ligada, sem políticas).

create table if not exists public.bkp_plano_efetivo_20260928 as
  select 'plano_efetivo(uuid)'::text as funcao, pg_get_functiondef('public.plano_efetivo(uuid)'::regprocedure) as definicao, now() as copiado_em;
alter table public.bkp_plano_efetivo_20260928 enable row level security;
revoke all on public.bkp_plano_efetivo_20260928 from anon, authenticated;

create or replace function public.plano_efetivo(uid uuid)
 returns text
 language plpgsql
 stable security definer
 set search_path to 'public'
as $function$
declare r text;
begin
  if not public.pode_ver_plano(uid) then
    raise exception 'so_o_proprio' using errcode = '42501';
  end if;
  select case
    when p.trial_ate > now() then 'trial'
    when exists (select 1 from public.assinaturas a where a.user_id = uid and a.estado = 'ativa'
                   and a.produto_id like 'familia%' and coalesce(a.renova_em, now() + interval '1 day') > now()) then 'familia'
    when exists (select 1 from public.assinaturas a where a.user_id = uid and a.estado = 'ativa'
                   and a.produto_id like 'pro%' and coalesce(a.renova_em, now() + interval '1 day') > now()) then 'pro'
    when p.plano in ('pro','familia') then p.plano
    -- Nada à venda: tudo aberto para toda a gente (lido de regras_legais, nunca cravado).
    when coalesce((select lower(trim(valor_txt)) from public.regras_legais where chave = 'planos_a_venda'), 'nao') <> 'sim'
      then 'trial'
    else 'free' end
  into r
  from public.profiles p where p.user_id = uid;
  return r;
end $function$;
