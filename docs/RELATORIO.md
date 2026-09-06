# RELATÓRIO — Em Dia

Missão `em-dia-missao-total-2026-09-05`. Começou às 22h20 de sexta, 5 de setembro. Este relatório fecha no sábado, 6 de setembro, à tarde. É para ser lido em voz alta, por isso está escrito corrido, sem tabelas.

---

## Primeiro, o que NÃO está feito

A app ainda não está publicada na loja para toda a gente. Está no teste interno, que é o passo antes disso. Para ir para a loja a sério faltam quatro declarações do formulário da Google (segurança dos dados, classificação de conteúdo, público-alvo e como é que o revisor entra na app) e a resposta a uma coisa que só tu podes decidir.

As quatro assinaturas não foram criadas. A Google recusou, e a resposta dela foi esta, tal e qual: não é possível criar uma subscrição sem primeiro registar um perfil de pagamentos na conta de programador. Esse perfil pede dados fiscais, morada e conta bancária. É teu.

Não houve push a chegar ao teu telemóvel. O projeto do Firebase espera que aceites os termos, e isso é um clique teu. Até lá, os avisos são calculados e ficam gravados na base de dados com a marca de que não houve envio.

Não gravei o vídeo do fluxo completo na app instalada, porque o telemóvel nunca esteve ligado por cabo. Assim que o ligares, faço.

E o domínio emdia.pt já é de outra empresa. O em-dia.pt está livre, mas comprar é pagamento teu.

---

## O que está feito, e como se prova

**A app existe e está no teu telemóvel a um clique.** O link para instalares é este: play.google.com/apps/internaltest/4701441008721807578. Foi a Google que o deu, depois de eu ter enviado a aplicação para o teste interno. A versão que lá está é a 1.0.0, com sessenta megabytes, assinada com uma chave nova só desta app.

**A ficha da loja está lá.** Chama-se "Em Dia: Recibos e Impostos", com a frase curta e o texto longo em português de Portugal e do Brasil. Tem o ícone, a imagem grande de destaque e oito fotografias. As fotografias não são maquetes: são fotos verdadeiras dos ecrãs da app, tiradas pela máquina de testes, com uma frase escrita por cima de cada uma.

**A app tem dez ecrãs feitos**, do onboarding ao assistente. São trinta e cinco ficheiros de ecrã. Cada um foi fotografado em três tamanhos de telemóvel, com e sem teclado, em português de Portugal e do Brasil: duzentas e setenta e três fotografias no total, e cinquenta e cinco testes que falham se algum texto sair do ecrã. Correm todos verdes.

**As regras da lei não estão no código.** Vivem numa tabela da base de dados, cada uma com a fonte oficial e a data em que foi verificada. São sessenta e seis. Sete estão marcadas como por confirmar, e a app e o assistente dizem isso em voz alta em vez de inventar. Quarenta e sete casos de teste verificam as contas: a calculadora do recibo, a vigia dos quinze mil euros, a Segurança Social com o mínimo e o tecto, o IRS por escalões, a inspeção do carro aos quatro, seis e oito anos, o imposto do carro no mês da matrícula, e os prazos que caem ao domingo e passam para a sexta.

**O servidor faz seis trabalhos sozinho**: monta o calendário de obrigações a partir do teu perfil, manda os avisos às nove da manhã de Lisboa, responde às perguntas com inteligência artificial, lê a foto de um extrato da Uber ou da Glovo, trata do suporte e valida as compras. Cada um foi escrito por um agente e depois derrubado por outro, com contexto limpo, que tentou provar que estava errado. Dois foram corrigidos por causa disso.

**O assistente responde de verdade.** As trinta perguntas que preparei foram feitas à app e as respostas estão guardadas uma a uma. Cita a regra certa, dá o prazo certo e acaba sempre a dizer qual é o próximo passo.

**O site está no ar** em em-dia-site.pages.dev, com a calculadora do recibo verde aberta a quem chega da Google, sem precisar de instalar nada. Cinquenta e sete verificações automáticas passam, zero falham — e não é a palavra "passou": são cinquenta e sete afirmações contadas, incluindo contas feitas no browser e comparadas com os casos de teste.

