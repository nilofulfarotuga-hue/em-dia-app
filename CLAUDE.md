# CLAUDE.md — Em Dia (app nova, separada do Bora)

> Regras desta app. As regras globais do Danilo (`~/.claude/CLAUDE.md`) continuam a valer; estas mandam mais aqui.
> Missão de origem: `docs/PROMPT_MISSAO_2026-09-05.md`. Estado: `docs/MARCOS.md`. Decisões: `docs/DECISOES.md`.

## O que é
Assistente do trabalhador independente a recibos verdes + assistente do carro, para Portugal (TVDE, estafetas,
serviços, freelancers, imigrantes brasileiros). Clone melhorado do MEI Fácil/MaisMei, Drivvo e Artur.

## Identificadores
| Item | Valor |
|---|---|
| Repo | `nilofulfarotuga-hue/em-dia-app`, branch `main` (push = CI: Android internal+alpha, web app + admin) |
| Supabase | `tgdmgtmknbwhcqoxtjbs` (em-dia, eu-west-3). NUNCA tocar no do Bora (`ojykpzwqrtusfeakzrna`). |
| Package Android | `pt.emdia.app` |
| Web | `app.emdia.boraguarda.com` (a app; caminho do iPhone/computador) · `admin.emdia.boraguarda.com` (painel) · `emdia.boraguarda.com` (site). Subdomínios de `boraguarda.com` — decisão do Danilo a 2026-09-07: sem domínio próprio. Os `*.pages.dev` continuam a existir (são os projetos Pages) e redirecionam para estes. Remetente de e-mail: `emdia@boraguarda.com`. |
| Google Cloud / Gemini | projeto `em-dia` (em-dia-507723); chave em `C:\BoraLocal\_segredos\em-dia\gemini.env` e no Vault (`gemini_api_key`); modelo `gemini-flash-latest` |
| Segredos locais | `C:\BoraLocal\_segredos\em-dia\` (keystore, teste.env, gemini.env) — intocável, nunca no repo |
| Vigia da noite | tarefa Windows `EmDia-Retomar` + rotina cloud `em-dia-noite` (fila em `docs/FILA-CLOUD.md`) |

## Regras invioláveis
1. **Idiomas:** app = PT-PT, tratamento por "tu", linguagem de criança de 5 anos, jargão só com explicação entre parênteses; painel admin = PT-BR; a IA responde na variante de quem escreve. Textos SEMPRE em `lib/l10n/partes/*.arb` (merge com `python tool/l10n/merge.py` + `flutter gen-l10n`), nunca no código.
2. **Números legais vivem na tabela `regras_legais`** (com `fonte_url`, `confianca`, `verificado_em`), nunca em constantes. O Dart lê-os por `RegrasLegais` (`lib/regras/`), o servidor por `_shared/regras.ts`. A IA só cita o que está na tabela; regra `por_confirmar` → "não tenho essa regra confirmada". Atualizar todo o janeiro pelo admin.
3. **versionCode é do CI** (`build_android.yml` incrementa e faz commit `[skip ci]`). Nunca à mão no `pubspec.yaml`.
4. **Tracks: `internal,alpha`.** Produção só depois de aprovado pela Google e por decisão do Danilo — nunca automático.
5. **Segredos:** só em GitHub Secrets (base64) e no Vault do Supabase (`public.ler_segredo`, service role). `.dart_defines`, `google-services.json`, `key.properties`, `*.jks` estão no `.gitignore`. Prova: `git grep` a zero.
6. **Trial e plano são do servidor:** `profiles.trial_ate = criado_em + 30 dias` (trigger); cadeados em `feature_flags` lidos do servidor (`PlanoStore`). O telemóvel não decide.
7. **Fuso Europe/Lisbon** em prazos e avisos; moeda `1.234,56 €`; datas `dd/mm/aaaa`; prazo a fim-de-semana/feriado → aviso na véspera útil (`avisoEm`).
8. **Push:** máximo 1 aviso por obrigação por dia (unique em `eventos_push`), às 09:00 de Lisboa, agrupado por utilizador.
9. **Permissões mínimas:** sem localização em segundo plano (foi o que a Google rejeitou ao Bora); fotos pelo Photo Picker; Data Safety declara só Firebase Messaging + Supabase.
10. **Design:** verde `#16A34A` em dia · laranja `#F97316` a vencer (1 por ecrã) · vermelho `#DC2626` passou · Inter explícito em todos os estilos · cantos 16. Ver `docs/DESIGN-SYSTEM.md`.
11. **Prova ou não aconteceu:** cada bloco fecha com saída literal (SELECT, resposta HTTP, foto, run do CI) em `docs/provas/` e linha em `docs/MARCOS.md`. Golden tests em 3 tamanhos + teclado + PT/BR; juiz de visão (`tool/juiz/vision_judge.py`) sem vermelhos.
12. **Dinheiro (Play Billing, preços, `assinaturas`, `validar-compra-play`):** preparar tudo, aplicar só com "vai" do Danilo.
13. **NUNCA `git add -A` nesta pasta.** Mete a stage só os ficheiros que TU tocaste, um a um (`git add <caminho>`), e lê o `git status` antes de commitar.
    - **Porquê:** podes não estar sozinho aqui. O vigia da noite retoma a sessão sozinho e a 6 de setembro de 2026 houve duas a escrever ao mesmo tempo. Um `git add -A` apanhou trabalho por acabar da outra e meteu-o num commit que não era dela.
    - **O que dizia esta regra antes, e estava errado:** que o desaparecimento dos dados de utilizador nesse dia foi um apagão acidental. Não foi. Foi ordem do Danilo, no ponto 1 do BLOCO 1 da missão LOOP TOTAL — apagar todos os dados de teste para um utilizador novo arrancar do zero. Está provado com antes e depois em `docs/provas/bloco1-limpar-e-corrigir-2026-09-06.md`. **Não se repõe cópia nenhuma**: repor traz de volta os dados de teste e desfaz as migrações 0010 a 0020.
    - **Antes de algo destrutivo na base** (reset, re-aplicar migrações, apagar utilizadores): confirma que foi mesmo pedido, e escreve a ordem literal no commit. Não há cópia destes dados.
    - **O vigia já não lança sessão por cima de sessão** (duas provas de vida: a tranca `docs/.sessao-viva` ou o transcript). Provado a 2026-09-06 em `docs/vigia.log`: três corridas agendadas seguidas responderam «sessão viva, saio».

## Comandos
```bash
flutter pub get && python tool/l10n/merge.py && flutter gen-l10n
flutter analyze --no-fatal-infos
flutter test test/unit -r compact          # 47 casos das regras (docs/casos-teste.md)
flutter test test/golden -r compact        # fábrica de fotos → test/golden/_fotos/
python tool/juiz/vision_judge.py           # juiz de visão → docs/provas/telas/
flutter build web --release -t lib/main_admin.dart -o build/web_admin   # painel
```

## Estrutura
`lib/regras/` (regras puras, testadas) · `lib/models/` · `lib/stores/` (Provider: sessão, perfil, regras/plano, dados) ·
`lib/screens/<tela>/` · `lib/admin/` (painel) · `lib/widgets/widgets.dart` · `lib/l10n/partes/` ·
`supabase/migrations/` (0001 schema, 0002 RLS, 0003 seed regras, 0004 vault+cron+admin, …) · `supabase/functions/` (6) ·
`test/unit/`, `test/golden/` · `tool/` (vigia, juiz, l10n, referências, marca) · `docs/` (marcos, decisões, provas, referências).
