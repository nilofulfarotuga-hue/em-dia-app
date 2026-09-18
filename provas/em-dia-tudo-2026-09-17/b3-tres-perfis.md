# BLOCO 3 — três perfis: recibos verdes, contrato, empresa · 2026-09-18

Linha no `e2e_log`: **2032** (`b3-tres-perfis`). Commit `2acb64f`.

## 1. As regras, todas com fonte (docs/REGRAS-PT-2026.md)
Verificadas online a 18/09/2026 e guardadas em `regras_legais` com `fonte_url` e `verificado_em` (migração 0036, SELECT de controlo: `regras_novas: 9, escaloes_2026_oficiais: 9, guias_novos: 8, cron: em-dia-pasta-contabilista-mes 0 6 1 * *`):
- **AT, Resumo anual — obrigações de pagamento 2026** (`Quadro_res_Pag_2026.aspx`): IRS PPC 20 jul / 21 set / 21 dez; IRC PPC 31 jul / 30 set / 15 dez; nota a) dia útil seguinte.
- **AT, Resumo anual — obrigações declarativas 2026** (`Quadro_res_Decl_2026.aspx`): DMR dia 10 (12 jan, 11 mai, 11 jun, 31 ago, 12 out); SAF-T dia 5 (9 jan, 8 abr, 8 mai, 6 jul, 31 ago, 7 set, 6 out, 7 dez); IVA mensal dia 20; IVA trimestral fev/mai/set/nov; Modelo 22 «30 f)» junho (prorrogação 2026; lei: 31 maio); IES 15 jul; mod. 3 30 jun; e-fatura fev.
- **CIRS art. 68.º** (Lei 73-A/2025): escalões 2026 — a tabela tinha 12 588 / 23 088 / 46 567 (a 1 € da lei) e `por_confirmar`; agora 12 587 / 23 089 / 46 566, parcelas recalculadas, `oficial`. Efeito: 24 000 € de serviços → 2 861,47 € (era 2 861,42); testes C25 e goldens (cofre, recibos) atualizados com a conta à mão.
- **CIRS art. 12.º-B** (IRS Jovem), **art. 25.º** (dedução 8,54 × IAS), **78.º-A a F** (deduções) — páginas do Portal das Finanças.
- **ISS «Taxas Contributivas»** (PDF): 11 % / 23,75 % / 34,75 %; MOE com gerência 34,75 %.
- **ISS Guia Prático Subsídio de Desemprego (2026)**: 360 dias em 24 meses, 90 dias, 65 %, 617,70 €–1 342,83 €, IAS 537,13 €, SMN 920 €.
- **Código do Trabalho** (PDF oficial da ACT, 11/10/2024): art. 238.º (22 dias úteis), 263.º (Natal até 15/12), 264.º (férias antes das férias), 268.º (+25/37,5/50; +50/75/100), 271.º (hora = salário × 12 ÷ 52 ÷ h).
- O que NÃO se conseguiu verificar ficou `por_confirmar` e fora da app (CAE por ofício, troca de carta, dístico TVDE).

## 2. Onboarding — «Trabalhas como?»
- 4 respostas (recibos verdes / contrato / os dois / tenho uma empresa); caminhos: contrato → salário bruto + ano de nascimento (IRS Jovem, pode saltar); empresa → ENI ou sociedade, IVA mensal/trimestral, e-mail do contabilista (pode saltar); recibos verdes → o caminho de sempre.
- Defeito apanhado pelo teste O01: ao escolher a última opção de uma pergunta, a seguinte aparecia já rolada para baixo (sem título). `ListView(key: ValueKey(_passo))`.
- Prova: `flutter test test/unit/onboarding_guarda_test.dart test/golden/onboarding_test.dart` → `+16: All tests passed!`; fotos `onboarding_trabalho_*`, `onboarding_salario_*`, `onboarding_nascimento_medio_pt`, `onboarding_empresa_medio_pt`, `onboarding_iva_periodo_medio_pt`, `onboarding_contabilista_medio_teclado_pt`.

## 3. As contas do contrato (`lib/regras/contrato.dart`) — testes H01–H13 calculados à mão
- 1 200 € brutos → SS 132,00 (11 %); com 96,50 € retidos → líquido 971,50 €.
- IRS anual: 16 800 € (14 meses) − 4 587,09 (8,54 × IAS) = 12 212,91 → 2.º escalão → 1 650,49 €; retido 1 351 € → **acerto a pagar 299,49 €**; com 150 €/mês retidos → reembolso 449,51 €.
- IRS Jovem: 26 anos, 1.º ano → 100 %, limite 29 542,15 €; 36 anos → não; 11.º ano → não.
- Desemprego: 400 dias → tem direito, 780,00 €/mês, pedir até 17/12/2026; 300 dias → faltam 60; SMN → mínimo 617,70 €; 4 000 € → teto 1 342,83 €.
- Horas extra (1 200 €, 40 h): hora 6,92 → 8,65 / 9,52 / 10,38; > 100 h → 10,38 / 12,11 / 13,84.
- Prova: `flutter test test/unit/contrato_test.dart` → `+13: All tests passed!`.

