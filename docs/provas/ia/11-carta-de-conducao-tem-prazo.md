# Pergunta 11 — A carta de condução tem prazo de validade?

- **Data/hora:** 2026-09-06 09:28:13 (Lisboa)
- **Perfil do guião:** Só-carro · **variante esperada:** PT
- **Pergunta enviada (literal):** `A carta de condução tem prazo de validade?`
- **Regras a citar (guião):** `carta_validade`
- **Esperado (guião):** Sim: 15 anos até aos 60 anos; depois 5 anos até aos 70; a partir dos 70, renova-se a cada 2 anos
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 2.6s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `16` · **limite_valor:** `None`

### Resposta literal

```text
Sim, a carta de condução tem prazo e tens de a renovar (voltar a pedir no IMT, o instituto dos transportes).

O tempo de validade depende da tua idade (carta_validade):
- Até aos 60 anos: é válida por 15 anos.
- Dos 60 aos 70 anos: é válida por 5 anos.
- Depois dos 70 anos: é válida por 2 anos.

Tem atenção à data que está escrita no teu documento para renovares antes de caducar.

Próximo passo: confirma a data de validade na tua carta de condução e renova no IMT antes dessa data (carta_validade).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Sim, a carta de condução tem prazo e tens de a renovar (voltar a pedir no IMT, o instituto dos transportes).\n\nO tempo de validade depende da tua idade (carta_validade):\n- Até aos 60 anos: é válida por 15 anos.\n- Dos 60 aos 70 anos: é válida por 5 anos.\n- Depois dos 70 anos: é válida por 2 anos.\n\nTem atenção à data que está escrita no teu documento para renovares antes de caducar.\n\nPróximo passo: confirma a data de validade na tua carta de condução e renova no IMT antes dessa data (carta_validade).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 16,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 3/3; encontrados: `15 anos`, `5 anos`, `2 anos`; chaves do guião citadas no texto: `carta_validade`
- **(b) termina com "Próximo passo:" e prazo/data?** NÃO — linha: `Próximo passo: confirma a data de validade na tua carta de condução e renova no IMT antes dessa data (carta_validade).` · prazo detetado: `—`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 4
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (b) o "Próximo passo:" não tem prazo/data
