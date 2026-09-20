# B7b — «Estatísticas de utilização»: interruptor nas Definições + eventos na app — 2026-09-20

> Missão `em-dia-vender-2026-09-18`, Bloco 7 parte b. Fecha o Bloco 7 com o B7a (`b7a-funil.md`).

## Quem fez o quê
- **GLM (glm-5.2)**: NÃO fez. Às 19:21 o plano Go respondeu «Weekly usage limit reached. Resets in 5hr 39min» (log do
  opencode) e o `opencode run` ficou pendurado sem escrever nada — morto às 19:32. Quota semanal do Go partilhada (armadilha
  já prevista na missão); volta por volta da 01:00 de 21/09.
- **ChatGPT Plus (gpt-5.5, `opencode run -m openai/gpt-5.5`, cascata «codigo» do MOTORES.json)** por
  `delegar.ps1 chatgpt … -Id b7b-consentimento`: escreveu tudo (16 ficheiros, +200/−2), correu merge + gen-l10n + analyze.
  A sessão do Claude Code caiu durante os goldens dele (o vigia relançou às 20:16); o `delegar.ps1` morreu com ela, sem
  `resultado.json`. O diff foi tirado da cópia isolada (`git diff` no work) e aplicado aqui.
- **Claude Code (maestro)**: reviu o diff com contexto limpo, aplicou, correu analyze, unit e goldens.

## O que ficou
- `lib/models/perfil.dart` (`consentiuEstatisticas`, fromMap/toUpdate/copyWith); `lib/services/uso.dart` (`EventoUso`,
  `Uso.registar` só com consentimento, nunca lança); chamadas: `abriuApp` no `PerfilStore.carregar`, `concluiuOnboarding`
  no fim do onboarding, `viuPlano` no `initState` do plano, `iniciouCompra`/`comprou`/`cancelou` em `Compras` (o perfil
  vai por parâmetro; a lógica de compra não mudou).
- `definicoes_screen.dart`: secção «Estatísticas de utilização» com `SwitchListTile.adaptive` (Key `defs_estatisticas`),
  guarda por `PerfilStore.guardar`, erro → `Aviso` vermelho. Textos PT/BR em `60_mais_*.arb`.
- Testes: `test/unit/uso_test.dart` (3), golden `mais: definições estatísticas (PT/BR)`.

## Provas literais (checker = Claude Code, 2026-09-20 20:2x)
```
flutter analyze --no-fatal-infos → 1 issue found (anonKey, pré-existente)
flutter test test/unit/uso_test.dart test/unit/perfis_test.dart -r compact → 00:08 +16: All tests passed!
  (o teste «com consentimento, erro do cliente não propaga» imprime «uso: não registou comprou (… You must initialize
   the supabase instance …)» — é o comportamento pedido: engole e segue)
flutter test test/golden/mais_test.dart test/golden/plano_test.dart test/golden/onboarding_test.dart -r compact
  → 00:51 +18: All tests passed!  (inclui «mais: definições estatísticas (PT/BR)»)
```
Saída do motor: `b7b-saida-chatgpt.txt`. Pasta: `~/.claude/delegacoes/2026-09-20/b7b-consentimento/`.
