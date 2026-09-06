# Prova — Edge Function `suporte-auto`

Data/hora: 2026-09-05 23:37–23:38 UTC (2026-09-06 00:37–00:38 Lisboa)
Projeto: tgdmgtmknbwhcqoxtjbs · deploy via MCP `deploy_edge_function` (verify_jwt: true)

```
{"id":"636a642d-5437-49a3-b268-ef58c8348791","slug":"suporte-auto","status":"ACTIVE","version":1,"verify_jwt":true,
 "entrypoint_path":".../source/suporte-auto/index.ts"}
```

Ficheiros: `supabase/functions/suporte-auto/index.ts`, `supabase/functions/_shared/{cors,segredos,gemini,contexto_ia}.ts`.

Contrato: `POST { tipo, assunto, descricao, logs? }` com JWT → `200 { ticket_id, resposta, escalado, estado, email }`.
Estado dos segredos: `resend_api_key` **não existe** no Vault (ver ia-responder.md) → o e-mail de escala fica só registado (`email: "sem_resend_api_key"`).

Todas as chamadas abaixo com o JWT de teste@emdia.pt (user_id `a2194877-dcbc-49fd-9197-e826948eec16`).

## Teste 1 — `reembolso` → resposta fixa (Google Play) e ticket fechado

Body `{"tipo":"reembolso","assunto":"Quero cancelar a assinatura","descricao":"Já não preciso da app, como cancelo?"}` · 23:37:55Z
```
HTTP 200
{"ticket_id":"5cfa39f8-81b1-4709-90b2-73260e45552a","resposta":"Os reembolsos e cancelamentos da assinatura do Em Dia são tratados diretamente na Google Play, não na app.\nPara cancelar: abre a Google Play → menu da tua conta → Pagamentos e subscrições → Subscrições → Em Dia → Cancelar.\nPara pedir reembolso: em play.google.com, \"Pedir reembolso\", na compra em causa (a Google decide em 48 horas).\nDepois de cancelares, continuas com o plano até ao fim do período já pago.\nPróximo passo: abre a Google Play e faz o pedido lá; se a Google recusar, responde a este ticket com o n.º do pedido.","escalado":false,"estado":"fechado","email":"nao_aplicavel"}
```

## Teste 2 — `bug` com "cobraram" + "cartão" → escalar_humano, logs guardados, aberto

Body `{"tipo":"bug","assunto":"Cobraram-me duas vezes","descricao":"A app crashou e cobraram-me duas vezes no cartão","logs":"E/flutter: NullPointerException em PlanoScreen linha 42"}` · 23:37:56Z
```
HTTP 200
{"ticket_id":"28d29f0e-2423-439b-827a-cb3199d48790","resposta":"Obrigado por avisares. Guardámos o relatório e os registos da app; a equipa vai analisar e responde-te aqui.\nEste pedido foi passado a uma pessoa da equipa.","escalado":true,"estado":"aberto","email":"sem_resend_api_key"}
```

## Teste 3 — `outro` com "AIMA" e "processo" → escalar_humano

Body `{"tipo":"outro","assunto":"Renovação AIMA","descricao":"Tenho o processo na AIMA parado, a app ajuda?"}` · 23:37:57Z
```
HTTP 200
{"ticket_id":"63e73445-ffc2-4225-8a29-677d04268804","resposta":"Recebemos o teu pedido. A equipa vai analisar e responde-te aqui.\nEste pedido foi passado a uma pessoa da equipa.","escalado":true,"estado":"aberto","email":"sem_resend_api_key"}
```

## Teste 4 — `duvida` sem chave Gemini → ticket criado, resposta de recurso, `erro_ia`

Body `{"tipo":"duvida","assunto":"Quando pago SS?","descricao":"Abri atividade em março, quando começo a pagar?"}` · 23:37:59Z
```
HTTP 200
{"ticket_id":"d7ea44e0-aa0e-491d-8748-82fdf1844af5","resposta":"Registámos a tua dúvida. O assistente automático não está disponível agora, por isso uma pessoa da equipa vai responder-te.","escalado":false,"estado":"aberto","email":"nao_aplicavel","erro_ia":"sem_gemini_api_key"}
```
Decisão: numa dúvida, a falta de IA **não** devolve 503 — o ticket fica registado (estado `aberto`, `resposta_ia` null) para um humano responder; o campo `erro_ia` diz porquê.

