# Pergunta 16 — Sou brasileiro, o tempo do INSS conta?

- **Data/hora:** 2026-09-06 09:29:07 (Lisboa)
- **Perfil do guião:** Estafeta (imigrante brasileiro) · **variante esperada:** BR
- **Pergunta enviada (literal):** `Sou brasileiro, o tempo do INSS conta?`
- **Regras a citar (guião):** `acordo_pt_br_url`, `reforma_carreira_minima_anos`, `reforma_idade`
- **Esperado (guião):** Sim, o Acordo de Segurança Social Portugal–Brasil soma o tempo descontado nos dois países; a carreira mínima em Portugal é de 15 anos e a idade de reforma em 2026 é 66 anos e 9 meses
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 2.5s

## Resposta — HTTP 200

- **variante detetada:** `br` · **fora_das_regras:** `False` · **usadas:** `21` · **limite_valor:** `None`

### Resposta literal

```text
Sim, conta! 

Existe um acordo entre Portugal e o Brasil (acordo_pt_br_url). O tempo em que você pagou o INSS no Brasil junta-se ao tempo de descontos da Segurança Social em Portugal para a sua reforma (a sua aposentadoria).

Guarde bem o seu extrato do INSS (o papel que prova os pagamentos no Brasil) para quando precisar pedir o benefício.

Próximo passo: Guarde o seu extrato do INSS e pague o seu pagamento por conta de IRS até 20 de setembro de 2026 (irs_pagamentos_conta_datas).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Sim, conta! \n\nExiste um acordo entre Portugal e o Brasil (acordo_pt_br_url). O tempo em que você pagou o INSS no Brasil junta-se ao tempo de descontos da Segurança Social em Portugal para a sua reforma (a sua aposentadoria).\n\nGuarde bem o seu extrato do INSS (o papel que prova os pagamentos no Brasil) para quando precisar pedir o benefício.\n\nPróximo passo: Guarde o seu extrato do INSS e pague o seu pagamento por conta de IRS até 20 de setembro de 2026 (irs_pagamentos_conta_datas).\nInformação geral, não substitui contabilista.",
  "variante": "br",
  "fora_das_regras": false,
  "usadas": 21,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** NÃO — grupos encontrados 1/3; encontrados: `acordo`; **em falta:** 15 anos / reforma_carreira_minima_anos; 66 anos e 9 meses / 66[.,]75 / reforma_idade; chaves do guião citadas no texto: `acordo_pt_br_url`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Guarde o seu extrato do INSS e pague o seu pagamento por conta de IRS até 20 de setembro de 2026 (irs_pagamentos_conta_datas).` · prazo detetado: `até`
- **(c) variante certa (BR)?** sim — API: `br` · "você" no texto: True · marcas de "tu" (tens/teu/podes…): 0
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (a) faltam valores esperados: 15 anos / reforma_carreira_minima_anos; 66 anos e 9 meses / 66[.,]75 / reforma_idade
