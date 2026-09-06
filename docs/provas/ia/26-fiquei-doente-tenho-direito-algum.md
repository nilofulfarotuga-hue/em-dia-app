# Pergunta 26 — Fiquei doente, tenho direito a algum benefício?

- **Data/hora:** 2026-09-06 09:32:26 (Lisboa)
- **Perfil do guião:** Estafeta (brasileiro) · **variante esperada:** BR
- **Pergunta enviada (literal):** `Fiquei doente, tenho direito a algum benefício?`
- **Regras a citar (guião):** `baixa_doenca_dia_inicio`, `baixa_doenca_prazo_garantia_meses`
- **Esperado (guião):** Sim: subsídio de doença a partir do 11.º dia de baixa, desde que tenha pelo menos 6 meses de descontos
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 2.4s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `31` · **limite_valor:** `None`

### Resposta literal

```text
Sim! Podes ter dinheiro da Segurança Social se ficarem doentes. 

Mas olha: só começas a receber a partir do dia 11 da tua baixa (baixa_doenca_dia_inicio). Os primeiros 10 dias são para ti.

Além disso, tens de ter descontado pelo menos 6 meses (baixa_doenca_prazo_garantia_meses) antes de adoeceres.

Próximo passo: fala com o teu médico para pedir a baixa e confirma na Segurança Social se já tens os meses necessários, até ao 11.º dia da tua baixa (baixa_doenca_dia_inicio).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Sim! Podes ter dinheiro da Segurança Social se ficarem doentes. \n\nMas olha: só começas a receber a partir do dia 11 da tua baixa (baixa_doenca_dia_inicio). Os primeiros 10 dias são para ti.\n\nAlém disso, tens de ter descontado pelo menos 6 meses (baixa_doenca_prazo_garantia_meses) antes de adoeceres.\n\nPróximo passo: fala com o teu médico para pedir a baixa e confirma na Segurança Social se já tens os meses necessários, até ao 11.º dia da tua baixa (baixa_doenca_dia_inicio).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 31,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 2/2; encontrados: `dia 11`, `6 meses`; chaves do guião citadas no texto: `baixa_doenca_dia_inicio`, `baixa_doenca_prazo_garantia_meses`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: fala com o teu médico para pedir a baixa e confirma na Segurança Social se já tens os meses necessários, até ao 11.º dia da tua baixa (baixa_doenca_dia_inicio).` · prazo detetado: `já`
- **(c) variante certa (BR)?** NÃO — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 6
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=6
