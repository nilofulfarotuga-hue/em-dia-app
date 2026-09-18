# BLOCO 6 — PWA: a app na web com nome, ícone, e a abrir sem rede (2026-09-18)

> Missão `em-dia-tudo-2026-09-17`. Ordem: «manifest, offline, semântica, resize provado 5×, TTFF».
> Estado antes (Bloco 0): manifest de fábrica (`name: em_dia`, azul Flutter), ícones do Flutter, **sem
> service worker** (o do Flutter 3.47 é um resto que se desregista), semântica 0 nós, resize preso.

## O que ficou feito

| Peça | Antes | Agora |
|---|---|---|
| `web/manifest.json` | `em_dia`, «A new Flutter project.», `#0175C2` | «Em Dia», descrição PT-PT, `lang: pt-PT`, `theme_color #16A34A`, `background #F6F7F4`, `id`/`scope`/`start_url` `/`, categorias finance/productivity, 4 ícones (192/512 + maskable) |
| Ícones | Flutter azul (web, favicon, Android) | Proposta 1 da marca (calendário com visto verde; D68): `web/icons/*`, `web/favicon.png`, `assets/branding/icon*.png`, mipmaps Android adaptativos (`dart run flutter_launcher_icons`) |
| `web/index.html` | `<html>` sem língua, sem `theme-color` | `lang="pt-PT"`, `theme-color #16A34A`, `color-scheme light`, `apple-touch-icon` 192/512, barra iOS `default` |
| Service worker | `flutter_service_worker.js` (stub deprecado: desregista-se e recarrega a página — flutter/flutter#156910) | **`web/sw.js` nosso** (D69): rede primeiro para página/bootstrap/`main.dart.js`; cache primeiro para CanvasKit, tipos de letra e assets; Supabase/Turnstile intactos; depois do primeiro ecrã a página manda a lista do que carregou e o worker guarda-a |
| Arranque | `flutter_bootstrap.js` de fábrica (regista o stub) | **`web/flutter_bootstrap.js`** (modelo): chama o carregador SEM `serviceWorkerSettings`, regista `sw.js` no `load`, pede «guardar» 1,5 s depois do `flutter-first-frame` |
| Versão do worker | — | CI carimba `__VERSAO__` com o commit (`build_web_deploy.yml` → «Carimbar versão»): worker novo a cada deploy, cache antiga apagada ao ativar |
| Semântica | 0 nós | `ensureSemantics()` no arranque (B1) → **24 nós** `flt-semantics` na entrada |
| Prova | — | `tool/provas/pwa_prova.py`: serve a build, abre num Chromium do Playwright «como pessoa», mede tudo, corta a rede e volta a abrir, redimensiona 5×, escreve relatório + capturas |

## Prova (saída literal — `python tool/provas/pwa_prova.py`, build local `build/web_app`, 14:53)

```
# Prova da PWA — 2026-09-18 14:53:29 (PASSOU)

Base: `http://localhost:8791` · Chromium do Playwright, UA de Chrome normal, `--disable-blink-features=AutomationControlled`.

- `<html lang>`: `pt-PT` · `theme-color`: `#16A34A`
- Manifest: {"name": "Em Dia", "short_name": "Em Dia", "lang": "pt-PT", "theme_color": "#16A34A", "background_color": "#F6F7F4", "display": "standalone", "start_url": "/"} · ícones: 192x192, 512x512, 192x192 maskable, 512x512 maskable
- Primeiro ecrã COM rede: **2259 ms** (canvas = True)
- Semântica: **24 nós** `flt-semantics` (5 com rótulo/papel)
- Service worker a controlar a página aos 6 ms; pediu para guardar aos 7 ms; respondeu «guardado» aos 122 ms: {"tipo": "guardado", "quantos": 7, "total": 9, "versao": "__VERSAO__"}
- Cache `em-dia-__VERSAO__`: **13 ficheiros** — {"main.dart.js": true, "flutter_bootstrap.js": true, "canvaskit": true, "inter": true, "assets": 4}
- SEM rede: página abriu = True; primeiro ecrã **819 ms**; flutter-view = True, canvas = True
- Redimensionar 5×: 390x844 → ok em 0 ms (vigia: 0); 1100x700 → ok em 78 ms (vigia: 0); 700x900 → ok em 37 ms (vigia: 0); 360x780 → ok em 70 ms (vigia: 0); 1280x800 → ok em 92 ms (vigia: 0)
```

Capturas em `provas/em-dia-tudo-2026-09-17/pwa/`: `01-com-rede.png` e `02-sem-rede.png` são o mesmo ecrã de
entrada («Entra com o teu e-mail»), o segundo **com a rede cortada** (`context.set_offline(True)` e nova
navegação); `03-resize-*.png` são os 5 tamanhos.

O primeiro ensaio (14:51) dizia «canvas = False» e chumbava os 5 redimensionamentos: o `<canvas>` do CanvasKit
vive dentro do shadow root da `<flt-glass-pane>` e um `querySelector` na `<flutter-view>` não o vê. A prova
passou a descer os shadow roots; a app estava certa (a captura sem rede já mostrava o ecrã).

## O que a build local tem a mais/menos do que a do CI

- A build local foi feita com o modelo `web/flutter_bootstrap.js` antes de lhe acrescentar o ouvinte da resposta
  «guardado» (3 linhas); esse trecho foi colado à mão em `build/web_app/flutter_bootstrap.js`, **igual ao modelo**,
  para a prova o poder ler. O CI compila do modelo.
- `__VERSAO__` fica por carimbar na build local (o `sed` é do CI); o worker funciona na mesma, com a cache
  `em-dia-__VERSAO__`.
- **Prova na app publicada (15:06, commit `3c07fb7` no ar — CI verde nos três workflows):**
  `python tool/provas/pwa_prova.py --url https://app.emdia.boraguarda.com --saida provas/em-dia-tudo-2026-09-17/pwa-no-ar`

  ```
  - Primeiro ecrã COM rede: **6344 ms** (canvas = True)          ← arranque frio, Cloudflare + CanvasKit do CDN + Turnstile
  - Semântica: **24 nós** `flt-semantics` (5 com rótulo/papel)
  - Service worker a controlar a página aos 2 ms; respondeu «guardado» aos 4 ms: {"quantos": 7, "total": 9, "versao": "3c07fb71f0fc"}
  - Cache `em-dia-3c07fb71f0fc`: **13 ficheiros** — main.dart.js, flutter_bootstrap.js, canvaskit, inter, 4 assets
  - SEM rede: página abriu = True; primeiro ecrã **723 ms**; flutter-view = True, canvas = True
  - Redimensionar 5×: 390x844 → ok em 0 ms; 1100x700 → 43 ms; 700x900 → 57 ms; 360x780 → 62 ms; 1280x800 → 74 ms
  ```
  A versão do worker é o commit carimbado pelo CI (`__VERSAO__` → `3c07fb71f0fc`): a cache muda a cada deploy.

## Limites honestos

- «Sem rede» = a app abre e mostra os ecrãs; o que precisa do servidor (entrar, ler as obrigações) fica com o
  aviso de rede que já existia. Dados em cache para leitura sem rede ficam para outra volta.
- O tempo até ao primeiro ecrã com rede (2,3 s local; ~3 s no ar medido no Bloco 0) é o custo do `main.dart.js`
  (5,7 MB) + CanvasKit do CDN da Google; cortá-lo a sério é «deferred loading» ou Wasm, fora deste bloco.
- iOS instala a PWA pelo Safari («Adicionar ao ecrã principal») e não corre service workers em todas as versões
  da mesma maneira; não foi testado num iPhone real (não há aparelho).

## Decisões

D68 (ícone = proposta 1 até o Danilo escolher outro) e D69 (service worker nosso) em `docs/DECISOES.md`.
