# Prova — Edge Function `avisos-cron`

**Data/hora:** 2026-09-05 23:32–23:35 UTC (= 2026-09-06 00:32–00:35 Lisboa)
**Projeto:** tgdmgtmknbwhcqoxtjbs
**Ficheiros:** `supabase/functions/avisos-cron/index.ts`, `supabase/functions/_shared/mensagens.ts` (novo), `supabase/functions/_shared/fcm.ts` (novo); reutiliza `_shared/cors.ts`, `_shared/segredos.ts`, `_shared/google_oauth.ts` (já existiam, de outras funções).

## 1. Deploy

`deploy_edge_function` (MCP), `verify_jwt: true`, entrypoint `avisos-cron/index.ts` + 5 ficheiros `_shared/*.ts`. Resposta literal:

```json
{"id":"c4cc4769-b4d0-478a-aeb4-5ca97d2a86e3","slug":"avisos-cron","name":"avisos-cron","status":"ACTIVE","version":1,"verify_jwt":true,"entrypoint_path":"file:///tmp/user_fn_tgdmgtmknbwhcqoxtjbs_c4cc4769-b4d0-478a-aeb4-5ca97d2a86e3_1/source/avisos-cron/index.ts"}
```

## 2. Estado prévio (SELECT)

```sql
select (select count(*) from vault.secrets where name='cron_secret') as tem_cron_secret,
       (select count(*) from vault.secrets where name='fcm_service_account') as tem_fcm,
       (select count(*) from auth.users) as users,
       (select jobname from cron.job where jobname='em-dia-avisos-hora') as cron;
-- [{"tem_cron_secret":1,"tem_fcm":0,"users":2,"cron":"em-dia-avisos-hora"}]
```

O `cron_secret` já existia no Vault (não foi preciso `guardar_segredo`). **Não existe `fcm_service_account`** → caminho `sem_fcm` é o que se prova. Regras lidas da BD: `push_hora_lisboa=9`, `iva_isencao_aviso=12000`, `ipo_avisos_dias=[30,7]`.

## 3. Chamadas (Python urllib; tokens/segredos nunca impressos)

Todas com `Authorization: Bearer <anon>` (obrigatório pelo `verify_jwt`) e `apikey: <anon>`. Script: scratchpad `chamar.py` / `prova.py`.

### 3.1 SEM `x-cron-secret` (só anon) → 401

Body `{"forcar":true}`.
```
HTTP 401
{"erro":"nao_autorizado","mensagem":"Só o cron (x-cron-secret) ou um admin podem chamar esta função."}
```

### 3.2 JWT do utilizador de teste (não é admin) → 401

Body `{"forcar":true}`.
```
HTTP 401
{"erro":"nao_autorizado","mensagem":"Só o cron (x-cron-secret) ou um admin podem chamar esta função."}
```

### 3.3 `x-cron-secret` correto, SEM `forcar` (00h Lisboa ≠ 9h) → saltado

Body `{"origem":"pg_cron"}` (o mesmo que o pg_cron manda).
```
HTTP 200
{"saltado":true,"hora_lisboa":0,"data_lisboa":"2026-09-06","hora_push":9}
```

### 3.4 Preparar dados + `x-cron-secret` + `{"forcar":true}` — 1.ª chamada

Nota: uma primeira inserção por SQL (23:30 UTC) desapareceu antes da chamada — outra sessão está a limpar as tabelas do utilizador de teste (`select count(*) from public.obrigacoes` → 0 às 23:33). Repetiu-se com inserção via REST (JWT do utilizador, `on_conflict=user_id,chave_unica`) e chamada imediata no mesmo script.

Inseridas (HTTP 201) para `a2194877-dcbc-49fd-9197-e826948eec16` (teste@emdia.pt), `hoje_lisboa = 2026-09-06`:
- `ss_pagamento` "Pagamento à Segurança Social (teste push 5 dias)", `data_limite=2026-09-11` (hoje+5), `aviso_em=2026-09-10`, 123.45 → id `76b16f17-ac69-44f2-a515-2122f4a55f85`
- `iva_pagamento` "Pagamento do IVA (teste push dia)", `data_limite=2026-09-07`, `aviso_em=2026-09-06` (hoje), 1234.56 → id `4a5fbb97-cdca-4cde-a2fb-f65b920275ae`

```
HTTP 200
{"hora_lisboa":0,"data_lisboa":"2026-09-06","forcado":true,"autenticado":"cron","fcm_configurado":false,"utilizadores":2,"eventos_criados":2,"enviados":0,"sem_fcm":2,"sem_token":0,"limite_plano":0,"erros":0,"passadas_marcadas":0,"detalhes":[{"user_id":"a2194877-dcbc-49fd-9197-e826948eec16","eventos":2,"tipos":["5_dias","dia"],"resultado":"sem_fcm","tokens":0}]}
```

### 3.5 Mesma chamada outra vez (não duplica)

```
HTTP 200
{"hora_lisboa":0,"data_lisboa":"2026-09-06","forcado":true,"autenticado":"cron","fcm_configurado":false,"utilizadores":2,"eventos_criados":0,"enviados":0,"sem_fcm":0,"sem_token":0,"limite_plano":0,"erros":0,"passadas_marcadas":0,"detalhes":[]}
```

