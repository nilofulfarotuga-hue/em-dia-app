#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Prova da PWA (B6, 2026-09-18): a app na web abre sem rede, o manifest é o da
marca, a árvore de semântica existe, o ecrã acompanha 5 redimensionamentos, e o
tempo até ao primeiro ecrã fica medido — tudo com números, num Chromium do
Playwright (headless, sem tocar no Chrome do Danilo).

O que faz, por ordem:
  1. Serve a build (build/web_app por omissão) em http://localhost:<porta>.
  2. Abre a app num Chromium que se apresenta como pessoa (User-Agent de Chrome
     normal e `--disable-blink-features=AutomationControlled`, senão a porta dos
     robôs do index.html recusa-o — e bem).
  3. Mede o primeiro ecrã (evento `flutter-first-frame`) com rede.
  4. Espera que o sw.js guarde o que a página carregou e lista a cache.
  5. Corta a rede, recarrega, e mede outra vez o primeiro ecrã — SEM rede.
  6. Redimensiona a janela 5 vezes e mede quanto tempo a <flutter-view> demora
     a acompanhar (com o canvas presente).
  7. Conta os nós de semântica (`flt-semantics`) e confere o manifest.
  8. Escreve o relatório em provas/em-dia-tudo-2026-09-17/pwa/RELATORIO.md e
     as capturas ao lado. Sai 0 se tudo passou; 2 se algo falhou.

