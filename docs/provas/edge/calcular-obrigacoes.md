# Prova — Edge Function `calcular-obrigacoes`

Data/hora: 2026-09-06 00:35–00:38 (Lisboa) = 2026-09-05T23:35–23:37Z
Projeto Supabase: `tgdmgtmknbwhcqoxtjbs` · função `calcular-obrigacoes` v1 (id `7937f9a6-bc94-4262-a338-b10913a7e884`), `verify_jwt: true`, estado `ACTIVE`.

Ficheiros:
- `supabase/functions/_shared/regras.ts` — porta TypeScript (espelho exato) de `lib/regras/{datas,formatos,seguranca_social,irs,carro,obrigacoes,regras_legais}.dart`. Nenhuma constante legal: tudo vem de `regras_legais` / `irs_escaloes` / `feriados`; regra em falta lança erro (a função responde 500 `regra_em_falta`).
- `supabase/functions/_shared/regras_test.ts` — 33 testes Deno espelhando `test/unit/regras_test.dart` (C10–C30, C33, C36–C39, C41–C47).
- `supabase/functions/calcular-obrigacoes/index.ts` — a função.

## 1. Testes Deno (oráculo)

`deno` não está instalado na máquina (`deno: command not found`); correu-se com `npx -y deno@2` (deno 2.9.6).

Comando: `npx -y deno@2 test supabase/functions/_shared/regras_test.ts`

Saída literal (resumo; cada linha `... ok`):
```
running 33 tests from ./supabase/functions/_shared/regras_test.ts
C10 1.000 €/mês serviços → 149,80 €/mês ... ok
C11 ajuste −25% → 112,35 €; +25% → 187,25 € ... ok
C12 ajuste fora do limite é tapado a ±25% ... ok
C13 100 €/mês → mínimo de 20 € ... ok
C14 vendas 1.000 €/mês → base 20% → 42,80 € ... ok
C15 20.000 €/mês → teto 12×IAS (6.445,56 €) → 1.379,35 € ... ok
C16 isenção: abriu 15/03/2026 → paga desde 01/03/2027; 1.ª declaração abril 2027 ... ok
C17 isenção: abriu 31/12/2026 → paga desde 01/12/2027; 1.ª declaração janeiro 2028 ... ok
C18 isenção: abriu 29/02/2028 (bissexto) → paga desde 01/02/2029 ... ok
C19 prazos: declaração até ao último dia do mês; pagamento até dia 20 ... ok
C20 12.000 € serviços 2025 → abaixo do mínimo de existência → 0 ... ok
C21 24.000 € serviços 2025 → coletável 18.000 → 2.941,37 €; 245,11 €/mês; PPC 637,30 € ... ok
C22 40.000 € serviços 2025 → 6.463,95 €; tem de justificar despesas ... ok
C23 40.000 € vendas 2025 → coletável 6.000 → 0 ... ok
C24 100.000 € serviços 2025 → 25.355,56 € ... ok
C25 2026: escalões POR CONFIRMAR ficam marcados; 24.000 € → 2.861,42 € ... ok
C26 datas: PPC 20 jul/set/dez; entrega até 30 jun; e-fatura até 25 fev ... ok
C27 IUC: matrícula de fevereiro → até 28/02 (29 em bissexto) ... ok
C28 IPO ligeiro 2021: 4/6/8 anos e depois anual ... ok
C29 IPO carro de 2015 com inspeção feita em junho de 2026 → junho de 2027 ... ok
C30 IPO TVDE: anual (POR CONFIRMAR) ... ok
C33 IUC estimado: 1199 cc, 120 g CO2 (WLTP), 2021 → 111,48 €; elétrico → 0 ... ok
C36 véspera útil: domingo, sábado, feriado ... ok
C37 15 dias úteis a partir de 01/12/2026 (feriado + 8/12) → 23/12/2026 ... ok
C38 somar meses prende o dia ao fim do mês ... ok
C39 moeda 1.234,56 € ... ok
C41 hora de Lisboa: verão +1, inverno +0 ... ok
C42 TVDE aberto a 15/03/2026, isento: fim da isenção, pagamentos desde março 2027, sem IVA ... ok
C43 regime normal de IVA: declaração dia 20 e pagamento dia 25 do 2.º mês após o trimestre ... ok
C44 carro de fevereiro de 2021 com seguro em maio: IUC 28/02, IPO 28/02/2027, seguro roda para 2027 ... ok
C45 sem atividade e sem carro → nada ... ok
C46 número em falta é erro, nunca um valor inventado ... ok
C47 escalões: 2027 não existe → usa o ano mais recente (2026) ... ok

ok | 33 passed | 0 failed (35ms)
```

