-- B7a (2026-09-19): funil «quantos abrem, acabam o onboarding, experimentam
-- e pagam», semana a semana, para o painel admin (RPC admin_funil, só admin).
-- 1) profiles.consentiu_estatisticas — a pessoa ligou as «estatísticas de
--    utilização» nas Definições. Sem isso, a app não escreve eventos_uso.
-- 2) eventos_uso — abriu_app, concluiu_onboarding, viu_plano, iniciou_compra,
--    comprou, cancelou. O próprio insere (só com consentimento) e lê os seus;
--    o admin lê tudo. As contas, o onboarding, o trial e as assinaturas não
--    precisam de consentimento: são dados da conta, não de uso.

alter table public.profiles
  add column if not exists consentiu_estatisticas boolean not null default false;

comment on column public.profiles.consentiu_estatisticas is
  'A pessoa ligou as «estatísticas de utilização» nas Definições: sem isto, a app não escreve eventos_uso dela.';

create table if not exists public.eventos_uso (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  tipo text not null check (tipo in ('abriu_app','concluiu_onboarding','viu_plano','iniciou_compra','comprou','cancelou')),
  criado_em timestamptz not null default now()
);

create index if not exists eventos_uso_tipo_quando on public.eventos_uso (tipo, criado_em);

alter table public.eventos_uso enable row level security;

-- O próprio insere os seus eventos, só se tiver consentido (subquery na
-- policy); lê os seus. O admin lê tudo (is_admin). Ninguém altera nem apaga
-- nada por aqui.
create policy eventos_uso_insert on public.eventos_uso
  for insert to authenticated
  with check (
    auth.uid() = user_id
    and exists (select 1 from public.profiles p where p.user_id = auth.uid() and p.consentiu_estatisticas)
  );
create policy eventos_uso_select on public.eventos_uso
  for select to authenticated
  using (auth.uid() = user_id or public.is_admin());

-- Funil: uma linha por semana (segunda-feira, date_trunc('week'), fuso
-- Europe/Lisbon), as mais recentes primeiro. Colunas:
--   contas_criadas       — profiles.criado_em na semana
--   onboarding_concluido — os criados na semana que acabaram o onboarding
--   abriram              — profiles com ultimo_acesso na semana
--   em_trial             — no fim da semana: trial_ate > fim, onboarding feito e conta já criada
--   pagam                — assinaturas ativas no fim da semana (comecou_em <= fim e terminou_em nulo ou > fim)
--   eventos_consentidos  — eventos_uso escritos na semana (só existem de quem consentiu)
--   consentiram          — no fim da semana: contas com consentiu_estatisticas (acumulado)
create or replace function public.admin_funil(p_semanas integer default 8)
returns setof jsonb
language sql
stable
security definer
set search_path = public
as $$
  with semanas as (
    select w.segunda,
           w.segunda::timestamp at time zone 'Europe/Lisbon' as inicio,
           (w.segunda + 7)::timestamp at time zone 'Europe/Lisbon' as fim
    from (
      select (date_trunc('week', (now() at time zone 'Europe/Lisbon'))::date - (g.i * 7)) as segunda
      from generate_series(0, greatest(1, least(p_semanas, 104)) - 1) as g(i)
    ) w
  )
  select jsonb_build_object(
    'semana', s.segunda,
    'contas_criadas', (select count(*) from public.profiles p where p.criado_em >= s.inicio and p.criado_em < s.fim),
    'onboarding_concluido', (select count(*) from public.profiles p
                               where p.criado_em >= s.inicio and p.criado_em < s.fim and p.onboarding_concluido),
    'abriram', (select count(*) from public.profiles p where p.ultimo_acesso >= s.inicio and p.ultimo_acesso < s.fim),
    'em_trial', (select count(*) from public.profiles p
                   where p.trial_ate > s.fim and p.onboarding_concluido and p.criado_em <= s.fim),
    'pagam', (select count(*) from public.assinaturas a
                where a.estado = 'ativa' and a.comecou_em <= s.fim and (a.terminou_em is null or a.terminou_em > s.fim)),
    'eventos_consentidos', (select count(*) from public.eventos_uso e where e.criado_em >= s.inicio and e.criado_em < s.fim),
    'consentiram', (select count(*) from public.profiles p where p.consentiu_estatisticas and p.criado_em <= s.fim)
  )
  from semanas s
  where public.is_admin()
  order by s.segunda desc;
$$;

revoke all on function public.admin_funil(integer) from public;
grant execute on function public.admin_funil(integer) to authenticated, service_role;
