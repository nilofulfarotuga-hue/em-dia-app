# Pergunta 24 — Meu seguro do carro vence quando, e quando recebo aviso?

- **Data/hora:** 2026-09-06 09:31:53 (Lisboa)
- **Perfil do guião:** Só-carro (brasileiro) · **variante esperada:** BR
- **Pergunta enviada (literal):** `Meu seguro do carro vence quando, e quando recebo aviso?`
- **Regras a citar (guião):** `seguro_aviso_dias`
- **Esperado (guião):** O aviso chega 45 dias antes da renovação, para dar tempo de comparar preços
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 2 · duração da última: 2.4s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `29` · **limite_valor:** `None`

### Resposta literal

```text
O teu seguro renova a 15 de maio de 2027. A app avisa-te 45 dias antes (seguro_aviso_dias). É nessa altura que deves comparar preços!

Próximo passo: Comparar preços de seguros a 45 dias da data de renovação (15 de maio de 2027).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "O teu seguro renova a 15 de maio de 2027. A app avisa-te 45 dias antes (seguro_aviso_dias). É nessa altura que deves comparar preços!\n\nPróximo passo: Comparar preços de seguros a 45 dias da data de renovação (15 de maio de 2027).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 29,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 1/1; encontrados: `45 dias`; chaves do guião citadas no texto: `seguro_aviso_dias`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Comparar preços de seguros a 45 dias da data de renovação (15 de maio de 2027).` · prazo detetado: `45 dias`
- **(c) variante certa (BR)?** NÃO — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 2
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=2
