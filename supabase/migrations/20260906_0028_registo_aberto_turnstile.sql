-- 0028 — o registo volta a ficar ABERTO; a porta contra robôs é o Turnstile (2026-09-06, noite).
--
-- A 0027 fechou o registo a convites porque nasceram contas com endereços
-- inventados. O Danilo leu melhor os registos: NÃO eram pessoas. Eram IPs da
-- Google (66.249.88.x Googlebot, 74.125.x, 66.102.x) a rastrear a app web e a
-- submeter o formulário de entrada. Uma lista de convidados não é resposta a
-- um rastreador — é uma porta fechada a clientes.
--
-- A resposta certa, e está provada antes desta migração correr:
--   1. robots.txt + <meta noindex> + X-Robots-Tag em app-em-dia.pages.dev (e97dc6a)
--   2. Cloudflare Turnstile no pedido de código (app 6683646) e ligado à
--      protecção de bots do Auth do Supabase: pedido sem token → 400
--      captcha_failed; pedido com token → 200 e e-mail na caixa.
--
-- Por isso: o gatilho volta a ser SÓ a guarda dos endereços que não recebem
-- correio (a lição da 0021 continua válida: cada devolução gasta o domínio por
-- onde sai o código), a lista de convidados desaparece e a regra
-- `registo_aberto` também — não há "dia do lançamento" que dependa de uma
-- linha esquecida.

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
  if dominio = any(grandes) and caixa = any(inventadas) then
    raise exception 'email_que_nao_recebe: %', e using errcode = '23514';
  end if;

  return new;
end $$;

revoke execute on function public.recusa_email_que_nao_recebe() from anon, authenticated, public;

comment on function public.recusa_email_que_nao_recebe() is
  'Recusa criar conta com endereço que não recebe correio (TLD morto, domínio de exemplo, caixa inventada num provedor grande). Contra robôs a porta é o Turnstile no Auth, não esta função.';

drop table if exists public.emails_convidados;
delete from public.regras_legais where chave = 'registo_aberto';