## 4. O calendário de cada perfil (Dart `perfis_test.dart` P01–P12 e Deno P01/P06/P07/P09/P10/P12)
- Contrato: IRS (anexo A), e-fatura, subsídio de Natal 15/12 (valor = salário, lembrete), «pede fatura com NIF» 12× (lembrete); sem SS/IVA de independente.
- Os dois: SS de independente + Natal + IRS «anexos A e B».
- Empresa ENI trimestral: IVA 4×, SAF-T 12× (5 out é feriado → 6, como a AT), DMR 12× (10 out sábado → 12), SS 12× (25 out domingo → 26); sem IRC/IES.
- Sociedade mensal: IVA de setembro → 20 nov; Modelo 22 31/05/2027; IES 15/07/2027; PPC IRC 30/09/2026, 15/12/2026, 31/07/2027; IRS pessoal.
- **Cicatriz**: `add(Duration(days: 1))` no fim da hora de verão (25/10/2026) dava «26/10 às 23:00»; `somarDias()` por calendário em `datas.dart`, `carro.dart`, `obrigacoes.dart`, `seguranca_social.dart` (teste P08).
- Prova: `flutter test test/unit` → `+164`; `deno test _shared/regras_test.ts` → `39 passed`.

## 5. O servidor (calcular-obrigacoes v6) — prova real na conta de teste `boraappbora+emulador`
- 1.ª chamada com `tipo_trabalho='contrato'` → **500** `violates check constraint "obrigacoes_tipo_check"` → migração **0037** (tipos novos no CHECK).
- 2.ª chamada (pg_net id 303) → **200** `{"geradas":15,"novas":13,"atualizadas":2,"apagadas":9}`; SELECT: `faturas_nif 12 (1.ª 2026-09-30)`, `subsidio_natal 1 (2026-12-15, 1200.00)`, `irs_entrega`, `efatura_validar`.
- Reposto `independente` e regenerado → de volta a `ss_pagamento 6, ss_declaracao 2, fim_isencao_ss 1, irs_entrega 1, efatura_validar 1`.

## 6. Pasta do contabilista — prova real, e-mail entregue
- `resend_api_key` posta no Vault (`length 36`, domínio `boraguarda.com` verified na Resend: `GET /domains → 200`).
- Conta de teste com `contabilista_email = boraappbora@gmail.com` e 2 entradas de agosto (84,50 + 61,20); chamada pg_net id 301 com `user_id` + segredo → `pastas_contabilista`: `mes 2026-08-01, estado enviada, itens {"entradas":2,…}, enviado_em 2026-09-18 10:18:54`.
- Gmail (MCP): thread `1a0b406bff1c167b`, de `emdia@boraguarda.com` para `boraappbora@gmail.com`, assunto **«Pasta de agosto de 2026 — cliente Em Dia (Em Dia)»**, corpo «Entrou: 145,70 € (2 linhas)…», **5 anexos** `entrou.csv, saiu.csv, extrato.csv, faturas_recebidas.csv, faturas_recibo_emitidas.csv`.
- Limpeza: as 2 entradas de teste apagadas; `pasta_contabilista_ativa=false` na conta de teste (para o cron do dia 1 não lhe enviar nada).
- Cron `em-dia-pasta-contabilista-mes` `0 6 1 * *` ativo; modo «agora» na app («Enviar já a do mês passado»).

## 7. Ecrãs
- «O meu trabalho» (contrato): recibo de vencimento linha a linha + IRS do ano (verde reembolso / laranja acerto), cartão IRS Jovem (só com ≤ 35 anos), «Pede fatura com NIF» com as 5 deduções e o prazo de fevereiro, «Fiquei sem trabalho» (régua de meses, valor, data limite, 3 passos, botões SS Direta/IEFP), «Horas extra, férias e subsídios».
- «A minha empresa»: ENI/sociedade em duas frases, «O que vem a seguir» (4 datas), pasta do contabilista (e-mail, interruptor, enviar já).
- Golden `recibos_perfis_test` → `+5`; suite golden → `+132: All tests passed!`; analyze 1 aviso pré-existente.
