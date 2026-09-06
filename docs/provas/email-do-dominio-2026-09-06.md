# Prova — parar de queimar o domínio que manda o código de entrada (2026-09-06, 17h)

O Danilo escreveu: *"corrige os testes E2E do Bora que estão a enviar para um
domínio que não existe desde 1 de setembro. São 11 dos 18 falhados e estão a
queimar a reputação do domínio que o Em Dia usa para mandar o código de entrada."*

## O diagnóstico é outro, e é preciso dizê-lo

Fui ao registo da Resend antes de mexer em nada. Nos últimos 15 dias:

| Para | Estado | Quantos |
|---|---|---:|
| `boraappbora@gmail.com` e `boraappbora+…@gmail.com` | Delivered | 8 |
| `test@gmail.com` | **Suppressed** | 6 |
| `newuser@gmail.com` | **Bounced** | 1 |

**Sete falhas em quinze envios, e o assunto de todas é "O teu codigo do Em Dia".**
Não são os testes E2E do Bora: são os códigos de entrada do próprio Em Dia,
mandados para dois endereços inventados enquanto se experimentava o registo.
`test@gmail.com` já está na lista negra da Resend.

Fui confirmar o lado do Bora na base dele, só a ler: a tabela
`weekly_digest_log` tem **três linhas ao todo**, a mais recente de **23 de
agosto**, e uma delas para `@bora.app`. Não é de lá que vem a queimadura.

Os endereços de teste do Bora (`@boraapp.test`) são criados pela API de
administração com `email_confirm: True`, que **não manda e-mail nenhum**. Nunca
chegaram a sair.

## Primeira correcção, que não chegou

Pus a trava na app: `SessaoStore.enderecoDeMentira` recusa antes de sair do
telemóvel. Publiquei às 16h45 e provei ao vivo em app-em-dia.pages.dev — a app
responde *"Esse e-mail não recebe correio. Escreve o teu a sério, senão o
código não chega a lado nenhum."* e não manda nada.

**Meia hora depois havia mais dois envios para `test@gmail.com` no registo.**
A trava do telemóvel não vale nada contra um script que fala directamente com
`/auth/v1/otp`, e foi assim que saíram.

## Segunda correcção, no servidor, onde ninguém lhe foge

Um gatilho antes de criar a conta (`auth.users`). Sem conta, o GoTrue não tem a
quem mandar o código. Prova, a falar directo com a API:

```
test@gmail.com                       -> 500 {"code":"23514","message":"email_que_nao_recebe: test@gmail.com"}
newuser@gmail.com                    -> 500 {"code":"23514","message":"email_que_nao_recebe: newuser@gmail.com"}
alguem@example.com                   -> 500 {"code":"23514","message":"email_que_nao_recebe: alguem@example.com"}
e2e@boraapp.test                     -> 500 {"code":"23514","message":"email_que_nao_recebe: e2e@boraapp.test"}
boraappbora+depoisdatrava@gmail.com  -> 200
```

E o registo da Resend, logo a seguir:

```
boraappbora+depoisdatrava@gmail.com   Delivered    just now
boraappbora+provafinal@gmail.com      Delivered    8min ago
test@emdia.app                        Delivered    13min ago
test@gmail.com                        Suppressed   15min ago   <- a ultima falha, ANTES da trava
```

**Zero falhas novas depois da correcção.** Os quatro endereços mortos que
martelei não deixaram uma única linha: nada saiu do servidor.

## O que fica travado, e o que não

Travado: as terminações reservadas por norma (`.test`, `.invalid`, `.example`,
`.localhost`, `.local`), os domínios de exemplo (`example.com` e irmãos), e as
caixas inventadas nos fornecedores grandes (`test@`, `teste@`, `demo@`,
`noreply@`, `asdf@`… em gmail, hotmail, outlook, yahoo, icloud, sapo).

**Não travado, de propósito:** `nome+etiqueta@gmail.com`. É a forma certa de
fazer testes — chega mesmo à caixa de quem a escreveu — e está provado a
funcionar acima. Fica escrito como regra: **quem precisar de um endereço de
teste usa `boraappbora+<etiqueta>@gmail.com`, nunca um inventado.**

## E o Bora, já agora

Mesmo não sendo a causa, o digest semanal do Bora manda a partir de
`fecho@boraguarda.com` — o **mesmo** domínio do Em Dia. Basta uma fixture
`@boraapp.test` chegar a `weekly_digest_log` para a história se repetir por lá.
Ficou com a mesma guarda, no ramo `fix/digest-enderecos-mortos` do
`bora-app-cloud`, sem tocar em mais nada do Bora.

## Onde ficou

- App: `lib/stores/sessao_store.dart` (`enderecoDeMentira`), testes L10 e L11.
- Servidor: `supabase/migrations/20260906_0021_trava_emails_que_nao_recebem.sql`.
- Bora: ramo `fix/digest-enderecos-mortos`, commit `0f4cfa49`.
