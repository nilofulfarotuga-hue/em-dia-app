# Prova — Assistente IA (`ia-responder`) com as 30 perguntas de `docs/perguntas-teste.md`

- **Corrida:** 2026-09-06 09:26:22 (Lisboa) → 2026-09-06 09:33:05 (Lisboa) · projeto `tgdmgtmknbwhcqoxtjbs` · utilizador `teste@emdia.pt` (plano efetivo `trial`, sem limite mensal)
- **Script:** `tool/ia/perguntas_teste.py` (Python, urllib; 3 s entre perguntas; em 429/503 espera 20 s e repete até 3×)
- **Critérios por pergunta:** (a) cita valores/chaves esperados · (b) linha "Próximo passo:" com prazo/data · (c) variante certa (PT-PT sem "você" / PT-BR com "você") · (d) rodapé "Informação geral, não substitui contabilista.". PASSA = os quatro.

## Totais

| PASSA | FALHA | SEM RESPOSTA |
|---|---|---|
| **11** | **19** | **0** |

## Tabela das 30

| # | pergunta (curta) | variante esp./API | regra(s) esperada(s) | encontrada? | próximo passo? | veredito | prova |
|---|---|---|---|---|---|---|---|
| 1 | Abri atividade em março, quando começo a pagar a Seg… | pt / pt | `ss_isencao_meses`, `ss_pagamento_dia_inicio`, `ss_pagamento_dia_fim`, `ss_declaracao_meses` | sim (3/3) | sim (até) | **PASSA** | [01-abri-atividade-em-marco-quando.md](01-abri-atividade-em-marco-quando.md) |
| 2 | Passei os 15 mil, e agora? | pt / pt | `iva_isencao_limite`, `iva_isencao_perda_imediata`, `iva_isencao_comunicacao_dias_uteis` | sim (4/4) | sim (15 dias úteis) | **PASSA** | [02-passei-os-15-mil-agora.md](02-passei-os-15-mil-agora.md) |
| 3 | Posso pagar menos à Segurança Social? | pt / pt | `ss_ajuste_max`, `ss_minimo_mensal` | sim (2/2) | sim (até) | **PASSA** | [03-posso-pagar-menos-seguranca-social.md](03-posso-pagar-menos-seguranca-social.md) |
| 4 | Quando é a inspeção do meu carro de 2021? | pt / pt | `ipo_ligeiros_anos`, `ipo_avisos_dias` | sim (3/3) | sim (até) | **PASSA** | [04-quando-inspecao-do-meu-carro.md](04-quando-inspecao-do-meu-carro.md) |
| 5 | Tenho de emitir recibo verde para tudo o que recebo? | pt / pt | `iva_mencao_isencao`, `retencao_padrao`, `retencao_dispensa_limite` | sim (3/3) | NÃO | **FALHA** | [05-tenho-de-emitir-recibo-verde.md](05-tenho-de-emitir-recibo-verde.md) |
| 6 | Qual é a diferença entre a retenção de 23% e a de 25%? | pt / pt | `retencao_padrao`, `retencao_opcao` | sim (2/2) | NÃO | **FALHA** | [06-qual-diferenca-entre-retencao-de.md](06-qual-diferenca-entre-retencao-de.md) |
| 7 | Quando pago o IUC do meu carro? | pt / pt | `iuc_regra` | sim (1/1) | sim (até) | **PASSA** | [07-quando-pago-iuc-do-meu.md](07-quando-pago-iuc-do-meu.md) |
| 8 | Quanto tenho de guardar para o IRS? | pt / pt | `irs_coef_servicos`, `irs_minimo_existencia` | sim (2/2) | sim (até) | **PASSA** | [08-quanto-tenho-de-guardar-para.md](08-quanto-tenho-de-guardar-para.md) |
| 9 | O que é o M10 no recibo? | pt / pt | `iva_mencao_isencao` | sim (2/2) | sim (até) | **PASSA** | [09-que-m10-no-recibo.md](09-que-m10-no-recibo.md) |
| 10 | Quando entrego a declaração de IRS? | pt / pt | `irs_entrega_inicio`, `irs_entrega_fim`, `efatura_validar_ate` | sim (3/3) | sim (até) | **PASSA** | [10-quando-entrego-declaracao-de-irs.md](10-quando-entrego-declaracao-de-irs.md) |
| 11 | A carta de condução tem prazo de validade? | pt / pt | `carta_validade` | sim (3/3) | NÃO | **FALHA** | [11-carta-de-conducao-tem-prazo.md](11-carta-de-conducao-tem-prazo.md) |
| 12 | O que acontece se não pagar a Segurança Social a tempo? | pt / pt | `ss_pagamento_dia_inicio`, `ss_pagamento_dia_fim` | NÃO (1/2) | sim (2027-03-01) | **FALHA** | [12-que-acontece-se-nao-pagar.md](12-que-acontece-se-nao-pagar.md) |
| 13 | Posso ficar isenta de IVA para sempre? | pt / pt | `iva_isencao_limite`, `iva_isencao_perda_imediata` | sim (2/2) | sim (em 2026) | **PASSA** | [13-posso-ficar-isenta-de-iva.md](13-posso-ficar-isenta-de-iva.md) |
| 14 | Quando são os pagamentos por conta do IRS? | pt / pt | `irs_pagamentos_conta_pct`, `irs_pagamentos_conta_datas` | NÃO (3/4) | sim (até) | **FALHA** | [14-quando-sao-os-pagamentos-por.md](14-quando-sao-os-pagamentos-por.md) |
| 15 | Levei uma multa de estacionamento, tenho quanto temp… | pt / pt | `multa_pagamento_voluntario_dias_uteis` | sim (1/1) | sim (15 dias úteis) | **PASSA** | [15-levei-uma-multa-de-estacionamento.md](15-levei-uma-multa-de-estacionamento.md) |
| 16 | Sou brasileiro, o tempo do INSS conta? | br / br | `acordo_pt_br_url`, `reforma_carreira_minima_anos`, `reforma_idade` | NÃO (1/3) | sim (até) | **FALHA** | [16-sou-brasileiro-tempo-do-inss.md](16-sou-brasileiro-tempo-do-inss.md) |
| 17 | Quando eu abro atividade, já começo a pagar Seguranç… | br / pt | `ss_isencao_meses` | sim (1/1) | sim (até) | **FALHA** | [17-quando-eu-abro-atividade-ja.md](17-quando-eu-abro-atividade-ja.md) |
| 18 | Preciso trocar minha carteira de motorista brasileira? | br / pt | `troca_carta_estrangeira_prazo_anos`, `por_confirmar` | sim (1/1) | sim (quanto antes) | **FALHA** | [18-preciso-trocar-minha-carteira-de.md](18-preciso-trocar-minha-carteira-de.md) |
| 19 | O que é o e-fatura e até quando eu tenho que validar? | br / pt | `efatura_validar_ate` | sim (1/1) | sim (até) | **FALHA** | [19-que-fatura-ate-quando-eu.md](19-que-fatura-ate-quando-eu.md) |
| 20 | Quanto é a taxa da Segurança Social pra mim? | br / br | `ss_taxa`, `ss_base_servicos` | NÃO (1/2) | sim (até) | **FALHA** | [20-quanto-taxa-da-seguranca-social.md](20-quanto-taxa-da-seguranca-social.md) |
| 21 | Posso descontar menos do que o valor cheio? | br / pt | `ss_ajuste_max`, `ss_minimo_mensal` | NÃO (1/2) | sim (até) | **FALHA** | [21-posso-descontar-menos-do-que.md](21-posso-descontar-menos-do-que.md) |
| 22 | O que acontece se eu ultrapassar os 15 mil de fatura… | br / pt | `iva_isencao_limite`, `iva_isencao_perda_imediata`, `iva_isencao_comunicacao_dias_uteis` | sim (3/3) | NÃO | **FALHA** | [22-que-acontece-se-eu-ultrapassar.md](22-que-acontece-se-eu-ultrapassar.md) |
| 23 | Vendo produtos e presto serviço, como calculo o IRS? | br / pt | `irs_coef_servicos`, `irs_coef_vendas` | sim (2/2) | sim (até) | **FALHA** | [23-vendo-produtos-presto-servico-como.md](23-vendo-produtos-presto-servico-como.md) |
| 24 | Meu seguro do carro vence quando, e quando recebo av… | br / pt | `seguro_aviso_dias` | sim (1/1) | sim (45 dias) | **FALHA** | [24-meu-seguro-do-carro-vence.md](24-meu-seguro-do-carro-vence.md) |
| 25 | Qual é a idade de aposentadoria em Portugal? | br / br | `reforma_idade`, `reforma_carreira_minima_anos` | sim (2/2) | sim (até) | **PASSA** | [25-qual-idade-de-aposentadoria-em.md](25-qual-idade-de-aposentadoria-em.md) |
| 26 | Fiquei doente, tenho direito a algum benefício? | br / pt | `baixa_doenca_dia_inicio`, `baixa_doenca_prazo_garantia_meses` | sim (2/2) | sim (já) | **FALHA** | [26-fiquei-doente-tenho-direito-algum.md](26-fiquei-doente-tenho-direito-algum.md) |
| 27 | Posso ficar desempregado sendo autônomo? | br / pt | `cessacao_atividade_prazo_garantia_dias` | sim (2/2) | sim (até) | **FALHA** | [27-posso-ficar-desempregado-sendo-autonomo.md](27-posso-ficar-desempregado-sendo-autonomo.md) |
| 28 | Até quando tenho que comunicar as faturas dos meus c… | br / pt | `recibos_comunicar_dia` | sim (1/1) | sim (até) | **FALHA** | [28-ate-quando-tenho-que-comunicar.md](28-ate-quando-tenho-que-comunicar.md) |
| 29 | Quantas inspeções meu carro de 2018 já teve? | br / pt | `ipo_ligeiros_anos`, `ipo_apos_8_anos` | NÃO (1/4) | sim (quanto antes) | **FALHA** | [29-quantas-inspecoes-meu-carro-de.md](29-quantas-inspecoes-meu-carro-de.md) |
| 30 | O certificado de motorista TVDE tem validade? | br / pt | `tvde_certificado_validade_anos` | sim (1/1) | sim (5 anos) | **FALHA** | [30-certificado-de-motorista-tvde-tem.md](30-certificado-de-motorista-tvde-tem.md) |

