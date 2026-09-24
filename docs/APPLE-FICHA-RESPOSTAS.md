# APPLE-FICHA-RESPOSTAS — Em Dia

> Respostas prontas a colar no App Store Connect. Atualizado a 2026-09-23 (missão em-dia-ios-2026-09-22, bloco 3).
> A ficha foi preenchida pela Claude.ai a 23/09 01:14; este ficheiro é a fonte para conferir e completar o que falta (capturas, privacidade, idade, notas ao revisor).
> O Em Dia é uma marca própria: nenhum texto da ficha o apresenta como produto de outra app.

## Identificação

| Campo | Valor |
|---|---|
| Nome na loja | Em Dia: Recibos e Impostos |
| Nome no ecrã do iPhone | Em Dia (`CFBundleDisplayName`) |
| Subtítulo (máx. 30) | Recibos verdes, prazos e carro |
| Bundle ID | `com.boraguarda.emdia` (a Apple recusou `pt.emdia.app`; o Android continua com esse) |
| Apple ID da app | 6814807320 |
| SKU | emdia-ios-001 |
| Idioma principal | Português (Portugal) |
| Categoria principal | Finanças |
| Categoria secundária | Produtividade |
| URL de suporte | https://emdia.boraguarda.com/ |
| URL de marketing | https://emdia.boraguarda.com/ |
| URL da política de privacidade | https://emdia.boraguarda.com/privacidade |
| Preço | Grátis |
| Compras dentro da app | Nenhuma nesta versão |
| Direitos de autor | 2026 Em Dia |

## Texto promocional (máx. 170)

Por agora está tudo aberto e não se paga nada. Recibos verdes, prazos da Segurança Social, IVA e IRS, e lembretes do carro, em português simples.

## Descrição (pt-PT)

O Em Dia ajuda quem trabalha por conta própria em Portugal a perceber o recibo verde, os prazos da Segurança Social, do IVA e do IRS, e os lembretes do carro.

O que podes fazer:
• Calcular quanto recebes mesmo de um recibo e quanto deves pôr de lado.
• Ver numa agenda todos os prazos do trabalho e do carro, com aviso na véspera.
• Marcar cada prazo como pago e guardar o comprovativo.
• Guardar os dados do carro: seguro, inspeção, IUC e revisões.
• Perguntar ao assistente em português simples, com a fonte de cada regra.
• Ver como fica sem criar conta, com um exemplo já preenchido.

Por agora está tudo aberto e não se paga nada. Quando as assinaturas abrirem, avisamos com 30 dias de antecedência e ninguém é cobrado sem dizer que sim.

O Em Dia não substitui o contabilista, a Autoridade Tributária nem a Segurança Social. Dá informação geral, com linguagem simples, para chegares aos prazos mais organizado.

## Palavras-chave (máx. 100 caracteres, sem espaços depois das vírgulas)

recibos verdes,independente,segurança social,IRS,IVA,TVDE,estafeta,impostos,prazos,carro

## Novidades desta versão

Vem de `ios/notas_de_versao.json` — o CI escreve-as sozinho em cada envio.

## Capturas de ecrã

Geradas pelo CI no simulador (`.github/workflows/build_ios.yml`, job A, passo «Capturas 6,9" e 6,5"»), a partir da app a sério no modo «Vê como fica, com um exemplo» (`integration_test/capturas_loja_test.dart`). Saem no artefacto `ios-capturas-<n.º da corrida>`:

