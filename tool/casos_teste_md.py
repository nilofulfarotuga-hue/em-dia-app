#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Gera docs/casos-teste.md a partir de test/unit/regras_test.dart.

A verdade executável são os testes; este documento é a leitura humana deles:
para cada caso, o nome (que já traz entrada → esperado) e as asserções.
Uso: python tool/casos_teste_md.py
"""
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
FONTE = RAIZ / "test" / "unit" / "regras_test.dart"
DESTINO = RAIZ / "docs" / "casos-teste.md"


def main() -> int:
    texto = FONTE.read_text(encoding="utf-8")
    grupos = []
    grupo_atual = None
    caso_atual = None
    for linha in texto.splitlines():
        m = re.match(r"\s*group\('([^']+)'", linha)
        if m:
            grupo_atual = {"nome": m.group(1), "casos": []}
            grupos.append(grupo_atual)
            caso_atual = None
            continue
        m = re.match(r"\s*test\('(C\d+) ([^']+)'", linha)
        if m and grupo_atual is not None:
            caso_atual = {"id": m.group(1), "nome": m.group(2), "expects": []}
            grupo_atual["casos"].append(caso_atual)
            continue
        if caso_atual is not None:
            m = re.match(r"\s*expect\((.+)\);\s*(//.*)?$", linha)
            if m:
                caso_atual["expects"].append(m.group(1).strip())
    total = sum(len(g["casos"]) for g in grupos)
    out = []
    out.append("# Casos de teste das regras — Em Dia")
    out.append("")
    out.append(f"> Gerado de `test/unit/regras_test.dart` por `tool/casos_teste_md.py`. **{total} casos.** "
               "O esperado foi calculado à mão a partir das regras de `regras_legais` (seed 0003). "
               "Se um caso falhar, mudou a regra ou o código — nunca se ajusta o esperado para bater.")
    out.append("")
    out.append("Correr: `flutter test test/unit -r compact` (última corrida verde: ver docs/MARCOS.md).")
    out.append("")
    for g in grupos:
        out.append(f"## {g['nome']}")
        out.append("")
        out.append("| # | Caso (entrada → esperado) | Asserções |")
        out.append("|---|---|---|")
        for c in g["casos"]:
            asserts = "<br>".join(f"`{e}`" for e in c["expects"]) or "—"
            asserts = asserts.replace("|", "\\|")
            out.append(f"| {c['id']} | {c['nome']} | {asserts} |")
        out.append("")
    DESTINO.write_text("\n".join(out) + "\n", encoding="utf-8")
    print(f"escrito {DESTINO} com {total} casos em {len(grupos)} grupos")
    return 0


if __name__ == "__main__":
    sys.exit(main())
