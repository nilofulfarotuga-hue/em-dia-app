-- 0025 — as ligações diretas para as páginas do Estado (2026-09-06).
--
-- A app diz "tens de entregar a declaração trimestral". A pergunta a seguir é
-- "onde?". Estes são os endereços, para a app pôr um botão em cada obrigação.
--
-- Vivem na base e não no código Dart de propósito: quando o Estado mudar um
-- endereço (e muda), corrige-se aqui e a app do telemóvel de toda a gente fica
-- certa no mesmo minuto, sem publicar versão nova na loja.
--
-- DOIS LADOS DO ESTADO, E NÃO SÃO IGUAIS:
--
-- **Finanças (AT)** — cada serviço tem endereço próprio e funciona. Quem não
-- tem sessão é reencaminhado para `acesso.gov.pt` com o caminho guardado no
-- parâmetro `path=`, por isso depois de entrar cai na página certa.
--
-- **Segurança Social** — NÃO há endereço estável para dentro. Em 2026 o
-- `app.seg-social.pt` reencaminha para `www.seg-social.pt/ptss/`, a área com
-- sessão vive em `/ptss/pssd/home?dswid=<número gerado por sessão>` e o login
-- tem reCAPTCHA. Por isso só há UM endereço, o da porta, e a app tem de
-- mostrar o caminho em passos antes de o abrir. **Nunca prometer que o botão
-- abre o formulário — não abre, e uma promessa dessas quebrada custa mais do
-- que o botão vale.**
--
-- AVISO QUE VALE OURO, e está provado: os dois portais respondem "tudo bem" a
-- caminhos inventados. A AT devolve 302 para o login mesmo para
-- `/recibos/portal/xxxx-nao-existe-zzz`, e a Segurança Social devolve 200 para
-- `/ptss/pssd/menu/xpto-nao-existe-zzz999`. Um vigia por código HTTP fica
-- verde para sempre num link morto. É por isso que a coluna `part_id` existe e
-- que o vigia compara com o mapa do site, não com o código de resposta.

create table if not exists public.ligacoes_estado (
  chave text primary key,
  -- 'financas' | 'seguranca_social' — a app trata-os de maneira diferente
  entidade text not null check (entidade in ('financas', 'seguranca_social')),
  url text not null,
  -- A aplicação por trás, no acesso.gov.pt (SIRE, EFPF, M3SV, DAPF, PCAH,
  -- DFCP, LIUC). Se mudar, a aplicação foi substituída — é o segundo sinal do
  -- vigia, além do mapa do site.
  part_id text,
  titulo text not null,
  -- O que a pessoa vai lá fazer, em palavras dela. É isto que aparece no botão.
  ajuda text not null,
  responsivo boolean not null default true,
  -- Quando é falso, a app avisa antes de abrir: "esta página é do portal
  -- antigo e vê-se mal no telemóvel".
  ordem smallint not null default 100,
  ativa boolean not null default true,
  verificado_em date,
  atualizado_em timestamptz not null default now()
);

comment on table public.ligacoes_estado is
  'Endereços das páginas do Estado (AT e Segurança Social) para os botões da app. Na base e não no código: o Estado muda endereços e a app tem de acertar sem publicar versão.';

alter table public.ligacoes_estado enable row level security;

drop policy if exists ligacoes_leitura_publica on public.ligacoes_estado;
create policy ligacoes_leitura_publica on public.ligacoes_estado
  for select to anon, authenticated using (ativa);
-- Escrita: só service_role e o painel do admin (que usa service_role).

insert into public.ligacoes_estado (chave, entidade, url, part_id, titulo, ajuda, responsivo, ordem, verificado_em) values
('recibo_emitir', 'financas',
 'https://irs.portaldasfinancas.gov.pt/recibos/portal/emitir', 'SIRE',
 'Fazer um recibo verde',
 'Aqui fazes o teu recibo. Escreves o número de contribuinte de quem te paga e quanto é. O papel fica logo feito.',
 true, 10, current_date),
('recibo_consultar', 'financas',
 'https://irs.portaldasfinancas.gov.pt/recibos/portal/consultar', 'SIRE',
 'Ver os recibos que já fiz',
 'Aqui vês todos os recibos que já fizeste. Escolhes o ano e carregas em Pesquisar. Podes voltar a descarregar qualquer um.',
 true, 20, current_date),
('financas_a_pagar', 'financas',
 'https://sitfiscal.portaldasfinancas.gov.pt/inffin/pagamentosEmFalta.html', 'DFCP',
 'Ver o que devo às Finanças',
 'Aqui está a lista do que ainda deves. Carregas em cima de cada linha e sai uma referência de Multibanco para pagares.',
 true, 30, current_date),
('irs_entregar', 'financas',
 'https://irs.portaldasfinancas.gov.pt/escolherModoEntregaIRS.action', 'M3SV',
 'Entregar o IRS',
 'Aqui entregas o IRS, uma vez por ano. Escolhes o ano, confirmas se os teus dados estão certos, e vês se tens a receber ou a pagar.',
 true, 40, current_date),
