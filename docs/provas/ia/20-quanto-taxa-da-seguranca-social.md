# Pergunta 20 — Quanto é a taxa da Segurança Social pra mim?

- **Data/hora:** 2026-09-06 09:30:22 (Lisboa)
- **Perfil do guião:** TVDE (brasileiro) · **variante esperada:** BR
- **Pergunta enviada (literal):** `Quanto é a taxa da Segurança Social pra mim?`
- **Regras a citar (guião):** `ss_taxa`, `ss_base_servicos`
- **Esperado (guião):** 21,4% sobre 70% do rendimento trimestral de serviços (a base de incidência)
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 16.8s

## Resposta — HTTP 200

- **variante detetada:** `br` · **fora_das_regras:** `False` · **usadas:** `25` · **limite_valor:** `None`

### Resposta literal

```text
Oi! A taxa que você vai pagar para a Segurança Social (o cofrinho do governo para te ajudar quando ficar velhinho ou se ficar doente) é de 21,4% (ss_taxa). 

Mas tenho uma notícia muito boa para você! Como você abriu a sua atividade em março de 2026, você tem direito a ficar 12 meses (ss_isencao_meses) sem pagar nada. Isso se chama isenção (tempo livre de pagamentos).

Você só vai começar a pagar essa taxa de 21,4% (ss_taxa) a partir do dia 1 de março de 2027 (fim_isencao_ss). Até lá, você não precisa se preocupar com esse pagamento no seu celular, tá? 

Quando esse tempo acabar, a taxa vai ser aplicada sobre uma parte do que você ganha com o seu trabalho de TVDE.

Próximo passo: Aproveitar a sua isenção de pagamentos até 1 de março de 2027 (fim_isencao_ss).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Oi! A taxa que você vai pagar para a Segurança Social (o cofrinho do governo para te ajudar quando ficar velhinho ou se ficar doente) é de 21,4% (ss_taxa). \n\nMas tenho uma notícia muito boa para você! Como você abriu a sua atividade em março de 2026, você tem direito a ficar 12 meses (ss_isencao_meses) sem pagar nada. Isso se chama isenção (tempo livre de pagamentos).\n\nVocê só vai começar a pagar essa taxa de 21,4% (ss_taxa) a partir do dia 1 de março de 2027 (fim_isencao_ss). Até lá, você não precisa se preocupar com esse pagamento no seu celular, tá? \n\nQuando esse tempo acabar, a taxa vai ser aplicada sobre uma parte do que você ganha com o seu trabalho de TVDE.\n\nPróximo passo: Aproveitar a sua isenção de pagamentos até 1 de março de 2027 (fim_isencao_ss).\nInformação geral, não substitui contabilista.",
  "variante": "br",
  "fora_das_regras": false,
  "usadas": 25,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** NÃO — grupos encontrados 1/2; encontrados: `21,4%`; **em falta:** 70\s?% / ss_base_servicos; chaves do guião citadas no texto: `ss_taxa`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Aproveitar a sua isenção de pagamentos até 1 de março de 2027 (fim_isencao_ss).` · prazo detetado: `até`
- **(c) variante certa (BR)?** sim — API: `br` · "você" no texto: True · marcas de "tu" (tens/teu/podes…): 0
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (a) faltam valores esperados: 70\s?% / ss_base_servicos
