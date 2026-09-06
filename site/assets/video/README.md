# Vídeo de herói — PROVISÓRIO

`heroi.mp4` (8,1 s · 1280×720 · h264 · sem áudio · ~340 KB) e `heroi-poster.jpg` foram gerados a
2026-09-06 por `tool/site/preparar_media.py` com o ffmpeg do BoraStudio: ken-burns (zoom lento) +
fundo desfocado sobre 4 capturas REAIS da app (`test/golden/_fotos/painel_verde`, `recibos`,
`calendario`, `carro` — variante `_medio_pt`).

**O Bora Studio substitui este ficheiro** pelo vídeo definitivo de 60 s (guião em `docs/videos/`),
mantendo o mesmo nome e as mesmas regras: `muted autoplay loop playsinline preload="metadata"`,
poster real, h264 yuv420p, ≤ 2 MB. Nada mais no site precisa de mudar.

Para regenerar o provisório: `python tool/site/preparar_media.py`.
