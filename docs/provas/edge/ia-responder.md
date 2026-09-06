# Prova — Edge Function `ia-responder`

Data/hora: 2026-09-05 23:33–23:38 UTC (2026-09-06 00:33–00:38 Lisboa)
Projeto: tgdmgtmknbwhcqoxtjbs · deploy via MCP `deploy_edge_function` (verify_jwt: true)

```
{"id":"709e560e-fdb6-416e-ba35-526a723cf4f4","slug":"ia-responder","status":"ACTIVE","version":1,"verify_jwt":true,
 "entrypoint_path":".../source/ia-responder/index.ts"}
```

Ficheiros: `supabase/functions/ia-responder/index.ts`, `supabase/functions/_shared/{cors,segredos,gemini,contexto_ia}.ts`.

## Estado dos segredos no arranque (SQL via execute_sql, corre como postgres)

```sql
select 'gemini', (public.ler_segredo('gemini_api_key') is not null)
union all select 'resend', (public.ler_segredo('resend_api_key') is not null)
union all select 'cron', (public.ler_segredo('cron_secret') is not null);
```
```
[{"k":"gemini","existe":false},{"k":"resend","existe":false},{"k":"cron","existe":true}]
```
→ **Não há chave Gemini no Vault.** As 3 perguntas reais ("abri atividade em março…", "passei os 15 mil…", "inspeção do carro de 2021") **não foram feitas** — não há resposta do modelo para guardar. Fica provado o caminho sem chave.

## Chaves de custo criadas em `regras_legais` (não existiam)

```sql
insert into public.regras_legais (chave, valor_num, unidade, ano, descricao, fonte_url, confianca, verificado_em) values
('ia_custo_entrada_eur_por_milhao', 0.28, 'eur', 2026, 'preço aproximado do Gemini Flash por milhão de tokens (entrada)', 'https://ai.google.dev/pricing', 'aproximado', '2026-09-06'),
('ia_custo_saida_eur_por_milhao', 2.30, 'eur', 2026, 'preço aproximado do Gemini Flash por milhão de tokens (saída)', 'https://ai.google.dev/pricing', 'aproximado', '2026-09-06')
on conflict (chave) do nothing;
select chave, valor_num, unidade, confianca from public.regras_legais where chave like 'ia_custo_%' order by 1;
```
```
[{"chave":"ia_custo_alarme_dia_eur","valor_num":"0.50","unidade":"eur","confianca":"oficial"},
 {"chave":"ia_custo_entrada_eur_por_milhao","valor_num":"0.28","unidade":"eur","confianca":"aproximado"},
 {"chave":"ia_custo_saida_eur_por_milhao","valor_num":"2.30","unidade":"eur","confianca":"aproximado"}]
```

## Teste 1 — sem JWT → 401 (gateway, verify_jwt)

`POST /functions/v1/ia-responder` · headers: apikey (anon) · body `{"pergunta":"abri atividade em março, quando começo a pagar?"}`
```
HTTP 401
{"code":"UNAUTHORIZED_NO_AUTH_HEADER","message":"Missing authorization header"}
```

## Teste 2 — com JWT do utilizador de teste (teste@emdia.pt, plano efetivo `trial`), sem chave Gemini → 503

Body `{"pergunta":"abri atividade em março, quando começo a pagar?"}` · 2026-09-05T23:34:01Z
```
HTTP 503
{"erro":"sem_gemini_api_key","mensagem":"O assistente ainda não está ligado: falta a chave da Gemini no Vault (gemini_api_key). Tenta mais tarde."}
```
Nota: o 503 acontece **depois** do limite ter sido verificado (feature_limite → null em trial, logo passa) e do contexto ter sido montado; a chave é a última coisa que falta.

## Teste 3 — limite do plano free → 402

