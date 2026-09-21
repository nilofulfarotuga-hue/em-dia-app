# Play Console - respostas prontas do Em Dia

Notas de prova local:
- Os ficheiros pedidos `docs/provas/play/ficha-20260906-112014.md`, `docs/provas/play/data-safety-20260907-010943.md` e `provas/em-dia-vender-2026-09-18/b0-estado-real.md` não existem nesta cópia. Usei `docs/loja/descricao-play.md`, `docs/loja/play/data-safety-em-dia.csv`, `site/index.html`, `site/privacidade.html` e o código em `lib/services/`, `lib/stores/` e `lib/screens/`.
- Localização aproximada está confirmada no código: `PertoStore.usarLocalizacao()` pede permissão em primeiro plano, usa precisão baixa, chama `postos_perto` e `centros_perto`, e o comentário diz que não guarda a localização.
- Fotos pelo Photo Picker estão confirmadas em `LeitorDocumento` e `comprovativo.dart`.
- Acesso de revisor por palavra-passe existe se a build vier com `EMAIL_REVISOR`; a palavra-passe não está na app.

## Lista de secções

- Ficha da loja principal
- Categoria e etiquetas
- Detalhes de contacto
- Política de privacidade
- Acesso à app
- Anúncios
- Classificação de conteúdo
- Público-alvo e conteúdo
- Notícias, COVID e apps governamentais
- Funcionalidades financeiras
- Saúde
- Segurança dos dados
- Notas para a revisão
- Produtos de subscrição

## Ficha da loja principal

Caminho na consola: Crescimento > Presença na loja > Definições da loja > Ficha principal da loja.

### pt-PT

Nome da app:
```text
Em Dia: Recibos e Impostos
```

Descrição curta:
```text
Recibos verdes, IVA, Segurança Social e o teu carro sempre em dia.
```

Descrição longa:
```text
Em Dia é o assistente do trabalhador independente em Portugal. Serve para motoristas TVDE, estafetas, freelancers, prestadores de serviços e pessoas brasileiras que chegaram há pouco e querem perceber os recibos verdes.

A app ajuda-te a saber o que entra, o que tens de guardar e que prazo vem a seguir.

O que podes fazer:

- Calcular recibos verdes com retenção, IVA e o valor que fica para ti.
- Ver quanto deves guardar para Segurança Social, IRS e IVA.
- Montar um calendário com prazos da Segurança Social, IVA, IRS, IUC, inspeção, seguro e carta de condução.
- Receber avisos antes dos prazos.
- Registar rendimentos e despesas.
- Guardar dados do carro, combustível, revisões e lembretes.
- Ver postos de combustível e centros de inspeção perto de ti, se deres permissão de localização.
- Juntar fotos de comprovativos e faturas que escolhas no telemóvel.
- Ler fotos de extratos ou documentos pela app, quando o plano permitir.
- Fazer perguntas ao assistente em português simples.
- Criar uma prova de rendimento em PDF com base nos dados que escreveste.

O Em Dia não é banco, não faz empréstimos, não faz transferências entre pessoas e não substitui o teu contabilista. Dá informação geral e ajuda-te a chegar aos prazos com calma.

Tens 30 dias grátis. Depois podes continuar com o plano grátis ou escolher uma assinatura pela Google Play.
```

Texto sobre preço:
```text
30 dias grátis. Depois, plano grátis com limites ou assinatura pela Google Play.
```

### pt-BR

Nome da app:
```text
Em Dia: Impostos em Portugal
```

Descrição curta:
```text
Recibos verdes, Segurança Social, IVA e IRS de Portugal em um só app.
```

