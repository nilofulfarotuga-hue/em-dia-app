-- Em Dia — profiles: as duas colunas que a biblioteca de regras (lib/regras/obrigacoes.dart e
-- supabase/functions/_shared/regras.ts) já lê mas que não existiam na tabela. Sem elas, o
-- servidor nunca gerava 'recibos_comunicar' nem 'tvde_certificado' (perfilDeLinha assumia
-- false/null). Valores por omissão inofensivos: nada muda para quem já existe.
alter table public.profiles
  add column if not exists usa_software_faturacao boolean not null default false,
  add column if not exists tvde_certificado_validade date;

comment on column public.profiles.usa_software_faturacao is
  'true se passa faturas por software certificado (SAF-T): gera a obrigação mensal recibos_comunicar (regra recibos_comunicar_dia).';
comment on column public.profiles.tvde_certificado_validade is
  'Data em que caduca o certificado de motorista TVDE: gera a obrigação tvde_certificado quando cai nos próximos 12 meses.';
