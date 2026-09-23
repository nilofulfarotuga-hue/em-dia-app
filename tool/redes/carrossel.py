"""Carrosséis 1080×1350 (e stories/capas estáticas 1080×1920) do Em Dia.

Cada lâmina é um dicionário (ver `conteudo.py`). Tipos:
  capa   — gancho enorme, etiqueta, subtítulo, «desliza»
  texto  — número, título, corpo, caixa de destaque, fonte oficial
  ecra   — título + ecrã verdadeiro da app (telemóvel ou pedaço de ecrã)
  lista  — datas/itens (calendário de prazos)
  cta    — fecho: grátis, sem cartão, link, promessa
"""
from __future__ import annotations

from PIL import Image, ImageDraw

from motor import (BRANCO, CINZA, CINZA_CLARO, CREME, FUNDOS, LARANJA, LARANJA_CLARO, LINK, PROMESSA,
                   PROMESSA_BR, TINTA, VERDE, VERDE_CLARO, VERDE_ESC, altura, cabe, cartao_ecra, cola,
                   escreve, fonte, fundo, logo, pilula, pincel, qr, telemovel)

W, H = 1080, 1350
M = 84  # margem


def _topo(img, d, fundo_nome, pag, total, rotulo=None):
    _, txt, _, subtil = FUNDOS[fundo_nome]
    logo(img, (M, 64), tam=58, cor_texto=txt)
    if total > 1:
        t = f'{pag}/{total}'
        f = fonte(28, 600)
        w = f.getlength(t)
        cor_p = (255, 255, 255, 60) if fundo_nome in ('verde', 'escuro', 'laranja') else CINZA_CLARO
        d.rounded_rectangle((W - M - w - 40, 70, W - M, 116), radius=23, fill=cor_p)
        d.text((W - M - w / 2 - 20, 93), t, font=f, fill=txt, anchor='mm')


def _rodape(d, fundo_nome, texto, y=None):
    _, txt, _, subtil = FUNDOS[fundo_nome]
    if not texto:
        return
    h = altura(texto, 24, 400, W - 2 * M, 1.3)
    escreve(d, (M, (y or H - 64) - h), texto, 24, 400, cor=subtil, acento=subtil, largura=W - 2 * M, entrelinha=1.3)


def _desliza(d, fundo_nome, esquerda=False):
    _, txt, acento, _ = FUNDOS[fundo_nome]
    f = fonte(32, 700)
    t = 'Desliza'
    w = f.getlength(t)
    x = W - M - w - 70
    if esquerda:
        x = M
        d.text((x, H - 96), t, font=f, fill=txt, anchor='lm')
        ax = M + w + 20
        d.line((ax, H - 96, ax + 40, H - 96), fill=txt, width=5)
        d.polygon([(ax + 44, H - 96), (ax + 28, H - 108), (ax + 28, H - 84)], fill=txt)
        return
    d.text((x, H - 96), t, font=f, fill=txt, anchor='lm')
    # seta
    ax = W - M - 44
    d.line((ax, H - 96, ax + 40, H - 96), fill=txt, width=5)
    d.polygon([(ax + 44, H - 96), (ax + 28, H - 108), (ax + 28, H - 84)], fill=txt)