Preparação (SQL): tirar o trial ao utilizador de teste e inserir 5 conversas de chat no mês corrente.
```sql
update public.profiles set trial_ate = now() - interval '1 day' where user_id = 'a2194877-dcbc-49fd-9197-e826948eec16';
insert into public.conversas_ia (user_id, pergunta, resposta, variante, modelo, modo)
select 'a2194877-dcbc-49fd-9197-e826948eec16', 'teste limite ' || g, 'resposta de teste', 'pt', 'teste', 'chat' from generate_series(1,5) g;
select public.plano_efetivo(uid) as plano_efetivo, public.feature_limite(uid,'ia_perguntas') as limite, (count chat no mês) as usadas_mes ...
```
```
[{"plano_efetivo":"free","limite":5,"extrato_permitido":false,"usadas_mes":5}]
```
(`feature_flags.ia_perguntas.limite_free` já era 5 no seed — não foi preciso alterar.)

Chamada: body `{"pergunta":"passei os 15 mil, e agora?"}` · 2026-09-05T23:38:18Z
```
HTTP 402
{"limite":true,"usadas":5,"limite_valor":5,"mensagem":"Já usaste as 5 perguntas grátis deste mês. Com o plano Pro as perguntas são ilimitadas."}
```
(O campo chama-se `limite_valor` porque `limite: true` é a bandeira pedida; a app lê `usadas` e `limite_valor`.)

Limpeza (SQL) e confirmação:
```sql
update public.profiles set trial_ate = '2026-10-05 23:25:00.207976+00' where user_id = 'a2194877-...';
delete from public.conversas_ia where user_id = 'a2194877-...' and modelo = 'teste' and pergunta like 'teste limite %';
select public.plano_efetivo(uid), trial_ate, count(conversas_ia), count(tickets_suporte) ...
```
```
[{"plano_efetivo":"trial","trial_ate":"2026-10-05 23:25:00.207976+00","conversas_restantes":0,"tickets":4}]
```

## Logs das funções (query_logs, 23:30–23:40 UTC, source function_logs)

Para a função `709e560e…` (ia-responder) só há linhas `booted` / `shutdown` — nenhum `console.error` (nem `feature_limite falhou`, nem `conversas_ia insert falhou`). O único `error` no intervalo é de outra função (`21eddb85…`, validar-compra-play: "oauth google unknown/unsupported ASN.1 DER tag") — não é desta.

## O que NÃO ficou provado (falta clique humano)

- **Resposta real do Gemini**: precisa da chave no Vault. Quando o Danilo a tiver, guardar com
  `select public.guardar_segredo('gemini_api_key', '<chave>', 'Gemini API key');` (via SQL/MCP, nunca no repo) e repetir as 3 perguntas:
  1. "abri atividade em março, quando começo a pagar?" 2. "passei os 15 mil, e agora?" 3. "quando é a inspeção do meu carro de 2021?"
  Verificar depois: `select pergunta, variante, modelo, tokens_entrada, tokens_saida, custo_tokens, fora_das_regras from conversas_ia order by criado_em desc limit 3;`
- Por consequência, também não está provado: o registo em `conversas_ia` com tokens/custo reais, o `fora_das_regras` → ticket `guia_novo`, e a deteção da variante `br` (código: marcas você/tá/celular/ônibus/aposentadoria/cê/pra /né/tô/INSS/CPF; sem marca usa `profiles.variante_pt`).

## Decisões de implementação (para quem vier a seguir)

- Limite: aplica-se em qualquer modo, mas conta só linhas `modo='chat'` do mês corrente (início do mês em Lisboa calculado na função). `feature_limite` null = sem limite (trial/pro/família).
- Contexto enviado ao modelo: TODAS as `regras_legais` (chave, valor, unidade, confianca, descricao, fonte), `irs_escaloes` do ano corrente, guias publicados (corpo_pt até 1500 chars), perfil (com fim da isenção = 1.º dia do mês de abertura + `ss_isencao_meses`, lido da regra e não fixo no código), soma de rendimentos do ano, 10 obrigações pendentes, carros.
- Se a resposta do modelo não terminar com "Informação geral, não substitui contabilista.", a função acrescenta essa linha.
- Custo em EUR = entrada×0.28/1e6 + saída×2.30/1e6, preços lidos de `regras_legais` (não fixos no código).
- Ticket `guia_novo` só é criado em modo `chat` (em modo `suporte` já existe o ticket do suporte-auto).

