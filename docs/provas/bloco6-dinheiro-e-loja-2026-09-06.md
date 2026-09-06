# Prova — Bloco 6: dinheiro e loja (2026-09-06, 18h30)

> ⚠️ **Este bloco mexe em dinheiro.** Regra da casa: preparar tudo, aplicar só
> com o "vai" do Danilo. Nada aqui foi activado. Os quatro produtos existem em
> ensaio, os planos base nascem em rascunho, e ninguém consegue comprar.

## 1. O trial é do servidor, e o telemóvel não lhe toca

`profiles.trial_ate` tem por omissão `now() + interval '30 days'`. Não é o
telemóvel que a escreve — é a base, no momento em que a conta nasce. As quatro
contas que existem hoje:

```
3acbfc8d…  free  criado 2026-09-06  trial até 2026-10-06  →  30 dias
500f99a2…  free  criado 2026-09-06  trial até 2026-10-06  →  30 dias
b05a7458…  free  criado 2026-09-06  trial até 2026-10-06  →  30 dias
083cfbfc…  free  criado 2026-09-06  trial até 2026-10-06  →  30 dias
```

### E o telemóvel a tentar fazer batota

Com a sessão de um utilizador **normal** (`083cfbfc…`, que não está na tabela
`admins`), a falar directamente com a base:

| O que tentou | O que aconteceu |
|---|---|
| Esticar o trial 10 anos | **IGNORADO** — ficou 2026-10-06 |
| Subir-se a Família | **IGNORADO** — ficou `free` |
| Mudar o `banido` | **IGNORADO** — ficou `false` |

Quem faz isto é o gatilho `protege_campos_servidor`, que repõe os valores
antigos em silêncio. **Nota de desenho, para quem vier a seguir:** ele não
recusa com erro, repõe. É de propósito — a app não precisa de saber que tentou
—, mas quem estiver a depurar tem de saber, senão passa uma hora a perguntar-se
porque é que o UPDATE "correu bem" e não mudou nada.

### Um susto que valeu a pena, e fica escrito

À primeira tentativa este teste deu **"PASSOU!"** nas duas linhas, e por um
minuto pareceu um buraco de segurança. Não era: eu tinha corrido o teste com a
conta `500f99a2…`, **que é administradora** — e a trava deixa os admins passar,
que é exactamente o que ela deve fazer. O defeito estava no teste, não na trava.

Deixou estrago, e foi reposto: a conta ficou com `trial_ate` em 2036 e plano
`familia` durante o teste, e voltou a `criado_em + 30 dias` e a `free` a
seguir — está na tabela acima. **Lição: um teste de segurança feito com a conta
do dono não prova nada.** Faz-se sempre com uma conta que não é ninguém.

## 2. Os quatro produtos da Play — ensaiados, nenhum criado

```
$ python tool/play/produtos.py
- subscriptions.list -> 0 já existem: (nenhuma)
- ENSAIO pro_mensal      · Em Dia Pro (mensal)     · P1M · 3,49 €  · plano base em DRAFT (não criado)
- ENSAIO pro_anual       · Em Dia Pro (anual)      · P1Y · 29,90 € · plano base em DRAFT (não criado)
- ENSAIO familia_mensal  · Em Dia Família (mensal) · P1M · 5,99 €  · plano base em DRAFT (não criado)
- ENSAIO familia_anual   · Em Dia Família (anual)  · P1Y · 49,90 € · plano base em DRAFT (não criado)
```

O comportamento por omissão é ensaio: mostra o que ia fazer e não faz. Só com
`--criar` é que cria, e mesmo aí os planos base nascem em **rascunho** —
ninguém compra nada até alguém os activar à mão. **Activar é o "vai".**

Os preços não são decisão minha: vêm do prompt da missão e vivem em
`regras_legais` (`preco_pro_mensal`, `preco_pro_anual`, `preco_familia_mensal`,
`preco_familia_anual`). O ecrã do plano lê-os de lá — mudar um preço não obriga
a publicar app nova.

**O que trava:** a Google recusa criar subscrições sem perfil de pagamentos.
Resposta literal da API: `HTTP 400 FAILED_PRECONDITION: "Cannot create a
subscription without first registering a payments profile for the developer
account."` Pede dados fiscais, morada, conta bancária e identidade — a Google
exige a pessoa. Está em `docs/PENDENTE-DANILO.md`.

## 3. A app já sabe comprar

`lib/services/compras.dart` conhece os quatro produtos e ouve o
`purchaseStream`; `lib/screens/plano/plano_screen.dart` lê os preços das regras
e chama `comprar(...)`. Quando a loja não responde (é o caso hoje, porque os
produtos ainda não existem), os botões ficam **desligados** em vez de darem
erro — a pessoa vê os preços e vê que ainda não dá.

A validação da compra é do servidor (`validar-compra-play`), não do telemóvel:
o telemóvel manda o recibo, o servidor pergunta à Google se é verdadeiro.

## 4. A ficha da loja e a segurança dos dados

Feito e no repositório: `docs/loja/descricao-play.md`, oito capturas
(`docs/loja/play/captura-1..8.png`), o gráfico de destaque 1024×500 e o ícone
512. A declaração de segurança dos dados está escrita em
`docs/loja/play/data-safety-em-dia.csv`.

**O que trava:** o modelo público da Google está desactualizado e falta-lhe a
pergunta `PSL_SUPPORTED_ACCOUNT_CREATION_METHODS`; os identificadores de
resposta dela não estão publicados em lado nenhum (foram testados 20
candidatos contra a API, todos recusados) e não se inventam. Com o CSV
exportado da consola, fecha-se com um comando. É um clique.

## 5. Marketing — completo, à espera de quem o publique

| Peça | Estado |
|---|---|
| 20 posts para grupos | `docs/marketing/posts.md` — 20 escritos, 4 por cada um dos 5 públicos |
| 5 anúncios | `docs/marketing/anuncios.md` — TVDE, estafetas, brasileiros, cabeleireiras, mães |
| Calendário de 30 dias | `docs/marketing/calendario-30-dias.md` — 1 post por dia, rotativo, com hora pensada pelo hábito de cada público |
| 3 vídeos | `docs/videos/` — 30 s (a multa do TVDE), 15 s (loja), 60 s (explicativo) |
| Convite a testadores e respostas a comentários | `docs/marketing/` |

## O que fica em cima da mesa do Danilo

Nenhum destes é código. Estão todos em `docs/PENDENTE-DANILO.md`:

1. **Perfil de pagamentos da Play** — sem ele não há produtos, e sem produtos
   não há receita. É o primeiro da fila.
2. **Exportar o CSV da Segurança dos Dados** (1 clique).
3. **Activar os planos base** depois de existirem — é este passo que abre as
   compras a sério, e é o "vai".
4. **Como é que o revisor da Google entra na app** — a entrada é por código no
   e-mail e o revisor não tem acesso a essa caixa. Duas saídas prontas a
   executar; falta escolher qual.