('irs_despesas', 'financas',
 'https://irs.portaldasfinancas.gov.pt/app/dashboard-regime-simplificado', 'M3SV',
 'As despesas do meu trabalho',
 'Aqui vês as despesas do teu trabalho: combustível, o carro, o telemóvel. Dizes quanto de cada uma é para o trabalho e quanto é para ti.',
 true, 50, current_date),
('pagamento_por_conta', 'financas',
 'https://irs.portaldasfinancas.gov.pt/pagantah/listaPedidos/entrar', 'PCAH',
 'Pagar por conta',
 'Aqui pedes o papel para pagar o adiantamento do imposto. Escolhes o ano e o valor, e sai uma referência de Multibanco.',
 true, 60, current_date),
('efatura_ver', 'financas',
 'https://faturas.portaldasfinancas.gov.pt/consultarDocumentosAdquirente.action', 'EFPF',
 'Ver as minhas faturas (e-fatura)',
 'Aqui aparecem as compras que fizeste com o teu número de contribuinte. Se alguma estiver por classificar, dizes o que é.',
 true, 70, current_date),
('efatura_registar', 'financas',
 'https://faturas.portaldasfinancas.gov.pt/registarDocumentoAdquirenteForm.action', 'EFPF',
 'Meter uma fatura à mão',
 'Se compraste uma coisa e a fatura não apareceu sozinha, metes aqui os dados do papel que tens na mão.',
 true, 80, current_date),
('atividade', 'financas',
 'https://sitfiscal.portaldasfinancas.gov.pt/atividade/atividade/entregar', 'DAPF',
 'Abrir, mudar ou fechar atividade',
 'Aqui dizes às Finanças que vais começar a trabalhar por conta própria, que mudaste de trabalho, ou que vais parar.',
 true, 90, current_date),
('iuc_consultar', 'financas',
 'https://sitfiscal.portaldasfinancas.gov.pt/iuc/consultarIUC/consultarIUC', 'LIUC',
 'Ver o imposto do carro',
 'Escreves a matrícula e ele mostra-te se já pagaste o imposto do carro este ano, e quanto foi.',
 true, 100, current_date),
('iuc_pagar', 'financas',
 'https://sitfiscal.portaldasfinancas.gov.pt/iuc/entregarIUC/entregarIUC', 'LIUC',
 'Pagar o imposto do carro',
 'Escreves a matrícula, confirmas os dados do carro e sai um papel com a referência de Multibanco.',
 true, 110, current_date),
('seguranca_social', 'seguranca_social',
 'https://www.seg-social.pt/ptss/', null,
 'Abrir a Segurança Social Direta',
 'Este botão abre a porta, não o formulário. Lá dentro: entra com o teu número, carrega em Trabalhador Independente no menu da esquerda, e depois em Declaração Trimestral de Rendimentos.',
 true, 200, current_date),
('ss_independentes', 'seguranca_social',
 'https://www.seg-social.pt/ptss/pssd/menu/trabalho/remuneracoes-contribuicoes/trabalhadores-independentes', null,
 'Saber mais sobre trabalhadores independentes',
 'Página da Segurança Social a explicar as regras de quem trabalha por conta própria. É para ler, não é para preencher.',
 true, 210, current_date),
('ss_carreira', 'seguranca_social',
 'https://www.seg-social.pt/ptss/pssd/menu/trabalho/remuneracoes-contribuicoes/carreira-contributiva', null,
 'Saber mais sobre a carreira contributiva',
 'Explica como contam os anos de descontos para a reforma. O teu extrato só se vê dentro da Segurança Social Direta, com sessão iniciada.',
 true, 220, current_date)
on conflict (chave) do update set
  url = excluded.url, part_id = excluded.part_id, titulo = excluded.titulo,
  ajuda = excluded.ajuda, responsivo = excluded.responsivo, ordem = excluded.ordem,
  verificado_em = excluded.verificado_em, atualizado_em = now();

-- Registo do vigia semanal. Uma linha por corrida, com o que ele viu.
create table if not exists public.ligacoes_estado_vigia (
  id uuid primary key default gen_random_uuid(),
  corrido_em timestamptz not null default now(),
  mapa_bytes integer,
  mapa_ligacoes integer,
  verificadas integer not null default 0,
  em_falta text[] not null default '{}',
  saltado boolean not null default false,
  nota text
);
alter table public.ligacoes_estado_vigia enable row level security;
drop policy if exists vigia_ligacoes_admin on public.ligacoes_estado_vigia;
create policy vigia_ligacoes_admin on public.ligacoes_estado_vigia
  for select to authenticated using (public.is_admin());

comment on table public.ligacoes_estado_vigia is
  'Corridas do vigia dos endereços do Estado. `saltado` = o mapa do site veio pequeno demais e não se acreditou nele (ver a Edge Function vigia-ligacoes).';