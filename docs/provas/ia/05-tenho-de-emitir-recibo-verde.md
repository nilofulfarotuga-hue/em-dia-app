# Pergunta 05 — Tenho de emitir recibo verde para tudo o que recebo?

- **Data/hora:** 2026-09-06 09:26:39 (Lisboa)
- **Perfil do guião:** Cabeleireira · **variante esperada:** PT
- **Pergunta enviada (literal):** `Tenho de emitir recibo verde para tudo o que recebo?`
- **Regras a citar (guião):** `iva_mencao_isencao`, `retencao_padrao`, `retencao_dispensa_limite`
- **Esperado (guião):** Sim, todo o rendimento de serviços tem recibo verde. Se estiver isenta de IVA (< 15.000 €/ano) o recibo leva "IVA - regime de isenção [artigo 53.º do CIVA] (M10)"; a retenção de IRS é 23% (ou 25% por opção), com dispensa possível se faturou menos de 15.000 € no ano anterior
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 4.1s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `10` · **limite_valor:** `None`

### Resposta literal

```text
Sim! Sempre que fazes um trabalho e recebes dinheiro pelo teu serviço (como no TVDE), tens de passar um recibo verde no Portal das Finanças. 

O recibo verde serve para mostrar às Finanças o que ganhaste.

Como estás no regime de isenção de IVA até 15.000 € (iva_isencao_limite), em cada recibo deves escolher a opção com o código M10, que diz "IVA - regime de isenção [artigo 53.º do CIVA] (M10)" (iva_mencao_isencao). Assim não cobras IVA ao cliente.

Na retenção na fonte (o adiantamento do IRS que fica guardado), a tua regra padrão é descontar 23% (retencao_padrao), se o cliente tiver contabilidade organizada (uma empresa).

Lembra-te: passa sempre o recibo a quem te paga pelo teu trabalho.

Próximo passo: Passa o recibo verde no Portal das Finanças logo após receberes o pagamento do teu serviço.
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Sim! Sempre que fazes um trabalho e recebes dinheiro pelo teu serviço (como no TVDE), tens de passar um recibo verde no Portal das Finanças. \n\nO recibo verde serve para mostrar às Finanças o que ganhaste.\n\nComo estás no regime de isenção de IVA até 15.000 € (iva_isencao_limite), em cada recibo deves escolher a opção com o código M10, que diz \"IVA - regime de isenção [artigo 53.º do CIVA] (M10)\" (iva_mencao_isencao). Assim não cobras IVA ao cliente.\n\nNa retenção na fonte (o adiantamento do IRS que fica guardado), a tua regra padrão é descontar 23% (retencao_padrao), se o cliente tiver contabilidade organizada (uma empresa).\n\nLembra-te: passa sempre o recibo a quem te paga pelo teu trabalho.\n\nPróximo passo: Passa o recibo verde no Portal das Finanças logo após receberes o pagamento do teu serviço.\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 10,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 3/3; encontrados: `M10`, `23%`, `15.000`; chaves do guião citadas no texto: `iva_mencao_isencao`, `retencao_padrao`
- **(b) termina com "Próximo passo:" e prazo/data?** NÃO — linha: `Próximo passo: Passa o recibo verde no Portal das Finanças logo após receberes o pagamento do teu serviço.` · prazo detetado: `—`
- **(c) variante certa (PT)?** sim — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 8
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (b) o "Próximo passo:" não tem prazo/data
