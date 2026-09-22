#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Prova de fumo da Play Console com Chrome real e perfil Bora copiado.

Guarda sempre uma captura, mesmo quando a Google pede nova verificação. A missão
considera a captura a prova válida, porque a Play Console não é fiável por texto.
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import time
from pathlib import Path

from playwright.sync_api import sync_playwright


ORIGEM = Path.home() / "AppData" / "Local" / "Google" / "Chrome" / "User Data"


def copiar_perfil(destino: Path) -> dict:
    destino.parent.mkdir(parents=True, exist_ok=True)
    if destino.exists():
        shutil.rmtree(destino, ignore_errors=True)
    destino.mkdir(parents=True, exist_ok=True)
    cmd = [
        "robocopy",
        str(ORIGEM),
        str(destino),
        "/MIR",
        "/XD",
        "Crashpad",
        "ShaderCache",
        "GrShaderCache",
        "GraphiteDawnCache",
        "/XF",
        "Singleton*",
        "*.tmp",
        "/R:1",
        "/W:1",
    ]
    r = subprocess.run(cmd, text=True, capture_output=True, timeout=900)
    # Robocopy usa 0-7 para sucesso; 8+ é erro real.
    return {"returncode": r.returncode, "ok": r.returncode < 8, "stdout_tail": r.stdout[-4000:], "stderr_tail": r.stderr[-2000:]}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--profile-copy", default=str(Path(r"C:\Users\danil\AppData\Local\Temp\opencode") / "chrome-user-data-play-smoke"))
    a = ap.parse_args()

    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    copia = Path(a.profile_copy)
    resultado = {"profile_copy": str(copia), "copy": copiar_perfil(copia)}

    screenshot = out / "b-1-play-console-smoke.png"
    with sync_playwright() as p:
        ctx = p.chromium.launch_persistent_context(
            str(copia),
            channel="chrome",
            headless=False,
            ignore_default_args=["--enable-automation"],
            args=["--profile-directory=Profile 1", "--disable-blink-features=AutomationControlled"],
            viewport={"width": 1440, "height": 950},
            locale="pt-PT",
        )
        page = ctx.pages[0] if ctx.pages else ctx.new_page()
        page.goto("https://play.google.com/console", wait_until="domcontentloaded", timeout=90000)
        page.wait_for_timeout(20000)
        title = page.title()
        url = page.url
        page.screenshot(path=str(screenshot), full_page=True)
        resultado.update({"title": title, "url": url, "screenshot": str(screenshot), "ts": time.strftime("%Y-%m-%d %H:%M:%S")})
        ctx.close()

    (out / "b-1-play-console-smoke.json").write_text(json.dumps(resultado, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(resultado, ensure_ascii=False, indent=2))
    return 0 if resultado["copy"]["ok"] else 1


if __name__ == "__main__":
    sys.exit(main())
