#!/usr/bin/env python3
"""Em Dia — gera supabase/seed/guias.sql a partir de supabase/seed/guias/*.md.

Cada .md tem frontmatter YAML simples (chave: valor, uma por linha), o corpo PT-PT,
a linha `---BR---` e o corpo PT-BR. `verificado_em: POR CONFIRMAR` vira NULL.
Só stdlib. Uso:

    python tool/guias/carregar.py            # escreve supabase/seed/guias.sql
    python tool/guias/carregar.py --check    # só valida e conta palavras, não escreve
"""
from __future__ import annotations

import re
import sys
from datetime import date
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
PASTA = RAIZ / "supabase" / "seed" / "guias"
SAIDA = RAIZ / "supabase" / "seed" / "guias.sql"

CATEGORIAS = {"atividade", "impostos", "seguranca_social", "tvde", "estafeta", "imigrante", "carro"}
OBRIGATORIOS = ("slug", "titulo", "resumo", "categoria", "ordem", "fonte_url", "verificado_em")
SEPARADOR_BR = "---BR---"
DOLLAR = "$g$"
LIMITE_PALAVRAS = 220


def parse(md: Path) -> dict:
    texto = md.read_text(encoding="utf-8").replace("\r\n", "\n")
    if not texto.startswith("---\n"):
        raise ValueError(f"{md.name}: falta o frontmatter no início")
    fim = texto.find("\n---\n", 4)
    if fim < 0:
        raise ValueError(f"{md.name}: frontmatter sem fecho '---'")
    meta: dict[str, str] = {}
    for linha in texto[4:fim].split("\n"):
        if not linha.strip():
            continue
        chave, sep, valor = linha.partition(":")
        if not sep:
            raise ValueError(f"{md.name}: linha de frontmatter inválida: {linha!r}")
        meta[chave.strip()] = valor.strip()
    corpo = texto[fim + len("\n---\n"):]
    if SEPARADOR_BR not in corpo:
        raise ValueError(f"{md.name}: falta a linha {SEPARADOR_BR}")
    pt, _, br = corpo.partition(SEPARADOR_BR + "\n")
    meta["corpo_pt"] = pt.strip() + "\n"
    meta["corpo_br"] = br.strip() + "\n"
    return meta


def validar(g: dict, nome: str) -> None:
    for k in OBRIGATORIOS:
        if not g.get(k):
            raise ValueError(f"{nome}: falta '{k}' no frontmatter")
    if g["slug"] != Path(nome).stem:
        raise ValueError(f"{nome}: slug '{g['slug']}' diferente do nome do ficheiro")
    if g["categoria"] not in CATEGORIAS:
        raise ValueError(f"{nome}: categoria '{g['categoria']}' não está em {sorted(CATEGORIAS)}")
    if not g["ordem"].isdigit():
        raise ValueError(f"{nome}: ordem '{g['ordem']}' não é número")
    v = g["verificado_em"]
    if v != "POR CONFIRMAR" and not re.fullmatch(r"\d{4}-\d{2}-\d{2}", v):
        raise ValueError(f"{nome}: verificado_em '{v}' tem de ser AAAA-MM-DD ou POR CONFIRMAR")
    for campo in ("corpo_pt", "corpo_br"):
        if DOLLAR in g[campo]:
            raise ValueError(f"{nome}: o {campo} contém {DOLLAR}, não pode ser dollar-quoted")
        if "Fonte:" not in g[campo] or "Verificado em:" not in g[campo]:
            raise ValueError(f"{nome}: o {campo} não termina com 'Fonte: … · Verificado em: …'")


def palavras(s: str) -> int:
    return len(s.split())


def sql_txt(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + s.replace("'", "''") + "'"


def sql_corpo(s: str) -> str:
    return f"{DOLLAR}{s}{DOLLAR}"


def sql_data(v: str) -> str:
    return "null" if v == "POR CONFIRMAR" else f"'{v}'"


def gerar(guias: list[dict]) -> str:
    linhas = [
        f"-- Em Dia — seed dos guias de 1 minuto (gerado por tool/guias/carregar.py em {date.today().isoformat()})",
        f"-- Fonte: supabase/seed/guias/*.md ({len(guias)} guias). Não editar à mão: edita o .md e volta a correr o script.",
        "-- verificado_em = null quando o .md diz POR CONFIRMAR.",
        "",
    ]
    for g in guias:
        linhas.append(
            "insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, categoria, ordem, fonte_url, publicado, verificado_em) values ("
        )
        linhas.append(f"  {sql_txt(g['slug'])},")
        linhas.append(f"  {sql_txt(g['titulo'])},")
        linhas.append(f"  {sql_txt(g['resumo'])},")
        linhas.append(f"  {sql_corpo(g['corpo_pt'])},")
        linhas.append(f"  {sql_corpo(g['corpo_br'])},")
        linhas.append(f"  {sql_txt(g['categoria'])},")
        linhas.append(f"  {int(g['ordem'])},")
        linhas.append(f"  {sql_txt(g['fonte_url'])},")
        linhas.append("  true,")
        linhas.append(f"  {sql_data(g['verificado_em'])}")
        linhas.append(")")
        linhas.append(
            "on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt,"
        )
        linhas.append(
            "  corpo_br = excluded.corpo_br, categoria = excluded.categoria, ordem = excluded.ordem, fonte_url = excluded.fonte_url,"
        )
        linhas.append("  publicado = excluded.publicado, verificado_em = excluded.verificado_em;")
        linhas.append("")
    return "\n".join(linhas)


def main(argv: list[str]) -> int:
    for fluxo in (sys.stdout, sys.stderr):  # console do Windows em cp850 estraga os acentos
        if hasattr(fluxo, "reconfigure"):
            fluxo.reconfigure(encoding="utf-8")
    so_check = "--check" in argv
    ficheiros = sorted(PASTA.glob("*.md"))
    if not ficheiros:
        print(f"ERRO: nenhum .md em {PASTA}", file=sys.stderr)
        return 1
    guias: list[dict] = []
    erros: list[str] = []
    for md in ficheiros:
        try:
            g = parse(md)
            validar(g, md.name)
            guias.append(g)
        except ValueError as e:
            erros.append(str(e))
    if erros:
        for e in erros:
            print("ERRO:", e, file=sys.stderr)
        return 1
    guias.sort(key=lambda g: int(g["ordem"]))

    print(f"{'slug':38} {'PT':>5} {'BR':>5}  verificado_em")
    avisos = 0
    for g in guias:
        npt, nbr = palavras(g["corpo_pt"]), palavras(g["corpo_br"])
        marca = ""
        if npt > LIMITE_PALAVRAS:
            marca = f"  AVISO: PT > {LIMITE_PALAVRAS} palavras"
            avisos += 1
        print(f"{g['slug']:38} {npt:5} {nbr:5}  {g['verificado_em']}{marca}")

    if so_check:
        print(f"\n{len(guias)} guias válidos, {avisos} avisos. (modo --check: nada escrito)")
        return 0 if avisos == 0 else 2

    SAIDA.write_text(gerar(guias), encoding="utf-8", newline="\n")
    print(f"\nEscrito {SAIDA} com {len(guias)} inserts.")
    return 0 if avisos == 0 else 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
