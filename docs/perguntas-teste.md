# 30 perguntas de teste do Assistente IA — Em Dia

> Gerado para a secção 3 da missão (`docs/PROMPT_MISSAO_2026-09-05.md`). 15 perguntas em PT-PT, 15 em PT-BR,
> cobrindo os perfis TVDE, estafeta, cabeleireira, freelancer, imigrante brasileiro e só-carro.
> Cada "prazo/número esperado" foi calculado a partir de `supabase/migrations/20260905_0003_seed.sql`
> (a ÚNICA fonte de números legais) e, quando aplicável, confere com os casos de `docs/casos-teste.md`
> (C08, C16, C28, C42). Onde a regra está `por_confirmar` na tabela, o esperado é a IA dizer isso —
> nunca inventar um valor.
>
> Quando corridas de verdade contra `ia-responder`, guardar as 30 saídas em `docs/provas/ia/`
> (fora do âmbito desta tarefa — aqui só se define o guião e o esperado calculável).

## PT-PT (15 perguntas)

| # | variante | perfil | pergunta | regra(s) a citar (chave de regras_legais) | prazo/número esperado na resposta |
|---|---|---|---|---|---|
| 1 | PT-PT | TVDE | "Abri atividade em março [de 2026], quando começo a pagar a Segurança Social?" | `ss_isencao_meses`, `ss_pagamento_dia_inicio`, `ss_pagamento_dia_fim`, `ss_declaracao_meses` | Isenção termina no fim de fevereiro de 2027; paga desde março de 2027 (contribuição mensal até dia 20); primeira declaração trimestral até 30/04/2027 (confere com C16/C42) |
| 2 | PT-PT | TVDE | "Passei os 15 mil [de faturação este ano], e agora?" | `iva_isencao_limite`, `iva_isencao_perda_imediata`, `iva_isencao_comunicacao_dias_uteis` | Entre 15.000 € e 18.750 €: cobra IVA a partir de 1 de janeiro do ano seguinte. Acima de 18.750 €: perde a isenção de imediato (a fatura seguinte já leva 23% de IVA) e tem de comunicar às Finanças em 15 dias úteis (confere com C08/C09) |
| 3 | PT-PT | Estafeta | "Posso pagar menos à Segurança Social?" | `ss_ajuste_max`, `ss_minimo_mensal` | Pode pedir um ajuste de até 25% a menos (ou a mais) na declaração trimestral, mas nunca abaixo do mínimo de 20 €/mês (confere com C11/C12/C13) |
| 4 | PT-PT | Só-carro | "Quando é a inspeção do meu carro de 2021?" | `ipo_ligeiros_anos`, `ipo_avisos_dias` | 1.ª inspeção aos 4 anos (2025), 2.ª aos 6 anos (2027), 3.ª aos 8 anos (2029), depois todos os anos; aviso 30 e 7 dias antes (confere com C28) |
| 5 | PT-PT | Cabeleireira | "Tenho de emitir recibo verde para tudo o que recebo?" | `iva_mencao_isencao`, `retencao_padrao`, `retencao_dispensa_limite` | Sim, todo o rendimento de serviços tem recibo verde. Se estiver isenta de IVA (< 15.000 €/ano) o recibo leva "IVA - regime de isenção [artigo 53.º do CIVA] (M10)"; a retenção de IRS é 23% (ou 25% por opção), com dispensa possível se faturou menos de 15.000 € no ano anterior |
| 6 | PT-PT | Freelancer | "Qual é a diferença entre a retenção de 23% e a de 25%?" | `retencao_padrao`, `retencao_opcao` | 23% é a retenção padrão (desde 2025); 25% é uma opção do próprio prestador, para reter mais e sobrar menos para pagar no IRS final |
| 7 | PT-PT | TVDE | "Quando pago o IUC do meu carro?" | `iuc_regra` | Todos os anos, até ao fim do mês da matrícula do carro |
| 8 | PT-PT | Estafeta | "Quanto tenho de guardar para o IRS?" | `irs_coef_servicos`, `irs_minimo_existencia` | No regime simplificado só 75% do que recebe de serviços conta para o rendimento coletável; até 12.880 €/ano de rendimento líquido não paga IRS (mínimo de existência); acima disso aplica-se o escalão correspondente |
| 9 | PT-PT | Cabeleireira | "O que é o M10 no recibo?" | `iva_mencao_isencao` | É a menção obrigatória no recibo verde de quem está isento de IVA: "IVA - regime de isenção [artigo 53.º do CIVA] (M10)" |
| 10 | PT-PT | Freelancer | "Quando entrego a declaração de IRS?" | `irs_entrega_inicio`, `irs_entrega_fim`, `efatura_validar_ate` | Entre 1 de abril e 30 de junho; antes disso, valida as faturas no e-fatura até 25 de fevereiro |
| 11 | PT-PT | Só-carro | "A carta de condução tem prazo de validade?" | `carta_validade` | Sim: 15 anos até aos 60 anos; depois 5 anos até aos 70; a partir dos 70, renova-se a cada 2 anos |
| 12 | PT-PT | TVDE | "O que acontece se não pagar a Segurança Social a tempo?" | `ss_pagamento_dia_inicio`, `ss_pagamento_dia_fim` | Cita só o prazo confirmado (pagamento entre dia 10 e 20); a app não tem confirmado o valor dos juros/coima em atraso — resposta esperada inclui "não tenho essa regra confirmada" para o valor da penalização |
| 13 | PT-PT | Cabeleireira | "Posso ficar isenta de IVA para sempre?" | `iva_isencao_limite`, `iva_isencao_perda_imediata` | Pode continuar isenta enquanto não ultrapassar 15.000 €/ano; passa a pagar IVA a partir do ano seguinte se ultrapassar esse valor, ou de imediato se ultrapassar 18.750 € |
| 14 | PT-PT | Freelancer | "Quando são os pagamentos por conta do IRS?" | `irs_pagamentos_conta_pct`, `irs_pagamentos_conta_datas` | 20 de julho, 20 de setembro e 20 de dezembro; juntos totalizam 65% do IRS calculado do ano anterior, divididos em 3 prestações |
| 15 | PT-PT | Estafeta | "Levei uma multa de estacionamento, tenho quanto tempo para pagar?" | `multa_pagamento_voluntario_dias_uteis` | 15 dias úteis (pagamento voluntário) |

