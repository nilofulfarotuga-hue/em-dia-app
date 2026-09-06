#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Desenha as 5 propostas de ícone do Em Dia em vetor (Pillow, supersampling 2x) e os derivados.

Porquê Pillow e não Gemini: a 2026-09-06 a chave grátis tem limite 0 para os modelos de imagem
(429 com quotaValue=None em todos: ver docs/marca/pedidos.log). Este ficheiro é o fallback
determinístico: cores da marca (docs/DESIGN-SYSTEM.md), sem texto, legível a 48 px.

Uso:
  python tool/marca/desenhar.py propostas            → docs/marca/proposta-1..5.png (1024, canto arredondado)
  python tool/marca/desenhar.py icones --n 3         → assets/branding/icon.png, icon_foreground.png,
                                                        docs/marca/escolhida.png, favicon, web/icons/*
  python tool/marca/desenhar.py feature --n 3        → docs/marca/feature-graphic-1024x500.png
"""
import argparse
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

RAIZ = Path(__file__).resolve().parents[2]
VERDE = (0x16, 0xA3, 0x4A)
VERDE_ESC = (0x15, 0x80, 0x3D)
VERDE_ESC2 = (0x06, 0x5F, 0x46)
VERDE_CLARO = (0x22, 0xC5, 0x5E)
VERDE_FUNDO = (0xDC, 0xFC, 0xE7)
LARANJA = (0xF9, 0x73, 0x16)
VERMELHO = (0xDC, 0x26, 0x26)
FUNDO = (0xF6, 0xF7, 0xF4)
BRANCO = (255, 255, 255)
CINZA_ESC = (0x1F, 0x29, 0x37)
CINZA = (0x6B, 0x72, 0x80)
CINZA_CLARO = (0xE5, 0xE7, 0xEB)
FONTE = RAIZ / "assets" / "fonts" / "Inter-VariableFont.ttf"

S = 2  # supersampling


def _mix(a, b, t):
    return tuple(int(round(a[i] * (1 - t) + b[i] * t)) for i in range(3))


def gradiente(w, h, cor1, cor2, diagonal=False):
    """Gradiente vertical (ou diagonal) cor1→cor2."""
    base = Image.new("RGB", (w, h))
    px = base.load()
    for y in range(h):
        for x in range(w) if diagonal else (0,):
            t = ((x + y) / (w + h - 2)) if diagonal else (y / max(1, h - 1))
            c = _mix(cor1, cor2, t)
            if diagonal:
                px[x, y] = c
            else:
                for xx in range(w):
                    px[xx, y] = c
                break
    return base


def rr(draw, box, r, fill):
    draw.rounded_rectangle(box, radius=r, fill=fill)


def visto(draw, cx, cy, tam, esp, fill):
    """Visto (✓) centrado em (cx, cy); tam = largura total; esp = espessura do traço."""
    p1 = (cx - tam * 0.50, cy + tam * 0.02)
    p2 = (cx - tam * 0.14, cy + tam * 0.36)
    p3 = (cx + tam * 0.50, cy - tam * 0.34)
    draw.line([p1, p2, p3], fill=fill, width=int(esp), joint="curve")
    for p in (p1, p3):
        draw.ellipse([p[0] - esp / 2, p[1] - esp / 2, p[0] + esp / 2, p[1] + esp / 2], fill=fill)


def sombra(base, forma_fn, deslocamento, raio, alfa):
    """Desenha a forma em preto numa camada, desfoca e compõe como sombra suave."""
    w, h = base.size
    camada = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(camada)
    forma_fn(d, (0, 0, 0, alfa))
    camada = camada.filter(ImageFilter.GaussianBlur(raio))
    deslocada = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    deslocada.paste(camada, deslocamento)
    base.alpha_composite(deslocada)


def brilho(base, cx, cy, raio, cor, alfa, desfoque):
    w, h = base.size
    camada = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(camada).ellipse([cx - raio, cy - raio, cx + raio, cy + raio], fill=cor + (alfa,))
    base.alpha_composite(camada.filter(ImageFilter.GaussianBlur(desfoque)))


# ---------------------------------------------------------------- símbolos (em coordenadas 0..1 do canvas)
def simbolo_calendario_visto(img, ox, oy, L, com_estrada=False, refinado=False):
    """Calendário branco, cabeçalho verde, argolas, visto verde grande. Caixa (ox,oy,L).
    refinado=True: "simpler, bolder, thicker strokes, fewer details" — sem contorno, argolas maiores,
    cabeçalho mais alto, visto maior e mais grosso."""
    d = ImageDraw.Draw(img)
    x0, y0 = ox + L * 0.06, oy + L * (0.12 if not com_estrada else 0.04)
    x1, y1 = ox + L * 0.94, oy + L * (0.94 if not com_estrada else 0.74)
    r = L * 0.10
    sombra(img, lambda dd, c: dd.rounded_rectangle([x0, y0, x1, y1], radius=r, fill=c),
           (0, int(L * 0.03)), L * 0.035, 70)
    d = ImageDraw.Draw(img)
    rr(d, [x0, y0, x1, y1], r, BRANCO)
    if not refinado:
        d.rounded_rectangle([x0, y0, x1, y1], radius=r, outline=CINZA_CLARO, width=max(1, int(L * 0.008)))
    cab = (y1 - y0) * (0.27 if refinado else 0.24)
    rr(d, [x0, y0, x1, y0 + cab + r], r, VERDE)
    d.rectangle([x0, y0 + cab - 1, x1, y0 + cab + r], fill=BRANCO)  # esquina inferior do cabeçalho reta
    d.rectangle([x0, y0 + cab * 0.55, x1, y0 + cab], fill=VERDE)
    # argolas
    for fx in (0.30, 0.70):
        ax = x0 + (x1 - x0) * fx
        aw, ah = (L * 0.065, L * 0.18) if refinado else (L * 0.045, L * 0.16)
        d.rounded_rectangle([ax - aw / 2, y0 - ah * 0.45, ax + aw / 2, y0 + ah * 0.55], radius=aw / 2, fill=VERDE_ESC2)
    # visto
    corpo_cy = y0 + cab + ((y1 - (y0 + cab)) / 2)
    tam = (x1 - x0) * (0.64 if refinado else 0.56)
    visto(d, (x0 + x1) / 2, corpo_cy, tam, tam * (0.25 if refinado else 0.21), VERDE)
    if com_estrada:
        # estrada curva subtil por baixo, com traço central branco descontínuo
        ex0, ey = ox, oy + L * 0.98
        pontos = []
        n = 40
        for i in range(n + 1):
            t = i / n
            px = ox + L * t
            py = ey - L * 0.20 * (4 * t * (1 - t))  # arco suave
            pontos.append((px, py))
        d.line(pontos, fill=CINZA, width=int(L * 0.12), joint="curve")
        for i in range(2, n - 2, 6):
            d.line([pontos[i], pontos[i + 2]], fill=BRANCO, width=int(L * 0.018))


def simbolo_semaforo(img, ox, oy, L):
    d = ImageDraw.Draw(img)
    x0, y0, x1, y1 = ox + L * 0.29, oy + L * 0.03, ox + L * 0.71, oy + L * 0.97
    r = L * 0.13
    sombra(img, lambda dd, c: dd.rounded_rectangle([x0, y0, x1, y1], radius=r, fill=c), (0, int(L * 0.03)), L * 0.04, 80)
    d = ImageDraw.Draw(img)
    rr(d, [x0, y0, x1, y1], r, CINZA_ESC)
    cx = (x0 + x1) / 2
    raio = (x1 - x0) * 0.37
    for i, (cor, aceso) in enumerate(((VERMELHO, False), (LARANJA, False), (VERDE_CLARO, True))):
        cy = y0 + (y1 - y0) * (0.18 + 0.32 * i)
        if aceso:
            brilho(img, cx, cy, raio * 2.0, VERDE_CLARO, 170, L * 0.05)
            d = ImageDraw.Draw(img)
            d.ellipse([cx - raio, cy - raio, cx + raio, cy + raio], fill=VERDE)
            visto(d, cx, cy + raio * 0.02, raio * 1.35, raio * 0.32, BRANCO)
        else:
            d.ellipse([cx - raio, cy - raio, cx + raio, cy + raio], fill=_mix(cor, CINZA_ESC, 0.42))


def simbolo_circulo_dia(img, ox, oy, L):
    d = ImageDraw.Draw(img)
    cx, cy, raio = ox + L * 0.46, oy + L * 0.46, L * 0.38
    sombra(img, lambda dd, c: dd.ellipse([cx - raio, cy - raio, cx + raio, cy + raio], fill=c), (0, int(L * 0.03)), L * 0.04, 80)
    d = ImageDraw.Draw(img)
    d.ellipse([cx - raio, cy - raio, cx + raio, cy + raio], fill=VERDE)
    visto(d, cx, cy + raio * 0.02, raio * 1.22, raio * 0.30, BRANCO)
    # etiqueta de dia de calendário no canto inferior direito
    t = L * 0.30
    bx0, by0 = ox + L * 0.68, oy + L * 0.66
    sombra(img, lambda dd, c: dd.rounded_rectangle([bx0, by0, bx0 + t, by0 + t], radius=t * 0.18, fill=c), (0, int(L * 0.02)), L * 0.03, 90)
    d = ImageDraw.Draw(img)
    rr(d, [bx0, by0, bx0 + t, by0 + t], t * 0.18, BRANCO)
    d.rounded_rectangle([bx0, by0, bx0 + t, by0 + t], radius=t * 0.18, outline=CINZA_CLARO, width=max(1, int(L * 0.008)))
    rr(d, [bx0, by0, bx0 + t, by0 + t * 0.34 + t * 0.18], t * 0.18, VERDE_ESC)
    d.rectangle([bx0, by0 + t * 0.34 - 1, bx0 + t, by0 + t * 0.34 + t * 0.18], fill=BRANCO)
    d.rectangle([bx0, by0 + t * 0.18, bx0 + t, by0 + t * 0.34], fill=VERDE_ESC)
    pc = L * 0.045
    d.ellipse([bx0 + t / 2 - pc, by0 + t * 0.66 - pc, bx0 + t / 2 + pc, by0 + t * 0.66 + pc], fill=LARANJA)


def simbolo_monograma(img, ox, oy, L):
    """E + D abstratos em branco; a barra do meio do E vira o visto que entra na barriga do D."""
    d = ImageDraw.Draw(img)
    esp = L * 0.10
    top, bot = oy + L * 0.22, oy + L * 0.78
    cy = (top + bot) / 2
    # E: barra vertical + barras de cima e de baixo (a do meio é o visto)
    ex = ox + L * 0.10
    d.rounded_rectangle([ex, top, ex + esp, bot], radius=esp / 2, fill=BRANCO)
    for fy in (top, bot):
        d.rounded_rectangle([ex, fy - esp / 2, ex + L * 0.30, fy + esp / 2], radius=esp / 2, fill=BRANCO)
    # D: barra vertical + meia-lua (arco de 180°) fechada com as barras de cima e de baixo
    dx = ox + L * 0.46
    d.rounded_rectangle([dx, top, dx + esp, bot], radius=esp / 2, fill=BRANCO)
    cx = dx + esp / 2
    ra = (bot - top) / 2
    d.arc([cx - ra, cy - ra, cx + ra, cy + ra], start=-90, end=90, fill=BRANCO, width=int(esp))
    d.rectangle([cx, top - esp / 2, cx + ra * 0.05, top + esp / 2], fill=BRANCO)
    d.rectangle([cx, bot - esp / 2, cx + ra * 0.05, bot + esp / 2], fill=BRANCO)
    # visto: a barra do meio do E sai para a direita e sobe pela barriga do D
    p1 = (ex + esp * 0.5, cy)
    p2 = (dx + esp * 0.5 + ra * 0.28, cy + ra * 0.34)
    p3 = (cx + ra * 0.72, cy - ra * 0.36)
    d.line([p1, p2, p3], fill=BRANCO, width=int(esp), joint="curve")
    d.ellipse([p3[0] - esp / 2, p3[1] - esp / 2, p3[0] + esp / 2, p3[1] + esp / 2], fill=BRANCO)


# ---------------------------------------------------------------- propostas
PROPOSTAS = {
    1: dict(nome="visto-no-calendario", fundo=("claro",), simbolo=lambda im, o, L: simbolo_calendario_visto(im, o, o, L),
            titulo="Visto verde dentro de um calendário minimalista",
            prompt="A bold green (#16A34A) check mark inside a minimalist calendar page with two small binder rings on top, "
                   "white calendar body on a soft off-white (#F6F7F4) rounded-square background, subtle soft shadow and gentle "
                   "studio lighting for depth (cinematic, premium, not a flat poster). App icon, flat vector, centered, no text, "
                   "solid background, high contrast, legible at 48px, 1024x1024."),
    2: dict(nome="semaforo-visto", fundo=("claro",), simbolo=lambda im, o, L: simbolo_semaforo(im, o, o, L),
            titulo="Semáforo estilizado com o verde aceso como um visto",
            prompt="A stylized modern traffic light seen from the front, rounded dark-charcoal housing, three lamps stacked "
                   "vertically: red (#DC2626) and orange (#F97316) lamps dimmed, the bottom green (#16A34A) lamp lit bright with "
                   "a white check mark and a soft glow. Off-white (#F6F7F4) rounded-square background, subtle cinematic lighting. "
                   "App icon, flat vector, centered, no text, solid background, high contrast, legible at 48px, 1024x1024."),
    3: dict(nome="circulo-visto-dia", fundo=("claro",), simbolo=lambda im, o, L: simbolo_circulo_dia(im, o, o, L),
            titulo="Visto verde num círculo com uma pequena folha de calendário",
            prompt="A big solid green (#16A34A) circle with a thick white check mark, and a small white calendar-day tab with a "
                   "dark-green header and an orange (#F97316) dot tucked at the lower right of the circle. Off-white (#F6F7F4) "
                   "rounded-square background, soft drop shadow, premium, clean, cinematic depth. App icon, flat vector, centered, "
                   "no text, solid background, high contrast, legible at 48px, 1024x1024."),
    4: dict(nome="calendario-estrada", fundo=("claro",), simbolo=lambda im, o, L: simbolo_calendario_visto(im, o, o, L, com_estrada=True),
            titulo="Calendário com visto e uma estrada subtil (carro)",
            prompt="A minimalist calendar page with a green (#16A34A) header bar and a bold green check mark in the middle; below "
                   "the calendar a subtle curved grey road with a dashed white centre line hinting at a car journey. Off-white "
                   "(#F6F7F4) rounded-square background, soft studio lighting. App icon, flat vector, centered, no text, solid "
                   "background, high contrast, legible at 48px, 1024x1024."),
    5: dict(nome="monograma-ed-visto", fundo=("verde",), simbolo=lambda im, o, L: simbolo_monograma(im, o, o, L),
            titulo="Forma abstrata E+D com visto",
            prompt="An abstract geometric monogram formed by the letter shapes E and D merged into one bold white glyph on a "
                   "green (#16A34A to #15803D) rounded square, where the middle bar of the E becomes a check mark rising into the "
                   "bowl of the D. Modern fintech feel, subtle depth. App icon, flat vector, centered, no text, solid background, "
                   "high contrast, legible at 48px, 1024x1024."),
}
# refinamento da melhor (proposta 1): mesmo prompt + "simpler, bolder, thicker strokes, fewer details"
PROPOSTAS["1r"] = dict(
    nome="visto-no-calendario-refinado", fundo=("claro",),
    simbolo=lambda im, o, L: simbolo_calendario_visto(im, o, o, L, refinado=True),
    titulo="Refinamento da proposta 1 (mais simples, traços mais grossos, menos detalhes)",
    prompt=PROPOSTAS[1]["prompt"] + " Simpler, bolder, thicker strokes, fewer details.")


def fundo_img(tipo, w, h):
    if tipo == "verde":
        return gradiente(w, h, VERDE_CLARO, VERDE_ESC, diagonal=True)
    return gradiente(w, h, FUNDO, VERDE_FUNDO)


def render(n, tamanho=1024, arredondado=True, margem=0.0, so_simbolo=False):
    """Renderiza a proposta n. margem = fração do canvas deixada livre à volta do símbolo."""
    p = PROPOSTAS[n]
    W = tamanho * S
    if so_simbolo:
        img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    else:
        img = fundo_img(p["fundo"][0], W, W).convert("RGBA")
        # brilho suave no canto superior (luz de estúdio)
        brilho(img, W * 0.25, W * 0.15, W * 0.45, BRANCO if p["fundo"][0] == "claro" else VERDE_CLARO, 60, W * 0.12)
    L = W * (1 - 2 * margem)
    o = W * margem
    p["simbolo"](img, o, L)
    if arredondado and not so_simbolo:
        mascara = Image.new("L", (W, W), 0)
        ImageDraw.Draw(mascara).rounded_rectangle([0, 0, W - 1, W - 1], radius=W * 0.22, fill=255)
        img.putalpha(mascara)
    return img.resize((tamanho, tamanho), Image.LANCZOS)


def cmd_propostas(a):
    pasta = RAIZ / "docs" / "marca"
    pasta.mkdir(parents=True, exist_ok=True)
    for n in PROPOSTAS:
        img = render(n, 1024, arredondado=True, margem=0.10)
        destino = pasta / f"proposta-{n}.png"
        img.save(destino, optimize=True)
        img.resize((48, 48), Image.LANCZOS).save(pasta / f"proposta-{n}-48px.png")
        print("ok", destino.name, img.size, destino.stat().st_size, "bytes")


def cmd_icones(a):
    n = a.n
    marca = RAIZ / "docs" / "marca"
    branding = RAIZ / "assets" / "branding"
    web = RAIZ / "web"
    branding.mkdir(parents=True, exist_ok=True)
    (web / "icons").mkdir(parents=True, exist_ok=True)
    # escolhida (apresentação, cantos redondos)
    render(n, 1024, arredondado=True, margem=0.10).save(marca / "escolhida.png", optimize=True)
    # icon.png: fundo cheio, sem transparência (o sistema aplica a máscara)
    cheio = render(n, 1024, arredondado=False, margem=0.12).convert("RGB")
    cheio.save(branding / "icon.png", optimize=True)
    # foreground adaptativo: só o símbolo, 25 % de margem, transparente
    render(n, 1024, arredondado=False, margem=0.25, so_simbolo=True).save(branding / "icon_foreground.png", optimize=True)
    # favicon 512 (cantos redondos, fundo transparente) e web/favicon.png
    fav = render(n, 512, arredondado=True, margem=0.10)
    fav.save(marca / "favicon.png", optimize=True)
    fav.save(web / "favicon.png", optimize=True)
    # web/icons: normais (fundo cheio, RGB) e maskable (fundo cheio, símbolo na zona segura ~ 60 %)
    for t in (192, 512):
        render(n, t, arredondado=False, margem=0.12).convert("RGB").save(web / "icons" / f"Icon-{t}.png", optimize=True)
        render(n, t, arredondado=False, margem=0.22).convert("RGB").save(web / "icons" / f"Icon-maskable-{t}.png", optimize=True)
    for f in [marca / "escolhida.png", branding / "icon.png", branding / "icon_foreground.png", marca / "favicon.png",
              web / "favicon.png"] + sorted((web / "icons").glob("Icon-*.png")):
        im = Image.open(f)
        print("ok", f.relative_to(RAIZ), im.size, im.mode, f.stat().st_size, "bytes")


def fonte(tam, peso="Bold"):
    f = ImageFont.truetype(str(FONTE), tam)
    try:
        f.set_variation_by_name(peso)
    except Exception as e:  # sem suporte a variação → peso regular
        print("aviso: variação de fonte indisponível:", e)
    return f


def cmd_feature(a):
    W, H = 1024, 500
    img = gradiente(W * S, H * S, VERDE_ESC2, VERDE, diagonal=True).convert("RGBA")
    brilho(img, W * S * 0.85, H * S * 0.1, W * S * 0.45, VERDE_CLARO, 110, W * S * 0.12)
    # ícone à esquerda
    ic = render(a.n, 340 * S, arredondado=True, margem=0.10)
    ix, iy = int(70 * S), int((H * S - ic.height) / 2)
    sombra(img, lambda d, c: d.rounded_rectangle([ix, iy, ix + ic.width, iy + ic.height], radius=340 * S * 0.22, fill=c),
           (0, int(10 * S)), 18 * S, 110)
    img.alpha_composite(ic, (ix, iy))
    img = img.resize((W, H), Image.LANCZOS)
    d = ImageDraw.Draw(img)
    x = 470
    d.text((x, 118), "Em Dia", font=fonte(112, "Bold"), fill=BRANCO)
    f2 = fonte(40, "SemiBold")
    linhas = ["Nunca mais levas multa", "da Segurança Social."]
    y = 268
    for ln in linhas:
        d.text((x + 2, y), ln, font=f2, fill=BRANCO)
        y += 52
    destino = RAIZ / "docs" / "marca" / "feature-graphic-1024x500.png"
    img.convert("RGB").save(destino, optimize=True)
    print("ok", destino.relative_to(RAIZ), img.size, destino.stat().st_size, "bytes")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["propostas", "icones", "feature"])
    ap.add_argument("--n", type=int, default=1)
    a = ap.parse_args()
    {"propostas": cmd_propostas, "icones": cmd_icones, "feature": cmd_feature}[a.cmd](a)


if __name__ == "__main__":
    sys.exit(main())