## Perguntas que não passaram (motivo literal)

- **#5** (FALHA): (b) o "Próximo passo:" não tem prazo/data
- **#6** (FALHA): (b) o "Próximo passo:" não tem prazo/data
- **#11** (FALHA): (b) o "Próximo passo:" não tem prazo/data
- **#12** (FALHA): (a) faltam valores esperados: não tenho essa regra confirmada
- **#14** (FALHA): (a) faltam valores esperados: 65\s?% / irs_pagamentos_conta_pct
- **#16** (FALHA): (a) faltam valores esperados: 15 anos / reforma_carreira_minima_anos; 66 anos e 9 meses / 66[.,]75 / reforma_idade
- **#17** (FALHA): (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=8
- **#18** (FALHA): (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=4
- **#19** (FALHA): (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=9
- **#20** (FALHA): (a) faltam valores esperados: 70\s?% / ss_base_servicos
- **#21** (FALHA): (a) faltam valores esperados: 20\s?€ / 20 euros / ss_minimo_mensal · (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=9
- **#22** (FALHA): (b) o "Próximo passo:" não tem prazo/data · (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=9
- **#23** (FALHA): (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=5
- **#24** (FALHA): (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=2
- **#26** (FALHA): (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=6
- **#27** (FALHA): (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=4
- **#28** (FALHA): (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=1
- **#29** (FALHA): (a) faltam valores esperados: 2022; 2024; 2026 · (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=3
- **#30** (FALHA): (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=2

