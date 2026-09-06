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