**A app também corre no browser**, em app-em-dia.pages.dev, que é o caminho para iPhone e computador. O painel de administração está em em-dia-admin.pages.dev, em português do Brasil, com sete secções.

**A fábrica de compilação funciona sozinha.** Cada vez que envio código, o GitHub compila o Android, publica a web e corre a máquina de fotografias. Está verde nos três. O número da versão é ele que incrementa; eu nunca lhe toco.

**Não há uma única chave escrita no código.** Estão todas guardadas fora, em segredos do GitHub e no cofre da base de dados.

---

## Uma coisa que quase passou despercebida

Durante a noite, a suíte de fotografias falhava sempre exactamente um teste — mas nunca o mesmo. Ora o calendário, ora o onboarding, ora os recibos. Cada um deles, corrido sozinho, passava. Tentei três explicações erradas: que era falta de memória, que era demasiada coisa ao mesmo tempo, que era falta de tempo. Nenhuma era.

A verdadeira causa era um erro de compilação num ficheiro do painel de administração. Como esse ficheiro não compilava, a máquina de testes marcava a falha na linha do teste seguinte — e o teste seguinte era diferente de cada vez. Uma linha corrigida e passaram os cinquenta e cinco. Ficou escrito no projeto para não voltar a enganar ninguém.

---

## O que preciso de ti

São doze coisas, e estão todas escritas com detalhe no ficheiro PENDENTE-DANILO. As quatro que valem mais são estas:

A primeira é aceitar os termos do Firebase. É um visto e um botão. Sem isso não há avisos no telemóvel.

A segunda é o perfil de pagamentos na Play. Sem ele não há assinaturas, e sem assinaturas não há receita. Assim que estiver, eu crio os quatro produtos com um comando que já está escrito e ensaiado, com os preços que tu escolheste.

A terceira é dizer-me como queres que o revisor da Google entre na app. Hoje a entrada é por código enviado ao e-mail, e o revisor não tem acesso a esse e-mail. Ou faço uma entrada por palavra-passe só para a conta de revisão, ou ligo o "entrar com Google". As duas estão prontas a fazer, é escolheres.

A quarta é o aviso do Supabase, que diz que o período de carência terminou e que os projetos podem parar de responder quando atingirem a cota. Isso afeta esta app e o Bora.

---

## Links

- Instalar no telemóvel: https://play.google.com/apps/internaltest/4701441008721807578
- Site: https://em-dia-site.pages.dev
- A app no browser: https://app-em-dia.pages.dev
- Painel de administração: https://em-dia-admin.pages.dev
- Código: https://github.com/nilofulfarotuga-hue/em-dia-app
- Play Console: https://play.google.com/console/u/0/developers/5372142912736686834/app/4973228433822861554/app-dashboard

---

## Custos

Zero. Não comprei domínio nem paguei nada. Tudo o que custa dinheiro ficou à tua espera.

---

## Decisões que tomei sozinho

Estão as treze escritas no ficheiro DECISOES, cada uma com o porquê e como se desfaz. As três que mais mudam as coisas: o repositório ficou público, como o do Bora, porque assim a compilação não gasta a quota de minutos; a entrada na app é por código no e-mail e não por SMS, porque o SMS obriga a um fornecedor pago; e a lógica das obrigações existe duas vezes, em Dart e no servidor, validada pelos mesmos quarenta e sete casos, para o onboarding poder mostrar-te o calendário sem esperar pela internet.

---

## Números

Vinte e dois envios de código. Trinta e cinco ficheiros de ecrã. Duzentas e setenta e três fotografias. Cinquenta e cinco testes de ecrã e quarenta e sete de regras, todos verdes. Oito alterações à base de dados. Seis funções no servidor. Onze guias escritos em português de Portugal e do Brasil. Trinta perguntas provadas ao assistente. Vinte publicações prontas para as redes, cinco anúncios, um calendário de trinta dias e três guiões de vídeo.