## Verificação independente

Verificador com contexto limpo · 2026-09-05 23:43–23:45 UTC · JWT novo obtido por `POST /auth/v1/token?grant_type=password` para teste@emdia.pt (len=807) · script `verif_ia.py` (Python urllib, no scratchpad da sessão). Nenhum token nesta prova.

**Deploy confirmado** (`list_edge_functions`): `ia-responder` id `709e560e-fdb6-416e-ba35-526a723cf4f4`, `status: ACTIVE`, `version: 1`, `verify_jwt: true`. `get_edge_function` devolve os 5 ficheiros (`ia-responder/index.ts`, `_shared/{cors,segredos,contexto_ia,gemini}.ts`) — conteúdo igual ao repo local.

**Estado dos segredos no momento** (`execute_sql`):
```
[{"k":"gemini","existe":false},{"k":"resend","existe":false}]
```

**Chamadas feitas por mim (saída literal):**
```
### IA-1 sem JWT
HTTP 401  {"code":"UNAUTHORIZED_NO_AUTH_HEADER","message":"Missing authorization header"}
### IA-2 JWT + corpo vazio (não JSON)
HTTP 400  {"erro":"corpo_invalido","mensagem":"O corpo do pedido tem de ser JSON."}
### IA-3 JWT + {}
HTTP 400  {"erro":"pergunta_em_falta","mensagem":"Escreve a tua pergunta."}
### IA-4 pergunta 2001 chars
HTTP 400  {"erro":"pergunta_demasiado_longa","mensagem":"A pergunta tem de ter no máximo 2000 caracteres."}
### IA-5 pergunta só espaços
HTTP 400  {"erro":"pergunta_em_falta","mensagem":"Escreve a tua pergunta."}
### IA-6 pergunta número (não string)
HTTP 400  {"erro":"pergunta_em_falta","mensagem":"Escreve a tua pergunta."}
### IA-7 modo "xpto", pergunta válida (trial, sem chave) — modo desconhecido cai em 'chat'
HTTP 503  {"erro":"sem_gemini_api_key","mensagem":"O assistente ainda não está ligado: falta a chave da Gemini no Vault (gemini_api_key). Tenta mais tarde."}
### IA-8 GET com JWT
HTTP 405  {"erro":"metodo_nao_permitido","mensagem":"Usa POST."}
### IA-9 JWT inválido ("eyJ.abc.def")
HTTP 401  {"code":"UNAUTHORIZED_INVALID_JWT_FORMAT","message":"Invalid JWT"}
```

**Limite mensal — dos dois lados.** Preparação por SQL: `trial_ate = now() - 1 day` + 5 linhas em `conversas_ia` (modelo `verif`, modo `chat`). Confirmação:
```
[{"plano_efetivo":"free","limite":5,"extrato":false,"usadas_mes":5}]
```
```
### IA-402 free + 5 conversas
HTTP 402  {"limite":true,"usadas":5,"limite_valor":5,"mensagem":"Já usaste as 5 perguntas grátis deste mês. Com o plano Pro as perguntas são ilimitadas."}
### IA-402 modo 'suporte' com 5 usadas — também bloqueia (o limite aplica-se a qualquer modo, conta só 'chat')
HTTP 402  {"limite":true,"usadas":5,"limite_valor":5,"mensagem":"Já usaste as 5 perguntas grátis deste mês. Com o plano Pro as perguntas são ilimitadas."}
```
Apaguei 1 conversa (`usadas_mes: 4`) e repeti — abaixo do limite passa e para só na chave:
```
### IA-4de5 free + 4 conversas
HTTP 503  {"erro":"sem_gemini_api_key","mensagem":"O assistente ainda não está ligado: falta a chave da Gemini no Vault (gemini_api_key). Tenta mais tarde."}
```

**Limpeza e confirmação** (trial reposto, conversas `verif` apagadas):
```
[{"plano_efetivo":"trial","trial_ate":"2026-10-05 23:25:00.207976+00","conversas":0,"tickets_restantes":4,"tickets_verif":0}]
```

