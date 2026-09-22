# B5 - dinheiro e decisao gratis

## Decisao aplicada no repo

Registei a decisao D76 em `docs/DECISOES.md`:

```text
D76 — Primeira submissão grátis, sem compras dentro da app
A app vai para a loja grátis, com os planos pagos desligados por interruptor.
Enquanto não existirem produtos publicados na Google Play, o botão de comprar não aparece e a ficha da loja não declara compras dentro da app.
```

## Ficha da Play ajustada

Ficheiro alterado: `docs/PLAY-FICHA-RESPOSTAS.md`.

Tambem alinhei a ficha antiga em `docs/loja/descricao-play.md`, que ainda dizia `30 dias gratis, sem cartao`.

Pontos alinhados nesta sessao:

```text
Descricao pt-PT/pt-BR: app gratis nesta primeira versao.
Classificacao: Compras digitais = Nao nesta primeira submissao.
Funcionalidades financeiras: nesta submissao nao ha compras dentro da app.
Seguranca dos dados: Historico de compras nao declarar nesta submissao.
Notas de revisao: nesta primeira versao nao ha compras dentro da app.
Produtos de subscricao: nao criar nesta submissao.
```

## O que nao fiz

Nao criei produtos, nao aceitei contrato de pagamentos, nao toquei em Stripe, Play Billing real, `assinaturas` ou dinheiro real.

O perfil de pagamentos continua item do Danilo, porque aceita contrato, NIF/IBAN e dados fiscais.

## e2e_log

Nao gravado por esta sessao: a Auth local recusou login com `captcha_failed` no B-1.
