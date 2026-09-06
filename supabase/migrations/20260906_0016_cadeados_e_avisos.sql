-- 0016 — os cadeados das funções novas e os prazos de aviso (2026-09-06).
-- Aplicada em produção: versão 20260906142512.
--
-- A regra do Danilo: 30 dias com tudo aberto, sem cartão; a partir do dia 31
-- fica o básico — painel, calendário com 3 avisos por mês, calculadora,
-- 1 carro, 5 perguntas ao assistente — e o resto com cadeado.
--
-- Onde me afastei da letra, e porquê (escrito em docs/DECISOES.md, D25):
--   · ESCREVER O QUE ENTRA fica aberto e sem limite. É o que faz as contas do
--     IRS e da Segurança Social ficarem certas; fechá-lo tornava os números do
--     plano grátis errados, e um número errado é pior do que nenhum.
--   · CONTAS A PAGAR ficam abertas até 3. Chega para a renda, a luz e o
--     telemóvel — que é onde a pessoa percebe que a app serve. A quarta pede Pro.
--   · VALE A PENA ESTA CORRIDA fica aberto: é a porta de entrada que traz gente
--     da Google, e está aberto no site também.
--   · LER POR FOTO: 5 por mês no grátis, sem limite no Pro, tal como pedido.

insert into public.feature_flags (chave, descricao, free, pro, familia, limite_free, limite_pro, limite_familia)
values
  ('entradas',            'Escrever o que entra (recibos, plataformas, salário…)', true,  true, true, null, null, null),
  ('saidas',              'Contas a pagar guardadas',                              true,  true, true, 3,    null, null),
  ('ler_foto',            'Ler fatura ou talão por foto (por mês)',                true,  true, true, 5,    null, null),
  ('caixa_correio',       'Caixa de correio das faturas (endereço próprio)',       false, true, true, null, null, null),
  ('cofre_imposto',       'Cofre do imposto (quanto pôr de lado)',                 true,  true, true, null, null, null),
  ('vale_a_pena',         'Vale a pena esta corrida?',                             true,  true, true, null, null, null),
  ('prova_rendimento',    'Prova de rendimento em PDF',                            false, true, true, null, null, null),
  ('radar_fidelizacao',   'Radar da fidelização dos contratos',                    false, true, true, null, null, null),
  ('fala_comigo',         'Falar com a app e ouvir a resposta',                    false, true, true, null, null, null),
  ('resumo_mes',          'Resumo do mês e do ano',                                true,  true, true, null, null, null),
  ('precos_combustivel',  'Preços de combustível da DGEG (por autorizar)',         false, false, false, null, null, null),
  ('faturacao_certificada','Emitir fatura-recibo por software certificado',        false, false, false, null, null, null),
  ('banco_movimentos',    'Ler movimentos do banco (open banking)',                false, false, false, null, null, null)
on conflict (chave) do update set
  descricao = excluded.descricao,
  free = excluded.free, pro = excluded.pro, familia = excluded.familia,
  limite_free = excluded.limite_free, limite_pro = excluded.limite_pro, limite_familia = excluded.limite_familia;

-- Quantos dias antes se avisa, por meio de pagamento. Não são leis — são
-- escolhas do Em Dia — por isso vão marcadas como `aproximado` e sem fonte
-- oficial. Ficam na tabela na mesma, porque a regra da casa é que nenhum
-- número destes vive como constante no código.
insert into public.regras_legais (chave, valor_num, unidade, descricao, fonte_url, confianca, verificado_em)
values
  ('aviso_debito_direto_dias', 1, 'dias',
   'Escolha do Em Dia, não é lei: débito direto avisa 1 dia antes, para dar tempo de pôr dinheiro na conta.',
   null, 'aproximado', current_date),
  ('aviso_referencia_dias', 3, 'dias',
   'Escolha do Em Dia, não é lei: pagamento por referência avisa 3 dias antes e outra vez no próprio dia.',
   null, 'aproximado', current_date),
  ('aviso_obrigacao_estado_dias', 5, 'dias',
   'Escolha do Em Dia, não é lei: obrigações do Estado avisam 5 dias antes e outra vez no próprio dia.',
   null, 'aproximado', current_date),
  ('aviso_fidelizacao_dias', 30, 'dias',
   'Escolha do Em Dia, não é lei: fim de fidelização avisa 30 dias antes, que é quando ainda dá para mudar sem multa.',
   null, 'aproximado', current_date)
on conflict (chave) do update set
  valor_num = excluded.valor_num, descricao = excluded.descricao,
  confianca = excluded.confianca, verificado_em = excluded.verificado_em;
