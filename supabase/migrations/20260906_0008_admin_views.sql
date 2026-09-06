-- Em Dia — 0008: apoio ao painel admin (2026-09-06)
-- Uma view com o plano efetivo por utilizador e duas RPCs (só admin): resumo da
-- visão geral e perguntas mais feitas à IA. Nada aqui é escrito pelo cliente.

-- Lista de utilizadores com o plano efetivo (trial > assinatura ativa > profiles.plano > free).
-- security_invoker: a RLS de profiles aplica-se a quem chama (o admin vê tudo, o resto só a si).
create or replace view public.v_admin_usuarios with (security_invoker = true) as
  select p.user_id, p.email, p.nome, p.telefone, p.tipo_atividade, p.plano, p.trial_ate,
         p.ultimo_acesso, p.banido, p.criado_em, p.variante_pt, p.onboarding_concluido,
         public.plano_efetivo(p.user_id) as plano_efetivo
  from public.profiles p;
grant select on public.v_admin_usuarios to authenticated;

-- Resumo da visão geral (uma chamada em vez de dez). Os preços vêm de regras_legais.
create or replace function public.admin_resumo() returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  hoje date := (now() at time zone 'Europe/Lisbon')::date;
  r jsonb;
begin
  if not public.is_admin() then
    raise exception 'so_admin' using errcode = '42501';
  end if;
  select jsonb_build_object(
    'usuarios_total', (select count(*) from public.profiles),
    'usuarios_ativos_7d', (select count(*) from public.profiles where ultimo_acesso > now() - interval '7 days'),
    'planos', coalesce((select jsonb_object_agg(plano, n)
                        from (select public.plano_efetivo(user_id) as plano, count(*) as n
                              from public.profiles group by 1) s), '{}'::jsonb),
    'receita_mensal_eur', (
      select coalesce(sum(case a.produto_id
        when 'pro_mensal'     then (select valor_num from public.regras_legais where chave = 'preco_pro_mensal')
        when 'pro_anual'      then (select valor_num from public.regras_legais where chave = 'preco_pro_anual') / 12
        when 'familia_mensal' then (select valor_num from public.regras_legais where chave = 'preco_familia_mensal')
        when 'familia_anual'  then (select valor_num from public.regras_legais where chave = 'preco_familia_anual') / 12
        else 0 end), 0)
      from public.assinaturas a
      where a.estado = 'ativa' and coalesce(a.renova_em, now() + interval '1 day') > now()),
    'assinaturas_ativas', (select count(*) from public.assinaturas a
                           where a.estado = 'ativa' and coalesce(a.renova_em, now() + interval '1 day') > now()),
    'tickets_abertos', (select count(*) from public.tickets_suporte where estado <> 'fechado'),
    'tickets_escalados', (select count(*) from public.tickets_suporte where estado <> 'fechado' and escalar_humano),
    'obrigacoes_passadas', (select count(*) from public.obrigacoes where estado = 'passado'),
    'alarme_eur', (select valor_num from public.regras_legais where chave = 'ia_custo_alarme_dia_eur'),
    'custo_ia', coalesce((select jsonb_agg(jsonb_build_object('dia', dia, 'conversas', conversas, 'custo_eur', custo_eur) order by dia desc)
                          from public.v_custo_ia_diario where dia > hoje - 7), '[]'::jsonb),
    'push_hoje', coalesce((select jsonb_agg(jsonb_build_object('resultado', coalesce(resultado, 'pendente'), 'n', n))
                           from (select resultado, count(*) as n from public.eventos_push where dia = hoje group by 1) s), '[]'::jsonb),
    'hoje', hoje
  ) into r;
  return r;
end $$;
revoke all on function public.admin_resumo() from public, anon;
grant execute on function public.admin_resumo() to authenticated, service_role;

-- Perguntas mais feitas à IA (normalizadas: minúsculas, espaços juntos). Só admin vê linhas.
create or replace function public.admin_ia_top_perguntas(limite integer default 30)
returns table (pergunta text, n bigint, ultima timestamptz, fora_das_regras bigint, variante_br bigint)
language sql stable security definer set search_path = public as $$
  select lower(regexp_replace(trim(c.pergunta), '\s+', ' ', 'g')) as pergunta,
         count(*) as n,
         max(c.criado_em) as ultima,
         count(*) filter (where c.fora_das_regras) as fora_das_regras,
         count(*) filter (where c.variante = 'br') as variante_br
  from public.conversas_ia c
  where public.is_admin() and c.modo <> 'extrato'
  group by 1
  order by 2 desc, 3 desc
  limit greatest(1, least(limite, 200));
$$;
revoke all on function public.admin_ia_top_perguntas(integer) from public, anon;
grant execute on function public.admin_ia_top_perguntas(integer) to authenticated, service_role;