Nota: a fixture dos testes (`regrasDeTeste2026()`) é um espelho do seed `20260905_0003_seed.sql`, tal como `RegrasLegais.padrao2026()` no Dart — só existe no ficheiro de teste, não no código de produção.

## 2. Preparação do utilizador de teste (SQL, execute_sql)

Utilizador `teste@emdia.pt` já existia em `auth.users` (id `a2194877-dcbc-49fd-9197-e826948eec16`).

```sql
update profiles set tipo_atividade='tvde', data_abertura='2026-03-15', regime_iva='isento_53',
  tipo_rendimento='servicos', rendimento_mensal_estimado=1500, ajuste_ss_pct=0, imigrante=false, residencia_renova_em=null
  where user_id = <id>;
delete from obrigacoes where user_id = <id>;   -- limpar para a prova
delete from carros where user_id = <id>;
insert into carros (user_id, matricula, data_matricula, combustivel, cilindrada_cc, co2_g_km, seguro_renova_em, uso_tvde, ativo)
  values (<id>, 'AA-11-BB', '2021-02-28', 'gasolina', 1199, 120, '2026-05-15', false, true);
```
Resultado literal:
```
[{"user_id":"a2194877-dcbc-49fd-9197-e826948eec16","obrigacoes_apagadas":2,"carros_apagados":0,
  "carro_id":"682bb3e7-c855-497f-a98a-e31b7e775c56","matricula":"AA-11-BB"}]
```

## 3. 1.ª chamada (Python urllib; curl está bloqueado)

Login: `POST /auth/v1/token?grant_type=password` → HTTP 200, user `a2194877-…`.
Chamada: `POST /functions/v1/calcular-obrigacoes`, headers `apikey: <anon>`, `Authorization: Bearer <jwt do utilizador>`, corpo `{"hoje":"2026-09-06"}` (o campo é opcional; hoje em Lisboa era mesmo 2026-09-06 — ver §6).

Resposta literal (HTTP 200; `itens` reproduzidos em formato compacto):
```
{"geradas": 17, "novas": 17, "atualizadas": 0, "apagadas": 2, "hoje": "2026-09-06"}
  2026-09-20  aviso=2026-09-18  irs_pagamento_conta    valor=412.26  chave=irs_pagamento_conta|2026-09-20
  2026-12-20  aviso=2026-12-18  irs_pagamento_conta    valor=412.26  chave=irs_pagamento_conta|2026-12-20
  2027-02-25  aviso=2027-02-25  efatura_validar        valor=None    chave=efatura_validar|2027-02-25
  2027-02-28  aviso=2027-02-26  iuc                    valor=111.48  chave=iuc|2027-02-28|682bb3e7-c855-497f-a98a-e31b7e775c56
  2027-02-28  aviso=2027-02-26  ipo                    valor=None    chave=ipo|2027-02-28|682bb3e7-c855-497f-a98a-e31b7e775c56
  2027-03-01  aviso=2027-01-29  fim_isencao_ss         valor=224.7   chave=fim_isencao_ss|2027-03-01
  2027-03-20  aviso=2027-03-19  ss_pagamento           valor=224.7   chave=ss_pagamento|2027-03-20
  2027-04-20  aviso=2027-04-20  ss_pagamento           valor=224.7   chave=ss_pagamento|2027-04-20
  2027-04-30  aviso=2027-04-30  ss_declaracao          valor=None    chave=ss_declaracao|2027-04-30
  2027-05-15  aviso=2027-05-14  seguro                 valor=None    chave=seguro|2027-05-15|682bb3e7-c855-497f-a98a-e31b7e775c56
  2027-05-20  aviso=2027-05-20  ss_pagamento           valor=224.7   chave=ss_pagamento|2027-05-20
  2027-06-20  aviso=2027-06-18  ss_pagamento           valor=224.7   chave=ss_pagamento|2027-06-20
  2027-06-30  aviso=2027-06-30  irs_entrega            valor=None    chave=irs_entrega|2027-06-30
  2027-07-20  aviso=2027-07-20  ss_pagamento           valor=224.7   chave=ss_pagamento|2027-07-20
  2027-07-20  aviso=2027-07-20  irs_pagamento_conta    valor=412.26  chave=irs_pagamento_conta|2027-07-20
  2027-07-31  aviso=2027-07-30  ss_declaracao          valor=None    chave=ss_declaracao|2027-07-31
  2027-08-20  aviso=2027-08-20  ss_pagamento           valor=224.7   chave=ss_pagamento|2027-08-20
```
Sem JWT: HTTP 401 `{"code": "UNAUTHORIZED_NO_AUTH_HEADER", "message": "Missing authorization header"}` (o gateway com `verify_jwt` trava antes da função; a função por dentro também devolve 401 `nao_autenticado` se o JWT não resolver um utilizador).

