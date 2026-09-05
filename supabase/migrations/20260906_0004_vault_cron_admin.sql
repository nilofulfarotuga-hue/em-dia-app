-- Em Dia — 0004: segredos no Vault, cron dos avisos, admin automático, utilizador de teste (2026-09-06)
create extension if not exists pg_cron;
create extension if not exists pg_net;

-- Ler um segredo do Vault a partir das Edge Functions (service role) — nunca pelo cliente.
create or replace function public.ler_segredo(nome text) returns text
language sql stable security definer set search_path = public, vault as $$
  select decrypted_secret from vault.decrypted_secrets where name = nome limit 1;
$$;
revoke all on function public.ler_segredo(text) from public, anon, authenticated;
grant execute on function public.ler_segredo(text) to service_role;

-- Guardar/atualizar um segredo (só para o admin, pelo painel, ou via SQL no MCP)
create or replace function public.guardar_segredo(nome text, valor text, descricao text default null) returns void
language plpgsql security definer set search_path = public, vault as $$
declare sid uuid;
begin
  select id into sid from vault.secrets where name = nome limit 1;
  if sid is null then
    perform vault.create_secret(valor, nome, coalesce(descricao, nome));
  else
    perform vault.update_secret(sid, valor, nome, coalesce(descricao, nome));
  end if;
end $$;
revoke all on function public.guardar_segredo(text, text, text) from public, anon, authenticated;
grant execute on function public.guardar_segredo(text, text, text) to service_role;

-- Os donos entram como admin assim que criam conta (a tabela admins também serve o is_admin()).
create or replace function public.admin_automatico() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.email in ('nilofulfarotuga@gmail.com', 'boraappbora@gmail.com') then
    insert into public.admins (user_id) values (new.user_id) on conflict do nothing;
  end if;
  return new;
end $$;
drop trigger if exists trg_admin_automatico on public.profiles;
create trigger trg_admin_automatico after insert on public.profiles
  for each row execute function public.admin_automatico();

-- Marcar como 'passado' o que venceu e não foi pago (corre todos os dias na função avisos-cron,
-- mas fica aqui como função SQL reutilizável).
create or replace function public.marcar_obrigacoes_passadas() returns integer
language plpgsql security definer set search_path = public as $$
declare n integer;
begin
  update public.obrigacoes set estado = 'passado'
  where estado = 'pendente' and data_limite < (now() at time zone 'Europe/Lisbon')::date;
  get diagnostics n = row_count;
  return n;
end $$;
revoke all on function public.marcar_obrigacoes_passadas() from public, anon, authenticated;
grant execute on function public.marcar_obrigacoes_passadas() to service_role;

-- Cron: de hora a hora chama avisos-cron; a função só age quando são 09:00 em Lisboa
-- (assim o horário de verão/inverno nunca engana) e nunca repete um aviso no mesmo dia.
select cron.unschedule(jobid) from cron.job where jobname = 'em-dia-avisos-hora';
select cron.schedule(
  'em-dia-avisos-hora',
  '5 * * * *',
  $$
  select net.http_post(
    url := 'https://tgdmgtmknbwhcqoxtjbs.supabase.co/functions/v1/avisos-cron',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRnZG1ndG1rbmJ3aGNxb3h0amJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MTkyOTIsImV4cCI6MjEwNDE5NTI5Mn0.XFzQgX1jj6sVhAQNDPLtwJze61WxnEWkN56hYwD5wCM',
      'x-cron-secret', coalesce((select decrypted_secret from vault.decrypted_secrets where name = 'cron_secret'), '')
    ),
    body := '{"origem":"pg_cron"}'::jsonb
  );
  $$
);
