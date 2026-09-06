-- 0029 — a guarda dos endereços inventados passa a apanhar "testuser12345" (2026-09-06, 21h30).
--
-- Às 20:09Z, com o Turnstile JÁ ligado, um IP da Google (74.125.209.194) fez o
-- pedido de código a partir de app-em-dia.pages.dev para `testuser12345@gmail.com`
-- e recebeu 200: o renderizador da Google é um Chrome a sério e a Cloudflare
-- deu-lhe token. A conta ficou por confirmar (o /verify seguinte deu 403) e foi
-- apagada. O que falhou aqui não foi o Turnstile, foi a guarda da 0021: a lista
-- de caixas inventadas compara o nome EXACTO ("test", "demo"…) e "testuser12345"
-- não está lá. Passa a ser um padrão: nome de teste + letras + números, só nos
-- provedores grandes (uma empresa com `teste@empresa.pt` não é apanhada).

create or replace function public.recusa_email_que_nao_recebe()
returns trigger
language plpgsql security definer set search_path to 'public' as $$
declare
  e text := lower(trim(coalesce(new.email, '')));
  caixa text;
  dominio text;
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
  if dominio = any(grandes) then
    if caixa = any(inventadas) then
      raise exception 'email_que_nao_recebe: %', e using errcode = '23514';
    end if;
    -- testuser12345, teste2026, demo.user1, user123, asdf99, abc123 — mas não
    -- testemunha.silva nem testa.silva (Testa é apelido) nem carlos.teste.
    -- (Aplicado em duas vezes: 0029 e 0029b, que afinou o padrão.)
    if caixa ~ '^(test|teste|testes|testing|demo|exemplo|example|usuario|utilizador|asdf|qwerty|aaaa|abc|foo|bar|dummy|fake|sample)([._-]?(user|users|utilizador|usuario|conta|account|mail|email|app|emdia|novo|new|test|teste))?[0-9]{0,8}$'
       or caixa ~ '^(user|usuario|utilizador|novouser|newuser)[._-]?[0-9]{1,8}$' then
      raise exception 'email_que_nao_recebe: %', e using errcode = '23514';
    end if;
  end if;

  return new;
end $$;

revoke execute on function public.recusa_email_que_nao_recebe() from anon, authenticated, public;

comment on function public.recusa_email_que_nao_recebe() is
  'Recusa criar conta com endereço que não recebe correio: TLD morto, domínio de exemplo, e — só nos provedores grandes — caixa inventada (nome exacto, ou nome de teste + números / segunda palavra de teste). Contra robôs a porta é o Turnstile no Auth.';