Uso: python tool/provas/pwa_prova.py [--dir build/web_app] [--porta 8791] [--url https://app.emdia.boraguarda.com]
  Com --url usa-se a app publicada em vez da build local (só para conferir o
  que está no ar; a prova do «sem rede» faz-se na mesma).
"""
from __future__ import annotations

import argparse
import datetime as dt
import functools
import http.server
import json
import socketserver
import sys
import threading
import time
from pathlib import Path

from playwright.sync_api import sync_playwright

RAIZ = Path(__file__).resolve().parents[2]
UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
TAMANHOS = [(390, 844), (1100, 700), (700, 900), (360, 780), (1280, 800)]


class _Silencioso(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *a):  # noqa: D401 — sem ruído no terminal
        pass

    def end_headers(self):
        # Como a Cloudflare Pages: revalidar sempre; o service worker é que guarda.
        self.send_header("Cache-Control", "public, max-age=0, must-revalidate")
        super().end_headers()

    def do_GET(self):
        # SPA: caminhos que não existem em disco caem no index.html (como nas Pages).
        caminho = Path(self.directory) / self.path.lstrip("/").split("?")[0]
        if not caminho.exists():
            self.path = "/index.html"
        return super().do_GET()


def servir(pasta: Path, porta: int):
    handler = functools.partial(_Silencioso, directory=str(pasta))
    socketserver.TCPServer.allow_reuse_address = True
    srv = socketserver.ThreadingTCPServer(("127.0.0.1", porta), handler)
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    return srv


def esperar(page, expr: str, timeout_ms: int = 30000, passo_ms: int = 100):
    """Espera até `expr` (JS) ser verdadeiro; devolve ms que demorou ou None."""
    t0 = time.time()
    while (time.time() - t0) * 1000 < timeout_ms:
        try:
            if page.evaluate(expr):
                return int((time.time() - t0) * 1000)
        except Exception:  # noqa: BLE001 — a página pode estar a recarregar
            pass
        page.wait_for_timeout(passo_ms)
    return None


# O canvas do CanvasKit vive dentro do shadow root da <flt-glass-pane>: um
# querySelector('canvas') na <flutter-view> não o vê. Isto desce os shadow roots.
JS_TEM_CANVAS = """(function () {
  function procura(n) {
    if (!n) return false;
    if (n.querySelector && n.querySelector('canvas')) return true;
    var todos = n.querySelectorAll ? n.querySelectorAll('*') : [];
    for (var i = 0; i < todos.length; i++) { if (todos[i].shadowRoot && procura(todos[i].shadowRoot)) return true; }
    return false;
  }
  return procura(document.querySelector('flutter-view'));
})()"""


def primeiro_frame_ms(page):
    """Tempo do arranque da navegação até ao `flutter-first-frame` (ms)."""
    if esperar(page, "!!window.__emDiaPrimeiroFrame", 60000) is None:
        return None
    return page.evaluate("Math.round(window.__emDiaPrimeiroFrame - performance.timeOrigin)")


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")  # Windows: a consola é cp1252 e o relatório tem «→»
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=str(RAIZ / "build" / "web_app"))
    ap.add_argument("--porta", type=int, default=8791)
    ap.add_argument("--url", default="")
    ap.add_argument("--saida", default=str(RAIZ / "provas" / "em-dia-tudo-2026-09-17" / "pwa"))
    a = ap.parse_args()
    saida = Path(a.saida)
    saida.mkdir(parents=True, exist_ok=True)
    ts = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    srv = None
    if a.url:
        base = a.url.rstrip("/")
    else:
        pasta = Path(a.dir)
        if not (pasta / "index.html").exists():
            print(f"ERRO: não há build em {pasta} (corre flutter build web)")
            return 2
        srv = servir(pasta, a.porta)
        base = f"http://localhost:{a.porta}"

    r: dict = {"quando": ts, "base": base, "falhas": []}
    falha = r["falhas"].append

    with sync_playwright() as p:
        browser = p.chromium.launch(args=["--disable-blink-features=AutomationControlled"])
        ctx = browser.new_context(user_agent=UA, viewport={"width": 390, "height": 844}, locale="pt-PT")
        page = ctx.new_page()
        consola = []
        page.on("console", lambda m: consola.append(f"{m.type}: {m.text}"[:200]))

        # --- 1. com rede ---------------------------------------------------
        page.goto(base + "/", wait_until="domcontentloaded")
        r["html_lang"] = page.evaluate("document.documentElement.lang")
        r["theme_color"] = page.evaluate("(document.querySelector('meta[name=theme-color]')||{}).content||''")
        r["ttff_com_rede_ms"] = primeiro_frame_ms(page)
        if r["ttff_com_rede_ms"] is None:
            falha("sem primeiro ecrã com rede em 60 s")
        r["com_rede_canvas"] = page.evaluate(JS_TEM_CANVAS)
        page.screenshot(path=str(saida / "01-com-rede.png"))

        # manifest
        man = page.evaluate("fetch('manifest.json').then(x => x.json())")
        r["manifest"] = {k: man.get(k) for k in ("name", "short_name", "lang", "theme_color", "background_color", "display", "start_url")}
        r["manifest_icones"] = [f"{i.get('sizes')}{' maskable' if i.get('purpose') == 'maskable' else ''}" for i in man.get("icons", [])]
        if man.get("name") != "Em Dia" or man.get("theme_color", "").upper() != "#16A34A":
            falha(f"manifest não é o da marca: {r['manifest']}")
        if not any("512" in i and "maskable" in i for i in r["manifest_icones"]):
            falha("manifest sem ícone maskable 512")

        # semântica
        page.wait_for_timeout(1500)
        r["semantica_nos"] = page.evaluate("document.querySelectorAll('flt-semantics').length")
        r["semantica_com_rotulo"] = page.evaluate("Array.from(document.querySelectorAll('flt-semantics[aria-label], flt-semantics[role]')).length")
        if r["semantica_nos"] == 0:
            falha("árvore de semântica vazia (0 nós flt-semantics)")

        # service worker: registado, ativo, cache cheia
        r["sw_registado_ms"] = esperar(page, "!!(navigator.serviceWorker && navigator.serviceWorker.controller)", 30000)
        r["sw_pediu_guardar_ms"] = esperar(page, "!!window.__emDiaSwPediuGuardar", 40000)
        r["sw_guardou_ms"] = esperar(page, "!!window.__emDiaSwGuardou", 40000)
        r["sw_guardou"] = page.evaluate("window.__emDiaSwGuardou || null")
        page.wait_for_timeout(1000)
        cache = page.evaluate(
            """(async () => {
                 const nomes = await caches.keys();
                 const out = {nomes, urls: []};
                 for (const n of nomes) { const c = await caches.open(n); const ks = await c.keys(); out.urls.push(...ks.map(k => k.url)); }
                 return out;
               })()"""
        )
        r["cache_nomes"] = cache["nomes"]
        r["cache_total"] = len(cache["urls"])
        urls = cache["urls"]
        r["cache_tem"] = {
            "main.dart.js": any(u.endswith("/main.dart.js") for u in urls),
            "flutter_bootstrap.js": any(u.endswith("/flutter_bootstrap.js") for u in urls),
            "canvaskit": any("canvaskit" in u for u in urls),
            "inter": any("Inter" in u for u in urls),
            "assets": sum(1 for u in urls if "/assets/" in u),
        }
        if not r["cache_tem"]["main.dart.js"]:
            falha("main.dart.js não ficou guardado no service worker")

        # --- 2. sem rede ---------------------------------------------------
        ctx.set_offline(True)
        page.evaluate("window.__emDiaPrimeiroFrame = 0")
        try:
            page.goto(base + "/", wait_until="domcontentloaded", timeout=30000)
            r["sem_rede_carregou"] = True
        except Exception as e:  # noqa: BLE001
            r["sem_rede_carregou"] = False
            falha(f"sem rede a página não abriu: {str(e)[:120]}")
        r["ttff_sem_rede_ms"] = primeiro_frame_ms(page) if r["sem_rede_carregou"] else None
        if r["ttff_sem_rede_ms"] is None:
            falha("sem primeiro ecrã SEM rede")
        r["sem_rede_flutter_view"] = page.evaluate("!!document.querySelector('flutter-view')")
        r["sem_rede_canvas"] = page.evaluate(JS_TEM_CANVAS)
        page.screenshot(path=str(saida / "02-sem-rede.png"))
        ctx.set_offline(False)

        # --- 3. redimensionar 5x ------------------------------------------
        r["resize"] = []
        for (w, h) in TAMANHOS:
            page.set_viewport_size({"width": w, "height": h})
            t0 = time.time()
            ok = esperar(
                page,
                f"(() => {{ const v = document.querySelector('flutter-view'); if (!v) return false; const b = v.getBoundingClientRect();"
                f" return Math.abs(b.width - {w}) <= 1 && Math.abs(b.height - {h}) <= 1 && {JS_TEM_CANVAS}; }})()",
                8000,
                50,
            )
            demorou = int((time.time() - t0) * 1000)
            vigia = page.evaluate("(window.__emDiaVigiaTamanho||{}).corrigiu||0")
            r["resize"].append({"para": f"{w}x{h}", "acompanhou": ok is not None, "ms": demorou, "empurroes_do_vigia": vigia})
            if ok is None:
                falha(f"a flutter-view não acompanhou {w}x{h} em 8 s")
            page.screenshot(path=str(saida / f"03-resize-{w}x{h}.png"))

        r["consola_erros"] = [c for c in consola if c.startswith("error")][:10]
        browser.close()
    if srv:
        srv.shutdown()

    # --- relatório -------------------------------------------------------
    ok = not r["falhas"]
    md = [f"# Prova da PWA — {ts} ({'PASSOU' if ok else 'FALHOU'})", "", f"Base: `{base}` · Chromium do Playwright, UA de Chrome normal, `--disable-blink-features=AutomationControlled`.", ""]
    md += ["## Números", "",
           f"- `<html lang>`: `{r['html_lang']}` · `theme-color`: `{r['theme_color']}`",
           f"- Manifest: {json.dumps(r['manifest'], ensure_ascii=False)} · ícones: {', '.join(r['manifest_icones'])}",
           f"- Primeiro ecrã COM rede: **{r['ttff_com_rede_ms']} ms** (canvas = {r['com_rede_canvas']})",
           f"- Semântica: **{r['semantica_nos']} nós** `flt-semantics` ({r['semantica_com_rotulo']} com rótulo/papel)",
           f"- Service worker a controlar a página aos {r['sw_registado_ms']} ms; pediu para guardar aos {r['sw_pediu_guardar_ms']} ms; respondeu «guardado» aos {r['sw_guardou_ms']} ms: {json.dumps(r['sw_guardou'])}",
           f"- Cache `{', '.join(r['cache_nomes'])}`: **{r['cache_total']} ficheiros** — {json.dumps(r['cache_tem'])}",
           f"- SEM rede: página abriu = {r['sem_rede_carregou']}; primeiro ecrã **{r['ttff_sem_rede_ms']} ms**; flutter-view = {r['sem_rede_flutter_view']}, canvas = {r['sem_rede_canvas']}",
           "- Redimensionar 5×: " + "; ".join(f"{x['para']} → {'ok' if x['acompanhou'] else 'FALHOU'} em {x['ms']} ms (vigia: {x['empurroes_do_vigia']})" for x in r["resize"]),
           ""]
    if r["consola_erros"]:
        md += ["## Erros na consola", ""] + [f"- `{c}`" for c in r["consola_erros"]] + [""]
    if r["falhas"]:
        md += ["## Falhas", ""] + [f"- {f}" for f in r["falhas"]] + [""]
    md += ["## Capturas", "", "`01-com-rede.png`, `02-sem-rede.png`, `03-resize-*.png` nesta pasta.", ""]
    (saida / "RELATORIO.md").write_text("\n".join(md), encoding="utf-8")
    (saida / "resultado.json").write_text(json.dumps(r, ensure_ascii=False, indent=2), encoding="utf-8")
    print("\n".join(md))
    return 0 if ok else 2


if __name__ == "__main__":
    sys.exit(main())
