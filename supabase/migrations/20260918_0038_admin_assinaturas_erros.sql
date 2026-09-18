-- B7 (2026-09-18): painel admin — assinaturas de todos, erros de OCR/importação/
-- e-mail/recibo numa lista só, e a simulação do «apagar conta» (o apagar a
-- sério é a Edge Function admin-apagar-conta, com a service role, que também
-- limpa os ficheiros do Storage).
-- Todas as funções: SECURITY DEFINER + is_admin() (o padrão de admin_resumo).

-- 1) Assinaturas de todos os utilizadores, com e-mail e plano efetivo.
create or replace function public.admin_assinaturas(p_limite integer default 500)
returns setof jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', a.id,
    'user_id', a.user_id,
    'email', p.email,
    'nome', p.nome,
    'produto_id', a.produto_id,
    'plataforma', a.plataforma,
    'estado', a.estado,
    'comecou_em', a.comecou_em,
    'renova_em', a.renova_em,
    'terminou_em', a.terminou_em,
    'criado_em', a.criado_em,
    'atualizado_em', a.atualizado_em,
    'plano_efetivo', public.plano_efetivo(a.user_id),
    'tem_comprovativo', a.comprovativo_play is not null
  )
  from public.assinaturas a
  left join public.profiles p on p.user_id = a.user_id
  where public.is_admin()
  order by a.criado_em desc
  limit greatest(1, least(p_limite, 2000));
$$;

-- 2) Erros de leitura e importação, numa lista só:
--    ocr        — leituras_ocr sem valor lido, com confiança < 0,6, ou corrigidas pela pessoa
--    importacao — importacoes_extrato com erro
--    fatura     — faturas_recebidas com estado de erro/«não deu»
--    recibo     — recibos_emitidos com erro
create or replace function public.admin_erros(p_limite integer default 300)
returns setof jsonb
language sql
stable
security definer
set search_path = public
as $$
  with tudo as (
    select 'ocr' as tipo, l.id, l.user_id, l.criado_em as quando,
           coalesce(l.tipo_esperado, '') || ' · ' || coalesce(l.entidade_nome, '(sem entidade)') ||
             case when l.valor_total is null then ' · sem valor' else ' · ' || l.valor_total::text || ' €' end as resumo,
           case when l.valor_total is null then 'sem_valor'
                when l.corrigido then 'corrigido_pela_pessoa'
                else 'confianca_' || round(coalesce(l.confianca, 0) * 100)::text end as erro,
           jsonb_build_object('origem', l.origem, 'confianca', l.confianca, 'confirmado', l.confirmado, 'corrigido', l.corrigido, 'ficheiro_url', l.ficheiro_url) as detalhe
    from public.leituras_ocr l
    where l.valor_total is null or coalesce(l.confianca, 0) < 0.6 or l.corrigido
    union all
    select 'importacao', i.id, i.user_id, i.criado_em,
           coalesce(i.banco, '?') || ' · ' || coalesce(i.formato, '?') || ' · ' || coalesce(i.ficheiro, '') ||
             ' · ' || coalesce(i.linhas_lidas, 0)::text || ' lidas',
           i.erro,
           jsonb_build_object('linhas_lidas', i.linhas_lidas, 'linhas_novas', i.linhas_novas, 'linhas_repetidas', i.linhas_repetidas, 'linhas_ignoradas', i.linhas_ignoradas)
    from public.importacoes_extrato i
    where i.erro is not null
    union all
    select 'fatura', f.id, f.user_id, coalesce(f.recebido_em, f.criado_em),
           coalesce(f.remetente, '?') || ' · ' || coalesce(f.assunto, '') || coalesce(' · ' || f.anexo_nome, ''),
           coalesce(f.erro, f.estado),
           jsonb_build_object('estado', f.estado, 'anexo_bytes', f.anexo_bytes, 'leitura_ocr_id', f.leitura_ocr_id)
    from public.faturas_recebidas f
    where f.erro is not null or f.estado in ('erro', 'nao_deu', 'sem_anexo')
    union all
    select 'recibo', r.id, r.user_id, r.criado_em,
           coalesce(r.cliente_nome, '?') || ' · ' || coalesce(r.valor::text, '') || ' € · ' || coalesce(r.descricao, ''),
           coalesce(r.erro, r.estado),
           jsonb_build_object('estado', r.estado, 'fornecedor', r.fornecedor, 'numero', r.numero)
    from public.recibos_emitidos r
    where r.erro is not null or r.estado = 'erro'
  )
  select jsonb_build_object(
    'tipo', t.tipo, 'id', t.id, 'user_id', t.user_id, 'email', p.email, 'quando', t.quando,
    'resumo', t.resumo, 'erro', t.erro, 'detalhe', t.detalhe
  )
  from tudo t
  left join public.profiles p on p.user_id = t.user_id
  where public.is_admin()
  order by t.quando desc
  limit greatest(1, least(p_limite, 2000));
$$;

-- 3) Simulação do apagar conta: quantas linhas iriam embora, por tabela, e
--    quantos ficheiros no Storage. Não apaga nada. O apagar a sério passa pela
--    Edge Function admin-apagar-conta (service role: Storage + auth.users, que
--    arrasta o resto por ON DELETE CASCADE).
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
  if not public.is_admin() then
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

revoke all on function public.admin_assinaturas(integer) from public;
revoke all on function public.admin_erros(integer) from public;
revoke all on function public.admin_apagar_conta_simular(uuid) from public;
grant execute on function public.admin_assinaturas(integer) to authenticated, service_role;
grant execute on function public.admin_erros(integer) to authenticated, service_role;
grant execute on function public.admin_apagar_conta_simular(uuid) to authenticated, service_role;
