-- 0042 (2026-09-21): espelho da migração aplicada em produção pela Claude.ai.
-- Não reaplicar sem verificar o histórico remoto; este ficheiro existe para o repo
-- não divergir do estado já aplicado.

revoke execute on function public.admin_apagar_conta_simular(uuid) from anon;
revoke execute on function public.admin_assinaturas(integer) from anon;
revoke execute on function public.admin_erros(integer) from anon;
revoke execute on function public.admin_fechos_mensais(integer) from anon;
revoke execute on function public.admin_funil(integer) from anon;

alter function public.distancia_km(double precision, double precision, double precision, double precision)
  set search_path = public;

alter function public.dia_util_seguinte_ou_igual(date)
  set search_path = public;
