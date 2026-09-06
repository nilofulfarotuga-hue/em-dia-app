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

## Verificação independente

**Verificador com contexto limpo — 2026-09-05 23:37–23:43 UTC (= 2026-09-06 00:37–00:43 Lisboa).**
Objetivo: derrubar o trabalho. Script: scratchpad `verif_avisos.py` (fases `AD`, `E`, `F`; Python urllib; tokens/segredos nunca impressos). Utilizador usado: **teste2** (`fcb4a7ad-5202-4148-9e37-d5f0ed5e76d2`), para não colidir com a outra sessão que limpa as tabelas do `teste@`.

### V1. Deploy e código

`list_edge_functions` → `avisos-cron` `status: ACTIVE`, `version: 1`, `verify_jwt: true`, `ezbr_sha256: e6e1e41e…`. `get_edge_function` devolveu 6 ficheiros (`avisos-cron/index.ts`, `_shared/cors.ts`, `segredos.ts`, `mensagens.ts`, `fcm.ts`, `google_oauth.ts`) **iguais** aos ficheiros locais em `supabase/functions/`.

### V2. Segredos e números cravados

```
grep -rn -E "AIza|private_key|sk_|eyJ" supabase/functions docs/provas
→ só nomes de campo (sa.private_key) em fcm.ts/google_oauth.ts. Nenhum valor.
grep -rn -E "21\.4|15000|537\.13|0\.75" supabase/functions   (excluindo regras_test.ts)
→ 0 resultados.
```
Regras lidas da BD pela função: `push_hora_lisboa=9`, `iva_isencao_aviso=12000`, `ipo_avisos_dias=[30,7]` (confirmado por SELECT em `regras_legais`).
Ressalva (não é invenção, mas fica escrito): `mensagens.ts` tem "15.000 €", "3,49 €", "29,90 €" dentro dos textos — cópia literal de `lib/l10n/app_pt.arb` / `app_pt_BR.arb` (confirmado por `grep` nos .arb; os 9 textos batem palavra a palavra). O "15.000" coincide hoje com `regras_legais.iva_isencao_limite=15000` mas não vem de lá.

### V3. Autenticação e entradas fora do domínio (todas com saída literal)

| # | Chamada | HTTP | Resposta |
|---|---|---|---|
| A1 | sem `Authorization` nenhum, `{forcar:true}` | 401 | `{"code":"UNAUTHORIZED_NO_AUTH_HEADER","message":"Missing authorization header"}` (gateway, verify_jwt) |
| A2 | anon, sem `x-cron-secret` | 401 | `{"erro":"nao_autorizado","mensagem":"Só o cron (x-cron-secret) ou um admin podem chamar esta função."}` |
| A3 | anon + `x-cron-secret: errado-123` | 401 | idem |
| A4 | anon + `x-cron-secret:` (vazio) | 401 | idem |
| A5 | JWT do `teste2` (não admin) | 401 | idem |
| A6 | JWT não-admin + segredo errado | 401 | idem |
| B1 | segredo certo, **sem corpo** | 200 | `{"saltado":true,"hora_lisboa":0,"data_lisboa":"2026-09-06","hora_push":9}` |
| B2 | segredo certo, corpo `isto nao e json` | 200 | `{"saltado":true,…}` (não rebentou com 500) |
| B3 | segredo certo, `{"forcar":"sim"}` | 200 | `{"saltado":true,…}` (só `=== true` força) |
| B4 | segredo certo, `{"forcar":1}` | 200 | `{"saltado":true,…}` |
| B5 | `GET` com segredo | 405 | `{"erro":"metodo_nao_permitido"}` |
| B6 | corpo real do pg_cron `{"origem":"pg_cron"}` | 200 | `{"saltado":true,…}` |

### V4. Os 7 tipos de aviso no mesmo dia + idempotência

