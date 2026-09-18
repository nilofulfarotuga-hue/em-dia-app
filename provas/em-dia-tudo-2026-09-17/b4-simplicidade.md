# BLOCO 4 — Onboarding e simplicidade (2026-09-18)

> Missão `em-dia-tudo-2026-09-17`. Ordem: «só perguntar o que a app não descobre sozinha, uma pergunta por
> ecrã, «posso mudar depois» em todas; juiz de ecrãs com a pergunta **«uma pessoa que nunca usou uma app
> destas percebe o que fazer aqui?»** e a resposta literal por ecrã; botão Ouvir em todos os ecrãs; botão
> para a página certa em cada obrigação». Parte 1 no commit `018737f`; parte 2 (o que o juiz apontou) aqui.

## O que ficou feito

**Parte 1 (commit `018737f`):** botão «Ouvir» em todos os ecrãs (onboarding, login, Mais, perto de mim, recibo de
vencimento, empresa, passar fatura…); «Podes mudar depois» em todas as perguntas do onboarding; nome, ícone, grupo e
site certo para os 9 tipos de obrigação novos (`tipos_obrigacao.dart`); o juiz de simplicidade em
`tool/juiz/vision_judge.py --modo simplicidade` (pergunta fixa, resposta em JSON `{percebe, resposta, palavras_dificeis, melhoria}`).

**Parte 2 (este commit):**

1. **O juiz correu nas 111 fotos `_medio_pt`.** A primeira corrida (11:52) deixou 49 fotos em erro: 47 porque
   `gemini-2.5-flash-lite` devolve 404 «no longer available to new users» (não é «not found», e o juiz só rodava
   nesse) e 2 por timeout. Corrigido (D67: qualquer 404/429/timeout roda; `--retomar` julga só os erros) e retomado
   às 14:07 — **111 fotos, 0 erros: {'verde': 46, 'amarelo': 60, 'vermelho': 5, 'erro': 0}** (verde = sim, amarelo = quase, vermelho = não).
2. **Os 5 vermelhos corrigidos:**
   - `painel_skeleton`, `cofre_a_carregar`, `vida_sobra_carregar` — «ecrã vazio, sem instrução»: os esqueletos passam a
     dizer por palavras «A carregar as tuas contas… só demora um segundo.» (`LinhaACarregar`, D65).
   - `mais` — «nomes abstratos sem a função prática»: cada acesso ganhou uma linha simples («Prova de rendimento — Um
     papel que diz quanto ganhas», «Fim da fidelização — Quando podes trocar de operadora», «Reforma e direitos — O que a
     Segurança Social te dá um dia»…) (D66).
   - `recibos_empresa` — «termos técnicos e sem botões de ação em cada item»: as 4 datas do calendário passaram a
     abrir o detalhe (como pagar + site) com a nota «Toca numa data para ver como se paga e onde», e o ecrã tem o
     botão das palavras difíceis (NIPC, IRC, SAF-T, DMR, IES, IVA…).
3. **A causa comum dos 60 «quase» — jargão sem explicação** (IRS 17×, Segurança Social 14×, IVA 13×, TVDE 8×, IUC 5×,
   NIF, DGEG, IMT, CAE, NISS, ENI, NIPC, Lda., retenção, anexo B, trimestre…): botão **«O que é isto?»**
   (`BotaoPalavras`) em 20 ecrãs e 9 passos do onboarding, que abre a folha «Palavras difíceis» com as palavras
   desse ecrã explicadas em linguagem de criança de 5 anos, cada uma com Ouvir (glossário de 41 palavras em
   `lib/l10n/partes/glossario_*.arb`, PT-PT por «tu» e PT-BR por «você»; D64). Teste S01 garante que nenhuma
   palavra pedida por um ecrã falta no glossário; o teste J01 (jargão) continua verde.
4. **Pequenos arranjos que o juiz pediu e cabiam:** «Fazer conta com esta» → «Registar como despesa» (caixa das
   faturas, 2 ecrãs); frase por baixo de «Separei»/«Tirei» no cofre; botão «Tentar outra vez» no erro do radar;
   pega + botão «Fechar» na folha das palavras difíceis.
5. **Pedidos do juiz que NÃO se fizeram, e porquê:** «ícone de carregamento animado» (regra da casa: nunca roda a
   girar; e uma animação infinita prende o `pumpAndSettle` dos testes); «barra de pesquisa no Mais» (12 tiles não
   precisam de pesquisa); «botão para gerar a referência Multibanco» (a referência é do Estado, não da app — o
   botão que existe abre o site certo); «tornar o microfone cinzento no limite» e «instrução de manter premido»
   já existiam (`ativo: podeFalar`, texto «Larga o dedo, ou toca outra vez»); «texto cortado no topo» na caixa das
   faturas é a foto rolada de propósito para mostrar a lista, não um corte real. Ficam na lista para uma volta seguinte:
   «Marcar como pago» em cada linha da agenda; partilhar o endereço da caixa por WhatsApp; exemplo visual de onde
   está a data de início de atividade.

## Segunda corrida do juiz, nos 27 ecrãs mexidos (14:30)

Contagem: **{'verde': 3, 'amarelo': 24, 'vermelho': 0, 'erro': 0}** — os 5 vermelhos desapareceram; 3 verdes; o resto continua «quase» porque o
modelo vê um «?» no canto e não sabe que abre as explicações — e porque sugere sempre mais um botão. Antes → depois:

| Ecrã | Antes | Depois | Palavras que ainda aponta | O que ainda sugere |
|---|---|---|---|---|
| `caixa_faturas` | quase | quase | — | Clarificar a diferença entre as opções «Já não preciso» e «Apagar de vez» para evitar hesitações. |
| `calendario` | quase | quase | IVA, IRS, Segurança Social | Adicionar uma breve explicação a indicar se a aplicação serve apenas para lembretes ou se permite efetuar os pagamentos diretamente. |
| `carro_despesas` | quase | quase | NIF, IRS, DGEG, IMT | Adicionar uma breve explicação inicial a indicar se as faturas com NIF entram aqui de forma automática. |
| `carro` | quase | quase | TVDE, IUC | Adicionar botões explícitos de ação em cada lembrete, como 'Pagar' ou 'Ver detalhes', para orientar o utilizador. |
| `cofre_a_carregar` | NÃO | quase | — | Adicionar um botão para re Tentar ou cancelar caso o carregamento demore demasiado tempo. |
| `cofre_chega` | quase | quase | Segurança Social, IRS, contabilidade | Adicionar uma breve instrução no topo a indicar claramente qual deve ser a primeira acção do utilizador. |
| `cofre_vazio` | quase | quase | IRS, Segurança Social, contabilidade | Adicionar um pequeno exemplo prático de quanto reter por cada ganho para ajudar quem não percebe de impostos. |
| `fala_com_resposta` | quase | quase | IVA, Segurança Social, trimestre | Adicionar um botão de ação rápida por baixo do texto, como "Ver referências para pagamento". |
| `guias` | quase | quase | CAE, IVA, art. 53.º, Retenção na fonte, anexo B, mínimo de existência, TVDE | Adicionar uma pergunta inicial no topo como 'Qual é a tua dúvida hoje?' para guiar o utilizador diretamente para o guia certo. |
| `horas_extra` | quase | quase | proporcional, art. 238.º | Adicionar uma breve explicação em linguagem simples sobre o que significa um subsídio ser proporcional. |
| `ia` | quase | quase | IRS, Segurança Social, IVA | Adicionar um botão direto para simular a criação automática dessa pouparça numa conta separada. |
| `mais` | NÃO | quase | fidelização, Segurança Social | Adicionar uma barra de pesquisa no topo para que o utilizador possa escrever o que procura em vez de navegar por todos os cartões. |
| `onboarding_empresa` | quase | quase | ENI, NIF, Lda., unipessoal, NIPC | Adicionar exemplos práticos mais claros debaixo de cada opção para ajudar quem não conhece estes termos fiscais. |
| `onboarding_p2_abertura` | quase | quase | Portal das Finanças, abriste atividade, Segurança Social | Adicionar um pequeno exemplo visual ou link de ajuda a indicar onde encontrar a data exata no documento oficial. |
| `painel_skeleton` | NÃO | quase | — | Adicionar um ícone de carregamento animado mais explícito para confirmar que a aplicação não está bloqueada. |
| `palavras_dificeis_guias_pequeno_pt` | — (novo) | sim | CAE, IVA, IRS | Adicionar uma barra de pesquisa no topo para encontrar termos rapidamente. |
| `palavras_dificeis` | — (novo) | quase | — | Adicionar um botão evidente para fechar o ecrã e regressar ao menu anterior. |
| `plano` | quase | quase | Pro, extratos, folha de cálculo, Reforma | Adicionar uma pequena nota explicativa sobre o que acontece ao plano gratuito após o período experimental para reduzir o receio de cobranças inesperadas. |
| `prova_vazia` | quase | quase | NIF | Adicionar um botão 'Ir para Dinheiro' diretamente no centro do ecrã para facilitar a navegação imediata. |
| `radar_erro` | quase | sim | — | Adicionar uma pequena mensagem a sugerir verificar a ligação à internet caso o erro persista após várias tentativas. |
| `recibos_contrato` | quase | quase | IRS, NIF, IVA, e-fatura | Adicionar um botão de ação principal ou um checklist de tarefas pendentes para guiar o utilizador sobre o que deve fazer na app em vez de apenas o enviar para sites externos. |
| `recibos_empresa` | NÃO | quase | NIPC, IRC, IVA, Declaração Mensal de Remunerações, AT | Adicionar um botão de 'Como fazer' ou 'Resolver' dentro de cada item da lista que abra um guia passo-a-passo simples ou um link direto para o portal das Finanças. |
| `recibos` | quase | quase | IVA, Retenção na fonte, art. 53.º | Adicionar um pequeno botão de ajuda ou 'tooltip' junto a cada opção que explique, em linguagem simples, em que casos se deve escolher cada uma. |
| `reforma` | quase | sim | estimativa simples, carreira | Adicionar um botão ou texto explicativo que indique claramente se os dados estão a ser importados automaticamente da Segurança Social ou se precisam de ser configurados. |
| `vale_perde` | quase | quase | IRS, Retenção | Adicionar um botão de ação claro no fundo do ecrã, como 'Guardar esta corrida' ou 'Nova corrida'. |
| `vida_sobra_carregar` | NÃO | quase | — | Adicionar uma mensagem de ajuda ou um botão de 'Configurar contas' caso o carregamento demore mais do que o esperado. |
| `vida_sobra_mau` | quase | quase | Falta pagar ao Estado, Cofre do imposto | Adicionar um botão de ação flutuante com um sinal '+' para permitir adicionar rapidamente uma nova receita ou despesa. |

