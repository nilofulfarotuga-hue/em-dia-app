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
