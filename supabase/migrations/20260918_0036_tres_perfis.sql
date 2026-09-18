-- Em Dia — 0036: três perfis (independente, contrato, empresa) — B3, 2026-09-18
-- Regras novas com fonte oficial e data em cada linha (docs/REGRAS-PT-2026.md).

-- ---------------------------------------------------------------- perfil
alter table public.profiles
  add column if not exists tipo_trabalho text not null default 'independente'
    check (tipo_trabalho in ('independente','contrato','ambos','empresa')),
  add column if not exists salario_bruto_mensal numeric(10,2),
  add column if not exists data_nascimento date,
  add column if not exists empresa_tipo text check (empresa_tipo in ('eni','sociedade')),
  add column if not exists iva_periodicidade text check (iva_periodicidade in ('mensal','trimestral')),
  add column if not exists contabilista_email text,
  add column if not exists pasta_contabilista_ativa boolean not null default false;
comment on column public.profiles.tipo_trabalho is '«Trabalhas como?»: independente (recibos verdes) | contrato | ambos | empresa.';
comment on column public.profiles.pasta_contabilista_ativa is 'Todo o dia 1 a app junta o mês anterior (entrou, saiu, extrato, faturas) e envia ao contabilista.';

-- ---------------------------------------------------------------- regras (com fonte)
insert into public.regras_legais (chave, valor_num, valor_txt, valor_json, unidade, ano, descricao, fonte_url, confianca, verificado_em) values
  ('smn', 920, null, null, 'eur', 2026,
   'Salário mínimo nacional 2026: 920 €.',
   'https://www.seg-social.pt/ptss/pssd/documento/cmc0debv9008agw2ys1kly9so', 'oficial', '2026-09-18'),
  ('ss_trabalhador_taxa', 11, null, null, 'pct', 2026,
   'Trabalhador por conta de outrem: 11 % do salário bruto para a Segurança Social (taxa global 34,75 %).',
   'https://www.seg-social.pt/ptss/pssd/documento/cmd3e0ssc0019hn2y4z341qa8', 'oficial', '2026-09-18'),
  ('ss_empregador_taxa', 23.75, null, null, 'pct', 2026,
   'Entidade empregadora: 23,75 % (SS «Taxas Contributivas»).',
   'https://www.seg-social.pt/ptss/pssd/documento/cmd3e0ssc0019hn2y4z341qa8', 'oficial', '2026-09-18'),
  ('ss_moe_taxa', 34.75, null, null, 'pct', 2026,
   'Membros dos órgãos estatutários com funções de gerência: 23,75 % + 11 % = 34,75 %.',
   'https://www.seg-social.pt/ptss/pssd/documento/cmd3e0ssc0019hn2y4z341qa8', 'oficial', '2026-09-18'),
  ('irs_deducao_especifica_ias', 8.54, null, null, 'multiplo_ias', 2026,
   'Categoria A: dedução específica de 8,54 × IAS (ou as contribuições obrigatórias, se maiores). CIRS art. 25.º, redação da Lei 45-A/2024.',
   'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs25.aspx', 'oficial', '2026-09-18'),
  ('subsidio_natal_ate', null, '12-15', null, 'data', 2026,
   'Subsídio de Natal: um mês de retribuição, pago até 15 de dezembro (Código do Trabalho, art. 263.º).',
   'https://diariodarepublica.pt/dr/legislacao-consolidada/lei/2009-34546475-56397971', 'oficial', '2026-09-18'),
  ('ferias_dias_uteis', 22, null, null, 'dias_uteis', 2026,
   'Férias: mínimo de 22 dias úteis por ano (CT art. 238.º); subsídio de férias pago antes das férias (CT art. 264.º).',
   'https://diariodarepublica.pt/dr/legislacao-consolidada/lei/2009-34546475', 'oficial', '2026-09-18'),
  ('horas_extra_pct', null, null,
   '{"ate_100h": {"primeira": 25, "seguintes": 37.5, "descanso_ou_feriado": 50}, "mais_100h": {"primeira": 50, "seguintes": 75, "descanso_ou_feriado": 100}}'::jsonb,
   'tabela', 2026,
   'Trabalho suplementar (CT art. 268.º, Lei 13/2023): até 100 h/ano +25 % (1.ª hora) e +37,5 %; descanso/feriado +50 %; acima de 100 h/ano +50 %/+75 %/+100 %. Retribuição horária = (salário × 12) ÷ (52 × horas semanais), CT art. 271.º.',
   'https://diariodarepublica.pt/dr/legislacao-consolidada/lei/2009-34546475-211441912', 'oficial', '2026-09-18'),
  ('irs_jovem', null, null,
   '{"idade_max": 35, "anos": 10, "limite_ias": 55, "pct_por_ano": [100, 75, 75, 75, 50, 50, 50, 25, 25, 25]}'::jsonb,
   'tabela', 2026,
   'IRS Jovem (CIRS art. 12.º-B, Lei 45-A/2024): até 35 anos, não dependente, 10 primeiros anos de rendimentos; isenção de 100 % (1.º ano), 75 % (2.º–4.º), 50 % (5.º–7.º), 25 % (8.º–10.º), limite 55 × IAS; opção na declaração.',
   'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs12b.aspx', 'oficial', '2026-09-18'),
  ('deducoes_irs', null, null,
   '{"saude": {"pct": 15, "max": 1000}, "educacao": {"pct": 30, "max": 800}, "rendas": {"pct": 15, "max": 800}, "iva_faturas": {"pct": 15, "max": 250}, "gerais_familiares": {"pct": 35, "max": 250}, "dependente": 600}'::jsonb,
   'tabela', 2026,
   'Deduções à coleta do IRS: saúde 15 % até 1.000 € (78.º-C); educação 30 % até 800 € (78.º-D); rendas 15 % até 800 € (78.º-E, Lei 36/2024); IVA de faturas 15 % até 250 € (78.º-F); gerais familiares 35 % até 250 € (78.º-B); 600 € por dependente (78.º-A).',
   'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs78c.aspx', 'oficial', '2026-09-18'),
  ('desemprego', null, null,
   '{"prazo_garantia_dias": 360, "janela_meses": 24, "pedir_ate_dias": 90, "pct_rr": 65, "min_eur": 617.70, "max_eur": 1342.83}'::jsonb,
   'tabela', 2026,
   'Subsídio de desemprego (Guia Prático do ISS, 2026): 360 dias de registo de salários nos 24 meses anteriores; pedir até 90 dias seguidos; 65 % da remuneração de referência; mínimo 617,70 € (1,15 × IAS) quando os salários eram ≥ SMN; máximo 1.342,83 € (2,5 × IAS).',
   'https://www.seg-social.pt/ptss/pssd/documento/cmc0debv9008agw2ys1kly9so', 'oficial', '2026-09-18'),
  ('dmr_dia', 10, null, null, 'dia_do_mes', 2026,
   'Declaração Mensal de Remunerações até ao dia 10 do mês seguinte (agenda fiscal AT 2026; passa ao dia útil seguinte).',
   'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Decl_2026.aspx', 'oficial', '2026-09-18'),
  ('saft_dia', 5, null, null, 'dia_do_mes', 2026,
   'Comunicação dos elementos das faturas (SAF-T) até ao dia 5 do mês seguinte (agenda fiscal AT 2026).',
   'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Decl_2026.aspx', 'oficial', '2026-09-18'),
  ('iva_mensal_declaracao_dia', 20, null, null, 'dia_do_mes', 2026,
   'IVA regime mensal: declaração periódica até ao dia 20 do 2.º mês seguinte (CIVA art. 41.º n.º 1 a); agenda AT 2026: dia 20 de todos os meses).',
   'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Decl_2026.aspx', 'oficial', '2026-09-18'),
  ('irc_modelo22_data', null, '05-31', null, 'data', 2026,
   'IRC: Modelo 22 até 31 de maio (CIRC art. 120.º). Em 2026 a AT prorrogou para 30 de junho por despacho da SEAF — confirmar todos os anos na agenda.',
   'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Decl_2026.aspx', 'oficial', '2026-09-18'),
  ('ies_data', null, '07-15', null, 'data', 2026,
   'IES (Informação Empresarial Simplificada) até 15 de julho (agenda fiscal AT 2026).',
   'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Decl_2026.aspx', 'oficial', '2026-09-18'),
  ('irc_pagamentos_conta_datas', null, null, '["07-31", "09-30", "12-15"]'::jsonb, 'tabela', 2026,
   'Pagamentos por conta de IRC: 31 de julho, 30 de setembro e 15 de dezembro (quadro de pagamentos AT 2026).',
   'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Pag_2026.aspx', 'oficial', '2026-09-18')