**Logs** (`query_logs`, function_logs, 23:42–23:46 UTC): fn `709e560e…` 15 linhas, `erros: 0`; filtro por `falhou|error` devolve `[]`.

**Colunas usadas em `construirContexto` existem todas** (information_schema): `guias(slug,titulo,resumo,corpo_pt,ordem,publicado)`, `irs_escaloes(ano,ate,taxa,parcela_abater,ordem,confianca)`, `profiles(tipo_atividade,data_abertura,regime_iva,rendimento_mensal_estimado,plano,variante_pt,tipo_rendimento,retencao_opcao)`, `rendimentos(valor_bruto,mes)`, `obrigacoes(tipo,descricao,data_limite,valor_estimado,origem_regra,estado)`, `carros(nome,matricula,data_matricula,proxima_ipo,uso_tvde,ativo)`. Dados disponíveis hoje: 62 regras (3 `por_confirmar`), 9 escalões 2026, 0 guias publicados, 1 carro do utilizador de teste.

**Segredos em ficheiros:** `grep -rnE 'AIza|private_key|sk_|eyJ' supabase/functions docs/provas` → só nomes de campo `private_key` em `fcm.ts`/`google_oauth.ts` (não são valores) e o eco desse grep noutra prova. Nada de chaves nem JWT.

**Números cravados:** `grep -rnE '21\.4|15000|537\.13|0\.75' supabase/functions` (excluindo `regras_test.ts`) → 0 ocorrências. Os preços de tokens (0.28/2.30) e `ss_isencao_meses` (12) são lidos de `regras_legais` em runtime (confirmado por SELECT: `ss_isencao_meses = 12`, `ss_taxa = 21.4`, `ia_custo_entrada… = 0.28`, `ia_custo_saida… = 2.30`).

**Observações (não bloqueiam):**
- O 402 devolve o número em `limite_valor` (a spec dizia `limite`, que colide com `limite: true`). A app em `lib/` ainda não chama esta função — quem a ligar tem de ler `usadas` e `limite_valor`.
- Continua por provar (sem chave no Vault, confirmado por SQL): resposta real do Gemini, registo em `conversas_ia` com tokens/custo, ticket `guia_novo`, variante `br`.

**Veredicto:** aprovado. Sem falha de execução, sem resultado errado, sem segredo em claro, sem número cravado.

## Redeploy e verificação final (03:50)

**Data:** 2026-09-06, 03:50–04:15 (hora de Lisboa). A chave `gemini_api_key` já está no Vault (`ler_segredo` devolve valor; não se copia).

**Deploy (MCP `deploy_edge_function`, `verify_jwt: true`, entrypoint `ia-responder/index.ts`, ficheiros `ia-responder/index.ts` + `_shared/cors.ts` + `_shared/segredos.ts` + `_shared/contexto_ia.ts` + `_shared/gemini.ts`):**
```
{"slug":"ia-responder","status":"ACTIVE","version":2,"updated_at":1788663595486,"verify_jwt":true,
 "ezbr_sha256":"7a9822ef24f653adba6f5c4275ebcfec69e8a5b69eff8cf9f0661851cb84a33c"}
```
Hash diferente da v1 (`f2167b4a…`): a v1 ainda tinha `'gemini-2.5-flash'`. `get_edge_function('ia-responder')` depois do deploy devolve em `_shared/gemini.ts`:
```
export function modeloGemini(): string {
  // gemini-2.5-flash deixou de existir para contas novas (404 provado 2026-09-06 01:20);
  // 'gemini-flash-latest' resolve para o Flash atual (3.8 em setembro de 2026).
  return Deno.env.get('GEMINI_MODEL')?.trim() || 'gemini-flash-latest'
}
```

**Chamadas** (Python `urllib`, `POST …/functions/v1/ia-responder`, `apikey` anon + `Authorization: Bearer <JWT de teste@emdia.pt>`; `feature_limite(uid,'ia_perguntas')` = `null` → sem limite, logo sem 402; `plano_efetivo` = `trial`).

