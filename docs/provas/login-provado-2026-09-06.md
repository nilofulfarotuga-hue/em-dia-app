# PROVADO — o código de entrada chega à caixa (6 de setembro de 2026, 19h24)

> Substitui o `login-por-confirmar-2026-09-06.md` das 19h15, que estava
> **errado**: dizia que os e-mails das 17h52–17h58 "não apareciam na Resend".
> Apareciam. A ferramenta `tool/vigia/emails.py` só mostrava a cauda de
> falhas, e o conector do Gmail tinha o índice parado nas 12h39. O Danilo leu
> os registos de autenticação melhor do que eu: 200 `user_confirmation_requested`
> em 1,1–1,6 s é o servidor a entregar ao SMTP e o SMTP a aceitar.

## A prova que o Danilo pediu — as três peças no mesmo pedido

| Peça | O que se viu |
|---|---|
| **1. Pedido real** | `boraappbora+provafinal@gmail.com` na app publicada (`app-em-dia.pages.dev`), 18:24 UTC. GoTrue respondeu **200** e a app passou às seis casinhas. |
| **2. Registo da Resend, com id** | `GET /emails/225334cd-b362-43c2-b059-0200b6119023` → `last_event: delivered`, `created_at 2026-09-06T18:24:26Z`, de `em-dia@boraguarda.com`. Os três anteriores também: `b83a2ef7…`, `db590427…`, `293dfa23…` — todos `delivered`. |
| **3. E-mail na caixa** | Gmail de `boraappbora@gmail.com` (sessão do Chrome), `#inbox/1a0765f55098a2be`: "7:24 PM (1 minute ago)", código **689238**. |
| **4. O código entra** | `689238` aceite → sessão criada → onboarding (5 passos) → "Pronto…" → guia de início. |

## O que era o mistério, afinal

Não havia mistério no envio. Havia dois instrumentos meus a mentir por omissão:
`emails.py` a listar só falhas, e o conector do Gmail com índice velho. A
hipótese (a) do Danilo — outra chave da Resend — não se confirmou: a chave em
`C:\BoraLocal\_segredos\em-dia\resend.key` vê os quatro e-mails, e a Resend dá
`delivered` (aceite pelo MX do Gmail). A (b) — lista de supressão — também não:
`GET /suppressions` sem os endereços. A (c) — limite horário — não: 30/h
configurado, quatro pedidos na hora.

## O que a prova ao vivo encontrou a seguir (e é isso que reabriu a missão)

Depois do onboarding, no guia de 3 ecrãs, o **terceiro "Seguinte" deixou a app
num ecrã cinzento**: `Null check operator used on a null value` em
`main.dart.js:64955` = `GuiaInicioScreen.build`, `passos[_passo]` com `_passo == 3`.
Corrigido em `16585f5` (tecto no `_avancar`, `clamp` no build, e um
`ErrorWidget.builder` com frase em português e botão "Recomeçar" para nunca mais
haver cinzento mudo). A prova de "vê o painel" fica no documento da prova final.

## Contas inventadas: não eram pessoas

`joao.silva@`, `maria.ferreira@`, `testuser1234@`, `explorador.emdia@` vieram de
IPs da Google (66.249.88.x Googlebot; 74.125.x; 66.102.x) a rastrear
`app-em-dia.pages.dev` e a submeter o formulário. Resposta: `robots.txt` a
bloquear tudo, `noindex` na página e no cabeçalho `X-Robots-Tag` (`e97dc6a`), e
Cloudflare Turnstile no pedido de código (documento próprio quando estiver
provado).
