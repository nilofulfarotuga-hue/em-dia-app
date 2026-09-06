-- 0009 — fecha os avisos de segurança do linter do Supabase (2026-09-06, noite).
--
-- Encontrado por `get_advisors(type: security)` e CONFIRMADO com pedidos reais
-- à API pública (docs/provas/seguranca-supabase-2026-09-06.md):
--
--   1) Qualquer pessoa COM SESSÃO lia `v_custo_ia_diario`. Um utilizador normal
--      de teste recebeu, tal e qual:
--         [{"dia":"2026-09-06","conversas":37,"custo_eur":0.170677}]
--      Isso é informação do negócio (quanto a IA gastou, quantas conversas
--      houve na plataforma toda) e só o painel de administração a devia ver.
--      A view não tinha `security_invoker`, por isso corria como dona e passava
--      por cima do RLS da tabela `conversas_ia`.
--
--   2) `plano_efetivo(uid)`, `feature_permitida(uid, flag)` e
--      `feature_limite(uid, flag)` são SECURITY DEFINER, aceitam o uid de
--      QUALQUER pessoa e estavam ao alcance de quem não tem sessão. Provado:
--         POST /rest/v1/rpc/plano_efetivo {"uid":"500f99a2-…"}  -> 200 "trial"
--      Ninguém sem sessão precisa delas: a app só as chama depois de entrar
--      (lib/stores/regras_store.dart) e as Edge Functions usam a service role.
--
--   3) Quatro funções sem `search_path` fixo. Nenhuma é SECURITY DEFINER, por
--      isso o risco é pequeno, mas fixá-lo não custa nada.
--
-- O QUE NÃO SE MEXE, DE PROPÓSITO:
--   · `is_admin()` continua ao alcance de todos. Não é fuga nenhuma (não leva
--     argumentos e responde sobre QUEM chama; a quem não tem sessão responde
--     `false`), e 31 políticas de RLS chamam-na — inclusive as de
--     `regras_legais` e `guias`, que o site lê sem sessão. Tirar-lhe a permissão
--     partia a calculadora do site.
--   · `handle_new_user()` e `admin_automatico()` são funções de gatilho e não
--     são chamáveis pela API (provado: HTTP 404 PGRST202). Mexer nas permissões
--     delas arrisca partir o registo de contas para calar um aviso que não
--     corresponde a um buraco real.
--   · `pg_net` fica no schema `public`: movê-la parte os trabalhos do pg_cron.

-- 1) O custo da IA passa a ser só do administrador -------------------------
drop view if exists public.v_custo_ia_diario;
create view public.v_custo_ia_diario
with (security_invoker = true) as
  select (criado_em at time zone 'Europe/Lisbon')::date as dia,
         count(*)            as conversas,
         sum(custo_tokens)   as custo_eur
    from public.conversas_ia
   where public.is_admin()
   group by 1
   order by 1 desc;

comment on view public.v_custo_ia_diario is
  'Custo diário da IA. Só o administrador vê linhas (where is_admin()), e corre '
  'com o RLS de quem pergunta (security_invoker) — 2026-09-06.';

grant select on public.v_custo_ia_diario to authenticated, service_role;

-- 2) Quem não tem sessão deixa de poder perguntar pelo plano dos outros -----
revoke execute on function public.plano_efetivo(uuid)              from anon, public;
revoke execute on function public.feature_permitida(uuid, text)    from anon, public;
revoke execute on function public.feature_limite(uuid, text)       from anon, public;
-- (quem tem sessão e a service role mantêm a permissão própria que já tinham)

-- 3) search_path fixo ------------------------------------------------------
alter function public.set_atualizado_em()             set search_path = public, pg_temp;
alter function public.protege_campos_servidor()       set search_path = public, pg_temp;
alter function public.eh_dia_util(date)               set search_path = public, pg_temp;
alter function public.dia_util_anterior_ou_igual(date) set search_path = public, pg_temp;
