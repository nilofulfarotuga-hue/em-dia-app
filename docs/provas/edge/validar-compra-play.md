# Prova — Edge Function `validar-compra-play`

- **Data/hora:** 2026-09-05 23:29 UTC (2026-09-06 00:29 Lisboa)
- **Projeto Supabase:** tgdmgtmknbwhcqoxtjbs
- **Ficheiros:**
  - `supabase/functions/validar-compra-play/index.ts`
  - `supabase/functions/_shared/google_oauth.ts` (OAuth2 service account, JWT RS256 com `npm:jose@5`; reutilizável pelo `avisos-cron` para FCM — `obterAccessTokenGoogle(sa, scopes)`)
- **Deploy (MCP `deploy_edge_function`, `verify_jwt: true`):**
  `{"id":"21eddb85-14d6-4fb9-a9da-260574787c56","slug":"validar-compra-play","status":"ACTIVE","version":1,"verify_jwt":true}`
  Nota: o bundler resolve `../_shared/` a partir do caminho do entrypoint, por isso os ficheiros foram enviados com os nomes `supabase/functions/validar-compra-play/index.ts` e `supabase/functions/_shared/google_oauth.ts` (a primeira tentativa com `index.ts` + `_shared/google_oauth.ts` falhou com "Module not found").

## Comportamento implementado

- `POST { produto_id, token_compra }` com JWT do utilizador (401 sem sessão).
- Validação: `produto_id` tem de ser um de `pro_mensal | pro_anual | familia_mensal | familia_anual` (400), `token_compra` obrigatório (400).
- Credenciais: `Deno.env.get('PLAY_SERVICE_ACCOUNT')` → senão `ler_segredo('play_service_account')` (service role). Sem segredo → **503 `{ erro: 'sem_play_service_account' }`**.
- Com credenciais: OAuth2 (scope `androidpublisher`) → `GET .../applications/pt.emdia.app/purchases/subscriptionsv2/tokens/{token}`.
- `lineItems[0].productId` ≠ `produto_id` → 400 `produto_nao_corresponde`. Token já ligado a outro `user_id` → 409.
- Mapeamento `subscriptionState`: ACTIVE / IN_GRACE_PERIOD → `ativa`; CANCELED → `cancelada` (acesso até `renova_em`); EXPIRED → `expirada`; PAUSED → `pausa`; PENDING → `pendente`.
- Upsert em `assinaturas` por `(plataforma='play', token_compra)` com `comprovativo_play` (JSON completo), `comecou_em = startTime`, `renova_em = lineItems[0].expiryTime`.
- `profiles.plano` → `pro`/`familia` (prefixo do produto) quando `ativa`; `free` quando `expirada`; restantes estados não mexem.
- `acknowledgementState = ACKNOWLEDGEMENT_STATE_PENDING` → `POST .../purchases/subscriptions/{produto_id}/tokens/{token}:acknowledge` (erro ignorado).
- Resposta 200: `{ estado, plano, renova_em }`.

## Chamadas de teste (utilizador `teste@emdia.pt`, JWT obtido via `/auth/v1/token?grant_type=password`; tokens omitidos)

Script: Python `urllib` → `POST https://tgdmgtmknbwhcqoxtjbs.supabase.co/functions/v1/validar-compra-play`, headers `apikey` (anon) + `Authorization: Bearer <jwt>`.

```
login 200 jwt
--- sem JWT
POST {"produto_id": "pro_mensal", "token_compra": "token-falso-123"}
HTTP 401
{"code":"UNAUTHORIZED_NO_AUTH_HEADER","message":"Missing authorization header"}
--- falta produto_id
POST {"token_compra": "token-falso-123"}
HTTP 400
{"erro":"produto_id_invalido","mensagem":"produto_id em falta ou inválido. Valores aceites: pro_mensal, pro_anual, familia_mensal, familia_anual."}
--- produto_id invalido
POST {"produto_id": "premium", "token_compra": "token-falso-123"}
HTTP 400
{"erro":"produto_id_invalido","mensagem":"produto_id em falta ou inválido. Valores aceites: pro_mensal, pro_anual, familia_mensal, familia_anual."}
--- falta token_compra
POST {"produto_id": "pro_mensal"}
HTTP 400
{"erro":"token_compra_em_falta","mensagem":"token_compra é obrigatório."}
--- token falso, sem service account
POST {"produto_id": "pro_anual", "token_compra": "token-falso-123"}
HTTP 503
{"erro":"sem_play_service_account","mensagem":"A conta de serviço do Google Play ainda não está configurada. A validação de compras fica disponível quando a app for publicada."}
```

(Os acentos apareceram como `�` na consola Windows por causa do codepage; o JSON enviado pela função é UTF-8.)

## SELECT de confirmação (execute_sql, depois das chamadas)

