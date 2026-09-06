# Prova — Edge Function `ler-extrato`

Data/hora: 2026-09-05 23:35–23:38 UTC (2026-09-06 00:35–00:38 Lisboa)
Projeto: tgdmgtmknbwhcqoxtjbs · deploy via MCP `deploy_edge_function` (verify_jwt: true)

```
{"id":"d43d1868-c961-45b1-bf9c-f10c11a069eb","slug":"ler-extrato","status":"ACTIVE","version":1,"verify_jwt":true,
 "entrypoint_path":".../source/ler-extrato/index.ts"}
```

Ficheiros: `supabase/functions/ler-extrato/index.ts`, `supabase/functions/_shared/{cors,segredos,gemini}.ts`.

Contrato: `POST { imagem_base64, mime }` com JWT. Ordem das verificações: JWT → cadeado `feature_permitida(uid,'ler_extrato_foto')` → corpo (imagem/mime) → Gemini (inlineData + instrução "só JSON") → validação do JSON → registo em `conversas_ia` modo `extrato`.

## Teste 1 — sem JWT → 401

Body `{"imagem_base64":"aGVsbG8=","mime":"image/png"}` · 2026-09-05T23:37:50Z
```
HTTP 401
{"code":"UNAUTHORIZED_NO_AUTH_HEADER","message":"Missing authorization header"}
```

## Teste 2 — JWT do utilizador de teste em `trial` (cadeado aberto), sem chave Gemini → 503

Mesmo body · 2026-09-05T23:37:52Z
```
HTTP 503
{"erro":"sem_gemini_api_key","mensagem":"O assistente ainda não está ligado: falta a chave da Gemini no Vault (gemini_api_key). Tenta mais tarde."}
```
→ prova que em trial o cadeado deixa passar (`feature_permitida` devolveu true) e que sem chave a função para de forma limpa, antes de chamar a Google.

## Teste 3 — mime inválido → 400

Body `{"imagem_base64":"aGVsbG8=","mime":"text/plain"}` · 2026-09-05T23:37:53Z
```
HTTP 400
{"erro":"mime_invalido","mensagem":"Formato não suportado. Usa: image/jpeg, image/png, image/webp, image/heic, application/pdf."}
```

## Teste 4 — cadeado do plano free → 402

Preparação: `update profiles set trial_ate = now() - interval '1 day'` no utilizador de teste; confirmação por SQL:
```
[{"plano_efetivo":"free","limite":5,"extrato_permitido":false,"usadas_mes":5}]
```
(`feature_flags.ler_extrato_foto.free = false` no seed.)

Body `{"imagem_base64":"aGVsbG8=","mime":"image/png"}` · 2026-09-05T23:38:19Z
```
HTTP 402
{"cadeado":true,"mensagem":"Ler o extrato por foto faz parte do plano Pro. No mês grátis está aberto."}
```

Limpeza: trial reposto (`trial_ate = '2026-10-05 23:25:00.207976+00'`), confirmado `plano_efetivo = trial`.

## SELECT de confirmação (nada foi gravado, como esperado)

```sql
select count(*) from public.conversas_ia where user_id = 'a2194877-dcbc-49fd-9197-e826948eec16' and modo = 'extrato';
```
→ 0 (a função só regista depois de o Gemini responder; sem chave não há linha). Total de conversas do utilizador após limpeza: `conversas_restantes: 0`.

## Logs (query_logs 23:30–23:40 UTC)

Função `d43d1868…`: só `booted` — sem `console.error`.

## O que NÃO ficou provado (falta a chave Gemini)

- Leitura real de uma imagem e o JSON `{ plataforma, mes, valor_bruto, confianca, notas }`.
- O registo em `conversas_ia` (modo `extrato`, pergunta `'extrato'`, resposta = JSON) e o custo em tokens.
- Para provar depois de guardar a chave (`select public.guardar_segredo('gemini_api_key', '<chave>')`): enviar um extrato Uber/Bolt real em base64 (`python -c "import base64;print(base64.b64encode(open('extrato.jpg','rb').read()).decode())"`), com `mime: image/jpeg`, e verificar:
  `select pergunta, resposta, modelo, tokens_entrada, tokens_saida, custo_tokens from conversas_ia where modo='extrato' order by criado_em desc limit 1;`

