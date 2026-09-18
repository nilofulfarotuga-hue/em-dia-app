# Prova da PWA — 2026-09-18 14:53:29 (PASSOU)

Base: `http://localhost:8791` · Chromium do Playwright, UA de Chrome normal, `--disable-blink-features=AutomationControlled`.

## Números

- `<html lang>`: `pt-PT` · `theme-color`: `#16A34A`
- Manifest: {"name": "Em Dia", "short_name": "Em Dia", "lang": "pt-PT", "theme_color": "#16A34A", "background_color": "#F6F7F4", "display": "standalone", "start_url": "/"} · ícones: 192x192, 512x512, 192x192 maskable, 512x512 maskable
- Primeiro ecrã COM rede: **2259 ms** (canvas = True)
- Semântica: **24 nós** `flt-semantics` (5 com rótulo/papel)
- Service worker a controlar a página aos 6 ms; pediu para guardar aos 7 ms; respondeu «guardado» aos 122 ms: {"tipo": "guardado", "quantos": 7, "total": 9, "versao": "__VERSAO__"}
- Cache `em-dia-__VERSAO__`: **13 ficheiros** — {"main.dart.js": true, "flutter_bootstrap.js": true, "canvaskit": true, "inter": true, "assets": 4}
- SEM rede: página abriu = True; primeiro ecrã **819 ms**; flutter-view = True, canvas = True
- Redimensionar 5×: 390x844 → ok em 0 ms (vigia: 0); 1100x700 → ok em 78 ms (vigia: 0); 700x900 → ok em 37 ms (vigia: 0); 360x780 → ok em 70 ms (vigia: 0); 1280x800 → ok em 92 ms (vigia: 0)

## Capturas

`01-com-rede.png`, `02-sem-rede.png`, `03-resize-*.png` nesta pasta.
