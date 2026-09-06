# Pergunta 06 — Qual é a diferença entre a retenção de 23% e a de 25%?

- **Data/hora:** 2026-09-06 09:26:46 (Lisboa)
- **Perfil do guião:** Freelancer · **variante esperada:** PT
- **Pergunta enviada (literal):** `Qual é a diferença entre a retenção de 23% e a de 25%?`
- **Regras a citar (guião):** `retencao_padrao`, `retencao_opcao`
- **Esperado (guião):** 23% é a retenção padrão (desde 2025); 25% é uma opção do próprio prestador, para reter mais e sobrar menos para pagar no IRS final
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 2 · duração da última: 9.2s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `11` · **limite_valor:** `None`

### Resposta literal

```text
A retenção na fonte (o dinheiro que o cliente guarda para dar às Finanças por ti) é como um mealheiro para o teu IRS.

A diferença é esta:

1. **Retenção de 23%** (retencao_padrao): É a opção normal. O cliente guarda 23% do teu recibo para as Finanças e dá-te o resto.
2. **Retenção de 25%** (retencao_opcao): É uma escolha tua. O cliente guarda um bocadinho mais (25%). Assim, guardas mais dinheiro nas Finanças durante o ano. Quando chegar a altura de acertar o IRS, pagas menos ou podes até receber algum de volta.

Tu tens a opção normal de 23% ativa no teu perfil.

Próximo passo: Escolhe a taxa de retenção sempre que passares um recibo verde no Portal das Finanças.
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "A retenção na fonte (o dinheiro que o cliente guarda para dar às Finanças por ti) é como um mealheiro para o teu IRS.\n\nA diferença é esta:\n\n1. **Retenção de 23%** (retencao_padrao): É a opção normal. O cliente guarda 23% do teu recibo para as Finanças e dá-te o resto.\n2. **Retenção de 25%** (retencao_opcao): É uma escolha tua. O cliente guarda um bocadinho mais (25%). Assim, guardas mais dinheiro nas Finanças durante o ano. Quando chegar a altura de acertar o IRS, pagas menos ou podes até receber algum de volta.\n\nTu tens a opção normal de 23% ativa no teu perfil.\n\nPróximo passo: Escolhe a taxa de retenção sempre que passares um recibo verde no Portal das Finanças.\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 11,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 2/2; encontrados: `23%`, `25%`; chaves do guião citadas no texto: `retencao_padrao`, `retencao_opcao`
- **(b) termina com "Próximo passo:" e prazo/data?** NÃO — linha: `Próximo passo: Escolhe a taxa de retenção sempre que passares um recibo verde no Portal das Finanças.` · prazo detetado: `—`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 7
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (b) o "Próximo passo:" não tem prazo/data
