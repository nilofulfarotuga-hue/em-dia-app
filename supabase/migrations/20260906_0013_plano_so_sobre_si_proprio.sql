-- 0013 — ninguém pergunta pelo plano dos outros (2026-09-06).
-- Aplicada em produção: versão 20260906140414.
--
-- `plano_efetivo(uid)`, `feature_permitida(uid, flag)` e `feature_limite(uid, flag)`
-- são SECURITY DEFINER e aceitavam o uid de QUALQUER pessoa. Quem tivesse sessão
-- podia perguntar que plano tem outra pessoa. Não é dinheiro nem morada, mas é
-- informação de outra pessoa e não custa nada fechar.
--
-- Passam a responder só sobre:
--   · quem pergunta (uid = auth.uid()),
--   · qualquer um, se quem pergunta for administrador,
--   · qualquer um, se for o servidor (service_role — as Edge Functions).
-- A qualquer outra pergunta respondem com erro 42501, como o `admin_resumo`.
--
-- PROVA (2026-09-06 14:05). Como as duas contas do Danilo são AMBAS admin, a
-- primeira tentativa de prova não valia nada (respondia sempre). Repetida com
-- um utilizador que não é admin:
--   sou admin?                 -> false
--   plano de outra pessoa      -> recusou com 42501
--   cadeado de outra pessoa    -> recusou com 42501
--   limite de outra pessoa     -> recusou com 42501
-- E o servidor continua a poder:
--   service_role pergunta pelo plano de um utilizador -> trial
--   service_role pergunta por um cadeado              -> true

create or replace function public.pode_ver_plano(uid uuid) returns boolean
language sql stable security definer set search_path to 'public' as $$
  select uid = auth.uid()
      or coalesce(auth.role(), '') = 'service_role'
      or current_user = 'service_role'
      or public.is_admin();
$$;
revoke execute on function public.pode_ver_plano(uuid) from anon, public;
grant  execute on function public.pode_ver_plano(uuid) to authenticated, service_role;

create or replace function public.plano_efetivo(uid uuid) returns text
language plpgsql stable security definer set search_path to 'public' as $$
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
    else 'free' end
  into r
  from public.profiles p where p.user_id = uid;
  return r;
end $$;

create or replace function public.feature_permitida(uid uuid, flag text) returns boolean
language sql stable security definer set search_path to 'public' as $$
  select case public.plano_efetivo(uid)
    when 'trial' then true
    when 'familia' then coalesce((select familia from public.feature_flags where chave = flag), false)
    when 'pro' then coalesce((select pro from public.feature_flags where chave = flag), false)
    else coalesce((select free from public.feature_flags where chave = flag), false) end;
$$;

create or replace function public.feature_limite(uid uuid, flag text) returns integer
language sql stable security definer set search_path to 'public' as $$
  select case public.plano_efetivo(uid)
    when 'trial' then null
    when 'familia' then (select limite_familia from public.feature_flags where chave = flag)
    when 'pro' then (select limite_pro from public.feature_flags where chave = flag)
    else (select limite_free from public.feature_flags where chave = flag) end;
$$;

comment on function public.plano_efetivo(uuid) is
  'Plano em vigor. Só responde sobre quem pergunta, ou a admin/service_role (2026-09-06).';
