# Pergunta 02 — Passei os 15 mil [de faturação este ano], e agora?

- **Data/hora:** 2026-09-06 09:26:22 (Lisboa)
- **Perfil do guião:** TVDE · **variante esperada:** PT
- **Pergunta enviada (literal):** `Passei os 15 mil, e agora?`
- **Regras a citar (guião):** `iva_isencao_limite`, `iva_isencao_perda_imediata`, `iva_isencao_comunicacao_dias_uteis`
- **Esperado (guião):** Entre 15.000 € e 18.750 €: cobra IVA a partir de 1 de janeiro do ano seguinte. Acima de 18.750 €: perde a isenção de imediato (a fatura seguinte já leva 23% de IVA) e tem de comunicar às Finanças em 15 dias úteis (confere com C08/C09)
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 2.7s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `7` · **limite_valor:** `None`

### Resposta literal

```text
Quando passas o limite de 15.000 € (iva_isencao_limite) num ano, perdes a isenção de IVA (o imposto que se soma ao preço).

O que acontece agora:
1. **Avisar as Finanças:** Tens 15 dias úteis (iva_isencao_comunicacao_dias_uteis) para entregar a declaração de alterações no Portal das Finanças.
2. **Cobrar IVA:** Passas a cobrar 23% (iva_taxa_normal) a mais aos teus clientes. Se passares logo os 18.750 € (iva_isencao_perda_imediata), a fatura seguinte tem logo de levar IVA. Esse dinheiro não é teu, guardas para dar ao Estado.
3. **Entregar o IVA:** De 3 em 3 meses, entregas a declaração até ao dia 20 (iva_declaracao_trimestral_dia) e pagas o IVA até ao dia 25 (iva_pagamento_dia) do segundo mês a seguir ao trimestre.

Próximo passo: Entregar a declaração de alterações no Portal das Finanças no prazo de 15 dias úteis (iva_isencao_comunicacao_dias_uteis).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Quando passas o limite de 15.000 € (iva_isencao_limite) num ano, perdes a isenção de IVA (o imposto que se soma ao preço).\n\nO que acontece agora:\n1. **Avisar as Finanças:** Tens 15 dias úteis (iva_isencao_comunicacao_dias_uteis) para entregar a declaração de alterações no Portal das Finanças.\n2. **Cobrar IVA:** Passas a cobrar 23% (iva_taxa_normal) a mais aos teus clientes. Se passares logo os 18.750 € (iva_isencao_perda_imediata), a fatura seguinte tem logo de levar IVA. Esse dinheiro não é teu, guardas para dar ao Estado.\n3. **Entregar o IVA:** De 3 em 3 meses, entregas a declaração até ao dia 20 (iva_declaracao_trimestral_dia) e pagas o IVA até ao dia 25 (iva_pagamento_dia) do segundo mês a seguir ao trimestre.\n\nPróximo passo: Entregar a declaração de alterações no Portal das Finanças no prazo de 15 dias úteis (iva_isencao_comunicacao_dias_uteis).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 7,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 4/4; encontrados: `15.000`, `18.750`, `15 dias úteis`, `23%`; chaves do guião citadas no texto: `iva_isencao_limite`, `iva_isencao_perda_imediata`, `iva_isencao_comunicacao_dias_uteis`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Entregar a declaração de alterações no Portal das Finanças no prazo de 15 dias úteis (iva_isencao_comunicacao_dias_uteis).` · prazo detetado: `15 dias úteis`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 3
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **PASSA**
