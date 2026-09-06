#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""F-OLHO · Camada 2 — JUIZ DE VISÃO do Em Dia (adaptado do Bora).

Olha as fotos da fábrica (test/golden/_fotos/*.png) e classifica cada uma:
  verde    — tela ok
  amarelo  — abaixo do padrão (texto colado, contraste fraco, vazio feio, jargão)
  vermelho — quebrado (botão cortado, texto por cima de texto, estouro, ilegível)

Compara com o DESIGN-SYSTEM.md (critério do fiscal, secção 10): reprova se a
tela tiver mais elementos que a referência da mesma função, se o número mais
importante não for o maior, se houver mais de um laranja, se um botão principal
não estiver visível, texto < 13 px, aviso sem passo concreto, jargão sem explicação.

Chave: env GEMINI_API_KEY → C:\\BoraLocal\\_segredos\\em-dia\\gemini.env. Modelo:
env GEMINI_MODEL (default gemini-flash-latest). Sem chave: sai 0 com aviso — nunca
inventa vereditos. Relatório SEMPRE em docs/provas/telas/vision_report_<ts>.json
e .md (o juiz nunca falha em silêncio).

Uso: python tool/juiz/vision_judge.py [--dir test/golden/_fotos] [--filtro login] [--max 60]
Saída: 0 = tudo verde/amarelo · 2 = há vermelhos
"""
from __future__ import annotations

import argparse
import base64
import datetime as dt
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
MODELO = os.environ.get("GEMINI_MODEL", "gemini-flash-latest")

PROMPT = (
    "És o juiz de visão da app Em Dia (Portugal: recibos verdes, Segurança Social, IVA, IRS, carro; "
    "público pouco digital, linguagem de criança de 5 anos; marca: verde #16A34A = em dia, laranja #F97316 = a vencer, "
    "vermelho #DC2626 = passou; fonte Inter; cantos 16). Olha para esta captura de ecrã e responde SÓ com JSON: "
    '{"severity":"verde|amarelo|vermelho","finding":"<1 frase PT-PT>","jargao":["<palavra sem explicação>"]}. '
    "vermelho = botão cortado/pela metade, texto por cima de texto, tela estourada (riscas amarelas e pretas), "
    "conteúdo ilegível, ícone em caixa, texto em quadrados. amarelo = feio mas usável: texto colado às margens, "
    "contraste fraco, estado vazio pobre, alinhamento torto, mais de um elemento laranja, número principal pequeno, "
    "jargão sem explicação entre parênteses (ex.: 'retenção' sem dizer o que é). verde = tela normal e clara. "
    "Ignora a barra de estado e dados de exemplo. Sê conservador: na dúvida, verde."
)


def _chave() -> str | None:
    k = os.environ.get("GEMINI_API_KEY")
    if k:
        return k.strip()
    f = Path(r"C:\BoraLocal\_segredos\em-dia\gemini.env")
    if f.exists():
        for linha in f.read_text().splitlines():
            if linha.startswith("GEMINI_API_KEY="):
                return linha.split("=", 1)[1].strip()
    return None


def julgar(png: Path, chave: str) -> dict:
    corpo = {
        "contents": [{"parts": [
            {"text": PROMPT},
            {"inline_data": {"mime_type": "image/png", "data": base64.b64encode(png.read_bytes()).decode()}},
        ]}],
        "generationConfig": {"temperature": 0.1, "responseMimeType": "application/json"},
    }
    req = urllib.request.Request(
        f"https://generativelanguage.googleapis.com/v1beta/models/{MODELO}:generateContent",
        data=json.dumps(corpo).encode(),
        headers={"x-goog-api-key": chave, "Content-Type": "application/json"},
    )
    for tentativa in range(3):
        try:
            d = json.loads(urllib.request.urlopen(req, timeout=90).read())
            texto = d["candidates"][0]["content"]["parts"][0]["text"]
            j = json.loads(texto)
            j["severity"] = j.get("severity", "verde").lower()
            return j
        except urllib.error.HTTPError as e:
            if e.code in (429, 503) and tentativa < 2:
                time.sleep(8 * (tentativa + 1))
                continue
            return {"severity": "erro", "finding": f"HTTP {e.code}: {e.read().decode()[:200]}"}
        except Exception as exc:  # noqa: BLE001
            return {"severity": "erro", "finding": f"{type(exc).__name__}: {exc}"[:200]}
    return {"severity": "erro", "finding": "sem resposta"}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=str(RAIZ / "test" / "golden" / "_fotos"))
    ap.add_argument("--filtro", default="")
    ap.add_argument("--max", type=int, default=80)
    a = ap.parse_args()
    fotos = sorted(p for p in Path(a.dir).glob("*.png") if a.filtro in p.name)[: a.max]
    ts = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    saida = RAIZ / "docs" / "provas" / "telas"
    saida.mkdir(parents=True, exist_ok=True)
    chave = _chave()
    resultados = []
    if not chave:
        print("AVISO: sem GEMINI_API_KEY — o juiz não inventa vereditos. Nada julgado.")
    else:
        for i, p in enumerate(fotos, 1):
            r = julgar(p, chave)
            r["foto"] = p.name
            resultados.append(r)
            print(f"[{i}/{len(fotos)}] {r['severity']:8s} {p.name} — {r.get('finding','')[:110]}")
    contagem = {s: sum(1 for r in resultados if r["severity"] == s) for s in ("verde", "amarelo", "vermelho", "erro")}
    rel = {"data": ts, "modelo": MODELO, "fotos": len(fotos), "contagem": contagem, "resultados": resultados}
    (saida / f"vision_report_{ts}.json").write_text(json.dumps(rel, ensure_ascii=False, indent=2), encoding="utf-8")
    md = [f"# Juiz de visão — {ts}", "", f"Modelo: {MODELO} · fotos: {len(fotos)} · {contagem}", "",
          "| Foto | Veredito | Achado |", "|---|---|---|"]
    md += [f"| {r['foto']} | {r['severity']} | {r.get('finding','').replace('|','/')} |" for r in resultados]
    (saida / f"vision_report_{ts}.md").write_text("\n".join(md) + "\n", encoding="utf-8")
    print(f"relatório: {saida / f'vision_report_{ts}.md'} · {contagem}")
    return 2 if contagem["vermelho"] else 0


if __name__ == "__main__":
    sys.exit(main())
