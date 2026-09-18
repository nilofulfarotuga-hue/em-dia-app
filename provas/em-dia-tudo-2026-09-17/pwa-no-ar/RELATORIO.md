# Prova da PWA — 2026-09-18 15:20:06 (PASSOU)

Base: `https://app.emdia.boraguarda.com` · Chromium do Playwright, UA de Chrome normal, `--disable-blink-features=AutomationControlled`.

## Números

- `<html lang>`: `pt-PT` · `theme-color`: `#16A34A`
- Manifest: {"name": "Em Dia", "short_name": "Em Dia", "lang": "pt-PT", "theme_color": "#16A34A", "background_color": "#F6F7F4", "display": "standalone", "start_url": "/"} · ícones: 192x192, 512x512, 192x192 maskable, 512x512 maskable
- Primeiro ecrã COM rede: **6344 ms** (canvas = True)
- Semântica: **24 nós** `flt-semantics` (5 com rótulo/papel)
- Service worker a controlar a página aos 2 ms; pediu para guardar aos 0 ms; respondeu «guardado» aos 4 ms: {"tipo": "guardado", "quantos": 7, "total": 9, "versao": "3c07fb71f0fc"}
- Cache `em-dia-3c07fb71f0fc`: **13 ficheiros** — {"main.dart.js": true, "flutter_bootstrap.js": true, "canvaskit": true, "inter": true, "assets": 4}
- SEM rede: página abriu = True; primeiro ecrã **723 ms**; flutter-view = True, canvas = True
- Redimensionar 5×: 390x844 → ok em 0 ms (vigia: 0); 1100x700 → ok em 43 ms (vigia: 0); 700x900 → ok em 57 ms (vigia: 0); 360x780 → ok em 62 ms (vigia: 0); 1280x800 → ok em 74 ms (vigia: 0)

## Capturas

`01-com-rede.png`, `02-sem-rede.png`, `03-resize-*.png` nesta pasta.
