# Prova — os avisos das contas de casa (2026-09-06, 17h de Lisboa)

Ponto 12 do Bloco 3: *"débito direto avisa 1 dia antes; referência avisa 3 dias
antes e no dia; obrigações do Estado 5 dias antes e no dia. Nunca mais de um
aviso por item por dia."*

## Porque é que os prazos são diferentes

Não é capricho. Uma conta em **débito direto** não pede trabalho nenhum: só é
preciso ter o dinheiro na conta. Avisar cinco dias antes assustava sem servir
para nada — avisa-se na véspera. Uma conta com **referência** obriga a ir pagar,
e um aviso só no próprio dia apanha quem já não tem tempo — avisa-se três dias
antes **e** no dia.

Os dois números vivem em `regras_legais`, não no código:

```
aviso_debito_direto_dias   1
aviso_referencia_dias      3
ipo_avisos_dias            [30, 7]
iva_isencao_aviso          12000
push_hora_lisboa           9
```

## O que foi montado para a prova

Quatro contas do utilizador `500f99a2…` (boraappbora@gmail.com), com dias de
propósito diferentes:

| Conta | Meio | Vence | O que se espera |
|---|---|---|---|
| [PROVA] Luz de casa | débito direto | 07/09 (amanhã) | `conta_debito_amanha` |
| [PROVA] Água da Guarda | referência | 09/09 (3 dias) | `conta_referencia_3_dias` |
| [PROVA] Internet | referência | 06/09 (hoje) | `conta_referencia_hoje` |
| [PROVA] Ginásio | MB WAY | 02/09 (passou) | `conta_passou` |

## A chamada, feita pelo cron a sério (pg_net + segredo do Vault)

```
POST /functions/v1/avisos-cron   {"forcar": true, "origem": "prova_contas_de_casa"}
200
{"hora_lisboa":17,"data_lisboa":"2026-09-06","forcado":true,"autenticado":"cron",
 "fcm_configurado":false,"utilizadores":3,"eventos_criados":4,"enviados":0,
 "sem_fcm":4,"sem_token":0,"limite_plano":0,"erros":0,"passadas_marcadas":0,
 "detalhes":[{"user_id":"500f99a2-…","eventos":4,
   "tipos":["conta_passou","conta_referencia_hoje","conta_debito_amanha","conta_referencia_3_dias"],
   "resultado":"sem_fcm","tokens":0}]}
```

**Quatro contas, quatro avisos, cada um do tipo certo.** E o texto que sai:

```
Conta por pagar       Passou o dia 02/09/2026 e [PROVA] Ginasio continua por pagar.
                      Vê se já pagaste — se sim, marca aqui.
É hoje                É hoje: [PROVA] Internet, 29,99 €. Toca aqui e copia a
                      referência para pagares no multibanco.
Amanhã sai da conta   Amanhã sai 42,30 € da tua conta: [PROVA] Luz de casa.
                      Não tens de fazer nada, só de ter o dinheiro lá.
Faltam 3 dias         Faltam 3 dias para pagares [PROVA] Agua da Guarda (18,75 €),
                      até 09/09/2026. A referência está aqui dentro.
```

## Nunca mais de um por item por dia

Segunda chamada, seguida, sem mudar nada:

```
200 {"eventos_criados":0,"detalhes":[]}
```

Zero. A trava é da base de dados, não do código: a migração 0022 troca a unique
antiga por `eventos_push_um_por_dia on (user_id, tipo, dia, obrigacao_id,
pagamento_id) nulls not distinct`. Sem o `pagamento_id` lá dentro, as quatro
contas do mesmo utilizador colidiam umas com as outras (todas têm
`obrigacao_id` nulo) e só passava uma.

## Um erro apanhado a meio, que vale a pena escrever

O código lia `aviso_debito_direto_dias` e `aviso_referencia_dias` das regras,
mas a consulta só pedia três chaves à tabela. As duas novas nunca chegavam, e os
valores por omissão do código (1 e 3) tapavam o buraco em silêncio — a app
parecia certa e o painel do Danilo não mandava nada. Corrigido antes do deploy:
as cinco chaves vão na mesma consulta.

## Limpeza

As quatro contas de prova e os quatro eventos foram apagados a seguir. Estado
final da base: `saidas 0 · saidas_pagamentos 0 · eventos_push 0`.

## O que fica por fazer, e é honesto dizê-lo

`fcm_configurado: false`. A service account do Firebase ainda não está no Vault
(`fcm_service_account`), por isso os avisos ficam **registados** mas não saem
para o telemóvel — o resultado gravado é `sem_fcm`, não um falso "enviado".
Fecha-se no Bloco 6, com a app já na Play.

## Onde ficou

- `supabase/functions/avisos-cron/index.ts` (versão 5, ACTIVE)
- `supabase/functions/_shared/mensagens.ts` (quatro textos novos, PT e BR)
- `supabase/migrations/20260906_0022_avisos_das_contas.sql`
