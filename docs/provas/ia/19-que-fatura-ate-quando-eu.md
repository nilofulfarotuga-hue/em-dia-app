# Pergunta 19 — O que é o e-fatura e até quando eu tenho que validar?

- **Data/hora:** 2026-09-06 09:29:57 (Lisboa)
- **Perfil do guião:** Cabeleireira (imigrante) · **variante esperada:** BR
- **Pergunta enviada (literal):** `O que é o e-fatura e até quando eu tenho que validar?`
- **Regras a citar (guião):** `efatura_validar_ate`
- **Esperado (guião):** Até 25 de fevereiro de cada ano, validar as faturas do ano anterior no portal e-fatura
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 22.6s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `24` · **limite_valor:** `None`

### Resposta literal

```text
O e-fatura é um site do Estado (as Finanças) onde ficam guardados os papéis de tudo o que compras. Sempre que dás o teu NIF (número de contribuinte) numa compra, essa fatura (papel da compra) vai para lá.

Tu precisas de ir a esse site para dizer o que é cada despesa (gasto de dinheiro). Tens de explicar se o gasto foi para o teu trabalho, para a tua comida ou para a escola. Fazer isto ajuda-te a pagar muito menos IRS (o imposto sobre o que ganhas) no ano seguinte.

Tens de validar (confirmar) as tuas faturas de 2026 até ao dia 25 de fevereiro de 2027 (efatura_validar_ate). Se não o fizeres, podes perder direito a descontos no imposto.

Próximo passo: Entra no site do e-fatura ou na aplicação do telemóvel para confirmares as tuas despesas até 25 de fevereiro de 2027 (efatura_validar_ate).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "O e-fatura é um site do Estado (as Finanças) onde ficam guardados os papéis de tudo o que compras. Sempre que dás o teu NIF (número de contribuinte) numa compra, essa fatura (papel da compra) vai para lá.\n\nTu precisas de ir a esse site para dizer o que é cada despesa (gasto de dinheiro). Tens de explicar se o gasto foi para o teu trabalho, para a tua comida ou para a escola. Fazer isto ajuda-te a pagar muito menos IRS (o imposto sobre o que ganhas) no ano seguinte.\n\nTens de validar (confirmar) as tuas faturas de 2026 até ao dia 25 de fevereiro de 2027 (efatura_validar_ate). Se não o fizeres, podes perder direito a descontos no imposto.\n\nPróximo passo: Entra no site do e-fatura ou na aplicação do telemóvel para confirmares as tuas despesas até 25 de fevereiro de 2027 (efatura_validar_ate).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 24,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 1/1; encontrados: `25 de fevereiro`; chaves do guião citadas no texto: `efatura_validar_ate`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Entra no site do e-fatura ou na aplicação do telemóvel para confirmares as tuas despesas até 25 de fevereiro de 2027 (efatura_validar_ate).` · prazo detetado: `até`
- **(c) variante certa (BR)?** NÃO — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 9
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=9
