# Pergunta 15 — Levei uma multa de estacionamento, tenho quanto tempo para pagar?

- **Data/hora:** 2026-09-06 09:28:51 (Lisboa)
- **Perfil do guião:** Estafeta · **variante esperada:** PT
- **Pergunta enviada (literal):** `Levei uma multa de estacionamento, tenho quanto tempo para pagar?`
- **Regras a citar (guião):** `multa_pagamento_voluntario_dias_uteis`
- **Esperado (guião):** 15 dias úteis (pagamento voluntário)
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 13.5s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `20` · **limite_valor:** `None`

### Resposta literal

```text
Se levaste uma multa de estacionamento, tens de a pagar depressa. 

O prazo para fazeres o pagamento voluntário (pagar por tua vontade para não ficar mais caro) é de 15 dias úteis (multa_pagamento_voluntario_dias_uteis). Dias úteis são os dias de trabalho. Não contam os sábados, os domingos nem os feriados.

Se deixares passar este tempo, o valor da multa pode subir e ficas com problemas maiores. Podes pagar facilmente no multibanco ou através do teu telemóvel.

Próximo passo: Paga a multa de estacionamento no prazo de 15 dias úteis (multa_pagamento_voluntario_dias_uteis).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Se levaste uma multa de estacionamento, tens de a pagar depressa. \n\nO prazo para fazeres o pagamento voluntário (pagar por tua vontade para não ficar mais caro) é de 15 dias úteis (multa_pagamento_voluntario_dias_uteis). Dias úteis são os dias de trabalho. Não contam os sábados, os domingos nem os feriados.\n\nSe deixares passar este tempo, o valor da multa pode subir e ficas com problemas maiores. Podes pagar facilmente no multibanco ou através do teu telemóvel.\n\nPróximo passo: Paga a multa de estacionamento no prazo de 15 dias úteis (multa_pagamento_voluntario_dias_uteis).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 20,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 1/1; encontrados: `15 dias úteis`; chaves do guião citadas no texto: `multa_pagamento_voluntario_dias_uteis`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Paga a multa de estacionamento no prazo de 15 dias úteis (multa_pagamento_voluntario_dias_uteis).` · prazo detetado: `15 dias úteis`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 5
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **PASSA**
