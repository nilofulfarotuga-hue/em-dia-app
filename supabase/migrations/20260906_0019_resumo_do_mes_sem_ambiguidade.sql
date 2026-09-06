-- 0019 — o mesmo `mes` ambíguo, agora no resumo do mês (2026-09-06).
-- Mesma armadilha da 0018: variável e coluna com o mesmo nome. Fica escrito
-- para não haver uma terceira vez: em plpgsql, nunca dar a uma variável o nome
-- de uma coluna da tabela que se vai ler.
create or replace function public.resumo_do_mes(uid uuid, mes_ref date default null)
returns jsonb
language plpgsql stable security definer set search_path to 'public' as $$
declare
  mes_do_ciclo date := date_trunc('month', coalesce(mes_ref, (now() at time zone 'Europe/Lisbon')::date))::date;
  fim date := (mes_do_ciclo + interval '1 month - 1 day')::date;
  entrou numeric := 0; saiu numeric := 0; falta_contas numeric := 0; falta_estado numeric := 0;
  no_cofre numeric := 0;
begin
  if not public.pode_ver_plano(uid) then
    raise exception 'so_o_proprio' using errcode = '42501';
  end if;

  select coalesce(sum(e.valor), 0) into entrou
    from public.entradas e where e.user_id = uid and e.data between mes_do_ciclo and fim;

  select coalesce(sum(p.valor), 0) into saiu
    from public.saidas_pagamentos p
   where p.user_id = uid and p.mes = mes_do_ciclo and p.estado = 'pago';

  select coalesce(sum(p.valor), 0) into falta_contas
    from public.saidas_pagamentos p
   where p.user_id = uid and p.mes = mes_do_ciclo and p.estado = 'pendente';

  select coalesce(sum(o.valor_estimado), 0) into falta_estado
    from public.obrigacoes o
   where o.user_id = uid and o.estado = 'pendente'
     and o.data_limite between mes_do_ciclo and fim;

  select coalesce(sum(c.valor), 0) into no_cofre
    from public.cofre_movimentos c where c.user_id = uid;

  return jsonb_build_object(
    'mes', mes_do_ciclo,
    'entrou', round(entrou, 2),
    'saiu', round(saiu, 2),
    'falta_pagar_contas', round(falta_contas, 2),
    'falta_pagar_estado', round(falta_estado, 2),
    -- Como acaba o mês: o que entrou menos tudo o que ainda tem de sair.
    'como_acaba_o_mes', round(entrou - saiu - falta_contas - falta_estado, 2),
    'no_cofre', round(no_cofre, 2)
  );
end $$;
