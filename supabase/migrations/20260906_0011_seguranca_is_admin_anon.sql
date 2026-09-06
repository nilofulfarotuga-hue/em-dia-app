-- 0011 — quem não tem sessão deixa de tocar em `is_admin()` (2026-09-06).
-- Aplicada em produção: versão 20260906140036.
--
-- A migração 0009 tinha deixado isto de fora, e com uma razão boa: 31 políticas
-- de RLS chamam `is_admin()`, e as tabelas que o site lê sem sessão
-- (regras_legais, irs_escaloes, feriados, feature_flags, guias) têm uma política
-- de administrador ao lado da de leitura. Como as políticas permissivas se
-- somam, tirar a permissão a `anon` partia a calculadora do site.
--
-- Em vez de repetir a razão, tira-se a razão: as políticas de administrador
-- passam a ser SÓ para quem tem sessão (`to authenticated`). Assim quem não tem
-- sessão nunca chega a avaliar `is_admin()`, e aí já se lhe pode tirar a
-- permissão sem partir nada. A `service_role` não é afetada — ignora o RLS.
--
-- PROVA (2026-09-06 14:00), com a chave anónima, pedidos reais:
--   GET /rest/v1/regras_legais  -> 200   GET /rest/v1/guias         -> 200
--   GET /rest/v1/irs_escaloes   -> 200   GET /rest/v1/feature_flags -> 200
--   GET /rest/v1/feriados       -> 200
--   POST /rest/v1/rpc/is_admin  -> 401 {"code":"42501","message":"permission denied for function is_admin"}
-- E com sessão: o admin vê 3 perfis e is_admin()=true; quem não é admin vê 1
-- perfil (o seu), 11 guias e 66 regras.

-- 1) `guias`: a leitura pública deixa de chamar a função ----------------------
drop policy if exists guias_read on public.guias;
create policy guias_publicas on public.guias
  for select using (publicado);
comment on table public.guias is
  'Guias. Leitura pública só das publicadas (não chama is_admin); o resto é do admin.';

-- 2) todas as políticas que chamam `is_admin()` passam a exigir sessão --------
do $$
declare p record; n int := 0;
begin
  for p in
    select tablename, policyname
      from pg_policies
     where schemaname = 'public'
       and roles::text = '{public}'
       and (qual like '%is_admin%' or coalesce(with_check,'') like '%is_admin%')
  loop
    execute format('alter policy %I on public.%I to authenticated', p.policyname, p.tablename);
    n := n + 1;
  end loop;
  raise notice 'políticas passadas para authenticated: %', n;
end $$;

-- 3) agora sim: fora do alcance de quem não tem sessão ------------------------
revoke execute on function public.is_admin() from anon, public;

-- 4) funções de gatilho: ninguém as chama pela API ----------------------------
-- (um gatilho não precisa que quem escreve na tabela tenha permissão na função;
--  a permissão é verificada quando o gatilho é criado, não quando dispara.
--  Provado: uma conta nova criada às 14:01:08, DEPOIS deste revoke, apanhou
--  perfil com plano `free` e 30 dias de mês grátis.)
revoke execute on function public.handle_new_user()  from anon, authenticated, public;
revoke execute on function public.admin_automatico() from anon, authenticated, public;
