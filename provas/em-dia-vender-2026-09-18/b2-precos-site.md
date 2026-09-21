# B2 (parte sem dinheiro) — página de preços no site, a ler `regras_legais` — 2026-09-21

> Missão `em-dia-vender-2026-09-18`, Bloco 2. A parte com dinheiro (perfil de pagamentos, os 4 produtos na Play, prova de
> compra com conta de teste, ligar `validar-compra-play`) fica bloqueada pelo contrato de pagamentos — o clique do Danilo.

## Quem fez o quê
- **ChatGPT Plus (gpt-5.5, opencode)**, `delegar.ps1 chatgpt … -Id b2-precos-site` (301 s, anti-mentira PASSOU):
  `site/precos.html` (3 cartões Grátis/Pro/Família-Frota; preços mensal/anual lidos por REST anónimo de `regras_legais`
  com «—» a carregar e «preço na app» se falhar; «(poupas X %)» calculado; «1.º mês grátis na Google Play»; como cancelar;
  desistir em 14 dias → /termos; iPhone/computador = PWA no grátis; FAQ), rodapé + sitemap + asserção no verificador;
  em `site/index.html` tirou os preços escritos à mão (JSON-LD e texto de reserva) — ficam só os lidos da tabela.
- **Claude Code**: reviu, publicou (`tool/site/publicar.ps1`) e verificou no ar.

## Provas literais
```
node --check site/testes/verifica.mjs → ok
publicar.ps1 → ✨ Deployment complete! https://372f035f.em-dia-site.pages.dev
node site/testes/verifica.mjs https://emdia.boraguarda.com → PASSA /precos 200 com título, Google Play e 14 dias
  61 asserções passaram / 0 falharam
REST anónimo (a mesma chamada que a página faz):
  [{"chave":"preco_familia_anual","valor_num":49.9},{"chave":"preco_familia_mensal","valor_num":5.99},
   {"chave":"preco_pro_anual","valor_num":29.9},{"chave":"preco_pro_mensal","valor_num":3.49}]
```
O ecrã do plano na app já mostra mensal ao lado do anual, os cadeados por plano e «cancelas quando quiseres» (B7 da
missão anterior) e agora a linha dos termos + 14 dias (B4b).

## Bloqueado pelo clique do Danilo (contrato de pagamentos)
Criar os 4 produtos (`pro_mensal` 3,49 €, `pro_anual` 29,90 €, `familia_mensal` 5,99 €, `familia_anual` 49,90 €, 1.º mês
grátis, impostos PT) — `tool/play/api.py cria_subscricao` está pronto; conta de teste de licença; prova de compra.
