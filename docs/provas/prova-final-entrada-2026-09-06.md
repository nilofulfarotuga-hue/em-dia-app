# PROVA FINAL — uma pessoa nova entra, faz o onboarding e vê o painel (6 de setembro de 2026, 20h50)

> O que o Danilo pediu ao reabrir: "um telemóvel novo instala a app pela Play
> interna, pede código, recebe o email, entra, faz o onboarding e vê o painel.
> Vídeo em docs/provas." Está aqui tudo o que se consegue provar sem um
> telemóvel na mão — e está dito, sem rodeios, o que falta.

## O vídeo

`docs/provas/entrada-2026-09-06/entrada-ate-ao-painel.mp4` — **59 segundos**,
ecrã de telemóvel (412×915), app publicada `app-em-dia.pages.dev` na build
`2a63b8d` (a mesma que a Play interna tem). Fotogramas ao lado, um por passo
(`00-entrada.png` … `19-painel.png`).

O que se vê, por ordem: o ecrã de entrada → a app já com a sessão da pessoa →
"Olá! Eu sou o Em Dia… 4 perguntas rápidas" → **Pergunta 1** "O que fazes?"
(Motorista TVDE) → **2** "Quando abriste atividade?" (março de 2026, nos dois
seletores) → **3** IVA (não faturou mais de 15.000 €: "Não cobras IVA…") →
**4** "Tens carro?" (não) → **5** "Quanto ganhas por mês?" (1.500 €) → **a
primeira simulação** → "Entrar na app" → **guia de 3 ecrãs** (Seguinte, Seguinte,
Começar — o toque que dava cinzento até esta noite) → **PAINEL**: "Olá! Estás
em dia? Mês grátis até 06/10 · O QUE FAZER AGORA: Paga o adiantamento do IRS,
412,26 €, até 20 de setembro de 2026 · Está tudo em dia · Guardar para o IRS
158,56 € por mês · Vigia do IVA 0 € de 15.000 €".

## As três peças da entrada (fora do vídeo, com id)

| Passo | Prova |
|---|---|
| Pede o código | `POST /auth/v1/otp` para `boraappbora+video@gmail.com` **com token do Turnstile** (Chrome a sério) → **200** às 19:35:06Z |
| Recebe o e-mail | Resend **`bfda933d-5e22-4b1f-a208-8a0706718f75`**, `created_at 2026-09-06T19:35:04Z`, `delivered` |
| Entra | o código de 6 números lido nesse e-mail → `POST /auth/v1/verify` → sessão (`user 1f9a84de-a4f4-4d3b-b6e2-f0819680090c`) |

A mesma sessão é a que o vídeo usa. Mais cedo, às 18h24 e às 19h24, o mesmo
caminho foi feito ponta a ponta com o código escrito à mão na app publicada
(`login-provado-2026-09-06.md`, `turnstile-2026-09-06.md`).

## Porque é que o e-mail e o código não estão DENTRO do vídeo

Porque o Turnstile faz o trabalho dele: o browser que grava (Playwright) e o
painel do Claude Code são browsers automáticos e a Cloudflare recusa-os
(`600010`), exactamente como recusa o Googlebot. Para os deixar passar teria de
desligar o captcha uns minutos — **essa alteração foi recusada pela camada de
permissões da sessão, e não a contornei.** O Chrome verdadeiro (o da extensão)
passa o Turnstile, mas estava numa janela escondida (0×0) e não grava. Por isso
a entrada foi feita a sério num Chrome verdadeiro e a sessão resultante foi
posta no browser que grava, no sítio onde a app a guarda
(`localStorage['sb-tgdmgtmknbwhcqoxtjbs-auth-token']`). Ferramenta:
`tool/provas/gravar_entrada.py`.

## O que FALTA, e só o Danilo pode fazer

**Instalar num telemóvel novo pela Play interna.** Não há aparelho ligado a
este PC (`adb devices` vazio) e nenhum emulador cabe em 4 GB com o resto a
correr. A build está lá: o CI `2a63b8d` publicou nos tracks `internal` e
`alpha` (versionCode 25+). No telemóvel: link de testador interno → instalar →
pedir código → e-mail → onboarding → painel — o que o vídeo mostra, agora no
Android. Enquanto isso não acontecer, **a missão fica aberta**: não escrevo
MISSAO-CONCLUIDA por cima de uma prova que não fiz.

## O que ficou provado nesta reabertura (por ordem do Danilo)

1. **Login sem e-mail — era mentira minha, não da app.** Os e-mails apareciam na Resend (`delivered`) e chegavam à caixa; a minha ferramenta só listava falhas. Prova com id + caixa + código aceite.
2. **Não eram pessoas.** IPs da Google. Resposta: `robots.txt`, `noindex`, `X-Robots-Tag`, Turnstile no Auth (sem token 400, com token 200), registo **aberto** (0028), lista de convidados apagada.
3. **Erro limpo em vez de 500 feio:** a app traduz `email_que_nao_recebe` numa frase; `registo_fechado` já não existe.
4. **A lista "para o Danilo" ficou a uma linha por item e só com o que exige a pessoa** (`docs/PENDENTE-DANILO.md`): perfil de pagamentos (caixa aberta no ecrã), domínio (página aberta), DGEG (minuta preenchida + rascunho no Gmail), InvoiceXpress/Enable Banking (criar conta), instruções do revisor na Play (a consola não aceitou o meu clique). Feitos por mim: Segurança dos Dados (200), revisor da Google (conta + entrada por palavra-passe), Turnstile, página "Apagar a conta".
5. **Prova final:** este vídeo — e o telemóvel, que é teu.
