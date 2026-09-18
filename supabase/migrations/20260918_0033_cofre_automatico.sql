-- Em Dia — 0033: o cofre automático (B2d, 2026-09-18)
-- Por cada rendimento gravado, a app aponta sozinha no cofre a fatia para o Estado
-- (Segurança Social + IRS estimado), ligada à entrada (`cofre_movimentos.entrada_id`,
-- nota 'auto'). É contabilidade, nunca dinheiro. A pessoa desliga aqui.
alter table public.profiles add column if not exists cofre_automatico boolean not null default true;
comment on column public.profiles.cofre_automatico is 'O cofre aponta sozinho a fatia do imposto de cada rendimento (SS + IRS estimado). Ligado por omissão.';