```sql
select now() as agora,
  (select count(*) from public.assinaturas where token_compra = 'token-falso-123') as assinaturas_com_token_falso,
  (select plano from public.profiles where email = 'teste@emdia.pt') as plano_teste,
  (select count(*) from vault.secrets where name = 'play_service_account') as segredo_play_existe;
```

Resultado literal:

```
[{"agora":"2026-09-05 23:29:40.715031+00","assinaturas_com_token_falso":0,"plano_teste":"free","segredo_play_existe":0}]
```

Ou seja: sem service account a função **não grava nada** (0 linhas em `assinaturas`, plano continua `free`) e responde 503 claro.

## O que falta (bloco de publicação)

- **Service account do Google Play** (JSON com acesso à Play Developer API, app `pt.emdia.app`) — precisa de clique humano no Play Console / Google Cloud. Quando existir, guarda-se com `select public.guardar_segredo('play_service_account', '<json>')` (service role) e a função passa automaticamente ao caminho real. Até lá, todo o fluxo pós-503 (OAuth, consulta do recibo, upsert, plano, acknowledge) **não foi exercido contra a Google** — está escrito, deployado e compilado, mas sem prova de execução real.
- Os 4 produtos (`pro_mensal`, `pro_anual`, `familia_mensal`, `familia_anual`) têm de ser criados no Play Console com estes ids exatos.

## Verificação independente

- **Data/hora:** 2026-09-05 23:31–23:36 UTC (2026-09-06 01:31 Lisboa)
- **Quem:** verificador com contexto limpo (maker/checker). Chamadas feitas com Python `urllib`, JWTs novos obtidos por `/auth/v1/token?grant_type=password` para `teste@emdia.pt` e `teste2@emdia.pt` (tokens omitidos).

### Deploy e código

`list_edge_functions` → `{"slug":"validar-compra-play","status":"ACTIVE","version":1,"verify_jwt":true,"entrypoint_path":".../supabase/functions/validar-compra-play/index.ts"}`.
`get_edge_function` devolveu `functions/validar-compra-play/index.ts` + `functions/_shared/google_oauth.ts` com conteúdo igual ao local. `supabase/functions/_shared/fcm.ts:6` importa `obterAccessTokenGoogle` de `./google_oauth.ts` — a reutilização pelo `avisos-cron` é real, não só prometida.

### Grep de segredos e números (saída literal)

```
$ grep -rn -E "AIza|private_key|sk_|eyJ" supabase/functions docs/provas
supabase/functions/_shared/fcm.ts:20:    if (!sa.project_id || !sa.client_email || !sa.private_key) {
supabase/functions/_shared/fcm.ts:21:      console.error('fcm_service_account sem project_id/client_email/private_key')
supabase/functions/_shared/google_oauth.ts:12:  private_key: string;
supabase/functions/_shared/google_oauth.ts:20: * Troca um JWT assinado com a private_key da service account por um access_token OAuth2.
supabase/functions/_shared/google_oauth.ts:27:  if (!sa?.client_email || !sa?.private_key) {
supabase/functions/_shared/google_oauth.ts:28:    throw new Error('service account inválida: faltam client_email ou private_key');
supabase/functions/_shared/google_oauth.ts:37:  const pem = sa.private_key.replace(/\\n/g, '\n');
$ grep -rn -E "21\.4|15000|537\.13|0\.75" supabase/functions
(vazio)
```
Só nomes de campo; nenhum valor de segredo, nenhum número legal cravado.

### Bateria de chamadas (estado inicial: Vault sem `play_service_account`)

```
--- sem JWT                      → HTTP 401 {"code":"UNAUTHORIZED_NO_AUTH_HEADER","message":"Missing authorization header"}
--- JWT lixo (abc.def.ghi)       → HTTP 401 {"code":"UNAUTHORIZED_INVALID_JWT_FORMAT","message":"Invalid JWT"}
--- GET com JWT                  → HTTP 405 {"erro":"metodo_nao_permitido","mensagem":"Usa POST."}
--- corpo vazio ('')             → HTTP 400 {"erro":"corpo_invalido","mensagem":"O corpo do pedido tem de ser JSON."}
--- corpo 'isto nao e json'      → HTTP 400 {"erro":"corpo_invalido",...}
--- corpo '{}'                   → HTTP 400 {"erro":"produto_id_invalido","mensagem":"produto_id em falta ou inválido. Valores aceites: pro_mensal, pro_anual, familia_mensal, familia_anual."}
--- corpo 'null'                 → HTTP 500 Internal Server Error   <<< DEFEITO
--- corpo '[]'                   → HTTP 400 {"erro":"produto_id_invalido",...}
--- produto_id 123 (número)      → HTTP 400 {"erro":"produto_id_invalido",...}
--- produto_id "PRO_MENSAL"      → HTTP 400 {"erro":"produto_id_invalido",...}
--- produto_id "pro_semanal"     → HTTP 400 {"erro":"produto_id_invalido",...}
--- token_compra "   "           → HTTP 400 {"erro":"token_compra_em_falta","mensagem":"token_compra é obrigatório."}
--- token_compra 12345 (número)  → HTTP 400 {"erro":"token_compra_em_falta",...}
--- token_compra null            → HTTP 400 {"erro":"token_compra_em_falta",...}
--- pro_mensal / pro_anual / familia_mensal / familia_anual, token "tok-verif-1"
                                 → HTTP 503 {"erro":"sem_play_service_account","mensagem":"A conta de serviço do Google Play ainda não está configurada. A validação de compras fica disponível quando a app for publicada."} (4×)
--- repetida 1 e 2 (pro_anual)   → HTTP 503 sem_play_service_account (idêntico; nada gravado)
--- teste2 com o mesmo token     → HTTP 503 sem_play_service_account
--- OPTIONS sem JWT              → HTTP 200 ok
```

