-- 0020 — a porta do administrador recusa, em vez de responder vazio (2026-09-06).
-- Aplicada em produção: versão 20260906162xxx.
--
-- O Danilo levantou a suspeita: "`admin_resumo()` e `admin_ia_top_perguntas()`
-- são chamáveis por QUALQUER utilizador com sessão. Se não verificam
-- `is_admin()` lá dentro, qualquer pessoa registada lê o resumo do
-- administrador."
--
-- Fui ver com um utilizador normal a sério — criado à mão, com palavra-passe,
-- sem estar na tabela `admins`. Resultado literal ANTES de mexer em nada:
--
--   POST /rest/v1/rpc/admin_resumo            -> 403 {"code":"42501","message":"so_admin"}
--   POST /rest/v1/rpc/admin_ia_top_perguntas  -> 200 []
--   POST /rest/v1/rpc/is_admin                -> 200 false
--
-- NÃO havia fuga. O `admin_resumo` já recusava, e o outro filtrava tudo com
-- `where public.is_admin()`, por isso a lista vinha vazia.
--
-- Mesmo assim mudei. Responder "200, nada" é ambíguo: lê-se como "não há
-- perguntas" e não como "não és tu que perguntas". Quem venha a mexer nisto
-- amanhã pode ver a lista vazia, pensar que a guarda não existe, e tirá-la.
-- Agora recusa como o irmão, com o mesmo erro e o mesmo 403.
create or replace function public.admin_ia_top_perguntas(limite integer default 30)
returns table (pergunta text, n bigint, ultima timestamptz, fora_das_regras bigint, variante_br bigint)
language plpgsql stable security definer set search_path to 'public' as $$
begin
  if not public.is_admin() then
    raise exception 'so_admin' using errcode = '42501';
  end if;
  return query
    select lower(regexp_replace(trim(c.pergunta), '\s+', ' ', 'g')) as pergunta,
           count(*) as n,
           max(c.criado_em) as ultima,
           count(*) filter (where c.fora_das_regras) as fora_das_regras,
           count(*) filter (where c.variante = 'br') as variante_br
      from public.conversas_ia c
     where c.modo <> 'extrato'
     group by 1
     order by 2 desc, 3 desc
     limit greatest(1, least(limite, 200));
end $$;
revoke execute on function public.admin_ia_top_perguntas(integer) from anon, public;
grant  execute on function public.admin_ia_top_perguntas(integer) to authenticated, service_role;

comment on function public.admin_ia_top_perguntas(integer) is
  'Perguntas mais feitas ao assistente. Só administrador; a quem não é, responde 42501 (2026-09-06).';