Observação honesta: a resposta diz `apagadas: 2`. Eu tinha limpo `obrigacoes` do utilizador por SQL (§2, `obrigacoes_apagadas: 2`) uns segundos antes; entre esse SQL e a chamada apareceram 2 linhas pendentes novas para este utilizador (outra sessão/agente a usar o mesmo utilizador de teste em paralelo — não foram criadas por mim). A função apagou-as por serem pendentes, não-manuais e fora do conjunto gerado, que é o comportamento pedido. Não sei o conteúdo delas.

Comparação com o oráculo Dart (C42 + C44): fim_isencao_ss 2027-03-01 / 224,70 / aviso 2027-01-29 ✔; ss_pagamento 1.º = 2027-03-20, aviso 2027-03-19, 224,70, 6 pagamentos (mar–ago 2027) ✔; ss_declaracao 2027-04-30 e 2027-07-31 ✔; nenhum `iva_*` ✔; irs_entrega 2027-06-30 ✔; efatura_validar 2027-02-25 ✔; iuc 2027-02-28 / 111,48 / aviso 2027-02-26 ✔; ipo 2027-02-28 ✔; seguro 2027-05-15 ✔; chaves todas distintas ✔; ordenado por data ✔.
(Os `irs_pagamento_conta` de 412,26 € não são afirmados no C42, mas batem com a regra: 18.000 × 0,75 = 13.500 coletável → escalão 2026 (por confirmar) 0,212 − 959,28 = 1.902,72 → × 65% ÷ 3 = 412,26.)

## 4. SELECT de confirmação (depois da 1.ª chamada)

```sql
select tipo, data_limite, aviso_em, valor_estimado, estado, chave_unica, carro_id is not null as tem_carro
from obrigacoes where user_id = <id> and chave_unica in (...7 chaves...) order by data_limite;
```
Resultado literal:
```
[{"tipo":"iuc","data_limite":"2027-02-28","aviso_em":"2027-02-26","valor_estimado":"111.48","estado":"pendente","chave_unica":"iuc|2027-02-28|682bb3e7-c855-497f-a98a-e31b7e775c56","tem_carro":true},
 {"tipo":"ipo","data_limite":"2027-02-28","aviso_em":"2027-02-26","valor_estimado":null,"estado":"pendente","chave_unica":"ipo|2027-02-28|682bb3e7-c855-497f-a98a-e31b7e775c56","tem_carro":true},
 {"tipo":"fim_isencao_ss","data_limite":"2027-03-01","aviso_em":"2027-01-29","valor_estimado":"224.70","estado":"pendente","chave_unica":"fim_isencao_ss|2027-03-01","tem_carro":false},
 {"tipo":"ss_pagamento","data_limite":"2027-03-20","aviso_em":"2027-03-19","valor_estimado":"224.70","estado":"pendente","chave_unica":"ss_pagamento|2027-03-20","tem_carro":false},
 {"tipo":"ss_declaracao","data_limite":"2027-04-30","aviso_em":"2027-04-30","valor_estimado":null,"estado":"pendente","chave_unica":"ss_declaracao|2027-04-30","tem_carro":false},
 {"tipo":"seguro","data_limite":"2027-05-15","aviso_em":"2027-05-14","valor_estimado":null,"estado":"pendente","chave_unica":"seguro|2027-05-15|682bb3e7-c855-497f-a98a-e31b7e775c56","tem_carro":true},
 {"tipo":"irs_entrega","data_limite":"2027-06-30","aviso_em":"2027-06-30","valor_estimado":null,"estado":"pendente","chave_unica":"irs_entrega|2027-06-30","tem_carro":false}]
```

## 5. Idempotência e preservação de estado (2.ª chamada)

