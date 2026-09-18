-- Em Dia — 0030: prazo efetivo (dia útil seguinte) + regras verificadas na fonte (2026-09-18)
--
-- Defeito 3 da missão em-dia-tudo-2026-09-17: a 17/09 o painel dizia «Segurança Social até
-- domingo, dia 20». Em Portugal, um prazo do Estado que cai a sábado, domingo ou feriado
-- passa para o dia útil seguinte:
--   · AT, «Resumo anual — Obrigações de pagamento em 2026», nota a): «Nos meses que terminam
--     em fim de semana ou feriado, a obrigação pode ser cumprida até ao dia útil seguinte.»
--     https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Pag_2026.aspx
--   · Segurança Social, Guia Prático «Pagamento de Contribuições à Segurança Social»: «Se o
--     último dia de pagamento coincidir com um sábado, domingo ou feriado, o pagamento poderá
--     ser efetuado no dia útil seguinte.»
--
-- A coluna `data_limite` continua a ser o dia LEGAL («até dia 20»); `prazo_efetivo` é até
-- quando se pode mesmo cumprir. O aviso (`aviso_em`) fica na véspera útil do dia legal.

alter table public.obrigacoes add column if not exists prazo_efetivo date;
update public.obrigacoes set prazo_efetivo = data_limite where prazo_efetivo is null;
alter table public.obrigacoes alter column prazo_efetivo set default null;
comment on column public.obrigacoes.data_limite is 'O dia legal (o que a lei ou o Estado escrevem).';
comment on column public.obrigacoes.prazo_efetivo is 'Até quando se pode mesmo cumprir: dia útil seguinte quando o dia legal cai a fim-de-semana/feriado e o prazo é do Estado (AT/SS). Nulo = igual a data_limite.';
create index if not exists obrigacoes_user_prazo_efetivo on public.obrigacoes (user_id, prazo_efetivo);

-- O «passou» conta pelo prazo efetivo, não pelo dia legal.
create or replace function public.marcar_obrigacoes_passadas() returns integer
language plpgsql security definer set search_path = public as $$
declare n integer;
begin
  update public.obrigacoes set estado = 'passado'
  where estado = 'pendente'
    and coalesce(prazo_efetivo, data_limite) < (now() at time zone 'Europe/Lisbon')::date;
  get diagnostics n = row_count;
  return n;
end $$;
revoke all on function public.marcar_obrigacoes_passadas() from public, anon, authenticated;
grant execute on function public.marcar_obrigacoes_passadas() to service_role;

-- Dia útil seguinte (o espelho SQL de prazoEfetivo, para quem consultar a tabela à mão).
create or replace function public.dia_util_seguinte_ou_igual(d date) returns date
language plpgsql stable as $$
declare x date := d;
begin
  while not public.eh_dia_util(x) loop x := x + 1; end loop;
  return x;
end $$;

-- ---------- regras verificadas na fonte a 2026-09-18 ----------
-- Novas
insert into public.regras_legais (chave, valor_txt, ano, descricao, fonte_url, confianca, verificado_em) values
  ('prazo_dia_nao_util', 'dia_util_seguinte', 2026,
   'Prazo do Estado (AT/SS) que cai a sábado, domingo ou feriado cumpre-se no dia útil seguinte.',
   'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Pag_2026.aspx',
   'oficial', '2026-09-18')
on conflict (chave) do update set valor_txt = excluded.valor_txt, descricao = excluded.descricao,
  fonte_url = excluded.fonte_url, confianca = excluded.confianca, verificado_em = excluded.verificado_em;

insert into public.regras_legais (chave, valor_num, unidade, ano, descricao, fonte_url, confianca, verificado_em) values
  ('iva_trimestre2_mes', 9, 'mes', 2026,
   'A declaração de IVA do 2.º trimestre (e do mês de junho) entrega-se até 20 de setembro, não em agosto (CIVA art. 41.º n.º 10, redação do DL 49/2025); o pagamento é a 25 de setembro (quadro AT 2026).',
   'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva41.aspx',
   'oficial', '2026-09-18'),
  ('tvde_idade_max_anos', 7, 'anos', 2026,
   'Os veículos TVDE devem ter idade inferior a sete anos a contar da primeira matrícula (Lei 45/2018, art. 12.º n.º 4).',
   'https://diariodarepublica.pt/dr/detalhe/lei/45-2018-115991688', 'oficial', '2026-09-18'),
  ('ss_empregador_pagamento_dia_fim', 25, 'dia', 2026,
   'Entidades empregadoras (empresas com trabalhadores/gerentes): contribuições pagas entre o dia 1 e o dia 25 do mês seguinte (CRC art. 43.º, redação do DL 127/2025, em vigor desde 1/1/2026).',
   'https://diariodarepublica.pt/dr/detalhe/decreto-lei/127-2025-967317021', 'oficial', '2026-09-18')
