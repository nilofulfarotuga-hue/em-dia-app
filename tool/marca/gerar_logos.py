#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Gera as propostas de logo/ícone do Em Dia pela API Gemini (modelo de imagem).

Tema (ordem da missão): um visto verde dentro de um calendário ou de um semáforo,
moderno, legível a 48 px, "imagem impressionante de cinema, não cartaz plano".
Saída: docs/marca/proposta-NN.png + docs/marca/index.md (prompt e modelo de cada uma).
Chave: C:\\BoraLocal\\_segredos\\em-dia\\gemini.env (nunca no repo).
Uso: python tool/marca/gerar_logos.py [--modelo nano-banana-pro-preview] [--n 5]
"""
import argparse
import base64
import datetime as dt
import json
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
SAIDA = RAIZ / "docs" / "marca"

PROMPTS = [
    ("visto-calendario",
     "App icon design for a Portuguese personal-finance app called 'Em Dia'. A bold green check mark (#16A34A) "
     "inside a minimal calendar page, flat vector, rounded square icon with subtle depth and soft cinematic lighting, "
     "light background, no text, crisp edges readable at 48 px. Modern, friendly, premium."),
    ("semaforo-verde",
     "App icon for 'Em Dia': a stylized traffic light where the green lamp is a check mark, orange and red lamps dimmed, "
     "flat vector on a rounded square, soft studio light, light background, no text, readable at 48 px."),
    ("visto-circulo-cinema",
     "Cinematic app icon: a glossy green circle (#16A34A) with a white check mark, floating above a pale green surface "
     "with a gentle shadow, subtle rim light, minimal, no text, rounded square icon, premium fintech feel."),
    ("calendario-dia-marcado",
     "Flat vector app icon: a calendar sheet with one day highlighted in green and a small check mark on it, "
     "orange dot for 'due soon' as a tiny accent, Inter-like geometry, light background, no text, 48 px legibility."),
    ("v-folha-verde",
     "Minimal app icon: a check mark that turns into a green leaf, symbolizing 'all in order', gradient green "
     "(#16A34A to #22C55E), rounded square, soft cinematic lighting, no text, readable at 48 px."),
]


def chave() -> str:
    for linha in Path(r"C:\BoraLocal\_segredos\em-dia\gemini.env").read_text().splitlines():
        if linha.startswith("GEMINI_API_KEY="):
            return linha.split("=", 1)[1].strip()
    raise SystemExit("sem GEMINI_API_KEY")


def gerar(modelo: str, prompt: str, k: str) -> bytes | None:
    corpo = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"responseModalities": ["IMAGE"], "imageConfig": {"aspectRatio": "1:1"}},
    }
    req = urllib.request.Request(
        f"https://generativelanguage.googleapis.com/v1beta/models/{modelo}:generateContent",
        data=json.dumps(corpo).encode(),
        headers={"x-goog-api-key": k, "Content-Type": "application/json"},
    )
    for tentativa in range(3):
        try:
            d = json.loads(urllib.request.urlopen(req, timeout=180).read())
            for parte in d["candidates"][0]["content"]["parts"]:
                dados = parte.get("inlineData") or parte.get("inline_data")
                if dados:
                    return base64.b64decode(dados["data"])
            print("  sem imagem na resposta:", json.dumps(d)[:300])
            return None
        except urllib.error.HTTPError as e:
            texto = e.read().decode()[:300]
            print(f"  HTTP {e.code}: {texto}")
            if e.code in (429, 503) and tentativa < 2:
                time.sleep(15 * (tentativa + 1))
                continue
            return None
    return None


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--modelo", default="nano-banana-pro-preview")
    ap.add_argument("--n", type=int, default=5)
    a = ap.parse_args()
    SAIDA.mkdir(parents=True, exist_ok=True)
    k = chave()
    linhas = [f"# Propostas de logo — Em Dia", "", f"Geradas a {dt.date.today().isoformat()} pela API Gemini (modelo `{a.modelo}`). "
              "Tema: visto verde dentro de um calendário ou semáforo, moderno, legível a 48 px.", ""]
    ok = 0
    for i, (nome, prompt) in enumerate(PROMPTS[: a.n], 1):
        print(f"[{i}] {nome} …")
        img = gerar(a.modelo, prompt, k)
        if img:
            destino = SAIDA / f"proposta-{i:02d}-{nome}.png"
            destino.write_bytes(img)
            ok += 1
            linhas.append(f"## Proposta {i} — `{destino.name}`\n\n![{nome}]({destino.name})\n\nPrompt: {prompt}\n")
            print(f"  ok {len(img)} bytes → {destino.name}")
        else:
            linhas.append(f"## Proposta {i} — FALHOU ({nome})\n")
    (SAIDA / "index.md").write_text("\n".join(linhas) + "\n", encoding="utf-8")
    print(f"{ok}/{min(a.n, len(PROMPTS))} propostas em {SAIDA}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
