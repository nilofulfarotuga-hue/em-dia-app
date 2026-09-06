# Prova — juiz de visão em todos os ecrãs (2026-09-06, noite)

A missão pede o juiz de visão «sem vermelhos». Até esta noite ele só tinha
olhado para o login. Passei-o por **todos** os ecrãs: uma foto por ecrã, tamanho
médio, em PT-PT (41 ecrãs da app) e as 13 do painel de administração.

## App: 41 ecrãs, **zero vermelhos**

```
{'verde': 19, 'amarelo': 22, 'vermelho': 0, 'erro': 0}
```

Relatório: `docs/provas/telas/vision_report_20260906-135206.md`.

## Painel de administração: o juiz estava a gritar por tudo

À primeira passagem deu **1 verde, 11 amarelos e 1 vermelho**. Fui ver os
motivos e quase nenhum era defeito:

- Os 11 amarelos eram quase todos *«tem palavras difíceis e termos técnicos»*,
  *«palavras em inglês»*, *«o pai e a mãe não percebem»*. Mas o painel é PT-BR e
  é uma consola interna para **uma** pessoa técnica — a regra da linguagem de
  criança de 5 anos é da APP, não do painel. O juiz estava a aplicar a regra
  errada.
- O único vermelho foi `admin_erro`, que é uma fotografia **de propósito** do
  ecrã de erro. O próprio teste chama-se *«admin_erro: leitura falhada mostra
  Aviso vermelho»* e verifica que aparece «Não consegui ler os dados» e o botão
  «Tentar de novo». Ou seja: o ecrã estava a fazer exactamente o que devia, e o
  juiz reprovou-o por isso.

Um juiz que reprova o certo não serve para nada — passa a ser ignorado, e no dia
em que apanhar um defeito a sério ninguém liga. Por isso arranjei o juiz:

- ecrãs `admin_*` são julgados como **consola interna** (termos técnicos, nomes
  de tabelas e palavras em inglês deixam de ser defeito; continua a reprovar
  texto por cima de texto, colunas cortadas, botões pela metade);
- ecrãs de **estado propositado** (`_erro`, `_vazio`, `_skeleton`, `_cadeado`,
  `_limite`, `_breve`, `conta-nao-abriu`) passam a ser julgados pela pergunta
  certa: *«este estado está bem explicado e tem saída?»*, em vez de *«porque é
  que isto está vazio/em erro?»*.

Mesmas 13 fotos, com o juiz arranjado:

```
antes:  {'verde': 1,  'amarelo': 11, 'vermelho': 1, 'erro': 0}
depois: {'verde': 12, 'amarelo': 1,  'vermelho': 0, 'erro': 0}
```

E o `admin_erro` passou a **verde**, com a razão certa: *«o estado de erro de
permissão está claramente indicado com um alerta explicativo e botão para tentar
de novo»*.

Nos ecrãs de estado da app a mudança foi igual: `carro_vazio`, `ia_vazio`,
`suporte_vazio`, `carro_cadeado`, `reforma_cadeado`, `conta-nao-abriu` e
`painel_erro` passaram todos a **verde**, cada um com a explicação do caminho de
saída que oferecem.

## O único amarelo do painel é verdadeiro — e fui confirmá-lo

*«A coluna de erro na tabela está cortada no lado direito»*
(`admin_avisos_desktop_br.png`). Abri a foto: é verdade, o cabeçalho «Erro» está
cortado a meio da palavra e o valor `FCM…` também.

Mas fui ao código antes de mexer: `TabelaAdmin`
(`lib/admin/admin_widgets.dart:229`) já envolve a `DataTable` num
`SingleChildScrollView(scrollDirection: Axis.horizontal)`. **A tabela rola de
lado** — a coluna não está perdida, está fora do enquadramento da fotografia.
O que falta é só uma pista visual de que há mais à direita. Não é defeito de
funcionamento e não mexi.

## Um vermelho da app que fui verificar e NÃO é defeito

Na passagem dos estados, o `ia_limite_medio_pt` veio **vermelho**: *«o texto com
o número de perguntas usadas está tapado e cortado pela primeira caixa de
mensagem»*. Na passagem anterior a mesma foto tinha vindo amarela — o juiz
hesita nesta.

Fui ao código: `lib/screens/ia/ia_screen.dart` põe o cabeçalho e a conversa como
**irmãos dentro de uma `Column`** (cabeçalho na linha 177, `Expanded(ListView)`
na 190). Não há `Stack`, não há sobreposição nenhuma. O que se vê é uma conversa
rolada até ao fim: a primeira bolha visível está cortada pelo topo da lista, como
em qualquer conversa. **Não é defeito.** Fica escrito para não se andar a
persegui-lo outra vez.

## O que eu vi com os meus olhos e vale a pena decidir

No mesmo ecrã do limite da IA, a mesma mensagem aparece **três vezes**:

1. no cabeçalho — «Usaste 5 de 5 perguntas este mês»;
2. num cartão roxo — «No plano grátis tens 5 perguntas por mês. Usaste 5.» com
   «Ver o plano Pro»;
3. na barra de baixo — «Ativa o Pro para perguntas sem limite.»

Três avisos a dizer o mesmo, e dois deles a vender. Não lhe toquei porque é o
ecrã que leva à assinatura — mexer aí é decisão de negócio, tua. A minha opinião:
ficava melhor com o cabeçalho e a barra de baixo, e sem o cartão roxo do meio.

## Os 22 amarelos da app

Quase todos são a mesma família: *jargão sem explicação* — IRS, IVA, TVDE,
«isento», «folha de cálculo». Isso é a regra 1 do `CLAUDE.md` a ser aplicada
com razão, e é uma passagem de conteúdo (reescrever textos em `lib/l10n/partes/`)
que se faz com calma e com o Danilo a ler, não de madrugada. Ficam listados um a
um no relatório do juiz.

## Como se repete

```bash
python tool/juiz/vision_judge.py --filtro medio_pt   --max 41   # a app, 1 foto por ecrã
python tool/juiz/vision_judge.py --filtro desktop_br --max 13   # o painel
```