on conflict (chave) do update set valor_num = excluded.valor_num, unidade = excluded.unidade, descricao = excluded.descricao,
  fonte_url = excluded.fonte_url, confianca = excluded.confianca, verificado_em = excluded.verificado_em;

-- Existentes: fonte confirmada hoje (o número não mudou)
update public.regras_legais set fonte_url = 'https://diariodarepublica.pt/dr/legislacao-consolidada/lei/2009-34514575', confianca = 'oficial', verificado_em = '2026-09-18',
  descricao = 'Trabalhadores independentes: pagamento mensal entre o dia 10 e o dia 20 do mês seguinte (CRC, Lei 110/2009, art. 155.º n.º 2). Não mudou com o DL 127/2025 (esse mexeu só no art. 43.º, das entidades empregadoras).'
  where chave in ('ss_pagamento_dia_inicio', 'ss_pagamento_dia_fim');
update public.regras_legais set fonte_url = 'https://diariodarepublica.pt/dr/legislacao-consolidada/lei/2009-34514575', confianca = 'oficial', verificado_em = '2026-09-18',
  descricao = 'Declaração trimestral até ao último dia de abril, julho, outubro e janeiro (CRC art. 151.º-A n.º 3).'
  where chave = 'ss_declaracao_meses';
update public.regras_legais set fonte_url = 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/artigo-53-o-do-civa.aspx', confianca = 'oficial', verificado_em = '2026-09-18',
  descricao = 'Isenção do art. 53.º do CIVA: volume de negócios do ano anterior não superior a 15 000 € (redação do DL 35/2025).'
  where chave = 'iva_isencao_limite';
update public.regras_legais set fonte_url = 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva41.aspx', confianca = 'oficial', verificado_em = '2026-09-18',
  descricao = 'Declaração periódica trimestral até ao dia 20 do 2.º mês seguinte ao trimestre (CIVA art. 41.º n.º 1 b)); 2.º trimestre até 20 de setembro (n.º 10).'
  where chave = 'iva_declaracao_trimestral_dia';
update public.regras_legais set fonte_url = 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva27.aspx', confianca = 'oficial', verificado_em = '2026-09-18',
  descricao = 'Pagamento do IVA até ao dia 25 do 2.º mês seguinte ao trimestre (CIVA art. 27.º n.º 1 b)).'
  where chave = 'iva_pagamento_dia';
update public.regras_legais set fonte_url = 'https://www.imt-ip.pt/veiculos/inspecao-de-veiculos/tipos-de-inspecoes/', confianca = 'oficial', verificado_em = '2026-09-18',
  descricao = 'Ligeiros de passageiros (M1): «Quatro anos após a data da primeira matrícula e, em seguida, de dois em dois anos, até perfazerem oito anos, e, depois, anualmente.» (IMT)'
  where chave in ('ipo_ligeiros_anos', 'ipo_apos_8_anos');
update public.regras_legais set valor_txt = 'anual', fonte_url = 'https://diariodarepublica.pt/dr/detalhe/lei/45-2018-115991688', confianca = 'oficial', verificado_em = '2026-09-18',
  descricao = 'TVDE: «Os veículos devem ser apresentados à inspeção técnica periódica um ano após a data da primeira matrícula e, em seguida, anualmente.» (Lei 45/2018, art. 12.º n.º 5)'
  where chave = 'ipo_tvde';
update public.regras_legais set fonte_url = 'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Pag_2026.aspx', confianca = 'oficial', verificado_em = '2026-09-18',
  descricao = 'Pagamentos por conta de IRS: até 20 de julho, 20 de setembro e 20 de dezembro (em 2026 a AT mostra 20/07, 21/09 e 21/12 por caírem a domingo).'
  where chave = 'irs_pagamentos_conta_datas';

-- Feriados: a fonte é a lei (Código do Trabalho, art. 234.º), guardada como regra para a app citar.
insert into public.regras_legais (chave, valor_txt, ano, descricao, fonte_url, confianca, verificado_em) values
  ('feriados_fonte', 'Código do Trabalho, art. 234.º', 2026,
   'Feriados obrigatórios: 1 de janeiro, Sexta-Feira Santa, Domingo de Páscoa, 25 de abril, 1 de maio, Corpo de Deus, 10 de junho, 15 de agosto, 5 de outubro, 1 de novembro, 1, 8 e 25 de dezembro. A tabela `feriados` tem 2026 e 2027 (Páscoa 5/4/2026 e 28/3/2027).',
   'https://diariodarepublica.pt/dr/legislacao-consolidada/lei/2009-34546475', 'oficial', '2026-09-18')
on conflict (chave) do update set valor_txt = excluded.valor_txt, descricao = excluded.descricao,
  fonte_url = excluded.fonte_url, confianca = excluded.confianca, verificado_em = excluded.verificado_em;
