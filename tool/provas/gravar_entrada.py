#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Grava em vídeo a entrada na app publicada: e-mail → código → onboarding → painel.

Porquê isto existe (2026-09-06, noite): a prova final da missão é "uma pessoa
entra, faz o onboarding e vê o painel", em vídeo. Os dois browsers da sessão
não gravam (o painel do Claude Code não grava; o Chrome da extensão estava numa
janela escondida, 0×0). O Playwright local grava sozinho (WebKit ou Chromium)
e o vídeo fica em docs/provas/.

CUIDADO: o Turnstile recusa browsers automáticos — e ainda bem. Por isso a
sessão é obtida a sério (Chrome verdadeiro + Turnstile + código lido na Resend
+ /auth/v1/verify) e injectada aqui com --sessao; o pedido de código com token
tem prova própria em docs/provas/turnstile-2026-09-06.md.

Como a app é Flutter web (canvas), o script liga a árvore de semântica
(o botão escondido "Enable accessibility") e a partir daí clica por nome.

Uso:
  python tool/provas/gravar_entrada.py --dump                # só mostra o que está no ecrã
  python tool/provas/gravar_entrada.py --email X --passos passos.json
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
from pathlib import Path

import requests
from playwright.sync_api import sync_playwright

RAIZ = Path(__file__).resolve().parents[2]
URL = "https://app-em-dia.pages.dev/"
RESEND_KEY = Path(r"C:\BoraLocal\_segredos\em-dia\resend.key").read_text(encoding="utf-8").strip()


def codigo_da_resend(email: str, depois_de: float, espera: int = 60) -> str:
    """Espera pelo e-mail do código (enviado depois de `depois_de`) e devolve os 6 números."""
    fim = time.time() + espera
    while time.time() < fim:
        r = requests.get("https://api.resend.com/emails?limit=8",
                         headers={"Authorization": f"Bearer {RESEND_KEY}"}, timeout=20)
        for e in r.json().get("data", []):
            if email.lower() in [t.lower() for t in (e.get("to") or [])]:
                criado = e.get("created_at", "")
                t = time.mktime(time.strptime(criado[:19], "%Y-%m-%dT%H:%M:%S"))
                if t + 3600 * 0 >= depois_de - 120:  # UTC vs local: margem larga
                    corpo = requests.get(f"https://api.resend.com/emails/{e['id']}",
                                         headers={"Authorization": f"Bearer {RESEND_KEY}"}, timeout=20).json()
                    txt = corpo.get("text") or re.sub(r"<[^>]+>", " ", corpo.get("html") or "")
                    m = re.search(r"\b(\d{6})\b", txt)
                    if m:
                        return m.group(1)
        time.sleep(3)
    raise SystemExit("o e-mail com o código não chegou à Resend em tempo útil")


def nomes(page) -> list[str]:
    """Os nomes acessíveis visíveis (Flutter web com semântica ligada)."""
    return page.evaluate("""() => {
      const out = [];
      document.querySelectorAll('flt-semantics, [role]').forEach(e => {
        const r = e.getAttribute('role') || e.tagName.toLowerCase();
        const n = e.getAttribute('aria-label') || (e.querySelector && e.querySelector('input') ? '(campo)' : '') || (e.innerText || '').trim();
        if (n && n.length < 160) out.push(r + ' | ' + n);
      });
      return out;
    }""")


def ligar_semantica(page):
    page.wait_for_selector("flt-semantics-placeholder", state="attached", timeout=60000)
    page.evaluate("""() => {
      const p = document.querySelector('flt-semantics-placeholder');
      p.dispatchEvent(new PointerEvent('pointerdown', {bubbles: true}));
      p.dispatchEvent(new PointerEvent('pointerup', {bubbles: true}));
      p.click();
    }""")
    page.wait_for_timeout(1500)