SELECT depois da bateria (execute_sql):
```
[{"agora":"2026-09-05 23:33:40.913374+00","assinaturas_tok_verif":0,"total_assinaturas":0,"plano_teste":"free","plano_teste2":"free","segredo_play_existe":1}]
```
(`segredo_play_existe`=1 aqui porque o segredo temporário do passo seguinte já tinha sido escrito; 0 antes e depois — ver abaixo.)

Log do 500 (`query_logs`, source `function_logs`):
```
TypeError: Cannot read properties of null (reading 'produto_id')
    at Object.handler (file:///var/tmp/sb-compile-edge-runtime/functions/validar-compra-play/index.ts:94:34)
```
Causa: `corpo = await req.json()` aceita o literal JSON `null`; a linha `typeof corpo.produto_id` rebenta. Correção de uma linha: `corpo = (await req.json()) ?? {}` ou validar `typeof corpo !== 'object' || corpo === null` → 400 `corpo_invalido`.

### Trigger `protege_campos_servidor` deixa passar o service_role (o update de `profiles.plano` não é anulado)

```sql
select set_config('request.jwt.claims', '{"role":"service_role"}', true);
set local role service_role;
update public.profiles set plano = 'familia' where email = 'teste@emdia.pt';  -- registar plano
update public.profiles set plano = 'free' where email = 'teste@emdia.pt';     -- reverter
```
Resultado literal:
```
[{"passo":"apos_update_como_service_role","plano":"familia","papel":"service_role"},{"passo":"revertido_para_free","plano":"free","papel":"service_role"}]
```

### Caminho pós-503 exercitado com segredo TEMPORÁRIO no Vault (apagado no fim)

1. `guardar_segredo('play_service_account','nao-e-json')` → chamada `pro_mensal`/`tok-verif-1`:
   `HTTP 503 {"erro":"play_service_account_invalida","mensagem":"O segredo play_service_account não é JSON válido."}`
   (prova que a função lê mesmo o Vault via `ler_segredo`).
2. `guardar_segredo('play_service_account','{"client_email":"verificacao-falsa@exemplo.iam.gserviceaccount.com","private_key":"-----BEGIN PRIVATE KEY-----\nAAAA\n-----END PRIVATE KEY-----\n"}')` → chamada:
   `HTTP 502 {"erro":"oauth_google_falhou","mensagem":"Não foi possível autenticar junto da Google."}`
   Log literal: `oauth google unknown/unsupported ASN.1 DER tag: 0x00` (o `npm:jose` / `importPKCS8` correu de verdade).
3. `delete from vault.secrets where name = 'play_service_account' and description = 'TEMPORARIO verificacao — apagar';` → SELECT literal:
   `[{"agora":"2026-09-05 23:34:31.756297+00","segredo_play_existe":0,"total_assinaturas":0,"plano_teste":"free"}]`
4. Chamada final depois de apagar (saída literal do script):

```
login 200
--- depois de apagar o segredo temporario
POST {"produto_id": "pro_mensal", "token_compra": "tok-verif-1"}
HTTP 503
{"erro":"sem_play_service_account","mensagem":"A conta de serviço do Google Play ainda não está configurada. A validação de compras fica disponível quando a app for publicada."}

```

### Não exercido (continua sem prova real, por falta de credenciais)

GET `subscriptionsv2` na Google, 400 `produto_nao_corresponde`, 409 `token_de_outro_utilizador`, upsert em `assinaturas`, mudança real de `profiles.plano` pela função, `:acknowledge`. Fica para o bloco de publicação com a service account verdadeira.

### Veredicto do verificador

**Reprovado por 1 defeito real:** corpo JSON `null` → HTTP 500 em vez de 400 (`supabase/functions/validar-compra-play/index.ts`, linhas 75-81: `corpo = await req.json()` sem guardar contra `null`). Tudo o resto verificado bate com a especificação. Reproduzir: `POST /functions/v1/validar-compra-play` com JWT válido, `Content-Type: application/json`, corpo literal `null`.
