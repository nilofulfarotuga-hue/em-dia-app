# Pergunta 09 — O que é o M10 no recibo?

- **Data/hora:** 2026-09-06 09:27:37 (Lisboa)
- **Perfil do guião:** Cabeleireira · **variante esperada:** PT
- **Pergunta enviada (literal):** `O que é o M10 no recibo?`
- **Regras a citar (guião):** `iva_mencao_isencao`
- **Esperado (guião):** É a menção obrigatória no recibo verde de quem está isento de IVA: "IVA - regime de isenção [artigo 53.º do CIVA] (M10)"
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 2 · duração da última: 2.4s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `14` · **limite_valor:** `None`

### Resposta literal

```text
O **M10** é uma opção que escolhes ao passar o recibo verde. 

Serve para dizer às Finanças que estás livre de cobrar IVA (o imposto que se junta ao preço). Mostra a frase: "IVA - regime de isenção [artigo 53.º do CIVA] (M10)" (iva_mencao_isencao).

Podes usar o M10 se faturares menos de 15.000 € por ano (iva_isencao_limite). Como tens o regime de isenção do artigo 53.º no teu perfil, não precisas de cobrar IVA aos teus clientes nem de o entregar ao Estado.

Próximo passo: Escolhe a opção M10 sempre que passares um recibo verde, até ao limite de 15.000 € no ano (iva_isencao_limite).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "O **M10** é uma opção que escolhes ao passar o recibo verde. \n\nServe para dizer às Finanças que estás livre de cobrar IVA (o imposto que se junta ao preço). Mostra a frase: \"IVA - regime de isenção [artigo 53.º do CIVA] (M10)\" (iva_mencao_isencao).\n\nPodes usar o M10 se faturares menos de 15.000 € por ano (iva_isencao_limite). Como tens o regime de isenção do artigo 53.º no teu perfil, não precisas de cobrar IVA aos teus clientes nem de o entregar ao Estado.\n\nPróximo passo: Escolhe a opção M10 sempre que passares um recibo verde, até ao limite de 15.000 € no ano (iva_isencao_limite).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 14,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 2/2; encontrados: `M10`, `artigo 53`; chaves do guião citadas no texto: `iva_mencao_isencao`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Escolhe a opção M10 sempre que passares um recibo verde, até ao limite de 15.000 € no ano (iva_isencao_limite).` · prazo detetado: `até`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 5
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **PASSA**