## PT-BR (15 perguntas)

| # | variante | perfil | pergunta | regra(s) a citar (chave de regras_legais) | prazo/número esperado na resposta |
|---|---|---|---|---|---|
| 16 | PT-BR | Estafeta (imigrante brasileiro) | "Sou brasileiro, o tempo do INSS conta?" | `acordo_pt_br_url`, `reforma_carreira_minima_anos`, `reforma_idade` | Sim, o Acordo de Segurança Social Portugal–Brasil soma o tempo descontado nos dois países; a carreira mínima em Portugal é de 15 anos e a idade de reforma em 2026 é 66 anos e 9 meses |
| 17 | PT-BR | Freelancer (imigrante) | "Quando eu abro atividade, já começo a pagar Segurança Social na hora?" | `ss_isencao_meses` | Não: os primeiros 12 meses de atividade são isentos de contribuições; só começa a pagar no 13.º mês |
| 18 | PT-BR | TVDE (imigrante) | "Preciso trocar minha carteira de motorista brasileira?" | `troca_carta_estrangeira_prazo_anos` (`por_confirmar`) | Regra ainda não confirmada na app — resposta esperada: "não tenho essa regra confirmada"; o valor de referência guardado (não citável como certo) é 2 anos após fixar residência, a confirmar no IMT |
| 19 | PT-BR | Cabeleireira (imigrante) | "O que é o e-fatura e até quando eu tenho que validar?" | `efatura_validar_ate` | Até 25 de fevereiro de cada ano, validar as faturas do ano anterior no portal e-fatura |
| 20 | PT-BR | TVDE (brasileiro) | "Quanto é a taxa da Segurança Social pra mim?" | `ss_taxa`, `ss_base_servicos` | 21,4% sobre 70% do rendimento trimestral de serviços (a base de incidência) |
| 21 | PT-BR | Estafeta (brasileira) | "Posso descontar menos do que o valor cheio?" | `ss_ajuste_max`, `ss_minimo_mensal` | Sim, pode pedir até 25% a menos na declaração trimestral, respeitando o mínimo de 20 €/mês |
| 22 | PT-BR | Freelancer (brasileira) | "O que acontece se eu ultrapassar os 15 mil de faturamento?" | `iva_isencao_limite`, `iva_isencao_perda_imediata`, `iva_isencao_comunicacao_dias_uteis` | Entre 15.000 € e 18.750 €: perde a isenção no ano seguinte. Acima de 18.750 €: perde na hora, com comunicação às Finanças em 15 dias úteis |
| 23 | PT-BR | Cabeleireira (brasileira) | "Vendo produtos e presto serviço, como calculo o IRS?" | `irs_coef_servicos`, `irs_coef_vendas` | 75% do que recebe de serviços conta como rendimento; só 15% do que recebe de venda de produtos conta; soma-se os dois valores para chegar ao rendimento coletável |
| 24 | PT-BR | Só-carro (brasileiro) | "Meu seguro do carro vence quando, e quando recebo aviso?" | `seguro_aviso_dias` | O aviso chega 45 dias antes da renovação, para dar tempo de comparar preços |
| 25 | PT-BR | TVDE (brasileiro) | "Qual é a idade de aposentadoria em Portugal?" | `reforma_idade`, `reforma_carreira_minima_anos` | 66 anos e 9 meses em 2026, com carreira contributiva mínima de 15 anos |
| 26 | PT-BR | Estafeta (brasileiro) | "Fiquei doente, tenho direito a algum benefício?" | `baixa_doenca_dia_inicio`, `baixa_doenca_prazo_garantia_meses` | Sim: subsídio de doença a partir do 11.º dia de baixa, desde que tenha pelo menos 6 meses de descontos |
| 27 | PT-BR | Freelancer (brasileiro) | "Posso ficar desempregado sendo autônomo?" | `cessacao_atividade_prazo_garantia_dias` | Existe o subsídio por cessação de atividade (o "desemprego" dos independentes), que exige 360 dias de descontos nos 24 meses anteriores |
| 28 | PT-BR | Cabeleireira (brasileira) | "Até quando tenho que comunicar as faturas dos meus clientes?" | `recibos_comunicar_dia` | Até ao dia 5 do mês seguinte, se usar software de faturação (SAF-T) |
| 29 | PT-BR | Só-carro (brasileiro) | "Quantas inspeções meu carro de 2018 já teve?" | `ipo_ligeiros_anos`, `ipo_apos_8_anos` | Já passou pelas inspeções de 4 anos (2022) e 6 anos (2024); em 2026 (8 anos) tem a terceira, e a partir daí passa a ser todos os anos |
| 30 | PT-BR | TVDE (brasileiro) | "O certificado de motorista TVDE tem validade?" | `tvde_certificado_validade_anos` | Sim, válido por 5 anos |

## Resumo

- **PT-PT:** 15 perguntas (#1–15) — perfis TVDE (4), Estafeta (3), Cabeleireira (3), Freelancer (3), Só-carro (2).
- **PT-BR:** 15 perguntas (#16–30) — todas de utilizador imigrante/brasileiro, cobrindo TVDE (4), Estafeta (3), Cabeleireira (3), Freelancer (3), Só-carro (2).
- **Total: 30 perguntas.**
- As 5 perguntas obrigatórias da missão estão incluídas: #1, #2, #3, #4 (PT-PT) e #16 (PT-BR).
- 2 perguntas (#12, #18) testam o caso "regra não confirmada" — a IA deve responder "não tenho essa regra confirmada" em vez de inventar um número (`ss` sem regra de juros de mora citada; `troca_carta_estrangeira_prazo_anos` marcada `por_confirmar` na seed).
