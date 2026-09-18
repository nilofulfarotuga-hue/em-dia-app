-- Em Dia — 0032: o dinheiro entra sozinho (B2a) e as coisas que se repetem (B2c) — 2026-09-18
--
-- A pessoa importa o extrato do banco (CSV/Excel, exportado pelo próprio banco); a app lê-o no
-- aparelho (lib/regras/extrato_banco.dart) e guarda aqui cada movimento, sem repetir (chave por
-- dia + valor + descrição normalizada). Do que se repete (o mesmo nome, o mesmo valor, meses
-- diferentes) nasce a lista «pagas X por mês em coisas que se repetem», com «como cancelar».
-- Nada de ler SMS nem Gmail (D23). Nada disto mexe em dinheiro.

-- ---------------------------------------------------------------- MOVIMENTOS DO BANCO
create table if not exists public.movimentos_banco (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  data date not null,
  descricao text not null,
  valor numeric(12,2) not null,                    -- positivo entrou, negativo saiu
  saldo numeric(12,2),
  banco text,                                       -- cgd | santander | millennium | … | null
  categoria text not null default 'outro',          -- as de `saidas` + 'entrada' + 'rendimento'
  fornecedor text,
  recorrente boolean not null default false,        -- marcado pela app ao importar
  entrada_id uuid references public.entradas(id) on delete set null,   -- «isto é rendimento meu»
  saida_id uuid references public.saidas(id) on delete set null,       -- «isto é a minha conta X»
  importacao_id uuid,
  chave text not null,                              -- dia|valor|descrição normalizada
  criado_em timestamptz not null default now(),
  unique (user_id, chave)
);
create index if not exists movimentos_banco_por_pessoa on public.movimentos_banco (user_id, data desc);
create index if not exists movimentos_banco_recorrentes on public.movimentos_banco (user_id, recorrente) where recorrente;

-- ---------------------------------------------------------------- IMPORTAÇÕES (para o admin ver os erros)
create table if not exists public.importacoes_extrato (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  ficheiro text,
  formato text check (formato in ('csv','xlsx','pdf')),
  banco text,
  linhas_lidas integer not null default 0,
  linhas_novas integer not null default 0,
  linhas_repetidas integer not null default 0,
  linhas_ignoradas integer not null default 0,
  erro text,                                        -- sem_cabecalho | ficheiro_vazio | … | null
  criado_em timestamptz not null default now()
);
create index if not exists importacoes_por_pessoa on public.importacoes_extrato (user_id, criado_em desc);
alter table public.movimentos_banco add constraint movimentos_importacao_fk
  foreign key (importacao_id) references public.importacoes_extrato(id) on delete set null;

-- ---------------------------------------------------------------- REGRAS DE CATEGORIA (públicas, admin edita)
create table if not exists public.categorias_regras (
  padrao text primary key,                          -- já normalizado (minúsculas, sem acentos)
  categoria text not null,
  fornecedor text,
  ativa boolean not null default true,
  atualizado_em timestamptz not null default now()
);

-- ---------------------------------------------------------------- COMO CANCELAR (públicas, admin edita)
create table if not exists public.operadores_cancelar (
  chave text primary key,                           -- meo | nos | vodafone | edp | …
  nome text not null,
  categoria text not null,
  como_cancelar text not null,                      -- PT-PT, linguagem simples
  url text,                                         -- a página certa do operador
  telefone text,
  fonte_url text,
  verificado_em date,
  atualizado_em timestamptz not null default now()
);

-- ---------------------------------------------------------------- RLS
alter table public.movimentos_banco enable row level security;
alter table public.importacoes_extrato enable row level security;
alter table public.categorias_regras enable row level security;
alter table public.operadores_cancelar enable row level security;

drop policy if exists movimentos_banco_dono on public.movimentos_banco;
create policy movimentos_banco_dono on public.movimentos_banco
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists importacoes_dono on public.importacoes_extrato;
create policy importacoes_dono on public.importacoes_extrato
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists categorias_regras_read on public.categorias_regras;
create policy categorias_regras_read on public.categorias_regras for select to authenticated using (true);
drop policy if exists categorias_regras_admin on public.categorias_regras;
create policy categorias_regras_admin on public.categorias_regras for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists operadores_cancelar_read on public.operadores_cancelar;
create policy operadores_cancelar_read on public.operadores_cancelar for select to authenticated using (true);
drop policy if exists operadores_cancelar_admin on public.operadores_cancelar;
create policy operadores_cancelar_admin on public.operadores_cancelar for all using (public.is_admin()) with check (public.is_admin());

