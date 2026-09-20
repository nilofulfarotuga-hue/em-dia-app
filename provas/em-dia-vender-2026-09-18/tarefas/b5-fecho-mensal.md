# Tarefa B5 — Fecho de mês automático (dia 1): extrato da Google Play → bruto / comissão / líquido / IVA → pasta `fecho-mensal/em-dia/AAAA-MM/` com folha de rosto

Projeto «Em Dia» (Supabase `tgdmgtmknbwhcqoxtjbs`, Edge Functions em Deno em `supabase/functions/`, migrações em
`supabase/migrations/`). Lê primeiro: `supabase/functions/avisos-cron/index.ts` (padrão de cron + `x-cron-secret`),
`supabase/functions/_shared/segredos.ts` (`lerSegredo`), `supabase/functions/_shared/google_oauth.ts`
(`obterAccessTokenGoogle`), `supabase/functions/validar-compra-play/index.ts` (como se lê `play_service_account`),
`supabase/migrations/20260906_0004_vault_cron_admin.sql` (cron), `20260906_0007_bucket_comprovativos.sql` (bucket +
políticas), `20260918_0038_admin_assinaturas_erros.sql` (RPC só-admin).

## Como a Google entrega os números
Os relatórios financeiros da Play Console vivem num bucket do Google Cloud Storage cujo nome é
`pubsite_prod_rev_<id>` (o `<id>` lê-se na Play Console em «Transferir relatórios → Financeiros» — NÃO é o id da conta
de programador; fica no Vault como `play_relatorios_bucket`, ainda por pôr). Dentro há CSV mensais do tipo
`earnings/earnings_AAAAMM-<n>.zip` (relatório de ganhos: uma linha por transação, com colunas como
`Transaction Date`, `Transaction Type`, `Product Title`, `Buyer Country`, `Buyer Currency`, `Amount (Buyer Currency)`,
`Currency Conversion Rate`, `Merchant Currency`, `Amount (Merchant Currency)`) e `sales/salesreport_AAAAMM.zip`.
Não podes confirmar o formato exato agora (sem acesso), por isso o leitor tem de ser **tolerante**: lê o cabeçalho, procura
as colunas por nome (case-insensitive, com fallback), e se não reconhecer, guarda o ficheiro tal como veio e marca o fecho
como `estado = 'por_rever'` com o motivo. Nunca inventes números: o que não se lê fica `null`.
Regras de cálculo (escreve-as em comentário e no `resumo.json`):
- **bruto** = soma de `Amount (Merchant Currency)` das linhas `Transaction Type = 'Charge'` (cobranças ao cliente);
- **comissão** = soma (negativa) das linhas `Transaction Type = 'Google fee'` (a Google mostra a sua taxa como linha própria);
- **IVA** = soma das linhas `Transaction Type = 'Tax'` (na UE a Google cobra e entrega o IVA — fica registado à parte);
- **reembolsos** = linhas `Charge refund` / `Google fee refund` / `Tax refund` (somadas à parte);
- **líquido** = bruto + comissão + reembolsos (o que a Google paga ao programador; o IVA não entra porque a Google o entrega
  ela própria — escreve isto na folha de rosto).
Se o bucket ainda não existir/não estiver configurado (segredo em falta), o fecho corre na mesma e escreve a folha de rosto
com «Sem extrato da Google: <motivo>» e zeros marcados como «sem dados» — nunca falha em silêncio.

## O que fazer

### 1. Migração `supabase/migrations/20260920_0041_fecho_mensal.sql` (NÃO a apliques — só o ficheiro)
- Bucket privado `fecho-mensal` (`storage.buckets`, `public=false`, 20 MB, mimes csv/zip/json/markdown/pdf); políticas:
  só `service_role` escreve; lê quem `public.is_admin()`.
- Tabela `public.fechos_mensais (id bigserial pk, app text not null default 'em-dia', mes date not null, moeda text,
  bruto numeric, comissao numeric, iva numeric, reembolsos numeric, liquido numeric, transacoes int, assinaturas_ativas int,
  ficheiros jsonb not null default '[]', estado text not null check (estado in ('ok','sem_extrato','por_rever','erro')),
  motivo text, criado_em timestamptz default now(), unique (app, mes))` + RLS: admin lê; ninguém escreve por RLS
  (só service_role).
