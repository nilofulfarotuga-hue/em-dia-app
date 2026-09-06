# PROVADO — Turnstile ligado ao Auth: sem token recusa, com token passa (6 de setembro de 2026, 20h24)

> Ordem do Danilo ao reabrir a missão: "Prova: pedido sem token Turnstile a
> ser recusado, pedido com token a passar." As duas peças estão aqui, com hora,
> id e IP, e o e-mail no fim.

## O que ficou ligado

| Peça | Valor |
|---|---|
| Widget Cloudflare | `em-dia-login`, sitekey `0x4AAAAAAEqfIpGJNQgnZ9TO`, modo **managed**, domínios `app-em-dia.pages.dev`, `em-dia.app`, `localhost`; conta `boraappbora@gmail.com` (`6864b594…`), criado 18:54Z pela API do painel (POST → 200) |
| Segredo | `C:\BoraLocal\_segredos\em-dia\turnstile.env` (nunca no repo) |
| App | `TURNSTILE_SITE_KEY` no `.dart_defines` e no secret `DART_DEFINES_FILE_B64` (HTTP 204); build `6683646` publicada — `main.dart.js` contém a sitekey e o script `challenges.cloudflare.com` |
| Auth do Supabase | `PATCH /v1/projects/tgdmgtmknbwhcqoxtjbs/config/auth` → **200**, `security_captcha_enabled: true`, `security_captcha_provider: turnstile`, segredo definido (20:17 local) |

## 1. Sem token → recusado

Três pedidos do meu PC (IP `89.152.62.43`), 19:17Z, todos **HTTP 400 `captcha_failed`**:

| Pedido | Resposta |
|---|---|
| `POST /auth/v1/otp` sem `captcha_token` | `{"code":400,"error_code":"captcha_failed","msg":"captcha protection: request disallowed (no captcha_token found)"}` |
| `POST /auth/v1/otp` com token inventado | `…"msg":"captcha protection: request disallowed (invalid-input-response)"` |
| `POST /auth/v1/token?grant_type=password` (revisor) sem token | 400 `no captcha_token found` |

Registo de autenticação do Supabase (`query_logs`, `source = 'auth_logs'`):
`/otp` 400 às 19:17:28 e 19:17:49, `/token` 400 às 19:17:28 — mesmo IP, erro
escrito. **É exactamente o que o Googlebot vai levar** quando voltar a submeter
o formulário de entrada.

## 2. Com token → passa, e o e-mail chega

Num Chrome a sério (o do Danilo, sessão da extensão), na página
`app-em-dia.pages.dev/robots.txt` (domínio do widget), com o `api.js` da
Cloudflare injectado: `turnstile.render` deu token em **3,7 s sem mostrar nada**
(773 caracteres, `1.mYSqI_EUes…`). Com esse token:

`POST /auth/v1/otp {email: boraappbora+turnstile@gmail.com, captcha_token}` →
**HTTP 200** às 19:24:14Z.

| Onde | Prova |
|---|---|
| Registo do Auth | `/otp` **200**, 19:24:12Z, IP `89.152.62.43`, sem erro (2,4 s — o tempo do SMTP) |
| Resend | id **`ded65df9-a112-44c3-b794-565f6e3ae2a0`**, `created_at 2026-09-06T19:24:12.851Z`, para `boraappbora+turnstile@gmail.com`, `last_event: delivered`, assunto "O teu codigo do Em Dia" |

## O que o modo invisível ensinou (e por isso ficou managed)

Experimentei o modo *invisible* do widget: o meu browser automático levou
**600010 "A visitor failed to solve a Turnstile Challenge"** em segundos — o
Turnstile a fazer o trabalho dele — mas nesse modo uma pessoa que falhe fica
sem saída, porque não há caixa para carregar. Em *managed*, quem a Cloudflare
não reconhece vê a caixa "Sou humano" e segue. O browser automático da
sessão (o painel do Claude Code) não passa nem no managed: é assim que deve
ser, e é por isso que a prova do token foi feita num Chrome verdadeiro.

**Defeito encontrado nesta prova:** quando o invisível falha, a app diz
"Não consegui confirmar que não és um robô" mas a caixa visível **não aparece**
e o botão fica cinzento — uma pessoa nessa situação ficava presa. Corrigido a
seguir (ver o commit seguinte a `6683646`).

## Depois da prova: o registo abriu

Migração `0028_registo_aberto_turnstile` aplicada: o gatilho voltou a ser só a
guarda dos endereços que não recebem correio, `emails_convidados` foi apagada e
a regra `registo_aberto` também. Já não há "linha do dia do lançamento".

## Robôs fora da app web (a outra metade da resposta)

`GET https://app-em-dia.pages.dev/` → 200 com `X-Robots-Tag: noindex, nofollow,
noarchive`, `<meta name="robots" content="noindex">`, e `robots.txt` com
`Disallow: /` (commit `e97dc6a`).

## O que o Turnstile NÃO trava — visto às 20:09Z, depois da prova (acrescentado 21h40)

| Hora (UTC) | IP | Pedido | Resposta |
|---|---|---|---|
| 20:09:17 | `74.125.209.194` (Google), referer `app-em-dia.pages.dev` | `POST /otp` `testuser12345@gmail.com` | **200** — `user_confirmation_requested`; Resend `d0dda5f4-1d52-432e-af14-2c109d569e4c` delivered |
| 20:09:43 | `74.125.209.195` | `POST /verify` (código inventado) | 403 `otp_expired` |

O renderizador da Google é um Chrome a sério e a Cloudflare, em modo *managed*,
dá-lhe token. Um pedido meu sem token às 21:28 continuou a levar **400** — o
Turnstile está ligado; simplesmente não distingue um robô da Google de uma
pessoa num Chrome. Por isso:

1. **`web/index.html`** (commit `e65cbeb`): quem se apresenta como robô no
   User-Agent (`bot`, `crawl`, `spider`, `Google-InspectionTool`,
   `HeadlessChrome`, …) ou com `navigator.webdriver` não carrega a app — vê uma
   frase e o link do site. Era o terceiro item da ordem ("bloqueio por
   User-Agent de bots na página de entrada") e faltava.
2. **Migração 0029/0029b**: a guarda dos endereços inventados apanha nome de
   teste + números nos provedores grandes. Padrão testado com 20 caixas:
   `testuser12345`, `testuser1234`, `demo2026`, `user1`, `abc123`, `teste.user`,
   `test.emdia`, `usuario2026` → apanhados; `joao.silva`, `maria.ferreira`,
   `testa.silva`, `testemunha.silva`, `carlos.teste`, `revisor.google` → passam.
3. A conta `testuser12345@gmail.com` (7b5af669…, nunca confirmada) foi apagada.

### A porta dos robôs, provada na app publicada (21h58)

WebKit do Playwright contra `app-em-dia.pages.dev` (build `e65cbeb`):

| Quem se apresenta | O que carrega |
|---|---|
| `Googlebot/2.1` | **Só a frase** "Esta é a aplicação, só para pessoas…" com o link do site — sem `flutter_bootstrap.js`, sem Flutter |
| Chrome/Android normal (sem `navigator.webdriver`) | A app (`flutter-view` presente, `flutter_bootstrap.js` carregado) |

Um browser automático com `navigator.webdriver` também fica na frase; por isso o
gravador `tool/provas/gravar_entrada.py` passou a apresentar-se como pessoa
(só para gravar o percurso de uma).
