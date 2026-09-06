# Pergunta 12 — O que acontece se não pagar a Segurança Social a tempo?

- **Data/hora:** 2026-09-06 09:28:18 (Lisboa)
- **Perfil do guião:** TVDE · **variante esperada:** PT
- **Pergunta enviada (literal):** `O que acontece se não pagar a Segurança Social a tempo?`
- **Regras a citar (guião):** `ss_pagamento_dia_inicio`, `ss_pagamento_dia_fim`
- **Esperado (guião):** Cita só o prazo confirmado (pagamento entre dia 10 e 20); a app não tem confirmado o valor dos juros/coima em atraso — resposta esperada inclui "não tenho essa regra confirmada" para o valor da penalização
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 9.3s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `17` · **limite_valor:** `None`

### Resposta literal

```text
Se não pagares a Segurança Social a tempo, ficas com uma dívida. Além disso, vais ter de pagar um bocadinho mais de dinheiro. Esse valor extra chama-se juros de mora (uma multa pequena por pagares fora do prazo).

Deves pagar sempre as tuas contribuições entre o dia 10 (ss_pagamento_dia_inicio) e o dia 20 (ss_pagamento_dia_fim) de cada mês. 

Como abriste atividade há pouco tempo, ainda tens isenção (estás livre de pagar). Esta ajuda dura 12 primeiros meses (ss_isencao_meses) e só termina no dia 2027-03-01 (ss_isencao_meses). Por isso, até lá não tens de pagar esta contribuição mensal.

Se no futuro te atrasares num pagamento, entra logo no site da Segurança Social Direta e paga o mais rápido possível para os juros não crescerem.

Próximo passo: Aponta na agenda o fim da tua isenção a 2027-03-01 (ss_isencao_meses).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Se não pagares a Segurança Social a tempo, ficas com uma dívida. Além disso, vais ter de pagar um bocadinho mais de dinheiro. Esse valor extra chama-se juros de mora (uma multa pequena por pagares fora do prazo).\n\nDeves pagar sempre as tuas contribuições entre o dia 10 (ss_pagamento_dia_inicio) e o dia 20 (ss_pagamento_dia_fim) de cada mês. \n\nComo abriste atividade há pouco tempo, ainda tens isenção (estás livre de pagar). Esta ajuda dura 12 primeiros meses (ss_isencao_meses) e só termina no dia 2027-03-01 (ss_isencao_meses). Por isso, até lá não tens de pagar esta contribuição mensal.\n\nSe no futuro te atrasares num pagamento, entra logo no site da Segurança Social Direta e paga o mais rápido possível para os juros não crescerem.\n\nPróximo passo: Aponta na agenda o fim da tua isenção a 2027-03-01 (ss_isencao_meses).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 17,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** NÃO — grupos encontrados 1/2; encontrados: `dia 10`; **em falta:** não tenho essa regra confirmada; chaves do guião citadas no texto: `ss_pagamento_dia_inicio`, `ss_pagamento_dia_fim`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Aponta na agenda o fim da tua isenção a 2027-03-01 (ss_isencao_meses).` · prazo detetado: `2027-03-01`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 8
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (a) faltam valores esperados: não tenho essa regra confirmada