| Pasta | Tamanho que a Apple pede | Simulador (o primeiro que existir na imagem do runner) |
|---|---|---|
| `capturas/6.9/` | 1320 × 2868 (6,9") | iPhone 17 Pro Max → 16 Pro Max → 16 Plus → 15 Pro Max |
| `capturas/6.5/` | 1284 × 2778 ou 1242 × 2688 (6,5") | iPhone 14 Plus → 13 Pro Max → 12 Pro Max → 11 Pro Max |

O log do passo imprime a largura e a altura de cada PNG (`sips`) — conferir antes de carregar.

| Ficheiro | Ecrã | Frase por cima (se se usar moldura) |
|---|---|---|
| `01-painel.png` | Painel | Vê se estás em dia antes do prazo passar. |
| `02-recibo.png` | Recibos, calculadora com 1.000 € | Calcula o recibo e sabe o que fica para ti. |
| `03-cofre.png` | O cofre do imposto | Guarda dinheiro para o IRS, o IVA e a Segurança Social. |
| `04-agenda.png` | Agenda | Junta os prazos do trabalho e do carro no mesmo sítio. |
| `05-carro.png` | O carro | Seguro, inspeção e IUC sem te esqueceres. |
| `06-assistente.png` | Pergunta o que quiseres | Pergunta ao Em Dia em português simples. |

A faixa laranja do modo exemplo aparece nas capturas — é de propósito: mostra que os dados são de exemplo (a Maria) e não de uma pessoa real (diretriz 2.3.3).

Estado: **geradas** — corrida https://github.com/nilofulfarotuga-hue/em-dia-app/actions/runs/35891779298, artefacto `ios-capturas-2`: 6,9" = 1320×2868 (iPhone 17 Pro Max, iOS 26.5) e 6,5" = 1284×2778 (iPhone 14 Plus), 6 de cada. A `06-assistente` foi conferida no código: não mostra erro (ver `provas/em-dia-ios-2026-09-22/b3-capturas-ci.md`). Prontas a carregar.

## Privacidade da app (App Privacy)

Rastreamento (tracking): **Não.** A app não junta dados com dados de outras empresas para publicidade nem os partilha com corretores de dados. Sem IDFA, sem pedido de App Tracking Transparency.

Dados recolhidos — todos **ligados à identidade**, nenhum usado para rastreamento:

| Tipo na Apple | O que é no Em Dia | Para quê (finalidade na Apple) |
|---|---|---|
| Informações de contacto → Endereço de e-mail | O e-mail com que a pessoa entra | Funcionalidade da app |
| Identificadores → ID do utilizador | UUID da conta no Supabase | Funcionalidade da app |
| Informações financeiras → Outras informações financeiras | Valores de recibos, despesas e rendimentos que a pessoa escreve | Funcionalidade da app |
| Conteúdo do utilizador → Fotos ou vídeos | Faturas e comprovativos que a pessoa escolhe | Funcionalidade da app |
| Conteúdo do utilizador → Outro conteúdo | Perguntas ao assistente, pedidos de suporte, dados do carro | Funcionalidade da app |
| Localização → Localização aproximada | Só com a app aberta, para mostrar postos e centros de inspeção perto | Funcionalidade da app |
| Dados de utilização → Interação com o produto | Só se a pessoa ligar «estatísticas de utilização» nas Definições (6 eventos: arranque, fim do onboarding, plano…) | Estatísticas |
| Diagnóstico → Outros dados de diagnóstico | Token de notificações do Firebase, quando o push estiver ligado | Funcionalidade da app |

Não recolhidos: histórico de compras, dados de pagamento, contactos, saúde, histórico de navegação, localização precisa, áudio (o ditado por voz usa o reconhecimento do próprio iPhone e só a frase escrita é enviada, como pergunta).

Fornecedores: Supabase (autenticação, base de dados e ficheiros, servidores na União Europeia); Firebase Cloud Messaging (notificações, quando ligadas); Google Gemini (responde às perguntas ao assistente — recebe o texto da pergunta).

Retenção e apagar: os dados ficam enquanto a conta existir. A pessoa apaga a conta dentro da app em **Mais → Definições → Apagar a minha conta** (e fora da app em https://emdia.boraguarda.com/apagar-conta). Documentos e fotos seguem a mesma regra.

## Classificação etária

Respostas ao questionário da Apple — todas **Nenhum / Não**:

- Violência (de desenho animado, realista, prolongada), terror, conteúdo sexual ou nudez, linguagem grosseira, humor para adultos: **Nenhum**.
- Álcool, tabaco, drogas; jogos de azar simulados; concursos; temas médicos: **Nenhum**.
- Acesso à web sem restrições: **Não** (só abre ligações fixas: site, privacidade, fontes oficiais).
- Conteúdo gerado por utilizadores visível a outros, mensagens entre utilizadores, publicidade: **Não**.
- Jogo a dinheiro: **Não**.

Resultado esperado: **4+**. A ficha antiga dizia 18+; a Apple calcula a idade pelas respostas e nada nesta app a leva acima de 4+. O público é adulto (quem passa recibos), e isso fica dito na descrição, não na idade.

## Acesso do revisor e notas ao revisor

Campo «Início de sessão obrigatório»: **Sim**, com a conta abaixo (e o modo exemplo como caminho sem conta).

Conta: o e-mail configurado em `EMAIL_REVISOR` na build (segredo `DART_DEFINES_FILE_B64`). O `.dart_defines` é um só para o Android, a web e o iOS, por isso é **a mesma conta do revisor da Google**: `revisor.google@boraguarda.com` — confirmada no Supabase do Em Dia a 23/09 (criada a 06/09, com palavra-passe). A palavra-passe **não está no repo**: está na Play Console (credenciais do revisor) e no PC; cola-se só no App Store Connect.

Texto para o campo «Notas» (inglês, porque o revisor lê inglês; a app é em português):

> Em Dia is a free app (no in-app purchases in this version) that helps self-employed workers in Portugal with their green receipts, Social Security/VAT/income tax deadlines and car reminders. The app is in European Portuguese.
>
> HOW TO SIGN IN (no mailbox needed):
> • Option 1 — no account: on the first screen tap «Vê como fica, com um exemplo» ("See how it looks, with an example"). The whole app opens with sample data (a fictitious user, Maria), with an orange banner saying it is an example. Every tab works: Painel, Recibos, Dinheiro, Agenda, Carro, Mais.
> • Option 2 — review account: type the e-mail below in the sign-in field. For this one address the app replaces the e-mailed 6-digit code with a password field. E-mail: revisor.google@boraguarda.com — Password: [colar aqui, fora do repo].
>
> Normal users sign in with e-mail + a one-time code sent by the app. There is no third-party or social login (the Google button is disabled on iOS), so Sign in with Apple is not required.
>
> Account deletion: Mais → Definições → «Apagar a minha conta».
> Location is only requested while the app is open, to show nearby fuel stations and inspection centres; the user can type the town instead.
> The assistant answers general questions using official sources; it does not replace an accountant.

## Antes de submeter (a quem colar)

- [ ] Correr o job A e carregar as capturas 6,9" e 6,5" (conferir o tamanho no log).
- [ ] Colar a palavra-passe do revisor no App Store Connect e confirmar que `EMAIL_REVISOR=revisor.google@boraguarda.com` está no `DART_DEFINES_FILE_B64`.
- [ ] Privacidade e classificação etária como acima.
- [ ] Segredos da Apple postos (`docs/SECRETS-IOS.md`) → job B com `enviar` ligado.
