-- 0015 — "A MINHA VIDA": o que entra e o que sai (2026-09-06).
-- Aplicada em produção: versão 20260906142351.
--
-- Até aqui a app só sabia das obrigações do Estado e do carro. Passa a saber
-- da vida toda: o dinheiro que entra (de onde e quando) e o que sai (contas
-- fixas, contas variáveis, e como se pagam).
--
-- Três tabelas novas e mais duas:
--   entradas            — cada vez que entra dinheiro
--   saidas              — a conta em si (a renda, a luz), que se repete
--   saidas_pagamentos   — cada vez que uma conta é (ou tem de ser) paga
--   cofre_movimentos    — o dinheiro posto de lado para o imposto
--   leituras_ocr        — o que a inteligência artificial leu numa foto
--
-- Porquê separar `saidas` de `saidas_pagamentos`: a renda é uma coisa só, mas
-- paga-se 12 vezes por ano. Guardar as duas juntas obrigava a repetir a
-- entidade e a referência 12 vezes, e a app perdia a noção de "isto é a mesma
-- conta". Assim o aviso, o histórico e o "quanto falta pagar este mês" saem
-- todos da mesma raiz.

-- ---------------------------------------------------------------- ENTRADAS
create table if not exists public.entradas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  data date not null,
  valor numeric(12,2) not null check (valor >= 0),
  -- de onde veio o dinheiro. Cada um conta de maneira diferente para o IRS e
  -- para a Segurança Social, por isso não é um campo livre.
  tipo text not null check (tipo in (
    'recibo_verde',   -- prestação de serviços com recibo
    'plataforma',     -- Uber, Bolt, Glovo, Uber Eats
    'salario',        -- trabalho por conta de outrem
    'dinheiro_mao',   -- biscate, sem recibo
    'arrendamento',   -- casa ou quarto arrendado
    'subsidio',       -- apoio do Estado
    'pensao',
    'outro')),
  plataforma text,                 -- só quando tipo='plataforma'
  descricao text,
  -- por que período é este valor. Quem trabalha em app recebe à semana.
  periodo text not null default 'dia' check (periodo in ('dia','semana','mes')),
  km numeric(10,1),                -- para o "vale a pena esta corrida?"
  horas numeric(6,2),
  conta_para_irs boolean not null default true,
  foto_url text,
  leitura_ocr_id uuid,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index if not exists entradas_por_pessoa_e_data on public.entradas (user_id, data desc);
create index if not exists entradas_por_tipo on public.entradas (user_id, tipo, data desc);

-- ------------------------------------------------------------------ SAÍDAS
create table if not exists public.saidas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  nome text not null,
  categoria text not null check (categoria in (
    'renda','luz','agua','gas','telemovel','internet','tv','seguro','ginasio',
    'escola','creche','credito','carro','combustivel','compras','saude',
    'assinatura','imposto','outro')),
  valor numeric(12,2),             -- nulo quando é variável e ainda não se sabe
  variavel boolean not null default false,
  dia_do_mes smallint check (dia_do_mes between 1 and 31),
  -- como se paga. Decide quantos dias antes se avisa (ver 0016).
  meio text not null default 'referencia_mb' check (meio in (
    'debito_direto','referencia_mb','mbway','transferencia','dinheiro','cartao')),
  entidade text check (entidade ~ '^[0-9]{5}$'),        -- 5 números
  referencia text check (referencia ~ '^[0-9]{9}$'),    -- 9 números
  -- Radar da fidelização: o dia em que se pode sair sem multa.
  fim_fidelizacao date,
  fornecedor text,
  ativa boolean not null default true,
  foto_url text,
  leitura_ocr_id uuid,
  notas text,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index if not exists saidas_por_pessoa on public.saidas (user_id, ativa, dia_do_mes);
create index if not exists saidas_fidelizacao on public.saidas (user_id, fim_fidelizacao)
  where fim_fidelizacao is not null;

-- ------------------------------------------------------- PAGAMENTOS DAS SAÍDAS
create table if not exists public.saidas_pagamentos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  saida_id uuid not null references public.saidas(id) on delete cascade,
  mes date not null,               -- sempre o dia 1 do mês a que respeita
  data_limite date not null,
  valor numeric(12,2),
  estado text not null default 'pendente' check (estado in ('pendente','pago','saltado')),
  pago_em timestamptz,
  comprovativo_url text,
  criado_em timestamptz not null default now(),
  unique (saida_id, mes)           -- uma conta paga-se uma vez por mês
);
create index if not exists pagamentos_por_pessoa_e_prazo
  on public.saidas_pagamentos (user_id, estado, data_limite);

-- ------------------------------------------------------------------- COFRE
create table if not exists public.cofre_movimentos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  data date not null default (now() at time zone 'Europe/Lisbon')::date,
  valor numeric(12,2) not null,    -- positivo guarda, negativo tira
  motivo text not null check (motivo in ('guardar','pagar_imposto','tirar','acerto')),
  entrada_id uuid references public.entradas(id) on delete set null,
  obrigacao_id uuid references public.obrigacoes(id) on delete set null,
  nota text,
  criado_em timestamptz not null default now()
);
create index if not exists cofre_por_pessoa on public.cofre_movimentos (user_id, data desc);

-- ------------------------------------------------------------ LEITURAS POR FOTO
create table if not exists public.leituras_ocr (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  origem text not null check (origem in ('foto','email','pdf')),
  tipo_esperado text check (tipo_esperado in ('fatura','combustivel','talao','extrato','outro')),
  ficheiro_url text,
  bruto jsonb,                     -- o que o modelo devolveu, tal e qual
  entidade_nome text,
  nif text,
  data_documento date,
  valor_total numeric(12,2),
  entidade_pagamento text,
  referencia_pagamento text,
  litros numeric(8,2),
  preco_litro numeric(8,3),
  confianca numeric(4,3),
  confirmado boolean not null default false,   -- a pessoa viu e disse que sim
  corrigido boolean not null default false,    -- a pessoa mudou algum campo
  criado_em timestamptz not null default now()
);
create index if not exists ocr_por_pessoa on public.leituras_ocr (user_id, criado_em desc);

alter table public.entradas add constraint entradas_leitura_fk
  foreign key (leitura_ocr_id) references public.leituras_ocr(id) on delete set null;
alter table public.saidas add constraint saidas_leitura_fk
  foreign key (leitura_ocr_id) references public.leituras_ocr(id) on delete set null;

-- ------------------------------------------------------------------- RLS
alter table public.entradas          enable row level security;
alter table public.saidas            enable row level security;
alter table public.saidas_pagamentos enable row level security;
alter table public.cofre_movimentos  enable row level security;
alter table public.leituras_ocr      enable row level security;

-- `to authenticated` desde o início: quem não tem sessão nunca avalia is_admin()
-- (a lição da migração 0011).
create policy entradas_minhas on public.entradas for all to authenticated
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());
create policy saidas_minhas on public.saidas for all to authenticated
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());
create policy pagamentos_meus on public.saidas_pagamentos for all to authenticated
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());
create policy cofre_meu on public.cofre_movimentos for all to authenticated
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());
create policy ocr_meu on public.leituras_ocr for all to authenticated
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());

-- carimbo de "atualizado em"
create trigger entradas_atualizado before update on public.entradas
  for each row execute function public.set_atualizado_em();
create trigger saidas_atualizado before update on public.saidas
  for each row execute function public.set_atualizado_em();
