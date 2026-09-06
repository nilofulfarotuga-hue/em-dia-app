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
| Web | `app-em-dia.pages.dev` (a app; caminho do iPhone/computador) · `em-dia-admin.pages.dev` (painel) |
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