Pergunta 1 — **passou**:
```
### PERGUNTA: abri atividade em março, quando começo a pagar?
HTTP 200
{"resposta": "Na Segurança Social, tens direito a 12 meses (ss_isencao_meses) de isenção (tempo em que não precisas de pagar).\n\nComo abriste atividade em março de 2026, a isenção termina a 2027-03-01 (ss_isencao_meses). Por isso, só começas a pagar à Segurança Social em abril de 2027, entre o dia 10 (ss_pagamento_dia_inicio) e o dia 20 de abril de 2027 (ss_pagamento_dia_fim), com uma taxa de 21.4% (ss_taxa).\n\nMas tem atenção aos outros pagamentos que chegam mais cedo:\n- No IRS (o imposto sobre o dinheiro que ganhas), tens um pagamento por conta no valor de 65% (irs_pagamentos_conta_pct) calculado para pagar a 2026-09-20 (irs_pagamentos_conta_datas).\n- Tens também uma multa pendente até 2026-10-01 (multa_pagamento_voluntario_dias_uteis).\n\nPróximo passo: Faz o pagamento por conta de IRS até 2026-09-20 (irs_pagamentos_conta_datas).\nInformação geral, não substitui contabilista.",
 "variante": "pt", "fora_das_regras": false, "usadas": 1, "limite": null}
```
Cita as chaves das regras (`ss_isencao_meses`, `ss_pagamento_dia_inicio`, `ss_pagamento_dia_fim`, `ss_taxa`, `irs_pagamentos_conta_pct`, `irs_pagamentos_conta_datas`, `multa_pagamento_voluntario_dias_uteis`), usa o perfil (abertura 2026-03-15) e as obrigações do utilizador, termina com `Próximo passo:` e com o rodapé fixo. Em PT-PT.

SELECT em `conversas_ia` (a única conversa de hoje):
```
{"id":"cd4f13f6-f3e8-438f-856c-da8734d35225","teste":true,"modo":"chat","modelo":"gemini-flash-latest","tokens_entrada":6087,"tokens_saida":1814,"custo_tokens":0.005877,"fora_das_regras":false,"variante":"pt","pergunta":"abri atividade em março, quando começo a pagar?","criado_em":"2026-09-06T03:04:48.27218+00:00"}
```
`modelo` = `gemini-flash-latest`, `custo_tokens` = 0,005877 € > 0 (6087 × 0,28/1e6 + 1814 × 2,30/1e6; os 1814 de saída incluem os tokens de raciocínio do modelo).

Perguntas 2 e 3 — **falharam por quota da Gemini** (saída literal; repetido 4× com 65 s de intervalo, sempre igual):
```
### PERGUNTA: passei os 15 mil, e agora?
HTTP 503
{"erro": "gemini_indisponivel", "detalhe": "HTTP 429: {\n  \"error\": {\n    \"code\": 429,\n    \"message\": \"You exceeded your current quota, please check your plan and billing details. … Quota exceeded for metric: generativelanguage.googleapis.com/generate_content_free_tier_requests, limit: 5, ", "mensagem": "O assistente está com muitos pedidos. Tenta daqui a um minuto."}

### PERGUNTA: quando é a inspeção do meu carro de 2021?
HTTP 503
{"erro": "gemini_indisponivel", "detalhe": "HTTP 429: … generate_content_free_tier_requests, limit: 5, ", "mensagem": "O assistente está com muitos pedidos. Tenta daqui a um minuto."}
```
A função mapeia o 429 para 503 `gemini_indisponivel` como desenhado. Nenhuma linha foi gravada em `conversas_ia` para estas duas (só existe a da pergunta 1).