## Notas de implementação

- Aceita `data:...;base64,` no início (é retirado). Limite ~6 MB de imagem (8 M chars base64) → 413.
- Validação do JSON do modelo: `plataforma` fora de uber/bolt/glovo → `outro`; `mes` tem de ser `AAAA-MM`; `valor_bruto` numérico ≥ 0; `confianca` presa a [0,1]. Se falhar → 502 `resposta_invalida` com o detalhe (não inventa valores).
- Modo JSON do Gemini (`responseMimeType: application/json`), temperatura 0.2.

## Verificação independente

Verificador com contexto limpo · 2026-09-05 23:43–23:45 UTC · JWT novo para teste@emdia.pt · script `verif_ia.py`. Nenhum token nesta prova.

**Deploy confirmado** (`list_edge_functions`): `ler-extrato` id `d43d1868-c961-45b1-bf9c-f10c11a069eb`, `ACTIVE`, `version: 1`, `verify_jwt: true`; `get_edge_function` devolve `ler-extrato/index.ts` + `_shared/{cors,segredos,gemini}.ts`, iguais ao repo.

**Chamadas (saída literal):**
```
### LE-1 sem JWT
HTTP 401  {"code":"UNAUTHORIZED_NO_AUTH_HEADER","message":"Missing authorization header"}
### LE-2 corpo vazio (trial)
HTTP 400  {"erro":"corpo_invalido","mensagem":"O corpo do pedido tem de ser JSON."}
### LE-3 {} (trial)
HTTP 400  {"erro":"imagem_em_falta","mensagem":"Envia a foto do extrato (imagem_base64)."}
### LE-4 "data:image/png;base64,aGVsbG8=" + mime "IMAGE/PNG" (trial, sem chave) — prefixo retirado e mime normalizado, para só na chave
HTTP 503  {"erro":"sem_gemini_api_key","mensagem":"O assistente ainda não está ligado: falta a chave da Gemini no Vault (gemini_api_key). Tenta mais tarde."}
### LE-5 imagem só espaços
HTTP 400  {"erro":"imagem_em_falta","mensagem":"Envia a foto do extrato (imagem_base64)."}
### LE-6 mime image/gif
HTTP 400  {"erro":"mime_invalido","mensagem":"Formato não suportado. Usa: image/jpeg, image/png, image/webp, image/heic, application/pdf."}
```

**Cadeado em free** (mesma preparação SQL da prova do ia-responder: `plano_efetivo: free`, `extrato: false`):
```
### LE-402 free
HTTP 402  {"cadeado":true,"mensagem":"Ler o extrato por foto faz parte do plano Pro. No mês grátis está aberto."}
### LE-402 free com corpo inválido ("xx") — o cadeado é verificado antes do corpo
HTTP 402  {"cadeado":true,"mensagem":"Ler o extrato por foto faz parte do plano Pro. No mês grátis está aberto."}
```

**Confirmação após limpeza:** `plano_efetivo: trial`, `conversas: 0` (nada foi gravado em modo `extrato`, como esperado sem chave). `conversas_ia_modo_check` aceita `'extrato'` (CHECK lido de pg_constraint), por isso o insert vai passar quando houver chave.

**Logs** (function_logs 23:42–23:46 UTC): fn `d43d1868…` 12 linhas, `erros: 0`.

**Segredos / números cravados:** ver secção equivalente em `ia-responder.md` (greps a zero). Os preços de tokens são lidos de `regras_legais` dentro da função.

**Por provar (sem chave, confirmado por SQL `ler_segredo('gemini_api_key') is null`):** leitura real de imagem, JSON validado, registo `modo='extrato'`.

**Veredicto:** aprovado.

## Redeploy e verificação final (03:50)

**Data:** 2026-09-06, 03:50–04:15 (hora de Lisboa).

