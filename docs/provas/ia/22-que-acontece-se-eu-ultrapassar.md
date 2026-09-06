# Pergunta 22 — O que acontece se eu ultrapassar os 15 mil de faturamento?

- **Data/hora:** 2026-09-06 09:31:01 (Lisboa)
- **Perfil do guião:** Freelancer (brasileira) · **variante esperada:** BR
- **Pergunta enviada (literal):** `O que acontece se eu ultrapassar os 15 mil de faturamento?`
- **Regras a citar (guião):** `iva_isencao_limite`, `iva_isencao_perda_imediata`, `iva_isencao_comunicacao_dias_uteis`
- **Esperado (guião):** Entre 15.000 € e 18.750 €: perde a isenção no ano seguinte. Acima de 18.750 €: perde na hora, com comunicação às Finanças em 15 dias úteis
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 19.8s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `27` · **limite_valor:** `None`

### Resposta literal

```text
Se ganhares mais de 15.000 € (iva_isencao_limite) num ano, deixas de estar isento (livre de pagar imposto). Isto significa que vais ter de cobrar IVA (um imposto que vai para o Estado) aos teus clientes.

Tens duas regras:
1. Se passares os 15.000 € (iva_isencao_limite), tens de avisar as Finanças. Tens 15 dias úteis (iva_isencao_comunicacao_dias_uteis) para entregar a declaração de alterações (um documento para mudar as tuas regras).
2. Se passares logo os 18.750 € (iva_isencao_perda_imediata), a isenção acaba na hora. O recibo seguinte já tem de levar a taxa de 23% (iva_taxa_normal) de IVA.

Como o teu perfil diz que estás isento (regime_iva), vai acompanhando os teus ganhos na app.

Próximo passo: Controla os teus ganhos para não passar os 15.000 € (iva_isencao_limite) sem

(A resposta ficou incompleta — pergunta outra vez, de forma mais curta.)
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Se ganhares mais de 15.000 € (iva_isencao_limite) num ano, deixas de estar isento (livre de pagar imposto). Isto significa que vais ter de cobrar IVA (um imposto que vai para o Estado) aos teus clientes.\n\nTens duas regras:\n1. Se passares os 15.000 € (iva_isencao_limite), tens de avisar as Finanças. Tens 15 dias úteis (iva_isencao_comunicacao_dias_uteis) para entregar a declaração de alterações (um documento para mudar as tuas regras).\n2. Se passares logo os 18.750 € (iva_isencao_perda_imediata), a isenção acaba na hora. O recibo seguinte já tem de levar a taxa de 23% (iva_taxa_normal) de IVA.\n\nComo o teu perfil diz que estás isento (regime_iva), vai acompanhando os teus ganhos na app.\n\nPróximo passo: Controla os teus ganhos para não passar os 15.000 € (iva_isencao_limite) sem\n\n(A resposta ficou incompleta — pergunta outra vez, de forma mais curta.)\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 27,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 3/3; encontrados: `15.000`, `18.750`, `15 dias úteis`; chaves do guião citadas no texto: `iva_isencao_limite`, `iva_isencao_perda_imediata`, `iva_isencao_comunicacao_dias_uteis`
- **(b) termina com "Próximo passo:" e prazo/data?** NÃO — linha: `Próximo passo: Controla os teus ganhos para não passar os 15.000 € (iva_isencao_limite) sem` · prazo detetado: `—`
- **(c) variante certa (BR)?** NÃO — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 9
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (b) o "Próximo passo:" não tem prazo/data
- (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=9
