-- Grupos do Facebook do Em Dia no painel admin (2026-09-28, missão emdia-redes-2026-09-28, E2).
-- A lista (nome, link, membros, regras, se deixam promoção, última publicação) vive na VPS
-- (/opt/data/emdia-redes/grupos/grupos_emdia_estado.json); o grupos_emdia_sync.py espelha-a aqui
-- por uma RPC com a mesma chave do robô das redes (Vault 'redes_robot_key') e lê de volta as pausas.
-- O painel só lê e pausa (um grupo ou tudo). Nada aqui adere nem publica: isso é feito um a um,
-- depois do «sim» do Danilo. Nada toca em dinheiro nem em dados de utilizadores.

create table if not exists public.grupos_divulgacao (
  link               text primary key,
  nome               text not null,
  segmento           text,
  distrito           text,
  lingua             text,
  membros            integer,
  encaixe            integer,
  estado             text not null default 'candidato'
                     check (estado in ('candidato','pedido','aceite','publicado','proibe')),
  permite_publicidade text not null default 'por_confirmar'
                     check (permite_publicidade in ('sim','nao','por_confirmar')),
  regras_texto       text,
  pedido_adesao_em   timestamptz,
  aceite_em          timestamptz,
  ultima_publicacao_em timestamptz,
  ultimo_post_url    text,
  publicacoes        integer not null default 0,
  pausado            boolean not null default false,   -- só o painel muda isto
  pausado_em         timestamptz,
  atualizado_em      timestamptz not null default now()
);
create index if not exists grupos_divulgacao_estado_idx on public.grupos_divulgacao (estado, encaixe desc);
alter table public.grupos_divulgacao enable row level security;
drop policy if exists grupos_divulgacao_admin_le on public.grupos_divulgacao;
create policy grupos_divulgacao_admin_le on public.grupos_divulgacao
  for select to authenticated using (public.is_admin());

-- Uma linha só: o interruptor geral e o estado do dia que a VPS reporta.
create table if not exists public.grupos_divulgacao_config (
  id              integer primary key default 1 check (id = 1),
  pausado_tudo    boolean not null default false,
  pausado_em      timestamptz,
  tecto_hoje      integer,
  dias_limpos     integer,
  ultimo_aviso    text,
  ultimo_aviso_em timestamptz,
  ultimo_plano    date,
  sincronizado_em timestamptz,
  atualizado_em   timestamptz not null default now()
);
insert into public.grupos_divulgacao_config (id) values (1) on conflict (id) do nothing;
alter table public.grupos_divulgacao_config enable row level security;
drop policy if exists grupos_divulgacao_config_admin_le on public.grupos_divulgacao_config;
create policy grupos_divulgacao_config_admin_le on public.grupos_divulgacao_config
  for select to authenticated using (public.is_admin());