**Diagnóstico da quota** (para saber se era por minuto ou por dia, sem tirar a chave do Vault: `net.http_post` a partir do Postgres com `public.ler_segredo('gemini_api_key')` no header; resposta lida em `net._http_response`, pedido 5, 03:10:00Z):
```
status_code: 429
"quotaMetric": "generativelanguage.googleapis.com/generate_content_free_tier_requests",
"quotaId": "GenerateRequestsPerDayPerProjectPerModel-FreeTier",
"quotaDimensions": {"model": "gemini-3.8-flash", "location": "global"},
"quotaValue": "20"
```
Ou seja: `gemini-flash-latest` resolve hoje para `gemini-3.8-flash`, e o free tier dá **20 pedidos por dia** por modelo (o `limit: 5` da mensagem truncada é a quota por minuto). Os 20 de hoje já estavam gastos (sessões anteriores + a pergunta 1). Repõe à meia-noite do Pacífico (08:00 de Lisboa).

**PARA O DANILO:** com o free tier (20 pedidos/dia) o assistente não aguenta nem os testes, quanto mais utilizadores. Para lançar é preciso ativar faturação no projeto Google AI Studio (o modelo é barato: a pergunta 1 custou 0,0059 €) — é um clique humano.

## Roda de modelos (04:20)

**Data:** 2026-09-06, 04:15–04:21 (hora de Lisboa). O coordenador alterou `_shared/gemini.ts`: em 429 (ou 404 "not found") a chamada passa ao modelo seguinte de `RODA_MODELOS` (`gemini-flash-latest`, `gemini-3.7-flash`, `gemini-3.6-flash`, `gemini-3.5-flash`, `gemini-flash-lite-latest`, `gemini-3.5-flash-lite`, `gemini-3.1-flash-lite`, `gemini-2.5-flash-lite`) — cada modelo tem a sua quota diária de 20 no free tier.

**Deploy (mesmo processo, `verify_jwt: true`):**
```
{"slug":"ia-responder","status":"ACTIVE","version":3,"updated_at":1788664560365,"ezbr_sha256":"224347f6f30d1b19e80cfe0088d3fee69535721b9254d297986a9cacf068a7ca"}
```
`get_edge_function` (feito no `ler-extrato` v3, cujo `_shared/gemini.ts` é byte a byte o mesmo enviado aqui) devolve `export const RODA_MODELOS = [ 'gemini-flash-latest', 'gemini-3.7-flash', … ]` e o ciclo `for (const candidato of roda) { … if (resp.status === 429 || …) continue … }` — está no ar.

**Q2 (literal, JWT do utilizador de teste):**
```
### IA Q2 | 04:19:37 | 8.3s | HTTP 200
{"resposta": "Como passaste o limite de 15 000 € (iva_isencao_limite), vais ter de começar a cobrar IVA (um imposto que se junta ao preço do teu trabalho).\n\nDepende do valor total que atingiste:\n- **Se estás entre 15 000 € e 18 750 € (iva_isencao_perda_imediata):** continuas sem cobrar IVA até ao fim deste ano. Só começas a cobrar IVA a partir de janeiro do próximo ano.\n- **Se passaste logo os 18 750 € (iva_isencao_perda_imediata):** perdes a isenção no momento. O teu próximo recibo já tem de incluir IVA à taxa normal de 23% (iva_taxa_normal).\n\nTens de avisar as Finanças sobre esta mudança no prazo de 15 dias úteis (iva_isencao_comunicacao_dias_uteis), entregando uma declaração de alterações de atividade.\n\nPróximo passo: Envia a declaração de alterações no Portal das Finanças no prazo de 15 dias úteis (iva_isencao_comunicacao_dias_uteis).\nInformação geral, não substitui contabilista.",
 "variante": "pt", "fora_das_regras": false, "usadas": 2, "limite": null}
```
Cita `iva_isencao_limite`, `iva_isencao_perda_imediata`, `iva_taxa_normal`, `iva_isencao_comunicacao_dias_uteis`; `Próximo passo:` + rodapé. Completa.

**Q3 (literal):**
```
### IA Q3 | 04:19:49 | 12.4s | HTTP 200
{"resposta": "a simple, child-friendly response:\n            - Os carros normais fazem a inspeção (ver se o carro está bom) aos 4, 6 e 8 anos (ipo_ligeiros_anos).\n            - O teu carro AA-11-BB foi matriculado a 28 de fevereiro de 2021.\n            - Por isso, a\nInformação geral, não substitui contabilista.",
 "variante": "pt", "fora_das_regras": false, "usadas": 3, "limite": null}
```
Cita `ipo_ligeiros_anos` e usa o carro do perfil (AA-11-BB, 2021-02-28), mas **vem cortada** ("Por isso, a") e sem `Próximo passo:`; o rodapé foi acrescentado pelo código (`if (!resposta.includes(RODAPE_FIXO))`), não pelo modelo.