## As 111 respostas literais do juiz (corrida completa de 14:07)

Pergunta: «Uma pessoa que nunca usou uma app destas percebe o que fazer aqui?» — modelo Gemini (roda `gemini-flash-latest`,
`gemini-3.7-flash`, `gemini-3.6-flash`, `gemini-3.5-flash`, `gemini-flash-lite-latest`…). Relatório completo em
`docs/provas/telas/simplicidade_20260918-140719.md`; a segunda corrida em `simplicidade_20260918-143054.md`.

### `caixa_desligada` — quase

O utilizador vê uma mensagem a explicar que a funcionalidade de receção de faturas ainda não está ativa porque o endereço de e-mail dedicado ainda não foi adquirido. Perante a indicação de que não precisa de fazer nada, o utilizador limitar-se-ia a esperar que a situação se resolvesse sozinha. No entanto, a pessoa será travada pela confusão de lhe ser pedido para reencaminhar faturas para um endereço que ainda não está visível nem ativo.

- Palavras difíceis: endereço da app
- Melhoria sugerida: Incluir um botão de ação direta para comprar ou configurar o endereço, ou explicar claramente se essa compra é automática por parte da plataforma.
- Modelo: `gemini-3.5-flash`

### `caixa_faturas` — quase → agora quase

O utilizador vê uma lista de faturas recebidas por e-mail com diferentes estados, como pendente ('Por ver'), processada ('Já é conta') ou com erro ('Não deu'). Para avançar, a pessoa tentaria clicar em 'Ver o documento' ou 'Fazer conta com esta' para registar a despesa da EDP. Contudo, o texto explicativo no topo do ecrã está cortado e ilegível, e a expressão 'Fazer conta' pode ser ambígua para quem não percebe de contabilidade.

- Palavras difíceis: Fazer conta
- Melhoria sugerida: Corrigir o erro visual do texto cortado no topo e alterar 'Fazer conta com esta' para algo mais explícito como 'Registar despesa'.
- Modelo: `gemini-3.5-flash`

### `caixa_ligada` — sim

O utilizador vê um e-mail personalizado para onde deve reencaminhar as suas faturas e uma lista com os documentos recebidos, como a fatura da EDP pendente. A seguir, ele saberia que pode copiar o endereço para enviar faturas ou clicar em 'Fazer conta com esta' para processar o documento. O que o poderia travar ligeiramente é a dúvida sobre se 'fazer conta' significa registar a despesa para impostos ou efetuar o pagamento da mesma.

- Palavras difíceis: Fazer conta
- Melhoria sugerida: Substituir 'Fazer conta com esta' por um termo mais preciso como 'Registar despesa' ou 'Associar à atividade'.
- Modelo: `gemini-3.5-flash`

### `caixa_vazia` — quase

O utilizador vê um endereço de e-mail próprio para onde deve reencaminhar as suas faturas de despesas. A seguir, tentaria copiar esse endereço para o colar no seu programa de correio eletrónico habitual. No entanto, a necessidade de sair da aplicação para ir ao e-mail reencaminhar uma fatura pode causar alguma confusão inicial sobre o que fazer a seguir.

- Palavras difíceis: reencaminha-a
- Melhoria sugerida: Adicionar um botão direto para partilhar o endereço por e-mail ou WhatsApp.
- Modelo: `gemini-flash-lite-latest`

### `calendario_detalhe` — quase

O utilizador vê um aviso sobre o pagamento da Segurança Social e o respetivo valor estimado. Provavelmente tentaria carregar no botão verde para abrir o site externo ou para marcar como pago. No entanto, o texto com setas a explicar como pagar em 'Segurança Social Direta' é demasiado complexo para quem nunca lidou com impostos.

- Palavras difíceis: Segurança Social Direta, Conta-corrente, Multibanco
- Melhoria sugerida: Adicionar um botão direto para gerar a referência ou simplificar os passos de pagamento com imagens.
- Modelo: `gemini-flash-lite-latest`

### `calendario` — quase → agora quase

O utilizador vê um resumo mensal de pagamentos com um calendário e lista de despesas. Provavelmente tentaria carregar no botão 'Adicionar' ou nos filtros para gerir as contas. No entanto, a confusão sobre o que exatamente significam termos como 'IVA/IRS' ou como pagar a 'Multa' diretamente na aplicação pode causar hesitação.

- Palavras difíceis: IVA, IRS
- Melhoria sugerida: Adicionar um botão de ação rápida para pagar ou marcar como pago diretamente em cada item da lista.
- Modelo: `gemini-flash-lite-latest`

### `carro_abastecimentos` — quase

O utilizador vê um resumo dos seus gastos com o carro e combustíveis, parecendo intuitivo carregar no botão verde de adicionar para inserir novos dados. No entanto, termos técnicos e siglas podem gerar alguma confusão sobre o impacto fiscal exato de cada registo. A principal dúvida seria perceber se o preenchimento destes dados é obrigatório para a sua atividade e como afeta os impostos.

- Palavras difíceis: TVDE, NIF, IRS
- Melhoria sugerida: Adicionar uma breve frase explicativa no topo a indicar para que servem estes registos na contabilidade.
- Modelo: `gemini-flash-lite-latest`

### `carro_cadeado` — quase

O utilizador vê o resumo do seu carro atual e os lembretes de despesas importantes como o seguro e a inspeção. Provavelmente tentaria clicar em "Adicionar carro" para perceber como funciona, mas seria travado pela restrição do plano grátis que exige pagamento para avançar. Ficaria confuso sem saber se deve pagar o Pro ou onde gerir os avisos que já aparecem.

- Palavras difíceis: TVDE, IUC, Pro
- Melhoria sugerida: Adicionar um botão direto para atualizar o plano ou explicar melhor o que limita a versão gratuita.
- Modelo: `gemini-flash-lite-latest`

### `carro_despesas` — quase → agora quase

O utilizador vê um resumo das despesas do carro associadas ao seu NIF e portagens por pagar. Provavelmente tentaria carregar em 'Adicionar' ou 'Ver perto de mim' para gerir o carro. No entanto, a confusão entre despesas guardadas para o IRS e portagens por pagar pode travar um leigo sem conhecimentos fiscais.

- Palavras difíceis: NIF, IRS, DGEG, IMT
- Melhoria sugerida: Explicar numa frase simples o que significa guardar faturas para o IRS neste contexto.
- Modelo: `gemini-flash-lite-latest`

### `carro` — quase → agora quase

O utilizador vê um resumo com os dados do seu automóvel e vários lembretes sobre despesas e prazos importantes, como o seguro e a inspeção. Provavelmente tentaria clicar num dos lembretes para ver mais detalhes ou atualizar o estado. No entanto, a sigla IUC e o termo TVDE podem gerar confusão, e não é evidente onde deve clicar para pagar ou registar estas ações.

- Palavras difíceis: TVDE, IUC
- Melhoria sugerida: Adicionar botões de ação claros em cada lembrete, como 'Marcar como pago' ou 'Ver detalhes'.
- Modelo: `gemini-flash-lite-latest`

### `carro_perto` — sim

O utilizador vê uma explicação clara sobre como encontrar combustível mais barato perto de si, podendo escolher entre usar a localização atual ou escrever o concelho. A seguir, carregaria no botão verde para ativar a localização ou introduziria o nome na caixa de texto. O que o poderia travar ligeiramente seria a quantidade de texto inicial, mas as opções de ação são muito diretas.

- Palavras difíceis: DGEG
- Melhoria sugerida: Tornar o texto introdutório mais curto para focar imediatamente a atenção nos botões de ação.
- Modelo: `gemini-flash-lite-latest`

### `carro_perto_sem_permissao` — sim

O utilizador vê um pedido para indicar a localização para encontrar combustível mais barato e centros de inspeção. O próximo passo intuitivo é clicar no botão verde para usar a localização atual ou escrever o concelho na caixa de texto. A explicação simples e direta evita qualquer confusão, mesmo para quem não está habituado a estas aplicações.

- Palavras difíceis: concelho
- Melhoria sugerida: Adicionar um exemplo prático na caixa de texto, como por exemplo 'Ex: Lisboa'.
- Modelo: `gemini-flash-lite-latest`

### `carro_perto_vazio` — sim

O utilizador vê um ecrã para partilhar a localização e encontrar combustível e inspeções perto de si. A seguir, o mais provável é carregar no botão verde para usar a localização automática ou escrever o concelho na caixa de texto. O texto longo pode inicialmente confundir alguém menos habituado, mas as instruções são claras.

- Palavras difíceis: concelho
- Melhoria sugerida: Reduzir a quantidade de texto explicativo para tornar o ecrã mais limpo e direto.
- Modelo: `gemini-flash-lite-latest`

### `carro_vazio` — sim

O utilizador vê que ainda não tem nenhum veículo registado na aplicação e que pode associar um facilmente. Para avançar, bastaria carregar no botão verde bem evidente para adicionar o carro. O que poderia causar alguma confusão ou travagem são as siglas técnicas DGEG e IMT mencionadas no cartão inferior, caso o utilizador não saiba o que significam.

- Palavras difíceis: DGEG, IMT
- Melhoria sugerida: Explicar brevemente o significado de DGEG e IMT ou remover as siglas para tornar o texto mais acessível a leigos.
- Modelo: `gemini-flash-lite-latest`

### `cofre_a_carregar` — NÃO → agora quase

