# B0 — Estado real (2026-09-18, 07:00–08:15, sessão 49feae11)

## O que está no ar (curl, User-Agent de Chrome)
```
https://app.emdia.boraguarda.com/            -> 200 4423B 0.35s
https://admin.emdia.boraguarda.com/          -> 200 4423B 0.73s
https://emdia.boraguarda.com/                -> 200 56648B 0.49s
https://emdia.boraguarda.com/privacidade     -> 200 6389B 0.12s
```
Track interno da Play: ficha da missão anterior (versionCode 32 no pubspec, último CI verde em 64ac508 — docs/MARCOS.md 2026-09-07 01:25). Não voltei a abrir a consola da Play neste bloco.

## Build web atual (medido no ficheiro publicado)
- `flutter_bootstrap.js` publicado: `"renderer":"canvaskit"`, `"compileTarget":"dart2js"`. O CI usa Flutter 3.47.2 (`build_web_deploy.yml`), onde o renderer HTML já não existe (removido em 3.29) — as opções são só CanvasKit (WebGL) ou skwasm (Wasm, precisa de COOP/COEP).
- CanvasKit vem do CDN da Google: `www.gstatic.com/flutter-canvaskit/a804b261…/chromium/canvaskit.wasm` (5,4 MB; a variante genérica tem 7,3 MB).
- Tamanhos (curl): `main.dart.js` 5.259.532 B em disco, 1.478 KB comprimido na rede; `Inter-VariableFont.ttf` 446 KB carregada em tempo de execução; `flutter_service_worker.js` 784 B (é o stub do Flutter 3.47 — não há service worker registado: `navigator.serviceWorker.getRegistrations()` = 0).
- `manifest.json` publicado é o de fábrica do Flutter: `name: em_dia`, `description: A new Flutter project.`, `theme_color: #0175C2` (azul Flutter). Instalável como PWA só de nome.

## Tempo até ao primeiro ecrã (Performance API, navegador embutido)
- Carregamento frio (primeira visita): `responseStart` 83 ms, `domContentLoaded` 1979 ms, `main.dart.js` acabou de chegar aos 2237 ms, tipo de letra Inter aos 3034 ms → primeiro ecrã ≈ 3,1 s.
- Carregamento quente (segunda visita, cache): evento `flutter-first-frame` aos **711 ms**.
- Total transferido na primeira visita: ~2,0 MB (sem contar o CanvasKit do CDN, que não reporta tamanho por ser de outra origem).

## Semântica / acessibilidade
- `flt-semantics-host` existe mas tem **0 filhos**; `flt-semantics` = 0 nós. O código não chama `SemanticsBinding.instance.ensureSemantics()` (grep a zero em lib/). A árvore de acessibilidade está vazia até a pessoa carregar no botão invisível do Flutter — leitores de ecrã e testes automáticos não veem nada.

## Redimensionar (o defeito 2 do Bloco 1, reproduzido)
- Navegador embutido, viewport 800x450 → 1100x700: `flutter-view` passou a 1100x700 mas o `<canvas>` foi removido e **não voltou** (página cinzenta) até um clique; depois do clique, canvas 1375x875 (1100x700 css). Segundo redimensionamento (→700x900): a `flutter-view` ficou presa em 1100x700 durante mais de 5 s.
- Página carregada com a janela a 0x0 e depois posta a 600x400: `flutter-view` ficou 0x0 e sem canvas; `visualViewport.dispatchEvent(new Event('resize'))` à mão → a `flutter-view` passou logo a 600x400 e o canvas apareceu. **Conclusão: o motor (Flutter 3.47, CanvasKit) só ouve `visualViewport.resize`; quando esse evento não chega (ou chega com a página escondida) a app não se redesenha.** Um `window.resize` sintético não faz nada.
- WebGL: hardware (ANGLE/AMD Radeon, D3D11), 62 rAF/s, `crossOriginIsolated=false` (skwasm ficaria fora sem cabeçalhos COOP/COEP, que partiriam o Turnstile e o Google Sign-In em iframe).

## Máquina e portão de RAM
- `AvailableMBytes` = 467 MB às 06:55 (portão leve 400 MB passa; o pesado, 800 MB, exige libertar antes de compilar). Às 08:10 media 1960 MB. O `llama-server` está a correr (idle) e é o consumidor que se pára antes de `flutter build`, como a 2026-09-05.
- O navegador reporta 16 núcleos e 16 GB — não é o Celeron de 4 GB do CLAUDE.md global; a regra do portão aplica-se na mesma pelo número medido.

## Vigia
- `EmDia-Retomar` tinha sido **apagado** a 2026-09-07 00:06:59 (docs/vigia.log: «MISSAO-CONCLUIDA encontrada: apago a tarefa»). Re-registado às 06:56 (State: Ready, NextRunTime 07:16:29) apontado à sessão 49feae11 e ao marcador `MISSAO-CONCLUIDA em-dia-tudo-2026-09-17`; batimento pid 7372 a renovar `docs/.sessao-viva`.