**SELECT `conversas_ia` (as 4 conversas desta ronda, por ordem):**
```
{"id":"83f34ee2-…","modo":"chat","modelo":"gemini-3.7-flash","pergunta":"passei os 15 mil, e agora?","tokens_entrada":6088,"tokens_saida":1794,"custo_tokens":0.005831,"fim_resposta":"o_dias_uteis).\nInformação geral, não substitui contabilista.","criado_em":"2026-09-06T03:19:35Z"}
{"id":"ff51eab8-…","modo":"chat","modelo":"gemini-3.6-flash","pergunta":"quando é a inspeção do meu carro de 2021","tokens_entrada":6092,"tokens_saida":2044,"custo_tokens":0.006407,"fim_resposta":" - Por isso, a\nInformação geral, não substitui contabilista.","criado_em":"2026-09-06T03:19:48Z"}
{"id":"a3f7be2f-…","modo":"extrato","modelo":"gemini-3.6-flash","tokens_entrada":1368,"tokens_saida":336,"custo_tokens":0.001156,…}
{"id":"5b6378a4-…","modo":"suporte","modelo":"gemini-3.6-flash","tokens_entrada":6157,"tokens_saida":2044,"custo_tokens":0.006425,"fim_resposta":"passas a pagar\nInformação geral, não substitui contabilista.",…}
```
`modelo` gravado é um modelo da roda (`gemini-3.7-flash` na Q2, `gemini-3.6-flash` nas seguintes), **não** o `gemini-3.8-flash` esgotado. A roda funciona.

**Problema encontrado (não bloqueia a roda, mas é resultado errado para o utilizador):** Q3 e o suporte-auto têm `tokens_saida = 2044` ≈ `maxTokens: 2048` de `responderComIA` — o modelo esgotou o orçamento de saída (que inclui os tokens de raciocínio, `thoughtsTokenCount`) e a resposta chegou cortada (finishReason MAX_TOKENS). Como o código acrescenta o rodapé sempre que falta, o corte fica mascarado e passa por resposta completa (`fora_das_regras: false`). O `gemini-3.7-flash` (Q2, 1794 tokens) coube; o `gemini-3.6-flash` gasta mais a "pensar". Sugestão para o próximo passo: em `contexto_ia.ts` subir `maxTokens` (ex.: 4096) e/ou passar `thinkingConfig: { thinkingBudget: 512 }` em `generationConfig`; e tratar `finishReason === 'MAX_TOKENS'` como erro `resposta_cortada` em vez de colar o rodapé.

## Resposta inteira (04:35)

**Data:** 2026-09-06, 04:27–04:32 (hora de Lisboa). `_shared/gemini.ts` passou a ter `maxOutputTokens: opts.maxTokens ?? 4096`, `thinkingConfig: { thinkingBudget: 512 }` e devolve `cortada: true` (com aviso no texto) quando `finishReason === 'MAX_TOKENS'`.

**Deploy (mesmo processo, `verify_jwt: true`):**
```
{"slug":"ia-responder","status":"ACTIVE","version":4,"updated_at":1788665207544,"ezbr_sha256":"8873e7adf8d51f6365a662fba7fbb252a1759858a012bfcece483e0553ab0f53"}
```
`thinkingConfig` **não foi rejeitado** por nenhum modelo usado (sem 400): as duas chamadas abaixo passaram por `gemini-3.5-flash` e `gemini-flash-lite-latest` e responderam 200.

