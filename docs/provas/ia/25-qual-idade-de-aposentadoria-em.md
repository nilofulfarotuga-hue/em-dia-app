# Pergunta 25 — Qual é a idade de aposentadoria em Portugal?

- **Data/hora:** 2026-09-06 09:32:20 (Lisboa)
- **Perfil do guião:** TVDE (brasileiro) · **variante esperada:** BR
- **Pergunta enviada (literal):** `Qual é a idade de aposentadoria em Portugal?`
- **Regras a citar (guião):** `reforma_idade`, `reforma_carreira_minima_anos`
- **Esperado (guião):** 66 anos e 9 meses em 2026, com carreira contributiva mínima de 15 anos
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 2.5s

## Resposta — HTTP 200

- **variante detetada:** `br` · **fora_das_regras:** `False` · **usadas:** `30` · **limite_valor:** `None`

### Resposta literal

```text
Oi! 

A idade normal para a reforma (aposentadoria) em Portugal é de 66,75 anos (reforma_idade). 

Para ter direito à pensão, você precisa ter descontado por pelo menos 15 anos (reforma_carreira_minima_anos). 

Próximo passo: continuar descontando para juntar os anos necessários. Prazo: até atingir a idade da reforma.

Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Oi! \n\nA idade normal para a reforma (aposentadoria) em Portugal é de 66,75 anos (reforma_idade). \n\nPara ter direito à pensão, você precisa ter descontado por pelo menos 15 anos (reforma_carreira_minima_anos). \n\nPróximo passo: continuar descontando para juntar os anos necessários. Prazo: até atingir a idade da reforma.\n\nInformação geral, não substitui contabilista.",
  "variante": "br",
  "fora_das_regras": false,
  "usadas": 30,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 2/2; encontrados: `66,75`, `15 anos`; chaves do guião citadas no texto: `reforma_idade`, `reforma_carreira_minima_anos`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: continuar descontando para juntar os anos necessários. Prazo: até atingir a idade da reforma.` · prazo detetado: `até`
- **(c) variante certa (BR)?** sim — API: `br` · "você" no texto: True · marcas de "tu" (tens/teu/podes…): 0
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **PASSA**
