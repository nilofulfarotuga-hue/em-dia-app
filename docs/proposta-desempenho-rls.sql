-- PROPOSTA de desempenho — NÃO ESTÁ APLICADA e NÃO está em supabase/migrations/
-- de propósito, para ninguém a correr sem querer.
--
-- Vem de `get_advisors(type: performance)` a 2026-09-06: 16 avisos
-- `auth_rls_initplan` e 7 `unindexed_foreign_keys`.
--
-- O QUE MUDA: as 16 políticas têm todas a MESMA condição,
--   ((user_id = auth.uid()) OR is_admin())
-- que o Postgres reavalia LINHA A LINHA. Envolver as duas chamadas em
-- `(select …)` faz com que sejam calculadas UMA vez por consulta. A regra
-- é a mesma; só o número de vezes que se pergunta é que muda.
--
-- PORQUE NÃO FOI APLICADA na noite de 2026-09-06: uma política de RLS mal
-- escrita não fica lenta, fica ABERTA. Com 5 utilizadores o ganho hoje é
-- zero e a app está no teste interno. Aplica-se com alguém a ver, e a
-- seguir corre-se a verificação do fim deste ficheiro.

begin;

-- 1) auth.uid() e is_admin() calculados uma vez por consulta ---------------
alter policy "abastecimentos_all" on public.abastecimentos
  using (((select auth.uid()) = user_id) or (select public.is_admin()))
  with check (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "admins_select" on public.admins
  using (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "assinaturas_select" on public.assinaturas
  using (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "carros_all" on public.carros
  using (((select auth.uid()) = user_id) or (select public.is_admin()))
  with check (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "conversas_insert" on public.conversas_ia
  with check (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "conversas_select" on public.conversas_ia
  using (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "despesas_carro_all" on public.despesas_carro
  using (((select auth.uid()) = user_id) or (select public.is_admin()))
  with check (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "eventos_select" on public.eventos_push
  using (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "obrigacoes_all" on public.obrigacoes
  using (((select auth.uid()) = user_id) or (select public.is_admin()))
  with check (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "profiles_insert" on public.profiles
  with check (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "profiles_select" on public.profiles
  using (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "profiles_update" on public.profiles
  using (((select auth.uid()) = user_id) or (select public.is_admin()))
  with check (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "push_tokens_all" on public.push_tokens
  using (((select auth.uid()) = user_id) or (select public.is_admin()))
  with check (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "rendimentos_all" on public.rendimentos
  using (((select auth.uid()) = user_id) or (select public.is_admin()))
  with check (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "tickets_insert" on public.tickets_suporte
  with check (((select auth.uid()) = user_id) or (select public.is_admin()));
alter policy "tickets_select" on public.tickets_suporte
  using (((select auth.uid()) = user_id) or (select public.is_admin()));

-- 2) índices nas chaves estrangeiras que não os tinham ---------------------
create index if not exists idx_abastecimentos_user_id on public.abastecimentos (user_id);
create index if not exists idx_admin_audit_log_admin_id on public.admin_audit_log (admin_id);
create index if not exists idx_avisos_massa_enviado_por on public.avisos_massa (enviado_por);
create index if not exists idx_despesas_carro_user_id on public.despesas_carro (user_id);
create index if not exists idx_eventos_push_user_id on public.eventos_push (user_id);
create index if not exists idx_obrigacoes_carro_id on public.obrigacoes (carro_id);
create index if not exists idx_tickets_suporte_user_id on public.tickets_suporte (user_id);

commit;

-- 3) VERIFICAÇÃO — correr DEPOIS, e comparar com o esperado ----------------
-- Um utilizador normal só se vê a si; o administrador vê tudo.
--   normal  -> profiles: 1 linha (a dele)   · conversas_ia: só as dele
--   admin   -> profiles: todas             · v_custo_ia_diario: com linhas
--   sem sessão -> profiles: 0 linhas       · regras_legais: com linhas
-- O guião de docs/provas/seguranca-supabase-2026-09-06.md faz exactamente isto.