Dados criados via REST com o JWT do `teste2` (HTTP 201/200), `hoje` Lisboa = 2026-09-06:
carro `VR-77-ZZ` (`914bc497…`); obrigações `verif_5dias` (ss_pagamento, data_limite 2026-09-11, 100), `verif_dia` (iva_pagamento, aviso_em hoje, 2500.5), `verif_passado` (multa, data_limite 2026-09-05, **pendente**), `verif_carro` (ipo, data_limite 2026-10-06 = hoje+30, carro_id), `verif_fim_isencao` (fim_isencao_ss, data_limite 2027-03-01, aviso_em hoje, 20.3), `verif_sem_valor` (outro, data_limite hoje+5, **sem valor_estimado**); rendimento 12345.67 em 2026-01; `ultimo_acesso` = há 10 dias.

D1 — `x-cron-secret` + `{"forcar":true}`:
```
HTTP 200
{"hora_lisboa":0,"data_lisboa":"2026-09-06","forcado":true,"autenticado":"cron","fcm_configurado":false,"utilizadores":2,"eventos_criados":8,"enviados":0,"sem_fcm":8,"sem_token":0,"limite_plano":0,"erros":0,"passadas_marcadas":1,"detalhes":[{"user_id":"fcb4a7ad-5202-4148-9e37-d5f0ed5e76d2","eventos":8,"tipos":["5_dias","dia","carro","fim_isencao","5_dias","passado","vigia_iva","reativacao"],"resultado":"sem_fcm","tokens":0}]}
```
D2 — mesma chamada logo a seguir:
```
HTTP 200
{"hora_lisboa":0,"data_lisboa":"2026-09-06","forcado":true,"autenticado":"cron","fcm_configurado":false,"utilizadores":2,"eventos_criados":0,"enviados":0,"sem_fcm":0,"sem_token":0,"limite_plano":0,"erros":0,"passadas_marcadas":0,"detalhes":[]}
```
SELECT de confirmação (eventos do `teste2`, join com obrigações) — 8 linhas, todas `dia=2026-09-06`, `resultado=sem_fcm`, `erro="Sem credenciais FCM no Vault (fcm_service_account). O aviso ficou registado mas não foi enviado."`:
- `5_dias` → "Faltam 5 dias para SS verif 5 dias (100,00 €). Toca aqui para ver como pagar." (obrigacao `22db2bcc…`)
- `5_dias` → "Faltam 5 dias para Sem valor verif (valor por confirmar). Toca aqui…" (sem valor_estimado → texto de recurso)
- `carro` → "A inspeção do teu carro (VR-77-ZZ) é até 06/10/2026. Marca já — os centros enchem no fim do mês."
- `dia` → "É hoje. IVA verif dia, 2.500,50 €, até à meia-noite. Já pagaste? Toca em Já paguei."
- `fim_isencao` → "Daqui a 30 dias acaba a tua isenção de Segurança Social. A partir de março vais pagar cerca de 20,30 €/mês. …"
- `passado` → "Passou o dia 05/09/2026 e não marcaste como pago. …" (obrigação `verif_passado` ficou `estado=passado` → `passadas_marcadas:1` é real)
- `reativacao` → "Está tudo em dia do teu lado. Não precisas de fazer nada. Eu avisarei." (`obrigacao_id` NULL)
- `vigia_iva` → "Atenção: já vais em 12.345,67 € este ano. Se passares os 15.000 €, …" (`obrigacao_id` NULL)

Moeda `1.234,56 €`, datas `dd/mm/aaaa`, mês por extenso e matrícula: corretos.

### V5. `limite_plano` e `trial_31` (uma vez só)

- Inseridos por SQL 3 eventos falsos `resultado='ok'`, `dia=2026-09-05`, título `FAKE verif limite N` (apagados no fim).
- `PATCH profiles.trial_ate` via REST com JWT do utilizador **não alterou** o campo (continuou 2026-10-05): o trigger `trg_profiles_servidor` (`protege_campos_servidor`, migration 0001 l.50-63) protege-o — correto, é do servidor. Alterado então por SQL: `trial_ate = now() - 1 day` → `plano_efetivo='free'`, `feature_limite(uid,'avisos_push')=3`, `ok_mes=3`.

