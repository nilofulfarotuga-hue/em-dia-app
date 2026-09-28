"""Gera todas as peças das redes do Em Dia (missão redes-em-dia-2026-09-23).

    python tool/redes/gerar.py            # tudo
    python tool/redes/gerar.py carrosseis stories perfil csv   # só partes

Saída: docs/marketing/redes-em-dia/pecas/ + CALENDARIO-30-DIAS.md + CSV.
Antes de correr: as capturas reais (tool/redes/capturas_test.dart).
"""
from __future__ import annotations

import csv
import datetime as dt
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

from PIL import Image, ImageDraw  # noqa: E402

import carrossel  # noqa: E402
import conteudo as C  # noqa: E402
import reel  # noqa: E402
from motor import (BRANCO, CREME, LINK, PROMESSA, TINTA, VERDE, VERDE_ESC, cola, escreve, fonte, fundo,  # noqa: E402
                   guarda_png, logo, pincel, qr, telemovel, _icone)

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
BASE = os.path.join(RAIZ, 'docs', 'marketing', 'redes-em-dia')
PECAS = os.path.join(BASE, 'pecas')
RAW = 'https://raw.githubusercontent.com/nilofulfarotuga-hue/em-dia-app/main/docs/marketing/redes-em-dia/pecas/'

DIAS = ['segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado', 'domingo']


def rel(p):
    return os.path.relpath(p, BASE).replace(os.sep, '/')


# ------------------------------------------------------------------ carrosséis
def gera_carrosseis():
    for c in C.CARROSSEIS:
        pasta = os.path.join(PECAS, 'carrosseis', c['id'])
        n = len(c['laminas'])
        for i, s in enumerate(c['laminas'], 1):
            img = carrossel.lamina(s, i, n, br=c.get('br', False))
            guarda_png(img, os.path.join(pasta, f'{i:02d}.png'))
        print('carrossel', c['id'], n, 'lâminas')


