# B1 - web pronta para receber pessoas

## Feito

- App Flutter: o ecra `Plano` le `regras_legais.planos_a_venda` e `promessa_gratis_texto`.
- Com `planos_a_venda != sim`, a app mostra a promessa legal no topo do ecra de plano e esconde botoes de compra/gestao Google Play.
- Atalhos de subscricao no cadeado da IA e no suporte respeitam o mesmo interruptor.
- Site `/precos`: mostra a promessa legal vinda de `regras_legais` e deixa os botoes `Assinar na app` escondidos por defeito; so aparecem se `planos_a_venda=sim`.
- Site principal: tirou "30 dias gratis" e adicionou passos claros para por a app web no ecra inicial no iPhone e Android.

## Provas

Analyze depois das alteracoes:

```text
flutter analyze --no-fatal-infos
1 issue found: info antiga de anonKey deprecated em lib/services/arranque.dart:64:5
```

Teste do site:

```text
node site\testes\verifica.mjs
61 assercoes passaram / 0 falharam
```

SEO / indexacao:

```text
url=https://emdia.boraguarda.com/robots.txt status=200 length=93 noindex=False
url=https://emdia.boraguarda.com/sitemap.xml status=200 length=1148 noindex=False
url=https://emdia.boraguarda.com/ status=200 length=57300 noindex=False
url=https://emdia.boraguarda.com/precos status=200 length=10487 noindex=False
url=https://app.emdia.boraguarda.com/robots.txt status=200 length=634 noindex=True
```

Conclusao: site publico indexavel, app web fechada aos motores de busca.

## Limite real

Nao fiz prova de conta nova real com codigo por e-mail nesta sessao, porque isso exige fluxo de Auth com Turnstile/sessao real. Fica pedido em `docs/PARA-A-CLAUDE-AI.md` para a Claude.ai se for preciso fazer pelo Chrome do Danilo.

## Telegram

Pendente de envio no fecho B1/B2 conjunto.

## e2e_log

Linha material pendente para Claude.ai, como registado em `docs/PARA-A-CLAUDE-AI.md`.
