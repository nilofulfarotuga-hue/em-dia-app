# Pergunta 01 — Abri atividade em março [de 2026], quando começo a pagar a Segurança Social?

- **Data/hora:** 2026-09-06 09:25:01 (Lisboa)
- **Perfil do guião:** TVDE · **variante esperada:** PT
- **Pergunta enviada (literal):** `Abri atividade em março, quando começo a pagar a Segurança Social?`
- **Regras a citar (guião):** `ss_isencao_meses`, `ss_pagamento_dia_inicio`, `ss_pagamento_dia_fim`, `ss_declaracao_meses`
- **Esperado (guião):** Isenção termina no fim de fevereiro de 2027; paga desde março de 2027 (contribuição mensal até dia 20); primeira declaração trimestral até 30/04/2027 (confere com C16/C42)
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 2 · duração da última: 2.6s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `6` · **limite_valor:** `None`

### Resposta literal

```text
Como abriste atividade em março de 2026, tens direito a 12 meses (ss_isencao_meses) sem pagar nada à Segurança Social. É uma ajuda para quem começa.

A tua isenção acaba no dia 2027-03-01 (fim_isencao_ss). 

Depois disso, o teu primeiro pagamento da contribuição (o dinheiro que entregas todos os meses) é feito entre o dia 10 (ss_pagamento_dia_inicio) e o dia 20 de abril de 2027 (ss_pagamento_dia_fim).

Próximo passo: Acompanha os teus rendimentos na app até ao fim da isenção a 2027-03-01 (ss_isencao_meses).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Como abriste atividade em março de 2026, tens direito a 12 meses (ss_isencao_meses) sem pagar nada à Segurança Social. É uma ajuda para quem começa.\n\nA tua isenção acaba no dia 2027-03-01 (fim_isencao_ss). \n\nDepois disso, o teu primeiro pagamento da contribuição (o dinheiro que entregas todos os meses) é feito entre o dia 10 (ss_pagamento_dia_inicio) e o dia 20 de abril de 2027 (ss_pagamento_dia_fim).\n\nPróximo passo: Acompanha os teus rendimentos na app até ao fim da isenção a 2027-03-01 (ss_isencao_meses).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 6,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 3/3; encontrados: `12 meses`, `2027`, `dia 20`; chaves do guião citadas no texto: `ss_isencao_meses`, `ss_pagamento_dia_inicio`, `ss_pagamento_dia_fim`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Acompanha os teus rendimentos na app até ao fim da isenção a 2027-03-01 (ss_isencao_meses).` · prazo detetado: `até`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 5
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **PASSA**
