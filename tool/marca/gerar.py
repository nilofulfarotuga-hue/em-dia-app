#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Gera UMA imagem pela API Gemini (modelos de imagem) com roda de modelos em 429/503.

Uso:
  python tool/marca/gerar.py --prompt "..." --saida docs/marca/proposta-1.png
  python tool/marca/gerar.py --prompt "..." --saida x.png --referencia docs/marca/proposta-3.png  (refinamento)

Chave: C:\\BoraLocal\\_segredos\\em-dia\\gemini.env (GEMINI_API_KEY=...). NUNCA escrita em ficheiros do repo.
Quota grátis: 20 pedidos/dia POR MODELO → em 429 passa ao modelo seguinte.
Cada pedido fica registado (modelo, código HTTP, bytes) em docs/marca/pedidos.log.
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
LOG = RAIZ / "docs" / "marca" / "pedidos.log"
CHAVE_FICHEIRO = Path(r"C:\BoraLocal\_segredos\em-dia\gemini.env")

MODELOS_IMAGEM = ["gemini-3.1-flash-image", "nano-banana-pro-preview", "gemini-3-pro-image",
                  "gemini-3.1-flash-image-preview", "gemini-3-pro-image-preview", "gemini-2.5-flash-image",
                  "gemini-3.1-flash-lite-image"]
URL = "https://generativelanguage.googleapis.com/v1beta/models/{m}:generateContent"


def chave() -> str:
    for linha in CHAVE_FICHEIRO.read_text(encoding="utf-8").splitlines():
        if linha.startswith("GEMINI_API_KEY="):
            return linha.split("=", 1)[1].strip()
    raise SystemExit("sem GEMINI_API_KEY em " + str(CHAVE_FICHEIRO))


def registar(modelo: str, codigo: str, extra: str = "") -> None:
    LOG.parent.mkdir(parents=True, exist_ok=True)
    with LOG.open("a", encoding="utf-8") as f:
        f.write(f"{dt.datetime.now().isoformat(timespec='seconds')}\t{modelo}\t{codigo}\t{extra}\n")


def pedir(modelo: str, partes: list, k: str, modalidades: list, timeout: int = 240):
    """Faz 1 pedido. Devolve (codigo_http, json_ou_texto)."""
    corpo = {
        "contents": [{"parts": partes}],
        "generationConfig": {"responseModalities": modalidades},
    }
    req = urllib.request.Request(
        URL.format(m=modelo),
        data=json.dumps(corpo).encode(),
        headers={"x-goog-api-key": k, "Content-Type": "application/json"},
    )
    try:
        resp = urllib.request.urlopen(req, timeout=timeout)
        return resp.status, json.loads(resp.read())
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode(errors="replace")[:400]
    except Exception as e:  # rede, timeout
        return 0, repr(e)[:400]


def extrair_imagem(d: dict) -> bytes | None:
    for cand in d.get("candidates", []):
        for parte in cand.get("content", {}).get("parts", []):
            dados = parte.get("inlineData") or parte.get("inline_data")
            if dados and dados.get("data"):
                return base64.b64decode(dados["data"])
    return None


def gerar_imagem(prompt: str, k: str, referencia: Path | None = None, modelos=None) -> tuple[bytes | None, str]:
    """Roda de modelos: 429 → próximo; 503 → espera 20 s e repete 1x, depois próximo."""
    modelos = modelos or MODELOS_IMAGEM
    partes = [{"text": prompt}]
    if referencia:
        partes.append({"inlineData": {"mimeType": "image/png",
                                      "data": base64.b64encode(referencia.read_bytes()).decode()}})
    for modelo in modelos:
        for tentativa in range(2):
            print(f"  -> {modelo} (tentativa {tentativa + 1})", flush=True)
            codigo, d = pedir(modelo, partes, k, ["IMAGE", "TEXT"])
            if codigo == 200:
                img = extrair_imagem(d)
                if img:
                    registar(modelo, "200", f"{len(img)} bytes")
                    return img, modelo
                registar(modelo, "200-sem-imagem", json.dumps(d)[:200])
                print("  200 mas sem imagem:", json.dumps(d)[:300])
                break  # modelo respondeu sem imagem → tenta o seguinte
            registar(modelo, str(codigo), str(d)[:200])
            print(f"  HTTP {codigo}: {str(d)[:200]}")
            if codigo == 429:
                break  # quota do dia deste modelo → próximo modelo
            if codigo in (503, 0) and tentativa == 0:
                time.sleep(20)
                continue
            break
    return None, ""


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--saida", required=True)
    ap.add_argument("--referencia", default=None, help="PNG de referência (refinamento)")
    ap.add_argument("--modelo", default=None, help="força modelo(s), separados por vírgula (senão roda)")
    a = ap.parse_args()
    k = chave()
    modelos = a.modelo.split(",") if a.modelo else None
    img, modelo = gerar_imagem(a.prompt, k, Path(a.referencia) if a.referencia else None, modelos)
    if not img:
        print("FALHOU: nenhum modelo devolveu imagem")
        return 1
    destino = Path(a.saida)
    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_bytes(img)
    print(f"OK {modelo} -> {destino} ({len(img)} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
