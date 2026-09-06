# Vídeo 02 — Vídeo da loja (15s, Play Store)

**Objetivo:** vídeo curto para a ficha da app na Google Play — mostra 4 telas reais em sequência rápida, sem depender de som
(a maioria vê a prévia da loja em silêncio). Reforça "é simples, é para ti".

**Público:** quem já está na ficha da Play Store a decidir se instala (topo de funil já resolvido pela busca/anúncio).

**Música:** instrumental leve e positivo, tipo corporate/upbeat curto, sem letra — biblioteca royalty-free, volume baixo (o vídeo não depende de som).

**Sem voz obrigatória** — texto em ecrã carrega o significado.

**Capturas necessárias (nome da tela + estado):**
| Tela | Estado | Ficheiro de referência |
|---|---|---|
| painel | verde (tudo em dia) | `test/golden/_fotos/painel_verde_medio_pt.png` |
| calendário | normal (lista de obrigações) | `test/golden/_fotos/calendario_medio_pt.png` |
| carro | normal | `test/golden/_fotos/carro_medio_pt.png` |
| IA (assistente) | normal | `test/golden/_fotos/ia_medio_pt.png` |

**Ficheiro de voz esperado:** nenhum — vídeo sem narração. Se se quiser adicionar depois, `voz_02_loja_ptpt.mp3` (opcional, PT-PT, ≈10s).

## Storyboard

| # | Duração | Imagem/captura da app | Texto em ecrã | Voz (o que se diz) |
|---|---|---|---|---|
| 1 | 0–1s | Logótipo Em Dia sobre fundo verde `#16A34A` | "Em Dia" | (sem voz) |
| 2 | 1–4,5s | Captura `painel` verde | "Sabe se estás em dia" | (sem voz) |
| 3 | 4,5–8s | Captura `calendario` | "Nunca mais esqueças um prazo" | (sem voz) |
| 4 | 8–11,5s | Captura `carro` | "A inspeção do carro também" | (sem voz) |
| 5 | 11,5–14s | Captura `ia` | "Pergunta o que quiseres, em português" | (sem voz) |
| 6 | 14–15s | Logótipo + selo "Grátis 30 dias" | "Instala grátis" | (sem voz) |

**Observações de produção:**
- Cada tela em zoom lento (ken burns suave) para não parecer estático nem gerar overflow visual.
- Texto sempre no terço inferior, fundo com leve gradiente escuro para garantir contraste (regra de acessibilidade do design system).
- Sem CTA falado — a própria ficha da Play Store já tem o botão "Instalar" ao lado do vídeo.