Descrição longa:
```text
Em Dia é o assistente do trabalhador independente em Portugal. Serve para motoristas TVDE, entregadores, freelancers, prestadores de serviço e brasileiros que chegaram há pouco e querem entender os recibos verdes.

O app ajuda você a saber o que entra, o que precisa guardar e qual prazo vem depois.

O que você pode fazer:

- Calcular recibos verdes com retenção, IVA e o valor que fica para você.
- Ver quanto guardar para Segurança Social, IRS e IVA.
- Montar um calendário com prazos da Segurança Social, IVA, IRS, IUC, inspeção, seguro e carteira de motorista.
- Receber avisos antes dos prazos.
- Registrar rendimentos e despesas.
- Guardar dados do carro, combustível, revisões e lembretes.
- Ver postos de combustível e centros de inspeção perto de você, se der permissão de localização.
- Juntar fotos de comprovantes e faturas que você escolher no celular.
- Ler fotos de extratos ou documentos pelo app, quando o plano permitir.
- Fazer perguntas ao assistente em português simples.
- Criar uma prova de rendimento em PDF com base nos dados que você escreveu.

O Em Dia não é banco, não faz empréstimos, não faz transferências entre pessoas e não substitui o seu contador. Ele dá informação geral e ajuda você a chegar aos prazos com calma.

Você tem 30 dias grátis. Depois pode continuar no plano grátis ou escolher uma assinatura pela Google Play.
```

Texto sobre preço:
```text
30 dias grátis. Depois, plano grátis com limites ou assinatura pela Google Play.
```

Porquê: os textos seguem a função real vista no site e no código, sem prometer números de utilizadores, prémios ou substituição de contabilista.

## Categoria e etiquetas

Caminho na consola: Crescimento > Presença na loja > Definições da loja > Categoria da app e etiquetas.

Tipo:
```text
Aplicação
```

Categoria:
```text
Finanças
```

Porquê: a app organiza dinheiro, impostos, rendimentos, despesas e assinaturas; não é jogo, notícia, saúde nem rede social.

Etiquetas:
```text
POR CONFIRMAR na lista da Play: Finanças pessoais
POR CONFIRMAR na lista da Play: Impostos
POR CONFIRMAR na lista da Play: Faturação
POR CONFIRMAR na lista da Play: Orçamento
POR CONFIRMAR na lista da Play: Contabilidade
```

Porquê: a lista exata de etiquetas da Play não está nesta cópia. Estas são as mais próximas da função da app, mas devem ser escolhidas apenas se aparecerem na consola.

## Detalhes de contacto

Caminho na consola: Crescimento > Presença na loja > Definições da loja > Detalhes de contacto.

Email:
```text
emdia@boraguarda.com
```

Site:
```text
https://emdia.boraguarda.com
```

Telefone:
```text
Não preencher
```

Porquê: o site e a política de privacidade usam este contacto por email; não há telefone público indicado.

## Política de privacidade

Caminho na consola: Política > Conteúdo da app > Política de privacidade.

URL:
```text
https://emdia.boraguarda.com/privacidade
```

Porquê: é a página pública que explica dados, compras, apagamento de conta e contacto.

## Acesso à app

Caminho na consola: Política > Conteúdo da app > Acesso à app.

Resposta:
```text
A app pede entrada por email com código, sem palavra-passe, e também pode mostrar Google Sign-In se a build tiver essa opção configurada.

Use a conta de teste boraappbora+teste@gmail.com.

Como o revisor não tem acesso à caixa de correio para receber o código, há dois caminhos:

1. No ecrã de entrada, toque em "Vê como fica, com um exemplo". Este modo não precisa de conta e mostra a app preenchida com dados de exemplo. Todas as áreas principais podem ser vistas por esse caminho.

2. POR CONFIRMAR na build enviada: se `EMAIL_REVISOR` estiver configurado para boraappbora+teste@gmail.com, o ecrã troca o código por um campo de palavra-passe só para esse email. A credencial deve ser criada na Play Console como credencial de revisor. A palavra-passe não está dentro da app.

POR CONFIRMAR: se for decidido ter código fixo para este email de teste, isso tem de ficar no servidor antes de submeter. Não está confirmado nesta cópia.
```

