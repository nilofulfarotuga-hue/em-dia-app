-- 0024 — os centros de inspeção do IMT (2026-09-06).
--
-- A app diz "a tua inspeção é até 12/10". A pergunta a seguir é sempre "onde?".
-- Sem isto, a pessoa sai da app para procurar no Google, e a app deixou de
-- servir para nada nesse momento.
--
-- A fonte é um PDF do IMT (não há API, não há CSV, não há nada no dados.gov.pt).
-- Quem o lê é `tool/dados/centros_inspecao.py`, com travão de queda: se o PDF
-- mudar de formato e der menos de 180 centros, recusa-se a escrever.
--
-- Leitura ABERTA a toda a gente, incluindo quem não tem sessão: é informação
-- pública do Estado e o site também a mostra. Escrita só pelo service_role.
create table if not exists public.centros_inspecao (
  codigo_citv text primary key,
  nome text not null,
  morada text,
  codigo_postal text,
  localidade text,
  distrito text not null,
  -- O IMT não publica a categoria (A/B) nem o telefone por centro. Ficam a
  -- nulo em vez de inventados; se um dia houver fonte, entram aqui.
  categoria text check (categoria is null or categoria in ('A', 'B')),
  telefone text,
  lat double precision,
  lng double precision,
  coord_origem text not null default 'imt_pdf'
    check (coord_origem in ('imt_pdf', 'nominatim', 'manual')),
  fonte_url text,
  fonte_data date,
  ativo boolean not null default true,
  atualizado_em timestamptz not null default now()
);

create index if not exists centros_inspecao_por_distrito
  on public.centros_inspecao (distrito, nome);

comment on table public.centros_inspecao is
  'Centros de inspeção técnica de veículos (CITV), lidos do PDF oficial do IMT por tool/dados/centros_inspecao.py. Leitura pública.';
comment on column public.centros_inspecao.lat is
  'Nulo quando o PDF do IMT traz uma coordenada impossível (há centros com latitude 27 e 29 graus, que é mar alto). Não se adivinha: mandar a pessoa a um sítio errado é pior do que não dizer nada.';

alter table public.centros_inspecao enable row level security;

drop policy if exists centros_leitura_publica on public.centros_inspecao;
create policy centros_leitura_publica on public.centros_inspecao
  for select to anon, authenticated using (ativo);
-- Sem política de escrita: só o service_role (o script) mete dados aqui.

-- Registo de cada carregamento, para se saber quando foi e o que mudou.
create table if not exists public.centros_inspecao_sync (
  id uuid primary key default gen_random_uuid(),
  corrido_em timestamptz not null default now(),
  fonte_url text,
  fonte_sha256 text,
  fonte_last_modified text,
  total integer not null,
  com_coordenadas integer not null,
  nota text
);
alter table public.centros_inspecao_sync enable row level security;
-- Ninguém lê isto pela app; é para o admin e para o service_role.
drop policy if exists centros_sync_admin on public.centros_inspecao_sync;
create policy centros_sync_admin on public.centros_inspecao_sync
  for select to authenticated using (public.is_admin());

-- Os dados em si estão em `docs/dados/centros_inspecao.sql`, gerado pelo
-- script. Não se metem aqui: 223 linhas numa migração tornam-na ilegível, e o
-- ficheiro gerado volta a nascer sempre que o IMT publicar um PDF novo.
