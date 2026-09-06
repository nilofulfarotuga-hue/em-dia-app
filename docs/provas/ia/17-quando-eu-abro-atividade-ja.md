# Pergunta 17 — Quando eu abro atividade, já começo a pagar Segurança Social na hora?

- **Data/hora:** 2026-09-06 09:29:13 (Lisboa)
- **Perfil do guião:** Freelancer (imigrante) · **variante esperada:** BR
- **Pergunta enviada (literal):** `Quando eu abro atividade, já começo a pagar Segurança Social na hora?`
- **Regras a citar (guião):** `ss_isencao_meses`
- **Esperado (guião):** Não: os primeiros 12 meses de atividade são isentos de contribuições; só começa a pagar no 13.º mês
- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: 1 · duração da última: 18.0s

## Resposta — HTTP 200

- **variante detetada:** `pt` · **fora_das_regras:** `False` · **usadas:** `22` · **limite_valor:** `None`

### Resposta literal

```text
Não, não começas a pagar logo na hora!

Quando abres atividade, tens direito a uma isenção (tempo em que estás livre de pagar). Esta isenção dura 12 meses (ss_isencao_meses). Isto significa que ficas o teu primeiro ano de trabalho sem pagar nada à Segurança Social.

No teu caso, como abriste atividade a 15 de março de 2026, não pagas contribuições até ao dia 2027-03-01 (fim_isencao_ss). 

A app "Em Dia" vai enviar-te um aviso no telemóvel 30 dias (ss_aviso_fim_isencao_dias) antes de a tua isenção acabar para te poderes preparar.

Próximo passo: Continua a trabalhar descansado e acompanha o teu calendário na app até 2027-03-01 (fim_isencao_ss).
Informação geral, não substitui contabilista.
```

### JSON literal

```json
{
  "resposta": "Não, não começas a pagar logo na hora!\n\nQuando abres atividade, tens direito a uma isenção (tempo em que estás livre de pagar). Esta isenção dura 12 meses (ss_isencao_meses). Isto significa que ficas o teu primeiro ano de trabalho sem pagar nada à Segurança Social.\n\nNo teu caso, como abriste atividade a 15 de março de 2026, não pagas contribuições até ao dia 2027-03-01 (fim_isencao_ss). \n\nA app \"Em Dia\" vai enviar-te um aviso no telemóvel 30 dias (ss_aviso_fim_isencao_dias) antes de a tua isenção acabar para te poderes preparar.\n\nPróximo passo: Continua a trabalhar descansado e acompanha o teu calendário na app até 2027-03-01 (fim_isencao_ss).\nInformação geral, não substitui contabilista.",
  "variante": "pt",
  "fora_das_regras": false,
  "usadas": 22,
  "limite": null
}
```

## Verificação

- **(a) cita as chaves/valores esperados?** sim — grupos encontrados 1/1; encontrados: `12 meses`; chaves do guião citadas no texto: `ss_isencao_meses`
- **(b) termina com "Próximo passo:" e prazo/data?** sim — linha: `Próximo passo: Continua a trabalhar descansado e acompanha o teu calendário na app até 2027-03-01 (fim_isencao_ss).` · prazo detetado: `até`
- **(c) variante certa (BR)?** NÃO — API: `pt` · "você" no texto: False · marcas de "tu" (tens/teu/podes…): 8
- **(d) rodapé "Informação geral, não substitui contabilista."?** sim

## Veredito: **FALHA**

- (c) variante errada: esperada br, API devolveu pt, "você" no texto=False, marcas tu=8
