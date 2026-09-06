# Vídeo 03 — Explicativo do site (60s)

**Objetivo:** vídeo de herói da página inicial do site — explica o problema, os quatro sustos mais comuns, como a app avisa,
e fecha com os dois botões de download (Android / iPhone-computador). Voz calma, tom de confiança, PT-PT.

**Público:** visitante do site (veio da Google a pesquisar "recibos verdes", "IVA independente", etc.) — ainda não decidiu instalar.

**Música:** instrumental calmo, piano e cordas leves, sem letra, tom de confiança e proximidade — nada dramático, biblioteca royalty-free.

**Capturas necessárias (nome da tela + estado):**
| Tela | Estado | Ficheiro de referência |
|---|---|---|
| painel | laranja (situação genérica de início) | `test/golden/_fotos/painel_laranja_medio_pt.png` |
| calendário (detalhe) | obrigação SS | `test/golden/_fotos/calendario_detalhe_medio_pt.png` |
| calculadora (vigia IVA) | normal | `test/golden/_fotos/recibos_medio_pt.png` |
| calculadora (IRS) | normal | `test/golden/_fotos/recibos_irs_medio_pt.png` |
| carro | inspeção | `test/golden/_fotos/carro_medio_pt.png` |
| onboarding — boas-vindas | normal | `test/golden/_fotos/onboarding_p0_boasvindas_medio_pt.png` |
| painel | verde (resultado final) | `test/golden/_fotos/painel_verde_medio_pt.png` |

**Ficheiro de voz esperado:** `voz_03_explicativo_ptpt.mp3` — idioma PT-PT, tom calmo/institucional, duração ≈ 58s (deixa 2s de respiro no início e no fecho).

## Storyboard

| # | Duração | Imagem/captura da app | Texto em ecrã | Voz (o que se diz) |
|---|---|---|---|---|
| 1 | 0–5s | Cena genérica: pessoa a trabalhar (TVDE, cabeleireira, freelancer), plano largo e calmo | "Ser independente em Portugal" | "Ser trabalhador independente em Portugal é uma liberdade — até um prazo te apanhar desprevenido." |
| 2 | 5–10s | Captura `calendario_detalhe` (obrigação SS) | "Susto 1 — Segurança Social" | "A declaração da Segurança Social é a cada três meses. Passa despercebida a quase toda a gente." |
| 3 | 10–15s | Captura `recibos` (vigia do IVA, barra) | "Susto 2 — IVA" | "Se faturares mais de 15 mil euros no ano, começas a ter de cobrar IVA — e o prazo para avisar é curto." |
| 4 | 15–20s | Captura `recibos_irs` | "Susto 3 — IRS" | "Chega abril e há sempre alguém que não guardou nada para o IRS." |
| 5 | 20–25s | Captura `carro` (inspeção) | "Susto 4 — Inspeção do carro" | "E, para quem vive do carro, a inspeção que passa despercebida pode deixar-te sem trabalhar." |
| 6 | 25–32s | Captura `onboarding_p0_boasvindas` | "Em Dia avisa por ti" | "A app Em Dia foi feita para isto: avisa-te antes de cada prazo, em português simples." |
| 7 | 32–40s | Captura `painel` laranja → transição para `painel` verde | "Um semáforo simples" | "Um semáforo simples — verde é estás em dia, laranja é vai vencer, vermelho é já passou." |
| 8 | 40–47s | Sequência rápida: calendário, calculadora, carro (recorte das capturas anteriores) | "Tudo num só lugar" | "Recibos verdes, Segurança Social, IVA, IRS e o carro — tudo no mesmo sítio." |
| 9 | 47–52s | Captura `painel` verde, zoom | "30 dias grátis, sem cartão" | "Experimenta 30 dias grátis, sem cartão de crédito." |
| 10 | 52–57s | Ecrã final do site: dois botões lado a lado, mesmo peso visual | "Descarregar na Play Store · Usar no iPhone/computador" | "Descarrega na Play Store, ou usa direto no iPhone ou no computador." |
| 11 | 57–60s | Logótipo Em Dia sobre fundo claro, fecho calmo | "Em Dia" | (silêncio / música a desvanecer) |

**Observações de produção:**
- Voz em tom de conversa próxima, nunca vendedora — coerente com a regra de "vender o susto evitado, não a app".
- Os dois botões finais têm de ter o MESMO peso visual (nem Android nem web em destaque) — repete a regra do site (secção 5 da missão).
- Testar o vídeo com `prefers-reduced-motion` ligado e desligado no site (autoplay/muted/playsinline/poster), conforme a missão original.