- RPC `public.admin_fechos_mensais(p_meses int default 12) returns setof jsonb` security definer + `is_admin()`,
  mais recente primeiro (mesmo padrão da 0038/0040).
- Cron `em-dia-fecho-mensal`: `'10 6 1 * *'` (dia 1 às 06:10 UTC) a chamar `…/functions/v1/fecho-mensal` com o mesmo
  padrão de headers de `em-dia-avisos-hora` (Authorization anon + `x-cron-secret` do Vault), body `{"origem":"pg_cron"}`.

### 2. Edge Function `supabase/functions/fecho-mensal/index.ts`
- Aceita POST com `x-cron-secret` (igual a `avisos-cron`) ou `Authorization` service_role; body opcional `{ "mes": "2026-08" }`
  (por defeito: o mês anterior ao atual, em Europe/Lisbon); `{ "app": "em-dia" }` por defeito (estrutura pronta para
  `"bora"` mas SÓ o `em-dia` corre — para `bora` devolve 400 «ainda não ligado»).
- Passos: (1) lê `play_service_account` e `play_relatorios_bucket` por `lerSegredo`; se faltar o bucket → estado
  `sem_extrato`; (2) token GCS (`https://www.googleapis.com/auth/devstorage.read_only`), lista
  `earnings/earnings_AAAAMM-*.zip` (GCS JSON API `o?prefix=`), descarrega, descomprime (Deno: `npm:fflate`), lê o CSV
  (parser simples com aspas); (3) calcula as somas acima; (4) conta `assinaturas` ativas no fim do mês e transações;
  (5) escreve no bucket `fecho-mensal`: `em-dia/AAAA-MM/extrato-google.csv` (o original), `resumo.json`,
  `folha-de-rosto.md` (PT-PT, para o Danilo ler em voz alta: mês, moeda, bruto, comissão, IVA, reembolsos, líquido,
  nº transações, assinaturas ativas, de onde vieram os números, o que ficou por ler); (6) upsert em `fechos_mensais`;
  (7) responde JSON com o resumo. Erros → estado `erro` + motivo na tabela e resposta 500 com o texto.
- Sem e-mails, sem Telegram, sem push. Só ficheiros e tabela.
- Números em `resumo.json` com 2 casas; na folha de rosto no formato português `1.234,56 €`.

### 3. Teste local
- `supabase/functions/fecho-mensal/fecho_test.ts` (Deno test) para as funções puras: parser de CSV (aspas e vírgulas
  dentro de aspas), soma por `Transaction Type` com um CSV de exemplo de 8 linhas (2 Charge, 2 Google fee, 2 Tax,
  1 Charge refund, 1 Google fee refund) — confere bruto/comissão/iva/reembolsos/líquido à mão nos comentários;
  formatação `1.234,56 €`. Corre `deno test supabase/functions/fecho-mensal/` e cola a saída literal.
  (Se `deno` não estiver instalado, escreve os testes na mesma e diz literalmente que não os correste e porquê.)
- `deno check supabase/functions/fecho-mensal/index.ts` se houver deno.

### 4. Estrutura para o Bora (só pastas e nota)
Cria `fecho-mensal/README.md` na raiz do repo a explicar a estrutura `fecho-mensal/<app>/AAAA-MM/` no bucket, que o
`em-dia` corre e o `bora` fica preparado (outro projeto Supabase, outra conta Play) — sem código do Bora.

## Critério de feito
Migração escrita (não aplicada); função + teste; README. Nada de e-mails. Cola a saída literal dos testes e a lista de
ficheiros.

## Proibido
Aplicar migrações, deploy, git, tocar em `validar-compra-play`, preços, ou em qualquer coisa do Bora. Não inventes o
formato exato dos CSV como certeza — o leitor tolera e marca `por_rever`.
