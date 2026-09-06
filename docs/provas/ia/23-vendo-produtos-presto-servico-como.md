# Pergunta 23 — Vendo produtos e presto serviço, como calculo o IRS?

- **Data/hora:** 2026-09-06 09:31:24 (Lisboa)
- **Perfil do guião:** Cabeleireira (brasileira) · **variante esperada:** BR
- **Pergunta enviada (literal):** `Vendo produtos e presto serviço, como calculo o IRS?`
- **Regras a citar (guião):** `irs_coef_servicos`, `irs_coef_vendas`
- **Esperado (guião):** 75% do que recebe de serviços conta como rendimento; só 15% do que recebe de venda de produtos conta; soma-se os dois valores para chegar ao rendimento coletável
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 26.2s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `28` · **limite_valor:** `None`

### Resposta literal

```text
No regime simplificado (onde as Finanças fazem as contas de forma fácil), o IRS é calculado com base no que ganhas. Mas as Finanças não contam o dinheiro todo.

Para os serviços, elas acham que o teu lucro é de 75% (irs_coef_servicos) do que ganhaste. 

Para a venda de produtos, elas acham que o teu lucro é de apenas 15% (irs_coef_vendas) do que vendeste.

O imposto (IRS) é cobrado sobre essa soma de lucros. Se o teu rendimento final for muito pequenino, até 12.880 € (irs_minimo_existencia), podes não pagar nada de imposto.

Próximo passo: Valida as tuas faturas no e-fatura até 25 de fevereiro (efatura_validar_ate).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "No regime simplificado (onde as Finanças fazem as contas de forma fácil), o IRS é calculado com base no que ganhas. Mas as Finanças não contam o dinheiro todo.\n\nPara os serviços, elas acham que o teu lucro é de 75% (irs_coef_servicos) do que ganhaste. \n\nPara a venda de produtos, elas acham que o teu lucro é de apenas 15% (irs_coef_vendas) do que vendeste.\n\nO imposto (IRS) é cobrado sobre essa soma de lucros. Se o teu rendimento final for muito pequenino, até 12.880 € (irs_minimo_existencia), podes não pagar nada de imposto.\n\nPróximo passo: Valida as tuas faturas no e-fatura até 25 de fevereiro (efatura_validar_ate).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 28,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 2/2; encontrados: `75%`, `15%`; chaves do guião citadas no texto: `irs_coef_servicos`, `irs_coef_vendas`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Valida as tuas faturas no e-fatura até 25 de fevereiro (efatura_validar_ate).` · prazo detetado: `até`
- **(c) variante certa (BR)?** NÃO — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 5
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=5
