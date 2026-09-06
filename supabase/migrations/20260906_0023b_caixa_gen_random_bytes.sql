-- 0023b - o pgcrypto vive no esquema `extensions` e o search_path desta funcao
-- esta preso a 'public' (security definer). Sem o prefixo, dava 42883 na
-- primeira chamada a serio. Aplicado logo a seguir a 0023.
--
-- O corpo e igual ao da 0023, com uma unica diferenca: extensions.gen_random_bytes.
-- Fica como ficheiro proprio para o historico bater certo com a base de dados.
create or replace function public.minha_caixa_de_faturas()
returns table (endereco text, ligada boolean)
language plpgsql security definer set search_path to 'public' as $FN$
declare
  v_uid uuid := auth.uid();
  v_local text;
  v_nome text;
  v_base text;
  v_dominio text;
  v_tentativa int := 0;
begin
  if v_uid is null then
    raise exception 'sem_sessao' using errcode = '42501';
  end if;

  select p.caixa_local, p.nome into v_local, v_nome from profiles p where p.user_id = v_uid;

  if v_local is null then
    v_base := lower(regexp_replace(
      translate(coalesce(v_nome, ''),
                'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ',
                'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN'),
      '[^a-zA-Z]', '', 'g'));
    if length(v_base) < 3 then v_base := 'conta'; end if;
    v_base := left(v_base, 12);

    loop
      v_tentativa := v_tentativa + 1;
      v_local := v_base || '-' || lower(
        translate(encode(extensions.gen_random_bytes(6), 'base64'), '+/=', 'xyz')
      );
      v_local := left(v_local, length(v_base) + 9);
      begin
        update profiles set caixa_local = v_local where user_id = v_uid;
        exit;
      exception when unique_violation then
        if v_tentativa >= 5 then raise; end if;
      end;
    end loop;
  end if;

  select r.valor_txt into v_dominio from regras_legais r where r.chave = 'caixa_faturas_dominio';
  return query select
    v_local || '@' || coalesce(v_dominio, 'ainda-sem-dominio'),
    (v_dominio is not null and v_dominio <> '');
end $FN$;

revoke execute on function public.minha_caixa_de_faturas() from anon, public;
grant execute on function public.minha_caixa_de_faturas() to authenticated;
