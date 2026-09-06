-- 0017 — as contas do mês, o resumo, o cofre e o radar da fidelização (2026-09-06).
-- Aplicada em produção nas versões 20260906144... (0017), e corrigida por
-- 20260906_0018 e 20260906_0019 no mesmo dia. Este ficheiro traz as versões
-- FINAIS, já com as duas correções — quem correr isto de raiz fica logo certo.
--
-- CICATRIZ, duas vezes no mesmo dia: em plpgsql, uma variável chamada `mes`
-- torna ambígua qualquer referência à coluna `mes` da tabela, e o Postgres
-- recusa com «column reference "mes" is ambiguous». Aconteceu no
-- `gerar_pagamentos_do_mes` e outra vez no `resumo_do_mes`. Regra da casa:
-- nunca dar a uma variável o nome de uma coluna da tabela que se vai ler.
--
-- As quatro funções ficam no servidor, e não no telemóvel, pela mesma razão de
-- sempre: quem mudar a hora do aparelho não muda as contas.

-- ------------------------------------------------- 1. gerar as contas do mês
-- Uma conta que se paga todos os meses tem de aparecer no calendário deste mês.
-- Cuidados provados a 2026-09-06:
--   · dia 31 num mês de 30 → último dia do mês (telemóvel dia 31 → 30/09);
--   · prazo ao sábado, domingo ou feriado → recua para a véspera útil
--     (luz dia 20, que era domingo → sexta, 18/09).
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
    dia := mes_do_ciclo + (least(s.dia_do_mes,
                        extract(day from (mes_do_ciclo + interval '1 month - 1 day'))::int) - 1);
    dia := public.dia_util_anterior_ou_igual(dia);

    insert into public.saidas_pagamentos (user_id, saida_id, mes, data_limite, valor)
    values (uid, s.id, mes_do_ciclo, dia, s.valor)
    on conflict (saida_id, mes) do nothing;
    if found then criados := criados + 1; end if;
  end loop;
  return criados;
end $$;
revoke execute on function public.gerar_pagamentos_do_mes(uuid, date) from anon, public;
grant  execute on function public.gerar_pagamentos_do_mes(uuid, date) to authenticated, service_role;

-- --------------------------------------------------------- 2. resumo do mês
-- "Entrou X, saiu Y, ainda falta pagar Z, e o mês acaba assim."
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
    -- Pode dar negativo, e é isso que a app tem de dizer a tempo.
    'como_acaba_o_mes', round(entrou - saiu - falta_contas - falta_estado, 2),
    'no_cofre', round(no_cofre, 2)
  );
end $$;
revoke execute on function public.resumo_do_mes(uuid, date) from anon, public;
grant  execute on function public.resumo_do_mes(uuid, date) to authenticated, service_role;

-- ----------------------------------------------------------- 3. resumo do ano
-- Para o IRS: o que entrou por tipo, mês a mês.
create or replace function public.resumo_do_ano(uid uuid, ano integer default null)
returns jsonb
language plpgsql stable security definer set search_path to 'public' as $$
declare
  a integer := coalesce(ano, extract(year from (now() at time zone 'Europe/Lisbon'))::int);
  r jsonb;
begin
  if not public.pode_ver_plano(uid) then
    raise exception 'so_o_proprio' using errcode = '42501';
  end if;
  select jsonb_build_object(
    'ano', a,
    'entrou_total', coalesce((select round(sum(valor), 2) from public.entradas
                               where user_id = uid and extract(year from data) = a), 0),
    'entrou_para_irs', coalesce((select round(sum(valor), 2) from public.entradas
                                  where user_id = uid and extract(year from data) = a and conta_para_irs), 0),
    'por_tipo', coalesce((select jsonb_object_agg(tipo, total) from (
        select tipo, round(sum(valor), 2) as total from public.entradas
         where user_id = uid and extract(year from data) = a group by tipo) t), '{}'::jsonb),
    'por_mes', coalesce((select jsonb_object_agg(m, total) from (
        select to_char(date_trunc('month', data), 'YYYY-MM') as m, round(sum(valor), 2) as total
          from public.entradas where user_id = uid and extract(year from data) = a
         group by 1 order by 1) t), '{}'::jsonb),
    'saiu_total', coalesce((select round(sum(p.valor), 2) from public.saidas_pagamentos p
                             where p.user_id = uid and p.estado = 'pago' and extract(year from p.mes) = a), 0)
  ) into r;
  return r;
end $$;
revoke execute on function public.resumo_do_ano(uuid, integer) from anon, public;
grant  execute on function public.resumo_do_ano(uuid, integer) to authenticated, service_role;

-- ------------------------------------------------- 4. radar da fidelização
-- Contratos cuja fidelização acaba dentro de N dias — é a janela em que se pode
-- mudar sem pagar multa. Também mostra os que acabaram há menos de 30 dias,
-- porque muita gente só olha para isto depois.
create or replace function public.radar_fidelizacao(uid uuid, dias integer default null)
returns table (
  saida_id uuid, nome text, categoria text, fornecedor text,
  fim_fidelizacao date, dias_para_acabar integer, valor_mensal numeric
)
language plpgsql stable security definer set search_path to 'public' as $$
declare
  hoje date := (now() at time zone 'Europe/Lisbon')::date;
  janela integer := coalesce(dias, (select valor_num::int from public.regras_legais
                                     where chave = 'aviso_fidelizacao_dias'), 30);
begin
  if not public.pode_ver_plano(uid) then
    raise exception 'so_o_proprio' using errcode = '42501';
  end if;
  return query
    select s.id, s.nome, s.categoria, s.fornecedor, s.fim_fidelizacao,
           (s.fim_fidelizacao - hoje)::int, s.valor
      from public.saidas s
     where s.user_id = uid and s.ativa and s.fim_fidelizacao is not null
       and s.fim_fidelizacao between hoje - 30 and hoje + janela
     order by s.fim_fidelizacao;
end $$;
revoke execute on function public.radar_fidelizacao(uuid, integer) from anon, public;
grant  execute on function public.radar_fidelizacao(uuid, integer) to authenticated, service_role;

comment on function public.gerar_pagamentos_do_mes(uuid, date) is
  'Cria as contas a pagar deste mês a partir das saídas activas. Dia 31 em mês curto vai ao último dia; fim-de-semana e feriado recuam para a véspera útil.';
comment on function public.resumo_do_mes(uuid, date) is
  'Entrou, saiu, falta pagar (contas e Estado), como acaba o mês, e quanto está no cofre.';
