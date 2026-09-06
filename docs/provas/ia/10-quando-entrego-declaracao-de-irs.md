# Pergunta 10 — Quando entrego a declaração de IRS?

- **Data/hora:** 2026-09-06 09:28:06 (Lisboa)
- **Perfil do guião:** Freelancer · **variante esperada:** PT
- **Pergunta enviada (literal):** `Quando entrego a declaração de IRS?`
- **Regras a citar (guião):** `irs_entrega_inicio`, `irs_entrega_fim`, `efatura_validar_ate`
- **Esperado (guião):** Entre 1 de abril e 30 de junho; antes disso, valida as faturas no e-fatura até 25 de fevereiro
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 3.9s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `15` · **limite_valor:** `None`

### Resposta literal

```text
A declaração de IRS (o papel onde dizes às Finanças tudo o que ganhaste no ano anterior) entrega-se pela internet, no Portal das Finanças.

Podes entregar a partir do dia 1 de abril (irs_entrega_inicio) até ao dia 30 de junho (irs_entrega_fim). 

Antes disso, deves confirmar e arrumar as tuas faturas no site e-fatura até 25 de fevereiro (efatura_validar_ate) para teres todos os descontos no imposto.

Próximo passo: Valida as tuas despesas no e-fatura até 25 de fevereiro (efatura_validar_ate) e entrega a tua declaração de IRS entre 1 de abril e 30 de junho (irs_entrega_fim).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "A declaração de IRS (o papel onde dizes às Finanças tudo o que ganhaste no ano anterior) entrega-se pela internet, no Portal das Finanças.\n\nPodes entregar a partir do dia 1 de abril (irs_entrega_inicio) até ao dia 30 de junho (irs_entrega_fim). \n\nAntes disso, deves confirmar e arrumar as tuas faturas no site e-fatura até 25 de fevereiro (efatura_validar_ate) para teres todos os descontos no imposto.\n\nPróximo passo: Valida as tuas despesas no e-fatura até 25 de fevereiro (efatura_validar_ate) e entrega a tua declaração de IRS entre 1 de abril e 30 de junho (irs_entrega_fim).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 15,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 3/3; encontrados: `1 de abril`, `30 de junho`, `25 de fevereiro`; chaves do guião citadas no texto: `irs_entrega_inicio`, `irs_entrega_fim`, `efatura_validar_ate`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Valida as tuas despesas no e-fatura até 25 de fevereiro (efatura_validar_ate) e entrega a tua declaração de IRS entre 1 de abril e 30 de junho (irs_entrega_fim).` · prazo detetado: `até`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 5
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **PASSA**