## `conversas_ia` lidas pelo próprio utilizador (PostgREST com o JWT de teste, RLS) — modelo e custo por pergunta

| criado_em (UTC) | modelo | variante | tokens_entrada | tokens_saida | custo_tokens (€) | fora_das_regras | pergunta |
|---|---|---|---|---|---|---|---|
| 2026-09-06T08:25:26.994666+00:00 | gemini-3.7-flash | pt | 11786 | 194 | 0.003746 | False | Abri atividade em março, quando começo a pagar a Segurança S |
| 2026-09-06T08:26:24.037135+00:00 | gemini-3.7-flash | pt | 11784 | 302 | 0.003994 | False | Passei os 15 mil, e agora? |
| 2026-09-06T08:26:29.761021+00:00 | gemini-flash-latest | pt | 11780 | 319 | 0.004032 | False | Posso pagar menos à Segurança Social? |
| 2026-09-06T08:26:35.426294+00:00 | gemini-3.7-flash | pt | 11787 | 266 | 0.003912 | True | Quando é a inspeção do meu carro de 2021? |
| 2026-09-06T08:26:42.532915+00:00 | gemini-3.7-flash | pt | 11787 | 249 | 0.003873 | False | Tenho de emitir recibo verde para tudo o que recebo? |
| 2026-09-06T08:27:17.248935+00:00 | gemini-3.7-flash | pt | 11793 | 210 | 0.003785 | False | Qual é a diferença entre a retenção de 23% e a de 25%? |
| 2026-09-06T08:27:27.951925+00:00 | gemini-3.5-flash | pt | 11781 | 561 | 0.004589 | False | Quando pago o IUC do meu carro? |
| 2026-09-06T08:27:33.51919+00:00 | gemini-3.7-flash | pt | 11780 | 268 | 0.003915 | False | Quanto tenho de guardar para o IRS? |
| 2026-09-06T08:28:01.980619+00:00 | gemini-3.7-flash | pt | 11783 | 211 | 0.003785 | False | O que é o M10 no recibo? |
| 2026-09-06T08:28:08.832289+00:00 | gemini-3.7-flash | pt | 11781 | 381 | 0.004175 | False | Quando entrego a declaração de IRS? |
| 2026-09-06T08:28:14.483293+00:00 | gemini-3.7-flash | pt | 11783 | 161 | 0.00367 | False | A carta de condução tem prazo de validade? |
| 2026-09-06T08:28:26.787093+00:00 | gemini-3.5-flash | pt | 11784 | 1418 | 0.006561 | False | O que acontece se não pagar a Segurança Social a tempo? |
| 2026-09-06T08:28:39.15992+00:00 | gemini-3.5-flash | pt | 11782 | 1247 | 0.006167 | False | Posso ficar isenta de IVA para sempre? |
| 2026-09-06T08:28:47.062734+00:00 | gemini-3.6-flash | pt | 11782 | 419 | 0.004263 | False | Quando são os pagamentos por conta do IRS? |
| 2026-09-06T08:29:03.611159+00:00 | gemini-3.5-flash | pt | 11787 | 1087 | 0.0058 | False | Levei uma multa de estacionamento, tenho quanto tempo para p |
| 2026-09-06T08:29:09.1118+00:00 | gemini-3.7-flash | br | 11778 | 148 | 0.003638 | False | Sou brasileiro, o tempo do INSS conta? |
| 2026-09-06T08:29:30.066905+00:00 | gemini-3.5-flash | pt | 11787 | 1496 | 0.006741 | False | Quando eu abro atividade, já começo a pagar Segurança Social |
| 2026-09-06T08:29:52.834317+00:00 | gemini-3.5-flash | pt | 11783 | 1142 | 0.005926 | True | Preciso trocar minha carteira de motorista brasileira? |
| 2026-09-06T08:30:18.528742+00:00 | gemini-3.5-flash | pt | 11788 | 937 | 0.005456 | False | O que é o e-fatura e até quando eu tenho que validar? |
| 2026-09-06T08:30:38.368675+00:00 | gemini-3.5-flash | br | 11778 | 1034 | 0.005676 | False | Quanto é a taxa da Segurança Social pra mim? |
| 2026-09-06T08:30:56.87366+00:00 | gemini-3.5-flash | pt | 11783 | 522 | 0.0045 | False | Posso descontar menos do que o valor cheio? |
| 2026-09-06T08:31:19.637226+00:00 | gemini-3.5-flash | pt | 11788 | 2044 | 0.008002 | False | O que acontece se eu ultrapassar os 15 mil de faturamento? |
| 2026-09-06T08:31:48.850012+00:00 | gemini-3.5-flash | pt | 11784 | 1743 | 0.007308 | False | Vendo produtos e presto serviço, como calculo o IRS? |
| 2026-09-06T08:32:16.226679+00:00 | gemini-flash-lite-latest | pt | 11785 | 92 | 0.003511 | False | Meu seguro do carro vence quando, e quando recebo aviso? |
| 2026-09-06T08:32:21.67172+00:00 | gemini-flash-lite-latest | br | 11779 | 104 | 0.003537 | False | Qual é a idade de aposentadoria em Portugal? |
| 2026-09-06T08:32:27.060093+00:00 | gemini-flash-lite-latest | pt | 11785 | 152 | 0.003649 | False | Fiquei doente, tenho direito a algum benefício? |
| 2026-09-06T08:32:32.216681+00:00 | gemini-flash-lite-latest | pt | 11784 | 148 | 0.00364 | False | Posso ficar desempregado sendo autônomo? |
| 2026-09-06T08:32:37.022658+00:00 | gemini-flash-lite-latest | pt | 11785 | 75 | 0.003472 | False | Até quando tenho que comunicar as faturas dos meus clientes? |
| 2026-09-06T08:32:59.448709+00:00 | gemini-3.5-flash | pt | 11787 | 821 | 0.005189 | True | Quantas inspeções meu carro de 2018 já teve? |
| 2026-09-06T08:33:04.406662+00:00 | gemini-flash-lite-latest | pt | 11783 | 93 | 0.003513 | False | O certificado de motorista TVDE tem validade? |

- Linhas: 30 · custo somado: **0.140025 €**

## SELECT de prova (executado por SQL no projeto, colado pelo executor)

```sql
select count(*), sum(custo_tokens), min(criado_em), max(criado_em) from conversas_ia where criado_em > now() - interval '2 hours';
```

<!-- RESULTADO_SQL -->
