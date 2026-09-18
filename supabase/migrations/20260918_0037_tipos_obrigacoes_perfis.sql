-- Em Dia — 0037: os tipos de obrigação do contrato e da empresa (B3, 2026-09-18)
--
-- Apanhado na prova real da calcular-obrigacoes v6: a primeira regeneração de um perfil
-- «contrato» respondeu 500 «violates check constraint obrigacoes_tipo_check». A lista de
-- tipos aceites vivia só no CHECK e não conhecia os novos.
alter table public.obrigacoes drop constraint if exists obrigacoes_tipo_check;
alter table public.obrigacoes add constraint obrigacoes_tipo_check check (tipo = any (array[
  -- independente
  'ss_declaracao', 'ss_pagamento', 'iva_declaracao', 'iva_pagamento', 'irs_entrega', 'irs_pagamento_conta',
  'efatura_validar', 'recibos_comunicar', 'fim_isencao_ss',
  -- carro
  'iuc', 'ipo', 'seguro', 'carta', 'revisao', 'troca_carta',
  -- pessoa
  'residencia', 'tvde_certificado', 'tvde_licenca', 'multa', 'portagem', 'outro',
  -- contrato (B3): lembretes, nunca «o que fazer agora»
  'subsidio_natal', 'faturas_nif',
  -- empresa (B3): só calendário
  'dmr', 'saft', 'ss_empresa', 'irc_modelo22', 'irc_pagamento_conta', 'ies'
]));
comment on constraint obrigacoes_tipo_check on public.obrigacoes is 'Tipos gerados por lib/regras/obrigacoes.dart e _shared/regras.ts (espelhos) + os manuais. Ao acrescentar um tipo lá, acrescenta-se aqui.';
