# Prova — o registo fecha-se até ao lançamento (2026-09-06, 19h)

## O que apareceu, e não estava à espera

Fui ver o registo da Resend no fecho da missão. Duas linhas novas de hoje:

```
2026-09-06 16:52 | bounced | joao.silva@gmail.com        | "Em Dia" <em-dia@boraguarda.com> | O teu codigo do Em Dia
2026-09-06 17:56 | bounced | explorador.emdia@gmail.com  | "Em Dia" <em-dia@boraguarda.com> | O teu codigo do Em Dia
```

E na base, as contas correspondentes:

```
explorador.emdia@gmail.com   criada 2026-09-06 17:56:15
joao.silva@gmail.com         criada 2026-09-06 16:52:48
```

**A trava que pus às 15h30 não os apanhou** — e está certo que não tenha
apanhado. Ela recusa caixas obviamente inventadas (`test@`, `demo@`, `asdf@`).
`joao.silva@gmail.com` é um nome de gente. **Não há regra nenhuma que distinga
um `joao.silva@gmail.com` verdadeiro de um inventado**: só o servidor da Google
sabe, e diz-nos com uma devolução — que é exactamente aquilo que gasta a
reputação do domínio por onde sai o código de entrar na app.

Não fui eu que criei estas duas contas. Havia outra sessão a testar o login à
mesma hora — vê-se nos registos do Supabase, com `/otp` às 17:55, 17:56 e um
`/verify` às 17:56:37 a falhar com "token has expired or is invalid".

## O que resolve isto não é um padrão melhor. É o momento.

**A app ainda não foi lançada.** Antes do lançamento só entra quem foi
convidado, e a lista é nossa. No dia do lançamento muda-se uma linha e abre a
toda a gente. Isto não trava ninguém a sério: o teste interno da Play é por
convite na mesma.

- Tabela `emails_convidados` (hoje: as duas contas do Danilo).
- Regra `registo_aberto` em `regras_legais`, a `nao`.
- O gatilho `recusa_email_que_nao_recebe` ganhou a segunda pergunta.

## A prova, a falar direto com a API de autenticação

```
maria.ferreira@gmail.com           -> 500 {"code":"23514","message":"registo_fechado: maria.ferreira@gmail.com (a app ainda nao foi lancada; poe o endereco em emails_convidados)"}
boraappbora+provafinal@gmail.com   -> 200  (é convidado: passa, e o e-mail sai)
joao.silva@gmail.com               -> 200  ← ATENÇÃO
```

## O erro que quase me escapava, e que é a parte importante desta página

Aquele `joao.silva@gmail.com -> 200` **mandou mais um e-mail para um endereço
que devolve**. Porquê? Porque o gatilho é `BEFORE INSERT` em `auth.users`, e
essa conta **já existia**: não há insert nenhum, o GoTrue limita-se a mandar
código novo a quem já lá está.

**Fechar a porta não chega: é preciso tirar de dentro quem já entrou.** Apaguei
as três contas de teste (`joao.silva@`, `explorador.emdia@`, `testuser1234@`) e
voltei a bater à porta:

```
joao.silva@gmail.com        -> 500 registo_fechado
explorador.emdia@gmail.com  -> 500 registo_fechado
test@gmail.com              -> 500 email_que_nao_recebe
alguem@example.com          -> 500 email_que_nao_recebe
```

Confirmado também do lado do servidor, nos registos de autenticação do Supabase:
quatro `/otp` com `500` e a razão escrita, e os dois convidados com `200`.

## Uma correcção ao que escrevi de tarde

Em `docs/provas/email-do-dominio-2026-09-06.md` escrevi que os testes do Bora
não eram a causa, e mostrei que o digest semanal de lá tinha três linhas, a
última de 23 de agosto. Isso continua verdade — mas **estava incompleto**. No
registo da Resend, hoje às 16h35:

```
2026-09-06 16:35 | delivery_delayed | e2e_client_a@boraapp.test | "Bora" <nao-responder@boraguarda.com>
```

O Bora **continua a mandar** para o domínio que não existe, e é o mesmo
`boraguarda.com` do login do Em Dia. A minha trava está no projeto do Em Dia e
não protege o do Bora. Fica na lista do Danilo, como já estava — e agora com a
prova de que ainda acontece hoje, não só em setembro.

## Como se abre, no dia do lançamento

```sql
update regras_legais set valor_txt = 'sim' where chave = 'registo_aberto';
```

Uma linha, sem publicar app nenhuma. E para convidar mais alguém antes disso:

```sql
insert into emails_convidados (email, nota) values ('quem@quiseres.com', 'testador');
```
