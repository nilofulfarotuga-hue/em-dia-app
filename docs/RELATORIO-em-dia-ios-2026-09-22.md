# Relatório — Em Dia no iPhone — missão em-dia-ios-2026-09-22

Corrida: Claude Code na nuvem, 23/09/2026, ramo `em-dia-ios-2026-09-23` (a partir de `main`). **Sem push nem merge para `main`** — a web e o Android não foram publicados; fica um PR aberto para o Danilo decidir. Nada de compras nem preços (`planos_a_venda='nao'` intocado).

## Feito

| Bloco | O quê | Commit |
|---|---|---|
| 1 — identificador | `com.boraguarda.emdia` no `project.pbxproj` (Runner + RunnerTests). `Info.plist` lê `$(PRODUCT_BUNDLE_IDENTIFIER)` e o `Secrets.xcconfig` é gerado pelo CI sem bundle, por isso não mudaram. Linha iOS no `CLAUDE.md`. Android fica `pt.emdia.app`. | `81b7231` |
| 2 — CI | `build_ios.yml` com a receita do Bora: job A (analyze, unitários, percurso, **capturas 6,9" e 6,5" no simulador**, sem conta Apple) e job B (certificado + perfil, IPA com assinatura manual, `altool`, `ios_publicar.py`: versão com `AFTER_APPROVAL`, build ligada, notas, submetida). Só `workflow_dispatch`. Mesmos nomes de segredos do `bora-app-cloud`. `ASC_APP_ID=6814807320`. Nome do perfil lido de dentro do `.mobileprovision` e conferido contra o bundle; Team ID só em segredo. Adaptação no script: o nome da versão da loja passa a ser o da build (a 1.ª versão nasceu «1.0» no App Store Connect; a build vem do pubspec «1.0.0»). `docs/SECRETS-IOS.md` com a lista exata. | `6e28811` |
| 3 — ficha e revisor | `docs/APPLE-FICHA-RESPOSTAS.md` refeito com acentos: bundle e nome da loja certos, capturas mapeadas aos PNG do CI (`integration_test/capturas_loja_test.dart`, modo exemplo, 6 ecrãs — provado na VM), App Privacy tipo a tipo, questionário de idade (resultado 4+), notas ao revisor em inglês com os dois caminhos sem caixa de correio (modo exemplo; conta `EMAIL_REVISOR`). A conta que existe no Supabase do Em Dia é `revisor.google@boraguarda.com` (com palavra-passe, criada a 06/09); `revisor.apple@…` não existe. O `.dart_defines` é um só, por isso o revisor da Apple usa essa mesma conta. | `3d2e1e1` |
| 4 — divulgação | `docs/marketing/lancamento-web-iphone/posts.md` (5 posts PT-PT com acentos, marca Em Dia sozinha, iPhone = Safari até à aprovação) e `prompts-imagem.md`. No site: secção «Também no iPhone — grátis por agora» com o botão da App Store **escondido** atrás de `regras_legais.ios_na_app_store` (sem a linha = escondido; `'sim'` = aparece). Provado no Chromium: `provas/em-dia-ios-2026-09-22/b4-site-interruptor.md`. Site **não republicado** (não sai pelo CI e não era para publicar). | `b5a2dec` |
| 5 — fecho | Portão verde (abaixo), este relatório, linhas no `e2e_log`, PR para `main`. | este commit |

Portão (Flutter 3.47.2, Linux):
`flutter analyze --no-fatal-infos` → `No issues found!` · `flutter test test/unit` → `+182: All tests passed!` · `flutter test test/integracao` → `ECRAS_VISTOS=78`, `+6: All tests passed!` · `flutter test test/golden` → `+141: All tests passed!` · teste das capturas corrido na VM → 6 ecrãs (`01-painel` … `06-assistente`).

`e2e_log` (Supabase do Em Dia, `run_id = em-dia-ios-2026-09-22`): ids 13 (b1), 14 (b2), 15 (b3), 16 (b4), 17 (b5), 18 (capturas no CI), todos `ok`, e a linha `missao-concluida` do fecho.

