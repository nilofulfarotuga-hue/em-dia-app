-- 0043 (2026-09-21): as RPCs de «Perto de mim» só são chamadas pela app
-- autenticada (`lib/stores/perto_store.dart`). O site público não as usa.
-- Mantém acesso para utilizadores com sessão e remove qualquer concessão anónima
-- que exista no remoto.

revoke execute on function public.postos_perto(double precision, double precision, text, double precision, integer) from anon;
revoke execute on function public.centros_perto(double precision, double precision, integer) from anon;
revoke execute on function public.centro_do_municipio(text) from anon;
revoke execute on function public.combustiveis_disponiveis() from anon;

grant execute on function public.postos_perto(double precision, double precision, text, double precision, integer) to authenticated;
grant execute on function public.centros_perto(double precision, double precision, integer) to authenticated;
grant execute on function public.centro_do_municipio(text) to authenticated;
grant execute on function public.combustiveis_disponiveis() to authenticated;
