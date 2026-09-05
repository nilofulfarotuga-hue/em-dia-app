-- Em Dia — 0003 seed: regras legais 2026, escalões IRS, feriados, cadeados (2026-09-05)
-- confianca: oficial = valor da ordem do Danilo / fonte oficial lida · aproximado = tabela simplificada
-- (a app mostra "valor aproximado") · por_confirmar = a IA responde "não tenho essa regra confirmada".
-- Atualizar todo o janeiro (o admin edita sem código).

insert into public.regras_legais (chave, valor_num, valor_txt, valor_json, unidade, ano, descricao, fonte_url, confianca, verificado_em) values
-- IAS
('ias', 537.13, null, null, 'eur', 2026, 'IAS 2026 (Indexante dos Apoios Sociais) — a base de muitos limites', 'https://www.seg-social.pt/indexante-dos-apoios-sociais-ias', 'oficial', '2026-09-05'),
-- IVA
('iva_taxa_normal', 23, null, null, 'pct', 2026, 'Taxa normal de IVA no continente', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva18.aspx', 'oficial', '2026-09-05'),
('iva_isencao_limite', 15000, null, null, 'eur', 2026, 'Isenção do art. 53.º do CIVA: até 15.000 € de faturação por ano não se cobra IVA', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva53.aspx', 'oficial', '2026-09-05'),
('iva_isencao_aviso', 12000, null, null, 'eur', 2026, 'Aviso amarelo da vigia do IVA (80% do limite)', null, 'oficial', '2026-09-05'),
('iva_isencao_perda_imediata', 18750, null, null, 'eur', 2026, 'Acima de 18.750 € (limite + 25%) perde a isenção de imediato: a fatura seguinte já leva IVA', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva53.aspx', 'oficial', '2026-09-05'),
('iva_isencao_comunicacao_dias_uteis', 15, null, null, 'dias_uteis', 2026, 'Prazo para comunicar às Finanças a perda da isenção (declaração de alterações)', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva58.aspx', 'oficial', '2026-09-05'),
('iva_mencao_isencao', null, 'IVA - regime de isenção [artigo 53.º do CIVA] (M10)', null, 'texto', 2026, 'Frase obrigatória no recibo verde de quem está isento (código M10)', null, 'oficial', '2026-09-05'),
('iva_declaracao_trimestral_dia', 20, null, null, 'dia_do_mes', 2026, 'Regime normal trimestral: declaração periódica até ao dia 20 do 2.º mês após o trimestre', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva41.aspx', 'oficial', '2026-09-05'),
('iva_pagamento_dia', 25, null, null, 'dia_do_mes', 2026, 'Regime normal trimestral: pagamento do IVA até ao dia 25 do 2.º mês após o trimestre', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva27.aspx', 'oficial', '2026-09-05'),
-- Retenção na fonte (categoria B)
('retencao_padrao', 23, null, null, 'pct', 2026, 'Retenção na fonte padrão dos recibos verdes (desde 2025)', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs101.aspx', 'oficial', '2026-09-05'),
('retencao_opcao', 25, null, null, 'pct', 2026, 'Retenção por opção do prestador (25%)', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs101.aspx', 'oficial', '2026-09-05'),
('retencao_dispensa_limite', 15000, null, null, 'eur', 2026, 'Dispensa de retenção se no ano anterior faturou menos de 15.000 € (art. 101.º-B CIRS) e o cliente tem contabilidade organizada', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs101-b.aspx', 'oficial', '2026-09-05'),
-- Segurança Social (trabalhadores independentes)
('ss_taxa', 21.4, null, null, 'pct', 2026, 'Taxa contributiva dos independentes', 'https://www.seg-social.pt/trabalhadores-independentes', 'oficial', '2026-09-05'),
('ss_base_servicos', 70, null, null, 'pct', 2026, 'Base de incidência: 70% do rendimento de prestação de serviços', 'https://www.seg-social.pt/trabalhadores-independentes', 'oficial', '2026-09-05'),
('ss_base_vendas', 20, null, null, 'pct', 2026, 'Base de incidência: 20% do rendimento de produção/venda de bens', 'https://www.seg-social.pt/trabalhadores-independentes', 'oficial', '2026-09-05'),
('ss_ajuste_max', 25, null, null, 'pct', 2026, 'Pode pedir para pagar até 25% a menos ou a mais (ajuste na declaração trimestral)', 'https://www.seg-social.pt/trabalhadores-independentes', 'oficial', '2026-09-05'),
('ss_minimo_mensal', 20, null, null, 'eur', 2026, 'Contribuição mínima mensal de 20 €', 'https://www.seg-social.pt/trabalhadores-independentes', 'oficial', '2026-09-05'),
('ss_base_maxima_ias', 12, null, null, 'multiplo_ias', 2026, 'Base máxima mensal = 12 × IAS', 'https://www.seg-social.pt/trabalhadores-independentes', 'oficial', '2026-09-05'),
('ss_isencao_meses', 12, null, null, 'meses', 2026, 'Isenção de contribuições nos 12 primeiros meses de atividade', 'https://www.seg-social.pt/trabalhadores-independentes', 'oficial', '2026-09-05'),
('ss_declaracao_meses', null, null, '[1,4,7,10]', 'meses_do_ano', 2026, 'Declaração trimestral de rendimentos até ao último dia de janeiro, abril, julho e outubro', 'https://www.seg-social.pt/trabalhadores-independentes', 'oficial', '2026-09-05'),
('ss_pagamento_dia_inicio', 10, null, null, 'dia_do_mes', 2026, 'Pagamento da contribuição entre o dia 10 e o dia 20 de cada mês', 'https://www.seg-social.pt/trabalhadores-independentes', 'oficial', '2026-09-05'),
('ss_pagamento_dia_fim', 20, null, null, 'dia_do_mes', 2026, 'Último dia para pagar a contribuição do mês (dia 20)', 'https://www.seg-social.pt/trabalhadores-independentes', 'oficial', '2026-09-05'),
('ss_aviso_fim_isencao_dias', 30, null, null, 'dias', 2026, 'Aviso 30 dias antes de acabar a isenção do 1.º ano', null, 'oficial', '2026-09-05'),
-- IRS
('irs_coef_servicos', 0.75, null, null, 'coeficiente', 2026, 'Regime simplificado: 75% dos serviços contam como rendimento', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs31.aspx', 'oficial', '2026-09-05'),
('irs_coef_vendas', 0.15, null, null, 'coeficiente', 2026, 'Regime simplificado: 15% das vendas de bens contam como rendimento', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs31.aspx', 'oficial', '2026-09-05'),
('irs_minimo_existencia', 12880, null, null, 'eur', 2026, 'Mínimo de existência 2026: até este rendimento líquido não se paga IRS', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs70.aspx', 'oficial', '2026-09-05'),
('irs_pagamentos_conta_pct', 65, null, null, 'pct', 2026, 'Pagamentos por conta: 65% do IRS calculado do ano anterior, em 3 prestações', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs102.aspx', 'oficial', '2026-09-05'),
('irs_pagamentos_conta_datas', null, null, '["07-20","09-20","12-20"]', 'datas', 2026, 'Pagamentos por conta: 20 de julho, 20 de setembro e 20 de dezembro', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs102.aspx', 'oficial', '2026-09-05'),
('irs_entrega_inicio', null, '04-01', null, 'data', 2026, 'Entrega da declaração de IRS: a partir de 1 de abril', 'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/default.aspx', 'oficial', '2026-09-05'),
('irs_entrega_fim', null, '06-30', null, 'data', 2026, 'Entrega da declaração de IRS: até 30 de junho', 'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/default.aspx', 'oficial', '2026-09-05'),
('efatura_validar_ate', null, '02-25', null, 'data', 2026, 'Validar as faturas no e-fatura até 25 de fevereiro', 'https://faturas.portaldasfinancas.gov.pt/', 'oficial', '2026-09-05'),
('irs_despesas_justificar_limite', 27360, null, null, 'eur', 2026, 'Acima deste rendimento bruto anual (simplificado) tem de justificar 15% com despesas com NIF — verificar com contabilista', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs31.aspx', 'aproximado', '2026-09-05'),
('irs_despesas_justificar_pct', 15, null, null, 'pct', 2026, 'Percentagem de despesas a justificar acima do limite', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs31.aspx', 'oficial', '2026-09-05'),
('recibos_comunicar_dia', 5, null, null, 'dia_do_mes', 2026, 'Quem usa software de faturação comunica as faturas até ao dia 5 do mês seguinte (SAF-T)', 'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/Faturacao/Pages/default.aspx', 'oficial', '2026-09-05'),
-- Reforma e direitos
('reforma_idade', 66.75, '66 anos e 9 meses', null, 'anos', 2026, 'Idade normal de reforma em 2026', 'https://www.seg-social.pt/pensao-de-velhice', 'oficial', '2026-09-05'),
('reforma_carreira_minima_anos', 15, null, null, 'anos', 2026, 'Carreira contributiva mínima para ter pensão de velhice', 'https://www.seg-social.pt/pensao-de-velhice', 'oficial', '2026-09-05'),
('baixa_doenca_dia_inicio', 11, null, null, 'dia', 2026, 'Independentes: subsídio de doença a partir do 11.º dia de baixa', 'https://www.seg-social.pt/subsidio-de-doenca', 'oficial', '2026-09-05'),
('baixa_doenca_prazo_garantia_meses', 6, null, null, 'meses', 2026, 'Subsídio de doença: precisa de 6 meses de descontos', 'https://www.seg-social.pt/subsidio-de-doenca', 'oficial', '2026-09-05'),
('cessacao_atividade_prazo_garantia_dias', 360, null, null, 'dias', 2026, 'Subsídio por cessação de atividade (o "desemprego" dos independentes): 360 dias de descontos nos 24 meses anteriores', 'https://www.seg-social.pt/subsidio-por-cessacao-de-atividade', 'oficial', '2026-09-05'),
('acordo_pt_br_url', null, 'https://www.seg-social.pt/acordos-internacionais', null, 'url', 2026, 'Acordo de Segurança Social Portugal–Brasil: o tempo de descontos nos dois países soma-se para a reforma', 'https://www.seg-social.pt/acordos-internacionais', 'oficial', '2026-09-05'),
-- Carro
('iuc_regra', null, 'mes_da_matricula', null, 'texto', 2026, 'O IUC paga-se todos os anos até ao fim do mês da matrícula do carro', 'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/Folhetos_informativos/Documents/IUC.pdf', 'oficial', '2026-09-05'),
('iuc_tabela', null, null, '{"nota":"Tabela simplificada da categoria B (matriculados desde julho de 2007): soma da parcela da cilindrada com a parcela do CO2, vezes o coeficiente do ano. Categoria A (antes de julho de 2007): só cilindrada e combustível. Valores aproximados: confirma no Portal das Finanças.","cat_b_cilindrada":[{"ate":1250,"valor":32.36},{"ate":1750,"valor":64.92},{"ate":2500,"valor":129.77},{"ate":99999,"valor":444.51}],"cat_b_co2_nedc":[{"ate":120,"valor":64.58},{"ate":180,"valor":96.77},{"ate":250,"valor":210.17},{"ate":9999,"valor":360.09}],"cat_b_co2_wltp":[{"ate":140,"valor":64.58},{"ate":205,"valor":96.77},{"ate":260,"valor":210.17},{"ate":9999,"valor":360.09}],"cat_b_coef_ano":[{"ano":2007,"coef":1.0},{"ano":2008,"coef":1.05},{"ano":2009,"coef":1.1},{"ano":2010,"coef":1.15}],"cat_a_gasolina":[{"ate":1000,"valor":19.20},{"ate":1300,"valor":30.60},{"ate":1750,"valor":47.20},{"ate":2600,"valor":118.90},{"ate":3500,"valor":193.20},{"ate":99999,"valor":344.10}],"cat_a_gasoleo":[{"ate":1500,"valor":30.60},{"ate":2000,"valor":47.20},{"ate":3000,"valor":118.90},{"ate":99999,"valor":193.20}],"eletrico":0}', 'tabela', 2026, 'Tabela aproximada do IUC 2026 (para estimar o valor no calendário)', 'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/ciuc/Pages/ciuc-artigo-9.aspx', 'aproximado', '2026-09-05'),
('ipo_ligeiros_anos', null, null, '[4,6,8]', 'anos', 2026, 'Inspeção periódica de ligeiros: aos 4, 6 e 8 anos da matrícula; depois todos os anos', 'https://www.imt-ip.pt/sites/IMTT/Portugues/Veiculos/InspecoesTecnicas/Paginas/InspecoesTecnicas.aspx', 'oficial', '2026-09-05'),
('ipo_apos_8_anos', null, 'anual', null, 'texto', 2026, 'Depois dos 8 anos a inspeção é anual', 'https://www.imt-ip.pt/sites/IMTT/Portugues/Veiculos/InspecoesTecnicas/Paginas/InspecoesTecnicas.aspx', 'oficial', '2026-09-05'),
('ipo_tvde', null, 'anual', null, 'texto', 2026, 'Carros em TVDE/táxi: inspeção anual (confirmar no IMT)', 'https://www.imt-ip.pt/', 'por_confirmar', null),
('ipo_avisos_dias', null, null, '[30,7]', 'dias', 2026, 'Avisos da inspeção: 30 dias e 7 dias antes', null, 'oficial', '2026-09-05'),
('seguro_aviso_dias', 45, null, null, 'dias', 2026, 'Aviso 45 dias antes de o seguro renovar: é agora que comparas', null, 'oficial', '2026-09-05'),
('carta_validade', null, null, '{"ate_60":15,"60_a_70":5,"mais_70":2}', 'anos', 2026, 'Carta de condução: 15 anos até aos 60; depois 5; depois dos 70, 2', 'https://www.imt-ip.pt/sites/IMTT/Portugues/Condutores/CartaConducao/Paginas/CartadeConducao.aspx', 'oficial', '2026-09-05'),
('multa_pagamento_voluntario_dias_uteis', 15, null, null, 'dias_uteis', 2026, 'Multas de estacionamento/trânsito e portagens: pagamento voluntário em 15 dias úteis', 'https://www.ansr.pt/', 'oficial', '2026-09-05'),
('troca_carta_estrangeira_prazo_anos', 2, null, null, 'anos', 2026, 'Carta estrangeira: trocar até 2 anos depois de fixar residência (confirmar no IMT)', 'https://www.imt-ip.pt/', 'por_confirmar', null),
('tvde_certificado_validade_anos', 5, null, null, 'anos', 2026, 'Certificado de motorista TVDE: válido 5 anos', 'https://www.imt-ip.pt/sites/IMTT/Portugues/TVDE/Paginas/default.aspx', 'oficial', '2026-09-05'),
('tvde_licenca_veiculo', null, 'dístico anual do veículo TVDE (confirmar)', null, 'texto', 2026, 'Licença/dístico do carro TVDE', 'https://www.imt-ip.pt/sites/IMTT/Portugues/TVDE/Paginas/default.aspx', 'por_confirmar', null),
-- Plano e IA
('trial_dias', 30, null, null, 'dias', 2026, 'Mês grátis com tudo aberto, sem cartão', null, 'oficial', '2026-09-05'),
('trial_aviso_dia', 25, null, null, 'dia', 2026, 'Aviso no dia 25 do trial', null, 'oficial', '2026-09-05'),
('preco_pro_mensal', 3.49, null, null, 'eur', 2026, 'Pro mensal', null, 'oficial', '2026-09-05'),
('preco_pro_anual', 29.90, null, null, 'eur', 2026, 'Pro anual', null, 'oficial', '2026-09-05'),
('preco_familia_mensal', 5.99, null, null, 'eur', 2026, 'Família/Frota mensal (até 5 pessoas/carros)', null, 'oficial', '2026-09-05'),
('preco_familia_anual', 49.90, null, null, 'eur', 2026, 'Família/Frota anual', null, 'oficial', '2026-09-05'),
('ia_custo_alarme_dia_eur', 0.50, null, null, 'eur', 2026, 'Alarme no admin se o custo da IA passar este valor por dia', null, 'oficial', '2026-09-05'),
('push_hora_lisboa', 9, null, null, 'hora', 2026, 'Os avisos saem às 09:00 de Lisboa, no máximo 1 por obrigação por dia', null, 'oficial', '2026-09-05')
on conflict (chave) do update set valor_num = excluded.valor_num, valor_txt = excluded.valor_txt, valor_json = excluded.valor_json,
  unidade = excluded.unidade, ano = excluded.ano, descricao = excluded.descricao, fonte_url = excluded.fonte_url,
  confianca = excluded.confianca, verificado_em = excluded.verificado_em;

-- Escalões de IRS (rendimento coletável anual, continente). 2025 = tabela em vigor; 2026 = OE 2026, POR CONFIRMAR.
alter table public.irs_escaloes add column if not exists confianca text not null default 'oficial';
delete from public.irs_escaloes where ano in (2025, 2026);
insert into public.irs_escaloes (ano, ordem, ate, taxa, parcela_abater, confianca) values
(2025, 1, 8059.00, 0.1250, 0.00, 'oficial'),
(2025, 2, 12160.00, 0.1600, 282.07, 'oficial'),
(2025, 3, 17233.00, 0.2150, 950.87, 'oficial'),
(2025, 4, 22306.00, 0.2440, 1450.63, 'oficial'),
(2025, 5, 28400.00, 0.3140, 3012.05, 'oficial'),
(2025, 6, 41629.00, 0.3490, 4006.05, 'oficial'),
(2025, 7, 44987.00, 0.4310, 7419.63, 'oficial'),
(2025, 8, 83696.00, 0.4460, 8094.44, 'oficial'),
(2025, 9, null, 0.4800, 10940.10, 'oficial'),
(2026, 1, 8342.00, 0.1250, 0.00, 'por_confirmar'),
(2026, 2, 12588.00, 0.1570, 266.94, 'por_confirmar'),
(2026, 3, 17838.00, 0.2120, 959.28, 'por_confirmar'),
(2026, 4, 23088.00, 0.2410, 1476.58, 'por_confirmar'),
(2026, 5, 29397.00, 0.3110, 3092.74, 'por_confirmar'),
(2026, 6, 43090.00, 0.3490, 4209.83, 'por_confirmar'),
(2026, 7, 46567.00, 0.4310, 7743.21, 'por_confirmar'),
(2026, 8, 86634.00, 0.4460, 8441.72, 'por_confirmar'),
(2026, 9, null, 0.4800, 11387.28, 'por_confirmar');

-- Feriados nacionais (para a véspera útil)
insert into public.feriados (data, nome) values
('2026-01-01','Ano Novo'),('2026-04-03','Sexta-feira Santa'),('2026-04-05','Páscoa'),('2026-04-25','Dia da Liberdade'),
('2026-05-01','Dia do Trabalhador'),('2026-06-04','Corpo de Deus'),('2026-06-10','Dia de Portugal'),('2026-08-15','Assunção'),
('2026-10-05','Implantação da República'),('2026-11-01','Todos os Santos'),('2026-12-01','Restauração da Independência'),
('2026-12-08','Imaculada Conceição'),('2026-12-25','Natal'),
('2027-01-01','Ano Novo'),('2027-03-26','Sexta-feira Santa'),('2027-03-28','Páscoa'),('2027-04-25','Dia da Liberdade'),
('2027-05-01','Dia do Trabalhador'),('2027-05-27','Corpo de Deus'),('2027-06-10','Dia de Portugal'),('2027-08-15','Assunção'),
('2027-10-05','Implantação da República'),('2027-11-01','Todos os Santos'),('2027-12-01','Restauração da Independência'),
('2027-12-08','Imaculada Conceição'),('2027-12-25','Natal')
on conflict (data) do nothing;

-- Cadeados por plano (lidos do servidor: mudar limites sem publicar versão nova)
insert into public.feature_flags (chave, descricao, free, pro, familia, limite_free, limite_pro, limite_familia) values
('painel', 'Painel "Estás em dia?"', true, true, true, null, null, null),
('calculadora', 'Calculadora de recibo verde', true, true, true, null, null, null),
('calendario', 'Calendário de obrigações', true, true, true, null, null, null),
('avisos_push', 'Avisos por notificação (por mês)', true, true, true, 3, null, null),
('ia_perguntas', 'Perguntas ao assistente (por mês)', true, true, true, 5, null, null),
('ler_extrato_foto', 'Ler extrato Uber/Bolt/Glovo por foto', false, true, true, null, null, null),
('comprovativos_guardar', 'Guardar fotos dos comprovativos', false, true, true, null, null, null),
('carros', 'Carros registados', true, true, true, 1, null, 5),
('exportar_contabilista', 'Exportar PDF/CSV para o contabilista', false, true, true, null, null, null),
('reforma_completa', 'Reforma e direitos (completo)', false, true, true, null, null, null),
('membros', 'Pessoas na conta (Família/Frota)', false, false, true, null, null, 5)
on conflict (chave) do update set descricao = excluded.descricao, free = excluded.free, pro = excluded.pro, familia = excluded.familia,
  limite_free = excluded.limite_free, limite_pro = excluded.limite_pro, limite_familia = excluded.limite_familia;
