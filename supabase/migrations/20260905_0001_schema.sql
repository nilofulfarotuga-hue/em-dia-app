-- Em Dia — 0001 schema (2026-09-05)
-- Todas as tabelas com RLS (ver 0002). Valores legais NUNCA no código: vivem em regras_legais.
create extension if not exists pgcrypto;

-- ---------- utilidades ----------
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  criado_em timestamptz not null default now()
);

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin', false)
      or exists (select 1 from public.admins a where a.user_id = auth.uid());
$$;

create or replace function public.set_atualizado_em() returns trigger
language plpgsql as $$
begin new.atualizado_em = now(); return new; end $$;

-- ---------- perfis ----------
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nome text,
  email text,
  telefone text,
  tipo_atividade text not null default 'sem_atividade'
    check (tipo_atividade in ('tvde','estafeta','servicos','freelancer','sem_atividade','so_carro')),
  data_abertura date,
  regime_iva text not null default 'isento_53' check (regime_iva in ('isento_53','normal')),
  faturou_mais_15k_ano_anterior boolean not null default false,
  retencao_opcao text not null default 'padrao' check (retencao_opcao in ('padrao','25','dispensa')),
  tipo_rendimento text not null default 'servicos' check (tipo_rendimento in ('servicos','vendas')),
  rendimento_mensal_estimado numeric(12,2),
  ajuste_ss_pct smallint not null default 0 check (ajuste_ss_pct between -25 and 25),
  variante_pt text not null default 'pt' check (variante_pt in ('pt','br')),
  plano text not null default 'free' check (plano in ('free','pro','familia')),
  trial_ate timestamptz not null default (now() + interval '30 days'),
  onboarding_concluido boolean not null default false,
  imigrante boolean not null default false,
  residencia_renova_em date,
  ultimo_acesso timestamptz,
  banido boolean not null default false,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create trigger trg_profiles_atualizado before update on public.profiles
  for each row execute function public.set_atualizado_em();

-- trial_ate é do SERVIDOR: o cliente não o pode escrever (mudar a hora do telemóvel não engana)
create or replace function public.protege_campos_servidor() returns trigger
language plpgsql as $$
begin
  if not public.is_admin() and auth.role() <> 'service_role' then
    new.trial_ate := old.trial_ate;
    new.plano := old.plano;
    new.banido := old.banido;
    new.criado_em := old.criado_em;
  end if;
  return new;
end $$;
create trigger trg_profiles_servidor before update on public.profiles
  for each row execute function public.protege_campos_servidor();

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (user_id, email, nome, telefone)
  values (new.id, new.email,
          coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
          new.phone)
  on conflict (user_id) do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- rendimentos ----------
create table if not exists public.rendimentos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  mes date not null,                                   -- 1.º dia do mês
  valor_bruto numeric(12,2) not null check (valor_bruto >= 0),
  tipo text not null default 'servicos' check (tipo in ('servicos','vendas')),
  origem text not null default 'manual' check (origem in ('manual','foto')),
  plataforma text,                                     -- uber | bolt | glovo | outro
  comprovativo_url text,
  nota text,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index if not exists rendimentos_user_mes on public.rendimentos (user_id, mes);
create trigger trg_rendimentos_atualizado before update on public.rendimentos
  for each row execute function public.set_atualizado_em();

-- ---------- carros ----------
create table if not exists public.carros (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  nome text,
  matricula text not null,
  data_matricula date,
  mes_matricula smallint check (mes_matricula between 1 and 12),
  ano_matricula smallint check (ano_matricula between 1950 and 2100),
  categoria text not null default 'proprio' check (categoria in ('proprio','alugado_frota')),
  uso_tvde boolean not null default false,
  combustivel text check (combustivel in ('gasolina','gasoleo','eletrico','hibrido','gpl','outro')),
  cilindrada_cc integer,
  co2_g_km integer,
  seguradora text,
  seguro_renova_em date,
  ultima_ipo date,
  proxima_ipo date,
  km_atual integer,
  carta_validade date,
  revisao_proxima date,
  revisao_km integer,
  ativo boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index if not exists carros_user on public.carros (user_id);
create trigger trg_carros_atualizado before update on public.carros
  for each row execute function public.set_atualizado_em();

create table if not exists public.abastecimentos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  carro_id uuid not null references public.carros(id) on delete cascade,
  data date not null default current_date,
  litros numeric(8,2) check (litros > 0),
  valor_total numeric(10,2) not null check (valor_total >= 0),
  km integer,
  tipo_combustivel text,
  deposito_cheio boolean not null default true,
  posto text,
  com_nif boolean not null default false,
  criado_em timestamptz not null default now()
);
create index if not exists abastecimentos_carro_data on public.abastecimentos (carro_id, data);