**Deploy (MCP `deploy_edge_function`, `verify_jwt: true`, entrypoint `ler-extrato/index.ts`, ficheiros `ler-extrato/index.ts` + `_shared/cors.ts` + `_shared/segredos.ts` + `_shared/gemini.ts`):**
```
{"slug":"ler-extrato","status":"ACTIVE","version":2,"updated_at":1788663647916,"verify_jwt":true,
 "ezbr_sha256":"88626f9de9bb149d94708bb7d3e87fc13625e0ed8e4076e3992357834f29d9e8"}
```
Antes do deploy, `get_edge_function('ler-extrato')` (v1, `60865d48…`) mostrava `return Deno.env.get('GEMINI_MODEL')?.trim() || 'gemini-2.5-flash'` — a correção **não** estava no ar. O `_shared/gemini.ts` enviado é byte a byte o mesmo que o do `ia-responder` v2 (confirmado por `get_edge_function` nesse: `'gemini-flash-latest'`).

**Imagem:** PNG 400×200 gerado em Python com PIL 12.3.0 (7284 bytes), fundo branco, texto a preto em Arial 22: "Uber" / "Setembro 2026" / "Total 1.234,56 €". Enviado como `{"imagem_base64": <base64>, "mime": "image/png"}` com o JWT do utilizador de teste (`feature_permitida(uid,'ler_extrato_foto')` = `true`, plano `trial`).

**Resposta (literal):**
```
HTTP 503
{"erro":"gemini_indisponivel","detalhe":"HTTP 429: {\n  \"error\": {\n    \"code\": 429,\n    \"message\": \"You exceeded your current quota, please check your plan and billing details. … Quota exceeded for metric: generativelanguage.googleapis.com/generate_content_free_tier_requests, limit: 5, ","mensagem":"O assistente está com muitos pedidos. Tenta daqui a um minuto."}
```
A quota diária do free tier (20 pedidos/dia para `gemini-3.8-flash`, o modelo em que `gemini-flash-latest` resolve) estava esgotada — diagnóstico completo na prova do `ia-responder`. Nada foi gravado em `conversas_ia` em modo `extrato` (confirmado: a única conversa de hoje é a do chat).

**Fica por provar** (igual à secção anterior, agora por quota e não por falta de chave): leitura real da imagem, JSON validado, registo `modo='extrato'`. Repetir depois das 08:00 de Lisboa, ou depois de ativar faturação na Google.

## Roda de modelos (04:20)

**Deploy (`_shared/gemini.ts` com `RODA_MODELOS`, `verify_jwt: true`):**
```
{"slug":"ler-extrato","status":"ACTIVE","version":3,"updated_at":1788664620634,"ezbr_sha256":"ea5ab64970ba7fa9c86ce0f1b425eab3b2aa0327f2b5f8dc8ea377c775432cc7"}
```
`get_edge_function('ler-extrato')` depois do deploy devolve em `_shared/gemini.ts` `export const RODA_MODELOS = [ 'gemini-flash-latest', 'gemini-3.7-flash', 'gemini-3.6-flash', 'gemini-3.5-flash', 'gemini-flash-lite-latest', 'gemini-3.5-flash-lite', 'gemini-3.1-flash-lite', 'gemini-2.5-flash-lite' ]` e o ciclo de rotação em 429/404 — está no ar.

**Chamada** (mesmo PNG 400×200 gerado com PIL, 7284 bytes: "Uber" / "Setembro 2026" / "Total 1.234,56 €", `mime: image/png`, JWT do utilizador de teste):
```
### LER-EXTRATO | 04:19:54 | 4.6s | HTTP 200
{"plataforma": "uber", "mes": "2026-09", "valor_bruto": 1234.56, "confianca": 1,
 "notas": "Total de ganhos brutos de 1234,56 € lido com clareza para o mês de setembro de 2026."}
```
Leu a plataforma, o mês e o valor exatos da imagem. SELECT `conversas_ia`:
```
{"id":"a3f7be2f-6a28-40f0-b8e0-f24642d42cbd","modo":"extrato","modelo":"gemini-3.6-flash","tokens_entrada":1368,"tokens_saida":336,"custo_tokens":0.001156,"fora_das_regras":false,"variante":"pt","fim_resposta":"1234,56 € lido com clareza para o mês de setembro de 2026.\"}","criado_em":"2026-09-06T03:19:53Z"}
```
`modelo` = `gemini-3.6-flash` (modelo da roda; o 3.8 e o 3.7 devolveram 429 e foram saltados). O registo em modo `extrato` com tokens e custo > 0 fica assim provado.
