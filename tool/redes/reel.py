"""Reels 1080×1920 (9:16), 30 fps, com som — montados por código.

Regras (LIVRO-DE-REGRAS-REDES.md): 7 a 20 s, nenhum plano com mais de 4 s,
texto curto a acompanhar, ecrãs verdadeiros da app, zona segura:
  texto entre y=250 e y=1480 (em cima fica o cabeçalho do Instagram, em baixo
  a legenda, os botões e o nome); nada importante à direita de x=960.

Planos (dicionários em `conteudo.py`):
  gancho  — frase grande, entra linha a linha
  ecra    — legenda em cima + telemóvel com o ecrã real (entra e faz scroll)
  numero  — número grande a contar + legenda + fonte oficial
  lista   — itens (datas) a entrar um a um
  fim     — logótipo, «grátis, sem cartão», link, promessa
"""
from __future__ import annotations

import math
import os
import subprocess
import tempfile

from PIL import Image, ImageDraw

import musica
from motor import (BRANCO, FUNDOS, LARANJA, LARANJA_CLARO, LINK, PROMESSA, PROMESSA_BR, TINTA, VERDE,
                   VERDE_CLARO, VERDE_ESC, altura, cabe, captura, escreve, fonte, fundo, logo, pilula, pincel, quebra,
                   largura_linha, sombra)

W, H = 1080, 1920
FPS = 30
M = 80
TOPO = 270        # primeira linha de texto segura
FUNDO_SEGURO = 1480
FFMPEG = None


def _ffmpeg():
    global FFMPEG
    if FFMPEG is None:
        import imageio_ffmpeg
        FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
    return FFMPEG


def _ease(x):
    x = max(0.0, min(1.0, x))
    return 1 - (1 - x) ** 3


def _ease_io(x):
    x = max(0.0, min(1.0, x))
    return 0.5 - 0.5 * math.cos(math.pi * x)