O ecrã mostra apenas um título enigmático e blocos vazios, sem qualquer dado ou instrução para o utilizador. Alguém sem conhecimentos fiscais ficaria completamente perdido sem saber o que fazer a seguir. O que a travaria é a total ausência de explicações, botões de ação ou informações visíveis no ecrã.

- Palavras difíceis: imposto
- Melhoria sugerida: Adicionar uma breve explicação sobre o propósito do ecrã e um botão claro a indicar a próxima ação.
- Modelo: `gemini-flash-lite-latest`

### `cofre_caderno` — quase

Um utilizador leigo vê um resumo dos seus ganhos e impostos estimados, juntamente com um histórico de valores guardados ou retirados. Provavelmente tentaria carregar nos botões verdes de 'Separei' ou 'Tirei' para registar uma nova operação financeira. No entanto, a confusão sobre o que significa exatamente 'O cofre do imposto' e a falta de instrução clara sobre se deve inserir o valor total poupado ou apenas o último montante poderiam travá-lo.

- Palavras difíceis: IRS, Segurança Social
- Melhoria sugerida: Adicionar uma breve explicação por baixo dos botões a indicar claramente o que acontece ao carregar neles.
- Modelo: `gemini-flash-lite-latest`

### `cofre_chega` — quase → agora quase

O utilizador vê o montante total guardado para impostos e uma indicação clara de que tem dinheiro suficiente. Ficaria na dúvida sobre o que fazer a seguir, pois os botões 'Separei' e 'Tirei' são pouco intuitivos para quem não domina a aplicação. O que o travaria seria perceber se tem de fazer alguma ação manual nestes botões ou se o valor é atualizado automaticamente.

- Palavras difíceis: Segurança Social, IRS
- Melhoria sugerida: Adicionar uma breve explicação por baixo dos botões 'Separei' e 'Tirei' a indicar quando devem ser utilizados.
- Modelo: `gemini-flash-lite-latest`

### `cofre_erro` — sim

O utilizador vê uma mensagem clara a informar que não há ligação à internet. A ação seguinte é óbvia: carregar no botão verde para tentar novamente. O que o travaria seria apenas persistir o problema de falha de rede no telemóvel.

- Melhoria sugerida: Adicionar um ícone ou indicação visual para verificar o Wi-Fi ou dados móveis.
- Modelo: `gemini-flash-lite-latest`

### `cofre_falta_muito` — quase

Um utilizador leigo percebe que tem dinheiro guardado e em falta, mas confunde-se com a metáfora do 'cofre' e a falta de ações claras. Provavelmente tentaria carregar nos botões 'Separei' ou 'Tirei' sem saber bem o que significam na prática. O que o travaria é a dúvida sobre se tem de fazer alguma transferência bancária real ou se isto é apenas um registo manual.

- Palavras difíceis: Segurança Social, IRS
- Melhoria sugerida: Adicionar um botão explicativo com a indicação exata de quanto deve guardar da próxima vez que receber.
- Modelo: `gemini-flash-lite-latest`

### `cofre_falta_pouco` — quase

O utilizador vê o valor guardado para os impostos e percebe que lhe falta juntar mais um bocado. Ficaria confuso com o significado exato de termos como 'Segurança Social' e 'IRS' misturados com conceitos informais. Para avançar, tentaria carregar nos botões em baixo para registar o dinheiro que já separou.

- Palavras difíceis: Segurança Social, IRS, contabilidade
- Melhoria sugerida: Adicionar uma explicação curta sobre o que significam 'Segurança Social' e 'IRS' para quem nunca lidou com impostos.
- Modelo: `gemini-flash-lite-latest`

### `cofre_folha` — quase

O utilizador vê um formulário para registar dinheiro guardado ou retirado e indicará o valor e o motivo nas opções abaixo. A seguir, tentaria preencher o campo do dinheiro e carregar em «Guardar» no fundo do ecrã. O que o travaria é não saber exatamente que valor colocar ali nem se isto afeta diretamente as suas contas reais com o Estado.

- Palavras difíceis: IRS, Segurança Social
- Melhoria sugerida: Adicionar um exemplo prático no campo vazio para indicar que valor deve ser inserido.
- Modelo: `gemini-flash-lite-latest`

### `cofre_sem_sessao` — quase

O utilizador vê o título "O cofre do imposto" e uma caixa azul a pedir para entrar na app para ver o cofre. Para avançar, tentaria carregar nessa caixa azul por parecer um botão clicável. No entanto, a incerteza sobre se já tem sessão iniciada ou onde deve clicar exatamente para fazer login poderá causar alguma hesitação.

- Palavras difíceis: cofre
- Melhoria sugerida: Transformar a caixa azul num botão bem visível com o texto "Entrar na aplicação".
- Modelo: `gemini-flash-lite-latest`

### `cofre_vazio` — quase → agora quase

O utilizador vê um saldo de zero euros e percebe que deve clicar no botão verde para indicar quanto ganhou. A seguir, tentaria escrever o valor dos seus rendimentos para calcular o imposto. No entanto, a confusão entre o cofre virtual e os botões de "Separei" e "Tirei" pode travá-lo, pois não é evidente se tem de registar o dinheiro manualmente.

- Palavras difíceis: IRS, Segurança Social, contabilidade
- Melhoria sugerida: Adicionar uma breve instrução passo a passo a explicar a diferença entre indicar o que ganhou e mexer no dinheiro do cofre.
- Modelo: `gemini-flash-lite-latest`

### `conta-nao-abriu` — sim

O utilizador vê um ecrã de erro a indicar um problema de ligação à internet que impediu a abertura da conta. A seguir, tentaria carregar no botão verde para tentar novamente ou sairia da aplicação. Nada o travaria, pois as instruções são claras e acessíveis.

- Modelo: `gemini-flash-lite-latest`

### `desemprego` — sim

Uma pessoa leiga vê claramente que tem direito ao subsídio de desemprego e qual será o valor estimado. A seguir, tentaria seguir os três passos indicados e usaria os botões de atalho para abrir os sites externos. No entanto, a referência a códigos burocráticos pode gerar alguma hesitação inicial.

- Palavras difíceis: IEFP, modelo RP5044
- Melhoria sugerida: Adicionar uma breve explicação ou exemplo do que é o modelo RP5044 para facilitar a compreensão.
- Modelo: `gemini-flash-lite-latest`

### `exemplo_carro` — quase

O utilizador vê os dados do seu automóvel e vários lembretes sobre prazos importantes, como a inspeção e o seguro. Provavelmente tentaria clicar num dos lembretes para ver mais detalhes ou atualizar a informação. No entanto, a sigla 'TVDE' e termos fiscais como 'IUC' podem gerar confusão sobre onde pagar ou o que fazer exatamente.

- Palavras difíceis: TVDE, IUC
- Melhoria sugerida: Adicionar um botão direto em cada lembrete para 'Marcar no calendário' ou 'Saber como pagar'.
- Modelo: `gemini-flash-lite-latest`

### `exemplo_painel` — sim

Uma pessoa que nunca usou a aplicação vê claramente que tem de pagar a Segurança Social e o respetivo valor. O utilizador saberia carregar em "Ver como pagar" para avançar com o pagamento ou em "Já paguei" se já o tivesse feito. O que poderia gerar alguma dúvida inicial seria saber onde obter os dados de pagamento exatos, mas a instrução principal está muito clara.

- Palavras difíceis: Segurança Social, IRS
- Melhoria sugerida: Adicionar um pequeno texto explicativo a indicar que ao clicar em "Ver como pagar" aparecem as referências para o multibanco.
- Modelo: `gemini-flash-lite-latest`

### `exemplo_vida` — sim

Uma pessoa leiga vê claramente o dinheiro que ganhou este mês dividido por registos individuais, como viagens da Uber ou Bolt. O botão verde grande convida intuitivamente a registar novos ganhos caso seja necessário. O que a poderia travar era não saber se estes valores entram automaticamente ou se tem de os colocar sempre à mão.

- Melhoria sugerida: Adicionar um pequeno texto a explicar se os ganhos foram importados automaticamente ou inseridos manualmente.
- Modelo: `gemini-flash-lite-latest`

### `fala_a_ouvir` — quase

O utilizador vê um assistente por voz onde colocou uma questão sobre pagamentos e percebe que pode falar para obter uma resposta. O que faria a seguir seria continuar a falar ou largar o dedo para enviar a mensagem de voz. O que o poderia travar é a dúvida sobre se deve manter o dedo no botão verde enquanto fala.

- Melhoria sugerida: Adicionar uma instrução visual a indicar se deve manter o dedo premido ou apenas tocar uma vez.
- Modelo: `gemini-flash-lite-latest`

### `fala_a_pensar` — sim

O ecrã mostra um assistente de voz a processar um pedido com instruções claras para falar ou escrever. Uma pessoa sem experiência saberia que pode tocar no microfone para falar ou escolher a opção de escrever. O único fator que poderia gerar dúvida é o tempo de espera gerado pelo estado 'a pensar na resposta'.

- Melhoria sugerida: Adicionar uma animação mais clara de que o sistema está apenas a processar o áudio para evitar a sensação de bloqueio.
- Modelo: `gemini-flash-lite-latest`

### `fala_com_resposta` — quase → agora quase

O utilizador vê uma resposta clara sobre quanto dinheiro deve guardar para impostos, com valores e prazos indicados. A seguir, continuaria a usar o microfone para colocar novas dúvidas ou tocaria em "Prefiro escrever" se preferisse texto. No entanto, a ausência de indicações concretas sobre onde pagar estes valores ou como proceder exatamente pode deixá-lo confuso.

- Palavras difíceis: IVA, Segurança Social, trimestre
- Melhoria sugerida: Adicionar botões de ação rápida logo abaixo da resposta, como "Como pagar?" ou "Adicionar lembrete".
- Modelo: `gemini-flash-lite-latest`

### `fala_escrita` — sim

O utilizador vê um assistente de voz onde pode fazer perguntas diretamente ou escolher exemplos sugeridos. O que o faria avançar seria carregar numa das perguntas pré-definidas ou escrever no campo de texto para obter respostas. A única pequena barreira é perceber que o microfone está desligado, mas o texto explicativo resolve essa dúvida.

