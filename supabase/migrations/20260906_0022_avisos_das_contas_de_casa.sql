-- 0022 — os avisos das contas de casa (2026-09-06).
--
-- Até aqui os avisos eram só das obrigações do Estado. Passam a cobrir também
-- as contas de casa, com os prazos que o Danilo escreveu:
--   débito direto         → 1 dia antes ("vai sair 43,20 € da conta amanhã")
--   referência Multibanco → 3 dias antes E outra vez no próprio dia
--   obrigações do Estado  → 5 dias antes E no próprio dia (já era assim)
--
-- Os números vivem em `regras_legais` (aviso_debito_direto_dias,
-- aviso_referencia_dias, aviso_obrigacao_estado_dias), não no código.
--
-- Duas coisas de arrumação:
--  1) `eventos_push` ganha `pagamento_id`, porque a chave que impede repetir o
--     mesmo aviso duas vezes no mesmo dia é (user, tipo, dia, obrigacao_id) e
--     uma conta de casa não é uma obrigação — sem coluna própria, duas contas
--     no mesmo dia contavam como uma.
--  2) `tipo` ganha os valores novos.

alter table public.eventos_push
  add column if not exists pagamento_id uuid references public.saidas_pagamentos(id) on delete cascade;

-- a chave única passa a contar também o pagamento
alter table public.eventos_push
  drop constraint if exists eventos_push_user_id_tipo_dia_obrigacao_id_key;
create unique index if not exists eventos_push_um_por_dia
  on public.eventos_push (user_id, tipo, dia, obrigacao_id, pagamento_id) nulls not distinct;

alter table public.eventos_push drop constraint if exists eventos_push_tipo_check;
alter table public.eventos_push add constraint eventos_push_tipo_check check (tipo in (
  '5_dias','dia','passado','vigia_iva','fim_isencao','carro','reforma',
  'trial_25','trial_31','reativacao','massa',
  -- contas de casa
  'conta_debito_amanha','conta_referencia_3_dias','conta_referencia_hoje','conta_passou'
));

comment on column public.eventos_push.pagamento_id is
  'A conta de casa a que este aviso diz respeito. Nula nos avisos do Estado (2026-09-06).';
