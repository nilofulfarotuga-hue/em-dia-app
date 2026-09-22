# APPLE-FICHA-RESPOSTAS — Em Dia

## Identificacao

Nome: Em Dia

Subtitulo: Recibos verdes, prazos e carro

Categoria: Financas

Bundle ID: `pt.emdia.app`

URL de suporte: `https://emdia.boraguarda.com/`

URL de privacidade: `https://emdia.boraguarda.com/privacidade`

Compras dentro da app: Nao nesta versao.

## Descricao pt-PT

O Em Dia ajuda trabalhadores independentes em Portugal a perceber o recibo verde, os prazos da Seguranca Social, IVA e IRS, e os lembretes do carro.

Podes calcular quanto recebes mesmo de um recibo, ver quanto deves guardar, marcar prazos como pagos, guardar dados do carro e pedir ajuda ao assistente em portugues simples.

Por agora esta tudo aberto e nao se paga nada. Quando as assinaturas abrirem, avisamos com 30 dias de antecedencia e ninguem e cobrado sem dizer que sim.

O Em Dia nao substitui contabilista, Autoridade Tributaria ou Seguranca Social. Da informacao geral, com linguagem simples, para chegares aos prazos mais organizado.

## Descricao pt-BR

O Em Dia ajuda brasileiros e outros trabalhadores em Portugal a entender recibos verdes, prazos da Seguranca Social, IVA, IRS e lembretes do carro.

Voce pode calcular quanto recebe de verdade, ver quanto deve guardar, marcar prazos como pagos, guardar dados do carro e pedir ajuda ao assistente em portugues simples.

Por agora esta tudo aberto e nao se paga nada. Quando as assinaturas abrirem, avisamos com 30 dias de antecedencia e ninguem e cobrado sem dizer que sim.

O Em Dia nao substitui contador, Financas ou Seguranca Social. Ele da informacao geral para voce se organizar melhor.

## Palavras-chave

recibos verdes, trabalhador independente, seguranca social, IRS, IVA, TVDE, estafeta, Portugal, carro, impostos

## Classificacao etaria

18+. A app fala de impostos, rendimentos e organizacao financeira. Nao tem violencia, sexo, jogo, drogas, rede social publica nem conteudo gerado por utilizadores visivel a outras pessoas.

## Acesso do revisor

Primeiro caminho, sem conta: tocar em `Ve como fica, com um exemplo`. Esse modo abre a app preenchida com dados ficticios e permite ver painel, recibos, agenda, carro, assistente, ajuda e plano sem depender de e-mail.

Se a Apple exigir conta: usar a conta de revisor que a Claude.ai deve criar no Supabase do Em Dia e configurar na build por `EMAIL_REVISOR`. O ecrã troca codigo por palavra-passe apenas para esse e-mail. A palavra-passe nao fica no repo.

Pedido para a Claude.ai: criar/confirmar `revisor.apple@boraguarda.com`, definir palavra-passe segura fora do repo e configurar `EMAIL_REVISOR` no secret da build iOS.

## Notas ao revisor

Esta versao nao tem compras dentro da app. A app esta aberta por agora, sem cartao e sem cobranca.

O botao Google fica desligado e nao aparece no iOS. O login principal e por e-mail + codigo enviado pela propria app, sem Facebook, Google, X, LinkedIn ou outro login social de terceiro. Por isso nao ha Sign in with Apple nesta versao.

A app pede localizacao so enquanto esta aberta, para mostrar postos de combustivel e centros de inspecao perto. Tambem permite escrever concelho manualmente.

A app permite apagar conta dentro da app em Definicoes -> Apagar a minha conta.

Push no iOS pode ficar desligado na primeira submissao se `GoogleService-Info.plist`/APNs ainda nao estiverem configurados. Isso nao impede a app de funcionar.

## Privacidade Apple

Dados recolhidos e ligados ao utilizador:

- Endereco de e-mail: criar conta e entrar.
- Identificador de utilizador: UUID gerado pelo Supabase para manter sessao e separar dados por conta.
- Conteudo do utilizador: perguntas ao assistente, pedidos de suporte, dados que a pessoa escreve sobre rendimentos, prazos e carro.
- Fotos ou documentos escolhidos pela pessoa: faturas, comprovativos ou extratos enviados pela propria pessoa.
- Informacao financeira escrita pela pessoa: valores de recibos, despesas, rendimentos e estimativas.
- Localizacao aproximada em primeiro plano: apenas para mostrar postos e centros perto; nao ha localizacao em segundo plano.
- Identificadores do dispositivo: Firebase/Supabase para sessao, diagnostico e notificacoes quando ligadas.

Dados nao recolhidos nesta versao:

- Historico de compras.
- Cartoes de pagamento.
- Contactos.
- Saude.
- Navegacao fora da app.

Partilha com terceiros:

- Supabase: autenticacao e base de dados, servidores na Uniao Europeia.
- Firebase: mensagens push/diagnostico quando configurado.
- Google/Apple pagamentos: nao usado nesta versao.

Retencao e apagar dados:

- Os dados ficam guardados enquanto a conta existir, para a pessoa poder voltar aos seus prazos, recibos e comprovativos.
- A pessoa pode apagar a conta dentro da app em Definicoes -> Apagar a minha conta. Esse caminho remove a conta e os dados associados conforme a politica de privacidade.
- Documentos e fotos enviados pela pessoa ficam no armazenamento privado do Supabase e seguem a mesma regra de apagamento da conta.

## Capturas 6.9

Frase 1: Ve se estas em dia antes do prazo passar.

Frase 2: Calcula o recibo e sabe o que fica para ti.

Frase 3: Guarda dinheiro para IRS, IVA e Seguranca Social.

Frase 4: Junta prazos do trabalho e do carro no mesmo sitio.

Frase 5: Pergunta ao Em Dia em portugues simples.

Frase 6: Por agora esta tudo aberto e nao se paga nada.

## O que fica para a Claude.ai colar

Tudo acima. Nao submeter por OpenCode. Nao abrir App Store Connect nesta sessao.

Antes de submeter, a Claude.ai deve confirmar/criar a conta `revisor.apple@boraguarda.com`, configurar o secret `EMAIL_REVISOR`, confirmar que o botao Google nao aparece na build iOS, e confirmar que a build nao pede notificacoes se APNs/Firebase iOS nao estiverem configurados.