-- VPS -> base: espelha a lista (sem nunca mexer em 'pausado') e devolve as pausas.
create or replace function public.grupos_sincronizar(p_chave text, p_grupos jsonb, p_config jsonb default '{}'::jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, vault
as $$
declare v_ok text; v_n integer;
begin
  select decrypted_secret into v_ok from vault.decrypted_secrets where name = 'redes_robot_key';
  if v_ok is null or p_chave is null or p_chave <> v_ok then
    raise exception 'chave_invalida';
  end if;
  insert into public.grupos_divulgacao as g (link, nome, segmento, distrito, lingua, membros, encaixe, estado,
      permite_publicidade, regras_texto, pedido_adesao_em, aceite_em, ultima_publicacao_em, ultimo_post_url, publicacoes)
  select x->>'link', coalesce(x->>'nome', x->>'link'), x->>'segmento', x->>'distrito', x->>'lingua',
         nullif(x->>'membros','')::integer, nullif(x->>'encaixe','')::integer,
         coalesce(x->>'estado','candidato'), coalesce(x->>'permite_publicidade','por_confirmar'), x->>'regras_texto',
         nullif(x->>'pedido_adesao_em','')::timestamptz, nullif(x->>'aceite_em','')::timestamptz,
         nullif(x->>'ultima_publicacao_em','')::timestamptz, x->>'ultimo_post_url',
         coalesce(nullif(x->>'publicacoes','')::integer, 0)
  from jsonb_array_elements(coalesce(p_grupos, '[]'::jsonb)) x
  where coalesce(x->>'link','') <> ''
  on conflict (link) do update set
      nome = excluded.nome, segmento = excluded.segmento, distrito = excluded.distrito, lingua = excluded.lingua,
      membros = excluded.membros, encaixe = excluded.encaixe, estado = excluded.estado,
      permite_publicidade = excluded.permite_publicidade, regras_texto = excluded.regras_texto,
      pedido_adesao_em = excluded.pedido_adesao_em, aceite_em = excluded.aceite_em,
      ultima_publicacao_em = excluded.ultima_publicacao_em, ultimo_post_url = excluded.ultimo_post_url,
      publicacoes = excluded.publicacoes, atualizado_em = now()
    where (g.nome, g.estado, g.permite_publicidade, coalesce(g.regras_texto,''), coalesce(g.membros,-1),
           g.pedido_adesao_em, g.aceite_em, g.ultima_publicacao_em, g.publicacoes)
       is distinct from
          (excluded.nome, excluded.estado, excluded.permite_publicidade, coalesce(excluded.regras_texto,''),
           coalesce(excluded.membros,-1), excluded.pedido_adesao_em, excluded.aceite_em,
           excluded.ultima_publicacao_em, excluded.publicacoes);
  get diagnostics v_n = row_count;
  update public.grupos_divulgacao_config set
      tecto_hoje = coalesce(nullif(p_config->>'tecto_hoje','')::integer, tecto_hoje),
      dias_limpos = coalesce(nullif(p_config->>'dias_limpos','')::integer, dias_limpos),
      ultimo_aviso = coalesce(nullif(p_config->>'ultimo_aviso',''), ultimo_aviso),
      ultimo_aviso_em = coalesce(nullif(p_config->>'ultimo_aviso_em','')::timestamptz, ultimo_aviso_em),
      ultimo_plano = coalesce(nullif(p_config->>'ultimo_plano','')::date, ultimo_plano),
      sincronizado_em = now(), atualizado_em = now()
  where id = 1;
  return jsonb_build_object(
    'mudados', v_n,
    'total', (select count(*) from public.grupos_divulgacao),
    'pausado_tudo', (select pausado_tudo from public.grupos_divulgacao_config where id = 1),
    'pausados', coalesce((select jsonb_agg(link order by link) from public.grupos_divulgacao where pausado), '[]'::jsonb));
end $$;
revoke all on function public.grupos_sincronizar(text, jsonb, jsonb) from public;
grant execute on function public.grupos_sincronizar(text, jsonb, jsonb) to anon, authenticated, service_role;

-- Painel: lista (os que já andam primeiro, depois por encaixe e membros).
create or replace function public.admin_grupos(p_limite integer default 500)
returns setof jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'link', g.link, 'nome', g.nome, 'segmento', g.segmento, 'distrito', g.distrito, 'membros', g.membros,
    'encaixe', g.encaixe, 'estado', g.estado, 'permite_publicidade', g.permite_publicidade,
    'regras_texto', left(coalesce(g.regras_texto,''), 200), 'pedido_adesao_em', g.pedido_adesao_em,
    'aceite_em', g.aceite_em, 'ultima_publicacao_em', g.ultima_publicacao_em, 'ultimo_post_url', g.ultimo_post_url,
    'publicacoes', g.publicacoes, 'pausado', g.pausado)
  from public.grupos_divulgacao g
  where public.is_admin()
  order by (g.estado <> 'candidato') desc, g.encaixe desc nulls last, g.membros desc nulls last, g.nome
  limit greatest(1, least(coalesce(p_limite, 500), 2000));
$$;
revoke all on function public.admin_grupos(integer) from public;
grant execute on function public.admin_grupos(integer) to authenticated, service_role;

create or replace function public.admin_grupos_resumo()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select case when public.is_admin() then jsonb_build_object(
    'total', (select count(*) from public.grupos_divulgacao),
    'pedidos', (select count(*) from public.grupos_divulgacao where estado = 'pedido'),
    'aceites', (select count(*) from public.grupos_divulgacao where estado in ('aceite','publicado')),
    'publicacoes_7d', (select count(*) from public.grupos_divulgacao where ultima_publicacao_em > now() - interval '7 days'),
    'pausados', (select count(*) from public.grupos_divulgacao where pausado),
    'pausado_tudo', c.pausado_tudo, 'tecto_hoje', c.tecto_hoje, 'dias_limpos', c.dias_limpos,
    'ultimo_aviso', c.ultimo_aviso, 'ultimo_aviso_em', c.ultimo_aviso_em, 'sincronizado_em', c.sincronizado_em)
  else null end
  from public.grupos_divulgacao_config c where c.id = 1;
$$;
revoke all on function public.admin_grupos_resumo() from public;
grant execute on function public.admin_grupos_resumo() to authenticated, service_role;

-- Pausar: p_link null = interruptor geral; senão só esse grupo. Fica na auditoria do admin.
create or replace function public.admin_grupos_pausar(p_link text, p_pausado boolean)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare v_n integer;
begin
  if not public.is_admin() then raise exception 'so_admin'; end if;
  if p_link is null then
    update public.grupos_divulgacao_config
       set pausado_tudo = p_pausado, pausado_em = case when p_pausado then now() end, atualizado_em = now()
     where id = 1;
  else
    update public.grupos_divulgacao
       set pausado = p_pausado, pausado_em = case when p_pausado then now() end, atualizado_em = now()
     where link = p_link;
    get diagnostics v_n = row_count;
    if v_n = 0 then raise exception 'grupo_inexistente'; end if;
  end if;
  insert into public.admin_audit_log (admin_id, acao, alvo_tipo, alvo_id, antes, depois)
  values (auth.uid(), case when p_pausado then 'grupos_pausar' else 'grupos_retomar' end,
          'grupo_facebook', coalesce(p_link, 'todos'),
          jsonb_build_object('pausado', not p_pausado), jsonb_build_object('pausado', p_pausado));
  return jsonb_build_object('ok', true, 'link', coalesce(p_link, 'todos'), 'pausado', p_pausado);
end $$;
revoke all on function public.admin_grupos_pausar(text, boolean) from public;
grant execute on function public.admin_grupos_pausar(text, boolean) to authenticated, service_role;
