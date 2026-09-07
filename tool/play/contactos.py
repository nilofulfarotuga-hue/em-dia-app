#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Põe os contactos da ficha da Play (site e e-mail de apoio) pela API.

2026-09-07 (D46): o site passa a https://emdia.boraguarda.com e o e-mail de
apoio é boraappbora@gmail.com. O URL da política de privacidade NÃO está na
API (é em Conteúdo da app → Política de privacidade, na consola).

Uso: python tool/play/contactos.py            # ensaio
     python tool/play/contactos.py --aplicar  # grava e faz commit da edição
"""
from __future__ import annotations
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from api import Play, BASE  # noqa: E402

SITE = "https://emdia.boraguarda.com"
EMAIL = "boraappbora@gmail.com"


def main() -> int:
    aplicar = "--aplicar" in sys.argv
    p = Play()
    ed = p.abre_edicao()
    try:
        antes = p._pedido("GET", f"{BASE}/{p.pacote}/edits/{ed}/details")
        print("antes:", {k: antes.get(k) for k in ("contactWebsite", "contactEmail", "contactPhone", "defaultLanguage")})
        corpo = dict(antes)
        corpo["contactWebsite"] = SITE
        corpo["contactEmail"] = EMAIL
        depois = p._pedido("PUT", f"{BASE}/{p.pacote}/edits/{ed}/details", corpo)
        print("depois:", {k: depois.get(k) for k in ("contactWebsite", "contactEmail", "contactPhone", "defaultLanguage")})
        if aplicar:
            p.valida(ed)
            print("COMMIT:", p.submete(ed))
        else:
            p.descarta(ed)
            print("ENSAIO — edição apagada, nada mudou.")
    except Exception:
        try:
            p.descarta(ed)
        except Exception:
            pass
        raise
    return 0


if __name__ == "__main__":
    sys.exit(main())
