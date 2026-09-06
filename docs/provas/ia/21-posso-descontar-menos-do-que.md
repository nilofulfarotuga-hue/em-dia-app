# Pergunta 21 — Posso descontar menos do que o valor cheio?

- **Data/hora:** 2026-09-06 09:30:42 (Lisboa)
- **Perfil do guião:** Estafeta (brasileira) · **variante esperada:** BR
- **Pergunta enviada (literal):** `Posso descontar menos do que o valor cheio?`
- **Regras a citar (guião):** `ss_ajuste_max`, `ss_minimo_mensal`
- **Esperado (guião):** Sim, pode pedir até 25% a menos na declaração trimestral, respeitando o mínimo de 20 €/mês
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 15.5s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `26` · **limite_valor:** `None`

### Resposta literal

```text
Sim, podes! 

Quando fazes a tua declaração na Segurança Social (o grande mealheiro do Estado), podes pedir para pagar um bocadinho menos. 

A lei deixa-te escolher pagar até 25% (ss_ajuste_max) a menos do que o valor normal. Também podes pedir para pagar mais, se quiseres guardar mais dinheiro para quando fores velhinho. 

Mas atenção: se escolheres pagar menos agora, quando ficares doente ou quando te reformares (deixares de trabalhar por seres velhinho), a ajuda que vais receber do Estado também vai ser mais pequena. 

Podes fazer esta escolha de três em três meses, quando envias a tua declaração trimestral (ss_declaracao_meses).

Próximo passo: Podes pedir este ajuste na tua próxima declaração trimestral até 2027-04-30 (ss_declaracao_meses).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Sim, podes! \n\nQuando fazes a tua declaração na Segurança Social (o grande mealheiro do Estado), podes pedir para pagar um bocadinho menos. \n\nA lei deixa-te escolher pagar até 25% (ss_ajuste_max) a menos do que o valor normal. Também podes pedir para pagar mais, se quiseres guardar mais dinheiro para quando fores velhinho. \n\nMas atenção: se escolheres pagar menos agora, quando ficares doente ou quando te reformares (deixares de trabalhar por seres velhinho), a ajuda que vais receber do Estado também vai ser mais pequena. \n\nPodes fazer esta escolha de três em três meses, quando envias a tua declaração trimestral (ss_declaracao_meses).\n\nPróximo passo: Podes pedir este ajuste na tua próxima declaração trimestral até 2027-04-30 (ss_declaracao_meses).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 26,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** NÃO — grupos encontrados 1/2; encontrados: `25%`; **em falta:** 20\s?€ / 20 euros / ss_minimo_mensal; chaves do guião citadas no texto: `ss_ajuste_max`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Podes pedir este ajuste na tua próxima declaração trimestral até 2027-04-30 (ss_declaracao_meses).` · prazo detetado: `até`
- **(c) variante certa (BR)?** NÃO — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 9
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (a) faltam valores esperados: 20\s?€ / 20 euros / ss_minimo_mensal
- (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=9