on conflict (chave) do update set valor_num = excluded.valor_num, valor_txt = excluded.valor_txt, valor_json = excluded.valor_json,
  unidade = excluded.unidade, ano = excluded.ano, descricao = excluded.descricao, fonte_url = excluded.fonte_url,
  confianca = excluded.confianca, verificado_em = excluded.verificado_em;

-- Escalões de 2026 confirmados no CIRS art. 68.º (Lei 73-A/2025): limites 8.342 / 12.587 / 17.838 / 23.089 / 29.397 / 43.090 / 46.566 / 86.634.
-- Parcela a abater calculada: p(i) = p(i-1) + limite(i-1) × (taxa(i) − taxa(i-1)).
update public.irs_escaloes set ate = 12587, parcela_abater = 266.94, confianca = 'oficial' where ano = 2026 and ordem = 2;
update public.irs_escaloes set ate = 17838, parcela_abater = 959.23, confianca = 'oficial' where ano = 2026 and ordem = 3;
update public.irs_escaloes set ate = 23089, parcela_abater = 1476.53, confianca = 'oficial' where ano = 2026 and ordem = 4;
update public.irs_escaloes set ate = 29397, parcela_abater = 3092.76, confianca = 'oficial' where ano = 2026 and ordem = 5;
update public.irs_escaloes set ate = 43090, parcela_abater = 4209.85, confianca = 'oficial' where ano = 2026 and ordem = 6;
update public.irs_escaloes set ate = 46566, parcela_abater = 7743.23, confianca = 'oficial' where ano = 2026 and ordem = 7;
update public.irs_escaloes set ate = 86634, parcela_abater = 8441.72, confianca = 'oficial' where ano = 2026 and ordem = 8;
update public.irs_escaloes set parcela_abater = 11387.28, confianca = 'oficial' where ano = 2026 and ordem = 9;
update public.irs_escaloes set confianca = 'oficial' where ano = 2026 and ordem = 1;