- Palavras difíceis: IVA
- Melhoria sugerida: Adicionar um botão direto para ligar o microfone nas definições dentro do próprio ecrã.
- Modelo: `gemini-flash-lite-latest`

### `fala_limite` — quase

O utilizador vê um ecrã de assistente de voz com um aviso de que esgotou as perguntas mensais e um botão para ver um plano pago. A seguir, tentaria carregar no microfone para falar, mas ficaria confuso sobre se ainda pode fazer perguntas devido ao bloqueio. O que o travaria é a incerteza sobre se o botão do microfone funciona após esgotar o limite.

- Palavras difíceis: plano Pro
- Melhoria sugerida: Tornar o botão do microfone cinzento e inativo quando acabarem as perguntas, indicando claramente que é preciso atualizar o plano.
- Modelo: `gemini-flash-lite-latest`

### `fala_parado` — sim

O ecrã apresenta um assistente por voz onde o utilizador pode fazer perguntas oralmente ou escolher exemplos sugeridos. Para começar, a pessoa vê instruções claras para carregar no botão verde com o microfone e falar naturalmente. O que poderia gerar alguma dúvida inicial seria saber se o assistente compreende linguagem simples do dia a dia.

- Palavras difíceis: IVA
- Melhoria sugerida: Adicionar uma breve animação ou indicação visual a apontar diretamente para o botão do microfone para atrair imediatamente o olhar.
- Modelo: `gemini-flash-lite-latest`

### `fala_sem_microfone` — quase

O utilizador vê um assistente de voz com instruções para carregar no microfone e falar, além de sugestões de perguntas. A pessoa tentaria carregar no botão verde ou escrever, mas o aviso azul indica que o microfone está desligado. O que travaria o utilizador seria perceber como voltar a ligar o microfone nas definições do telemóvel.

- Palavras difíceis: IVA
- Melhoria sugerida: Adicionar um botão direto para abrir as definições do telemóvel e ligar o microfone.
- Modelo: `gemini-flash-lite-latest`

### `fala_sem_rede` — quase

O utilizador vê um assistente de voz para tirar dúvidas e um aviso vermelho a indicar falta de ligação à internet. TENTARIA carregar no botão verde do microfone para falar, mas ficaria retido pelo erro de ligação que impede o funcionamento da app.

- Palavras difíceis: IVA
- Melhoria sugerida: Adicionar um botão claro para tentar ligar novamente a internet e explicar como resolver o erro de rede.
- Modelo: `gemini-flash-lite-latest`

### `fala_trancado` — quase

O utilizador vê um assistente de voz para fazer perguntas sobre impostos e despesas. Para avançar, teria de carregar no botão do microfone ou escolher uma das perguntas sugeridas em baixo. No entanto, o aviso inicial a bloquear o acesso à funcionalidade principal gera logo confusão e travagem imediata.

- Palavras difíceis: Pro, IVA
- Melhoria sugerida: Tornar o botão de ativação do Pro mais claro ou explicar o que é necessário fazer para desbloquear o assistente de voz.
- Modelo: `gemini-flash-lite-latest`

### `guias_breve` — quase

O utilizador vê o título de um guia sobre como abrir atividade, mas logo a baixo descobre que o conteúdo ainda não está escrito. Tentaria ler as instruções para avançar com o processo, mas ficaria bloqueado por não haver informação disponível. O que o trava é precisamente a mensagem a indicar que o guia está em breve.

- Palavras difíceis: CAE, TVDE
- Melhoria sugerida: Adicionar uma estimativa de tempo para a disponibilidade do guia ou um botão para voltar atrás.
- Modelo: `gemini-flash-lite-latest`

### `guias_detalhe` — quase

O utilizador vê um guia passo a passo para pagar a Segurança Social, explicando que precisa de ir ao site externo e gerar uma referência Multibanco. A seguir, tentaria abrir o site indicado para seguir os passos, mas o texto exige sair da aplicação atual. O que o travaria é a necessidade de alternar entre a app e o site externo da Segurança Social para concluir a tarefa.

- Palavras difíceis: NISS, Conta-corrente, referência Multibanco
- Melhoria sugerida: Adicionar um botão direto para abrir o portal da Segurança Social no navegador do telemóvel.
- Modelo: `gemini-flash-lite-latest`

### `guias` — quase → agora quase

O utilizador vê uma lista de pequenos guias informativos sobre impostos e recibos verdes. Provavelmente tentaria carregar no primeiro guia para começar a aprender. No entanto, termos técnicos e siglas no meio dos títulos podem gerar confusão e travar a leitura.

- Palavras difíceis: CAE, IVA, art. 53.º, Retenção na fonte, IRS, anexo B, TVDE
- Melhoria sugerida: Adicionar uma breve frase de boas-vindas a explicar qual o primeiro guia que o utilizador deve ler consoante a sua situação.
- Modelo: `gemini-flash-lite-latest`

### `horas_extra` — quase → agora quase

O utilizador vê o cálculo detalhado das suas horas extra, dias de férias e subsídios com base num salário de 1.200 euros. Como se trata de um ecrã meramente informativo, a pessoa tentaria tocar no interruptor sobre as 100 horas extra para ver se o valor muda. No entanto, a referência a artigos legais complexos no final pode causar alguma confusão a quem não percebe de leis.

- Palavras difíceis: art. 238.º, subsídio de Natal, proporcional
- Melhoria sugerida: Adicionar uma breve explicação em linguagem simples sobre o impacto prático de ativar o botão das 100 horas extra.
- Modelo: `gemini-flash-lite-latest`

### `ia_limite` — quase

O utilizador vê respostas explicativas sobre impostos com conselhos práticos, mas depara-se com um bloqueio por ter esgotado as perguntas gratuitas. A seguir, tentaria escrever na barra inferior, mas perceberia que está inativa. O que a travaria é o limite do plano grátis que impede de continuar a conversa sem pagar.

- Palavras difíceis: SS, IRS, Pro
- Melhoria sugerida: Tornar a caixa de texto inferior claramente desativada com um aviso direto para carregar em 'Ver o plano Pro'.
- Modelo: `gemini-flash-lite-latest`

### `ia` — quase → agora quase

O utilizador vê explicações simples sobre isenções fiscais e uma estimativa de quanto deve poupar para o IRS. Como próximo passo, tentaria colocar o dinheiro numa conta à parte conforme sugerido. No entanto, termos técnicos podem gerar dúvidas sobre como proceder exatamente na prática.

- Palavras difíceis: Segurança Social, IVA, IRS
- Melhoria sugerida: Adicionar um botão direto para simular a criação dessa poupança ou calcular o valor exato com base nos rendimentos reais.
- Modelo: `gemini-flash-lite-latest`

### `ia_pensar` — quase

O utilizador vê uma conversa em formato de chat onde a aplicação responde diretamente a uma dúvida sobre o início de pagamentos à Segurança Social. Como a app já indica o próximo passo, a pessoa apenas continuaria a ler ou a fazer novas perguntas na caixa de texto. No entanto, a utilização de siglas e termos técnicos pode gerar alguma confusão sobre o que fazer exatamente na Autoridade Tributária.

- Palavras difíceis: Segurança Social, IVA, SS
- Melhoria sugerida: Adicionar botões de ação rápida abaixo da resposta com os próximos passos recomendados para o utilizador.
- Modelo: `gemini-flash-lite-latest`

### `ia_vazio` — sim

O utilizador vê um assistente de perguntas e respostas sobre impostos, recibos e carros, acompanhado de exemplos prontos a clicar. O próximo passo intuitivo é tocar numa das sugestões ou escrever uma dúvida na barra inferior. O que poderia travar alguém é a dúvida se o assistente compreende linguagem simples ou se vai responder com termos fiscais complicados.

- Palavras difíceis: IVA, Segurança Social
- Melhoria sugerida: Adicionar uma breve instrução no topo a incentivar o utilizador a escrever a sua própria questão por palavras simples.
- Modelo: `gemini-flash-lite-latest`

### `login-codigo` — sim

O utilizador vê um ecrã para introduzir um código numérico enviado por e-mail para validar a sua conta. A seguir, iria ao seu e-mail ver o código, voltava à aplicação para o digitar nas caixas e carregava no botão 'Confirmar'. O que o poderia travar era não encontrar o e-mail e ter de esperar o tempo indicado para pedir um novo.

- Melhoria sugerida: Adicionar um botão direto para abrir a aplicação de e-mail do telemóvel.
- Modelo: `gemini-flash-lite-latest`

### `login` — sim

O utilizador vê um ecrã limpo com instruções simples para iniciar sessão apenas com o endereço de correio eletrónico. A ação seguinte é natural: basta digitar o e-mail no campo indicado e carregar no botão verde para receber o código. A clareza da linguagem evita qualquer tipo de bloqueio ou confusão inicial.

- Modelo: `gemini-flash-lite-latest`

### `mais_definicoes` — sim

O utilizador vê um ecrã de definições simples para escolher a variante do português e gerir a conta. Para continuar, basta tocar na opção de idioma desejada ou no botão para sair. A clareza das opções evita qualquer confusão, mesmo para quem não está habituado a aplicações.

- Modelo: `gemini-flash-lite-latest`

### `mais` — NÃO → agora quase

O utilizador vê um conjunto de botões com nomes abstratos que não indicam claramente a sua função prática ou o benefício imediato. Alguém sem conhecimentos fiscais não saberia qual destas opções escolher para resolver um problema específico, como emitir um recibo ou verificar impostos. A falta de contexto ou de uma hierarquia de tarefas travaria o utilizador, deixando-o confuso sobre por onde começar.

- Palavras difíceis: Prova de rendimento, Fim da fidelização, Reforma e direitos
- Melhoria sugerida: Adicionar uma breve descrição ou subtítulo abaixo de cada título que explique a utilidade prática de cada opção.
- Modelo: `gemini-3.1-flash-lite`

### `onboarding_empresa` — quase → agora quase

