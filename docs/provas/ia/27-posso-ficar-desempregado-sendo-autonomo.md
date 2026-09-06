# Pergunta 27 — Posso ficar desempregado sendo autônomo?

- **Data/hora:** 2026-09-06 09:32:31 (Lisboa)
- **Perfil do guião:** Freelancer (brasileiro) · **variante esperada:** BR
- **Pergunta enviada (literal):** `Posso ficar desempregado sendo autônomo?`
- **Regras a citar (guião):** `cessacao_atividade_prazo_garantia_dias`
- **Esperado (guião):** Existe o subsídio por cessação de atividade (o "desemprego" dos independentes), que exige 360 dias de descontos nos 24 meses anteriores
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 2.1s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `32` · **limite_valor:** `None`

### Resposta literal

```text
Sim, podes! Quem trabalha a recibos verdes pode ter um apoio se parar de trabalhar. Chama-se subsídio por cessação de atividade (o "desemprego" dos independentes). 

Para teres este direito, precisas de ter descontado durante 360 dias (cessacao_atividade_prazo_garantia_dias) nos últimos 24 meses.

Como estás a começar agora e estás no primeiro ano de isenção, ainda não tens esses descontos feitos.

Próximo passo: Pagar o pagamento por conta do IRS até 20 de setembro (irs_pagamentos_conta_datas).

Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Sim, podes! Quem trabalha a recibos verdes pode ter um apoio se parar de trabalhar. Chama-se subsídio por cessação de atividade (o \"desemprego\" dos independentes). \n\nPara teres este direito, precisas de ter descontado durante 360 dias (cessacao_atividade_prazo_garantia_dias) nos últimos 24 meses.\n\nComo estás a começar agora e estás no primeiro ano de isenção, ainda não tens esses descontos feitos.\n\nPróximo passo: Pagar o pagamento por conta do IRS até 20 de setembro (irs_pagamentos_conta_datas).\n\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 32,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 2/2; encontrados: `360 dias`, `24 meses`; chaves do guião citadas no texto: `cessacao_atividade_prazo_garantia_dias`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Pagar o pagamento por conta do IRS até 20 de setembro (irs_pagamentos_conta_datas).` · prazo detetado: `até`
- **(c) variante certa (BR)?** NÃO — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 4
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=4