-- ---------------------------------------------------------------- guias novos (contrato e empresa)
insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, fonte_url, categoria, ordem, publicado, verificado_em) values
  ('recibo-de-vencimento', 'O recibo de vencimento, linha a linha',
   'Bruto, Segurança Social, IRS retido, líquido: o que é cada número.',
   E'O recibo tem quatro números que interessam.\n\n1. **Bruto** — o que o patrão paga por ti antes dos descontos.\n2. **Segurança Social (11 %)** — a tua parte para a reforma, a baixa e o desemprego. O patrão põe mais 23,75 % que não vês no recibo.\n3. **IRS retido** — um adiantamento do imposto do ano. Não é o imposto final: em abril acerta-se (podes receber de volta ou pagar a diferença).\n4. **Líquido** — o que entra na conta.\n\nA app calcula o líquido e diz-te se o que estão a reter chega para o IRS do ano. Se tiveres 35 anos ou menos, vê o guia do IRS Jovem.',
   E'O recibo tem quatro números que interessam.\n\n1. **Bruto** — o que o patrão paga por você antes dos descontos.\n2. **Segurança Social (11 %)** — a sua parte para a aposentadoria, a baixa e o desemprego. O patrão põe mais 23,75 % que você não vê no recibo.\n3. **IRS retido** — um adiantamento do imposto do ano. Não é o imposto final: em abril acerta-se (você pode receber de volta ou pagar a diferença).\n4. **Líquido** — o que entra na conta.\n\nO app calcula o líquido e diz se o que estão retendo chega para o IRS do ano. Se você tem 35 anos ou menos, veja o guia do IRS Jovem.',
   'https://www.seg-social.pt/ptss/pssd/documento/cmd3e0ssc0019hn2y4z341qa8', 'contrato', 120, true, '2026-09-18'),
  ('subsidios-ferias-natal', 'Subsídio de férias e de Natal: quando caem',
   'Dois salários extra por ano — e as datas.',
   E'Quem tem contrato recebe **14 meses** por ano: 12 salários + subsídio de férias + subsídio de Natal.\n\n- **Subsídio de férias**: um mês de salário, pago **antes das férias** (salvo acordo escrito). Tens direito a **22 dias úteis** de férias por ano.\n- **Subsídio de Natal**: um mês de salário, pago **até 15 de dezembro**. No ano em que entras ou sais é proporcional aos meses trabalhados.\n\nSe não vierem, primeiro fala com a entidade patronal; se não resolver, a ACT (Autoridade para as Condições do Trabalho) trata destas queixas.',
   E'Quem tem contrato recebe **14 meses** por ano: 12 salários + subsídio de férias + subsídio de Natal.\n\n- **Subsídio de férias**: um mês de salário, pago **antes das férias** (salvo acordo escrito). Você tem direito a **22 dias úteis** de férias por ano.\n- **Subsídio de Natal**: um mês de salário, pago **até 15 de dezembro**. No ano em que você entra ou sai é proporcional aos meses trabalhados.\n\nSe não vierem, primeiro fale com o patrão; se não resolver, a ACT (Autoridade para as Condições do Trabalho) trata dessas queixas.',
   'https://diariodarepublica.pt/dr/legislacao-consolidada/lei/2009-34546475-56397971', 'contrato', 130, true, '2026-09-18'),
  ('horas-extra', 'Horas extra: quanto te devem',
   'A primeira hora vale mais 25 %, as seguintes mais 37,5 %; ao fim de semana mais 50 %.',
   E'A hora extra paga-se com acréscimo sobre a tua hora normal (salário × 12 ÷ 52 ÷ horas por semana).\n\n**Até 100 horas extra no ano:**\n- 1.ª hora do dia: **+25 %**\n- horas seguintes: **+37,5 %**\n- dia de descanso ou feriado: **+50 %**\n\n**Depois das 100 horas no ano:** +50 %, +75 % e +100 %.\n\nA app calcula o valor com o teu salário. Guarda as horas num caderno ou nas mensagens: se houver discussão, é a tua prova.',
   E'A hora extra é paga com acréscimo sobre a sua hora normal (salário × 12 ÷ 52 ÷ horas por semana).\n\n**Até 100 horas extras no ano:**\n- 1.ª hora do dia: **+25 %**\n- horas seguintes: **+37,5 %**\n- dia de descanso ou feriado: **+50 %**\n\n**Depois das 100 horas no ano:** +50 %, +75 % e +100 %.\n\nO app calcula o valor com o seu salário. Guarde as horas num caderno ou nas mensagens: se houver discussão, é a sua prova.',
   'https://diariodarepublica.pt/dr/legislacao-consolidada/lei/2009-34546475-211441912', 'contrato', 140, true, '2026-09-18'),
  ('fiquei-desempregado', 'Fiquei desempregado: o que fazer em 90 dias',
   'Inscrever-te no centro de emprego e pedir o subsídio a tempo.',
   E'Três coisas, por esta ordem:\n\n1. **Inscreve-te no centro de emprego (IEFP)** logo que possas — é obrigatório para receber.\n2. **Pede o subsídio de desemprego na Segurança Social Direta até 90 dias** depois de ficares sem trabalho. Depois disso perdes dias.\n3. Junta o **modelo RP5044** (a entidade patronal preenche) e o contrato.\n\n**Tens direito se** descontaste pelo menos **360 dias nos últimos 24 meses**. O valor é **65 % do teu salário médio**, entre 617,70 € e 1.342,83 € por mês (2026). Se trabalhaste menos tempo, pergunta pelo subsídio social de desemprego.\n\nA app faz a conta com o teu salário e diz-te a data limite para pedir.',
   E'Três coisas, nesta ordem:\n\n1. **Inscreva-se no centro de emprego (IEFP)** assim que puder — é obrigatório para receber.\n2. **Peça o subsídio de desemprego na Segurança Social Direta em até 90 dias** depois de ficar sem trabalho. Depois disso você perde dias.\n3. Junte o **modelo RP5044** (o patrão preenche) e o contrato.\n\n**Você tem direito se** descontou pelo menos **360 dias nos últimos 24 meses**. O valor é **65 % do seu salário médio**, entre 617,70 € e 1.342,83 € por mês (2026). Se trabalhou menos tempo, pergunte pelo subsídio social de desemprego.\n\nO app faz a conta com o seu salário e diz a data limite para pedir.',
   'https://www.seg-social.pt/ptss/pssd/documento/cmc0debv9008agw2ys1kly9so', 'contrato', 150, true, '2026-09-18'),
  ('irs-jovem', 'IRS Jovem: quem tem direito e quantos anos',
   'Até aos 35 anos, 10 anos de desconto no IRS — 100 % no primeiro.',
   E'Se tens **35 anos ou menos** e não és dependente dos teus pais no IRS, podes pagar menos IRS nos **10 primeiros anos** em que ganhas dinheiro (com contrato ou recibos verdes).\n\n- 1.º ano: **100 % isento**\n- 2.º ao 4.º ano: **75 %**\n- 5.º ao 7.º ano: **50 %**\n- 8.º ao 10.º ano: **25 %**\n\nCom um limite: só até 55 × IAS por ano (29.542,15 € em 2026).\n\n**Como se pede:** na declaração de IRS (abril a junho), marca a opção IRS Jovem no anexo A (contrato) ou B (recibos verdes). Se tens contrato, podes também pedir ao patrão para aplicar já na retenção mensal.',
   E'Se você tem **35 anos ou menos** e não é dependente dos seus pais no IRS, pode pagar menos IRS nos **10 primeiros anos** em que ganha dinheiro (com contrato ou recibos verdes).\n\n- 1.º ano: **100 % isento**\n- 2.º ao 4.º ano: **75 %**\n- 5.º ao 7.º ano: **50 %**\n- 8.º ao 10.º ano: **25 %**\n\nCom um limite: só até 55 × IAS por ano (29.542,15 € em 2026).\n\n**Como pedir:** na declaração de IRS (abril a junho), marque a opção IRS Jovem no anexo A (contrato) ou B (recibos verdes). Se você tem contrato, pode também pedir ao patrão para aplicar já na retenção mensal.',
   'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/questoes_frequentes/pages/faqs-00053.aspx', 'contrato', 160, true, '2026-09-18'),
  ('faturas-com-nif', 'Pede fatura com NIF: o que desconta no IRS',
   'Saúde, escola, casa, oficina, restaurantes — e o prazo de fevereiro.',
   E'Sempre que pagares, diz o teu NIF. Em abril, parte volta no IRS:\n\n- **Saúde**: 15 % do que gastaste, até 1.000 €\n- **Educação** (escola, livros, creche): 30 %, até 800 €\n- **Renda da casa**: 15 %, até 800 €\n- **Oficina, cabeleireiro, restaurantes, ginásio, veterinário**: 15 % do IVA, até 250 €\n- **Tudo o resto** (supermercado, roupa…): 35 %, até 250 €\n- Cada filho: 600 €\n\nEm fevereiro entra em faturas.portaldasfinancas.gov.pt e confirma as faturas que ficaram «pendentes» — até **25 de fevereiro**. A app avisa-te.',
   E'Sempre que pagar, diga o seu NIF. Em abril, parte volta no IRS:\n\n- **Saúde**: 15 % do que gastou, até 1.000 €\n- **Educação** (escola, livros, creche): 30 %, até 800 €\n- **Aluguel da casa**: 15 %, até 800 €\n- **Oficina, cabeleireiro, restaurantes, academia, veterinário**: 15 % do IVA, até 250 €\n- **Todo o resto** (supermercado, roupa…): 35 %, até 250 €\n- Cada filho: 600 €\n\nEm fevereiro entre em faturas.portaldasfinancas.gov.pt e confirme as faturas que ficaram «pendentes» — até **25 de fevereiro**. O app avisa você.',
   'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs78c.aspx', 'contrato', 170, true, '2026-09-18'),
  ('eni-ou-sociedade', 'ENI ou sociedade? Em duas frases',
   'A diferença que interessa: quem responde pelas dívidas e quem paga o imposto.',
   E'**ENI (empresário em nome individual)**: és tu, com o teu NIF. Pagas IRS sobre o lucro e respondes pelas dívidas com o que é teu. Simples de abrir e fechar.\n\n**Sociedade (Lda. ou unipessoal)**: é outra pessoa (a empresa, com o seu NIPC). Paga IRC sobre o lucro, tu recebes salário de gerente (com Segurança Social a 34,75 %) e as dívidas ficam na empresa. Precisa de contabilista certificado.\n\nA app **não substitui o contabilista**: mostra-te o calendário e junta-lhe os papéis todos os meses.',
   E'**ENI (empresário em nome individual)**: é você, com o seu NIF. Paga IRS sobre o lucro e responde pelas dívidas com o que é seu. Simples de abrir e fechar.\n\n**Sociedade (Lda. ou unipessoal)**: é outra pessoa (a empresa, com o seu NIPC). Paga IRC sobre o lucro, você recebe salário de gerente (com Segurança Social de 34,75 %) e as dívidas ficam na empresa. Precisa de contador certificado.\n\nO app **não substitui o contador**: mostra o calendário e junta os papéis todos os meses.',
   'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Decl_2026.aspx', 'empresa', 180, true, '2026-09-18'),
  ('calendario-da-empresa', 'O calendário da empresa (o que o contabilista entrega)',
   'IVA, DMR, SAF-T, Segurança Social, Modelo 22, IES — só as datas.',
   E'Todos os meses:\n- **dia 5** — comunicar as faturas (SAF-T)\n- **dia 10** — DMR (salários do mês anterior)\n- **dia 20** — IVA (declaração do 2.º mês anterior, se estás no regime mensal; no trimestral é fev/mai/set/nov)\n- **dia 25** — pagar o IVA e as contribuições da Segurança Social (entre 1 e 25)\n\nTodos os anos (sociedades):\n- **31 de maio** — Modelo 22 (IRC)\n- **15 de julho** — IES\n- **31 jul / 30 set / 15 dez** — pagamentos por conta de IRC\n\nQuando o dia cai a fim de semana ou feriado, passa para o dia útil seguinte. A app marca tudo isto na tua agenda.',
   E'Todos os meses:\n- **dia 5** — comunicar as faturas (SAF-T)\n- **dia 10** — DMR (salários do mês anterior)\n- **dia 20** — IVA (declaração do 2.º mês anterior, se você está no regime mensal; no trimestral é fev/mai/set/nov)\n- **dia 25** — pagar o IVA e as contribuições da Segurança Social (entre 1 e 25)\n\nTodos os anos (sociedades):\n- **31 de maio** — Modelo 22 (IRC)\n- **15 de julho** — IES\n- **31 jul / 30 set / 15 dez** — pagamentos por conta de IRC\n\nQuando o dia cai em fim de semana ou feriado, passa para o dia útil seguinte. O app marca tudo isso na sua agenda.',
   'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Decl_2026.aspx', 'empresa', 190, true, '2026-09-18')