## Teste 5 — tipo inválido → 400

Body `{"tipo":"xpto","assunto":"a"}` · 23:38:00Z
```
HTTP 400
{"erro":"tipo_invalido","mensagem":"tipo tem de ser um de: duvida, bug, reembolso, outro."}
```

## SELECT de confirmação (execute_sql)

```sql
select id, tipo, estado, escalar_humano, motivo_escala, assunto, left(resposta_ia, 60) as resposta_ia_inicio, (logs is not null) as tem_logs, criado_em
from public.tickets_suporte where user_id = 'a2194877-dcbc-49fd-9197-e826948eec16' order by criado_em;
```
```
[{"id":"5cfa39f8-81b1-4709-90b2-73260e45552a","tipo":"reembolso","estado":"fechado","escalar_humano":false,"motivo_escala":null,"assunto":"Quero cancelar a assinatura","resposta_ia_inicio":"Os reembolsos e cancelamentos da assinatura do Em Dia são tr","tem_logs":false,"criado_em":"2026-09-05 23:37:54.462285+00"},
 {"id":"28d29f0e-2423-439b-827a-cb3199d48790","tipo":"bug","estado":"aberto","escalar_humano":true,"motivo_escala":"bug com menção a dinheiro (Cobraram)","assunto":"Cobraram-me duas vezes","resposta_ia_inicio":null,"tem_logs":true,"criado_em":"2026-09-05 23:37:55.684148+00"},
 {"id":"63e73445-ffc2-4225-8a29-677d04268804","tipo":"outro","estado":"aberto","escalar_humano":true,"motivo_escala":"menciona termo sensível (AIMA)","assunto":"Renovação AIMA","resposta_ia_inicio":null,"tem_logs":false,"criado_em":"2026-09-05 23:37:56.951898+00"},
 {"id":"d7ea44e0-aa0e-491d-8748-82fdf1844af5","tipo":"duvida","estado":"aberto","escalar_humano":false,"motivo_escala":null,"assunto":"Quando pago SS?","resposta_ia_inicio":null,"tem_logs":false,"criado_em":"2026-09-05 23:37:58.223426+00"}]
```
Os 4 tickets de teste ficam na base como prova (podem ser apagados com `delete from tickets_suporte where user_id='a2194877-...'`).

## Logs (query_logs 23:30–23:40 UTC)

Função `636a642d…`: 5 linhas `booted` (uma por chamada) — sem `console.error` (nem `tickets_suporte insert falhou`, nem `Resend falhou`).

## O que NÃO ficou provado (falta clique humano)

- **E-mail de escala via Resend**: não há `resend_api_key` no Vault. Guardar com `select public.guardar_segredo('resend_api_key', '<chave>')` e repetir o Teste 2; a resposta deve trazer `email: "enviado"`. O `from` tenta `Em Dia <suporte@emdia.pt>`; se o Resend responder 403/422 por domínio não verificado, a função repete com `onboarding@resend.dev`. Destinatário: nilofulfarotuga@gmail.com.
- **`duvida` com resposta da IA** (`resposta_ia` preenchida, registo em `conversas_ia` modo `suporte`): precisa da chave Gemini (ver ia-responder.md).

## Regras de escala implementadas

- Sempre: `advogado/a(s)`, `AIMA`, `processo`, `tribunal` (procura em assunto + descrição, sem distinguir maiúsculas).
- Só em `reembolso` e `bug`: `dinheiro`, `cobraram`, `pagamento`, `cartão/cartao`.
- Um `reembolso` escalado fica `aberto` (não fecha) e mantém a resposta fixa da Google Play.

## Verificação independente

Verificador com contexto limpo · 2026-09-05 23:43–23:45 UTC · JWT novo para teste@emdia.pt · script `verif_ia.py`. Nenhum token nesta prova.

