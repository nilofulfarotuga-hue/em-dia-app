-- 0018 — arranjo do `mes` ambíguo (2026-09-06).
-- A variável chamava-se `mes` e a coluna também: o Postgres recusou o insert
-- com «column reference "mes" is ambiguous». A variável passa a `mes_do_ciclo`.
create or replace function public.gerar_pagamentos_do_mes(uid uuid, mes_ref date default null)
returns integer
language plpgsql security definer set search_path to 'public' as $$
declare
  mes_do_ciclo date := date_trunc('month', coalesce(mes_ref, (now() at time zone 'Europe/Lisbon')::date))::date;
  criados integer := 0;
  s record;
  dia date;
begin
  if not public.pode_ver_plano(uid) then
    raise exception 'so_o_proprio' using errcode = '42501';
  end if;

  for s in
    select * from public.saidas
     where user_id = uid and ativa and dia_do_mes is not null
  loop
    -- o dia 31 num mês de 30 passa a ser o último dia desse mês
    dia := mes_do_ciclo + (least(s.dia_do_mes,
                        extract(day from (mes_do_ciclo + interval '1 month - 1 day'))::int) - 1);
    -- e um prazo ao sábado, domingo ou feriado recua para a véspera útil
    dia := public.dia_util_anterior_ou_igual(dia);

    insert into public.saidas_pagamentos (user_id, saida_id, mes, data_limite, valor)
    values (uid, s.id, mes_do_ciclo, dia, s.valor)
    on conflict (saida_id, mes) do nothing;
    if found then criados := criados + 1; end if;
  end loop;
  return criados;
end $$;
