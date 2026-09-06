-- 0010 — obrigações duplicadas nunca mais (2026-09-06).
-- Aplicada em produção: versão 20260906135646.
--
-- Havia duas obrigações iguais para o mesmo utilizador no mesmo dia. A chave
-- que existia era (user_id, chave_unica), e a chave_unica das obrigações
-- escritas à mão é um UUID ao acaso — logo, não travava repetições.
--
-- São duas regras, porque as obrigações não nascem todas da mesma maneira:
--
--   · As que o servidor calcula (têm `origem_regra`) só podem existir uma vez
--     por utilizador + tipo + dia. É a regra que o Danilo pediu.
--   · As que a pessoa escreve à mão (`origem_regra` a nulo) podem repetir tipo
--     e dia — "outro" no dia 11 pode ser a renda e o ginásio — mas não podem
--     ser a MESMA descrição no mesmo dia.
--
-- PROVA (2026-09-06 13:57): a segunda inserção igual devolveu, tal e qual:
--   ERROR: 23505: duplicate key value violates unique constraint
--   "obrigacoes_calculadas_uma_so"
--   DETAIL: Key (user_id, tipo, data_limite)=(500f99a2-…, ss_pagamento,
--           2099-01-20) already exists.

-- limpa o que já lá esteja repetido, ficando com a mais antiga
delete from public.obrigacoes o
 using public.obrigacoes mais_velha
 where o.user_id = mais_velha.user_id
   and o.tipo = mais_velha.tipo
   and o.data_limite = mais_velha.data_limite
   and coalesce(o.descricao,'') = coalesce(mais_velha.descricao,'')
   and o.criado_em > mais_velha.criado_em;

create unique index if not exists obrigacoes_calculadas_uma_so
  on public.obrigacoes (user_id, tipo, data_limite)
  where origem_regra is not null;

create unique index if not exists obrigacoes_manuais_uma_so
  on public.obrigacoes (user_id, tipo, data_limite, coalesce(descricao,''))
  where origem_regra is null;

comment on index public.obrigacoes_calculadas_uma_so is
  'Uma obrigação calculada pelo servidor por utilizador+tipo+dia (2026-09-06).';
comment on index public.obrigacoes_manuais_uma_so is
  'Uma obrigação escrita à mão por utilizador+tipo+dia+descrição (2026-09-06).';