O utilizador vê duas opções para classificar a sua atividade profissional e percebe que deve selecionar uma antes de carregar em 'Continuar'. No entanto, a falta de conhecimento sobre termos técnicos pode gerar insegurança sobre qual a opção correta para o seu caso específico. O que trava a pessoa é o medo de escolher a categoria errada e ter problemas com as Finanças.

- Palavras difíceis: ENI, NIF, Lda., NIPC
- Melhoria sugerida: Adicionar um pequeno botão de ajuda ou 'i' junto a cada opção que explique de forma simples o que significa cada uma.
- Modelo: `gemini-3.1-flash-lite`

### `onboarding_iva_periodo` — sim

O utilizador vê uma pergunta direta sobre a periodicidade do IVA com uma recomendação clara de qual opção escolher. A pessoa selecionaria a opção sugerida e carregaria no botão 'Continuar' para avançar. O que poderia travar o utilizador é a dúvida sobre se a escolha terá consequências fiscais graves caso não seja a correta.

- Palavras difíceis: IVA
- Melhoria sugerida: Adicionar uma breve explicação sobre o que é o IVA ou um link para 'Saber mais' para reduzir a ansiedade do utilizador.
- Modelo: `gemini-3.1-flash-lite`

### `onboarding_nascimento` — sim

O utilizador vê uma pergunta simples sobre a sua data de nascimento para verificar a elegibilidade para um benefício fiscal. A ação óbvia é confirmar o ano e carregar no botão 'Continuar' na base do ecrã. O que pode travar a pessoa é a incerteza sobre o que é exatamente o 'IRS Jovem' e se a aplicação está a calcular algo automaticamente ou apenas a recolher dados.

- Palavras difíceis: IRS, IRS Jovem
- Melhoria sugerida: Adicionar um pequeno ícone de ajuda ou um link 'Saber mais' junto à explicação do IRS Jovem para esclarecer o conceito sem sair do fluxo.
- Modelo: `gemini-3.1-flash-lite`

### `onboarding_p0_boasvindas` — sim

O utilizador vê uma mensagem de boas-vindas que explica o propósito da aplicação e o que esperar a seguir. A ação a tomar é clara: carregar no botão verde 'Começar' para iniciar o processo de configuração. O que poderia travar a pessoa é a ansiedade perante siglas fiscais que não compreende, mesmo que o botão seja óbvio.

- Palavras difíceis: IVA, IRS
- Melhoria sugerida: Adicionar uma pequena frase de apoio como 'Não te preocupes, vamos ajudar-te com cada passo' para reduzir a ansiedade fiscal.
- Modelo: `gemini-3.1-flash-lite`

### `onboarding_p1_atividade` — sim

O utilizador percebe que está a selecionar a sua ocupação profissional para configurar a conta. A pessoa escolheria a opção que melhor descreve o seu trabalho e carregaria no botão 'Continuar' no fundo do ecrã. O que poderia causar hesitação é a sigla 'TVDE', caso o utilizador não saiba que se refere a transporte individual de passageiros.

- Palavras difíceis: TVDE
- Melhoria sugerida: Adicionar uma pequena descrição ou exemplo por baixo de 'Motorista TVDE' para esclarecer que se trata de transporte de passageiros.
- Modelo: `gemini-3.1-flash-lite`

### `onboarding_p2_abertura` — quase → agora quase

O utilizador percebe que deve selecionar a data de início da sua atividade profissional através dos menus pendentes. Após ajustar a data, a pessoa carregaria no botão 'Continuar' para avançar. O que trava o utilizador é a incerteza sobre onde encontrar essa data específica no Portal das Finanças e o medo de errar num campo que parece ter implicações fiscais.

- Palavras difíceis: Portal das Finanças, Segurança Social
- Melhoria sugerida: Adicionar um pequeno botão ou link de ajuda que mostre um exemplo visual de onde encontrar a data de início de atividade no documento das Finanças.
- Modelo: `gemini-3.1-flash-lite`

### `onboarding_p4_carro` — sim

O utilizador percebe que está a configurar os dados do seu carro para a aplicação fazer cálculos automáticos. A pessoa preencheria os campos com as datas solicitadas e carregaria no botão 'Continuar'. O que poderia travar o utilizador é a dúvida sobre o que é o IUC ou a incerteza sobre a data exata da última inspeção.

- Palavras difíceis: IUC
- Melhoria sugerida: Adicionar uma pequena nota explicativa ou um ícone de ajuda junto à sigla IUC para esclarecer que se trata do Imposto Único de Circulação.
- Modelo: `gemini-3.1-flash-lite`

### `onboarding_p5_rendimento` — sim

O utilizador percebe que deve indicar o seu rendimento mensal aproximado para obter uma simulação. Ao ver os resultados imediatos sobre Segurança Social e IRS, sente-se encorajado a carregar no botão 'Continuar'. O que pode travar a pessoa é a incerteza sobre se o valor deve ser bruto ou líquido, algo que não está especificado.

- Palavras difíceis: IRS, Segurança Social
- Melhoria sugerida: Adicionar uma pequena nota a esclarecer se o valor a inserir deve ser o rendimento bruto ou líquido.
- Modelo: `gemini-3.1-flash-lite`

### `onboarding_salario` — sim

O utilizador vê uma pergunta direta sobre o seu salário bruto e uma caixa de texto onde pode inserir o valor ou escolher uma das opções sugeridas. A pessoa perceberia que deve confirmar o valor e carregar no botão 'Continuar' para avançar. O que poderia travar o utilizador é a dúvida sobre se deve incluir subsídios ou prémios no valor mensal.

- Palavras difíceis: bruto
- Melhoria sugerida: Adicionar um pequeno texto de ajuda ou um ícone de informação a explicar se o valor deve incluir subsídios de alimentação ou outros complementos.
- Modelo: `gemini-3.1-flash-lite`

### `onboarding_trabalho` — sim

O utilizador vê uma lista clara de situações profissionais e entende que deve selecionar a que melhor descreve o seu caso. A ação seguinte é clicar na opção correta e carregar no botão 'Continuar' no fundo do ecrã. O que pode travar alguém é a sigla 'TVDE', que pode não ser reconhecida por quem não trabalha no setor dos transportes.

- Palavras difíceis: TVDE
- Melhoria sugerida: Adicionar uma pequena explicação ou o significado completo da sigla TVDE (Transporte Individual e Remunerado de Passageiros em Veículos Descaracterizados a partir de Plataforma Eletrónica) num pequeno texto de ajuda.
- Modelo: `gemini-3.1-flash-lite`

### `painel_erro` — sim

O utilizador percebe que a aplicação não está a conseguir ligar à internet e que a solução imediata é carregar no botão para tentar novamente. O que o poderia travar é a dúvida sobre se o problema é do seu telemóvel ou da própria aplicação, gerando insegurança sobre se deve verificar o Wi-Fi ou apenas insistir.

- Melhoria sugerida: Adicionar uma pequena sugestão visual ou texto a indicar que deve verificar a ligação à internet do telemóvel.
- Modelo: `gemini-3.1-flash-lite`

### `painel_laranja` — sim

O utilizador vê claramente que tem um pagamento pendente da Segurança Social e um botão direto para saber como o efetuar. A pessoa carregaria em 'Ver como pagar' para obter as referências multibanco. O que poderia causar hesitação é a falta de contexto sobre o que é o 'IUC' mencionado no cartão laranja, apesar da explicação breve abaixo.

- Palavras difíceis: IUC
- Melhoria sugerida: Adicionar um pequeno ícone de ajuda ou um texto explicativo mais detalhado sobre o que acontece ao clicar em 'Já paguei' para evitar receio de erro.
- Modelo: `gemini-3.1-flash-lite`

### `painel_skeleton` — NÃO → agora quase

O utilizador vê apenas um ecrã vazio com uma saudação, sem qualquer instrução ou botão de ação. A pessoa sentir-se-ia perdida, sem saber se a aplicação está a carregar ou se precisa de configurar algo. A falta de um botão de 'Adicionar' ou 'Começar' trava completamente qualquer tentativa de utilização.

- Melhoria sugerida: Adicionar um botão de ação claro, como 'Adicionar o meu primeiro recibo' ou 'Configurar perfil', no centro do ecrã vazio.
- Modelo: `gemini-3.1-flash-lite`

### `painel_verde` — sim

O utilizador vê uma mensagem tranquilizadora de que não tem pagamentos pendentes e uma instrução clara para registar os seus rendimentos mensais. A pessoa sentir-se-ia confortável a carregar no botão verde para inserir o valor ganho, pois a linguagem é simples e direta. O que poderia travar o utilizador é a dúvida sobre se deve inserir o valor bruto ou líquido, algo que não está especificado.

- Palavras difíceis: IRS
- Melhoria sugerida: Adicionar uma pequena nota explicativa no botão ou abaixo dele a esclarecer se o valor a inserir deve ser o rendimento bruto ou líquido.
- Modelo: `gemini-3.1-flash-lite`

### `painel_vermelho` — sim

O utilizador vê claramente que tem uma dívida urgente à Segurança Social e um pagamento futuro de seguro. A pessoa carregaria no botão 'Ver como pagar' para resolver a pendência imediata. O que poderia travar alguém menos experiente é o medo de clicar num botão e efetuar um pagamento automático sem querer.

- Palavras difíceis: Segurança Social
- Melhoria sugerida: Adicionar uma pequena frase explicativa abaixo de 'Ver como pagar' indicando que o botão apenas mostra os dados para pagamento e não retira dinheiro da conta.
- Modelo: `gemini-3.1-flash-lite`

### `painel_vermelho_segunda` — sim

A utilizadora vê claramente que tem um pagamento em atraso da Segurança Social de 149,80 € e outro pagamento do IUC a aproximar-se. O passo seguinte seria clicar em 'Ver como pagar' para obter os dados de pagamento ou em 'Já paguei' se já o tivesse feito. O que a poderia travar seria a falta de contexto sobre a que mês ou período se refere este valor da Segurança Social.

- Melhoria sugerida: Adicionar a indicação do período ou mês a que corresponde o pagamento em falta da Segurança Social.
- Modelo: `gemini-3.5-flash`

### `plano_gratis` — sim

