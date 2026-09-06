# Pergunta 28 — Até quando tenho que comunicar as faturas dos meus clientes?

- **Data/hora:** 2026-09-06 09:32:36 (Lisboa)
- **Perfil do guião:** Cabeleireira (brasileira) · **variante esperada:** BR
- **Pergunta enviada (literal):** `Até quando tenho que comunicar as faturas dos meus clientes?`
- **Regras a citar (guião):** `recibos_comunicar_dia`
- **Esperado (guião):** Até ao dia 5 do mês seguinte, se usar software de faturação (SAF-T)
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 1.8s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `33` · **limite_valor:** `None`

### Resposta literal

```text
Para quem usa um programa de faturação, deves comunicar as faturas até ao dia 5 do mês seguinte (recibos_comunicar_dia).

Próximo passo: Comunicar as faturas até ao dia 5 de cada mês (recibos_comunicar_dia).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Para quem usa um programa de faturação, deves comunicar as faturas até ao dia 5 do mês seguinte (recibos_comunicar_dia).\n\nPróximo passo: Comunicar as faturas até ao dia 5 de cada mês (recibos_comunicar_dia).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 33,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 1/1; encontrados: `dia 5`; chaves do guião citadas no texto: `recibos_comunicar_dia`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Comunicar as faturas até ao dia 5 de cada mês (recibos_comunicar_dia).` · prazo detetado: `até`
- **(c) variante certa (BR)?** NÃO — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 1
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=1
