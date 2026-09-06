# Prova — "A Minha Vida" no servidor (2026-09-06, 16h00 Lisboa)

O que entra e o que sai passa a existir na base de dados, com quatro funções
que a app chama. Provado com dados a sério, e os dados apagados a seguir para a
base ficar como o Danilo mandou: um utilizador novo arranca do zero.

## As contas do mês nascem sozinhas, com as duas armadilhas resolvidas

Três contas registadas: a renda no dia 8, a luz no dia 20, o telemóvel no
dia 31. `gerar_pagamentos_do_mes` devolveu isto:

| Conta | Como se paga | Dia pedido | Prazo que saiu | Dia da semana |
|---|---|---:|---|---|
| Renda da casa | transferência | 8 | 08/09/2026 | terça |
| Luz | referência Multibanco | 20 | **18/09/2026** | sexta |
| Telemóvel e net | débito direto | 31 | **30/09/2026** | quarta |

As duas linhas a negrito são o que interessa:

- **O dia 20 de setembro de 2026 é um domingo.** O prazo recuou para a sexta,
  dia 18 — a mesma regra das obrigações do Estado (`dia_util_anterior_ou_igual`).
  Avisar no dia certo quando o dia certo é domingo não serve de nada.
- **Setembro não tem dia 31.** A conta do telemóvel foi para o dia 30, o último
  do mês, em vez de desaparecer ou ir parar a outubro.

## O resumo do mês

Com 492,40 € entrados (312,40 € de uma semana de Uber e 180,00 € de um recibo)
e as três contas por pagar:

```
mes                 2026-09-01
entrou                  492.40
saiu                      0.00
falta_pagar_contas      568.90
falta_pagar_estado        0.00
como_acaba_o_mes        -76.50
no_cofre                 60.00
```

O número que interessa é o **-76,50 €**: entra menos do que tem de sair. É esta
a frase que a app tem de dizer a tempo, e não no fim do mês.

## O resumo do ano, para o IRS

```
ano                 2026
entrou_total      492.40
entrou_para_irs   492.40
por_tipo          { plataforma: 312.40, recibo_verde: 180.00 }
por_mes           { 2026-09: 492.40 }
saiu_total             0
```

## O radar da fidelização

```
nome              Telemóvel e net
fornecedor        MEO
categoria         telemovel
fim_fidelizacao   2026-09-27
dias_para_acabar  21
valor_mensal      58.00
```

A janela de 30 dias vem da tabela das regras (`aviso_fidelizacao_dias`), não de
uma constante no código.

## Cicatriz: `mes` ambíguo, duas vezes no mesmo dia

O primeiro `gerar_pagamentos_do_mes` rebentou com:

```
ERROR: 42702: column reference "mes" is ambiguous
DETAIL: It could refer to either a PL/pgSQL variable or a table column.
```

A variável chamava-se `mes` e a coluna também. Corrigi, e meia hora depois caí
exatamente no mesmo no `resumo_do_mes`. Regra da casa, agora escrita no topo da
migração: **em plpgsql, nunca dar a uma variável o nome de uma coluna da tabela
que se vai ler.**

## Segurança

As quatro funções verificam `pode_ver_plano(uid)` antes de responder: só falam
sobre quem pergunta, sobre qualquer um se quem pergunta for administrador, e
sobre qualquer um para o servidor. `anon` não tem permissão em nenhuma.

## Estado da base depois de tudo

```
saidas 0 · saidas_pagamentos 0 · entradas 0 · cofre_movimentos 0
leituras_ocr 0 · conversas_ia 0 · perfis com onboarding feito 0
```