O utilizador vê claramente a comparação entre o seu plano gratuito atual e as vantagens de aderir ao plano 'Pro'. Para prosseguir, basta escolher a modalidade de pagamento e clicar no botão destacado para ativar o serviço. O que poderá travar o utilizador é a ausência de uma opção visível para fechar o ecrã ou voltar atrás caso não queira pagar.

- Palavras difíceis: PDF
- Melhoria sugerida: Adicionar um botão de fechar (X) ou 'Voltar' para que o utilizador saiba como sair deste ecrã sem subscrever.
- Modelo: `gemini-3.5-flash`

### `plano` — quase → agora quase

O utilizador vê o estado do seu plano atual e as vantagens da versão paga, mas pode ficar confuso sobre se já está a pagar ou apenas a testar. Provavelmente tentaria carregar no botão verde para ver o que acontece ou perceber como ativar o serviço. A hesitação surge na falta de clareza sobre o método de pagamento exato que será cobrado após o clique.

- Palavras difíceis: Pro, PDF, contabilista
- Melhoria sugerida: Adicionar uma frase curta a indicar exatamente onde será feito o pagamento (ex: 'Pagamento seguro através da App Store').
- Modelo: `gemini-flash-lite-latest`

### `prova_com_dados` — sim

Um utilizador leigo percebe facilmente que está a criar um comprovativo de rendimentos para mostrar a terceiros, como o senhorio ou o banco. Veria os seus dados e valores calculados automaticamente, sabendo que deve preencher o NIF opcional e carregar no botão verde para gerar o documento. O que o poderia travar ligeiramente seria a dúvida sobre se deve mesmo partilhar o seu NIF no documento.

- Palavras difíceis: NIF, IRS, Finanças
- Melhoria sugerida: Adicionar uma pequena frase a explicar o que é o NIF para quem possa ter dúvidas.
- Modelo: `gemini-flash-lite-latest`

### `prova_sem_dados` — quase

O utilizador percebe que está a criar um documento para comprovar rendimentos e que pode escolher o período desejado. No entanto, o aviso a laranja indica que faltam dados para concluir o documento, deixando o botão "Fazer a folha" inativo. A obrigatoriedade de introduzir mais registos anteriores para avançar poderá causar frustração a quem precisa do documento imediatamente.

- Palavras difíceis: NIF, IRS, Finanças, senhorio
- Melhoria sugerida: Adicionar um botão direto para adicionar os meses em falta logo abaixo do aviso a laranja.
- Modelo: `gemini-flash-lite-latest`

### `prova_trancada` — quase

O utilizador vê um resumo dos seus rendimentos e opções para escolher o período de tempo para a prova. Provavelmente tentaria clicar no botão verde "Fazer a folha" para avançar. No entanto, ficaria travado ao perceber que a funcionalidade está bloqueada por exigir um plano pago ("plano Pro").

- Palavras difíceis: plano Pro, NIF
- Melhoria sugerida: Adicionar uma explicação simples sobre o que é necessário para desbloquear o plano Pro logo abaixo do aviso do cadeado.
- Modelo: `gemini-flash-lite-latest`

### `prova_vazia` — quase → agora quase

O utilizador vê um ecrã para criar uma prova de rendimento e escolhe o período pretendido. Para avançar, teria de preencher o NIF e ir à secção 'Dinheiro' registar os ganhos anteriores. O que mais o travaria é a necessidade de sair do ecrã atual para inserir dados noutro local antes de conseguir gerar o documento.

- Palavras difíceis: NIF, PDF
- Melhoria sugerida: Adicionar um botão direto para a secção 'Dinheiro' logo abaixo do aviso para facilitar o registo imediato dos ganhos.
- Modelo: `gemini-flash-lite-latest`

### `radar_erro` — quase → agora sim

O utilizador vê uma explicação clara sobre o que é a fidelização e um aviso de erro a indicar que não foi possível carregar os contratos. Perante isto, a pessoa tentaria carregar novamente mais tarde, seguindo a instrução do aviso. No entanto, a ausência de um botão para atualizar ou tentar de novo no momento pode gerar frustração e incerteza.

- Palavras difíceis: fidelização
- Melhoria sugerida: Adicionar um botão de 'Tentar novamente' na caixa de erro para facilitar a nova tentativa.
- Modelo: `gemini-flash-lite-latest`

### `radar_lista_fim` — quase

O utilizador vê uma lista de contratos prestes a terminar ou já terminados, acompanhados por sugestões práticas. Tentaria carregar num dos contratos para ver detalhes ou na opção para ouvir a informação, mas pode ficar confuso sem saber como atualizar o estado de cada contrato. O que mais o travaria é a falta de botões óbvios para agir diretamente sobre cada contrato listado.

- Palavras difíceis: fidelização, MEO, NOS, Fitness Hut, Médis
- Melhoria sugerida: Adicionar botões de ação direta em cada cartão, como "Já renegociei" ou "Ligar agora".
- Modelo: `gemini-flash-lite-latest`

### `radar_lista` — sim

O utilizador vê uma explicação clara sobre o que é a fidelização e contratos listados em baixo com o respetivo estado. A pessoa tentaria tocar num contrato para ver detalhes ou seguiria o conselho escrito de ligar para a operadora. O ecrã é muito intuitivo e a única dúvida seria se tocar num contrato abre alguma opção na aplicação.

- Melhoria sugerida: Tornar os cartões dos contratos clicáveis para ver mais detalhes ou adicionar um botão direto para ligar ou enviar mensagem.
- Modelo: `gemini-flash-lite-latest`

### `radar_trancado` — sim

O utilizador lê uma explicação simples sobre o que é a fidelização e recebe conselhos práticos sobre o que fazer antes de ela terminar. A seguir, tentaria carregar no botão para ouvir o texto ou explorar a opção do plano Pro para ver os seus próprios contratos. O que o poderia travar é perceber que a lista real de contratos está bloqueada atrás de uma subscrição paga.

- Palavras difíceis: fidelização, plano Pro
- Melhoria sugerida: Adicionar um botão direto para adicionar o primeiro contrato logo abaixo da explicação.
- Modelo: `gemini-flash-lite-latest`

### `radar_vazio` — quase

O utilizador vê uma explicação clara sobre o conceito de fidelização e o que fazer para a negociar. A seguir, tentaria procurar onde adicionar os dados do seu contrato, mas o ecrã apenas mostra uma mensagem de que ainda não disse nenhuma data. A falta de um botão óbvio para adicionar o primeiro contrato é o que o travaria.

- Palavras difíceis: fidelização
- Melhoria sugerida: Adicionar um botão bem visível no fundo com o texto 'Adicionar contrato' para orientar o utilizador.
- Modelo: `gemini-flash-lite-latest`

### `recibo_vencimento` — quase

O utilizador vê instruções para inserir dois números do seu recibo de vencimento nos campos indicados. Face à explicação simples e aos exemplos preenchidos, perceberia que deve copiar os valores correspondentes do seu próprio papel. No entanto, o termo técnico "IRS" e a estimativa final de pagamento podem gerar alguma confusão a quem nunca lidou com impostos.

- Palavras difíceis: IRS
- Melhoria sugerida: Adicionar uma pequena ajuda visual a indicar exatamente onde encontrar esses dois números no recibo de papel.
- Modelo: `gemini-flash-lite-latest`

### `recibos_cartao_fatura` — quase

O utilizador vê uma opção para passar recibos sem ir ao portal das finanças. Ficaria a pensar que basta tocar na linha verde para avançar com o documento. No entanto, a falta de um botão óbito ou indicação clara de toque pode gerar alguma hesitação.

- Palavras difíceis: PDF
- Melhoria sugerida: Adicionar um botão explícito como 'Criar fatura-recibo' para clarificar que a linha é interativa.
- Modelo: `gemini-flash-lite-latest`

### `recibos_contrato` — quase → agora quase

O utilizador vê informações informativas sobre o IRS Jovem e deduções com o NIF, mas não tem ações claras para realizar diretamente na aplicação. Provavelmente tentaria carregar nos links externos para ver o que acontece. A grande dúvida seria perceber o que deve fazer concretamente na aplicação no dia a dia.

- Palavras difíceis: IRS, NIF, IVA, e-fatura
- Melhoria sugerida: Adicionar botões de ação mais diretos para registar ou verificar documentos dentro da própria app.
- Modelo: `gemini-flash-lite-latest`

### `recibos_emitir` — quase

O utilizador vê um guia passo a passo com instruções claras e um texto pronto a copiar para emitir um recibo verde. O que faria a seguir seria abrir o Portal das Finanças e seguir os passos indicados na aplicação. O que o travaria seria a necessidade de saltar entre a aplicação e o site externo das Finanças, o que pode gerar confusão a quem não tem prática.

- Palavras difíceis: NIF, TVDE
- Melhoria sugerida: Adicionar botões de atalho direto para os passos do Portal das Finanças sempre que possível, evitando que o utilizador tenha de navegar sozinho no site externo.
- Modelo: `gemini-flash-lite-latest`

### `recibos_empresa` — NÃO → agora quase

Um utilizador leigo vê informação genérica sobre empresas e prazos fiscais, mas não percebe o que deve fazer exatamente. Tentaria carregar nas datas ou nos links para perceber como resolver as obrigações. No entanto, ficaria travado por termos técnicos e pela falta de botões de ação direta para resolver cada pendente.

- Palavras difíceis: NIPC, IRC, SAF-T, IVA, AT
- Melhoria sugerida: Adicionar botões de ação clara em cada item da lista (por exemplo, 'Enviar' ou 'Consultar') para orientar o utilizador sobre o próximo passo prático.
- Modelo: `gemini-flash-lite-latest`

### `recibos_irs` — quase

Uma pessoa leiga percebe que deve guardar o valor indicado para impostos, mas pode assustar-se com as datas e valores futuros apresentados. Como o ecrã é apenas informativo e não tem botões de ação, o utilizador ficaria sem saber o que fazer a seguir. A principal barreira é a falta de clareza sobre se é necessário realizar alguma operação imediata ou se basta aguardar.

