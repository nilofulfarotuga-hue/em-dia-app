# Prova — nenhuma chave a sério no repositório (2026-09-06, 19h)

Regra 5 do `CLAUDE.md`: *"Segredos: só em GitHub Secrets (base64) e no Vault do
Supabase. Prova: `git grep` a zero."* Fecho da missão, com a varredura feita ao
ficheiro de trabalho **e ao histórico todo**.

## O que se procurou

Chaves de serviço do Supabase, chaves do Google/Gemini (`AIza…`), chaves vivas
da Stripe (`sk_live_`), fichas do GitHub (`ghp_`, `github_pat_`), chaves da
Resend (`re_`), e qualquer bloco `-----BEGIN PRIVATE KEY-----`.

## O que apareceu — e porque é que nenhum é um segredo

**1. A chave `anon` do Supabase**, em `site/index.html` e na migração 0004.
Descodifiquei-a para não ficar pela suposição:

```
role = anon | ref = tgdmgtmknbwhcqoxtjbs
```

**É a chave pública.** É a que vai dentro de todas as apps e de todos os sites
que falam com o Supabase — está no `.apk`, está no JavaScript da página. Quem a
protege não é o segredo dela, é o RLS: já hoje se provou que com essa chave um
estranho lê os centros de inspeção (200) e não consegue escrever lá nada (401).
A regra da casa fala de **service role**, e essa não está em lado nenhum.

**2. Um `-----BEGIN PRIVATE KEY-----` numa prova antiga**, em
`docs/provas/edge/validar-compra-play.md`. O conteúdo é `AAAA` e o e-mail é
`verificacao-falsa@exemplo.iam.gserviceaccount.com`: é a chave **de mentira**
com que se provou que a função recusa credenciais inválidas.

## Os ficheiros que nunca podem lá estar

```
git ls-files | grep -E "\.jks$|key\.properties|google-services\.json|\.dart_defines$|service-account.*\.json$|\.env$"
  (zero)
```

Nenhuma keystore, nenhum `key.properties`, nenhum `google-services.json`,
nenhum `.dart_defines`, nenhuma conta de serviço, nenhum `.env`.

## E o cofre local está de pé

`C:\BoraLocal\_segredos\em-dia\` tem os nove ficheiros, incluindo o
`.dart_defines` e a keystore `em-dia-release.jks`. **Nada disto foi tocado
durante a missão** — só lido.

## Uma coisa a saber, que não é problema mas é bom não descobrir tarde

A migração 0004 leva a chave `anon` escrita dentro do comando do `pg_cron`. Se
um dia se rodar essa chave, o cron dos avisos deixa de a ter certa. Como as
funções do cron autenticam pelo `x-cron-secret` do Vault e não pelo cabeçalho
`Authorization`, tirá-la dali é seguro — mas é uma migração nova, e hoje não
havia razão para mexer numa coisa que está a funcionar.