## 4. SELECT de confirmação (MCP execute_sql, 23:35 UTC)

```sql
select e.tipo, e.dia, e.titulo, e.corpo, e.resultado, e.erro, e.enviado_em, e.obrigacao_id,
       (select count(*) from public.eventos_push) as total_eventos,
       (select count(*) from public.obrigacoes where origem_regra='teste_push') as obrig_teste_ainda_existem
from public.eventos_push e where e.user_id='a2194877-dcbc-49fd-9197-e826948eec16' order by e.tipo;
```
```json
[{"tipo":"5_dias","dia":"2026-09-06","titulo":"Faltam 5 dias","corpo":"Faltam 5 dias para Pagamento à Segurança Social (teste push 5 dias) (123,45 €). Toca aqui para ver como pagar.","resultado":"sem_fcm","erro":"Sem credenciais FCM no Vault (fcm_service_account). O aviso ficou registado mas não foi enviado.","enviado_em":"2026-09-05 23:34:05.638+00","obrigacao_id":"76b16f17-ac69-44f2-a515-2122f4a55f85","total_eventos":2,"obrig_teste_ainda_existem":2},
 {"tipo":"dia","dia":"2026-09-06","titulo":"É hoje","corpo":"É hoje. Pagamento do IVA (teste push dia), 1.234,56 €, até à meia-noite. Já pagaste? Toca em Já paguei.","resultado":"sem_fcm","erro":"Sem credenciais FCM no Vault (fcm_service_account). O aviso ficou registado mas não foi enviado.","enviado_em":"2026-09-05 23:34:05.638+00","obrigacao_id":"4a5fbb97-cdca-4cde-a2fb-f65b920275ae","total_eventos":2,"obrig_teste_ainda_existem":2}]
```

`total_eventos = 2` depois de duas chamadas → sem duplicados. Moeda "1.234,56 €" e textos PT-PT copiados do `app_pt.arb`.

## 5. O que ficou provado / o que NÃO ficou

| Bloco | Estado | Prova |
|---|---|---|
| 401 sem segredo e com JWT não-admin | feito | 3.1, 3.2 |
| Saltar fora das 9h de Lisboa sem `forcar` | feito | 3.3 |
| `marcar_obrigacoes_passadas()` chamada | feito (`passadas_marcadas: 0`, não havia vencidas) | 3.4 |
| Avisos `5_dias` e `dia` + registo em `eventos_push` | feito | 3.4, 4 |
| Idempotência (1 por obrigação por dia) | feito (`eventos_criados: 0` na 2.ª) | 3.5, 4 |
| `sem_fcm` sem falhar | feito | 4 |
| Envio FCM real (`ok`), `sem_token`, `erro`, tokens inválidos apagados | **NÃO provado** — não há `fcm_service_account` no Vault nem `push_tokens` | — |
| `passado`, `vigia_iva`, `fim_isencao`, `carro`, `trial_25`, `trial_31`, `reativacao`, agrupamento "Tens N coisas hoje", `limite_plano` | código escrito, **não exercitado** nesta prova (só os 2 cenários pedidos) | — |
| Chamada por admin com JWT | **não provado** — não há conta admin (nilofulfarotuga@gmail.com / boraappbora@gmail.com) em `auth.users` | — |

## 6. Falta (precisa de clique humano)

1. **Firebase:** criar projeto FCM, descarregar o JSON da service account e guardar: `select public.guardar_segredo('fcm_service_account', '<json>', 'fcm');` (via MCP/SQL — nunca em ficheiro do repo). Sem isto todos os avisos ficam `sem_fcm`.
2. A app tem de gravar o token em `push_tokens` (lado Flutter — sessão principal).

## 7. Decisões de implementação a rever (PARA O DANILO / sessão principal)

- **`passado` repete todos os dias** enquanto a obrigação estiver em estado `passado` (a ordem diz "no máximo 1 por obrigação por dia" — cumprido; mas não diz quando parar). Se for demasiado, limitar a X dias após `data_limite`.
- **`vigia_iva` só para `regime_iva = 'isento_53'`** (para quem já está no regime normal o texto "tens de cobrar IVA" não faz sentido). Não estava na ordem — decisão minha, fácil de tirar.
- **`trial_31` não sai a quem já tem plano efetivo pro/família** (`plano_efetivo(uid)`), porque o texto pede para "ativar".
- Tipos sem `obrigacao_id` (vigia_iva, trial_*, reativacao): a `unique (user_id,tipo,dia,obrigacao_id)` **não trava com NULL** (NULL ≠ NULL em Postgres). A função filtra pelo que já existe em `eventos_push` antes de inserir; se quiseres a garantia na BD, migração futura: `unique nulls not distinct`.
- Títulos das notificações (ex.: "Faltam 5 dias", "É hoje", "Passou o prazo") não existem no `.arb`; ficaram em `_shared/mensagens.ts`. "Tens N coisas hoje" / "Você tem N coisas hoje" idem.
- Os `.arb` têm "15.000 €", "3,49 €", "29,90 €" dentro dos textos push — foram copiados tal e qual (fonte: a app), não vêm de `regras_legais`.
