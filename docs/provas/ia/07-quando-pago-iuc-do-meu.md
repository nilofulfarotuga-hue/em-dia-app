# Pergunta 07 — Quando pago o IUC do meu carro?

- **Data/hora:** 2026-09-06 09:27:21 (Lisboa)
- **Perfil do guião:** TVDE · **variante esperada:** PT
- **Pergunta enviada (literal):** `Quando pago o IUC do meu carro?`
- **Regras a citar (guião):** `iuc_regra`
- **Esperado (guião):** Todos os anos, até ao fim do mês da matrícula do carro
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 7.7s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `12` · **limite_valor:** `None`

### Resposta literal

```text
O IUC (imposto do carro) é como uma moedinha que dás ao Estado para o teu carro poder andar na estrada. 

Este imposto paga-se todos os anos. Tens de o pagar sempre até ao fim do mês em que o teu carro "faz anos", ou seja, no mês da matrícula do teu carro (iuc_regra). 

Como o teu carro tem matrícula do dia 28 de fevereiro, tens de pagar o IUC sempre até ao fim do mês de fevereiro (iuc_regra). No teu caso, o próximo pagamento será até ao dia 28 de fevereiro de 2027 (iuc_regra).

Podes tirar o papel para pagar no site do Portal das Finanças. Se te atrasares, podes ter de pagar uma multa.

Próximo passo: Pagar o IUC do carro AA-11-BB até 28 de fevereiro de 2027 (iuc_regra).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "O IUC (imposto do carro) é como uma moedinha que dás ao Estado para o teu carro poder andar na estrada. \n\nEste imposto paga-se todos os anos. Tens de o pagar sempre até ao fim do mês em que o teu carro \"faz anos\", ou seja, no mês da matrícula do teu carro (iuc_regra). \n\nComo o teu carro tem matrícula do dia 28 de fevereiro, tens de pagar o IUC sempre até ao fim do mês de fevereiro (iuc_regra). No teu caso, o próximo pagamento será até ao dia 28 de fevereiro de 2027 (iuc_regra).\n\nPodes tirar o papel para pagar no site do Portal das Finanças. Se te atrasares, podes ter de pagar uma multa.\n\nPróximo passo: Pagar o IUC do carro AA-11-BB até 28 de fevereiro de 2027 (iuc_regra).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 12,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 1/1; encontrados: `mês da matrícula`; chaves do guião citadas no texto: `iuc_regra`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Pagar o IUC do carro AA-11-BB até 28 de fevereiro de 2027 (iuc_regra).` · prazo detetado: `até`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 9
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **PASSA**
