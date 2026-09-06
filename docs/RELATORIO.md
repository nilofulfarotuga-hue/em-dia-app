# RELATÓRIO — Em Dia

Missão `em-dia-missao-total-2026-09-05`. Começou às 22h20 de sexta, 5 de setembro. Este relatório vai até à noite de sábado, 6 de setembro. É para ser lido em voz alta, por isso está escrito corrido, sem tabelas.

---

## Primeiro, o que NÃO está feito

A app ainda não está publicada na loja para toda a gente. Está no teste interno, que é o passo antes disso. Para ir para a loja a sério faltam declarações do formulário da Google. A da segurança dos dados está escrita e a Google já a lê e valida, mas encravou numa pergunta que o modelo público dela não tem e cujos códigos de resposta a Google não publica em lado nenhum — testei vinte hipóteses contra a API e a Google recusou-as todas, e não invento uma. Resolve-se com um clique teu: exportar o ficheiro da consola. As outras três — classificação de conteúdo, público-alvo e como é que o revisor entra na app — não existem na API da Google, só no formulário da consola, por isso precisam de uma janela com browser aberta.

As quatro assinaturas não foram criadas. A Google recusou, e a resposta dela foi esta, tal e qual: não é possível criar uma subscrição sem primeiro registar um perfil de pagamentos na conta de programador. Esse perfil pede dados fiscais, morada e conta bancária. É teu.

Não houve push a chegar ao teu telemóvel. O projeto do Firebase espera que aceites os termos, e isso é um clique teu. Até lá, os avisos são calculados e ficam gravados na base de dados com a marca de que não houve envio.

Não gravei o vídeo do fluxo completo na app instalada, porque o telemóvel nunca esteve ligado por cabo. Assim que o ligares, faço.

E o domínio emdia.pt já é de outra empresa. O em-dia.pt está livre, mas comprar é pagamento teu.

---

## O que se arranjou no sábado, depois de tu experimentares

Disseste que não dava para entrar com o e-mail, e que o ecrã ficava preso. Estavas certo, e não era uma coisa só: eram três.

A primeira, e a que te travava mesmo: o servidor mandava um código de **oito** números e o campo da app só deixava escrever **seis**. Nunca ias conseguir entrar. Tenho o e-mail das dez e cinquenta e nove guardado, com o código de oito números, como prova.

A segunda: quando voltavas atrás para pedir outro código, o servidor recusa durante um minuto — e a app dizia apenas "não consegui entrar, vê se o e-mail está certo". Parecia que tinhas escrito o e-mail mal. Agora cada erro tem a sua frase, e um relógio diz quantos segundos faltam.

A terceira só apareceu porque entrei mesmo na app, como uma pessoa qualquer: depois do login, se a conta não abrisse, ficava um símbolo a rodar para sempre e não havia por onde sair. Era a mesma cicatriz do Bora. Agora desiste ao fim de vinte segundos e mostra dois botões: tentar outra vez, e sair.

Ainda a entrar a sério, apanhei uma quarta coisa que nada tinha que ver com o login: o painel anunciava "próximo prazo: daqui a trezentos e quarenta e oito dias" quando o próximo prazo era dia vinte desse mesmo mês. A culpa era de uma armadilha do Supabase — quando se pede uma lista "por ordem", ele devolve-a ao contrário se não lhe disserem o contrário. Isso estragava também a ordem dos guias, dos carros e de quatro tabelas do painel de administração. Está tudo corrigido, e há um teste que reprova quem voltar a cair nisso.

Tudo isto foi provado a entrar de verdade no browser: pedi o código, escrevi os seis números, entrou, fiz as cinco perguntas do início e cheguei ao painel.

## Uma auditoria de segurança que valeu a pena

À noite passei a base de dados a pente fino com a ferramenta do próprio Supabase, e confirmei cada aviso com um pedido a sério — não acreditei em nenhum só porque um programa o disse.

Encontrei duas portas abertas. A pior: qualquer pessoa com conta na app conseguia ler quanto a inteligência artificial nos custou e quantas conversas houve na plataforma toda. Entrei com uma conta normal de teste e recebi o número. Isso é informação do negócio e agora só o teu painel a vê — confirmei que continua a ver.

A segunda: sem sessão nenhuma, bastava saber o número de conta de outra pessoa para descobrir que plano ela tinha. Agora responde "não tens permissão".

Ficaram treze avisos por fechar, e cada um está explicado um a um no ficheiro de prova — nenhum é um buraco. Há também sessenta e seis avisos de desempenho que **não** toquei de propósito: são reescritas de regras de acesso, e uma regra de acesso mal escrita não fica lenta, fica aberta. Isso faz-se contigo acordado. A proposta já está escrita e verificada, à espera.

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

Estão todas escritas com detalhe no ficheiro PENDENTE-DANILO. As que valem mais são estas:

A primeira é aceitar os termos do Firebase. É um visto e um botão. Sem isso não há avisos no telemóvel.

A segunda é o perfil de pagamentos na Play. Sem ele não há assinaturas, e sem assinaturas não há receita. Assim que estiver, eu crio os quatro produtos com um comando que já está escrito e ensaiado, com os preços que tu escolheste.

A terceira é dizer-me como queres que o revisor da Google entre na app. Hoje a entrada é por código enviado ao e-mail, e o revisor não tem acesso a esse e-mail. Ou faço uma entrada por palavra-passe só para a conta de revisão, ou ligo o "entrar com Google". As duas estão prontas a fazer, é escolheres.

A quarta é o aviso do Supabase, que diz que o período de carência terminou e que os projetos podem parar de responder quando atingirem a cota. Isso afeta esta app e o Bora.

A quinta apareceu no sábado à noite e é um clique: na consola da Play, exportar o ficheiro da segurança dos dados. Com ele fecho essa declaração com um comando.

A sexta também é um clique, e é a que mais me solta as mãos: criar um token de acesso do Supabase e guardá-lo na pasta dos segredos. Sem ele não consigo pôr no servidor as correções das funções — está uma à espera, que faz o assistente trocar de modelo quando a Google diz que está cheia, em vez de responder com um erro.

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