- Palavras difíceis: IRS, Adiantamentos do IRS, pagamentos por conta
- Melhoria sugerida: Adicionar um botão ou indicação clara no fundo a explicar o próximo passo, como por exemplo 'Como pagar' ou 'Entendido'.
- Modelo: `gemini-flash-lite-latest`

### `recibos` — quase → agora quase

O utilizador vê uma calculadora simples para calcular o valor líquido do recibo verde a partir do valor ganho nas plataformas. A linguagem é acessível, mas termos técnicos como 'IVA', 'Retenção na fonte' e artigos legais podem gerar alguma confusão inicial. O que o travaria é ter de decidir entre as opções de retenção e IVA sem saber qual se aplica ao seu caso específico.

- Palavras difíceis: IVA, Retenção na fonte, art. 53.º
- Melhoria sugerida: Adicionar uma pergunta inicial simples para preencher automaticamente as opções de retenção e IVA.
- Modelo: `gemini-flash-lite-latest`

### `recibos_passar_fatura` — quase

O utilizador percebe que deve preencher os dados do serviço prestado para emitir um documento oficial. A pessoa tentaria carregar no botão verde final, mas hesitaria ao ver termos técnicos sobre impostos que não compreende. O que a travaria seria a dúvida sobre se deve ou não ativar a retenção de IRS ou se o regime de isenção de IVA está correto para o seu caso específico.

- Palavras difíceis: NIF, TVDE, Retenção de IRS, IVA, Regime de isenção (artigo 53.º)
- Melhoria sugerida: Adicionar um pequeno ícone de ajuda ou um link 'O que é isto?' junto a cada termo técnico para explicar as consequências de cada escolha de forma simples.
- Modelo: `gemini-3.1-flash-lite`

### `recibos_sem_fatura` — quase

O utilizador percebe que deve inserir um valor monetário, mas sente-se perdido perante termos técnicos como 'Retenção na fonte' ou 'art. 53.º'. A pessoa tentaria preencher o campo de valor, mas travaria ao ter de escolher entre as várias opções de percentagens sem saber qual se aplica à sua situação específica. Falta uma indicação clara de qual opção escolher caso não saiba o seu enquadramento fiscal.

- Palavras difíceis: IVA, Retenção na fonte, art. 53.º
- Melhoria sugerida: Adicionar um pequeno botão de ajuda ou 'Não sei o que escolher' que explique de forma simples como verificar qual a taxa correta no portal das Finanças.
- Modelo: `gemini-3.1-flash-lite`

### `recibos_ss` — quase

O utilizador vê um resumo informativo sobre obrigações fiscais, percebendo que está isento de Segurança Social e que deve poupar dinheiro para o IRS. No entanto, como não existe nenhum botão de ação ou tarefa clara, o utilizador fica sem saber se precisa de configurar algo ou apenas ler. A falta de um botão de 'próximo passo' ou 'ver detalhes' pode causar insegurança sobre se a app está a funcionar corretamente.

- Palavras difíceis: IRS, Pagamentos por conta
- Melhoria sugerida: Adicionar um botão de ação claro no final de cada secção, como 'Ver histórico' ou 'Configurar pagamentos', para guiar o utilizador.
- Modelo: `gemini-3.1-flash-lite`

### `reforma_cadeado` — quase

O utilizador percebe que está a ver uma simulação da sua futura reforma baseada nos anos de descontos. A pessoa tentaria ajustar os anos com os botões de mais e menos para ver como o valor muda. O que a travaria é a incerteza sobre se estes valores são reais ou apenas uma estimativa genérica, e a falta de um botão de ação claro para guardar ou validar esta informação.

- Palavras difíceis: IA, Pro
- Melhoria sugerida: Adicionar um pequeno texto explicativo ou um link de 'Saber mais' que clarifique que estes dados são calculados com base no histórico real do utilizador ou se são apenas uma simulação hipotética.
- Modelo: `gemini-3.1-flash-lite`

### `reforma` — quase → agora sim

O utilizador percebe que está a ver uma estimativa da sua futura reforma e informações sobre direitos sociais. A pessoa tentaria ajustar os anos com os botões de mais e menos para ver diferentes cenários. O que a travaria é a falta de um botão de ação ou de um próximo passo claro, pois o ecrã é apenas informativo.

- Palavras difíceis: estimativa simples, carreira
- Melhoria sugerida: Adicionar um botão de 'Ver detalhes da minha carreira' ou 'Simular outro cenário' para dar continuidade à navegação.
- Modelo: `gemini-3.1-flash-lite`

### `suporte_bug` — sim

O utilizador percebe que algo correu mal e que deve descrever o problema nos campos de texto para enviar à equipa de suporte. A pessoa preencheria o assunto e a descrição, clicando depois em 'Enviar'. O que poderia travar o utilizador é a dúvida sobre se o envio é automático ou se precisa de anexar capturas de ecrã manualmente.

- Palavras difíceis: plano
- Melhoria sugerida: Adicionar um botão ou indicação clara para 'Anexar captura de ecrã' para facilitar o diagnóstico do erro.
- Modelo: `gemini-3.1-flash-lite`

### `suporte` — sim

O utilizador vê um menu de suporte claro com opções para tirar dúvidas, reportar erros ou pedir reembolsos. A pessoa saberia clicar na opção correspondente ao seu problema ou consultar o histórico dos pedidos anteriores. O que poderia travar alguém menos experiente é a incerteza sobre se o pedido será respondido por uma pessoa ou por um sistema automático.

- Palavras difíceis: Google Play
- Melhoria sugerida: Adicionar um botão de chat direto ou um ícone de 'Novo Pedido' mais visível para reforçar que é possível iniciar uma conversa nova.
- Modelo: `gemini-3.1-flash-lite`

### `suporte_reembolso` — quase

O utilizador percebe que a gestão do pagamento não é feita diretamente na aplicação, mas sim através da Google Play. Ao carregar no botão verde, espera ser redirecionado para as definições da sua conta Google para cancelar a subscrição. O que pode travar a pessoa é a incerteza sobre onde exatamente, dentro da Google Play, encontrará a opção de reembolso ou cancelamento após o redirecionamento.

- Palavras difíceis: subscrições, Google Play
- Melhoria sugerida: Adicionar um pequeno passo a passo visual ou um link direto para o artigo de suporte da Google que explica como cancelar subscrições.
- Modelo: `gemini-3.1-flash-lite`

### `suporte_vazio` — sim

O utilizador vê um menu de ajuda claro com opções para dúvidas, problemas técnicos ou cancelamentos. A pessoa escolheria a opção que melhor descreve o seu problema para avançar. O que a poderia travar é a incerteza sobre se o 'assistente' é uma pessoa real ou um robô automático.

- Palavras difíceis: dados técnicos
- Melhoria sugerida: Adicionar uma pequena nota a explicar que o assistente é um chat automático ou humano, para gerir expectativas.
- Modelo: `gemini-3.1-flash-lite`

### `vale_falta_carro` — sim

O utilizador percebe que deve preencher os campos com os dados da viagem e do seu veículo para obter um cálculo de rendimento líquido. A pessoa preencheria os valores solicitados nos campos de input, mas poderia sentir-se travada por não saber onde encontrar o consumo médio do carro no livrete ou computador de bordo.

- Palavras difíceis: livrete, computador de bordo
- Melhoria sugerida: Adicionar um botão ou link 'Onde encontro isto?' junto aos campos do carro que abra um pequeno guia visual ou exemplo.
- Modelo: `gemini-3.1-flash-lite`

### `vale_perde` — quase → agora quase

O utilizador percebe que está a analisar a rentabilidade de uma viagem, vendo os custos detalhados e o prejuízo final. A pessoa tentaria provavelmente fechar o ecrã ou procurar um botão de 'Guardar' ou 'Concluir', mas a falta de uma ação clara no final pode gerar confusão. O que trava o utilizador é a incerteza sobre se esta informação está a ser guardada ou se é apenas uma simulação rápida.

- Palavras difíceis: IRS, Segurança Social, Retenção
- Melhoria sugerida: Adicionar um botão de ação claro no fundo, como 'Guardar esta viagem' ou 'Voltar ao início', para dar uma conclusão ao fluxo.
- Modelo: `gemini-3.1-flash-lite`

### `vale_sobra_bem` — sim

O utilizador vê campos claros para inserir os dados da viagem e percebe imediatamente que o objetivo é calcular o lucro real. A pessoa preencheria os valores e leria o resumo final abaixo. O que pode travar o utilizador é a incerteza sobre se o valor de 'Segurança Social' ou 'Desgaste' está correto ou se precisa de ser ajustado manualmente.

- Palavras difíceis: Segurança Social
- Melhoria sugerida: Adicionar um botão de 'Calcular' ou 'Ver resultado' para confirmar a ação, em vez de atualizar o ecrã automaticamente.
- Modelo: `gemini-3.1-flash-lite`

### `vale_sobra_bem_resposta` — quase

O utilizador percebe que está a analisar a rentabilidade de uma viagem, vendo os custos detalhados e o lucro final. A pessoa sentir-se-ia tentada a carregar no botão 'Não me tiram nada' para ajustar o cálculo do IRS. No entanto, a falta de um botão de 'Guardar' ou 'Concluir' deixa o utilizador confuso sobre se a informação foi registada ou se é apenas uma simulação.

- Palavras difíceis: IRS, Segurança Social, Retenção
- Melhoria sugerida: Adicionar um botão de ação clara no final, como 'Guardar este registo', para confirmar a conclusão da tarefa.
- Modelo: `gemini-3.1-flash-lite`

### `vale_vazio` — sim

O utilizador percebe que deve preencher os campos com os dados da viagem e do seu veículo para obter um cálculo de rentabilidade. A pessoa preencheria os campos de valor, distância e consumo, mas poderia sentir-se insegura sobre onde clicar para ver o resultado final, já que não existe um botão de ação claro.

- Palavras difíceis: L/100 km, livrete
- Melhoria sugerida: Adicionar um botão de ação destacado no final do ecrã com o texto 'Calcular lucro' ou 'Ver resultado'.
- Modelo: `gemini-3.1-flash-lite`

### `vida_detalhe_conta` — sim

