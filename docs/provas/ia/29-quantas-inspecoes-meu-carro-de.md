# Pergunta 29 — Quantas inspeções meu carro de 2018 já teve?

- **Data/hora:** 2026-09-06 09:32:41 (Lisboa)
- **Perfil do guião:** Só-carro (brasileiro) · **variante esperada:** BR
- **Pergunta enviada (literal):** `Quantas inspeções meu carro de 2018 já teve?`
- **Regras a citar (guião):** `ipo_ligeiros_anos`, `ipo_apos_8_anos`
- **Esperado (guião):** Já passou pelas inspeções de 4 anos (2022) e 6 anos (2024); em 2026 (8 anos) tem a terceira, e a partir daí passa a ser todos os anos
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 19.5s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `True` · **usadas:** `34` · **limite_valor:** `None`

### Resposta literal

```text
Como trabalhas como TVDE, as regras para as inspeções do teu carro podem ser diferentes das de um carro normal. A regra sobre a inspeção anual para carros TVDE (ipo_tvde) ainda não está confirmada na minha aplicação.

Não tenho essa regra confirmada. Sugiro que fales com um contabilista para te ajudar a saber tudo sobre as inspeções do teu carro de trabalho.

Próximo passo: Fala com um contabilista para confirmar as regras de inspeção do teu carro TVDE o quanto antes.
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Como trabalhas como TVDE, as regras para as inspeções do teu carro podem ser diferentes das de um carro normal. A regra sobre a inspeção anual para carros TVDE (ipo_tvde) ainda não está confirmada na minha aplicação.\n\nNão tenho essa regra confirmada. Sugiro que fales com um contabilista para te ajudar a saber tudo sobre as inspeções do teu carro de trabalho.\n\nPróximo passo: Fala com um contabilista para confirmar as regras de inspeção do teu carro TVDE o quanto antes.\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": true,
  "usadas": 34,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** NÃO — grupos encontrados 1/4; encontrados: `anual`; **em falta:** 2022; 2024; 2026; chaves do guião citadas no texto: nenhuma
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Fala com um contabilista para confirmar as regras de inspeção do teu carro TVDE o quanto antes.` · prazo detetado: `quanto antes`
- **(c) variante certa (BR)?** NÃO — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 3
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (a) faltam valores esperados: 2022; 2024; 2026
- (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=3