create table if not exists public.despesas_carro (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  carro_id uuid not null references public.carros(id) on delete cascade,
  data date not null default current_date,
  tipo text not null check (tipo in ('iuc','ipo','seguro','revisao','pneus','reparacao','portagem','multa','estacionamento','lavagem','outro')),
  valor numeric(10,2) not null check (valor >= 0),
  descricao text,
  comprovativo_url text,
  com_nif boolean not null default false,
  data_limite date,                                     -- portagens/multas: 15 dias úteis
  pago boolean not null default true,
  criado_em timestamptz not null default now()
);
create index if not exists despesas_carro_carro_data on public.despesas_carro (carro_id, data);

-- ---------- obrigações (o calendário) ----------
create table if not exists public.obrigacoes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  carro_id uuid references public.carros(id) on delete cascade,
  tipo text not null check (tipo in (
    'ss_declaracao','ss_pagamento','iva_declaracao','iva_pagamento','irs_entrega','irs_pagamento_conta',
    'efatura_validar','recibos_comunicar','iuc','ipo','seguro','carta','revisao','residencia','troca_carta',
    'tvde_certificado','tvde_licenca','multa','portagem','fim_isencao_ss','outro')),
  descricao text not null,
  data_limite date not null,
  aviso_em date not null,                               -- véspera útil se cair a fim-de-semana/feriado
  valor_estimado numeric(12,2),
  estado text not null default 'pendente' check (estado in ('pendente','pago','passado')),
  comprovativo_url text,
  origem_regra text,                                    -- chave de regras_legais que a gerou
  como_pagar text,                                      -- texto curto: referência MB / onde clicar
  chave_unica text not null,                            -- user|tipo|data (regeneração idempotente)
  pago_em timestamptz,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  unique (user_id, chave_unica)
);
create index if not exists obrigacoes_user_data on public.obrigacoes (user_id, data_limite);
create index if not exists obrigacoes_aviso on public.obrigacoes (aviso_em) where estado = 'pendente';
create trigger trg_obrigacoes_atualizado before update on public.obrigacoes
  for each row execute function public.set_atualizado_em();

-- ---------- regras legais (a única fonte de números) ----------
create table if not exists public.regras_legais (
  chave text primary key,
  valor_num numeric,
  valor_txt text,
  valor_json jsonb,
  unidade text,                                         -- eur | pct | meses | anos | dias_uteis | dia_do_mes | tabela
  ano smallint not null default 2026,
  descricao text not null,
  fonte_url text,
  confianca text not null default 'oficial' check (confianca in ('oficial','aproximado','por_confirmar')),
  verificado_em date,
  atualizado_em timestamptz not null default now()
);
create trigger trg_regras_atualizado before update on public.regras_legais
  for each row execute function public.set_atualizado_em();

create table if not exists public.irs_escaloes (
  id serial primary key,
  ano smallint not null,
  ate numeric(12,2),                                    -- null = sem limite
  taxa numeric(6,4) not null,                           -- 0.1300 = 13%
  parcela_abater numeric(12,2) not null default 0,
  ordem smallint not null,
  unique (ano, ordem)
);

create table if not exists public.feriados (
  data date primary key,
  nome text not null,
  ambito text not null default 'nacional'
);

create or replace function public.eh_dia_util(d date) returns boolean
language sql stable as $$
  select extract(isodow from d) < 6 and not exists (select 1 from public.feriados f where f.data = d);
$$;

-- véspera útil: se o prazo cai a fim-de-semana/feriado, o aviso vai para o último dia útil antes.
create or replace function public.dia_util_anterior_ou_igual(d date) returns date
language plpgsql stable as $$
declare x date := d;
begin
  while not public.eh_dia_util(x) loop x := x - 1; end loop;
  return x;
end $$;

-- ---------- guias ----------
create table if not exists public.guias (
  slug text primary key,
  titulo text not null,
  resumo text,
  corpo_pt text not null,
  corpo_br text,
  audio_url text,
  fonte_url text,
  categoria text,
  ordem smallint not null default 100,
  publicado boolean not null default true,
  verificado_em date,
  atualizado_em timestamptz not null default now()
);
create trigger trg_guias_atualizado before update on public.guias
  for each row execute function public.set_atualizado_em();

-- ---------- IA / suporte ----------
create table if not exists public.conversas_ia (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  pergunta text not null,
  resposta text,
  variante text not null default 'pt' check (variante in ('pt','br')),
  modelo text,
  tokens_entrada integer not null default 0,
  tokens_saida integer not null default 0,
  custo_tokens numeric(10,6) not null default 0,       -- EUR estimado
  fora_das_regras boolean not null default false,
  modo text not null default 'chat' check (modo in ('chat','suporte','extrato')),
  criado_em timestamptz not null default now()
);
create index if not exists conversas_user_dia on public.conversas_ia (user_id, criado_em);

