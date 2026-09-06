-- 0023 — a caixa de correio das faturas (2026-09-06). Decisão D24.
--
-- A pessoa não dá a palavra-passe do e-mail a ninguém e a app não pede acesso ao
-- Gmail. Em vez disso, cada pessoa ganha um endereço nosso e reencaminha para lá
-- as faturas que já lhe chegam por e-mail (EDP, MEO, água, seguro...).
--
-- O endereço é `<nome>-<8 letras ao acaso>@<domínio>`. As 8 letras são a
-- fechadura: sem elas, um estranho adivinhava a caixa de outra pessoa a partir
-- do nome. O domínio NÃO está no código — está em `regras_legais`
-- (`caixa_faturas_dominio`), para se ligar no dia em que o domínio existir sem
-- publicar app nenhuma.
--
-- REGRA DE OURO DESTE FICHEIRO (custou duas migrações a aprender, ver 0018/0019):
-- uma variável plpgsql com o mesmo nome de uma coluna torna as referências
-- ambíguas (erro 42702). Por isso todas as variáveis aqui levam prefixo `v_`.

-- ---------------------------------------------------------------- o endereço
alter table public.profiles
  add column if not exists caixa_local text;

create unique index if not exists profiles_caixa_local_unica
  on public.profiles (caixa_local) where caixa_local is not null;

comment on column public.profiles.caixa_local is
  'A parte antes do @ da caixa de faturas desta pessoa. O domínio vem de regras_legais.caixa_faturas_dominio (D24).';

-- ------------------------------------------------------- as faturas que chegam
create table if not exists public.faturas_recebidas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  -- quem mandou e o que dizia o assunto: é por aqui que a pessoa reconhece a conta
  remetente text not null,
  assunto text,
  recebido_em timestamptz not null default now(),
  -- o anexo, já no Storage (bucket privado 'faturas'). Sem anexo, fica nulo.
  anexo_caminho text,
  anexo_nome text,
  anexo_bytes integer,
  -- o que a leitura automática percebeu (a mesma que lê as fotos)
  leitura_ocr_id uuid references public.leituras_ocr(id) on delete set null,
  -- o que a pessoa fez com isto
  estado text not null default 'nova'
    check (estado in ('nova', 'ligada', 'ignorada', 'falhou')),
  saida_id uuid references public.saidas(id) on delete set null,
  pagamento_id uuid references public.saidas_pagamentos(id) on delete set null,
  erro text,
  criado_em timestamptz not null default now()
);

create index if not exists faturas_recebidas_por_user
  on public.faturas_recebidas (user_id, recebido_em desc);
create index if not exists faturas_recebidas_por_estado
  on public.faturas_recebidas (user_id, estado) where estado = 'nova';

comment on table public.faturas_recebidas is
  'Faturas que chegaram por e-mail à caixa da pessoa. O Worker da Cloudflare entrega, a Edge Function receber-fatura escreve aqui (D24).';

alter table public.faturas_recebidas enable row level security;

drop policy if exists faturas_recebidas_dono_le on public.faturas_recebidas;
create policy faturas_recebidas_dono_le on public.faturas_recebidas
  for select to authenticated using (user_id = auth.uid());

drop policy if exists faturas_recebidas_dono_muda on public.faturas_recebidas;
create policy faturas_recebidas_dono_muda on public.faturas_recebidas
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists faturas_recebidas_dono_apaga on public.faturas_recebidas;
create policy faturas_recebidas_dono_apaga on public.faturas_recebidas
  for delete to authenticated using (user_id = auth.uid());

-- Ninguém insere daqui: só o service role (a Edge Function receber-fatura).
-- Sem policy de INSERT, o RLS recusa a toda a gente menos a ele.

-- -------------------------------------------------- o balde privado do Storage
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('faturas', 'faturas', false, 10485760,
        array['application/pdf','image/jpeg','image/png','image/webp'])
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- O caminho é sempre `<user_id>/<ficheiro>`: a primeira pasta é a fechadura.
drop policy if exists faturas_dono_le on storage.objects;
create policy faturas_dono_le on storage.objects
  for select to authenticated
  using (bucket_id = 'faturas' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists faturas_dono_apaga on storage.objects;
create policy faturas_dono_apaga on storage.objects
  for delete to authenticated
  using (bucket_id = 'faturas' and (storage.foldername(name))[1] = auth.uid()::text);

-- --------------------------------------------- nascer o endereço, uma só vez
-- Chamada pela app. Se ainda não houver endereço, inventa um e grava-o.
create or replace function public.minha_caixa_de_faturas()
returns table (endereco text, ligada boolean)
language plpgsql security definer set search_path to 'public' as $$
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
    -- o nome vira letras simples: "João Óscar" → "joaooscar", cortado aos 12
    -- sem extensão unaccent (não está instalada): troca-se à mão o que aparece em português
    v_base := lower(regexp_replace(
      translate(coalesce(v_nome, ''),
                'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ',
                'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN'),
      '[^a-zA-Z]', '', 'g'));
    if length(v_base) < 3 then v_base := 'conta'; end if;
    v_base := left(v_base, 12);

    loop
      v_tentativa := v_tentativa + 1;
      -- 8 letras/algarismos ao acaso — é isto que impede adivinhar a caixa de outro
      v_local := v_base || '-' || lower(
        -- `extensions.` a serio: o pgcrypto vive no esquema `extensions` e o
        -- search_path desta funcao esta preso a 'public' (security definer).
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
end $$;

revoke execute on function public.minha_caixa_de_faturas() from anon, public;
grant execute on function public.minha_caixa_de_faturas() to authenticated;

comment on function public.minha_caixa_de_faturas() is
  'Devolve (e cria na primeira vez) o endereço de e-mail das faturas desta pessoa. ligada=false enquanto não houver domínio (D24).';

-- ------------------------------------------------ o interruptor, desligado
-- Enquanto esta linha estiver vazia, a app mostra "ainda não está pronta" em vez
-- de um endereço que não recebe nada. Liga-se escrevendo o domínio aqui — sem
-- publicar app, sem mexer em código.
insert into regras_legais (chave, valor_txt, ano, descricao, confianca, fonte_url, verificado_em)
values ('caixa_faturas_dominio', null, 2026,
        'Dominio da caixa de correio das faturas (ex.: contas.emdia.pt). Vazio = a caixa esta desligada. D24.',
        'aproximado', null, current_date)
on conflict (chave) do nothing;
