-- 0005: a unique de eventos_push passa a tratar NULL como igual a NULL.
-- Antes, (user_id, tipo, dia, obrigacao_id) com obrigacao_id NULL (vigia_iva, trial_25, trial_31,
-- reativacao) não travava repetições — a função avisos-cron filtrava só em código (ressalva da
-- verificação independente de 2026-09-06). Com NULLS NOT DISTINCT a base de dados garante
-- "1 evento por utilizador, tipo e dia" também para os tipos sem obrigação.
-- O upsert da função (on conflict (user_id,tipo,dia,obrigacao_id) do nothing) continua a inferir
-- este índice; nada muda no código.
alter table public.eventos_push
  drop constraint if exists eventos_push_user_id_tipo_dia_obrigacao_id_key;
alter table public.eventos_push
  add constraint eventos_push_user_id_tipo_dia_obrigacao_id_key
  unique nulls not distinct (user_id, tipo, dia, obrigacao_id);
