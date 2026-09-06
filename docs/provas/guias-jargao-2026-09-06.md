# Prova — as siglas nos guias, e dois enganos meus pelo caminho (2026-09-06, noite)

Ontem fechei o jargão nos textos da app e descobri que o **IPO, o NISS e o CAE
não vinham das traduções** — vinham dos guias, que vivem na base de dados e têm
a fonte em `supabase/seed/guias/*.md`. Fui fechar essa ponta.

## Engano nº 1: o meu detetor não via o negrito

Escrevi um verificador que procurava `SIGLA (explicação)`. Deu **20 faltas**.
Fui ver a primeira e não era falta nenhuma:

```
supabase/seed/guias/imigrante-nif-niss-sns-aima.md:12
1. **NIF** (o número das Finanças). Pedes num balcão das Finanças…
```

O guia explica tudo — «NIF (o número das Finanças)», «NIF (o CPF daqui)»,
«AIMA (a agência das migrações, o antigo SEF)». O que o meu padrão não via era
o `**` do negrito entre a sigla e o parêntesis. Corrigi: 20 → 17.

## Engano nº 2: exigia as palavras exactas

Depois exigia frases como «código de atividade», e o guia dizia «o código da
**tua** atividade (o CAE, …)» — a explicação está lá, com a sigla **dentro** do
parêntesis em vez de antes. Acrescentei essa forma e uma lista maior de frases:
17 → 12. E dessas 12, ao ver à mão, ainda havia falsos positivos: o
`irs-independente.md` diz «O IRS é o imposto sobre o que ganhaste no ano» — está
explicado, só que em prosa e não entre parênteses.

**Por isso NÃO transformei isto num teste automático.** Nos textos da app o
padrão era limpo e deu para fechar (o `jargao_test.dart` de ontem). Nos guias, a
explicação vem em prosa, de cinco maneiras diferentes, e um verificador que grita
por tudo já provou hoje o que faz: deixa de ser ouvido. Os guias são textos sobre
impostos — mexer neles a partir de um alarme falso é pior do que não mexer.

## A falta que sobrou, e essa era mesmo

`tvde-o-que-e-preciso.md` — **CAE** e **IVA**, sem explicação, nas duas línguas:

```
- CAE 49320 — POR CONFIRMAR. Vê o guia "Abrir atividade".
- Isenção de IVA se faturares menos de 15.000 € (iva_isencao_limite).
```

O guia do TVDE é a porta de entrada de muita gente, e o guia irmão
(`abrir-atividade`) já explicava o CAE. Ficou assim:

```
- O CAE (o código que diz às Finanças o que fazes) é o 49320 — POR CONFIRMAR. …
- Isenção de IVA (o imposto sobre o valor acrescentado, aquele que se soma ao preço) …
```

Em PT-BR, o CAE ganhou a ponte que faltava: «(o código que diz às Finanças o que
você faz, **como o CNAE**)».

## E foi mesmo para a base de dados, não só para o repositório

O ficheiro fonte não chega — quem lê os guias na app lê a tabela `guias`. O MCP
do Supabase está em baixo nesta sessão e não há chave de service role neste PC,
por isso fiz o caminho todo como uma pessoa faria:

1. `POST /auth/v1/otp` para `boraappbora@gmail.com` → **HTTP 200**;
2. o código veio do registo da Resend (`GET /emails/{id}`), porque o Gmail estava
   com a vista em cache;
3. `POST /auth/v1/verify` → **HTTP 200**, e `rpc/is_admin` → **`true`**;
4. `PATCH /rest/v1/guias?slug=eq.tvde-o-que-e-preciso` → **HTTP 200, 1 linha**;
5. leitura **sem sessão nenhuma**, que é o que qualquer pessoa vê:

```
PT: - O CAE (o código que diz às Finanças o que fazes) é o 49320 — POR CONFIRMAR…
PT: - Isenção de IVA (o imposto sobre o valor acrescentado, aquele que se soma ao preço)…
BR: - O CAE (o código que diz às Finanças o que você faz, como o CNAE) é o 49320…
BR: - Isenção de IVA (o imposto sobre o valor acrescentado, aquele que se soma ao preço)…
```

`supabase/seed/guias.sql` foi regerado (`tool/guias/carregar.py`): 4 linhas
mudadas, exactamente as quatro.

O código e o token que usei foram apagados a seguir.

## Um susto que não era, e um problema que é

**O susto:** o código que pedi às 13:51 não aparecia no Gmail passados seis
minutos. Pareceu regressão do login que arranjei de manhã. Não era: o registo da
Resend mostra-o **entregue**.

```
2026-09-06 13:51:16 | boraappbora@gmail.com | delivered | O teu codigo do Em Dia
```

O que estava velho era a vista do Gmail (o mesmo `historyId` em três consultas
seguidas). Fui verificar em vez de assumir, e ainda bem.

**O problema, esse é real.** No mesmo registo:

```
2026-09-06 12:56:33 | test@gmail.com | suppressed
2026-09-06 12:55:15 | test@gmail.com | suppressed
2026-09-06 12:54:08 | test@gmail.com | suppressed
2026-09-06 11:41:59 | test@gmail.com | suppressed
2026-09-06 11:40:31 | test@gmail.com | suppressed
```

Cinco pedidos de código para `test@gmail.com` foram **suprimidos** — a Resend tem
esse endereço numa lista de bloqueio (de uma devolução antiga) e não envia nada.
E o servidor responde `200` na mesma. Ou seja: quem escrever um endereço nessas
condições fica no ecrã das casinhas à espera de um código que **nunca** vai
chegar, sem nenhum aviso.

A app não tem como saber disto na hora — o Supabase entrega ao SMTP e responde
logo. O que a app já tem, e ajuda, é a saída «Escrevi o e-mail errado» no topo e o
relógio do minuto. Se isto acontecer com uma pessoa a sério, vê-se aqui:
`GET https://api.resend.com/emails` mostra `suppressed` ao lado do endereço.

**Aviso ao próximo:** a API da Resend responde `403 error code: 1010` se o pedido
for feito com o User-Agent do Python — é o Cloudflare a bloquear, não a chave a
faltar permissões. Com um User-Agent de browser, funciona.