Porquê: o código confirma o botão de exemplo sem conta e confirma o caminho especial do revisor por `EMAIL_REVISOR`, mas não há palavra-passe ou código fixo no repositório.

## Anúncios

Caminho na consola: Política > Conteúdo da app > Anúncios.

Resposta:
```text
Não, a app não contém anúncios.
```

Porquê: não há código de anúncios encontrado e a política diz que os dados não são vendidos nem cedidos para publicidade.

## Classificação de conteúdo

Caminho na consola: Política > Conteúdo da app > Classificação de conteúdo.

Categoria IARC:
```text
Utilitário, produtividade, comunicação ou outro
```

Respostas:
```text
Violência: Não
Sexo ou nudez: Não
Linguagem ofensiva: Não
Drogas, álcool ou tabaco: Não
Jogo: Não
Conteúdo gerado por utilizadores: Sim, a pessoa escreve perguntas ao assistente e pedidos de ajuda, mas não há publicação pública nem rede social.
Compras digitais: Sim, assinaturas pela Google Play.
Partilha localização: Sim. A app pede localização em primeiro plano para mostrar combustível e centros de inspeção perto de mim. Não guarda a localização e também permite escrever o concelho.
Resultado esperado: PEGI 3.
```

Porquê: a app tem compras digitais e usa localização aproximada em primeiro plano; não tem violência, sexo, jogo ou drogas.

## Público-alvo e conteúdo

Caminho na consola: Política > Conteúdo da app > Público-alvo e conteúdo.

Resposta:
```text
Faixa etária alvo: 18 anos ou mais.
A app não é feita para crianças.
Não há apelo a crianças.
Não aderir ao programa Para famílias.
```

Porquê: é uma app para trabalhadores independentes que emitem recibos, pagam impostos e gerem carro de trabalho.

## Notícias, COVID e apps governamentais

Caminho na consola: Política > Conteúdo da app.

Apps de notícias:
```text
Não
```

Apps de rastreio de contactos COVID:
```text
Não
```

Apps governamentais:
```text
Não
```

Porquê: a app usa informação pública e regras legais, mas não representa o Estado, a Segurança Social, a Autoridade Tributária ou o IMT.

## Funcionalidades financeiras

Caminho na consola: Política > Conteúdo da app > Funcionalidades financeiras.

Resposta:
```text
A app tem gestão de finanças pessoais, impostos e rendimentos de trabalhador independente.

Não é banco.
Não dá crédito nem empréstimos.
Não faz pagamentos entre pessoas.
Não compra nem vende produtos financeiros.
Não gere investimentos.
A única compra dentro da app é a assinatura pela Google Play.
```

Porquê: o código de compras usa Google Play Billing para assinaturas; não há serviços bancários ou crédito.

## Saúde

Caminho na consola: Política > Conteúdo da app > Saúde.

Resposta:
```text
Não tem funcionalidades de saúde.
Não recolhe dados de saúde ou fitness.
```

## Segurança dos dados

Caminho na consola: Política > Segurança dos dados.

Respostas gerais:
```text
Recolhe dados do utilizador: Sim
Todos os dados recolhidos são encriptados em trânsito: Sim
O utilizador pode pedir eliminação dos dados: Sim
URL de eliminação: https://emdia.boraguarda.com/apagar-conta
Vende dados: Não
Partilha dados para publicidade: Não
Validação independente de segurança: Não
```

Métodos de conta:
```text
Email com código.
Google Sign-In, se configurado na build.
POR CONFIRMAR na build final: conta de revisor por palavra-passe apenas para o email configurado em `EMAIL_REVISOR`.
```

### Dados pessoais

Nome:
```text
Recolhido: Sim, quando a pessoa escreve o nome no perfil ou na prova de rendimento.
Obrigatório: Não para abrir a app; pode ser necessário para algumas funções como a prova de rendimento.
Partilhado: Não.
Finalidade: funcionalidade da app e gestão da conta.
```