def lamina(s: dict, pag: int, total: int, br=False) -> Image.Image:
    fn = s.get('fundo', 'creme')
    fundo_cor, txt, acento, subtil = FUNDOS[fn]
    if 'acento' in s:
        acento = s['acento']
    img = fundo((W, H), fn)
    d = pincel(img)
    tipo = s['tipo']
    _topo(img, d, fn, pag, total)
    larg = W - 2 * M

    if tipo == 'capa':
        y = 200
        if s.get('etiqueta'):
            cf = (255, 255, 255, 40) if fn in ('verde', 'escuro') else VERDE_CLARO
            ct = BRANCO if fn in ('verde', 'escuro') else VERDE_ESC
            if s.get('etiqueta_laranja'):
                cf, ct = LARANJA, BRANCO
            cx = pilula(d, (M, y), s['etiqueta'], 30, 800, cor_fundo=cf, cor_texto=ct)
            y = cx[3] + 44
        tem_ecra = bool(s.get('ecra'))
        alt_max = (560 if tem_ecra else 760)
        tam = cabe(s['titulo'], s.get('tam', 124), 900, larg, alt_max, entrelinha=1.04, minimo=64)
        y += escreve(d, (M, y), s['titulo'], tam, 900, cor=txt, acento=acento, largura=larg, entrelinha=1.04)
        if s.get('sub'):
            y += 30
            y += escreve(d, (M, y), s['sub'], 42, 500, cor=subtil if fn in ('creme', 'branco') else txt,
                         acento=acento, largura=larg - 40, entrelinha=1.3)
        if tem_ecra:
            tel = telemovel(s['ecra'], 470, corte=s.get('corte', (0, 0.62)))
            x = W - M - tel.width + 30
            yy = max(y + 50, H - tel.height - 40)
            cola(img, tel, (x, yy))
            # o telemóvel sai pela base: corta
            img = img.crop((0, 0, W, H))
            d = pincel(img)
        if not s.get('sem_desliza'):
            _desliza(d, fn, esquerda=tem_ecra)

    elif tipo == 'texto':
        # mede primeiro para centrar o bloco na vertical (nada de meia lâmina vazia)
        tam_t = cabe(s['titulo'], s.get('tam', 88), 800, larg, 360, entrelinha=1.08, minimo=48)
        tc = s.get('tam_corpo', 46)
        h = (148 if s.get('n') is not None else 0) + altura(s['titulo'], tam_t, 800, larg, 1.08)
        if s.get('corpo'):
            h += 34 + altura(s['corpo'], tc, 400, larg, 1.38)
        if s.get('caixa'):
            h += 44 + altura(s['caixa'], 46, 700, larg - 88, 1.28) + 88
        y = 200 if s.get('ecra') else max(190, int(190 + (H - 190 - 170 - h) * 0.42))
        if s.get('n') is not None:
            f = fonte(56, 900)
            cor_c = acento if fn in ('creme', 'branco') else BRANCO
            cor_n = BRANCO if fn in ('creme', 'branco') else VERDE_ESC
            d.ellipse((M, y, M + 104, y + 104), fill=cor_c)
            d.text((M + 52, y + 54), str(s['n']), font=f, fill=cor_n, anchor='mm')
            y += 104 + 44
        y += escreve(d, (M, y), s['titulo'], tam_t, 800, cor=txt, acento=acento, largura=larg, entrelinha=1.08)
        if s.get('corpo'):
            y += 34
            y += escreve(d, (M, y), s['corpo'], tc, 400,
                         cor=txt if fn not in ('creme', 'branco') else (55, 65, 81), acento=acento,
                         largura=larg, entrelinha=1.38)
        if s.get('caixa'):
            y += 44
            cor_cx = s.get('cor_caixa', 'branco')
            fundo_cx, cor_txt_cx, borda = {
                'branco': (BRANCO, TINTA, None),
                'verde': (VERDE_CLARO, VERDE_ESC, None),
                'laranja': (LARANJA_CLARO, (124, 45, 18), LARANJA),
            }[cor_cx]
            pad = 44
            hcx = altura(s['caixa'], 46, 700, larg - 2 * pad, 1.28) + 2 * pad
            d.rounded_rectangle((M, y, W - M, y + hcx), radius=36, fill=fundo_cx)
            if borda:
                d.rounded_rectangle((M, y, M + 14, y + hcx), radius=7, fill=borda)
            escreve(d, (M + pad, y + pad), s['caixa'], 46, 700, cor=cor_txt_cx, acento=VERDE_ESC if cor_cx != 'verde' else TINTA,
                    largura=larg - 2 * pad, entrelinha=1.28)
            y += hcx
        if s.get('ecra'):
            y += 40
            cart = cartao_ecra(s['ecra'], larg, corte=s.get('corte'))
            espaco = H - 150 - y
            if cart.height > espaco:
                cart = cart.crop((0, 0, cart.width, max(80, espaco)))
            cola(img, cart, (M, y), raio=36)
        _rodape(d, fn, s.get('fonte'))

    elif tipo == 'ecra':
        y = 190
        tam_t = cabe(s['titulo'], s.get('tam', 64), 800, larg, 230, entrelinha=1.1, minimo=44)
        y += escreve(d, (M, y), s['titulo'], tam_t, 800, cor=txt, acento=acento, largura=larg, entrelinha=1.1)
        if s.get('corpo'):
            y += 20
            y += escreve(d, (M, y), s['corpo'], 36, 400, cor=subtil if fn in ('creme', 'branco') else txt,
                         acento=acento, largura=larg, entrelinha=1.34)
        y += 44
        if s.get('cartao'):
            cart = cartao_ecra(s['ecra'], s.get('largura', larg), corte=s.get('corte'))
            espaco = H - 130 - y
            if cart.height > espaco:
                cart = cart.crop((0, 0, cart.width, espaco))
            cola(img, cart, ((W - cart.width) // 2, y), raio=36)
            y_nota = y + cart.height + 40
        else:
            tel = telemovel(s['ecra'], s.get('largura', 600), corte=s.get('corte', (0, 0.7)))
            x = (W - tel.width) // 2
            cola(img, tel, (x, y))
            img = img.crop((0, 0, W, H))
            d = pincel(img)
            # faixa por baixo para a fonte/nota ficar legível
        if s.get('nota'):
            f = fonte(26, 600)
            nota = s['nota']
            w = f.getlength(nota)
            yn = min(H - 110, y_nota) if s.get('cartao') else H - 110
            d.rounded_rectangle(((W - w) / 2 - 26, yn, (W + w) / 2 + 26, yn + 50), radius=25, fill=(17, 24, 39, 230))
            d.text((W / 2, yn + 25), nota, font=f, fill=BRANCO, anchor='mm')

    elif tipo == 'lista':
        tam_t = cabe(s['titulo'], s.get('tam', 80), 800, larg, 260, entrelinha=1.08, minimo=48)
        h = altura(s['titulo'], tam_t, 800, larg, 1.08) + 44
        for _d, _t, *_e in s['itens']:
            h += max(128, altura(_t, 36, 500, larg - 250, 1.28) + 56) + 22
        y = max(190, int(190 + (H - 190 - 170 - h) * 0.42))
        y += escreve(d, (M, y), s['titulo'], tam_t, 800, cor=txt, acento=acento, largura=larg, entrelinha=1.08)
        y += 44
        itens = s['itens']
        esp = 22
        for data, texto, *extra in itens:
            destaque = bool(extra and extra[0])
            h_txt = altura(texto, 36, 500, larg - 250, 1.28)
            h = max(128, h_txt + 56)
            cor_card = BRANCO if fn in ('creme',) else (CREME if fn == 'branco' else (255, 255, 255, 235))
            d.rounded_rectangle((M, y, W - M, y + h), radius=32, fill=cor_card)
            if destaque:
                d.rounded_rectangle((M, y, M + 14, y + h), radius=7, fill=LARANJA)
            # data em chip
            fdat = fonte(34 if len(data) <= 8 else 28, 800)
            cor_chip = LARANJA_CLARO if destaque else VERDE_CLARO
            cor_dat = (154, 52, 18) if destaque else VERDE_ESC
            d.rounded_rectangle((M + 30, y + (h - 84) / 2, M + 210, y + (h + 84) / 2), radius=20, fill=cor_chip)
            d.text((M + 120, y + h / 2), data, font=fdat, fill=cor_dat, anchor='mm')
            escreve(d, (M + 240, y + (h - h_txt) / 2), texto, 36, 500, cor=TINTA, acento=VERDE_ESC,
                    largura=larg - 270, entrelinha=1.28)
            y += h + esp
        _rodape(d, fn, s.get('fonte'))

    elif tipo == 'cta':
        fn2 = fn
        y = 210
        titulo = s.get('titulo', 'Vê se estás **em dia**.')
        tam_t = cabe(titulo, 104, 900, larg, 360, entrelinha=1.04, minimo=64)
        y += escreve(d, (M, y), titulo, tam_t, 900, cor=txt, acento=acento, largura=larg, entrelinha=1.04)
        y += 36
        sub = s.get('sub', 'Grátis, sem cartão.')
        y += escreve(d, (M, y), sub, 46, 700, cor=txt, acento=acento, largura=larg, entrelinha=1.25)
        y += 44
        # botão com o link
        f = fonte(40, 800)
        lk = s.get('link', LINK)
        w = f.getlength(lk)
        cor_b = BRANCO if fn2 in ('verde', 'escuro') else VERDE
        cor_bt = VERDE_ESC if fn2 in ('verde', 'escuro') else BRANCO
        d.rounded_rectangle((M, y, M + w + 100, y + 104), radius=52, fill=cor_b)
        d.text((M + 50, y + 52), lk, font=f, fill=cor_bt, anchor='lm')
        y += 104 + 22
        dica = s.get('dica', 'Link na bio · abre no telemóvel ou no computador')
        y += escreve(d, (M, y), dica, 30, 500, cor=subtil if fn2 in ('creme', 'branco') else txt, largura=larg)
        y += 50
        pontos = s.get('pontos', ['Diz-te quanto guardar', 'Avisa antes de cada prazo', 'Explica em português simples'])
        for p_ in pontos:
            cor_v = BRANCO if fn2 in ('verde', 'escuro') else VERDE
            d.ellipse((M, y, M + 52, y + 52), fill=cor_v)
            cv = VERDE if fn2 in ('verde', 'escuro') else BRANCO
            d.line((M + 14, y + 27, M + 23, y + 36, M + 39, y + 17), fill=cv, width=6, joint='curve')
            escreve(d, (M + 76, y + 4), p_, 38, 600, cor=txt, largura=larg - 80)
            y += 76
        # promessa em caixa
        prom = PROMESSA_BR if br else PROMESSA
        extra = s.get('aviso')
        texto_cx = prom + (f'\n{extra}' if extra else '')
        hp = altura(texto_cx, 31, 500, larg - 80, 1.34) + 72
        yp = H - 70 - hp
        cor_cx = (255, 255, 255, 38) if fn2 in ('verde', 'escuro') else BRANCO
        d.rounded_rectangle((M, yp, W - M, yp + hp), radius=32, fill=cor_cx)
        escreve(d, (M + 40, yp + 36), texto_cx, 31, 500, cor=txt if fn2 in ('verde', 'escuro') else (55, 65, 81),
                acento=acento, largura=larg - 80, entrelinha=1.34)
        if s.get('qr'):
            q = qr('https://' + LINK, 190)
            img.alpha_composite(q, (W - M - 190, 210))
    return img


# ---------------------------------------------------------------- 9:16 estático
SW, SH = 1080, 1920


def story(s: dict, br=False) -> Image.Image:
    """Story 1080×1920. Zonas livres: 250 px em cima, 340 px em baixo."""
    fn = s.get('fundo', 'verde')
    fundo_cor, txt, acento, subtil = FUNDOS[fn]
    img = fundo((SW, SH), fn)
    d = pincel(img)
    larg = SW - 2 * M
    logo(img, (M, 250), tam=62, cor_texto=txt)
    tipo = s['tipo']
    y = 400
    if not s.get('ecra') and tipo in ('titulo',):
        tam0 = cabe(s['titulo'], s.get('tam', 104), 900, larg, 520, entrelinha=1.05, minimo=60)
        h0 = 110 + altura(s['titulo'], tam0, 900, larg, 1.05) + (34 + altura(s['corpo'], 42, 500, larg, 1.34) if s.get('corpo') else 0)
        y = max(400, int(400 + (1400 - 400 - h0) * 0.45))
    if s.get('etiqueta'):
        cf = (255, 255, 255, 40) if fn in ('verde', 'escuro', 'laranja') else VERDE_CLARO
        ct = BRANCO if fn in ('verde', 'escuro', 'laranja') else VERDE_ESC
        cx = pilula(d, (M, y), s['etiqueta'], 32, 800, cor_fundo=cf, cor_texto=ct)
        y = cx[3] + 40
    if tipo == 'contagem':
        f = fonte(400, 900)
        d.text((M - 16, y - 40), str(s['numero']), font=f, fill=txt, anchor='la')
        bb = d.textbbox((M - 16, y - 40), str(s['numero']), font=f, anchor='la')
        d.text((bb[2] + 24, bb[3] - 40), s.get('unidade', 'dias'), font=fonte(80, 800), fill=acento, anchor='ls')
        y = bb[3] + 40
        y += escreve(d, (M, y), s['titulo'], 68, 800, cor=txt, acento=acento, largura=larg, entrelinha=1.12)
        if s.get('corpo'):
            y += 30
            y += escreve(d, (M, y), s['corpo'], 40, 500, cor=txt if fn != 'creme' else (55, 65, 81), acento=acento,
                         largura=larg, entrelinha=1.34)
    else:
        tam = cabe(s['titulo'], s.get('tam', 104), 900, larg, 520, entrelinha=1.05, minimo=60)
        y += escreve(d, (M, y), s['titulo'], tam, 900, cor=txt, acento=acento, largura=larg, entrelinha=1.05)
        if s.get('corpo'):
            y += 34
            y += escreve(d, (M, y), s['corpo'], 42, 500, cor=txt if fn not in ('creme', 'branco') else (55, 65, 81),
                         acento=acento, largura=larg, entrelinha=1.34)
    if s.get('ecra'):
        y += 50
        larg_t = s.get('largura', 700)
        c0, c1 = s.get('corte', (0, 0.6))
        bez = max(10, larg_t // 36)
        disp = SH - 420 - 50 - y  # o telemóvel acaba antes do botão do link
        frac = (disp - 2 * bez) / ((larg_t - 2 * bez) * 2532 / 1170)
        c1 = min(c1, c0 + max(0.12, frac))
        tel = telemovel(s['ecra'], larg_t, corte=(c0, c1))
        cola(img, tel, ((SW - tel.width) // 2, y))
        img = img.crop((0, 0, SW, SH))
        d = pincel(img)
    # sondagem / caixa de perguntas: o espaço do meio fica livre para o
    # autocolante do Instagram (põe-se à mão ao agendar — ver o calendário).
    # rodapé: link e fonte (acima da zona de resposta do story)
    yl = SH - 420
    if s.get('fonte'):
        hf = altura(s['fonte'], 26, 400, larg, 1.3)
        escreve(d, (M, yl - hf - 30), s['fonte'], 26, 400, cor=subtil if fn in ('creme', 'branco') else txt,
                acento=subtil, largura=larg, entrelinha=1.3)
    f = fonte(38, 800)
    lk = s.get('rodape', 'Grátis, sem cartão · ' + LINK)
    w = f.getlength(lk)
    cor_b = BRANCO if fn in ('verde', 'escuro', 'laranja') else VERDE
    cor_bt = VERDE_ESC if fn in ('verde', 'escuro', 'laranja') else BRANCO
    d.rounded_rectangle(((SW - w) / 2 - 44, yl, (SW + w) / 2 + 44, yl + 96), radius=48, fill=cor_b)
    d.text((SW / 2, yl + 48), lk, font=f, fill=cor_bt, anchor='mm')
    return img