create table if not exists public.tickets_suporte (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  tipo text not null default 'duvida' check (tipo in ('duvida','bug','reembolso','guia_novo','outro')),
  assunto text not null,
  descricao text,
  logs text,
  estado text not null default 'aberto' check (estado in ('aberto','em_curso','fechado')),
  escalar_humano boolean not null default false,
  motivo_escala text,
  resposta_ia text,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create trigger trg_tickets_atualizado before update on public.tickets_suporte
  for each row execute function public.set_atualizado_em();

-- ---------- push ----------
create table if not exists public.push_tokens (
  token text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  plataforma text not null default 'android',
  atualizado_em timestamptz not null default now()
);
create index if not exists push_tokens_user on public.push_tokens (user_id);

create table if not exists public.eventos_push (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  obrigacao_id uuid references public.obrigacoes(id) on delete set null,
  tipo text not null,                                   -- 5_dias | dia | passado | vigia_iva | fim_isencao | carro | trial_25 | trial_31 | reativacao | massa
  dia date not null default current_date,
  titulo text not null,
  corpo text not null,
  enviado_em timestamptz,
  resultado text,                                       -- ok | sem_token | erro
  erro text,
  unique (user_id, tipo, dia, obrigacao_id)
);

create table if not exists public.avisos_massa (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  corpo text not null,
  segmento text not null default 'todos',
  enviado_por uuid references auth.users(id),
  enviado_em timestamptz,
  total_enviados integer not null default 0,
  criado_em timestamptz not null default now()
);

-- ---------- plano / assinaturas / cadeados ----------
create table if not exists public.assinaturas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  produto_id text not null,                             -- pro_mensal | pro_anual | familia_mensal | familia_anual
  plataforma text not null default 'play' check (plataforma in ('play','stripe')),
  estado text not null default 'pendente' check (estado in ('pendente','ativa','cancelada','expirada','pausa')),
  token_compra text,
  comprovativo_play jsonb,
  comecou_em timestamptz,
  renova_em timestamptz,
  terminou_em timestamptz,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  unique (plataforma, token_compra)
);
create index if not exists assinaturas_user on public.assinaturas (user_id);
create trigger trg_assinaturas_atualizado before update on public.assinaturas
  for each row execute function public.set_atualizado_em();

create table if not exists public.feature_flags (
  chave text primary key,
  descricao text not null,
  free boolean not null default false,
  pro boolean not null default true,
  familia boolean not null default true,
  limite_free integer,                                  -- null = sem limite
  limite_pro integer,
  limite_familia integer,
  atualizado_em timestamptz not null default now()
);

-- plano efetivo: trial (30 dias, servidor) > assinatura ativa > free
create or replace function public.plano_efetivo(uid uuid) returns text
language sql stable security definer set search_path = public as $$
  select case
    when p.trial_ate > now() then 'trial'
    when exists (select 1 from public.assinaturas a where a.user_id = uid and a.estado = 'ativa'
                   and a.produto_id like 'familia%' and coalesce(a.renova_em, now() + interval '1 day') > now()) then 'familia'
    when exists (select 1 from public.assinaturas a where a.user_id = uid and a.estado = 'ativa'
                   and a.produto_id like 'pro%' and coalesce(a.renova_em, now() + interval '1 day') > now()) then 'pro'
    when p.plano in ('pro','familia') then p.plano
    else 'free' end
  from public.profiles p where p.user_id = uid;
$$;

create or replace function public.feature_permitida(uid uuid, flag text) returns boolean
language sql stable security definer set search_path = public as $$
  select case public.plano_efetivo(uid)
    when 'trial' then true
    when 'familia' then coalesce((select familia from public.feature_flags where chave = flag), false)
    when 'pro' then coalesce((select pro from public.feature_flags where chave = flag), false)
    else coalesce((select free from public.feature_flags where chave = flag), false) end;
$$;

create or replace function public.feature_limite(uid uuid, flag text) returns integer
language sql stable security definer set search_path = public as $$
  select case public.plano_efetivo(uid)
    when 'trial' then null
    when 'familia' then (select limite_familia from public.feature_flags where chave = flag)
    when 'pro' then (select limite_pro from public.feature_flags where chave = flag)
    else (select limite_free from public.feature_flags where chave = flag) end;
$$;

-- ---------- auditoria / provas ----------
create table if not exists public.admin_audit_log (
  id bigserial primary key,
  admin_id uuid references auth.users(id),
  acao text not null,
  alvo_tipo text,
  alvo_id text,
  antes jsonb,
  depois jsonb,
  criado_em timestamptz not null default now()
);

create table if not exists public.e2e_log (
  id bigserial primary key,
  created_at timestamptz not null default now(),
  fluxo text,
  passo text,
  estado text,
  detalhe text,
  device text,
  run_id text
);

-- custo IA por dia (alarme no admin acima de 0,50 €/dia)
create or replace view public.v_custo_ia_diario as
  select (criado_em at time zone 'Europe/Lisbon')::date as dia,
         count(*) as conversas,
         sum(custo_tokens) as custo_eur
  from public.conversas_ia group by 1 order by 1 desc;
