#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Junta as partes de tradução em lib/l10n/app_pt.arb e app_pt_BR.arb.

Cada tela tem a sua parte em lib/l10n/partes/<tela>_pt.arb e <tela>_pt_BR.arb
(assim vários agentes acrescentam textos sem pisar o mesmo ficheiro). Este
script junta tudo (00_comum primeiro), avisa de chaves repetidas e de chaves
que existem em PT e faltam em BR, e escreve os ficheiros finais que o
`flutter gen-l10n` lê. Correr sempre antes de `flutter gen-l10n`.
"""
import json
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
PARTES = RAIZ / "lib" / "l10n" / "partes"
DESTINO = RAIZ / "lib" / "l10n"


def juntar(sufixo: str, locale: str):
    saida = {"@@locale": locale}
    origem = {}
    for f in sorted(PARTES.glob(f"*_{sufixo}.arb")):
        dados = json.loads(f.read_text(encoding="utf-8"))
        for k, v in dados.items():
            if k == "@@locale":
                continue
            if k in saida and not k.startswith("@"):
                print(f"AVISO: chave repetida '{k}' em {f.name} (já vinha de {origem.get(k)}) — fica a primeira")
                continue
            saida[k] = v
            origem[k] = f.name
    return saida


def main() -> int:
    pt = juntar("pt", "pt")
    br = juntar("pt_BR", "pt_BR")
    chaves_pt = {k for k in pt if not k.startswith("@")}
    chaves_br = {k for k in br if not k.startswith("@")}
    faltam = sorted(chaves_pt - chaves_br)
    for k in faltam:
        # PT-BR cai para o texto PT-PT (o gen-l10n exige as mesmas chaves)
        br[k] = pt[k]
    if faltam:
        print(f"AVISO: {len(faltam)} chaves sem versão PT-BR (caíram para PT-PT): {', '.join(faltam[:12])}{'…' if len(faltam) > 12 else ''}")
    sobram = sorted(chaves_br - chaves_pt)
    for k in sobram:
        del br[k]
    if sobram:
        print(f"AVISO: {len(sobram)} chaves só em PT-BR foram ignoradas: {', '.join(sobram[:12])}")
    (DESTINO / "app_pt.arb").write_text(json.dumps(pt, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (DESTINO / "app_pt_BR.arb").write_text(json.dumps(br, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"app_pt.arb: {len(chaves_pt)} chaves · app_pt_BR.arb: {len({k for k in br if not k.startswith('@')})} chaves")
    return 0


if __name__ == "__main__":
    sys.exit(main())
