# Pergunta 13 — Posso ficar isenta de IVA para sempre?

- **Data/hora:** 2026-09-06 09:28:31 (Lisboa)
- **Perfil do guião:** Cabeleireira · **variante esperada:** PT
- **Pergunta enviada (literal):** `Posso ficar isenta de IVA para sempre?`
- **Regras a citar (guião):** `iva_isencao_limite`, `iva_isencao_perda_imediata`
- **Esperado (guião):** Pode continuar isenta enquanto não ultrapassar 15.000 €/ano; passa a pagar IVA a partir do ano seguinte se ultrapassar esse valor, ou de imediato se ultrapassar 18.750 €
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 9.4s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `18` · **limite_valor:** `None`

### Resposta literal

```text
O IVA (o imposto que se junta aos preços) funciona como um jogo. Podes ficar isenta (sem ter de cobrar este imposto) se ganhares pouco dinheiro por ano.

Para não cobrares IVA, só podes faturar (passar recibos do teu trabalho) até 15.000 € (iva_isencao_limite) em cada ano. Se ganhares menos do que isso todos os anos, sim, podes ficar isenta para sempre!

Mas atenção: se ganhares mais de 15.000 € (iva_isencao_limite) num ano, perdes a isenção. Se passares logo os 18.750 € (iva_isencao_perda_imediata), perdes a isenção no mesmo instante.

Como tu estimas ganhar 1.500 € por mês, num ano inteiro isso daria cerca de 18.000 €. Como este valor é maior do que 15.000 € (iva_isencao_limite), o mais provável é que não consigas ficar isenta para sempre.

Próximo passo: Controla o que ganhas na app para ver se vais passar os 15.000 € (iva_isencao_limite) em 2026.
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "O IVA (o imposto que se junta aos preços) funciona como um jogo. Podes ficar isenta (sem ter de cobrar este imposto) se ganhares pouco dinheiro por ano.\n\nPara não cobrares IVA, só podes faturar (passar recibos do teu trabalho) até 15.000 € (iva_isencao_limite) em cada ano. Se ganhares menos do que isso todos os anos, sim, podes ficar isenta para sempre!\n\nMas atenção: se ganhares mais de 15.000 € (iva_isencao_limite) num ano, perdes a isenção. Se passares logo os 18.750 € (iva_isencao_perda_imediata), perdes a isenção no mesmo instante.\n\nComo tu estimas ganhar 1.500 € por mês, num ano inteiro isso daria cerca de 18.000 €. Como este valor é maior do que 15.000 € (iva_isencao_limite), o mais provável é que não consigas ficar isenta para sempre.\n\nPróximo passo: Controla o que ganhas na app para ver se vais passar os 15.000 € (iva_isencao_limite) em 2026.\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 18,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 2/2; encontrados: `15.000`, `18.750`; chaves do guião citadas no texto: `iva_isencao_limite`, `iva_isencao_perda_imediata`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Controla o que ganhas na app para ver se vais passar os 15.000 € (iva_isencao_limite) em 2026.` · prazo detetado: `em 2026`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 5
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **PASSA**
