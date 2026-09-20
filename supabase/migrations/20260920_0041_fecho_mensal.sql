-- B5 (2026-09-20): fecho mensal automático do Em Dia.
-- Cria apenas a estrutura. A migração não foi aplicada por esta tarefa delegada.

create extension if not exists pg_cron;
create extension if not exists pg_net;

-- Bucket privado dos fechos mensais: fecho-mensal/<app>/AAAA-MM/...
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'fecho-mensal',
  'fecho-mensal',
  false,
  20971520, -- 20 MB
  array[
    'text/csv',
    'application/csv',
    'application/zip',
    'application/x-zip-compressed',
    'application/json',
    'text/markdown',
    'text/plain',
    'application/pdf'
  ]
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "fecho-mensal: admin le" on storage.objects;
create policy "fecho-mensal: admin le"
  on storage.objects for select to authenticated
  using (bucket_id = 'fecho-mensal' and public.is_admin());

drop policy if exists "fecho-mensal: service role insere" on storage.objects;
create policy "fecho-mensal: service role insere"
  on storage.objects for insert to service_role
  with check (bucket_id = 'fecho-mensal');

drop policy if exists "fecho-mensal: service role atualiza" on storage.objects;
create policy "fecho-mensal: service role atualiza"
  on storage.objects for update to service_role
  using (bucket_id = 'fecho-mensal')
  with check (bucket_id = 'fecho-mensal');

create table if not exists public.fechos_mensais (
  id bigserial primary key,
  app text not null default 'em-dia',
  mes date not null,
  moeda text,
  bruto numeric,
  comissao numeric,
  iva numeric,
  reembolsos numeric,
  liquido numeric,
  transacoes int,
  assinaturas_ativas int,
  ficheiros jsonb not null default '[]',
  estado text not null check (estado in ('ok','sem_extrato','por_rever','erro')),
  motivo text,
  criado_em timestamptz default now(),
  unique (app, mes)
);

alter table public.fechos_mensais enable row level security;

drop policy if exists "fechos_mensais: admin le" on public.fechos_mensais;
create policy "fechos_mensais: admin le"
  on public.fechos_mensais for select to authenticated
  using (public.is_admin());

-- Sem policies de escrita: o cliente nunca escreve. A Edge Function usa service_role.

create or replace function public.admin_fechos_mensais(p_meses integer default 12)
returns setof jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', f.id,
    'app', f.app,
    'mes', f.mes,
    'moeda', f.moeda,
    'bruto', f.bruto,
    'comissao', f.comissao,
    'iva', f.iva,
    'reembolsos', f.reembolsos,
    'liquido', f.liquido,
    'transacoes', f.transacoes,
    'assinaturas_ativas', f.assinaturas_ativas,
    'ficheiros', f.ficheiros,
    'estado', f.estado,
    'motivo', f.motivo,
    'criado_em', f.criado_em
  )
  from public.fechos_mensais f
  where public.is_admin()
  order by f.mes desc, f.criado_em desc
  limit greatest(1, least(p_meses, 120));
$$;

revoke all on function public.admin_fechos_mensais(integer) from public;
grant execute on function public.admin_fechos_mensais(integer) to authenticated, service_role;

-- Dia 1 às 06:10 UTC. A função calcula por defeito o mês anterior em Europe/Lisbon.
select cron.unschedule(jobid) from cron.job where jobname = 'em-dia-fecho-mensal';
select cron.schedule(
  'em-dia-fecho-mensal',
  '10 6 1 * *',
  $$
  select net.http_post(
    url := 'https://tgdmgtmknbwhcqoxtjbs.supabase.co/functions/v1/fecho-mensal',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRnZG1ndG1rbmJ3aGNxb3h0amJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MTkyOTIsImV4cCI6MjEwNDE5NTI5Mn0.XFzQgX1jj6sVhAQNDPLtwJze61WxnEWkN56hYwD5wCM',
      'x-cron-secret', coalesce((select decrypted_secret from vault.decrypted_secrets where name = 'cron_secret'), '')
    ),
    body := '{"origem":"pg_cron"}'::jsonb
  );
  $$
);