O utilizador percebe que tem uma conta para pagar e vê claramente os dados necessários para o fazer. A pessoa sentir-se-ia confortável em copiar os dados ou usar o botão de MB WAY, pois as instruções abaixo são simples. O que poderia travar alguém é a dúvida sobre se o pagamento foi confirmado após a ação.

- Palavras difíceis: Multibanco, MB WAY
- Melhoria sugerida: Adicionar um botão de 'Confirmar pagamento' ou 'Já paguei' após a realização da operação para dar segurança ao utilizador.
- Modelo: `gemini-3.1-flash-lite`

### `vida_entra_cheio` — quase

O utilizador percebe que esta é uma lista de rendimentos e que o botão verde serve para adicionar um novo valor. No entanto, pode sentir-se confuso sobre se deve registar manualmente cada entrada ou se a app deveria importar os dados automaticamente. A falta de contexto sobre como categorizar ou validar estes valores pode gerar insegurança.

- Palavras difíceis: Recibo verde
- Melhoria sugerida: Adicionar um pequeno texto explicativo ou um ícone de ajuda que esclareça se o registo é manual ou automático.
- Modelo: `gemini-3.1-flash-lite`

### `vida_entra_erro` — sim

O utilizador vê um resumo financeiro vazio e um aviso de erro de ligação. A pessoa entenderia que deve carregar no botão verde 'Escrevi que ganhei' para registar os seus rendimentos. O que a travaria seria a incerteza sobre se o erro de ligação impede o registo dos dados ou se deve tentar novamente mais tarde.

- Melhoria sugerida: Adicionar um botão de 'Tentar novamente' dentro da caixa de erro para facilitar a resolução do problema de ligação.
- Modelo: `gemini-3.1-flash-lite`

### `vida_entra_vazio` — sim

O utilizador vê um resumo financeiro vazio e percebe que precisa de registar os seus rendimentos. A ação óbvia é carregar no botão verde 'Escrevi que ganhei' na parte inferior. O que pode travar a pessoa é a dúvida sobre se o que registar aqui tem impacto direto nas Finanças ou se é apenas um bloco de notas pessoal.

- Melhoria sugerida: Adicionar uma pequena nota informativa a explicar que este registo é apenas para controlo pessoal e não substitui a emissão de recibos verdes.
- Modelo: `gemini-3.1-flash-lite`

### `vida_importar_extrato` — quase

O utilizador percebe que carregou um ficheiro do banco e vê um resumo dos dados lidos. A pessoa sentir-se-ia tentada a carregar no botão verde 'Guardar 8 movimentos' para concluir a tarefa. O que a travaria seria a incerteza sobre o que significa exatamente 'arrumar' os movimentos e se isso terá consequências fiscais que não compreende.

- Palavras difíceis: CSV, Excel
- Melhoria sugerida: Adicionar uma pequena frase explicativa abaixo do botão 'Guardar' que diga 'Isto apenas organiza os teus gastos na app, não altera nada nas Finanças'.
- Modelo: `gemini-3.1-flash-lite`

### `vida_nova_entrada` — sim

O utilizador percebe que deve inserir o valor ganho e selecionar a origem desse rendimento numa lista clara. A pessoa saberia clicar na opção correspondente ao seu caso, mas poderia hesitar se o valor a inserir deve ser o bruto ou o líquido. A falta de indicação sobre qual o valor exato a declarar pode gerar insegurança.

- Palavras difíceis: Recibo verde
- Melhoria sugerida: Adicionar uma pequena nota de ajuda abaixo do campo de input a esclarecer se deve ser inserido o valor bruto ou líquido.
- Modelo: `gemini-3.1-flash-lite`

### `vida_recorrentes` — sim

O utilizador percebe que a app identificou despesas recorrentes e oferece opções para gerir cada uma. A pessoa sentir-se-ia tentada a clicar em 'Como cancelar' ou 'Avisa-me antes' para testar a funcionalidade. O que poderia travar o utilizador é a dúvida sobre se a app tem permissão real para cancelar serviços ou se apenas fornece instruções genéricas.

- Palavras difíceis: débitos diretos
- Melhoria sugerida: Adicionar uma pequena nota explicativa sobre o que acontece ao clicar em 'Como cancelar' para clarificar se é um processo automático ou apenas informativo.
- Modelo: `gemini-3.1-flash-lite`

### `vida_recorrentes_vazio` — quase

O utilizador percebe que precisa de carregar no botão verde para avançar, mas pode sentir receio sobre o que significa 'importar o extrato'. A pessoa veria o botão como a única ação possível, mas ficaria travada pelo medo de partilhar dados bancários sensíveis com uma aplicação que não conhece bem.

- Palavras difíceis: extrato
- Melhoria sugerida: Adicionar uma pequena nota de segurança ou ícone de cadeado a explicar que a ligação ao banco é segura e apenas para leitura.
- Modelo: `gemini-3.1-flash-lite`

### `vida_sai_cheio` — quase

O utilizador vê um resumo de despesas pendentes e contas em atraso, percebendo que tem pagamentos por realizar. Teria a intenção de clicar nas contas para as pagar, mas ficaria travado por não existir um botão de ação direta ou indicação de como efetuar o pagamento dentro da aplicação. A falta de clareza sobre se a app apenas regista ou se permite pagar efetivamente gera incerteza.

- Palavras difíceis: Valor por saber
- Melhoria sugerida: Adicionar um botão 'Pagar' ou 'Marcar como pago' dentro de cada conta para tornar a ação imediata e clara.
- Modelo: `gemini-3.1-flash-lite`

### `vida_sai_vazio` — sim

O utilizador vê um resumo financeiro vazio e percebe claramente que deve adicionar as suas despesas mensais. A ação óbvia é clicar no botão verde 'Nova conta' para começar a registar os seus gastos. O que pode travar o utilizador é a dúvida sobre se 'conta' se refere a uma conta bancária ou a uma fatura de despesa, dado o exemplo dado na descrição.

- Palavras difíceis: conta
- Melhoria sugerida: Alterar o texto do botão 'Nova conta' para 'Adicionar despesa' para evitar confusão com contas bancárias.
- Modelo: `gemini-3.1-flash-lite`

### `vida_sobra_bom` — quase

O utilizador vê um resumo financeiro do mês e percebe que tem dinheiro disponível, mas não sabe como registar novas despesas ou receitas. A falta de botões de ação claros, como um sinal de '+' para adicionar movimentos, deixaria o utilizador confuso sobre como interagir com a app. A terminologia sobre o 'cofre do imposto' também pode gerar insegurança sobre se o dinheiro está a ser retido automaticamente ou se precisa de uma ação manual.

- Palavras difíceis: Cofre do imposto
- Melhoria sugerida: Adicionar um botão de ação flutuante (FAB) com um sinal de '+' para permitir adicionar rapidamente uma nova despesa ou receita.
- Modelo: `gemini-3.1-flash-lite`

### `vida_sobra_carregar` — NÃO → agora quase

O utilizador vê um ecrã vazio com separadores, mas não percebe se tem de inserir dados manualmente ou se a app deveria ter importado algo automaticamente. A falta de um botão de ação (como um sinal de +) deixa o utilizador sem saber como começar a registar as suas finanças. O que trava o utilizador é a ausência de instruções ou de um ponto de entrada claro para iniciar a utilização da funcionalidade.

- Melhoria sugerida: Adicionar um botão de ação flutuante com um sinal de '+' e uma mensagem de estado vazio a explicar como adicionar o primeiro movimento financeiro.
- Modelo: `gemini-3.1-flash-lite`

### `vida_sobra_mau` — quase → agora quase

O utilizador percebe que está em défice financeiro e que precisa de agir, mas não sabe como executar as sugestões dadas. A pessoa tentaria procurar um botão de 'adicionar' ou 'editar' para corrigir os valores, mas a falta de uma ação clara no ecrã causaria hesitação. O utilizador ficaria travado por não saber onde exatamente inserir os dados em falta ou como categorizar as despesas para reduzir o valor.

- Palavras difíceis: Falta pagar ao Estado, No cofre do imposto
- Melhoria sugerida: Adicionar botões de ação direta como 'Adicionar rendimento' ou 'Ver despesas' dentro do bloco vermelho para guiar o utilizador na resolução do problema.
- Modelo: `gemini-3.1-flash-lite`

### `vida_sobra_vazio` — quase

O utilizador percebe que precisa de inserir dados, mas pode sentir-se confuso sobre se deve introduzir tudo manualmente ou importar o extrato. O botão 'Escrever a primeira coisa' é claro, mas a opção de importar extrato pode gerar receio quanto à segurança bancária. O que trava o utilizador é a incerteza sobre o que acontece aos dados após a importação e se a app é segura.

- Palavras difíceis: extrato
- Melhoria sugerida: Adicionar uma pequena nota de segurança ou um ícone de cadeado junto ao botão 'Importar extrato' para transmitir confiança ao utilizador.
- Modelo: `gemini-3.1-flash-lite`

## Provas de máquina

```
$ flutter analyze --no-fatal-infos
1 issue found. (ran in 15.6s)   ← só o aviso pré-existente de `anonKey` deprecado

$ flutter test test/unit -r compact
00:22 +179: All tests passed!

$ flutter test test/golden -r compact
01:44 +134: All tests passed!   ← 668 fotos em test/golden/_fotos/

$ python tool/juiz/vision_judge.py --modo simplicidade --retomar docs/provas/telas/simplicidade_20260918-115212.json
relatório: docs/provas/telas/simplicidade_20260918-140719.md · {'verde': 46, 'amarelo': 60, 'vermelho': 5, 'erro': 0}

$ python tool/juiz/vision_judge.py --modo simplicidade --fotos <27 ecrãs mexidos>
relatório: docs/provas/telas/simplicidade_20260918-143054.md · {'verde': 3, 'amarelo': 24, 'vermelho': 0, 'erro': 0}
```

## Decisões

D64 («O que é isto?»), D65 (esqueleto diz que carrega), D66 (linha simples em cada acesso do Mais), D67 (juiz roda em qualquer 404 e retoma só os erros) em `docs/DECISOES.md`.
