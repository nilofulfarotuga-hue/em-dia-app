#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Saúde do canal de e-mail do Em Dia — o único sítio onde se vê se o código
de entrar chegou mesmo à pessoa.

Porquê existir: o Supabase responde `200` ao pedido de código e entrega o
e-mail ao SMTP. Se o fornecedor depois não o entregar — porque o endereço já
devolveu antes, porque o domínio não existe, porque está numa lista de bloqueio
— **ninguém dá por nada**: o servidor disse 200 e a pessoa fica no ecrã das
casinhas à espera de um código que nunca chega. Provado a 2026-09-06: cinco
pedidos para `test@gmail.com` saíram `suppressed` e o pedido devolveu 200.

Chave: `C:\\BoraLocal\\_segredos\\em-dia\\resend.key` (fora do repo).

CICATRIZ: a API da Resend responde `403 error code: 1010` ao User-Agent do
Python — é o Cloudflare a bloquear, não a chave sem permissões. Daí o UA de
browser aqui em baixo.

Uso:  python tool/vigia/emails.py            # resumo dos últimos 100 envios
      python tool/vigia/emails.py --maus     # só os que não chegaram
      python tool/vigia/emails.py --limite 50
Saída: 0 = menos de 10% por entregar · 2 = 10% ou mais (vale a pena olhar)
"""
from __future__ import annotations

import collections
import json
import sys
import urllib.error
import urllib.request
from pathlib import Path

for fluxo in (sys.stdout, sys.stderr):
    try:
        fluxo.reconfigure(encoding="utf-8", errors="replace")
    except Exception:  # noqa: BLE001
        pass

CHAVE = Path(r"C:\BoraLocal\_segredos\em-dia\resend.key")
UA = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/128.0 Safari/537.36")
BONS = {"delivered", "sent", "opened", "clicked"}


def envios(limite: int) -> list[dict]:
    chave = CHAVE.read_text(encoding="utf-8").strip()
    pedido = urllib.request.Request(
        f"https://api.resend.com/emails?limit={limite}",
        headers={"Authorization": "Bearer " + chave, "User-Agent": UA})
    try:
        with urllib.request.urlopen(pedido, timeout=60) as r:
            return json.loads(r.read().decode()).get("data", [])
    except urllib.error.HTTPError as e:
        corpo = e.read().decode()[:200]
        print(f"ERRO: HTTP {e.code} — {corpo}")
        if e.code == 403 and "1010" in corpo:
            print("(isto é o Cloudflare a recusar o User-Agent, não a chave)")
        raise SystemExit(1)


def main() -> int:
    limite = 100
    if "--limite" in sys.argv:
        limite = int(sys.argv[sys.argv.index("--limite") + 1])
    itens = envios(limite)
    if not itens:
        print("Sem envios registados.")
        return 0

    maus = [m for m in itens if m.get("last_event") not in BONS]
    pct = 100 * len(maus) / len(itens)
    print(f"{len(itens)} envios · {len(itens) - len(maus)} chegaram · "
          f"{len(maus)} não ({pct:.0f}%)\n")

    for estado, n in collections.Counter(m.get("last_event") for m in itens).most_common():
        print(f"  {n:4d}  {estado}")

    print("\npor destinatário:")
    por = collections.defaultdict(lambda: [0, 0])
    for m in itens:
        for t in (m.get("to") or []):
            por[t][0] += 1
            if m.get("last_event") not in BONS:
                por[t][1] += 1
    for t, (n, mau) in sorted(por.items(), key=lambda x: -x[1][0]):
        marca = "todos chegaram" if mau == 0 else f"{mau} POR ENTREGAR"
        print(f"  {n:4d}  {t:40} {marca}")

    if "--maus" in sys.argv or maus:
        print("\nos que não chegaram:")
        for m in sorted(maus, key=lambda x: x.get("created_at", "")):
            print(f"  {m.get('created_at','')[:16]} | {m.get('last_event'):17} | "
                  f"{','.join(m.get('to') or [])[:34]:34} | de {(m.get('from') or '')[:26]:26} | "
                  f"{(m.get('subject') or '')[:32]}")

    if pct >= 10:
        print(f"\nATENÇÃO: {pct:.0f}% por entregar. Devoluções a mais fazem os "
              "fornecedores travarem o domínio — e é por este domínio que sai o "
              "código de entrar na app.")
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