**Deploy confirmado** (`list_edge_functions`): `suporte-auto` id `636a642d-5437-49a3-b268-ef58c8348791`, `ACTIVE`, `version: 1`, `verify_jwt: true`; `get_edge_function` devolve `suporte-auto/index.ts` + `_shared/{cors,segredos,contexto_ia,gemini}.ts`, iguais ao repo. CHECKs lidos de `pg_constraint`: `tipo in (duvida,bug,reembolso,guia_novo,outro)`, `estado in (aberto,em_curso,fechado)`.

**Chamadas (saída literal; assuntos com prefixo `VERIF` para limpar depois):**
```
### SA-1 sem JWT
HTTP 401  {"code":"UNAUTHORIZED_NO_AUTH_HEADER","message":"Missing authorization header"}
### SA-2 corpo vazio
HTTP 400  {"erro":"corpo_invalido","mensagem":"O corpo do pedido tem de ser JSON."}
### SA-3 sem assunto
HTTP 400  {"erro":"assunto_em_falta","mensagem":"Escreve o assunto."}
### SA-4 assunto só espaços
HTTP 400  {"erro":"assunto_em_falta","mensagem":"Escreve o assunto."}
### SA-5 tipo "BUG" (maiúsculas) — rejeitado, é estrito
HTTP 400  {"erro":"tipo_invalido","mensagem":"tipo tem de ser um de: duvida, bug, reembolso, outro."}
### SA-6 reembolso + "cartão"/"dinheiro" (caso que o autor não testou: reembolso escalado NÃO fecha)
HTTP 200  {"ticket_id":"fb883f85-b47d-48b9-a4cf-b3c6117b73c9","resposta":"Os reembolsos e cancelamentos ... n.º do pedido.\nEste pedido foi passado a uma pessoa da equipa.","escalado":true,"estado":"aberto","email":"sem_resend_api_key"}
### SA-7 outro + "dinheiro" — não escala (só reembolso/bug escalam por dinheiro)
HTTP 200  {"ticket_id":"d81f382c-61a4-4e22-8515-20b0509fe17c","resposta":"Recebemos o teu pedido. A equipa vai analisar e responde-te aqui.","escalado":false,"estado":"aberto","email":"nao_aplicavel"}
### SA-8 duvida + "ADVOGADA" (maiúsculas) — escala, e sem chave dá erro_ia
HTTP 200  {"ticket_id":"908c3400-91e3-4d6b-a60c-09a87574e0d9","resposta":"Registámos a tua dúvida. ... vai responder-te.\nEste pedido foi passado a uma pessoa da equipa.","escalado":true,"estado":"aberto","email":"sem_resend_api_key","erro_ia":"sem_gemini_api_key"}
### SA-9 bug sem logs nem descricao
HTTP 200  {"ticket_id":"85f6a3cb-83a6-49e2-a567-701df9223e73","resposta":"Obrigado por avisares. ...","escalado":false,"estado":"aberto","email":"nao_aplicavel"}
### SA-10 corpo exatamente igual ao SA-9 — cria um segundo ticket (não há idempotência; a spec não a pedia)
HTTP 200  {"ticket_id":"7247b4c7-6f68-456a-87e9-9dda6451ced7","resposta":"Obrigado por avisares. ...","escalado":false,"estado":"aberto","email":"nao_aplicavel"}
### SA-11 bug com logs = {"a":1} (objeto, não string) — aceite, logs ficam null
HTTP 200  {"ticket_id":"527746ae-2fed-409d-8cd5-e19a94c4ab8f","resposta":"Obrigado por avisares. ...","escalado":false,"estado":"aberto","email":"nao_aplicavel"}
### SA-12 outro "processo de renovação" — escala por "processo"
HTTP 200  {"ticket_id":"1ce4e0ad-740a-4c5d-8878-4956b62774d9","resposta":"Recebemos o teu pedido. ...\nEste pedido foi passado a uma pessoa da equipa.","escalado":true,"estado":"aberto","email":"sem_resend_api_key"}
### SA-13 duvida "processo em tribunal" — escala + erro_ia
HTTP 200  {"ticket_id":"7981d659-0046-47f2-871f-7441af4d3912","resposta":"Registámos a tua dúvida. ...\nEste pedido foi passado a uma pessoa da equipa.","escalado":true,"estado":"aberto","email":"sem_resend_api_key","erro_ia":"sem_gemini_api_key"}
```
(O SA-6 foi enviado duas vezes por um erro de encoding do meu terminal na primeira corrida — o pedido chegou antes do crash do `print`; daí dois tickets `VERIF reembolso cartão`.)

