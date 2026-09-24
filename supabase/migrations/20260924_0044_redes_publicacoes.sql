-- Redes do Em Dia (2026-09-24, ordem do Danilo): registo do que foi publicado, do que está
-- agendado e do que falhou no Instagram (@em_dia_app) e no Facebook («Em Dia: Recibos e
-- Impostos»), separado do Bora. Quem escreve é o robô diário da VPS (emdia_redes.py) por uma
-- RPC com chave partilhada (guardada no Vault); quem lê é o painel admin (RPC só-admin).
-- Nada aqui toca em dinheiro nem em dados de pessoas.

create table if not exists public.redes_publicacoes (
  id            bigint generated always as identity primary key,
  peca          text not null,                 -- R01, C03, S12…
  formato       text not null,                 -- reel | carrossel | story | imagem
  rede          text not null check (rede in ('instagram','facebook')),
  agendada_para timestamptz,                   -- quando devia sair (hora de Lisboa convertida)
  publicada_em  timestamptz,
  estado        text not null default 'agendada'
                check (estado in ('agendada','publicada','falhou','saltada')),
  nota_fiscal   integer,                       -- 0-100 (só reels/vídeo)
  fiscal_detalhe text,
  link          text,                          -- permalink público
  id_externo    text,                          -- id da Meta
  legenda       text,
  erro          text,
  origem        text not null default 'robo',  -- robo | manual | agendado_meta
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create unique index if not exists redes_publicacoes_peca_rede_uniq
  on public.redes_publicacoes (peca, rede, coalesce(agendada_para, 'epoch'::timestamptz));
create index if not exists redes_publicacoes_estado_idx on public.redes_publicacoes (estado, agendada_para desc);
alter table public.redes_publicacoes enable row level security;
drop policy if exists redes_publicacoes_admin_le on public.redes_publicacoes;
create policy redes_publicacoes_admin_le on public.redes_publicacoes
  for select to authenticated using (public.is_admin());
comment on table public.redes_publicacoes is
  'Redes do Em Dia (IG/FB): publicado, agendado, falhou. Escreve o robô da VPS via redes_registar (chave no Vault); lê o admin.';

-- Chave partilhada do robô (o valor mete-se no Vault à mão: vault.create_secret('<chave>', 'redes_robot_key')).
create or replace function public.redes_registar(p_chave text, p_linha jsonb)
returns bigint
language plpgsql
security definer
set search_path = public, vault
as $$
declare v_ok text; v_id bigint;
begin
  select decrypted_secret into v_ok from vault.decrypted_secrets where name = 'redes_robot_key';
  if v_ok is null or p_chave is null or p_chave <> v_ok then
    raise exception 'chave_invalida';
  end if;
  insert into public.redes_publicacoes (peca, formato, rede, agendada_para, publicada_em, estado, nota_fiscal,
                                        fiscal_detalhe, link, id_externo, legenda, erro, origem)
  values (p_linha->>'peca', coalesce(p_linha->>'formato','reel'), p_linha->>'rede',
          nullif(p_linha->>'agendada_para','')::timestamptz, nullif(p_linha->>'publicada_em','')::timestamptz,
          coalesce(p_linha->>'estado','agendada'), nullif(p_linha->>'nota_fiscal','')::integer,
          p_linha->>'fiscal_detalhe', p_linha->>'link', p_linha->>'id_externo', p_linha->>'legenda',
          p_linha->>'erro', coalesce(p_linha->>'origem','robo'))
  on conflict (peca, rede, coalesce(agendada_para, 'epoch'::timestamptz)) do update
     set publicada_em = excluded.publicada_em, estado = excluded.estado, nota_fiscal = excluded.nota_fiscal,
         fiscal_detalhe = excluded.fiscal_detalhe, link = excluded.link, id_externo = excluded.id_externo,
         legenda = excluded.legenda, erro = excluded.erro, origem = excluded.origem, atualizado_em = now()
  returning id into v_id;
  return v_id;
end $$;
revoke all on function public.redes_registar(text, jsonb) from public;
grant execute on function public.redes_registar(text, jsonb) to anon, authenticated, service_role;

-- Painel: as últimas N linhas, mais recentes primeiro, com um resumo no topo.
create or replace function public.admin_redes(p_limite integer default 200)
returns setof jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', r.id, 'peca', r.peca, 'formato', r.formato, 'rede', r.rede,
    'agendada_para', r.agendada_para, 'publicada_em', r.publicada_em, 'estado', r.estado,
    'nota_fiscal', r.nota_fiscal, 'fiscal_detalhe', r.fiscal_detalhe, 'link', r.link,
    'legenda', left(coalesce(r.legenda,''), 160), 'erro', r.erro, 'origem', r.origem)
  from public.redes_publicacoes r
  where public.is_admin()
  order by coalesce(r.publicada_em, r.agendada_para, r.criado_em) desc, r.id desc
  limit greatest(1, least(coalesce(p_limite, 200), 1000));
$$;
revoke all on function public.admin_redes(integer) from public;
grant execute on function public.admin_redes(integer) to authenticated, service_role;

create or replace function public.admin_redes_resumo()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select case when public.is_admin() then jsonb_build_object(
    'publicadas_7d', (select count(*) from public.redes_publicacoes where estado = 'publicada' and publicada_em > now() - interval '7 days'),
    'agendadas', (select count(*) from public.redes_publicacoes where estado = 'agendada' and coalesce(agendada_para, now()) >= now() - interval '1 day'),
    'falhadas_7d', (select count(*) from public.redes_publicacoes where estado = 'falhou' and atualizado_em > now() - interval '7 days'),
    'ultima_publicacao', (select max(publicada_em) from public.redes_publicacoes where estado = 'publicada'),
    'proxima_agendada', (select min(agendada_para) from public.redes_publicacoes where estado = 'agendada' and agendada_para > now())
  ) else null end;
$$;
revoke all on function public.admin_redes_resumo() from public;
grant execute on function public.admin_redes_resumo() to authenticated, service_role;
