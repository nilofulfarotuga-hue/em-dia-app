-- B7 (2026-09-18): a simulação do «apagar conta» também é chamada pela Edge
-- Function admin-apagar-conta com a service role (sem JWT de pessoa) — e o
-- is_admin() só olha para o JWT. A service role passa; o resto continua a
-- exigir admin. (Prova: pg_net id 308 devolveu 500 «so_admin» antes disto.)
create or replace function public.admin_apagar_conta_simular(p_user_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  r jsonb;
begin
  if not (public.is_admin() or coalesce(auth.role(), '') = 'service_role') then
    raise exception 'so_admin' using errcode = '42501';
  end if;
  select jsonb_build_object(
    'user_id', p_user_id,
    'existe', exists (select 1 from auth.users u where u.id = p_user_id),
    'email', (select u.email from auth.users u where u.id = p_user_id),
    'eh_admin', exists (select 1 from public.admins a where a.user_id = p_user_id),
    'linhas', jsonb_build_object(
      'profiles', (select count(*) from public.profiles x where x.user_id = p_user_id),
      'obrigacoes', (select count(*) from public.obrigacoes x where x.user_id = p_user_id),
      'rendimentos', (select count(*) from public.rendimentos x where x.user_id = p_user_id),
      'entradas', (select count(*) from public.entradas x where x.user_id = p_user_id),
      'saidas', (select count(*) from public.saidas x where x.user_id = p_user_id),
      'saidas_pagamentos', (select count(*) from public.saidas_pagamentos x where x.user_id = p_user_id),
      'movimentos_banco', (select count(*) from public.movimentos_banco x where x.user_id = p_user_id),
      'importacoes_extrato', (select count(*) from public.importacoes_extrato x where x.user_id = p_user_id),
      'cofre_movimentos', (select count(*) from public.cofre_movimentos x where x.user_id = p_user_id),
      'carros', (select count(*) from public.carros x where x.user_id = p_user_id),
      'abastecimentos', (select count(*) from public.abastecimentos x where x.user_id = p_user_id),
      'despesas_carro', (select count(*) from public.despesas_carro x where x.user_id = p_user_id),
      'leituras_ocr', (select count(*) from public.leituras_ocr x where x.user_id = p_user_id),
      'faturas_recebidas', (select count(*) from public.faturas_recebidas x where x.user_id = p_user_id),
      'recibos_emitidos', (select count(*) from public.recibos_emitidos x where x.user_id = p_user_id),
      'pastas_contabilista', (select count(*) from public.pastas_contabilista x where x.user_id = p_user_id),
      'assinaturas', (select count(*) from public.assinaturas x where x.user_id = p_user_id),
      'push_tokens', (select count(*) from public.push_tokens x where x.user_id = p_user_id),
      'eventos_push', (select count(*) from public.eventos_push x where x.user_id = p_user_id),
      'conversas_ia_ficam_anonimas', (select count(*) from public.conversas_ia x where x.user_id = p_user_id),
      'tickets_ficam_anonimos', (select count(*) from public.tickets_suporte x where x.user_id = p_user_id)
    ),
    'ficheiros_storage', (select count(*) from storage.objects o where (storage.foldername(o.name))[1] = p_user_id::text),
    'ficheiros_por_bucket', coalesce((select jsonb_object_agg(bucket_id, n) from (
        select o.bucket_id, count(*) as n from storage.objects o where (storage.foldername(o.name))[1] = p_user_id::text group by 1) s), '{}'::jsonb)
  ) into r;
  return r;
end $$;
