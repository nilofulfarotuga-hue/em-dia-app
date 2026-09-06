-- 0007 — bucket privado dos comprovativos de pagamento.
-- A app envia para `comprovativos/{userId}/{obrigacaoId}.jpg` (Tela 1, botão
-- "Já paguei" → foto do comprovativo). Só o dono lê/escreve o seu prefixo.
-- Idempotente: pode correr mais de uma vez.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'comprovativos',
  'comprovativos',
  false,
  5242880, -- 5 MB
  array['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
)
on conflict (id) do nothing;

-- O dono lê o que está na sua pasta ({userId}/...)
drop policy if exists "comprovativos: dono le" on storage.objects;
create policy "comprovativos: dono le"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'comprovativos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- O dono escreve na sua pasta
drop policy if exists "comprovativos: dono escreve" on storage.objects;
create policy "comprovativos: dono escreve"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'comprovativos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- O dono substitui (upsert) na sua pasta
drop policy if exists "comprovativos: dono substitui" on storage.objects;
create policy "comprovativos: dono substitui"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'comprovativos'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'comprovativos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- O dono apaga na sua pasta
drop policy if exists "comprovativos: dono apaga" on storage.objects;
create policy "comprovativos: dono apaga"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'comprovativos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
