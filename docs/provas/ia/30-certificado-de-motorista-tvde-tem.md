# Pergunta 30 — O certificado de motorista TVDE tem validade?

- **Data/hora:** 2026-09-06 09:33:03 (Lisboa)
- **Perfil do guião:** TVDE (brasileiro) · **variante esperada:** BR
- **Pergunta enviada (literal):** `O certificado de motorista TVDE tem validade?`
- **Regras a citar (guião):** `tvde_certificado_validade_anos`
- **Esperado (guião):** Sim, válido por 5 anos
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 1.9s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `35` · **limite_valor:** `None`

### Resposta literal

```text
Sim! O certificado de motorista TVDE vale 5 anos (tvde_certificado_validade_anos). Quando o prazo estiver a acabar, tens de o renovar no instituto dos transportes (IMT).

Próximo passo: Verifica a data em que tiraste o teu certificado e aponta a validade de 5 anos (tvde_certificado_validade_anos).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Sim! O certificado de motorista TVDE vale 5 anos (tvde_certificado_validade_anos). Quando o prazo estiver a acabar, tens de o renovar no instituto dos transportes (IMT).\n\nPróximo passo: Verifica a data em que tiraste o teu certificado e aponta a validade de 5 anos (tvde_certificado_validade_anos).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 35,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 1/1; encontrados: `5 anos`; chaves do guião citadas no texto: `tvde_certificado_validade_anos`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Verifica a data em que tiraste o teu certificado e aponta a validade de 5 anos (tvde_certificado_validade_anos).` · prazo detetado: `5 anos`
- **(c) variante certa (BR)?** NÃO — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 2
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=2
