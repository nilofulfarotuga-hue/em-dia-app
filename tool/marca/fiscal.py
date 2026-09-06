#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fiscal visual das propostas de ícone: pede ao Gemini (texto+visão) pontuações 0-10 em JSON.

Critérios: legibilidade a 48 px, coerência com "em dia / visto / calendário", modernidade, ausência de texto/ruído.
Roda de modelos em 429: gemini-flash-latest → gemini-3.7-flash → gemini-3.6-flash → gemini-flash-lite-latest.
Cada proposta = 1 pedido (imagem 1024 + imagem 48 px no mesmo pedido). Se todos os modelos derem 429,
grava {"erro": ...} e o executor faz a avaliação manual (fica escrito no README).

Uso: python tool/marca/fiscal.py [--n 1 2 3 4 5] → docs/marca/pontuacoes.json
"""
import argparse
import base64
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from gerar import chave, pedir, registar  # noqa: E402

RAIZ = Path(__file__).resolve().parents[2]
MARCA = RAIZ / "docs" / "marca"
MODELOS_VISAO = ["gemini-flash-latest", "gemini-3.7-flash", "gemini-3.6-flash", "gemini-flash-lite-latest"]

PROMPT = (
    "You are a strict app-icon reviewer. Two images follow: the first is a 1024x1024 app icon proposal, the second is the "
    "SAME icon downscaled to 48x48 (how it looks on a phone home screen). The app is 'Em Dia' (Portuguese for 'up to date'): "
    "it reminds self-employed workers of Social Security / VAT / tax deadlines and car deadlines. The brand theme is a green "
    "check mark inside a calendar or a traffic light.\n"
    "Score 0-10 (integers) on: legibilidade_48px (is the main symbol instantly recognisable at 48px?), "
    "coerencia (does it say 'em dia / check / calendar'?), modernidade (modern, premium, not clip-art), "
    "sem_texto_ruido (10 = no text, no noise, no unnecessary details). Then a one-sentence 'comentario' in European Portuguese.\n"
    "Answer with ONLY a JSON object: {\"legibilidade_48px\": n, \"coerencia\": n, \"modernidade\": n, \"sem_texto_ruido\": n, "
    "\"comentario\": \"...\"}"
)


def b64(p: Path) -> str:
    return base64.b64encode(p.read_bytes()).decode()


def julgar(n: int, k: str, modelos_ok: list) -> dict:
    partes = [
        {"text": PROMPT},
        {"inlineData": {"mimeType": "image/png", "data": b64(MARCA / f"proposta-{n}.png")}},
        {"inlineData": {"mimeType": "image/png", "data": b64(MARCA / f"proposta-{n}-48px.png")}},
    ]
    for modelo in list(modelos_ok):
        print(f"  proposta {n} -> {modelo}", flush=True)
        codigo, d = pedir(modelo, partes, k, ["TEXT"], timeout=180)
        if codigo == 200:
            txt = "".join(p.get("text", "") for p in d["candidates"][0]["content"]["parts"])
            registar(modelo, "200", f"fiscal proposta {n}")
            inicio, fim = txt.find("{"), txt.rfind("}")
            try:
                r = json.loads(txt[inicio:fim + 1])
            except Exception:
                r = {"erro": "json inválido", "bruto": txt[:300]}
            r["modelo"] = modelo
            return r
        registar(modelo, str(codigo), f"fiscal proposta {n} " + str(d)[:120].replace("\n", " "))
        print(f"    HTTP {codigo}: {str(d)[:160]}")
        if codigo == 429:
            modelos_ok.remove(modelo)  # quota do dia deste modelo: não volta a tentar
    return {"erro": "todos os modelos de visão em 429/erro", "modelo": None}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, nargs="+", default=[1, 2, 3, 4, 5])
    a = ap.parse_args()
    k = chave()
    modelos_ok = list(MODELOS_VISAO)
    saida = MARCA / "pontuacoes.json"
    res = json.loads(saida.read_text(encoding="utf-8")) if saida.exists() else {}
    for n in a.n:
        if not modelos_ok:
            res[str(n)] = {"erro": "sem modelos de visão com quota", "modelo": None}
            continue
        res[str(n)] = julgar(n, k, modelos_ok)
        print("   ", json.dumps(res[str(n)], ensure_ascii=False)[:300])
    saida.write_text(json.dumps(res, ensure_ascii=False, indent=2), encoding="utf-8")
    print("gravado", saida)
    return 0


if __name__ == "__main__":
    sys.exit(main())
