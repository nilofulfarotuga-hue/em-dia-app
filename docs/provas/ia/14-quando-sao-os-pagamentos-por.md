# Pergunta 14 — Quando são os pagamentos por conta do IRS?

- **Data/hora:** 2026-09-06 09:28:43 (Lisboa)
- **Perfil do guião:** Freelancer · **variante esperada:** PT
- **Pergunta enviada (literal):** `Quando são os pagamentos por conta do IRS?`
- **Regras a citar (guião):** `irs_pagamentos_conta_pct`, `irs_pagamentos_conta_datas`
- **Esperado (guião):** 20 de julho, 20 de setembro e 20 de dezembro; juntos totalizam 65% do IRS calculado do ano anterior, divididos em 3 prestações
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 4.9s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `19` · **limite_valor:** `None`

### Resposta literal

```text
Os pagamentos por conta do IRS são adiantamentos do imposto que fazes ao Estado. 

Eles acontecem 3 vezes por ano, nestas datas (irs_pagamentos_conta_datas):
- 20 de julho
- 20 de setembro
- 20 de dezembro

No teu caso, o próximo pagamento por conta é a 20 de setembro de 2026.

Próximo passo: Paga a prestação do IRS até 20 de setembro de 2026 (irs_pagamentos_conta_datas).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Os pagamentos por conta do IRS são adiantamentos do imposto que fazes ao Estado. \n\nEles acontecem 3 vezes por ano, nestas datas (irs_pagamentos_conta_datas):\n- 20 de julho\n- 20 de setembro\n- 20 de dezembro\n\nNo teu caso, o próximo pagamento por conta é a 20 de setembro de 2026.\n\nPróximo passo: Paga a prestação do IRS até 20 de setembro de 2026 (irs_pagamentos_conta_datas).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 19,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** NÃO — grupos encontrados 3/4; encontrados: `20 de julho`, `20 de setembro`, `20 de dezembro`; **em falta:** 65\s?% / irs_pagamentos_conta_pct; chaves do guião citadas no texto: `irs_pagamentos_conta_datas`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Paga a prestação do IRS até 20 de setembro de 2026 (irs_pagamentos_conta_datas).` · prazo detetado: `até`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 2
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (a) faltam valores esperados: 65\s?% / irs_pagamentos_conta_pct
