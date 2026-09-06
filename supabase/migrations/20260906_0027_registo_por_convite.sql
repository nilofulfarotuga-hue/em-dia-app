-- 0027 — o registo fica por convite até ao lançamento (2026-09-06, noite).
--
-- PORQUÊ, e é um número de hoje: às 16h52 e às 17h56 nasceram duas contas com
-- `joao.silva@gmail.com` e `explorador.emdia@gmail.com`. **As duas devolveram.**
-- São endereços inventados por alguém a testar — não estão na lista de caixas
-- óbvias da migração 0021 (`test@`, `demo@`, `asdf@`), porque parecem nomes de
-- gente a sério. E não há regra nenhuma que distinga `joao.silva@gmail.com`
-- verdadeiro de `joao.silva@gmail.com` inventado: só o servidor de correio da
-- Google sabe, e diz-nos com uma devolução — que é exactamente o que gasta a
-- reputação do domínio por onde sai o código de entrada da app.
--
-- Nenhum padrão resolve isto. O que resolve é o momento: **a app ainda não foi
-- lançada.** Antes do lançamento só entra quem foi convidado, e a lista é
-- nossa. No dia do lançamento muda-se UMA linha e abre a toda a gente.
--
-- Isto não trava ninguém a sério: o teste interno da Play é por convite na
-- mesma, e quem lá está entra aqui.
--
-- CUIDADO, e está provado: o gatilho é BEFORE INSERT em `auth.users`. Uma conta
-- que JÁ exista passa-lhe ao lado, porque não há insert nenhum — o GoTrue
-- limita-se a mandar novo código a quem já lá está. Foi assim que, minutos
-- depois de pôr esta trava, `joao.silva@gmail.com` ainda recebeu um envio e
-- devolveu outra vez. **Fechar a porta não chega: é preciso tirar de dentro
-- quem já entrou.** As duas contas foram apagadas.

create table if not exists public.emails_convidados (
  email text primary key,
  nota text,
  criado_em timestamptz not null default now()
);
alter table public.emails_convidados enable row level security;
drop policy if exists convidados_admin on public.emails_convidados;
create policy convidados_admin on public.emails_convidados
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

comment on table public.emails_convidados is
  'Quem pode criar conta enquanto o registo estiver fechado (regras_legais.registo_aberto). Os endereços com + (nome+etiqueta@gmail.com) contam pela caixa base.';

insert into public.emails_convidados (email, nota) values
  ('boraappbora@gmail.com', 'Conta de trabalho do Danilo'),
  ('nilofulfarotuga@gmail.com', 'Conta pessoal do Danilo')
on conflict (email) do nothing;

insert into public.regras_legais (chave, valor_txt, ano, descricao, confianca, verificado_em)
values ('registo_aberto', 'nao', 2026,
        'Enquanto for "nao", so cria conta quem estiver em emails_convidados. Muda-se para "sim" no dia do lancamento.',
        'aproximado', current_date)
on conflict (chave) do update set valor_txt = excluded.valor_txt, descricao = excluded.descricao;

-- O gatilho da 0021 ganha a segunda pergunta.
create or replace function public.recusa_email_que_nao_recebe()
returns trigger
language plpgsql security definer set search_path to 'public' as $$
declare
  e text := lower(trim(coalesce(new.email, '')));
  caixa text;
  dominio text;
  base text;
  aberto boolean;
  mortas text[] := array['.test', '.invalid', '.example', '.localhost', '.local'];
  exemplos text[] := array['example.com', 'example.org', 'example.net'];
  inventadas text[] := array['test','teste','testes','testing','newuser','novouser',
                             'utilizador','exemplo','example','demo','asdf','aaaa',
                             'qwerty','noreply','no-reply'];
  grandes text[] := array['gmail.com','hotmail.com','outlook.com','outlook.pt',
                          'live.com','yahoo.com','yahoo.com.br','icloud.com','sapo.pt'];
  f text;
begin
  if e = '' then return new; end if;

  foreach f in array mortas loop
    if e like ('%' || f) then
      raise exception 'email_que_nao_recebe: %', e using errcode = '23514';
    end if;
  end loop;

  dominio := split_part(e, '@', 2);
  if dominio = any(exemplos) then
    raise exception 'email_que_nao_recebe: %', e using errcode = '23514';
  end if;

  caixa := split_part(split_part(e, '@', 1), '+', 1);
  if dominio = any(grandes) and caixa = any(inventadas) then
    raise exception 'email_que_nao_recebe: %', e using errcode = '23514';
  end if;

  -- Segunda pergunta (2026-09-06): antes do lancamento, so quem foi convidado.
  -- Nao ha padrao que distinga um "joao.silva@gmail.com" verdadeiro de um
  -- inventado — mas ha lista de convidados, e ela e nossa.
  select coalesce(lower(r.valor_txt), 'nao') = 'sim' into aberto
    from public.regras_legais r where r.chave = 'registo_aberto';
  if coalesce(aberto, false) is false then
    base := caixa || '@' || dominio;   -- nome+etiqueta@gmail.com conta pela caixa base
    if not exists (select 1 from public.emails_convidados c
                    where lower(c.email) in (e, base)) then
      raise exception 'registo_fechado: % (a app ainda nao foi lancada; poe o endereco em emails_convidados)', e
        using errcode = '23514';
    end if;
  end if;

  return new;
end $$;

revoke execute on function public.recusa_email_que_nao_recebe() from anon, authenticated, public;

comment on function public.recusa_email_que_nao_recebe() is
  'Recusa criar conta com endereço que não recebe correio, e — enquanto regras_legais.registo_aberto for "nao" — com qualquer endereço fora de emails_convidados. Duas contas inventadas devolveram a 2026-09-06 e cada devolução gasta o domínio do login.';
