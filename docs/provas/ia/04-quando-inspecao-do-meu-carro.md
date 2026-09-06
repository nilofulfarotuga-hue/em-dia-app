# Pergunta 04 — Quando é a inspeção do meu carro de 2021?

- **Data/hora:** 2026-09-06 09:26:34 (Lisboa)
- **Perfil do guião:** Só-carro · **variante esperada:** PT
- **Pergunta enviada (literal):** `Quando é a inspeção do meu carro de 2021?`
- **Regras a citar (guião):** `ipo_ligeiros_anos`, `ipo_avisos_dias`
- **Esperado (guião):** 1.ª inspeção aos 4 anos (2025), 2.ª aos 6 anos (2027), 3.ª aos 8 anos (2029), depois todos os anos; aviso 30 e 7 dias antes (confere com C28)
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 2.7s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `True` · **usadas:** `9` · **limite_valor:** `None`

### Resposta literal

```text
A inspeção periódica (IPO, o exame obrigatório ao carro) para carros ligeiros normais é feita aos 4, 6 e 8 anos da matrícula (ipo_ligeiros_anos). Depois dos 8 anos, passa a ser anual (ipo_apos_8_anos).

Como o teu carro (matrícula AA-11-BB) foi matriculado em 2021-02-28, a inspeção aos 6 anos calha até ao dia 2027-02-28 (ipo_ligeiros_anos).

Atenção: se o carro for usado para a atividade de TVDE, a regra de inspeção anual para TVDE (ipo_tvde) não está confirmada: Não tenho essa regra confirmada. Sugiro que fales com um contabilista ou confirmes no IMT.

A app vai avisar-te 30 dias e 7 dias antes do prazo terminar (ipo_avisos_dias).

Próximo passo: Fazer a inspeção periódica do carro AA-11-BB até 2027-02-28 (ipo_ligeiros_anos).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "A inspeção periódica (IPO, o exame obrigatório ao carro) para carros ligeiros normais é feita aos 4, 6 e 8 anos da matrícula (ipo_ligeiros_anos). Depois dos 8 anos, passa a ser anual (ipo_apos_8_anos).\n\nComo o teu carro (matrícula AA-11-BB) foi matriculado em 2021-02-28, a inspeção aos 6 anos calha até ao dia 2027-02-28 (ipo_ligeiros_anos).\n\nAtenção: se o carro for usado para a atividade de TVDE, a regra de inspeção anual para TVDE (ipo_tvde) não está confirmada: Não tenho essa regra confirmada. Sugiro que fales com um contabilista ou confirmes no IMT.\n\nA app vai avisar-te 30 dias e 7 dias antes do prazo terminar (ipo_avisos_dias).\n\nPróximo passo: Fazer a inspeção periódica do carro AA-11-BB até 2027-02-28 (ipo_ligeiros_anos).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": true,
  "usadas": 9,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 3/3; encontrados: `ipo_ligeiros_anos`, `2027`, `30 dias`; chaves do guião citadas no texto: `ipo_ligeiros_anos`, `ipo_avisos_dias`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Fazer a inspeção periódica do carro AA-11-BB até 2027-02-28 (ipo_ligeiros_anos).` · prazo detetado: `até`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 1
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **PASSA**
