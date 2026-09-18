-- Em Dia — 0031: o onboarding guarda cada resposta (defeito 1 da missão em-dia-tudo-2026-09-17)
--
-- A 17/09 a Claude.ai respondeu a 4 das 5 perguntas, escreveu a matrícula, recarregou a
-- página e a app voltou à pergunta 1. Agora cada resposta fica no aparelho (localStorage /
-- shared_preferences) E aqui, ao sair de cada pergunta; ao reabrir, a app retoma no passo
-- guardado. É rascunho: apaga-se quando o onboarding acaba. Só o próprio escreve (RLS de
-- `profiles` já limita o update ao dono).
alter table public.profiles add column if not exists onboarding_rascunho jsonb;
comment on column public.profiles.onboarding_rascunho is
  'Respostas do onboarding ainda por acabar ({passo, tipo, mesAbertura, …, guardado_em}). Nulo = sem rascunho ou onboarding concluído.';
