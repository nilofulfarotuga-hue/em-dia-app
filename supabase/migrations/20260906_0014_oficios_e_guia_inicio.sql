-- 0014 — mais dois ofícios e a marca do guia de boas-vindas (2026-09-06).
-- Aplicada em produção: versão 20260906141827.
--
-- A tela dos recibos era de motorista. Passa a ter opções por ofício, e faltavam
-- dois: quem anda nas obras e quem faz outra coisa qualquer. O ofício é o que
-- decide os exemplos, os textos e a descrição do serviço no recibo.
--
-- `viu_guia_inicio` guarda se a pessoa já viu os três ecrãs de boas-vindas, para
-- não os voltar a mostrar. Fica no servidor, não no telemóvel: quem trocar de
-- aparelho não leva com eles outra vez.

alter table public.profiles drop constraint if exists profiles_tipo_atividade_check;
alter table public.profiles add constraint profiles_tipo_atividade_check
  check (tipo_atividade in ('tvde','estafeta','servicos','obras','freelancer','outro','sem_atividade','so_carro'));

alter table public.profiles add column if not exists viu_guia_inicio boolean not null default false;

comment on column public.profiles.tipo_atividade is
  'O ofício: tvde, estafeta, servicos (cabelo/limpeza), obras, freelancer, outro, sem_atividade, so_carro.';
comment on column public.profiles.viu_guia_inicio is
  'Já viu os três ecrãs de boas-vindas. No servidor, para não repetir noutro telemóvel.';