def _linhas_img(texto, tamanho, peso, cor, acento, largura, entrelinha=1.1, alinha='esq'):
    """Cada linha do texto num RGBA próprio (para entrar uma a uma)."""
    f = fonte(tamanho, peso)
    lh = int(tamanho * entrelinha)
    out = []
    for linha in quebra(texto, f, largura):
        img = Image.new('RGBA', (largura, lh + int(tamanho * 0.3)), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        lw = largura_linha(linha, f)
        x = (largura - lw) / 2 if alinha == 'centro' else 0
        for t, enf in linha:
            d.text((x, 0), t, font=f, fill=acento if enf else cor)
            x += f.getlength(t)
        out.append(img)
    return out, lh


def _poe_linhas(base, linhas, lh, x, y, t, atraso=0.0, passo=0.09, dur=0.32):
    for i, li in enumerate(linhas):
        p = _ease((t - atraso - i * passo) / dur)
        if p <= 0:
            continue
        dy = int((1 - p) * 46)
        if p < 1:
            li2 = li.copy()
            a = li2.getchannel('A').point(lambda v: int(v * p))
            li2.putalpha(a)
        else:
            li2 = li
        base.alpha_composite(li2, (int(x), int(y + i * lh + dy)))
    return y + len(linhas) * lh


class Plano:
    def __init__(self, s: dict, br: bool):
        self.s = s
        self.br = br
        self.dur = float(s.get('dur', 3.0))
        assert self.dur <= 4.0 + 1e-6, f'plano com mais de 4 s: {s}'
        self.fn = s.get('fundo', 'verde')
        _, self.txt, self.acento, self.subtil = FUNDOS[self.fn]
        self.base = fundo((W, H), self.fn)
        self.prep()

    # ------------------------------------------------------------ preparação
    def prep(self):
        s, tipo = self.s, self.s['tipo']
        larg = W - 2 * M - 40
        self.larg = larg
        if tipo == 'gancho':
            tam = cabe(s['texto'], s.get('tam', 120), 900, larg, 900, entrelinha=1.06, minimo=70)
            self.l1, self.lh1 = _linhas_img(s['texto'], tam, 900, self.txt, self.acento, larg, 1.06)
            if s.get('sub'):
                self.l2, self.lh2 = _linhas_img(s['sub'], 48, 600, self.txt if self.fn not in ('creme', 'branco') else (55, 65, 81),
                                                self.acento, larg, 1.3)
        elif tipo == 'ecra':
            tam = cabe(s['legenda'], s.get('tam', 72), 800, larg, 300, entrelinha=1.1, minimo=50)
            self.l1, self.lh1 = _linhas_img(s['legenda'], tam, 800, self.txt, self.acento, larg, 1.1)
            self.y_tel = TOPO + len(self.l1) * self.lh1 + 80
            larg_tel = s.get('largura', 760)
            cap = captura(s['ecra'])
            self.bez = larg_tel // 34
            self.tela_w = larg_tel - 2 * self.bez
            k = self.tela_w / cap.width
            self.tela = cap.resize((self.tela_w, int(cap.height * k)), Image.LANCZOS)
            self.tela_h = min(self.tela.height, 1720 - self.y_tel)
            self.raio = int(larg_tel * 0.12)
            self.larg_tel = larg_tel
            alto = self.tela_h + 2 * self.bez
            moldura = Image.new('RGBA', (larg_tel, alto), (0, 0, 0, 0))
            dm = ImageDraw.Draw(moldura)
            dm.rounded_rectangle((0, 0, larg_tel - 1, alto - 1), radius=self.raio, fill=(14, 17, 15, 255))
            dm.rounded_rectangle((2, 2, larg_tel - 3, alto - 3), radius=self.raio - 2, outline=(60, 66, 62, 255), width=2)
            self.moldura = moldura
            self.mascara = Image.new('L', (self.tela_w, self.tela_h), 0)
            ImageDraw.Draw(self.mascara).rounded_rectangle((0, 0, self.tela_w - 1, self.tela_h - 1),
                                                          radius=self.raio - self.bez, fill=255)
            # sombra pré-calculada
            self.sombra = Image.new('RGBA', (W, H), (0, 0, 0, 0))
            x = (W - larg_tel) // 2
            sombra(self.sombra, (x, self.y_tel, x + larg_tel, self.y_tel + alto), self.raio, desfoque=46, opac=90)
        elif tipo == 'numero':
            self.l1, self.lh1 = _linhas_img(s['legenda'], s.get('tam_legenda', 60), 800, self.txt, self.acento, larg, 1.14)
            if s.get('antes'):
                self.l0, self.lh0 = _linhas_img(s['antes'], 52, 700, self.txt if self.fn not in ('creme', 'branco') else (55, 65, 81),
                                                self.acento, larg, 1.2)
        elif tipo == 'lista':
            tam = cabe(s['titulo'], 80, 900, larg, 260, entrelinha=1.06, minimo=56)
            self.l1, self.lh1 = _linhas_img(s['titulo'], tam, 900, self.txt, self.acento, larg, 1.06)
            self.itens = []
            for data, texto, *extra in s['itens']:
                dest = bool(extra and extra[0])
                h_txt = altura(texto, 40, 600, larg - 300, 1.24)
                h = max(150, h_txt + 60)
                card = Image.new('RGBA', (W - 2 * M, h), (0, 0, 0, 0))
                dc = pincel(card)
                dc.rounded_rectangle((0, 0, card.width - 1, h - 1), radius=34,
                                     fill=BRANCO if self.fn in ('creme',) else (255, 255, 255, 245))
                if dest:
                    dc.rounded_rectangle((0, 0, 16, h - 1), radius=8, fill=LARANJA)
                cor_chip = LARANJA_CLARO if dest else VERDE_CLARO
                cor_dat = (154, 52, 18) if dest else VERDE_ESC
                dc.rounded_rectangle((30, (h - 92) / 2, 250, (h + 92) / 2), radius=22, fill=cor_chip)
                dc.text((140, h / 2), data, font=fonte(38 if len(data) <= 6 else 32, 800), fill=cor_dat, anchor='mm')
                escreve(dc, (280, (h - h_txt) / 2), texto, 40, 600, cor=TINTA, acento=VERDE_ESC, largura=card.width - 310,
                        entrelinha=1.24)
                self.itens.append(card)
        elif tipo == 'fim':
            pass

    # ------------------------------------------------------------ fotograma
    def quadro(self, t: float) -> Image.Image:
        s, tipo = self.s, self.s['tipo']
        img = self.base.copy()
        if tipo == 'gancho':
            total_h = len(self.l1) * self.lh1 + (len(self.l2) * self.lh2 + 40 if s.get('sub') else 0)
            y = max(TOPO + 60, (TOPO + FUNDO_SEGURO) // 2 - total_h // 2 - 60) if not s.get('topo') else TOPO + 40
            if s.get('etiqueta'):
                d = pincel(img)
                p = _ease(t / 0.3)
                cf = (255, 255, 255, int(46 * p)) if self.fn in ('verde', 'escuro', 'laranja') else VERDE_CLARO
                ct = BRANCO if self.fn in ('verde', 'escuro', 'laranja') else VERDE_ESC
                if p > 0.05:
                    pilula(d, (M + 20, y - 110), s['etiqueta'], 34, 800, cor_fundo=cf, cor_texto=ct)
            y = _poe_linhas(img, self.l1, self.lh1, M + 20, y, t, atraso=0.05)
            if s.get('sub'):
                _poe_linhas(img, self.l2, self.lh2, M + 20, y + 40, t, atraso=0.35 + 0.09 * len(self.l1))
            if s.get('logo', True):
                logo(img, (M + 20, TOPO - 40), tam=64, cor_texto=self.txt)
        elif tipo == 'ecra':
            y = _poe_linhas(img, self.l1, self.lh1, M + 20, TOPO, t)
            p = _ease((t - 0.08) / 0.45)
            dy = int((1 - p) * 700)
            img.alpha_composite(self.sombra, (0, dy))
            x = (W - self.larg_tel) // 2
            img.alpha_composite(self.moldura, (x, self.y_tel + dy))
            a, b = s.get('pan', (0.0, 0.0))
            pp = _ease_io((t - 0.6) / max(0.1, self.dur - 0.9))
            frac = a + (b - a) * pp
            max_off = max(0, self.tela.height - self.tela_h)
            off = int(frac * max_off)
            off = max(0, min(max_off, off))
            janela = self.tela.crop((0, off, self.tela_w, off + self.tela_h))
            img.paste(janela, (x + self.bez, self.y_tel + self.bez + dy), self.mascara)
            if s.get('nota'):
                # etiqueta «Ecrã real · modo exemplo» colada ao topo do telemóvel, sem tapar o ecrã
                d = pincel(img)
                f = fonte(28, 700)
                w = f.getlength(s['nota'])
                yy = self.y_tel + dy - 30
                d.rounded_rectangle(((W - w) / 2 - 26, yy, (W + w) / 2 + 26, yy + 52), radius=26, fill=(17, 24, 39, 240))
                d.text((W / 2, yy + 26), s['nota'], font=f, fill=BRANCO, anchor='mm')
        elif tipo == 'numero':
            d = pincel(img)
            y = TOPO + 60
            if s.get('antes'):
                y = _poe_linhas(img, self.l0, self.lh0, M + 20, y, t) + 30
            alvo = s['numero']
            p = _ease((t - 0.15) / 1.1)
            texto = _conta(alvo, p) if s.get('contar', '/' not in alvo) else alvo
            tam = cabe(alvo, s.get('tam', 230), 900, W - 2 * M, 300, minimo=120)
            f = fonte(tam, 900)
            cor_n = s.get('cor_numero', self.acento if self.fn in ('creme', 'branco') else BRANCO)
            d.text((M + 20, y), texto, font=f, fill=cor_n)
            y += int(tam * 1.18)
            _poe_linhas(img, self.l1, self.lh1, M + 20, y + 10, t, atraso=0.5)
            if s.get('fonte'):
                escreve(d, (M + 20, FUNDO_SEGURO - 70), s['fonte'], 28, 500,
                        cor=self.subtil if self.fn in ('creme', 'branco') else (220, 240, 228), largura=W - 2 * M - 40, entrelinha=1.3)
        elif tipo == 'lista':
            y = _poe_linhas(img, self.l1, self.lh1, M + 20, TOPO, t) + 40
            for i, card in enumerate(self.itens):
                p = _ease((t - 0.35 - i * 0.28) / 0.35)
                if p <= 0:
                    y += card.height + 24
                    continue
                c = card if p >= 1 else _alfa(card, p)
                img.alpha_composite(c, (M + int((1 - p) * 120), y))
                y += card.height + 24
            if s.get('fonte'):
                d = pincel(img)
                escreve(d, (M + 20, FUNDO_SEGURO - 40), s['fonte'], 28, 500,
                        cor=self.subtil if self.fn in ('creme', 'branco') else (220, 240, 228), largura=W - 2 * M - 40, entrelinha=1.3)
        elif tipo == 'fim':
            d = pincel(img)
            p = _ease(t / 0.4)
            tam_ic = 150
            logo(img, (M + 20, TOPO + int((1 - p) * 60)), tam=tam_ic, cor_texto=self.txt)
            y = TOPO + tam_ic + 80
            titulo = s.get('titulo', 'Grátis, **sem cartão.**' if not self.br else 'Grátis, **sem cartão.**')
            y += escreve(d, (M + 20, y), titulo, 112, 900, cor=self.txt, acento=self.acento, largura=W - 2 * M - 40, entrelinha=1.05)
            y += 40
            f = fonte(44, 800)
            w = f.getlength(LINK)
            p2 = _ease((t - 0.35) / 0.35)
            if p2 > 0:
                d.rounded_rectangle((M + 20, y, M + 20 + w + 100, y + 116), radius=58, fill=(255, 255, 255, int(255 * p2))
                                    if self.fn in ('verde', 'escuro') else VERDE)
                d.text((M + 70, y + 58), LINK, font=f, fill=VERDE_ESC if self.fn in ('verde', 'escuro') else BRANCO, anchor='lm')
            y += 116 + 26
            d.text((M + 20, y), 'Link na bio' if not self.br else 'Link na bio', font=fonte(34, 600), fill=self.txt)
            y += 80
            pontos = (['Diz quanto guardar', 'Avisa antes de cada prazo'] if self.br
                      else ['Diz-te quanto guardar', 'Avisa antes de cada prazo'])
            for k, p_ in enumerate(pontos):
                p3 = _ease((t - 0.6 - k * 0.15) / 0.3)
                if p3 <= 0:
                    y += 74
                    continue
                d.ellipse((M + 20, y, M + 72, y + 52), fill=BRANCO if self.fn in ('verde', 'escuro') else VERDE)
                cv = VERDE if self.fn in ('verde', 'escuro') else BRANCO
                d.line((M + 34, y + 27, M + 43, y + 36, M + 59, y + 17), fill=cv, width=6, joint='curve')
                d.text((M + 96, y + 26), p_, font=fonte(40, 700), fill=self.txt, anchor='lm')
                y += 74
            y += 40
            prom = PROMESSA_BR if self.br else PROMESSA
            escreve(d, (M + 20, y), prom, 38, 500, cor=self.txt if self.fn in ('verde', 'escuro') else (55, 65, 81),
                    largura=W - 2 * M - 40, entrelinha=1.34)
        return img


def _alfa(img, p):
    i2 = img.copy()
    i2.putalpha(i2.getchannel('A').point(lambda v: int(v * p)))
    return i2


def _conta(alvo: str, p: float) -> str:
    """«179,76 €» a contar de 0 até ao valor (formato português)."""
    import re
    m = re.search(r'(\d[\d.]*)(,(\d+))?', alvo)
    if not m or p >= 1:
        return alvo
    inteiro = int(m.group(1).replace('.', ''))
    dec = m.group(3) or ''
    valor = (inteiro + (int(dec) / 10 ** len(dec) if dec else 0)) * p
    if dec:
        s = f'{valor:,.{len(dec)}f}'.replace(',', 'X').replace('.', ',').replace('X', '.')
    else:
        s = f'{int(valor):,}'.replace(',', '.')
    if '.' not in m.group(1) and not dec:
        s = s.replace('.', '')
    elif '.' not in m.group(1):
        s = s.replace('.', '')
    return alvo[:m.start()] + s + alvo[m.end():]


def monta(planos: list[dict], saida: str, semente=0, br=False, capa=None):
    ps = [Plano(s, br) for s in planos]
    total = sum(p.dur for p in ps)
    assert 7 <= total <= 20.5, f'reel com {total:.1f} s (tem de ser 7 a 20 s)'
    cortes = []
    acc = 0
    for p in ps[:-1]:
        acc += p.dur
        cortes.append(acc)
    tmp = tempfile.mkdtemp()
    wav = musica.gera(total, cortes, semente, os.path.join(tmp, 'm.wav'))
    os.makedirs(os.path.dirname(saida), exist_ok=True)
    cmd = [_ffmpeg(), '-y', '-loglevel', 'error', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-s', f'{W}x{H}', '-r', str(FPS),
           '-i', '-', '-i', wav, '-c:v', 'libx264', '-preset', 'medium', '-crf', '24', '-pix_fmt', 'yuv420p',
           '-profile:v', 'high', '-c:a', 'aac', '-b:a', '160k', '-shortest', '-movflags', '+faststart', saida]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    primeiro = None
    for p in ps:
        n = int(round(p.dur * FPS))
        for i in range(n):
            q = p.quadro(i / FPS).convert('RGB')
            if primeiro is None and i == n - 1:
                primeiro = q
            proc.stdin.write(q.tobytes())
    proc.stdin.close()
    proc.wait()
    if capa and primeiro is not None:
        primeiro.save(capa, quality=90)
    return total
