-- 0026 — os preços de combustível da DGEG (2026-09-06). FICA DESLIGADO.
--
-- O portal oficial (precoscombustiveis.dgeg.gov.pt) tem uma API JSON pública,
-- sem chave e sem login, que devolve todos os postos do continente numa só
-- chamada: 14.178 linhas de preço, 3.131 postos, 5,3 MB, HTTP 200.
--
-- O TRAVÃO NÃO É TÉCNICO, É LEGAL. O portal diz, com todas as letras, que "é
-- proibida a sua utilização para fins comerciais", e há um processo formal
-- ("Partilha de Informação") com uma minuta que tem de ser assinada e enviada
-- por e-mail à DGEG. O Em Dia cobra 3,49 €/mês — é uma app comercial. Sem essa
-- assinatura, isto NÃO pode ir para a app.
--
-- Por isso: as tabelas ficam feitas, o robô fica escrito e provado, e o
-- interruptor `feature_flags.precos_combustivel` fica a FALSO. Com o
-- interruptor desligado o robô corre em seco: vai buscar, conta, escreve
-- quantos viu no registo — e **não guarda um único preço**. Assim prova-se que
-- funciona sem usar comercialmente o que não é nosso.
--
-- Enquanto isto estiver desligado, o "vale a pena esta corrida" usa o preço do
-- último abastecimento da própria pessoa, ou um que ela escreva (decisão já
-- tomada em docs/DECISOES.md).

create table if not exists public.postos_combustivel (
  id integer primary key,                 -- o Id da DGEG, que é estável
  nome text not null,
  marca text,
  tipo_posto text,
  distrito text,
  municipio text,
  localidade text,
  morada text,
  cod_postal text,
  lat double precision,
  lng double precision,
  atualizado_em timestamptz not null default now()
);
create index if not exists postos_por_distrito on public.postos_combustivel (distrito, municipio);

create table if not exists public.precos_combustivel (
  posto_id integer not null references public.postos_combustivel(id) on delete cascade,
  combustivel text not null,
  preco numeric(6,3) not null,
  visto_em timestamptz,                   -- a "DataAtualizacao" que a DGEG dá
  atualizado_em timestamptz not null default now(),
  primary key (posto_id, combustivel)
);

comment on table public.precos_combustivel is
  'Preços por posto e combustível, da DGEG. VAZIA de propósito até haver autorização escrita da DGEG (uso comercial proibido sem ela).';

alter table public.postos_combustivel enable row level security;
alter table public.precos_combustivel enable row level security;

-- Leitura só para quem tem sessão, e só quando a funcionalidade estiver ligada.
-- A trava está na política, não na app: uma trava só na app contorna-se com a
-- chave anon (lição do D29).
drop policy if exists postos_leitura on public.postos_combustivel;
create policy postos_leitura on public.postos_combustivel
  for select to authenticated
  using ((select ff.free or ff.pro or ff.familia from public.feature_flags ff
           where ff.chave = 'precos_combustivel'));

drop policy if exists precos_leitura on public.precos_combustivel;
create policy precos_leitura on public.precos_combustivel
  for select to authenticated
  using ((select ff.free or ff.pro or ff.familia from public.feature_flags ff
           where ff.chave = 'precos_combustivel'));

create table if not exists public.precos_combustivel_sync (
  id uuid primary key default gen_random_uuid(),
  corrido_em timestamptz not null default now(),
  linhas integer not null default 0,
  postos integer not null default 0,
  gravou boolean not null default false,
  ms integer,
  nota text
);
alter table public.precos_combustivel_sync enable row level security;
drop policy if exists precos_sync_admin on public.precos_combustivel_sync;
create policy precos_sync_admin on public.precos_combustivel_sync
  for select to authenticated using (public.is_admin());

comment on table public.precos_combustivel_sync is
  'Corridas do robô dos preços. gravou = false significa corrida em seco: foi buscar e contou, mas não guardou nada (é o estado normal enquanto não houver autorização da DGEG).';
