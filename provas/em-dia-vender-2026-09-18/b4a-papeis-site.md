# B4a — Papéis para vender em Portugal, no site — 2026-09-20

> Missão `em-dia-vender-2026-09-18`, Bloco 4 parte a (site + docs). Parte b (avisos e ligações dentro da app) a seguir.

## Fontes lidas (por mim, Claude Code, sem browser — só HTTP; cópias literais em `fontes-b4/`)
- DL 24/2014 (PGDL, versão atualizada): arts. 4.º, 10.º (14 dias), 11.º, 12.º (reembolso em 14 dias), 15.º, 17.º-1-l
  (conteúdos digitais), 29.º, 33.º.
- Diretiva 2011/83/UE consolidada (EUR-Lex): arts. 6, 8, 9, 11, 14, 16. Diretiva 2013/11/UE art. 13.º (informar a entidade
  de RAL). RGPD arts. 6, 7, 12, 13, 15, 17, 20, 30. Páginas de ajuda da Play (subscrições, cancelar, reembolsos, apagar conta).
- **Não lido** (páginas só com JavaScript, sem browser nesta retoma): Lei 144/2015 no DR (texto nacional do dever de
  informar a RAL — citado pela diretiva), DL 156/2005 / 74/2017 do livro de reclamações (citado só o site oficial), lista
  de entidades de RAL da DGC (a competência da Guarda ficou «se a lista indicar um centro para a Guarda, usa esse»).
- A plataforma europeia ODR foi encerrada (Reg. (UE) 2024/3228, lido no EUR-Lex): não é citada em lado nenhum.

## Quem fez o quê
- **ChatGPT Plus (gpt-5.5, opencode)** por `delegar.ps1 chatgpt … -Id b4a-papeis-site` (lançado solto com Start-Process;
  324 s; anti-mentira PASSOU): `site/termos.html`, `site/reclamacoes.html`, `site/apagar-conta.html`, `site/privacidade.html`
  (e-mail errado corrigido, «Compras», «Estatísticas de utilização», direitos com artigos), rodapé, sitemap, 3 asserções
  no verificador, `docs/RGPD-REGISTO-TRATAMENTOS.md` (art. 30.º), `docs/REGRAS-PT-2026.md` (tabela com fonte/data/confiança).
  GLM continua sem quota semanal.
- **Claude Code**: reviu o texto das 3 páginas (nada inventado; só os factos da tarefa), trocou o marcador interno
  «POR CONFIRMAR» das páginas públicas por «se a lista da DGC (consumidor.gov.pt) indicar um centro para a Guarda, usa esse»,
  verificou estrutura (title/h1/html fechado, sem ODR, sem boraappbora), publicou com `tool/site/publicar.ps1 -Verificar`.

## Provas literais
```
node --check site/testes/verifica.mjs → ok
site/termos.html True True True True True   (title, h1, </html>, sem ODR, sem boraappbora) — idem reclamacoes, apagar-conta
publicar.ps1 -Verificar (1.ª corrida, logo a seguir ao deploy): 57 passaram / 3 falharam (as 3 novas ainda 404 — propagação)
node site/testes/verifica.mjs https://emdia.boraguarda.com (2.ª corrida, 1 min depois):
  PASSA  /termos 200 com título e 14 dias — status 200
  PASSA  /reclamacoes 200 com título e livroreclamacoes.pt — status 200
  PASSA  /apagar-conta 200 com título e e-mail — status 200
  60 asserções passaram / 0 falharam
curl: termos 200 200 · reclamacoes 200 200 · apagar-conta 200 200 (emdia.boraguarda.com e em-dia-site.pages.dev)
```
URLs para a Play (B3): privacidade `https://emdia.boraguarda.com/privacidade` · apagar conta
`https://emdia.boraguarda.com/apagar-conta` · termos `https://emdia.boraguarda.com/termos`.
