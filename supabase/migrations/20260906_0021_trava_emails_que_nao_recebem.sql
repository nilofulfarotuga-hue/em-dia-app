-- 0021 — a trava dos endereços mortos passa a ser do SERVIDOR (2026-09-06).
-- Aplicada em produção: versão 20260906164xxx.
--
-- Pus a trava na app às 16h45 e publiquei. Às 16h5x apareceram no registo da
-- Resend mais dois envios para `test@gmail.com`, os dois «Suppressed». Ou
-- seja: a trava do telemóvel não chega, porque qualquer script que fale
-- directamente com `/auth/v1/otp` passa-lhe ao lado. Foi assim que os dois
-- saíram — não pela app.
--
-- Cada devolução gasta a reputação de `boraguarda.com`, que é o domínio que
-- manda o código de entrada a toda a gente. Sete de quinze envios dos últimos
-- 15 dias falharam, todos por causa de dois endereços inventados.
--
-- Agora a trava está onde ninguém lhe foge: um gatilho antes de criar a conta.
-- Sem conta criada, o GoTrue não tem a quem mandar o código.
--
-- PROVA (a falar direto com a API, a passar ao lado da app):
--   test@gmail.com                       -> 500 {"code":"23514","message":"email_que_nao_recebe: test@gmail.com"}
--   newuser@gmail.com                    -> 500 idem
--   alguem@example.com                   -> 500 idem
--   e2e@boraapp.test                     -> 500 idem
--   boraappbora+depoisdatrava@gmail.com  -> 200, e o registo da Resend diz «Delivered, just now»
-- Nenhum dos quatro primeiros deixou uma única linha no registo da Resend.

create or replace function public.recusa_email_que_nao_recebe()
returns trigger
language plpgsql security definer set search_path to 'public' as $$
declare
  e text := lower(trim(coalesce(new.email, '')));
  caixa text;
  dominio text;
  -- Terminações reservadas por norma (RFC 2606 e RFC 6761): não existem na
  -- internet e nunca vão receber nada.
  mortas text[] := array['.test', '.invalid', '.example', '.localhost', '.local'];
  exemplos text[] := array['example.com', 'example.org', 'example.net'];
  -- Caixas inventadas, nos fornecedores grandes.
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

  -- `nome+etiqueta@gmail.com` chega mesmo à caixa de quem a escreveu: é a
  -- forma certa de testar, e passa.
  caixa := split_part(split_part(e, '@', 1), '+', 1);
  if dominio = any(grandes) and caixa = any(inventadas) then
    raise exception 'email_que_nao_recebe: %', e using errcode = '23514';
  end if;

  return new;
end $$;

drop trigger if exists antes_de_criar_conta_ve_o_email on auth.users;
create trigger antes_de_criar_conta_ve_o_email
  before insert on auth.users
  for each row execute function public.recusa_email_que_nao_recebe();

revoke execute on function public.recusa_email_que_nao_recebe() from anon, authenticated, public;

comment on function public.recusa_email_que_nao_recebe() is
  'Recusa criar conta com endereço que não recebe correio. A trava da app não chega: um script fala direto com /auth/v1/otp (2026-09-06).';
