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

## D6 — Rotina cloud `em-dia-noite` com claude-opus-5 e fila própria
- **O quê:** a rotina cloud (hora a hora) usa o modelo Opus e trabalha SÓ os itens de `docs/FILA-CLOUD.md` (documentos, guias, marketing, guiões); nunca toca em `lib/`, `android/`, `.github/`, `supabase/functions/`.
- **Porquê:** a missão está marcada [MODELO: OPUS] e os textos legais/guias exigem rigor; a fila separada evita conflitos de git com a sessão local. Custo por corrida vazia é quase zero (lê a fila e sai).
- **Como se desfaz:** https://claude.ai/code/routines/trig_01DwHNgzNGqmhr5rQaJgXU9q → pausar; ou trocar `model` para claude-sonnet-5.

## D10 — Na sessão retomada pelo vigia NÃO há browser: o que precisa de clique fica para a sessão interativa
- **O quê:** a retoma `claude --resume -p` (headless) não carrega as ferramentas do Chrome nem do painel de browser. Play Console, Firebase, domínio na Cloudflare, Gemini web/ChatGPT para imagens e TestSprite pelo browser ficam para quando a app do Claude Code voltar a estar aberta (basta escrever "continua" na janela de manhã). Tudo o que é código, base de dados, CI, textos, testes e imagens pela API continua esta noite.
- **Porquê:** limitação técnica do modo `-p`; não é falta de autorização.
- **Como se desfaz:** abrir a janela interativa da sessão `c51cb931…` e continuar — os marcos dizem onde ficou.
- **Imagens (logo, artes):** geradas pela API Gemini (modelos de imagem disponíveis na chave nova: `gemini-3.1-flash-image`, `nano-banana-pro-preview`) em vez do Gemini web + ChatGPT; as 5 propostas ficam em `docs/marca/` na mesma; se de manhã se quiser a ronda pelo ChatGPT, faz-se na sessão interativa.

## D9 — A rotina cloud passa a claude-sonnet-5 (o limite de 5 horas é partilhado)
- **O quê:** às 01:40 a sessão local morreu por "session limit" e a corrida cloud das 01:52 morreu pela MESMA razão (`rate_limit: rejected (five_hour)` no log da rotina). O limite é da conta, não da sessão: cada corrida Opus na cloud gasta o orçamento que mantém a sessão local (a que faz o caminho crítico: telas, CI, Play) viva.
- **Porquê:** proteger a noite. A fila da rotina são documentos/guias/posts — o Sonnet chega e gasta menos.
- **Como se desfaz:** https://claude.ai/code/routines/trig_01DwHNgzNGqmhr5rQaJgXU9q → model claude-opus-5.

## D7 — Lógica das obrigações existe em Dart E em TypeScript, com os mesmos testes
- **O quê:** `lib/regras/obrigacoes.dart` (pré-visualização no onboarding e testes) e `supabase/functions/_shared/regras.ts` (o servidor gera o calendário real). Os dois são validados pelos mesmos casos (`docs/casos-teste.md`, gerado de `test/unit/regras_test.dart`).
- **Porquê:** o servidor tem de ser a fonte de verdade (o cron dos avisos lê a tabela), mas o onboarding precisa de mostrar "este mês tens N coisas" sem esperar pela rede. Uma só implementação obrigaria a chamar o servidor para tudo.
- **Como se desfaz:** apagar o gerador Dart e chamar `calcular-obrigacoes` também na pré-visualização (fica 1 chamada mais lenta no onboarding).

## D8 — Utilizadores de teste criados por SQL com password (só para provas)
- **O quê:** `teste@emdia.pt` e `teste2@emdia.pt` em auth.users com password bcrypt (valores em `C:\BoraLocal\_segredos\em-dia\teste.env`), para obter JWT nas provas das Edge Functions sem caixa de e-mail.
- **Porquê:** a app real entra por código no e-mail/Google; para testar servidor precisa-se de um JWT repetível.
- **Como se desfaz:** `delete from auth.users where email like '%@emdia.pt'` (o cascade apaga perfil e dados).

## D5 — Segredos das Edge Functions no Vault do Supabase, não no CLI
- **O quê:** GEMINI_API_KEY, credenciais FCM e o segredo do cron vivem em `vault.secrets`; as funções lêem-nos com a service role (injetada automaticamente pela plataforma).
- **Porquê:** não há `supabase` CLI instalado nem token de acesso pessoal nesta máquina; o Vault é gerível por SQL via MCP, com prova por SELECT.
- **Como se desfaz:** `supabase secrets set` quando houver CLI; as funções aceitam env var primeiro e Vault como fallback.

## D11 — Centros de inspeção perto e combustível mais barato (DGEG) ficam para a fase 2: na Tela 4 é só um cartão "Em breve"
- **O quê:** a Tela 4 (O Carro) mostra um cartão cinzento "Em breve" com duas linhas — "Centros de inspeção perto de ti" (mapa, dados abertos) e "Combustível mais barato num raio de 10 km" (preços DGEG) — sem mapa, sem GPS e sem chamadas a serviços externos. Tudo o resto da tela (lembretes IUC/IPO/seguro/carta/revisão, abastecimentos e custo por km, despesas com NIF, portagens e multas, cadeado de 1 carro no grátis) está feito.
- **Porquê:** os dois pedem dados abertos (lista de centros do IMT e preços da DGEG), geolocalização com permissão e um mapa — três dependências novas (pacotes, chave de mapas, política de privacidade da localização) que não cabem no bloco das telas sem atrasar o caminho crítico (build + Play). Um cartão honesto "em breve" é melhor do que um mapa vazio ou dados inventados.
- **Como se desfaz:** substituir `_EmBreve` em `lib/screens/carro/carro_screen.dart` por dois cartões reais (uma Edge Function `combustivel-perto` que lê a API da DGEG e a lista de centros do IMT + `geolocator`), e apagar as chaves `carroEmBreve*`/`carroCentrosInspecao*`/`carroCombustivelBarato*` de `lib/l10n/partes/50_carro_*.arb`.

## D12 — Rotina cloud desligada até o Danilo dar acesso ao GitHub; a fila faz-se localmente
- **O quê:** `em-dia-noite` fica `enabled=false` desde 2026-09-06 09:15. Os itens F1, F3–F7 são feitos por agentes na sessão local (documentos, guias, marketing, guiões, ficha da loja, privacidade).
- **Porquê:** 9 corridas na noite, 0 pushes — o ambiente cloud não tem a Claude GitHub App instalada neste repo (403 em git push e na API). Cada corrida gastava ~10 min do limite de 5 h da conta, o mesmo que mantém a sessão local viva.
- **Como se desfaz:** instalar a app (link em PENDENTE-DANILO) e ligar a rotina em https://claude.ai/code/routines/trig_01DwHNgzNGqmhr5rQaJgXU9q; a fila continua a ser `docs/FILA-CLOUD.md`.