Antes da 2.ª chamada, por SQL:
```sql
update obrigacoes set estado='pago', pago_em=now(), comprovativo_url='https://exemplo.test/comprovativo-teste.jpg'
  where user_id=<id> and chave_unica='ss_pagamento|2027-03-20';
-- → [{"total_antes_2a_chamada":17,"marcada_paga":"ss_pagamento|2027-03-20","estado_marcado":"pago"}]
insert into obrigacoes (user_id,tipo,descricao,data_limite,aviso_em,valor_estimado,origem_regra,como_pagar,chave_unica)
  values (<id>,'multa','Multa de estacionamento (teste manual)','2026-10-01','2026-10-01',60,'multa_pagamento_voluntario_dias_uteis','Paga na ANSR','multa|2026-10-01|teste-manual');
-- → [{"tipo":"multa","chave_unica":"multa|2026-10-01|teste-manual","estado":"pendente"}]
```

2.ª chamada (mesmo corpo `{"hoje":"2026-09-06"}`) — resposta literal (HTTP 200):
```
{"geradas": 17, "novas": 0, "atualizadas": 17, "apagadas": 0, "hoje": "2026-09-06"}
```

SELECT de confirmação — resultado literal:
```
[{"total_depois_2a_chamada":18,"geradas_na_tabela":17,"chaves_distintas":18,
  "linha_paga":{"estado":"pago","pago_em":"2026-09-05T23:36:24.611822+00:00","comprovativo_url":"https://exemplo.test/comprovativo-teste.jpg","valor":224.7,"atualizado_em":"2026-09-05T23:36:50.675966+00:00"},
  "multa_manual":{"tipo":"multa","estado":"pendente"}}]
```
Leitura: 17 geradas + 1 multa manual = 18 (não duplicou: 18 chaves distintas em 18 linhas); a linha marcada `pago` continua `pago`, com `pago_em` e `comprovativo_url` intactos, mas foi tocada pelo upsert (`atualizado_em` 23:36:50 > `pago_em` 23:36:24 — só os campos permitidos); a `multa` manual não foi apagada.

Contagem por tipo (SQL):
```
irs_pagamento_conta 3 (2026-09-20 … 2027-07-20) · multa 1 · efatura_validar 1 (2027-02-25) · iuc 1 (2027-02-28) · ipo 1 (2027-02-28)
fim_isencao_ss 1 (2027-03-01) · ss_pagamento 6 (2027-03-20 … 2027-08-20) · ss_declaracao 2 (2027-04-30, 2027-07-31)
seguro 1 (2027-05-15) · irs_entrega 1 (2027-06-30)
```

## 6. Corpo vazio (hoje = Lisboa)

3.ª chamada com corpo `{}` às 23:37:24Z (= 00:37 de 2026-09-06 em Lisboa, horário de verão): resposta `{"geradas": 17, "novas": 0, "atualizadas": 17, "apagadas": 0, "hoje": "2026-09-06"}` — o `hojeLisboa()` deu o dia certo (em UTC ainda era dia 5).

## 7. O que falta / notas

- Nada bloqueado: esta função não usa segredos do Vault (só as três variáveis injetadas pelo Supabase).
- `profiles` não tem colunas `usa_software_faturacao` nem `tvde_certificado_validade` (existem só no perfil Dart); a função lê-as se existirem e assume `false`/`null` se não — logo `recibos_comunicar` e `tvde_certificado` não se geram hoje no servidor. Se a app precisar delas, é uma migration nova (não a criei: não era estritamente necessária).
- `query_logs` (function_edge_logs) devolveu vazio para as chamadas — os logs unificados ainda não tinham indexado; a prova de execução é o HTTP 200 + o SELECT com as linhas gravadas.
- Utilizador de teste ficou com o perfil C42/C44 e 18 linhas em `obrigacoes` (17 geradas + 1 multa manual); a linha `ss_pagamento|2027-03-20` ficou como `pago` de teste.

## Verificação independente

Verificador com contexto limpo, 2026-09-05T23:44–23:52Z (= 00:44–00:52 de 2026-09-06 em Lisboa). Tudo o que está abaixo é saída literal; o que não está aqui não foi verificado.

### V1. Testes Deno corridos por mim
`npx -y deno@2 test supabase/functions/_shared/regras_test.ts` (deno 2.9.6; `deno` local não existe) →
```
ok | 33 passed | 0 failed (36ms)
```

