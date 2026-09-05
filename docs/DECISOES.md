# DECISÕES tomadas sozinho — missão Em Dia (2026-09-05)

> Formato: **O quê** · **Porquê** · **Como se desfaz**. Modo noite: ninguém responde até de manhã.

## D1 — Repo GitHub público (como o Bora)
- **O quê:** `nilofulfarotuga-hue/em-dia-app` criado público.
- **Porquê:** o Bora (`bora-app-cloud`) é público e é o padrão provado; repos públicos têm minutos de GitHub Actions ilimitados (o build Android gasta 15–25 min por corrida; um repo privado no plano grátis tem só 2000 min/mês e acabava a meio do mês). Nenhum segredo vive no repo (tudo em secrets/base64).
- **Como se desfaz:** Settings → Danger zone → Change visibility → Private (1 clique).

## D2 — Um único projeto Flutter, dois pontos de entrada
- **O quê:** `lib/main.dart` (app cliente, PT-PT) e `lib/main_admin.dart` (painel admin web, PT-BR) no mesmo repo/pacote. Dois projetos Cloudflare Pages (`app-em-dia`, `em-dia-admin`) construídos com `-t lib/main_admin.dart`.
- **Porquê:** partilham modelos, tema, cliente Supabase e regras; o Bora fez o mesmo (admin dentro da app). Evita dois repos e duas cadeias de CI.
- **Como se desfaz:** extrair `lib/admin/` para um pacote próprio mais tarde; nada fica preso.

## D3 — Keystore gerada localmente, guardada fora do repo
- **O quê:** `C:\BoraLocal\_segredos\em-dia\em-dia-release.jks` (alias `emdia`), passwords aleatórias em `keystore.env` na mesma pasta; vai para o GitHub só como secret base64.
- **Porquê:** a regra do Bora (chaves nunca em claro no repo). A pasta `_segredos` é intocável (regra 9 do CLAUDE.md global).
- **Como se desfaz:** não se desfaz — perder a keystore = perder a app na Play. Fazer cópia para o Drive da equipa é passo PENDENTE-DANILO (é ele que escolhe onde).

## D4 — Auth: código por e-mail (OTP) + Google; SMS não
- **O quê:** entrada por e-mail com código de 6 dígitos (Supabase email OTP, SMTP Resend já existente do Bora) e Google Sign-In. Telemóvel guarda-se no perfil mas não é o login.
- **Porquê:** o SMS no Supabase exige Twilio/MessageBird (pago). O prompt manda: "se o SMS precisar de fornecedor pago, usa Google Sign-In + email magic link e regista a decisão".
- **Como se desfaz:** ligar o provider Phone no painel do Supabase e adicionar o ecrã de telemóvel — o modelo `profiles` já tem `telefone`.

## D5 — Segredos das Edge Functions no Vault do Supabase, não no CLI
- **O quê:** GEMINI_API_KEY, credenciais FCM e o segredo do cron vivem em `vault.secrets`; as funções lêem-nos com a service role (injetada automaticamente pela plataforma).
- **Porquê:** não há `supabase` CLI instalado nem token de acesso pessoal nesta máquina; o Vault é gerível por SQL via MCP, com prova por SELECT.
- **Como se desfaz:** `supabase secrets set` quando houver CLI; as funções aceitam env var primeiro e Vault como fallback.