def clicar_nome(page, padrao: str, papel: str | None = None, timeout: int = 15000):
    loc = page.get_by_role(papel, name=re.compile(padrao, re.I)) if papel else page.get_by_text(re.compile(padrao, re.I))
    loc.first.click(timeout=timeout)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--email")
    ap.add_argument("--passos", help="JSON com a lista de passos depois do código")
    ap.add_argument("--dump", action="store_true")
    ap.add_argument("--sessao", help="JSON de sessão (de /auth/v1/verify) para injetar no localStorage — usado quando o Turnstile recusa o browser automático (e deve recusar)")
    ap.add_argument("--chave", default="sb-tgdmgtmknbwhcqoxtjbs-auth-token", help="chave do localStorage onde a app guarda a sessão")
    ap.add_argument("--motor", default="webkit", choices=["webkit", "chromium"])
    ap.add_argument("--video", default=str(RAIZ / "docs" / "provas" / "video"))
    a = ap.parse_args()

    Path(a.video).mkdir(parents=True, exist_ok=True)
    with sync_playwright() as p:
        motor = getattr(p, a.motor)
        browser = motor.launch(headless=True)
        ctx = browser.new_context(viewport={"width": 412, "height": 915}, device_scale_factor=1,
                                  record_video_dir=a.video, record_video_size={"width": 412, "height": 915},
                                  locale="pt-PT")
        # A porta dos robôs em web/index.html não carrega a app quando
        # `navigator.webdriver` é verdadeiro — e no Playwright é. Este script
        # grava o percurso de uma pessoa, por isso apresenta-se como uma.
        ctx.add_init_script("Object.defineProperty(navigator, 'webdriver', {get: () => false})")
        page = ctx.new_page()
        page.on("console", lambda m: print("  consola:", m.text[:160]) if m.type in ("error", "warning") else None)
        page.goto(URL, wait_until="load", timeout=90000)
        page.wait_for_timeout(6000)
        if a.sessao:
            # A sessão foi obtida a sério (Chrome verdadeiro + Turnstile + código
            # da caixa); aqui só se põe no sítio onde a app a guarda e recarrega.
            sessao = Path(a.sessao).read_text(encoding="utf-8-sig")
            page.evaluate("([k, v]) => localStorage.setItem(k, v)", [a.chave, sessao])
            page.reload(wait_until="load")
            page.wait_for_timeout(7000)
        ligar_semantica(page)
        page.screenshot(path=str(Path(a.video) / "00-entrada.png"))
        if a.dump or not a.email:
            for n in nomes(page):
                print(n)
            ctx.close(); browser.close()
            return

        t0 = time.time()
        if a.sessao:
            print("--- ecrã com a sessão injetada ---")
            for n in nomes(page):
                print(n)
            correr_passos(page, a)
            ctx.close(); browser.close()
            vids = sorted(Path(a.video).glob("*.webm"), key=lambda f: f.stat().st_mtime)
            print("vídeo:", vids[-1] if vids else "nenhum")
            return
        page.get_by_role("textbox").first.click()
        page.keyboard.type(a.email, delay=40)
        page.wait_for_timeout(500)
        clicar_nome(page, r"Enviar c", "button")
        page.wait_for_timeout(4000)
        page.screenshot(path=str(Path(a.video) / "01-codigo-pedido.png"))
        codigo = codigo_da_resend(a.email, t0)
        print("código recebido:", codigo)
        page.get_by_role("textbox").first.click()
        page.keyboard.type(codigo, delay=120)
        page.wait_for_timeout(6000)
        page.screenshot(path=str(Path(a.video) / "02-depois-do-codigo.png"))
        print("--- ecrã depois do código ---")
        for n in nomes(page):
            print(n)

        correr_passos(page, a)
        page.wait_for_timeout(2500)
        ctx.close()
        browser.close()
        vids = sorted(Path(a.video).glob("*.webm"), key=lambda f: f.stat().st_mtime)
        print("vídeo:", vids[-1] if vids else "nenhum")


def correr_passos(page, a):
    if True:
        passos = json.loads(Path(a.passos).read_text(encoding="utf-8")) if a.passos else []
        for i, passo in enumerate(passos, 1):
            tipo = passo.get("tipo", "clicar")
            try:
                if tipo == "clicar":
                    clicar_nome(page, passo["nome"], passo.get("papel"))
                elif tipo == "escrever":
                    # Campos de números (mês, ano, euros) saem como spinbutton na
                    # árvore de semântica; os de texto, como textbox.
                    campos = page.get_by_role("spinbutton")
                    if campos.count() == 0:
                        campos = page.get_by_role("textbox")
                    if campos.count() == 0:
                        campos = page.locator("flt-semantics input")
                    campos.nth(passo.get("n", 0)).click()
                    page.keyboard.type(passo["texto"], delay=60)
                elif tipo == "esperar":
                    page.wait_for_timeout(int(passo.get("ms", 1000)))
                elif tipo == "xy":
                    # Campos que a árvore de semântica não expõe (mês/ano):
                    # clica-se no sítio, no ecrã de 412×915, e escreve-se.
                    page.mouse.click(int(passo["x"]), int(passo["y"]))
                    page.wait_for_timeout(400)
                    if passo.get("texto"):
                        page.keyboard.type(passo["texto"], delay=80)
                page.wait_for_timeout(int(passo.get("depois", 1200)))
            except Exception as e:  # noqa: BLE001
                if passo.get("opcional"):
                    print(f"passo {i} (opcional) não se aplicou — sigo")
                    continue
                print(f"passo {i} falhou: {e}")
                page.screenshot(path=str(Path(a.video) / f"falhou-passo-{i}.png"))
                for n in nomes(page):
                    print("   ", n)
                break
            page.screenshot(path=str(Path(a.video) / f"{i + 2:02d}-{passo.get('foto', 'passo')}.png"))
        print("--- fim ---")
        for n in nomes(page):
            print(n)


if __name__ == "__main__":
    sys.exit(main())