### V2. Deploy
`list_edge_functions` → `calcular-obrigacoes` id `7937f9a6-bc94-4262-a338-b10913a7e884`, `status: ACTIVE`, `version: 1`, `verify_jwt: true`. `get_edge_function` devolve `calcular-obrigacoes/index.ts` + `_shared/regras.ts`; comparei o conteúdo devolvido com os ficheiros locais (sha256 locais: regras.ts `8f615e27…4a27cb`, index.ts `f6fd80a4…537d29`) — texto igual.

### V3. Chamadas feitas por mim (Python urllib, JWT novo do `teste@emdia.pt`, user `a2194877-dcbc-49fd-9197-e826948eec16`)
```
sem JWT        -> 401 {"code":"UNAUTHORIZED_NO_AUTH_HEADER","message":"Missing authorization header"}
JWT lixo       -> 401 {"code":"UNAUTHORIZED_INVALID_JWT_FORMAT","message":"Invalid JWT"}
GET            -> 405 {"erro":"metodo_nao_permitido","mensagem":"Usa POST."}
corpo vazio    -> 200 {'geradas': 17, 'novas': 0, 'atualizadas': 17, 'apagadas': 0, 'hoje': '2026-09-06'}   (23:44Z = 00:44 Lisboa: hojeLisboa certo)
corpo não-JSON -> 200 {'geradas': 17, 'novas': 0, 'atualizadas': 17, 'apagadas': 0, 'hoje': '2026-09-06'}
hoje='2026-13-45' -> 200 {'geradas': 24, 'novas': 9, 'atualizadas': 15, 'apagadas': 2, 'hoje': '2027-02-14'}   <-- PROBLEMA (ver V7)
hoje='abc'        -> 200 {'geradas': 17, 'novas': 2, 'atualizadas': 15, 'apagadas': 9, 'hoje': '2026-09-06'}
hoje='2026-02-30' -> 200 {'geradas': 9,  'novas': 3, 'atualizadas': 6,  'apagadas': 10, 'hoje': '2026-03-02'}  <-- PROBLEMA (ver V7)
hoje=12345        -> 200 {'geradas': 17, 'novas': 10, 'atualizadas': 7, 'apagadas': 3, 'hoje': '2026-09-06'}
hoje=null         -> 200 {'geradas': 17, 'novas': 0, 'atualizadas': 17, 'apagadas': 0, 'hoje': '2026-09-06'}
normal (hoje=2026-09-06) -> 200 {'geradas': 17, 'novas': 0, 'atualizadas': 17, 'apagadas': 0}
repetida                 -> 200 {'geradas': 17, 'novas': 0, 'atualizadas': 17, 'apagadas': 0}   (idempotente)
```
Itens da chamada normal (data_limite, aviso_em, tipo, valor, chave) — iguais aos 17 da prova do autor; os que o oráculo Dart afirma (C42 + C44), lidos por mim em `test/unit/regras_test.dart`:
```
2027-02-28 2027-02-26 iuc             111.48  iuc|2027-02-28|682bb3e7-…      ✔ C44 (111,48; aviso 26/02 porque 28/02/2027 é domingo)
2027-02-28 2027-02-26 ipo             None    ipo|2027-02-28|682bb3e7-…      ✔ C44
2027-03-01 2027-01-29 fim_isencao_ss  224.7   fim_isencao_ss|2027-03-01      ✔ C42 (224,70; aviso 29/01)
2027-03-20 2027-03-19 ss_pagamento    224.7   ss_pagamento|2027-03-20        ✔ C42 (1.º de 6, mar–ago: contei 6)
2027-04-30 / 2027-07-31 ss_declaracao                                        ✔ C42
2027-05-15 2027-05-14 seguro          None    seguro|2027-05-15|682bb3e7-…   ✔ C44
2027-06-30 2027-06-30 irs_entrega                                            ✔ C42
2027-02-25 2027-02-25 efatura_validar                                        ✔ C42
nenhum iva_*                                                                 ✔ C42
```

### V4. Os números vêm MESMO da tabela (mutação temporária, revertida)
```sql
update regras_legais set valor_num = 21.5 where chave='ss_taxa' and valor_num = 21.4 returning chave, valor_num;
-- [{"chave":"ss_taxa","valor_num":"21.5"}]
```
Chamada (hoje=2026-09-06) → `fim_isencao_ss 225.75`, `ss_pagamento 225.75` ×6 (1.500×3/3×70% = 1.050 × 21,5% = 225,75 ✔).
```sql
update regras_legais set valor_num = 21.4 where chave='ss_taxa' and valor_num = 21.5 returning chave, valor_num;
-- [{"chave":"ss_taxa","valor_num":"21.4"}]
```
Chamada seguinte → `224.7` outra vez em todas. SELECT final: `ss_taxa_agora = 21.4`.