-- Admin lê tudo (o painel tem autoridade total)
drop policy if exists movimentos_banco_admin on public.movimentos_banco;
create policy movimentos_banco_admin on public.movimentos_banco for select using (public.is_admin());
drop policy if exists importacoes_admin on public.importacoes_extrato;
create policy importacoes_admin on public.importacoes_extrato for select using (public.is_admin());

-- ---------------------------------------------------------------- SEED: regras de categoria (espelho de regrasCategoriaPadrao)
insert into public.categorias_regras (padrao, categoria, fornecedor) values
  ('meo','telemovel','MEO'),('altice','telemovel','MEO'),('nos comunicacoes','telemovel','NOS'),('vodafone','telemovel','Vodafone'),
  ('nowo','internet','NOWO'),('digi','telemovel','DIGI'),
  ('edp','luz','EDP'),('endesa','luz','Endesa'),('iberdrola','luz','Iberdrola'),('goldenergy','luz','Goldenergy'),
  ('galp','combustivel','Galp'),('repsol','combustivel','Repsol'),('cepsa','combustivel','Cepsa'),('prio','combustivel','Prio'),
  ('epal','agua','EPAL'),('aguas','agua',null),
  ('netflix','assinatura','Netflix'),('spotify','assinatura','Spotify'),('disney','assinatura','Disney+'),('hbo','assinatura','HBO Max'),
  ('amazon prime','assinatura','Amazon Prime'),('prime video','assinatura','Amazon Prime'),('youtube','assinatura','YouTube'),
  ('apple com','assinatura','Apple'),('microsoft','assinatura','Microsoft'),
  ('fitness hut','ginasio','Fitness Hut'),('solinca','ginasio','Solinca'),('holmes place','ginasio','Holmes Place'),('ginasio','ginasio',null),
  ('continente','compras','Continente'),('pingo doce','compras','Pingo Doce'),('lidl','compras','Lidl'),('auchan','compras','Auchan'),
  ('mercadona','compras','Mercadona'),('intermarche','compras','Intermarché'),('minipreco','compras','Minipreço'),('aldi','compras','Aldi'),
  ('farmacia','saude',null),
  ('seguranca social','imposto','Segurança Social'),('seg social','imposto','Segurança Social'),('autoridade tributaria','imposto','AT'),('iuc','imposto','AT'),
  ('fidelidade','seguro','Fidelidade'),('tranquilidade','seguro','Tranquilidade'),('allianz','seguro','Allianz'),('ageas','seguro','Ageas'),('seguro','seguro',null),
  ('renda','renda',null),('prestacao','credito',null),('cofidis','credito','Cofidis'),('cetelem','credito','Cetelem'),
  ('via verde','carro','Via Verde'),('brisa','carro','Brisa'),
  ('uber','rendimento','Uber'),('bolt','rendimento','Bolt'),('glovo','rendimento','Glovo'),('uber eats','rendimento','Uber Eats')
on conflict (padrao) do nothing;

