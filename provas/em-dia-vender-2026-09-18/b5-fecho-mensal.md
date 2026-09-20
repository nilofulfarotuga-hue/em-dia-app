# B5 — Fecho de mês automático (dia 1) — 2026-09-21

> Missão `em-dia-vender-2026-09-18`, Bloco 5. O que ficou NO AR e provado; o que falta é um segredo que só se lê na consola.

## Quem fez o quê
- **ChatGPT Plus (gpt-5.5, opencode)**, `delegar.ps1 chatgpt … -Id b5-fecho-mensal` (440 s, anti-mentira PASSOU):
  `supabase/migrations/20260920_0041_fecho_mensal.sql`, `supabase/functions/fecho-mensal/{index.ts,_core.ts,fecho_test.ts}`,
  `fecho-mensal/README.md`. GLM continua sem quota semanal.
- **Claude Code**: reviu (auth por `x-cron-secret` ou service role; sem e-mails; nunca inventa números — `null` + estado
  `sem_extrato`/`por_rever`), correu os testes Deno, aplicou a migração, fez o deploy (v1) e provou a função em produção.

## O que faz
Dia 1 às 06:10 UTC o `pg_cron` (`em-dia-fecho-mensal`) chama a Edge Function `fecho-mensal`. Ela lê o mês anterior
(Europe/Lisbon), vai ao bucket dos relatórios financeiros da Play (`earnings/earnings_AAAAMM-*.zip`, via conta de serviço,
scope GCS read-only), calcula **bruto** (Charge), **comissão** (Google fee), **IVA** (Tax, à parte — a Google entrega-o),
**reembolsos** e **líquido** = bruto + comissão + reembolsos, conta as assinaturas ativas no fim do mês, e grava no bucket
privado `fecho-mensal` (só admin lê): `em-dia/AAAA-MM/extrato-google.csv`, `resumo.json`, `folha-de-rosto.md` (em
português, para ler em voz alta), e uma linha em `fechos_mensais` (RPC `admin_fechos_mensais` só-admin). Sem extrato →
escreve na mesma a folha com «Sem extrato da Google: <motivo>». Estrutura `fecho-mensal/<app>/` pronta para o `bora`
(devolve 400 «ainda não ligado»).

## Provas literais
```
deno test supabase/functions/fecho-mensal/  → ok | 3 passed | 0 failed (14ms)
apply_migration 20260920_0041_fecho_mensal   → {"success":true}
deploy_edge_function fecho-mensal            → status ACTIVE, version 1, verify_jwt true
net.http_post (mesmos headers do cron, body {"mes":"2026-08"}) → 200
  {"app":"em-dia","mes":"2026-08","bruto":null,…,"assinaturas_ativas":0,
   "ficheiros":["em-dia/2026-08/resumo.json","em-dia/2026-08/folha-de-rosto.md"],
   "estado":"sem_extrato","motivo":"Sem extrato da Google: segredo play_relatorios_bucket em falta."}
fechos_mensais: em-dia | 2026-08-01 | sem_extrato
storage.objects (bucket fecho-mensal): em-dia/2026-08/resumo.json 830 B · em-dia/2026-08/folha-de-rosto.md 946 B
cron.job em-dia-fecho-mensal '10 6 1 * *' active=true
x-cron-secret errado → 401 {"erro":"nao_autorizado"}
```

## O que falta (não é clique do Danilo — é da próxima sessão com Chrome)
1. Ler na Play Console «Transferir relatórios → Financeiros» o id do bucket (`pubsite_prod_rev_<id>`; tentado o id da conta
   de programador → 404, não é esse) e guardá-lo no Vault como `play_relatorios_bucket`.
2. Pôr `play_service_account` (o JSON de `C:\BoraLocal\_segredos\em-dia\play-service-account.json`) no Vault ou como
   segredo da função — hoje `validar-compra-play` lê-o por env; a função lê primeiro a env.
3. Dar à conta de serviço `em-dia-play@em-dia-507723.iam.gserviceaccount.com` a permissão «Ver dados financeiros» na
   Play Console (Utilizadores e permissões).
Enquanto os relatórios não existirem (só há relatórios depois de vendas), o fecho escreve «sem extrato» — está certo.
