# B4 — site: secção «Também no iPhone — grátis por agora» e interruptor da App Store

Prova feita a 2026-09-23 com Chromium (Playwright) a servir `site/` em `http://localhost:8765` (o browser desta sessão na nuvem não chega a emdia.boraguarda.com: ERR_TUNNEL_CONNECTION_FAILED; o Supabase também é recusado pelo proxy, por isso as regras vêm vazias = interruptor desligado, que é o estado real de hoje).

Saída literal (`display` = estilo calculado; `visivel` = `offsetParent !== null`):

```
http://localhost:8765/index.html                      (interruptor desligado — sem ios_na_app_store na tabela)
  Experimentar o Pro grátis hidden=true display=flex visivel=true
  Começar grátis hidden=true display=flex visivel=true
  Descarregar na App Store hidden=true display=none visivel=false
http://localhost:8765/zz_ligado_tmp.html              (cópia com regras.ios_na_app_store='sim' injetado)
  Experimentar o Pro grátis hidden=true display=flex visivel=true
  Começar grátis hidden=true display=flex visivel=true
  Descarregar na App Store hidden=false display=flex visivel=true
```

- O botão da App Store (`https://apps.apple.com/pt/app/id6814807320`) nasce `hidden` e só aparece com `regras_legais.ios_na_app_store = 'sim'`. Hoje essa linha não existe → escondido. Ligar depois da aprovação da Apple (é uma linha na tabela, sem republicar).
- `site/testes/verifica.mjs` ganhou 3 asserções (secção, botão nasce hidden com o id certo, obedece a `ios_na_app_store`). Conferidas contra o ficheiro local com node: `1 true true`.

## Erro fora do scope encontrado (NÃO corrigido)

As linhas «Experimentar o Pro grátis» / «Começar grátis» acima: os botões `data-compra` têm `hidden=true` mas ficam **visíveis** (`display=flex`), porque `.btn{display:inline-flex}` ganha ao `[hidden]` do browser. O mesmo em `site/precos.html` («Assinar na app» ×2, medido da mesma forma). Com `planos_a_venda='nao'`, o site mostra botões de compra que não devia. A asserção do verificador («data-compra nasce hidden») só lê o atributo, por isso passava 62/62. Correção proposta (1 linha de CSS em cada página): `[data-compra][hidden]{display:none}`. Para o botão novo da App Store já foi posta a regra equivalente (`[data-appstore][hidden]{display:none}`).
