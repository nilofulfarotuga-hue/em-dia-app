# Vídeo 01 — "Levei uma multa" (30s, vertical 9:16)

**Objetivo:** gancho emocional real (motorista TVDE que já levou multa) → mostrar a app a resolver o problema → CTA de instalação.
Formato para Facebook, Instagram Reels e TikTok — vertical 9:16, gancho nos primeiros 2 segundos.

**Público:** TVDE Portugal (também serve para estafetas, com pequenos ajustes de texto).

**Música:** batida eletrónica leve, ritmo urbano noturno, sem letra, instrumental — tipo "lo-fi driving beat" (biblioteca royalty-free, sem nome de faixa fixado ainda).

**Capturas necessárias (nome da tela + estado):**
| Tela | Estado | Ficheiro de referência |
|---|---|---|
| painel | vermelho (prazo passado) | `test/golden/_fotos/painel_vermelho_medio_pt.png` |
| calendário (detalhe) | laranja (obrigação a vencer) | `test/golden/_fotos/calendario_detalhe_medio_pt.png` |
| carro | verde (tudo em dia, inspeção marcada) | `test/golden/_fotos/carro_medio_pt.png` |
| painel | verde (tudo em dia) | `test/golden/_fotos/painel_verde_medio_pt.png` |
| calculadora (recibos) | normal | `test/golden/_fotos/recibos_medio_pt.png` |
| onboarding — boas-vindas | normal | `test/golden/_fotos/onboarding_p0_boasvindas_medio_pt.png` |

**Ficheiro de voz esperado:** `voz_01_tvde_multa_ptbr.mp3` — idioma PT-BR (motorista TVDE brasileiro em Portugal), duração ≈ 24s (deixa ~6s de música/CTA sem voz no fecho).

## Storyboard

| # | Duração | Imagem/captura da app | Texto em ecrã | Voz (o que se diz) |
|---|---|---|---|---|
| 1 | 0–2s | Ator (ou reencenação) dentro do carro, close no rosto cansado, à noite, luzes da rua desfocadas | "EU LEVEI UMA MULTA" | "Eu sou motorista TVDE e fiz isto porque levei uma multa." |
| 2 | 2–6s | Corte para o telemóvel: captura `painel` estado vermelho | "Passou o prazo e nem vi" | "Passou um prazo da Segurança Social e eu nem dei por isso." |
| 3 | 6–10s | Captura `onboarding_p0_boasvindas` (a instalar/abrir a app) | "Em português, simples" | "Descarreguei a app Em Dia — em português, feita pra gente simples de entender." |
| 4 | 10–14s | Captura `calendario_detalhe` (lista de obrigações, laranja) | "Tudo num só lugar" | "Agora vejo tudo o que tenho de pagar, num sítio só." |
| 5 | 14–18s | Captura `carro` (inspeção, verde) | "Até a inspeção do carro" | "Até a inspeção do carro ela avisa, antes de eu esquecer." |
| 6 | 18–22s | Captura `painel` estado verde, zoom no semáforo | "Sem sustos" | "Sem sustos. Sem multas." |
| 7 | 22–27s | Captura `recibos` (calculadora) | "Sei o que é meu" | "Sei sempre quanto é meu e quanto tenho de guardar." |
| 8 | 27–30s | Logótipo Em Dia sobre fundo verde, botão fake "Instalar" | "Em Dia — 30 dias grátis, sem cartão" | "Em Dia. Experimenta 30 dias grátis, sem cartão." |

**Observações de produção:**
- Ator/atriz real (ou voz gravada por motorista TVDE de verdade, se disponível) dá mais credibilidade do que voz sintética — mas voz sintética PT-BR é aceitável para a primeira versão de teste.
- Transições rápidas (corte seco, sem fade longo) para manter o ritmo de Reels/TikTok.
- Legendas embutidas obrigatórias (maioria vê sem som).
