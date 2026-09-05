#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Baixa capturas de referência (Play Store / sites) para docs/referencias/<app>/.

Uso: python tool/referencias/baixar.py <app> <ficheiro.json com lista de URLs>
As imagens da Play Store (play-lh.googleusercontent.com) aceitam o sufixo de
tamanho: troca-se o que vier por =w1080-h2400 para ter a captura em grande.
Escreve um index.md com a origem e a data (a regra do site-premio: referência
sem origem não vale).
"""
import datetime as dt
import json
import re
import sys
import urllib.request
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]


def main() -> int:
    if len(sys.argv) < 3:
        print("uso: baixar.py <app> <urls.json>")
        return 2
    app = sys.argv[1]
    urls = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
    pasta = RAIZ / "docs" / "referencias" / app
    pasta.mkdir(parents=True, exist_ok=True)
    linhas = [f"# Referência: {app}", "", f"Capturado a {dt.date.today().isoformat()} da Play Store / site oficial.", ""]
    ok = 0
    for i, u in enumerate(urls, 1):
        grande = re.sub(r"=w\d+-h\d+(-rw)?$", "=w1080-h2400", u) if "play-lh" in u else u
        destino = pasta / f"{i:02d}.png"
        try:
            req = urllib.request.Request(grande, headers={"User-Agent": "Mozilla/5.0"})
            dados = urllib.request.urlopen(req, timeout=30).read()
            destino.write_bytes(dados)
            ok += 1
            linhas.append(f"- `{destino.name}` ← {grande}")
        except Exception as e:  # noqa: BLE001
            linhas.append(f"- FALHOU {grande}: {e}")
    (pasta / "index.md").write_text("\n".join(linhas) + "\n", encoding="utf-8")
    print(f"{app}: {ok}/{len(urls)} capturas em {pasta}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
