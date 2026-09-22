# Digest — em-dia-web-iphone-2026-09-22

Missao fechada em 2026-09-22 pelo OpenCode gpt-5.5.

Foi entregue o caminho web/iPhone com tudo gratis por agora. Na app e no site, `planos_a_venda = nao` passa a esconder botoes de comprar, gerir subscricoes e abrir subscricoes. A promessa legal ficou visivel: por agora esta tudo aberto e nao se paga nada; quando as assinaturas abrirem, avisamos com 30 dias de antecedencia e ninguem e cobrado sem dizer que sim. O site tirou a linguagem de trial e ganhou instrucoes PWA para iPhone e Android.

Foi criada a base iOS no repo: pasta `ios/`, bundle `pt.emdia.app`, nome Em Dia, permissoes no `Info.plist`, `Podfile`, includes opcionais de `Secrets.xcconfig`, icones iOS, e workflow `.github/workflows/build_ios.yml` para macOS/TestFlight opcional. Decisao D77: no iOS o Google fica desligado; login por e-mail+codigo; sem Sign in with Apple nesta versao porque nao ha login social de terceiro.

Foram escritos `docs/APPLE-FICHA-RESPOSTAS.md` e `docs/DIVULGACAO-WEB-IPHONE-2026-09-22.md`. A ficha Apple inclui privacidade, notas ao revisor, ausencia de compras, apagar conta dentro da app, retencao/apagamento de documentos e pendencia da conta `revisor.apple@boraguarda.com`. A divulgacao tem 5 posts, cartao de instalacao e prompts de imagem; nada foi publicado nem gerado sem sessao autenticada.

B5 passou: `flutter analyze --no-fatal-infos` sem issues; `flutter test test/unit -r compact` com 182 testes verdes; `flutter test test/golden -r compact` com 141 verdes; `flutter test test/integracao/todos_os_ecras_test.dart -r compact` com 78 ecras vistos e 6 testes verdes. Foi removido o teste padrao do contador criado pelo Flutter, atualizados goldens que ainda esperavam botoes de compra, e trocado `anonKey` por `publishableKey`.

Bloqueios reais: `pod install` nao corre no Windows porque `pod` nao existe; build iOS local nao foi provado; App Store Connect/TestFlight/certificados/capturas finais sao para a Claude.ai; `e2e_log` e digest em `claude_ai_memoria` tambem ficam para a Claude.ai por causa da regra de nao fazer SQL no Supabase do Em Dia a partir do OpenCode. Provas em `provas/em-dia-web-iphone-2026-09-22/`. Relatorio em `docs/RELATORIO-em-dia-web-iphone-2026-09-22.md` e copia em `C:\Users\danil\Desktop\Bora\Projetos\RELATORIO-em-dia-web-iphone-2026-09-22.md`.
