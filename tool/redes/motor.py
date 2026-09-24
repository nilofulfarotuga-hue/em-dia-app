"""Motor das peças das redes do Em Dia (2026-09-23).

Tudo o que é texto, ecrã e logótipo entra por código (Pillow + Inter), nunca
pedido a uma IA de imagem. Os ecrãs são capturas VERDADEIRAS da app no modo
exemplo (a Maria), tiradas por `tool/redes/capturas_test.dart`.

Formatos:
  carrossel 1080×1350 (4:5) · reel/story 1080×1920 (9:16) · perfil 1080×1080
"""
from __future__ import annotations

import functools
import os
import re

from PIL import Image, ImageDraw, ImageFilter, ImageFont

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
FONTE = os.path.join(RAIZ, 'assets', 'fonts', 'Inter-VariableFont.ttf')
ICONE = os.path.join(RAIZ, 'assets', 'branding', 'icon_foreground.png')
CAPTURAS = os.path.join(RAIZ, 'docs', 'marketing', 'redes-em-dia', 'capturas')

# Paleta (docs/DESIGN-SYSTEM.md)
VERDE = (22, 163, 74)
VERDE_ESC = (13, 92, 43)
VERDE_FUNDO = (6, 60, 30)
VERDE_CLARO = (220, 252, 231)
LARANJA = (249, 115, 22)
LARANJA_CLARO = (255, 237, 213)
VERMELHO = (220, 38, 38)
CREME = (246, 247, 244)
BRANCO = (255, 255, 255)
TINTA = (17, 24, 39)
CINZA = (107, 114, 128)
CINZA_CLARO = (229, 231, 235)
AZUL_CLARO = (219, 234, 254)

FUNDOS = {
    'verde': (VERDE, BRANCO, (255, 237, 213), BRANCO),        # fundo, texto, acento, subtil
    'escuro': (VERDE_FUNDO, BRANCO, (134, 239, 172), (190, 220, 200)),
    'creme': (CREME, TINTA, VERDE, CINZA),
    'branco': (BRANCO, TINTA, VERDE, CINZA),
    'laranja': (LARANJA, BRANCO, TINTA, BRANCO),
}

PROMESSA = ('Por agora está tudo aberto e não se paga nada. Quando as assinaturas abrirem, '
            'avisamos com 30 dias de antecedência e ninguém é cobrado sem dizer que sim.')
PROMESSA_BR = ('Por enquanto está tudo aberto e não se paga nada. Quando as assinaturas abrirem, '
               'avisamos com 30 dias de antecedência e ninguém é cobrado sem dizer que sim.')
LINK = 'app.emdia.boraguarda.com'