**SELECT de confirmação** (antes da limpeza):
```
[{"id":"48517682-...","tipo":"reembolso","estado":"aberto","escalar_humano":true,"motivo_escala":"reembolso com menção a dinheiro (dinheiro)","assunto":"VERIF reembolso cartão","sem_descricao":false,"logs":null,"tem_resposta_ia":true},
 {"id":"fb883f85-...","tipo":"reembolso","estado":"aberto","escalar_humano":true,"motivo_escala":"reembolso com menção a dinheiro (dinheiro)","assunto":"VERIF reembolso cartão","sem_descricao":false,"logs":null,"tem_resposta_ia":true},
 {"id":"d81f382c-...","tipo":"outro","estado":"aberto","escalar_humano":false,"motivo_escala":null,"assunto":"VERIF outro dinheiro","sem_descricao":false,"logs":null,"tem_resposta_ia":false},
 {"id":"908c3400-...","tipo":"duvida","estado":"aberto","escalar_humano":true,"motivo_escala":"menciona termo sensível (advogada)","assunto":"VERIF duvida advogada","sem_descricao":false,"logs":null,"tem_resposta_ia":false},
 {"id":"85f6a3cb-...","tipo":"bug","estado":"aberto","escalar_humano":false,"motivo_escala":null,"assunto":"VERIF bug sem logs","sem_descricao":true,"logs":null,"tem_resposta_ia":false},
 {"id":"7247b4c7-...","tipo":"bug","estado":"aberto","escalar_humano":false,"motivo_escala":null,"assunto":"VERIF bug sem logs","sem_descricao":true,"logs":null,"tem_resposta_ia":false},
 {"id":"527746ae-...","tipo":"bug","estado":"aberto","escalar_humano":false,"motivo_escala":null,"assunto":"VERIF logs objeto","sem_descricao":true,"logs":null,"tem_resposta_ia":false},
 {"id":"1ce4e0ad-...","tipo":"outro","estado":"aberto","escalar_humano":true,"motivo_escala":"menciona termo sensível (processo)","assunto":"VERIF processo","sem_descricao":false,"logs":null,"tem_resposta_ia":false},
 {"id":"7981d659-...","tipo":"duvida","estado":"aberto","escalar_humano":true,"motivo_escala":"menciona termo sensível (processo)","assunto":"VERIF duvida processo","sem_descricao":false,"logs":null,"tem_resposta_ia":false}]
```
Tudo coerente com as respostas HTTP: reembolso escalado fica `aberto` com `resposta_ia` (texto fixo) guardada; escalas por termo sensível registam o motivo; `outro`+dinheiro não escala.

**Limpeza:** `delete from tickets_suporte where assunto like 'VERIF %'` → confirmação `tickets_verif: 0`, `tickets_restantes: 4` (os 4 do autor ficam como prova dele).

**Logs** (function_logs 23:42–23:46 UTC): fn `636a642d…` 17 linhas, `erros: 0`; nenhum `falhou`.

**Segredos / números cravados:** greps a zero (ver `ia-responder.md`). O e-mail de destino `nilofulfarotuga@gmail.com` está em constante — é um endereço, não um segredo, e foi pedido assim na spec.

**Observações (não bloqueiam):**
- Sem idempotência: o mesmo corpo duas vezes abre dois tickets. A spec não pedia chave de idempotência; se a app fizer retry automático, convém tratar do lado da app.
- `logs` que não seja string é descartado em silêncio (fica `null`).
- `resend_api_key` não existe (SQL) → caminho do e-mail continua por provar, como o autor disse.

**Veredicto:** aprovado.
