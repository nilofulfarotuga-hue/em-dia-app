-- Em Dia — 0035: fatura-recibo certificada pela InvoiceXpress, atrás de interruptor (B2b, 2026-09-18)
--
-- O interruptor nasce DESLIGADO para todos os planos (free/pro/familia = false). Enquanto assim
-- estiver, a app não mostra o botão e a Edge Function `emitir-recibo` responde `desligada`.
-- Liga-se no admin quando houver conta InvoiceXpress e os dois segredos no Vault
-- (`invoicexpress_account`, `invoicexpress_api_key`) — ver docs/PENDENTE-DANILO.md.

insert into public.feature_flags (chave, descricao, free, pro, familia, limite_free, limite_pro, limite_familia)
values ('faturacao_certificada', 'Fatura-recibo certificada (InvoiceXpress) emitida de dentro da app', false, false, false, null, null, null)
on conflict (chave) do nothing;

-- Cada documento pedido fica cá com rasto, ANTES de ir lá fora.
create table if not exists public.recibos_emitidos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  fornecedor text not null default 'invoicexpress',
  documento_id bigint,                 -- id do documento no fornecedor
  numero text,                         -- ex.: FR A/12
  cliente_nome text not null,
  cliente_nif text,
  descricao text not null,
  valor numeric(12,2) not null check (valor > 0),
  data date not null default current_date,
  isento boolean not null default true,
  retencao_pct numeric(5,2) not null default 0,
  estado text not null default 'a_emitir' check (estado in ('a_emitir','rascunho','emitida','erro','anulada')),
  pdf_url text,
  erro text,
  criado_em timestamptz not null default now(),
  emitida_em timestamptz
);
create index if not exists recibos_emitidos_user_idx on public.recibos_emitidos (user_id, criado_em desc);
comment on table public.recibos_emitidos is 'Faturas-recibo pedidas à InvoiceXpress (B2b). Escreve só o servidor (service role); a pessoa lê as suas.';

alter table public.recibos_emitidos enable row level security;
drop policy if exists "recibos_emitidos: dono le" on public.recibos_emitidos;
create policy "recibos_emitidos: dono le" on public.recibos_emitidos
  for select to authenticated using (auth.uid() = user_id);
drop policy if exists "recibos_emitidos: admin le" on public.recibos_emitidos;
create policy "recibos_emitidos: admin le" on public.recibos_emitidos
  for select to authenticated using (public.is_admin());
