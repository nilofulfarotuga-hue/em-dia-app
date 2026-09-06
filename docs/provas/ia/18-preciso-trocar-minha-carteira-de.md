# Pergunta 18 — Preciso trocar minha carteira de motorista brasileira?

- **Data/hora:** 2026-09-06 09:29:34 (Lisboa)
- **Perfil do guião:** TVDE (imigrante) · **variante esperada:** BR
- **Pergunta enviada (literal):** `Preciso trocar minha carteira de motorista brasileira?`
- **Regras a citar (guião):** `troca_carta_estrangeira_prazo_anos`, `por_confirmar`
- **Esperado (guião):** Regra ainda não confirmada na app — resposta esperada: "não tenho essa regra confirmada"; o valor de referência guardado (não citável como certo) é 2 anos após fixar residência, a confirmar no IMT
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 19.8s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `True` · **usadas:** `23` · **limite_valor:** `None`

### Resposta literal

```text
A tua carta de condução (o documento que te deixa conduzir o teu carro) do Brasil pode ter de ser trocada por uma carta portuguesa para poderes conduzir em Portugal. 

Não tenho essa regra confirmada. Sugiro que fales com um contabilista para te ajudar a perceber o que deves fazer. Também podes perguntar diretamente ao IMT (o instituto público que trata das cartas e dos carros).

Próximo passo: Fala com um contabilista para confirmares se precisas de trocar a carta o quanto antes.
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "A tua carta de condução (o documento que te deixa conduzir o teu carro) do Brasil pode ter de ser trocada por uma carta portuguesa para poderes conduzir em Portugal. \n\nNão tenho essa regra confirmada. Sugiro que fales com um contabilista para te ajudar a perceber o que deves fazer. Também podes perguntar diretamente ao IMT (o instituto público que trata das cartas e dos carros).\n\nPróximo passo: Fala com um contabilista para confirmares se precisas de trocar a carta o quanto antes.\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": true,
  "usadas": 23,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 1/1; encontrados: `Não tenho essa regra confirmada`; chaves do guião citadas no texto: nenhuma
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Fala com um contabilista para confirmares se precisas de trocar a carta o quanto antes.` · prazo detetado: `quanto antes`
- **(c) variante certa (BR)?** NÃO — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 4
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=4
