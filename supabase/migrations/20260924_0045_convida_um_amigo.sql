-- Convida um amigo (2026-09-24, missão em-dia-crescimento-organico): cada pessoa tem um código
-- próprio (link app.emdia.boraguarda.com/?c=CODIGO). Quando o amigo se regista com esse código e
-- USA a app (1.º rendimento/recibo, 1.ª entrada/saída ou 1.º prazo registado à mão), os dois
-- ganham 30 dias de plano pago (trial_ate + 30 dias). Anti-abuso: 1 prémio por pessoa convidada
-- (email confirmado, conta nova), no máximo 12 prémios (12 meses) por convidador, nunca a si
-- próprio. Tudo do lado do servidor: o cliente não escreve trial_ate.

alter table public.profiles add column if not exists codigo_convite text unique;
alter table public.profiles add column if not exists convidado_por uuid references auth.users(id) on delete set null;

create table if not exists public.convites (
  id            bigint generated always as identity primary key,
  convidador_id uuid not null references auth.users(id) on delete cascade,
  convidado_id  uuid not null unique references auth.users(id) on delete cascade,
  codigo        text not null,
  estado        text not null default 'pendente' check (estado in ('pendente','premiado','anulado')),
  motivo        text,
  criado_em     timestamptz not null default now(),
  premiado_em   timestamptz,
  premio_convidador boolean not null default false,
  premio_convidado  boolean not null default false
);
create index if not exists convites_convidador_idx on public.convites (convidador_id, estado);
alter table public.convites enable row level security;
drop policy if exists convites_ver_os_meus on public.convites;
create policy convites_ver_os_meus on public.convites for select to authenticated
  using (auth.uid() = convidador_id or auth.uid() = convidado_id or public.is_admin());
comment on table public.convites is 'Convida um amigo: quem convidou quem, e se o prémio (30 dias) já foi dado aos dois.';

-- O trigger que protege trial_ate/plano só deixa o servidor escrever; as RPCs daqui marcam-se
-- com esta chave de sessão para passar (só dentro da própria transação).
create or replace function public.protege_campos_servidor() returns trigger
language plpgsql as $$
begin
  if not public.is_admin() and auth.role() <> 'service_role'
     and coalesce(current_setting('emdia.servidor', true), '') <> 'convites' then
    new.trial_ate := old.trial_ate;
    new.plano := old.plano;
    new.banido := old.banido;
    new.criado_em := old.criado_em;
  end if;
  return new;
end $$;

-- O meu código (cria-o à primeira vez) e os números para o ecrã «Convida e ganha».
create or replace function public.convite_meu()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare v_uid uuid := auth.uid(); v_cod text; v_n int; v_p int;
begin
  if v_uid is null then raise exception 'sem_sessao'; end if;
  select codigo_convite into v_cod from public.profiles where user_id = v_uid;
  if v_cod is null then
    v_cod := upper(substr(md5(v_uid::text || '|emdia-convite'), 1, 7));
    update public.profiles set codigo_convite = v_cod where user_id = v_uid;
  end if;
  select count(*), count(*) filter (where estado = 'premiado') into v_n, v_p
    from public.convites where convidador_id = v_uid;
  return jsonb_build_object('codigo', v_cod, 'link', 'https://app.emdia.boraguarda.com/?c=' || v_cod,
                            'convidados', v_n, 'premiados', v_p, 'meses_ganhos', least(v_p, 12), 'maximo', 12);
end $$;
revoke all on function public.convite_meu() from public;
grant execute on function public.convite_meu() to authenticated;