**Q3 (literal):**
```
### PERGUNTA quando é a inspeção do meu carro de 2021 | 04:30:23 | 10.3s | HTTP 200
{"resposta": "O teu carro (matrícula AA-11-BB) é usado para TVDE (o serviço de transportar pessoas em carros bonitos). Os carros que trabalham no TVDE têm de fazer um exame especial todos os anos para ver se estão seguros e sem estragos. \n\nNão tenho essa regra confirmada. Sugiro falares com um contabilista para te ajudar a saber a data certa.\n\nPróximo passo: Falar com um contabilista para confirmar a data da inspeção do teu carro TVDE o quanto antes.\nInformação geral, não substitui contabilista.",
 "variante": "pt", "fora_das_regras": true, "usadas": 4, "limite": null}
>>> penúltima linha começa por "Próximo passo:": True | última = rodapé: True
```
Inteira: termina em `Próximo passo:` e depois o rodapé (o rodapé veio do modelo, não foi colado). O carro do perfil é TVDE e a regra `ipo_tvde` está `por_confirmar`, por isso o modelo disse corretamente "Não tenho essa regra confirmada." → `fora_das_regras: true` e abriu-se o ticket `guia_novo` automaticamente (SELECT abaixo).

**Pergunta em PT-BR (literal):**
```
### PERGUNTA sou brasileiro, o tempo do INSS conta pra aposentadoria? | 04:30:25 | 2.3s | HTTP 200
{"resposta": "Sim! O tempo que você descontou no Brasil (INSS) conta para a sua reforma (aposentadoria) em Portugal. \n\nIsso acontece por causa do Acordo de Segurança Social Portugal–Brasil, que junta o tempo dos dois países (acordo_pt_br_url).\n\nPróximo passo: Guarde os seus papéis do INSS para quando precisar pedir a reforma.\nInformação geral, não substitui contabilista.",
 "variante": "br", "fora_das_regras": false, "usadas": 5, "limite": null}
>>> penúltima linha começa por "Próximo passo:": True | última = rodapé: True
```
`variante: "br"` detetada (marcas `INSS`, `pra `, `aposentadoria`), resposta em PT-BR ("você", "aposentadoria"), cita `acordo_pt_br_url`, inteira.

**SELECT `conversas_ia` + ticket:**
```
{"id":"80593533-7234-4a9b-a080-610a24cc4532","modo":"chat","modelo":"gemini-3.5-flash","variante":"pt","tokens_entrada":6092,"tokens_saida":578,"custo_tokens":0.003035,"fora_das_regras":true,"fim_resposta":"a inspeção do teu carro TVDE o quanto antes.\nInformação geral, não substitui contabilista.","criado_em":"2026-09-06T03:30:22Z"}
{"id":"193ed54d-22ad-4d3d-914f-44461295244d","modo":"chat","modelo":"gemini-flash-lite-latest","variante":"br","tokens_entrada":6087,"tokens_saida":94,"custo_tokens":0.001921,"fora_das_regras":false,"fim_resposta":"o INSS para quando precisar pedir a reforma.\nInformação geral, não substitui contabilista.","criado_em":"2026-09-06T03:30:24Z"}
ticket_guia_novo: {"id":"f52f1368-ddf0-4cce-83af-605f5db55e4c","tipo":"guia_novo","estado":"aberto","assunto":"Pergunta sem regra confirmada: quando é a inspeção do meu carro de 2021?","criado_em":"2026-09-06T03:30:22Z"}
```
`tokens_saida` caiu de 2044 (cortada, na ronda anterior) para 578 e 94: o orçamento de raciocínio de 512 deixou de comer a resposta. A roda continua a andar (3.8, 3.7 e 3.6 já esgotados hoje → 3.5-flash, depois flash-lite-latest).

**Observação (para o próximo passo, não bloqueia):** `contexto_ia.ts` → `responderComIA` ainda passa `maxTokens: 2048` explicitamente a `chamarGemini`, por isso o novo default de 4096 do `gemini.ts` **não** se aplica ao chat nem ao suporte — só ao `ler-extrato` (que passa 512). Com o `thinkingBudget: 512` chega (as duas respostas couberam com folga), mas se se quiser mesmo 4096 no chat é preciso remover ou subir esse `maxTokens: 2048` em `contexto_ia.ts`.
