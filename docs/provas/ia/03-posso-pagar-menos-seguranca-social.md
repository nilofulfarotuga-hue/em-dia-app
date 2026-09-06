# Pergunta 03 — Posso pagar menos à Segurança Social?

- **Data/hora:** 2026-09-06 09:26:28 (Lisboa)
- **Perfil do guião:** Estafeta · **variante esperada:** PT
- **Pergunta enviada (literal):** `Posso pagar menos à Segurança Social?`
- **Regras a citar (guião):** `ss_ajuste_max`, `ss_minimo_mensal`
- **Esperado (guião):** Pode pedir um ajuste de até 25% a menos (ou a mais) na declaração trimestral, mas nunca abaixo do mínimo de 20 €/mês (confere com C11/C12/C13)
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 2.7s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `8` · **limite_valor:** `None`

### Resposta literal

```text
Sim, podes pagar menos de duas formas:

1. **Ajustar na declaração trimestral:** Quando entregas a declaração de 3 em 3 meses (o papel no computador a dizer o que ganhaste), podes pedir para pagar até 25% a menos (ss_ajuste_max). 

2. **Se não ganhares dinheiro:** O valor mínimo obrigatório a pagar é de 20 € por mês (ss_minimo_mensal).

Além disso, tens isenção (não pagas nada) nos primeiros 12 meses de atividade (ss_isencao_meses). Como abriste atividade em 2026-03-15, estás isento até 2027-03-01 (ss_isencao_meses). Por isso, agora ainda não precisas de pagar a contribuição mensal!

Quando a isenção acabar, a taxa normal é de 21,4% (ss_taxa) calculada sobre 70% do dinheiro que ganhaste em serviços (ss_base_servicos).

Próximo passo: Aproveita a tua isenção até 2027-03-01 (ss_isencao_meses) e só terás de fazer a primeira declaração até ao fim de abril de 2027 (ss_declaracao_meses).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Sim, podes pagar menos de duas formas:\n\n1. **Ajustar na declaração trimestral:** Quando entregas a declaração de 3 em 3 meses (o papel no computador a dizer o que ganhaste), podes pedir para pagar até 25% a menos (ss_ajuste_max). \n\n2. **Se não ganhares dinheiro:** O valor mínimo obrigatório a pagar é de 20 € por mês (ss_minimo_mensal).\n\nAlém disso, tens isenção (não pagas nada) nos primeiros 12 meses de atividade (ss_isencao_meses). Como abriste atividade em 2026-03-15, estás isento até 2027-03-01 (ss_isencao_meses). Por isso, agora ainda não precisas de pagar a contribuição mensal!\n\nQuando a isenção acabar, a taxa normal é de 21,4% (ss_taxa) calculada sobre 70% do dinheiro que ganhaste em serviços (ss_base_servicos).\n\nPróximo passo: Aproveita a tua isenção até 2027-03-01 (ss_isencao_meses) e só terás de fazer a primeira declaração até ao fim de abril de 2027 (ss_declaracao_meses).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 8,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 2/2; encontrados: `25%`, `20 €`; chaves do guião citadas no texto: `ss_ajuste_max`, `ss_minimo_mensal`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Aproveita a tua isenção até 2027-03-01 (ss_isencao_meses) e só terás de fazer a primeira declaração até ao fim de abril de 2027 (ss_declaracao_meses).` · prazo detetado: `até`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 6
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **PASSA**