Email:
```text
Recolhido: Sim.
Obrigatório: Sim, para entrar e gerir a conta.
Partilhado: Não para publicidade. Pode passar pelos serviços de autenticação e email usados para enviar o código.
Finalidade: funcionalidade da app, autenticação, segurança e gestão da conta.
```

IDs de utilizador:
```text
Recolhido: Sim.
Obrigatório: Sim.
Partilhado: Não para publicidade.
Finalidade: ligar os dados à conta certa, segurança e gestão da conta.
```

Outras informações pessoais:
```text
Recolhido: Sim. Inclui tipo de atividade, data de início de atividade, dados do carro e NIF se a pessoa o escrever na prova de rendimento.
Obrigatório: Parte é necessária para calcular prazos; NIF é opcional.
Partilhado: Não.
Finalidade: funcionalidade da app.
```

### Informação financeira

Histórico de compras:
```text
Recolhido: Sim, comprovativo técnico da assinatura e estado do plano.
Obrigatório: Sim para planos pagos.
Partilhado: A compra é tratada pela Google Play. A app não vê cartão.
Finalidade: funcionalidade da app e gestão da conta.
```

Outras informações financeiras:
```text
Recolhido: Sim. Inclui rendimentos, despesas, recibos, valores de impostos, extratos importados de ficheiro ou foto, fotos de faturas e comprovativos.
Obrigatório: Necessário para as funções que calculam prazos, valores e relatórios; a pessoa escolhe o que escreve ou envia.
Partilhado: Não para publicidade.
Finalidade: funcionalidade da app.
```

### Localização

Localização aproximada:
```text
Recolhido: Sim, apenas quando a pessoa toca em usar localização para "perto de mim".
Obrigatório: Não. A pessoa pode escrever o concelho.
Partilhado: Não para publicidade.
Finalidade: mostrar postos de combustível e centros de inspeção perto.
Observação: o código usa precisão baixa, em primeiro plano, e diz que não guarda a localização.
```

Localização exata:
```text
POR CONFIRMAR na consola. O código chama `getCurrentPosition` com precisão baixa, mas a permissão Android pode aparecer como localização do dispositivo. Se a Play separar por uso real, declarar aproximada; se exigir pelo tipo de permissão, rever antes de submeter.
```

### Fotos e vídeos

Fotos:
```text
Recolhido: Sim.
Obrigatório: Não.
Partilhado: Não para publicidade.
Finalidade: guardar comprovativos, ler faturas, talões ou extratos escolhidos pela pessoa.
Observação: no Android usa Photo Picker; a app só vê a foto escolhida, não a galeria toda.
```

Vídeos:
```text
Não.
```

### Mensagens e conteúdo escrito

Outras mensagens na app:
```text
Recolhido: Sim. Inclui perguntas ao assistente e pedidos de suporte.
Obrigatório: Não.
Partilhado: Não para publicidade.
Finalidade: responder à pessoa, manter histórico e apoio ao cliente.
```

Outro conteúdo gerado pelo utilizador:
```text
Recolhido: Sim. Inclui textos, notas, dados de rendimentos, despesas e pedidos de ajuda que a pessoa escreve.
Obrigatório: Necessário apenas para as funções onde a pessoa decide escrever esses dados.
Partilhado: Não para publicidade.
Finalidade: funcionalidade da app e apoio.
```

### Ficheiros e documentos

Ficheiros e documentos:
```text
Recolhido: Sim, quando a pessoa escolhe ficheiros, extratos, fotos de documentos ou gera documentos na app.
Obrigatório: Não.
Partilhado: Não para publicidade.
Finalidade: ler documentos, guardar comprovativos e criar prova de rendimento.
```

### Dispositivo e informação técnica

