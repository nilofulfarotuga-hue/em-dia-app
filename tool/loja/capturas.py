#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Material gráfico da ficha da Play Store, a partir das capturas REAIS da app.

Produz em docs/loja/play/:
  icone-512.png          — ícone da loja (proposta vencedora da marca, 512×512, sem alfa)
  feature-1024x500.png   — feature graphic
  captura-1..8.png       — 1080×1920, foto real da app com a frase por cima

As capturas saem de test/golden/_fotos (a fábrica de fotos), nunca de maquetes:
é a app a sério, com os dados de exemplo dos testes.

Uso: python tool/loja/capturas.py
"""
from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

RAIZ = Path(__file__).resolve().parents[2]
FOTOS = RAIZ / "test" / "golden" / "_fotos"
MARCA = RAIZ / "docs" / "marca"
SAIDA = RAIZ / "docs" / "loja" / "play"
FONTE = RAIZ / "assets" / "fonts" / "Inter-VariableFont.ttf"

VERDE = (22, 163, 74)
VERDE_ESCURO = (13, 92, 43)
LARANJA = (249, 115, 22)
BRANCO = (255, 255, 255)
ESCURO = (17, 24, 39)

# (ficheiro da foto, frase, cor de fundo)
CAPTURAS = [
    ("painel_verde_medio_pt.png", "Estás em dia?\nA app responde num segundo.", VERDE),
    ("painel_vermelho_medio_pt.png", "Nunca mais levas multa\nda Segurança Social.", (185, 28, 28)),
    ("recibos_medio_pt.png", "Quanto fica mesmo para ti\ndepois da retenção e do IVA.", VERDE),
    ("recibos_irs_medio_pt.png", "Sabe quanto guardar\npara o IRS, todos os meses.", VERDE_ESCURO),
    ("calendario_medio_pt.png", "Todos os prazos num sítio.\nCom o valor e o dia certo.", VERDE),
    ("carro_medio_pt.png", "A inspeção do carro\navisa-te sozinha.", LARANJA),
    ("ia_medio_pt.png", "Pergunta o que quiseres,\nem português simples.", VERDE_ESCURO),
    ("reforma_medio_pt.png", "O que descontas hoje\nvale reforma amanhã.", VERDE),
]


def fonte(tamanho: int, peso: int = 700) -> ImageFont.FreeTypeFont:
    f = ImageFont.truetype(str(FONTE), tamanho)
    try:
        f.set_variation_by_axes([peso])
    except Exception:  # noqa: BLE001  (fonte não variável: fica o peso base)
        pass
    return f


def texto_centrado(d: ImageDraw.ImageDraw, caixa, txt: str, f, cor, espaco=1.25):
    x0, y0, x1, y1 = caixa
    linhas = txt.split("\n")
    alturas = [d.textbbox((0, 0), l, font=f)[3] - d.textbbox((0, 0), l, font=f)[1] for l in linhas]
    passo = max(alturas) * espaco
    total = passo * len(linhas)
    y = y0 + ((y1 - y0) - total) / 2
    for l in linhas:
        w = d.textlength(l, font=f)
        d.text((x0 + ((x1 - x0) - w) / 2, y), l, font=f, fill=cor)
        y += passo


def cantos(im: Image.Image, raio: int) -> Image.Image:
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, im.size[0] - 1, im.size[1] - 1], raio, fill=255)
    fora = Image.new("RGBA", im.size, (0, 0, 0, 0))
    fora.paste(im, (0, 0), mask)
    return fora


def faz_icone() -> Path:
    """Ícone 512×512 sem canal alfa (a Play recusa PNG com transparência)."""
    origem = Image.open(MARCA / "proposta-1.png").convert("RGBA").resize((512, 512), Image.LANCZOS)
    fundo = Image.new("RGB", (512, 512), BRANCO)
    fundo.paste(origem, (0, 0), origem)
    destino = SAIDA / "icone-512.png"
    fundo.save(destino, "PNG")
    return destino


def faz_feature() -> Path:
    """Feature graphic 1024×500: fundo verde com degradê, símbolo e o nome."""
    w, h = 1024, 500
    im = Image.new("RGB", (w, h), VERDE)
    d = ImageDraw.Draw(im)
    for y in range(h):  # degradê vertical simples verde → verde escuro
        t = y / h
        cor = tuple(int(VERDE[i] + (VERDE_ESCURO[i] - VERDE[i]) * t) for i in range(3))
        d.line([(0, y), (w, y)], fill=cor)
    # círculos suaves de fundo (profundidade, sem parecer cartaz plano)
    bolha = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    db = ImageDraw.Draw(bolha)
    db.ellipse([-120, 180, 320, 620], fill=(255, 255, 255, 18))
    db.ellipse([760, -160, 1180, 260], fill=(255, 255, 255, 14))
    im = Image.alpha_composite(im.convert("RGBA"), bolha).convert("RGB")
    d = ImageDraw.Draw(im)
    simbolo = Image.open(MARCA / "proposta-1.png").convert("RGBA").resize((300, 300), Image.LANCZOS)
    im.paste(simbolo, (72, 100), simbolo)
    d.text((420, 168), "Em Dia", font=fonte(92, 800), fill=BRANCO)
    d.text((424, 276), "Recibos verdes, impostos e o carro", font=fonte(34, 500), fill=(226, 246, 233))
    d.text((424, 322), "sempre em dia — em português.", font=fonte(34, 500), fill=(226, 246, 233))
    destino = SAIDA / "feature-1024x500.png"
    im.save(destino, "PNG")
    return destino


def faz_capturas() -> list[Path]:
    feitas = []
    W, H = 1080, 1920
    for i, (ficheiro, frase, cor) in enumerate(CAPTURAS, 1):
        origem = FOTOS / ficheiro
        if not origem.exists():
            print(f"  FALTA {ficheiro} — capturа saltada")
            continue
        foto = Image.open(origem).convert("RGB")
        im = Image.new("RGB", (W, H), cor)
        d = ImageDraw.Draw(im)
        # frase no topo
        texto_centrado(d, (60, 90, W - 60, 420), frase, fonte(64, 800), BRANCO)
        # foto do telemóvel, com cantos e sombra
        largura = W - 200
        altura = int(foto.size[1] * largura / foto.size[0])
        alvo = foto.resize((largura, altura), Image.LANCZOS)
        alvo = cantos(alvo.convert("RGBA"), 48)
        y = 470
        visivel = min(altura, H - y - 60)
        sombra = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        ImageDraw.Draw(sombra).rounded_rectangle([100 + 8, y + 14, 100 + largura + 8, y + visivel + 14], 48, fill=(0, 0, 0, 60))
        im = Image.alpha_composite(im.convert("RGBA"), sombra)
        im.paste(alvo.crop((0, 0, largura, visivel)), (100, y), alvo.crop((0, 0, largura, visivel)))
        destino = SAIDA / f"captura-{i}.png"
        im.convert("RGB").save(destino, "PNG")
        feitas.append(destino)
    return feitas


def main() -> int:
    SAIDA.mkdir(parents=True, exist_ok=True)
    ic = faz_icone()
    print(f"ícone      {ic.name}  {Image.open(ic).size}  {ic.stat().st_size // 1024} KB")
    fe = faz_feature()
    print(f"feature    {fe.name}  {Image.open(fe).size}  {fe.stat().st_size // 1024} KB")
    for p in faz_capturas():
        print(f"captura    {p.name}  {Image.open(p).size}  {p.stat().st_size // 1024} KB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