@functools.lru_cache(maxsize=256)
def fonte(tamanho: int, peso: int = 400) -> ImageFont.FreeTypeFont:
    f = ImageFont.truetype(FONTE, tamanho)
    opsz = max(14, min(32, tamanho // 2))
    f.set_variation_by_axes([opsz, peso])
    return f


# ---------------------------------------------------------------- texto rico
# **palavra** = cor de acento. Quebra de linha manual com \n.
_TOK = re.compile(r'(\*\*.+?\*\*)')


def _tokens(texto: str):
    # «1.200 €», «21,4 %», «art. 53.º»: o número nunca fica sozinho no fim da linha
    texto = re.sub(r'(\d) (€|%)', '\\1\u00a0\\2', texto)
    texto = texto.replace('art. ', 'art.\u00a0')
    out = []
    for parte in _TOK.split(texto):
        if not parte:
            continue
        enf = parte.startswith('**') and parte.endswith('**')
        if enf:
            parte = parte[2:-2]
        for i, bloco in enumerate(parte.split('\n')):
            if i:
                out.append(('\n', False))
            for pal in re.findall(r'(?:[^\s]|\u00a0)+|\s+', bloco):
                out.append((pal, enf))
    return out


def quebra(texto: str, f: ImageFont.FreeTypeFont, largura: int):
    """Devolve linhas: cada linha é uma lista de (texto, enfase)."""
    linhas, atual, w = [], [], 0
    espaco = f.getlength(' ')
    for pal, enf in _tokens(texto):
        if pal == '\n':
            linhas.append(atual)
            atual, w = [], 0
            continue
        if pal.isspace():
            if atual:
                atual.append((' ', enf))
                w += espaco
            continue
        lw = f.getlength(pal)
        if atual and w + lw > largura:
            while atual and atual[-1][0] == ' ':
                atual.pop()
            linhas.append(atual)
            atual, w = [], 0
        atual.append((pal, enf))
        w += lw
    while atual and atual[-1][0] == ' ':
        atual.pop()
    if atual:
        linhas.append(atual)
    return linhas


def largura_linha(linha, f):
    return sum(f.getlength(t) for t, _ in linha)


def escreve(d: ImageDraw.ImageDraw, xy, texto, tamanho, peso=400, cor=TINTA, acento=VERDE,
            largura=900, entrelinha=1.18, alinha='esq', so_medir=False, tracking=0):
    """Escreve texto rico com quebra. Devolve a altura ocupada."""
    f = fonte(tamanho, peso)
    linhas = quebra(texto, f, largura)
    lh = int(tamanho * entrelinha)
    x0, y = xy
    for linha in linhas:
        lw = largura_linha(linha, f)
        if alinha == 'centro':
            x = x0 + (largura - lw) / 2
        elif alinha == 'dir':
            x = x0 + largura - lw
        else:
            x = x0
        if not so_medir:
            for t, enf in linha:
                d.text((x, y), t, font=f, fill=acento if enf else cor)
                x += f.getlength(t) + (tracking if t != ' ' else 0)
        y += lh
    return len(linhas) * lh


def altura(texto, tamanho, peso=400, largura=900, entrelinha=1.18):
    f = fonte(tamanho, peso)
    return len(quebra(texto, f, largura)) * int(tamanho * entrelinha)


def cabe(texto, tamanho_max, peso, largura, altura_max, entrelinha=1.1, minimo=40):
    """Maior tamanho de letra (≤ tamanho_max) com que o texto cabe na caixa."""
    t = tamanho_max
    while t > minimo:
        f = fonte(t, peso)
        linhas = quebra(texto, f, largura)
        larga = max((largura_linha(l, f) for l in linhas), default=0)
        if len(linhas) * int(t * entrelinha) <= altura_max and larga <= largura:
            return t
        t -= 4
    return minimo


# ---------------------------------------------------------------- formas
def ret(d, caixa, raio, cor, contorno=None, esp=0):
    d.rounded_rectangle(caixa, radius=raio, fill=cor, outline=contorno, width=esp)


def sombra(base: Image.Image, caixa, raio, desfoque=40, opac=70, desloc=(0, 24)):
    x0, y0, x1, y1 = caixa
    pad = desfoque * 3
    camada = Image.new('L', (int(x1 - x0) + pad * 2, int(y1 - y0) + pad * 2), 0)
    ImageDraw.Draw(camada).rounded_rectangle((pad, pad, pad + x1 - x0, pad + y1 - y0), radius=raio, fill=opac)
    camada = camada.filter(ImageFilter.GaussianBlur(desfoque))
    preto = Image.new('RGBA', camada.size, (0, 0, 0, 255))
    preto.putalpha(camada)
    base.alpha_composite(preto, (int(x0 - pad + desloc[0]), int(y0 - pad + desloc[1])))


@functools.lru_cache(maxsize=16)
def _icone(tam: int) -> Image.Image:
    """O ícone da app: quadrado branco de cantos redondos com o calendário."""
    sim = Image.open(ICONE).convert('RGBA')
    sim = sim.crop(sim.getbbox())
    esc = 4
    T = tam * esc
    img = Image.new('RGBA', (T, T), (0, 0, 0, 0))
    ImageDraw.Draw(img).rounded_rectangle((0, 0, T - 1, T - 1), radius=int(T * 0.26), fill=(255, 255, 255, 255))
    lado = int(T * 0.66)
    w, h = sim.size
    k = lado / max(w, h)
    sim = sim.resize((int(w * k), int(h * k)), Image.LANCZOS)
    img.alpha_composite(sim, ((T - sim.width) // 2, (T - sim.height) // 2 + int(T * 0.01)))
    return img.resize((tam, tam), Image.LANCZOS)


def logo(base: Image.Image, xy, tam=64, cor_texto=TINTA, com_nome=True, fundo_icone=None):
    """Símbolo (calendário com visto) + «Em Dia»."""
    x, y = xy
    ic = _icone(tam)
    if fundo_icone is not None:
        d = ImageDraw.Draw(base)
        d.rounded_rectangle((x - 6, y - 6, x + tam + 6, y + tam + 6), radius=int(tam * 0.28), fill=fundo_icone)
    base.alpha_composite(ic, (int(x), int(y)))
    if com_nome:
        d = ImageDraw.Draw(base)
        f = fonte(int(tam * 0.62), 800)
        d.text((x + tam + int(tam * 0.28), y + tam / 2), 'Em Dia', font=f, fill=cor_texto, anchor='lm')


@functools.lru_cache(maxsize=64)
def captura(nome: str) -> Image.Image:
    return Image.open(os.path.join(CAPTURAS, f'{nome}.png')).convert('RGBA')


def telemovel(nome: str, largura: int, corte=None, raio=None) -> Image.Image:
    """Um telemóvel (moldura escura) com a captura real lá dentro.

    [corte] = (y0, y1) em fração da altura da captura, para mostrar só um pedaço
    (o ecrã fica com a mesma proporção cortada)."""
    cap = captura(nome)
    cw, ch = cap.size
    if corte:
        cap = cap.crop((0, int(corte[0] * ch), cw, int(corte[1] * ch)))
        cw, ch = cap.size
    bez = max(10, largura // 36)
    tela_w = largura - 2 * bez
    tela_h = int(ch * tela_w / cw)
    alto = tela_h + 2 * bez
    raio = raio if raio is not None else int(largura * 0.12)
    img = Image.new('RGBA', (largura, alto), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((0, 0, largura - 1, alto - 1), radius=raio, fill=(14, 17, 15, 255))
    d.rounded_rectangle((2, 2, largura - 3, alto - 3), radius=raio - 2, outline=(60, 66, 62, 255), width=2)
    tela = cap.resize((tela_w, tela_h), Image.LANCZOS)
    mascara = Image.new('L', tela.size, 0)
    r2 = max(4, raio - bez)
    if corte and corte[0] > 0.01:
        # ecrã cortado por cima: cantos de cima retos não fazem sentido; mantém redondos
        pass
    ImageDraw.Draw(mascara).rounded_rectangle((0, 0, tela_w - 1, tela_h - 1), radius=r2, fill=255)
    img.paste(tela, (bez, bez), mascara)
    return img


def cartao_ecra(nome: str, largura: int, corte=None, raio=36) -> Image.Image:
    """Um pedaço de ecrã real como cartão (sem moldura de telemóvel)."""
    cap = captura(nome)
    cw, ch = cap.size
    if corte:
        cap = cap.crop((0, int(corte[0] * ch), cw, int(corte[1] * ch)))
        cw, ch = cap.size
    h = int(ch * largura / cw)
    tela = cap.resize((largura, h), Image.LANCZOS)
    m = Image.new('L', tela.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, largura - 1, h - 1), radius=raio, fill=255)
    out = Image.new('RGBA', tela.size, (0, 0, 0, 0))
    out.paste(tela, (0, 0), m)
    return out


def cola(base: Image.Image, img: Image.Image, xy, com_sombra=True, raio=60):
    x, y = int(xy[0]), int(xy[1])
    if com_sombra:
        sombra(base, (x, y, x + img.width, y + img.height), raio)
    base.alpha_composite(img, (x, y))


def fundo(tam, nome):
    cor = FUNDOS[nome][0]
    img = Image.new('RGBA', tam, cor + (255,))
    if nome in ('verde', 'escuro'):
        # gradiente suave (mais escuro em baixo) — dá profundidade sem brilhos
        w, h = tam
        grad = Image.linear_gradient('L').resize((w, h))
        escuro = Image.new('RGBA', tam, (0, 40, 18, 255))
        grad = grad.point(lambda v: int(v * 0.35))
        img = Image.composite(escuro, img, grad)
    return img


def pilula(d, xy, texto, tamanho=30, peso=700, cor_fundo=VERDE_CLARO, cor_texto=VERDE_ESC, pad=(24, 12)):
    f = fonte(tamanho, peso)
    w = f.getlength(texto)
    x, y = xy
    caixa = (x, y, x + w + 2 * pad[0], y + tamanho + 2 * pad[1])
    d.rounded_rectangle(caixa, radius=(tamanho + 2 * pad[1]) // 2, fill=cor_fundo)
    d.text((x + pad[0], y + pad[1] + tamanho / 2), texto, font=f, fill=cor_texto, anchor='lm')
    return caixa


def qr(texto: str, tam: int, cor=TINTA, fundo_cor=BRANCO) -> Image.Image:
    import qrcode
    q = qrcode.QRCode(border=1, error_correction=qrcode.constants.ERROR_CORRECT_M, box_size=10)
    q.add_data(texto)
    q.make(fit=True)
    img = q.make_image(fill_color=cor, back_color=fundo_cor).convert('RGBA')
    return img.resize((tam, tam), Image.NEAREST)


def guarda_png(img: Image.Image, caminho: str):
    os.makedirs(os.path.dirname(caminho), exist_ok=True)
    img.convert('RGB').save(caminho, optimize=True)


class Pincel:
    """ImageDraw que mistura as cores translúcidas (RGBA) em vez de as carimbar."""

    def __init__(self, img: Image.Image):
        self.img = img
        self.d = ImageDraw.Draw(img)

    def _trans(self, c):
        return isinstance(c, tuple) and len(c) == 4 and c[3] < 255

    def _camada(self, metodo, *a, **k):
        ov = Image.new('RGBA', self.img.size, (0, 0, 0, 0))
        getattr(ImageDraw.Draw(ov), metodo)(*a, **k)
        self.img.alpha_composite(ov)

    def rounded_rectangle(self, xy, radius=0, fill=None, outline=None, width=1):
        if self._trans(fill) or self._trans(outline):
            self._camada('rounded_rectangle', xy, radius=radius, fill=fill, outline=outline, width=width)
        else:
            self.d.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)

    def text(self, xy, texto, fill=None, **k):
        if self._trans(fill):
            self._camada('text', xy, texto, fill=fill, **k)
        else:
            self.d.text(xy, texto, fill=fill, **k)

    def __getattr__(self, nome):
        return getattr(self.d, nome)


def pincel(img):
    return Pincel(img)
