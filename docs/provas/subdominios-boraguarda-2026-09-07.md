# Subdomínios de boraguarda.com — os três endereços no ar com cadeado (7 de setembro de 2026)

> Decisão do Danilo (D46): sem domínio comprado. `emdia.boraguarda.com` (site),
> `app.emdia.boraguarda.com` (app), `admin.emdia.boraguarda.com` (painel),
> remetente `emdia@boraguarda.com`.

## O que os tokens deixavam (medido, não adivinhado)

| Token | DNS da zona | Email Routing | Pages (domínios) | Workers (custom domains) | Turnstile |
|---|---|---|---|---|---|
| `bora-site/.env` (conta nilofulfarotuga, 2cd0…) | 403 | 403 | 200 | 200 | 200 (só ler) |
| servidor do Bora `/opt/motor-bora/.env` (conta boraappbora, 6864…) | 403 | 403 | — | 403 | — |

Sem DNS não há CNAME. Com Workers há "custom domains", e a Cloudflare cria o DNS
e o certificado sozinha. Foi por aí.

## O que ficou feito

1. **Pages:** domínios personalizados registados nos três projetos (`POST …/pages/projects/<p>/domains` → 200; ficam `pending — CNAME record not set` até haver um token com DNS; não fazem mal).
2. **Worker `frente-emdia`** (`cloudflare/frente-emdia/`): `wrangler deploy` → "Deployed frente-emdia triggers: emdia.boraguarda.com, app.emdia.boraguarda.com, admin.emdia.boraguarda.com (custom domain)", versão `e352fa85…`. O Worker vai buscar cada pedido ao projeto Pages certo e devolve-o tal e qual (cabeçalhos incluídos); um `Location` da Pages volta com o nosso nome.
3. **Certificados (o cadeado), lidos por TLS do PC:**

| Endereço | IP | TLS | Certificado | Válido até |
|---|---|---|---|---|
| `emdia.boraguarda.com` | 172.67.157.51 | 1.3 | `boraguarda.com`, emitido por WE1 (Cloudflare) | 2026-11-25 |
| `app.emdia.boraguarda.com` | 104.21.74.105 | 1.3 | `boraguarda.com`, WE1 | 2026-12-06 |
| `admin.emdia.boraguarda.com` | 172.67.157.51 | 1.3 | `boraguarda.com`, WE1 | 2026-12-06 |

4. **HTTP:** `https://emdia.boraguarda.com/` → 200, título "Em Dia — Calculadora de recibo verde grátis…"; `/privacidade` → 200 "Política de privacidade — Em Dia". `https://app.emdia.boraguarda.com/` → **200**, título "Em Dia", `X-Robots-Tag: noindex, nofollow, noarchive` (o cabeçalho das Pages passa pelo Worker); `/robots.txt` → 200 com o `Disallow: /`; `https://admin.emdia.boraguarda.com/` → **200**, mesmo cabeçalho. (O resolvedor do PC demorou a ver os registos novos; estas leituras foram pelos IPs da Cloudflare com o nome certo no TLS, e 1.1.1.1 já resolvia.)
5. **Turnstile:** widget `em-dia-login` passou a aceitar `boraguarda.com` (cobre todos os subdomínios) — `PUT …/challenges/widgets/0x4AAAAAAEqfIpGJNQgnZ9TO` → 200.
6. **Auth do Supabase:** `site_url = https://app.emdia.boraguarda.com`; `uri_allow_list` com os endereços novos + os pages.dev + `pt.emdia.app://login-callback`; `smtp_admin_email = emdia@boraguarda.com` (domínio já verificado na Resend) — `PATCH config/auth` → 200.
7. **Play:** `edits.details` com `contactWebsite = https://emdia.boraguarda.com` e `contactEmail = boraappbora@gmail.com`, edição `13303867412713063085` submetida (`tool/play/contactos.py`).

## O que fica à espera de um direito que não tenho

- **Caixa de correio das faturas** (`faturas.boraguarda.com`): Email Routing (403 nos dois tokens). Linha em `docs/PENDENTE-DANILO.md`.
- **CNAME "a sério"** nas Pages: quando houver token com Zone DNS Edit, apagam-se o Worker e os três registos e apontam-se CNAME aos projetos.