# ------------------------------------------------------------------ reels
def gera_reels(so=None):
    for k, r in enumerate(C.REELS):
        if so and r['id'] not in so:
            continue
        saida = os.path.join(PECAS, 'reels', f"{r['id']}.mp4")
        capa = os.path.join(PECAS, 'reels', f"{r['id']}-capa.jpg")
        dur = reel.monta(r['planos'], saida, semente=k, br=r.get('br', False), capa=capa)
        r['_dur'] = dur
        print('reel', r['id'], f'{dur:.1f} s', os.path.getsize(saida) // 1024, 'KB')


# ------------------------------------------------------------------ stories
def gera_stories():
    for s in C.STORIES:
        s2 = dict(s)
        if s['tipo'] in ('sondagem', 'caixa_perguntas') and not s2.get('corpo'):
            s2['corpo'] = 'Responde aqui ↓' if not s.get('br') else 'Responda aqui ↓'
        if s.get('br'):
            s2['rodape'] = 'Grátis, sem cartão · ' + LINK
        img = carrossel.story(s2, br=s.get('br', False))
        guarda_png(img, os.path.join(PECAS, 'stories', f"{s['id']}.png"))
    print('stories', len(C.STORIES))


# ------------------------------------------------------------------ perfil
DESTAQUES = [('Prazos', 'calendário'), ('Recibos', 'recibo'), ('Carro', 'carro'), ('IVA', 'iva'),
             ('Brasil', 'br'), ('Ajuda', 'ajuda')]


def _desenha_simbolo(d, cx, cy, r, qual, cor):
    """Símbolos simples desenhados à mão (sem emojis nem ícones de terceiros)."""
    w = max(10, r // 7)
    if qual == 'calendário':
        d.rounded_rectangle((cx - r, cy - r * 0.8, cx + r, cy + r), radius=r * 0.2, outline=cor, width=w)
        d.line((cx - r, cy - r * 0.35, cx + r, cy - r * 0.35), fill=cor, width=w)
        d.line((cx - r * 0.45, cy - r * 1.05, cx - r * 0.45, cy - r * 0.6), fill=cor, width=w)
        d.line((cx + r * 0.45, cy - r * 1.05, cx + r * 0.45, cy - r * 0.6), fill=cor, width=w)
        d.line((cx - r * 0.45, cy + r * 0.3, cx - r * 0.1, cy + r * 0.62, cx + r * 0.5, cy), fill=cor, width=w, joint='curve')
    elif qual == 'recibo':
        d.rounded_rectangle((cx - r * 0.75, cy - r, cx + r * 0.75, cy + r), radius=r * 0.15, outline=cor, width=w)
        for k in range(3):
            y = cy - r * 0.45 + k * r * 0.45
            d.line((cx - r * 0.4, y, cx + r * 0.4, y), fill=cor, width=w)
    elif qual == 'carro':
        d.rounded_rectangle((cx - r, cy - r * 0.2, cx + r, cy + r * 0.55), radius=r * 0.2, outline=cor, width=w)
        d.line((cx - r * 0.65, cy - r * 0.2, cx - r * 0.4, cy - r * 0.7, cx + r * 0.4, cy - r * 0.7, cx + r * 0.65, cy - r * 0.2),
               fill=cor, width=w, joint='curve')
        for sx in (-0.55, 0.55):
            d.ellipse((cx + r * sx - r * 0.22, cy + r * 0.45, cx + r * sx + r * 0.22, cy + r * 0.89), fill=cor)
    elif qual == 'iva':
        f = fonte(int(r * 0.95), 900)
        d.text((cx, cy), '%', font=f, fill=cor, anchor='mm')
    elif qual == 'br':
        f = fonte(int(r * 0.8), 900)
        d.text((cx, cy), 'BR', font=f, fill=cor, anchor='mm')
    elif qual == 'ajuda':
        f = fonte(int(r * 1.3), 900)
        d.text((cx, cy), '?', font=f, fill=cor, anchor='mm')


def gera_perfil():
    pasta = os.path.join(PECAS, 'perfil')
    # foto de perfil (o Instagram corta em círculo: o símbolo fica ao centro)
    img = Image.new('RGBA', (1080, 1080), VERDE + (255,))
    ic = _icone(640)
    img.alpha_composite(ic, (220, 220))
    guarda_png(img, os.path.join(pasta, 'foto-perfil-1080.png'))
    # capa da página do Facebook: 1640×624 (mostra 820×312 no computador;
    # no telemóvel corta os lados: o essencial fica no centro 1100 px)
    W, H = 1640, 624
    capa = fundo((W, H), 'verde')
    d = pincel(capa)
    logo(capa, (290, 120), tam=96, cor_texto=BRANCO)
    escreve(d, (290, 262), 'Recibos verdes, IRS e prazos **sem sustos.**', 64, 900, cor=BRANCO, acento=(255, 237, 213),
            largura=760, entrelinha=1.08)
    escreve(d, (290, 440), 'Grátis, sem cartão · ' + LINK, 34, 700, cor=BRANCO, largura=800)
    tel = telemovel('painel', 330, corte=(0, 0.5))
    cola(capa, tel, (1000, 70))  # dentro do corte do telemóvel (centro ~1110 px)
    capa = capa.crop((0, 0, W, H))
    guarda_png(capa, os.path.join(pasta, 'capa-facebook-1640x624.png'))
    capa.convert('RGB').resize((851, 324), Image.LANCZOS).crop((0, 4, 851, 319)).save(
        os.path.join(pasta, 'capa-facebook-851x315.png'), optimize=True)
    # capas dos destaques do Instagram (1080×1920; o círculo mostra o centro)
    for nome, qual in DESTAQUES:
        im = Image.new('RGBA', (1080, 1920), VERDE + (255,))
        dd = pincel(im)
        dd.ellipse((240, 660, 840, 1260), fill=(255, 255, 255, 255))
        _desenha_simbolo(dd, 540, 960, 170, qual, VERDE_ESC)
        guarda_png(im, os.path.join(pasta, 'destaques', f'destaque-{nome.lower()}.png'))
    # cartaz A5 (300 dpi) para imprimir, com QR
    A5 = (1748, 2480)
    im = fundo(A5, 'verde')
    d = pincel(im)
    logo(im, (140, 150), tam=130, cor_texto=BRANCO)
    y = 380
    y += escreve(d, (140, y), 'Trabalhas a recibos verdes? **Estás em dia?**', 140, 900, cor=BRANCO, acento=(255, 237, 213),
                 largura=1470, entrelinha=1.04)
    y += 40
    y += escreve(d, (140, y), 'Quanto guardar para a Segurança Social e o IRS, que prazo vem a seguir e o que falta no carro. '
                 'Em português simples.', 58, 500, cor=BRANCO, largura=1400, entrelinha=1.3)
    q = qr('https://' + LINK, 560)
    d.rounded_rectangle((140, 1440, 140 + 640, 1440 + 640), radius=48, fill=BRANCO)
    im.alpha_composite(q, (180, 1480))
    escreve(d, (860, 1470), 'Aponta a câmara', 64, 800, cor=BRANCO, largura=780)
    escreve(d, (860, 1560), LINK, 50, 700, cor=(255, 237, 213), largura=800)
    escreve(d, (860, 1660), '**Grátis, sem cartão.**', 64, 900, cor=BRANCO, acento=BRANCO, largura=780)
    escreve(d, (140, 2170), PROMESSA, 40, 500, cor=BRANCO, largura=1470, entrelinha=1.35)
    guarda_png(im, os.path.join(pasta, 'cartaz-A5-qr.png'))
    print('perfil, capas, destaques e cartaz')


# ------------------------------------------------------------------ calendário e CSV
def _fmt_data(iso):
    d = dt.date.fromisoformat(iso)
    return f'{d.day:02d}/{d.month:02d}/{d.year}', DIAS[d.weekday()]


def publicacoes():
    """Todas as publicações do calendário, por data e hora."""
    out = []
    for c in C.CARROSSEIS:
        n = len(c['laminas'])
        out.append({
            'id': c['id'], 'data': c['data'], 'hora': c['hora'], 'rede': 'Instagram + Facebook', 'formato': f'Carrossel ({n} lâminas)',
            'publico': c['publico'], 'gancho': c['gancho'], 'hashtags': c['hashtags'],
            'texto': C.legenda(c['corpo'], br=c.get('br', False), fonte=c.get('fonte'), contabilista=c.get('contabilista')),
            'ficheiros': [f"pecas/carrosseis/{c['id']}/{i:02d}.png" for i in range(1, n + 1)], 'tipo_meta': 'Carrossel',
        })
    for r in C.REELS:
        out.append({
            'id': r['id'], 'data': r['data'], 'hora': r['hora'], 'rede': 'Instagram + Facebook', 'formato': 'Reel 9:16 com som',
            'publico': r['publico'], 'gancho': r['gancho'], 'hashtags': r['hashtags'],
            'texto': C.legenda(r['corpo'], br=r.get('br', False), fonte=r.get('fonte')),
            'ficheiros': [f"pecas/reels/{r['id']}.mp4"], 'capa': f"pecas/reels/{r['id']}-capa.jpg", 'tipo_meta': 'Reel',
        })
    for s in C.STORIES:
        extra = ''
        if s['tipo'] == 'sondagem':
            extra = f" — pôr o autocolante {s.get('sticker', 'Sondagem')} no espaço do meio"
        if s['tipo'] == 'caixa_perguntas':
            extra = ' — pôr o autocolante «Perguntas» no espaço do meio'
        out.append({
            'id': s['id'], 'data': s['data'], 'hora': s['hora'], 'rede': 'Instagram + Facebook (story)', 'formato': 'Story 9:16' + extra,
            'publico': 'Todos', 'gancho': s['titulo'].replace('**', ''), 'hashtags': '',
            'texto': '(story — sem legenda; pôr o autocolante de link para ' + LINK + ')',
            'ficheiros': [f"pecas/stories/{s['id']}.png"], 'tipo_meta': 'Story',
        })
    out.sort(key=lambda p: (p['data'], p['hora']))
    return out


def gera_calendario():
    pubs = publicacoes()
    L = ['# CALENDÁRIO 30 DIAS — redes do Em Dia (28/09/2026 a 27/10/2026)', '',
         '> Gerado por `tool/redes/gerar.py` a partir de `tool/redes/conteudo.py`. Não editar à mão: muda o conteúdo e volta a gerar.',
         '> Horas de Lisboa (a hora muda a 25/10: o Business Suite agenda na hora local da página).',
         '> Cadência: 5 reels + 3-4 carrosséis por semana + 1 story por dia. Carrosséis e reels vão para o Instagram e o Facebook',
         '> (no Business Suite, marca as duas contas). Stories agendam-se no mesmo sítio, um a um.', '',
         '## Resumo', '',
         '| Data | Dia | Hora | Rede | Formato | Público | Gancho | Ficheiro |', '|---|---|---|---|---|---|---|---|']
    for p in pubs:
        d, sem = _fmt_data(p['data'])
        fich = p['ficheiros'][0] if len(p['ficheiros']) == 1 else p['ficheiros'][0].rsplit('/', 1)[0] + '/'
        L.append(f"| {d} | {sem} | {p['hora']} | {p['rede']} | {p['formato']} | {p['publico']} | {p['gancho']} | `{fich}` |")
    L += ['', '## Textos finais (legenda + hashtags)', '']
    for p in pubs:
        if p['tipo_meta'] == 'Story':
            continue
        d, sem = _fmt_data(p['data'])
        L += [f"### {p['id']} · {d} ({sem}) {p['hora']} · {p['formato']} · {p['publico']}", '',
              f"**Gancho:** {p['gancho']}", '', '**Ficheiros:** ' + ', '.join(f'`{f}`' for f in p['ficheiros']), '']
        if p.get('capa'):
            L += [f"**Capa do reel:** `{p['capa']}`", '']
        L += ['```text', p['texto'], '', p['hashtags'], '```', '']
    L += ['## Stories', '', '| Data | Hora | Ficheiro | O que fazer ao agendar |', '|---|---|---|---|']
    for p in pubs:
        if p['tipo_meta'] != 'Story':
            continue
        d, _ = _fmt_data(p['data'])
        L.append(f"| {d} | {p['hora']} | `{p['ficheiros'][0]}` | autocolante de link → {LINK}{p['formato'].split('Story 9:16')[1]} |")
    with open(os.path.join(BASE, 'CALENDARIO-30-DIAS.md'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(L) + '\n')
    print('calendário', len(pubs), 'publicações')
    return pubs


# Cabeçalhos do CSV. POR CONFIRMAR com o «ficheiro de exemplo» que o Business
# Suite dá em Planeador → Carregamento em massa (facebook.com estava bloqueado
# nesta sessão). O `csv_meta.py` reescreve o CSV com os cabeçalhos exatos do
# ficheiro de exemplo que o Danilo descarregar.
CAMPOS = ['Title', 'Description', 'Link', 'Media URL', 'Scheduled date', 'Scheduled time', 'Post type', 'Platforms',
          'Cover image URL', 'Hashtags', 'Local file']


def gera_csv(pubs):
    linhas = []
    for p in pubs:
        if p['tipo_meta'] == 'Story':
            continue
        d = dt.date.fromisoformat(p['data'])
        linhas.append({
            'Title': f"{p['id']} — {p['gancho']}"[:100],
            'Description': p['texto'] + ('\n\n' + p['hashtags'] if p['hashtags'] else ''),
            'Link': 'https://' + LINK,
            'Media URL': ','.join(RAW + f.split('pecas/', 1)[1] for f in p['ficheiros']),
            'Scheduled date': d.strftime('%Y-%m-%d'),
            'Scheduled time': p['hora'],
            'Post type': p['tipo_meta'],
            'Platforms': 'Facebook,Instagram',
            'Cover image URL': RAW + p['capa'].split('pecas/', 1)[1] if p.get('capa') else '',
            'Hashtags': p['hashtags'],
            'Local file': ';'.join(p['ficheiros']),
        })
    todos = os.path.join(BASE, 'meta-carregamento-em-massa.csv')
    with open(todos, 'w', encoding='utf-8-sig', newline='') as f:
        w = csv.DictWriter(f, fieldnames=CAMPOS, quoting=csv.QUOTE_ALL)
        w.writeheader()
        w.writerows(linhas)
    # lotes de 25 (o limite por carregamento indicado nas fontes secundárias)
    for k in range(0, len(linhas), 25):
        caminho = os.path.join(BASE, f'meta-carregamento-em-massa-lote{k // 25 + 1}.csv')
        with open(caminho, 'w', encoding='utf-8-sig', newline='') as f:
            w = csv.DictWriter(f, fieldnames=CAMPOS, quoting=csv.QUOTE_ALL)
            w.writeheader()
            w.writerows(linhas[k:k + 25])
    print('csv', len(linhas), 'linhas')


# ------------------------------------------------------------------ folhas de contacto (revisão)
def folhas():
    import glob
    pasta = os.path.join(BASE, 'revisao')
    os.makedirs(pasta, exist_ok=True)
    for c in C.CARROSSEIS:
        fs = sorted(glob.glob(os.path.join(PECAS, 'carrosseis', c['id'], '*.png')))
        t = 360
        folha = Image.new('RGB', (len(fs) * (t + 10), int(t * 1.25) + 10), 'white')
        for i, f in enumerate(fs):
            folha.paste(Image.open(f).convert('RGB').resize((t, int(t * 1.25))), (i * (t + 10), 5))
        folha.save(os.path.join(pasta, f"{c['id']}.jpg"), quality=85)
    fs = sorted(glob.glob(os.path.join(PECAS, 'stories', '*.png')))
    t = 216
    folha = Image.new('RGB', (10 * (t + 8), 3 * (384 + 8)), 'white')
    for i, f in enumerate(fs):
        folha.paste(Image.open(f).convert('RGB').resize((t, 384)), ((i % 10) * (t + 8), (i // 10) * (384 + 8)))
    folha.save(os.path.join(pasta, 'stories.jpg'), quality=85)
    fs = sorted(glob.glob(os.path.join(PECAS, 'reels', '*-capa.jpg')))
    if fs:
        folha = Image.new('RGB', (11 * (t + 8), 2 * (384 + 8)), 'white')
        for i, f in enumerate(fs):
            folha.paste(Image.open(f).convert('RGB').resize((t, 384)), ((i % 11) * (t + 8), (i // 11) * (384 + 8)))
        folha.save(os.path.join(pasta, 'reels-capas.jpg'), quality=85)
    print('folhas de revisão')


if __name__ == '__main__':
    partes = sys.argv[1:] or ['carrosseis', 'stories', 'perfil', 'reels', 'csv', 'folhas']
    if 'carrosseis' in partes:
        gera_carrosseis()
    if 'stories' in partes:
        gera_stories()
    if 'perfil' in partes:
        gera_perfil()
    if 'reels' in partes:
        gera_reels([p for p in partes if p.startswith('R')] or None)
    if 'csv' in partes:
        gera_csv(gera_calendario())
    if 'folhas' in partes:
        folhas()
