-- Em Dia — 0002 RLS (2026-09-05)
-- Regra: o utilizador só vê o seu; o admin (claim app_metadata.role=admin ou tabela admins) vê tudo.
-- Tabelas públicas de leitura (regras, guias, flags, feriados, escalões): qualquer pessoa lê, só admin escreve.

alter table public.admins            enable row level security;
alter table public.profiles          enable row level security;
alter table public.rendimentos       enable row level security;
alter table public.carros            enable row level security;
alter table public.abastecimentos    enable row level security;
alter table public.despesas_carro    enable row level security;
alter table public.obrigacoes        enable row level security;
alter table public.regras_legais     enable row level security;
alter table public.irs_escaloes      enable row level security;
alter table public.feriados          enable row level security;
alter table public.guias             enable row level security;
alter table public.conversas_ia      enable row level security;
alter table public.tickets_suporte   enable row level security;
alter table public.push_tokens       enable row level security;
alter table public.eventos_push      enable row level security;
alter table public.avisos_massa      enable row level security;
alter table public.assinaturas       enable row level security;
alter table public.feature_flags     enable row level security;
alter table public.admin_audit_log   enable row level security;
alter table public.e2e_log           enable row level security;

-- admins: cada um vê-se; admin gere
create policy admins_select on public.admins for select using (user_id = auth.uid() or public.is_admin());
create policy admins_admin  on public.admins for all using (public.is_admin()) with check (public.is_admin());

-- profiles
create policy profiles_select on public.profiles for select using (user_id = auth.uid() or public.is_admin());
create policy profiles_update on public.profiles for update using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid() or public.is_admin());
create policy profiles_insert on public.profiles for insert with check (user_id = auth.uid() or public.is_admin());
create policy profiles_delete on public.profiles for delete using (public.is_admin());

-- dados do utilizador (padrão: dono ou admin)
create policy rendimentos_all on public.rendimentos for all using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid() or public.is_admin());
create policy carros_all on public.carros for all using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid() or public.is_admin());
create policy abastecimentos_all on public.abastecimentos for all using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid() or public.is_admin());
create policy despesas_carro_all on public.despesas_carro for all using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid() or public.is_admin());
create policy obrigacoes_all on public.obrigacoes for all using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid() or public.is_admin());
create policy push_tokens_all on public.push_tokens for all using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid() or public.is_admin());

-- leitura pública (a calculadora do site lê regras sem login); escrita só admin
create policy regras_read  on public.regras_legais for select using (true);
create policy regras_admin on public.regras_legais for all using (public.is_admin()) with check (public.is_admin());
create policy escaloes_read  on public.irs_escaloes for select using (true);
create policy escaloes_admin on public.irs_escaloes for all using (public.is_admin()) with check (public.is_admin());
create policy feriados_read  on public.feriados for select using (true);
create policy feriados_admin on public.feriados for all using (public.is_admin()) with check (public.is_admin());
create policy guias_read  on public.guias for select using (publicado or public.is_admin());
create policy guias_admin on public.guias for all using (public.is_admin()) with check (public.is_admin());
create policy flags_read  on public.feature_flags for select using (true);
create policy flags_admin on public.feature_flags for all using (public.is_admin()) with check (public.is_admin());

-- IA e suporte: o utilizador escreve as suas; admin tudo
create policy conversas_select on public.conversas_ia for select using (user_id = auth.uid() or public.is_admin());
create policy conversas_insert on public.conversas_ia for insert with check (user_id = auth.uid() or public.is_admin());
create policy conversas_admin  on public.conversas_ia for update using (public.is_admin()) with check (public.is_admin());
create policy tickets_select on public.tickets_suporte for select using (user_id = auth.uid() or public.is_admin());
create policy tickets_insert on public.tickets_suporte for insert with check (user_id = auth.uid() or public.is_admin());
create policy tickets_update on public.tickets_suporte for update using (public.is_admin()) with check (public.is_admin());

-- push: o utilizador lê os seus avisos; escrita é do servidor (service role ignora RLS) ou admin
create policy eventos_select on public.eventos_push for select using (user_id = auth.uid() or public.is_admin());
create policy eventos_admin  on public.eventos_push for all using (public.is_admin()) with check (public.is_admin());
create policy massa_admin on public.avisos_massa for all using (public.is_admin()) with check (public.is_admin());

-- assinaturas: o utilizador vê as suas; escrita é da validar-compra-play (service role) ou admin
create policy assinaturas_select on public.assinaturas for select using (user_id = auth.uid() or public.is_admin());
create policy assinaturas_admin  on public.assinaturas for all using (public.is_admin()) with check (public.is_admin());

-- auditoria e provas: só admin (o servidor escreve com service role)
create policy audit_admin on public.admin_audit_log for all using (public.is_admin()) with check (public.is_admin());
create policy e2e_admin on public.e2e_log for all using (public.is_admin()) with check (public.is_admin());

-- a view de custo é só para o admin
revoke all on public.v_custo_ia_diario from public, anon, authenticated;
grant select on public.v_custo_ia_diario to authenticated;
-- (a view lê conversas_ia com RLS do chamador: quem não é admin só soma as suas)
