MOTOR: OPUS. Pasta/repo em-dia-app (ramo main). Projeto Supabase do Em Dia: tgdmgtmknbwhcqoxtjbs (separado do Bora). Lê primeiro docs/MARCOS.md, docs/DECISOES.md, docs/PENDENTE-DANILO.md, docs/APPLE-FICHA-RESPOSTAS.md, docs/DIVULGACAO-WEB-IPHONE-2026-09-22.md e docs/RELATORIO-em-dia-web-iphone-2026-09-22.md. run_id em-dia-ios-2026-09-22, fluxo e2e_log em-dia-ios-2026-09-22 — uma linha por bloco com prova (se não houver acesso SQL, escreve as linhas em docs/PARA-A-CLAUDE-AI.md). Se correr na nuvem: o que precisar do PC regista como bloqueado-precisa-pc e segue. Outro erro encontrado = reporta com passo fora-de-scope, não corrige. regras_legais.planos_a_venda='nao' fica como está; sem compras.

PORQUÊ: pôr o Em Dia no iPhone (TestFlight e depois App Store), tudo grátis por agora. A missão de 22/09 deixou a base iOS com o identificador errado.

BLOCO 1 — identificador: a Apple recusou pt.emdia.app. O App ID e a app no App Store Connect (apple_id 6814807320, SKU emdia-ios-001, nome "Em Dia: Recibos e Impostos", idioma PT-PT) usam com.boraguarda.emdia. Troca em ios/Runner.xcodeproj/project.pbxproj, Info.plist, build_ios.yml, Secrets.xcconfig e onde mais aparecer. Commit.

BLOCO 2 — CI: copia do repo bora-app-cloud a receita de .github/workflows/build_ios.yml e .github/scripts/ios_publicar.py (runner macOS, altool, versão seguinte com lançamento AFTER_APPROVAL e submissão automática), adaptada a com.boraguarda.emdia e apple_id 6814807320, mesmos nomes de variáveis; lista em docs/SECRETS-IOS.md as variáveis que este repo tem de ter configuradas no GitHub.

BLOCO 3 — ficha e revisor: completa docs/APPLE-FICHA-RESPOSTAS.md (capturas 6,9 e 6,5 geradas no simulador pelo CI, privacidade, idade, notas ao revisor a explicar como entrar sem caixa de correio).

BLOCO 4 — divulgação: 5 posts finais PT-PT e prompts de imagem em docs/marketing/lancamento-web-iphone/; no site emdia.boraguarda.com a secção "Também no iPhone — grátis por agora" com botão para a App Store (apple_id 6814807320).

BLOCO 5 — fecho: flutter analyze limpo, testes verdes, push para main, relatório docs/RELATORIO-em-dia-ios-2026-09-22.md com a lista do que ficou bloqueado-precisa-pc.