on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt, corpo_br = excluded.corpo_br,
  fonte_url = excluded.fonte_url, categoria = excluded.categoria, ordem = excluded.ordem, publicado = excluded.publicado, verificado_em = excluded.verificado_em;

-- ---------------------------------------------------------------- pasta do contabilista
create table if not exists public.pastas_contabilista (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  mes date not null,                       -- primeiro dia do mês a que a pasta respeita
  para_email text not null,
  enviado_em timestamptz,
  itens jsonb,                             -- {"entradas": n, "saidas": n, "extrato": n, "faturas": n, "recibos": n}
  estado text not null default 'a_enviar' check (estado in ('a_enviar','enviada','erro')),
  erro text,
  criado_em timestamptz not null default now(),
  unique (user_id, mes)
);
comment on table public.pastas_contabilista is 'Pasta mensal enviada ao contabilista (B3): o que entrou, o que saiu, o extrato e as faturas do mês anterior, em CSV, por e-mail.';
alter table public.pastas_contabilista enable row level security;
drop policy if exists "pastas: dono le" on public.pastas_contabilista;
create policy "pastas: dono le" on public.pastas_contabilista for select to authenticated using (auth.uid() = user_id);
drop policy if exists "pastas: admin le" on public.pastas_contabilista;
create policy "pastas: admin le" on public.pastas_contabilista for select to authenticated using (public.is_admin());

-- Todo o dia 1 às 06:00 UTC (07:00 em Lisboa no verão, 06:00 no inverno).
select cron.unschedule(jobid) from cron.job where jobname = 'em-dia-pasta-contabilista-mes';
select cron.schedule(
  'em-dia-pasta-contabilista-mes',
  '0 6 1 * *',
  $$
  select net.http_post(
    url := 'https://tgdmgtmknbwhcqoxtjbs.supabase.co/functions/v1/pasta-contabilista',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRnZG1ndG1rbmJ3aGNxb3h0amJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MTkyOTIsImV4cCI6MjEwNDE5NTI5Mn0.XFzQgX1jj6sVhAQNDPLtwJze61WxnEWkN56hYwD5wCM',
      'x-cron-secret', coalesce((select decrypted_secret from vault.decrypted_secrets where name = 'cron_secret'), '')
    ),
    body := '{"origem":"pg_cron"}'::jsonb
  );
  $$
);