### V5. C43 (regime normal de IVA) na função deployada — o autor só o tinha corrido em Deno local
Perfil trocado por SQL para freelancer / 2024-01-10 / normal / 3000 → chamada (hoje=2026-09-06):
```
200 {'geradas': 32, 'novas': 16, 'atualizadas': 16, 'apagadas': 1}
iva_declaracao: 2026-11-20, 2027-02-20 (aviso 2027-02-19), 2027-05-20, 2027-08-20   ✔ C43
iva_pagamento : 2026-11-25, 2027-02-25, 2027-05-25, 2027-08-25                       ✔ C43
```
SELECT: `{"total":33,"ss_pagamento":12,"ss_declaracao":4,"iva":8,"fim_isencao":0,"pagos":1,"multas":1}` ✔ C43 (12 pagamentos, 4 declarações, sem fim_isencao; a linha paga e a multa sobreviveram).
Perfil reposto (tvde / 2026-03-15 / isento_53 / 1500) e nova chamada → `{'geradas': 17, 'novas': 1, 'atualizadas': 16, 'apagadas': 16}`.

### V6. Estado final (SELECT literal)
```
estado_final: {"total":18,"chaves_distintas":18,"pendentes":17,"pagos":1,"multas":1,"iva":0}
linha_paga  : {"estado":"pago","pago_em":"2026-09-05T23:36:24.611822+00:00","comprovativo_url":"https://exemplo.test/comprovativo-teste.jpg","valor":224.7}
perfil_agora: {"tipo":"tvde","abertura":"2026-03-15","iva":"isento_53","rend":1500}
```
Depois de ~12 chamadas minhas (incluindo as com `hoje` inválido e a troca de perfil), a linha marcada `pago` por SQL nunca foi tocada nem apagada, e a multa manual também não.

### V7. Segredos e constantes
- `grep -rnE "AIza|private_key|sk_|eyJ" supabase/functions docs/provas` → só nomes de campo `private_key` em `fcm.ts`/`google_oauth.ts` e citações na prova de `validar-compra-play` (chave falsa `AAAA`). Nenhum token real.
- `grep -nE "21\.4|15000|537\.13|0\.75" supabase/functions -r` → só em `_shared/regras_test.ts` (fixture espelho do seed). Em `regras.ts` os únicos literais são `dia(2007, 6, 30)` (corte da categoria B do IUC, igual a `lib/regras/carro.dart:132`), `2026` como ano por omissão de uma regra sem `ano` (igual a `regras_legais.dart:42`) e `coef = 1.0` inicial. Nenhum valor legal cravado.

### Problemas encontrados
1. **`hoje` não é validado** (`index.ts` passo 2): a regex `^\d{4}-\d{2}-\d{2}` aceita `2026-13-45` e `2026-02-30`, e `lerDia` → `Date.UTC` faz overflow silencioso (→ `2027-02-14` e `2026-03-02`). Qualquer utilizador autenticado (ou um bug na app) consegue regenerar a sua lista para outra janela, o que **apaga as pendentes** da janela real (`apagadas: 2` e `apagadas: 10` acima) e cria pendentes com datas passadas/futuras erradas. O dano é reversível (nova chamada sem `hoje` repõe; as pagas nunca se tocam), mas é um "resultado errado" para valor fora do domínio. Reproduzir: `POST /functions/v1/calcular-obrigacoes` com JWT e corpo `{"hoje":"2026-13-45"}` → `"hoje":"2027-02-14"`. Correção pequena: rejeitar quando `dataIso(lerDia(x)) !== x` (400 `hoje_invalido`), e/ou limitar o override a QA (ex.: só com `x-cron-secret` válido ou nunca em produção).
2. **`recibos_comunicar` e `tvde_certificado` nunca se geram no servidor** porque `profiles` não tem `usa_software_faturacao` nem `tvde_certificado_validade` (confirmado: `grep` no schema não encontra as colunas). O Dart gera-as; o servidor não → o "espelho exato" só é exato para os campos que existem na tabela. O autor declarou-o honestamente; fica a faltar a migration (ou a decisão de que não é preciso).
