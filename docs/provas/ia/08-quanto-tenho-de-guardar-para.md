# Pergunta 08 — Quanto tenho de guardar para o IRS?

- **Data/hora:** 2026-09-06 09:27:32 (Lisboa)
- **Perfil do guião:** Estafeta · **variante esperada:** PT
- **Pergunta enviada (literal):** `Quanto tenho de guardar para o IRS?`
- **Regras a citar (guião):** `irs_coef_servicos`, `irs_minimo_existencia`
- **Esperado (guião):** No regime simplificado só 75% do que recebe de serviços conta para o rendimento coletável; até 12.880 €/ano de rendimento líquido não paga IRS (mínimo de existência); acima disso aplica-se o escalão correspondente
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 2.6s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `13` · **limite_valor:** `None`

### Resposta literal

```text
Para o IRS (o imposto sobre o que ganhas), as Finanças contam apenas 75% do dinheiro dos teus serviços no regime simplificado (irs_coef_servicos). 

Nos recibos verdes, a retenção na fonte padrão (a parte que fica logo guardada como um adiantamento) é de 23% (retencao_padrao). Se escolheres essa opção, o teu cliente entrega esse valor diretamente às Finanças por ti.

Se não fizeres retenção ou quiseres estar seguro, guarda cerca de 23% (retencao_padrao) do que recebes todos os meses para não teres surpresas mais tarde. Além disso, se o teu rendimento anual líquido for até 12.880 € (irs_minimo_existencia), não pagas IRS.

Atenção: tens também pagamentos por conta pendentes (adiantamentos de IRS em 3 vezes), calculados em 65% (irs_pagamentos_conta_pct).

Próximo passo: Pagar o próximo pagamento por conta de IRS até 20 de setembro de 2026 (irs_pagamentos_conta_datas).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Para o IRS (o imposto sobre o que ganhas), as Finanças contam apenas 75% do dinheiro dos teus serviços no regime simplificado (irs_coef_servicos). \n\nNos recibos verdes, a retenção na fonte padrão (a parte que fica logo guardada como um adiantamento) é de 23% (retencao_padrao). Se escolheres essa opção, o teu cliente entrega esse valor diretamente às Finanças por ti.\n\nSe não fizeres retenção ou quiseres estar seguro, guarda cerca de 23% (retencao_padrao) do que recebes todos os meses para não teres surpresas mais tarde. Além disso, se o teu rendimento anual líquido for até 12.880 € (irs_minimo_existencia), não pagas IRS.\n\nAtenção: tens também pagamentos por conta pendentes (adiantamentos de IRS em 3 vezes), calculados em 65% (irs_pagamentos_conta_pct).\n\nPróximo passo: Pagar o próximo pagamento por conta de IRS até 20 de setembro de 2026 (irs_pagamentos_conta_datas).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 13,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 2/2; encontrados: `75%`, `12.880`; chaves do guião citadas no texto: `irs_coef_servicos`, `irs_minimo_existencia`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Pagar o próximo pagamento por conta de IRS até 20 de setembro de 2026 (irs_pagamentos_conta_datas).` · prazo detetado: `até`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 4
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **PASSA**