IDs do dispositivo:
```text
Recolhido: Sim. Inclui token do Firebase Messaging para avisos.
Obrigatório: Não; se a pessoa não aceitar notificações, a app funciona sem push.
Partilhado: Passa pelo Firebase Cloud Messaging para entregar notificações.
Finalidade: funcionalidade da app.
```

Desempenho e informação da app:
```text
Recolhido: Sim, se a pessoa enviar pedido de suporte com dados técnicos ou se ligar estatísticas nas Definições.
Obrigatório: Não.
Partilhado: Não para publicidade.
Finalidade: apoio, diagnóstico e melhoria da app com consentimento.
```

Atividade na app:
```text
Recolhido: Sim, apenas se a pessoa ligar estatísticas nas Definições. O código guarda eventos simples: abrir a app, acabar o início, ver plano, iniciar compra, comprar e cancelar.
Obrigatório: Não.
Partilhado: Não para publicidade.
Finalidade: análise com consentimento.
```

### O que muda face ao que estava declarado

Como os ficheiros de prova antigos não existem nesta cópia, comparei com `docs/loja/play/data-safety-em-dia.csv` e com o código atual.

Mudanças a rever na consola:
```text
Adicionar Localização aproximada: o código confirma uso em primeiro plano para "perto de mim".
Garantir Fotos: já estava no CSV atual e está confirmado no código.
Garantir Histórico de compras: já está no CSV atual e está confirmado pelo Google Play Billing.
Garantir Outras informações financeiras: já está no CSV atual e é central para a app.
Adicionar ou confirmar Outras mensagens na app: perguntas ao assistente e pedidos de suporte ficam em tabelas do servidor.
Adicionar ou confirmar Ficheiros e documentos: a app pode ler documentos/fotos e guardar comprovativos.
Confirmar Desempenho/informação técnica e Atividade na app: só se a pessoa enviar suporte ou ligar estatísticas.
Trocar URL de eliminação para https://emdia.boraguarda.com/apagar-conta, como pedido nesta tarefa.
```

## Notas para a revisão

Caminho na consola: Publicação > Revisão > Notas para a revisão.

Texto para colar:
```text
O Em Dia é uma app para trabalhadores independentes em Portugal gerirem recibos verdes, impostos, prazos e carro.
A app não é governamental, não é banco, não dá empréstimos e não faz pagamentos entre pessoas.
A entrada normal é por email com código, sem palavra-passe.
Para rever sem email, toque em "Vê como fica, com um exemplo" no ecrã de entrada; esse modo mostra a app preenchida e não precisa de conta.
Conta de teste sugerida: boraappbora+teste@gmail.com.
POR CONFIRMAR na build enviada: se `EMAIL_REVISOR` estiver configurado para essa conta, o ecrã mostra palavra-passe em vez de código; a credencial deve ser criada na Play Console.
A app usa localização só em primeiro plano para mostrar combustível e centros de inspeção perto, e também permite escrever o concelho.
As compras são apenas assinaturas pela Google Play.
```

## Produtos de subscrição

Caminho na consola: Monetização > Produtos > Subscrições.

Produto `pro_mensal`:
```text
Nome: Em Dia Pro mensal
Descrição: Avisos sem limites, perguntas ao assistente, leitura de fotos, comprovativos e exportações para te organizares melhor.
```

Produto `pro_anual`:
```text
Nome: Em Dia Pro anual
Descrição: As funções Pro durante um ano: avisos, perguntas, leitura de fotos, comprovativos e exportações, sem escrever preços aqui.
```

Produto `familia_mensal`:
```text
Nome: Em Dia Família mensal
Descrição: Para acompanhar até 5 pessoas e até 5 carros na mesma conta, com as funções Pro incluídas.
```

Produto `familia_anual`:
```text
Nome: Em Dia Família anual
Descrição: Plano anual para família ou pequena frota: até 5 pessoas, até 5 carros e funções Pro incluídas.
```

Porquê: os IDs existem no código de compras e não há preços escritos aqui, como pedido.