-- ---------------------------------------------------------------- SEED: como cancelar (páginas oficiais, verificadas a 2026-09-18 — ver B2c)
insert into public.operadores_cancelar (chave, nome, categoria, como_cancelar, url, telefone, fonte_url, verificado_em) values
  ('meo','MEO','telemovel','Na área de cliente MEO (my.meo.pt → Mensagens → Abrir pedido) pedes o cancelamento por escrito; também podes ligar 16200. Se ainda estás em fidelização, pergunta primeiro quanto custa sair — a app diz-te o dia em que acaba.','https://my.meo.pt/perfil/mensagens/abrir-pedido','16200','https://www.meo.pt/ajuda-e-suporte','2026-09-18'),
  ('nos','NOS','telemovel','Na app NOS ou em nos.pt (área de cliente) ou pela linha 16990. Pede por escrito e guarda o número do pedido. Confirma primeiro se a fidelização já acabou.','https://www.nos.pt/ajuda','16990','https://www.nos.pt/ajuda','2026-09-18'),
  ('vodafone','Vodafone','telemovel','Na app My Vodafone ou em ajuda.vodafone.pt (área de cliente), ou pela linha 16912. Guarda o comprovativo do pedido. Confirma o fim da fidelização.','https://ajuda.vodafone.pt/','16912','https://ajuda.vodafone.pt/','2026-09-18'),
  ('edp','EDP','luz','Mudar de fornecedor de luz não se cancela: pedes ao novo fornecedor e ele trata da troca (não há multa se não tiveres fidelização). Para cancelar de vez (casa vazia), pedes na app EDP Zero ou na área de cliente.','https://www.edp.pt/particulares/apoio-cliente/','808 53 53 53','https://www.edp.pt/particulares/apoio-cliente/','2026-09-18'),
  ('galp','Galp','luz','Para a luz e o gás da Galp: mudar de fornecedor faz-se pelo novo fornecedor; cancelar de vez pede-se na área de cliente ou pela linha de apoio.','https://galp.com/pt/pt/particulares/apoio-cliente','808 507 500','https://galp.com/pt/pt/particulares/apoio-cliente','2026-09-18'),
  ('netflix','Netflix','assinatura','Entra em netflix.com → Conta → Cancelar subscrição. Fica ativa até ao fim do mês já pago.','https://www.netflix.com/cancelplan',null,'https://help.netflix.com/pt/node/407','2026-09-18'),
  ('spotify','Spotify','assinatura','Entra em spotify.com/account → Plano → Cancelar Premium (pelo site, não pela app do telemóvel).','https://www.spotify.com/account/subscription/',null,'https://support.spotify.com/pt-pt/article/cancel-premium/','2026-09-18'),
  ('disney','Disney+','assinatura','Entra em disneyplus.com → Conta → Assinatura → Cancelar. Se pagas pela loja do telemóvel (Google/Apple), cancela lá.','https://www.disneyplus.com/account',null,'https://help.disneyplus.com/','2026-09-18'),
  ('hbo','HBO Max','assinatura','Entra em hbomax.com → Perfil → Subscrição → Cancelar. Se pagas pela loja do telemóvel, cancela lá.','https://www.hbomax.com/',null,'https://help.hbomax.com/','2026-09-18'),
  ('amazon_prime','Amazon Prime','assinatura','Entra em amazon.es → A minha conta → Prime → Terminar a subscrição.','https://www.amazon.es/gp/primecentral',null,'https://www.amazon.es/gp/help/customer/display.html','2026-09-18'),
  ('youtube','YouTube Premium','assinatura','Entra em youtube.com/paid_memberships → Gerir subscrição → Cancelar. Se pagas pela loja do telemóvel, cancela lá.','https://www.youtube.com/paid_memberships',null,'https://support.google.com/youtube/answer/6308278','2026-09-18'),
  ('google','Google (Play/One)','assinatura','No telemóvel: Google Play → perfil → Pagamentos e subscrições → Subscrições → escolhe e cancela.','https://play.google.com/store/account/subscriptions',null,'https://support.google.com/googleplay/answer/7018481','2026-09-18'),
  ('apple','Apple (App Store/iCloud)','assinatura','No iPhone: Definições → o teu nome → Subscrições → escolhe e cancela.','https://support.apple.com/pt-pt/118428',null,'https://support.apple.com/pt-pt/118428','2026-09-18'),
  ('fitness_hut','Fitness Hut','ginasio','Pede o cancelamento por escrito no ginásio ou na área de cliente; costuma haver 30 dias de aviso. Confirma o fim da fidelização antes. (O site fitnesshut.pt não respondeu a 18/09/2026; fica sem ligação até se confirmar.)',null,null,null,null),
  ('solinca','Solinca','ginasio','Pede o cancelamento por escrito no clube ou pela área de cliente; confirma o pré-aviso e o fim da fidelização.','https://www.solinca.pt/',null,'https://www.solinca.pt/','2026-09-18'),
  ('holmes_place','Holmes Place','ginasio','Pede o cancelamento por escrito no clube; confirma o pré-aviso e o fim da fidelização.','https://www.holmesplace.com/pt/',null,'https://www.holmesplace.com/pt/','2026-09-18'),
  ('generico','Outro serviço','outro','Procura na fatura ou no site do serviço a área de cliente e pede o cancelamento por escrito (e-mail ou formulário); guarda a resposta. Se houver fidelização, confirma primeiro o dia em que acaba.',null,null,null,'2026-09-18')
on conflict (chave) do nothing;