F1:
```
HTTP 200
{"hora_lisboa":0,"data_lisboa":"2026-09-06","forcado":true,"autenticado":"cron","fcm_configurado":false,"utilizadores":2,"eventos_criados":1,"enviados":0,"sem_fcm":0,"sem_token":0,"limite_plano":1,"erros":0,"passadas_marcadas":0,"detalhes":[{"user_id":"fcb4a7ad-5202-4148-9e37-d5f0ed5e76d2","eventos":1,"resultado":"limite_plano","limite":3,"ok_este_mes":3}]}
```
F2 (repetida): `"eventos_criados":0,"limite_plano":0,"detalhes":[]`.
SELECT: `trial_31 | 2026-09-06 | "Mês grátis acabou" | "Hoje evitaste multas durante um mês. Para continuar assim é 3,49 € por mês — menos que uma multa. Toca para ativar." | resultado=limite_plano | enviado_em=NULL`.

### V6. PROBLEMA REAL encontrado — `reativacao` repete na viragem do mês

A função carrega `eventos_push` só com `dia >= inicioMes` (`index.ts`: `admin.from('eventos_push')….gte('dia', inicioMes)`), mas a regra `reativacao` é "sem evento reativacao nos **últimos 7 dias**". Nos primeiros 6 dias de cada mês um `reativacao` enviado no fim do mês anterior é invisível → repete.

Reprodução (feita):
1. `delete … tipo='reativacao' and dia='2026-09-06'`; `insert … tipo='reativacao', dia='2026-08-31'` (há 6 dias) para o `teste2` com `ultimo_acesso` há 10 dias.
2. Chamada E2 (`x-cron-secret` + `{"forcar":true}`):
```
HTTP 200
{"hora_lisboa":0,"data_lisboa":"2026-09-06","forcado":true,"autenticado":"cron","fcm_configurado":false,"utilizadores":2,"eventos_criados":2,"enviados":0,"sem_fcm":2,"sem_token":0,"limite_plano":0,"erros":0,"passadas_marcadas":0,"detalhes":[{"user_id":"fcb4a7ad-5202-4148-9e37-d5f0ed5e76d2","eventos":2,"tipos":["dia","reativacao"],"resultado":"sem_fcm","tokens":0}]}
```
(o `dia` é da obrigação `verif_limite`/seguro inserida nesse passo; o **`reativacao` não devia existir**.)
3. SELECT: `reativacao | 2026-08-31 | FAKE reativacao ha 6 dias` **e** `reativacao | 2026-09-06 | Estás em dia | sem_fcm` — dois avisos em 6 dias.

Correção sugerida (1 linha): ler os eventos desde `min(inicioMes, ha7Dias)` (ou uma query própria para `reativacao` com `dia >= ha7Dias`). O carregamento por mês está certo para `vigia_iva` (regra é "este mês") e para `limite_plano`.

### V7. O que NÃO consegui exercitar (igual ao autor)

- Envio FCM real (`ok`/`sem_token`/`erro`, apagar tokens `UNREGISTERED`) e o título agrupado "Tens N coisas hoje": não há `fcm_service_account` no Vault (`select count(*) from vault.secrets where name='fcm_service_account'` → 0) nem `push_tokens` (0 linhas). O agrupamento só é observável no envio. Precisa do clique humano no Firebase.
- Caminho `autenticado:'admin'` com JWT: não há linha em `public.admins` nem `app_metadata.role='admin'` nos 2 utilizadores.
- Ressalva já conhecida: a `unique (user_id,tipo,dia,obrigacao_id)` **não trava NULL** — provei-o ao inserir 3 eventos iguais com `obrigacao_id NULL` sem erro. A função filtra em código; a garantia na BD seria `unique nulls not distinct`.

### V8. Limpeza

`profiles.trial_ate` do `teste2` reposto em `2026-10-05 23:25:00.207976+00`, `ultimo_acesso=NULL` (SELECT: `plano_efetivo='trial'`); eventos `FAKE%` apagados (`fake_restantes=0`). Ficaram como evidência os 10 eventos reais do `teste2`, as 7 obrigações `verif_*`, o carro `VR-77-ZZ` e o rendimento de 12345,67 (todos do utilizador de teste 2).

**Veredicto do verificador:** o que a ordem pedia (401, saltar fora das 9h, `5_dias`/`dia`, `sem_fcm`, idempotência) está provado e bate; os 7 tipos, `limite_plano` e `trial_31` também. **Não aprovado** por causa do V6 (resultado errado reproduzido) — correção pequena, depois disso passa.