**Missão fechada a 24/09/2026.** Tudo o que não precisa do PC nem de publicação está feito e provado. O PR https://github.com/nilofulfarotuga-hue/em-dia-app/pull/1 está verde e sem conflitos; o merge para `main` publica a web e o Android e fica para ordem explícita do Danilo.

## Bloqueado — precisa do PC (bloqueado-precisa-pc)

1. **Os 7 segredos da Apple** no GitHub do `em-dia-app`: `IOS_DIST_CERT_P12_B64`, `IOS_DIST_CERT_PASSWORD`, `IOS_PROVISIONING_PROFILE_B64`, `ASC_KEY_P8_B64`, `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_TEAM_ID`. Os ficheiros estão no PC; o perfil App Store de `com.boraguarda.emdia` ainda tem de ser criado no portal. Detalhe em `docs/SECRETS-IOS.md`.
2. **`GOOGLE_SERVICE_INFO_PLIST_B64`** (app iOS no Firebase do Em Dia) e chave APNs — sem isto o IPA sai sem push (funciona na mesma).
3. **Palavra-passe do revisor** (`revisor.google@boraguarda.com`) para colar no App Store Connect, e confirmar que o `DART_DEFINES_FILE_B64` traz `EMAIL_REVISOR` com esse e-mail.
4. **Job B** (Actions → build-ios → Run workflow com `enviar` ligado) depois dos segredos. O job A **já correu verde** neste ramo (corrida 35891779298): capturas 6,9" 1320×2868 e 6,5" 1284×2778, 6 de cada, no artefacto `ios-capturas-2` — prova em `provas/em-dia-ios-2026-09-22/b3-capturas-ci.md`. Falta descarregá-las e carregá-las no App Store Connect (a `06-assistente` foi conferida no código: não mostra erro — ver fora-de-scope 3).
5. **Imagens de divulgação**: gerar no Gemini/ChatGPT a partir de `prompts-imagem.md` (sem ferramenta de imagem autenticada na nuvem).
6. **Depois da aprovação da Apple**: `insert into regras_legais (chave, valor_txt, …) values ('ios_na_app_store','sim', …)` e republicar nada — o site lê a tabela.

## Fora do scope — encontrado e NÃO corrigido

1. **Site: botões de compra visíveis com `planos_a_venda='nao'`.** Os `data-compra` («Experimentar o Pro grátis», «Começar grátis» no início; «Assinar na app» ×2 em `/precos`) têm `hidden`, mas `.btn{display:inline-flex}` ganha ao `[hidden]` do browser → aparecem. Medido no Chromium (`display=flex`, visível). O verificador só lê o atributo e dava 62/62. Correção proposta: `[data-compra][hidden]{display:none}` em `index.html` e `precos.html`, e o verificador passar a medir no browser.
2. **`ios/Runner/Info.plist`: textos das permissões sem acentos** (`camara`, `localizacao`, `inspecao`, `sessao`) — é o que o iPhone mostra na janela de permissão. Correção proposta: `câmara`, `localização`, `inspeção`, `sessão`.
3. **Modo exemplo → assistente chama o Supabase.** Na corrida do 6,5" do job A, abrir «Pergunta o que quiseres» no modo exemplo deu `conversas_ia: … You must initialize the supabase instance`. Não parte o teste nem aparece no ecrã (`lib/stores/ia_store.dart:120` só faz `debugPrint`, a foto `06-assistente` pode usar-se), mas o modo exemplo devia ficar sem servidor. Correção proposta: no modo exemplo o `IaStore` não chama `carregarHistorico`.
4. O `docs/DIVULGACAO-WEB-IPHONE-2026-09-22.md` antigo fica como estava (substituído pelo `posts.md` novo).

## Para a Claude.ai

- Rever e fazer merge do PR (publica web + Android pelo CI — só com ordem do Danilo).
- Os pontos 1–6 de cima.