-- O amigo chegou com ?c=CODIGO: liga-o ao convidador (uma vez, conta nova, email confirmado).
create or replace function public.convite_aplicar(p_codigo text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare v_uid uuid := auth.uid(); v_conv uuid; v_cod text := upper(trim(coalesce(p_codigo, '')));
        v_criado timestamptz; v_conf timestamptz;
begin
  if v_uid is null then raise exception 'sem_sessao'; end if;
  if v_cod = '' then return jsonb_build_object('ok', false, 'motivo', 'sem_codigo'); end if;
  select user_id into v_conv from public.profiles where codigo_convite = v_cod;
  if v_conv is null then return jsonb_build_object('ok', false, 'motivo', 'codigo_desconhecido'); end if;
  if v_conv = v_uid then return jsonb_build_object('ok', false, 'motivo', 'proprio'); end if;
  if exists (select 1 from public.convites where convidado_id = v_uid) then
    return jsonb_build_object('ok', false, 'motivo', 'ja_convidado');
  end if;
  select created_at, email_confirmed_at into v_criado, v_conf from auth.users where id = v_uid;
  if v_conf is null then return jsonb_build_object('ok', false, 'motivo', 'email_nao_confirmado'); end if;
  if v_criado < now() - interval '14 days' then return jsonb_build_object('ok', false, 'motivo', 'conta_antiga'); end if;
  insert into public.convites (convidador_id, convidado_id, codigo) values (v_conv, v_uid, v_cod);
  update public.profiles set convidado_por = v_conv where user_id = v_uid and convidado_por is null;
  return jsonb_build_object('ok', true, 'motivo', 'ligado');
end $$;
revoke all on function public.convite_aplicar(text) from public;
grant execute on function public.convite_aplicar(text) to authenticated;

-- Dá o prémio quando o convidado usa a app pela 1.ª vez. Chamada pelos gatilhos abaixo.
create or replace function public.convites_premiar(p_convidado uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare r record; v_ja int;
begin
  select * into r from public.convites where convidado_id = p_convidado and estado = 'pendente';
  if not found then return; end if;
  perform set_config('emdia.servidor', 'convites', true);
  -- o convidado ganha sempre (1 prémio por pessoa real)
  update public.profiles set trial_ate = greatest(trial_ate, now()) + interval '30 days' where user_id = r.convidado_id;
  -- o convidador ganha até 12 vezes
  select count(*) into v_ja from public.convites where convidador_id = r.convidador_id and premio_convidador;
  if v_ja < 12 then
    update public.profiles set trial_ate = greatest(trial_ate, now()) + interval '30 days' where user_id = r.convidador_id;
  end if;
  update public.convites set estado = 'premiado', premiado_em = now(), premio_convidado = true,
         premio_convidador = (v_ja < 12), motivo = case when v_ja < 12 then null else 'convidador_no_maximo_12' end
   where id = r.id;
end $$;
revoke all on function public.convites_premiar(uuid) from public, anon, authenticated;

create or replace function public.trg_convites_uso() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  -- só prazos postos à mão contam (os gerados pelas regras têm origem_regra)
  -- (to_jsonb: o gatilho e' partilhado por 4 tabelas e NEW.origem_regra so existe numa)
  if tg_table_name = 'obrigacoes' and (to_jsonb(new) ->> 'origem_regra') is not null then return new; end if;
  perform public.convites_premiar(new.user_id);
  return new;
end $$;
drop trigger if exists trg_convite_rendimentos on public.rendimentos;
create trigger trg_convite_rendimentos after insert on public.rendimentos for each row execute function public.trg_convites_uso();
drop trigger if exists trg_convite_entradas on public.entradas;
create trigger trg_convite_entradas after insert on public.entradas for each row execute function public.trg_convites_uso();
drop trigger if exists trg_convite_saidas on public.saidas;
create trigger trg_convite_saidas after insert on public.saidas for each row execute function public.trg_convites_uso();
drop trigger if exists trg_convite_obrigacoes on public.obrigacoes;
create trigger trg_convite_obrigacoes after insert on public.obrigacoes for each row execute function public.trg_convites_uso();

-- Painel admin (PT-BR): quem convidou quem, prémios, e os melhores convidadores.
create or replace function public.admin_convites(p_limite integer default 300)
returns setof jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object('id', c.id, 'quando', c.criado_em, 'estado', c.estado, 'codigo', c.codigo,
    'convidador', coalesce(pc.nome, pc.email, c.convidador_id::text), 'convidado', coalesce(pv.nome, pv.email, c.convidado_id::text),
    'premiado_em', c.premiado_em, 'premio_convidador', c.premio_convidador, 'premio_convidado', c.premio_convidado, 'motivo', c.motivo)
  from public.convites c
  left join public.profiles pc on pc.user_id = c.convidador_id
  left join public.profiles pv on pv.user_id = c.convidado_id
  where public.is_admin()
  order by c.criado_em desc
  limit greatest(1, least(coalesce(p_limite, 300), 2000));
$$;
revoke all on function public.admin_convites(integer) from public;
grant execute on function public.admin_convites(integer) to authenticated, service_role;

create or replace function public.admin_convites_top(p_limite integer default 20)
returns setof jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object('convidador', coalesce(p.nome, p.email, c.convidador_id::text), 'codigo', p.codigo_convite,
    'convidados', count(*), 'premiados', count(*) filter (where c.estado = 'premiado'),
    'meses_ganhos', count(*) filter (where c.premio_convidador))
  from public.convites c join public.profiles p on p.user_id = c.convidador_id
  where public.is_admin()
  group by c.convidador_id, p.nome, p.email, p.codigo_convite
  order by count(*) filter (where c.estado = 'premiado') desc, count(*) desc
  limit greatest(1, least(coalesce(p_limite, 20), 200));
$$;
revoke all on function public.admin_convites_top(integer) from public;
grant execute on function public.admin_convites_top(integer) to authenticated, service_role;
