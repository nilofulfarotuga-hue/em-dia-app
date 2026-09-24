"""Música original para os reels (gerada por código: sem direitos de terceiros).

Batida leve e otimista (pop minimal): bombo, palmas, pratos, baixo, acordes e
um arpejo. Cada reel tem tom e andamento próprios (semente), para não soarem
todos iguais. Nos cortes de plano entra um «whoosh» suave.
"""
from __future__ import annotations

import wave

import numpy as np

SR = 44100

# progressões (graus em semitons a partir da tónica) — I V vi IV e variações
PROGRESSOES = [
    [(0, 4, 7), (7, 11, 14), (9, 12, 16), (5, 9, 12)],
    [(9, 12, 16), (5, 9, 12), (0, 4, 7), (7, 11, 14)],
    [(0, 4, 7), (5, 9, 12), (9, 12, 16), (7, 11, 14)],
]


def _hz(midi):
    return 440.0 * 2 ** ((midi - 69) / 12)


def _env(n, a=0.005, r=0.3):
    t = np.arange(n) / SR
    e = np.minimum(1, t / max(a, 1e-4)) * np.exp(-t / max(r, 1e-4))
    return e


def _lp(x, corte):
    # filtro passa-baixo de 1 polo
    a = np.exp(-2 * np.pi * corte / SR)
    y = np.empty_like(x)
    acc = 0.0
    # vetorizado por blocos seria mais rápido; os sinais são curtos
    for i in range(len(x)):
        acc = (1 - a) * x[i] + a * acc
        y[i] = acc
    return y


def _saw(f, n, fase=0.0):
    t = np.arange(n) / SR
    return 2 * ((t * f + fase) % 1) - 1


def gera(duracao: float, cortes=(), semente=0, caminho='musica.wav'):
    rng = np.random.default_rng(semente)
    bpm = [100, 104, 108, 112, 96][semente % 5]
    tonica = [60, 62, 57, 65, 64][(semente // 2) % 5]  # dó, ré, lá, fá, mi
    prog = PROGRESSOES[semente % len(PROGRESSOES)]
    n = int(duracao * SR)
    mix = np.zeros(n)
    batida = 60 / bpm
    compasso = batida * 4

    # bombo em 1 e 3 (+ um fantasma), palmas em 2 e 4, pratos em colcheias
    kick_n = int(0.35 * SR)
    tk = np.arange(kick_n) / SR
    freq = 45 + 90 * np.exp(-tk * 30)
    kick = np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.exp(-tk * 9)
    clap_n = int(0.18 * SR)
    clap = rng.standard_normal(clap_n) * _env(clap_n, 0.001, 0.05)
    clap = clap - _lp(clap, 900)
    hat_n = int(0.05 * SR)
    hat = rng.standard_normal(hat_n) * _env(hat_n, 0.0005, 0.012)
    hat = hat - _lp(hat, 6000)

    def poe(sinal, t0, g):
        i = int(t0 * SR)
        if i >= n:
            return
        j = min(n, i + len(sinal))
        mix[i:j] += sinal[: j - i] * g

    t = 0.0
    b = 0
    while t < duracao:
        pos = b % 4
        if pos in (0, 2):
            poe(kick, t, 0.9)
        if pos in (1, 3):
            poe(clap, t, 0.35)
        poe(hat, t, 0.10)
        poe(hat, t + batida / 2, 0.16)
        t += batida
        b += 1

    # acordes (pad de serra filtrada) + baixo + arpejo
    pad = np.zeros(n)
    baixo = np.zeros(n)
    arp = np.zeros(n)
    c = 0
    t = 0.0
    while t < duracao:
        acorde = prog[c % len(prog)]
        i0 = int(t * SR)
        m = min(n - i0, int(compasso * SR))
        if m <= 0:
            break
        tt = np.arange(m) / SR
        env = np.minimum(1, tt / 0.08) * np.minimum(1, (m / SR - tt) / 0.1)
        for g in acorde:
            f = _hz(tonica + g)
            pad[i0:i0 + m] += (_saw(f * 1.003, m) + _saw(f * 0.997, m, 0.3)) * env * 0.06
        fb = _hz(tonica + acorde[0] - 24)
        for k in range(8):  # baixo em colcheias
            ib = i0 + int(k * batida / 2 * SR)
            nb = min(int(batida / 2 * SR * 0.9), n - ib)
            if nb <= 0:
                continue
            tb = np.arange(nb) / SR
            baixo[ib:ib + nb] += (np.sin(2 * np.pi * fb * tb) + 0.25 * _saw(fb, nb)) * _env(nb, 0.004, 0.18) * 0.32
        notas = [acorde[0], acorde[1], acorde[2], acorde[1] + 12]
        for k in range(16):  # arpejo em semicolcheias
            ia = i0 + int(k * batida / 4 * SR)
            na = min(int(0.22 * SR), n - ia)
            if na <= 0:
                continue
            fa = _hz(tonica + 12 + notas[k % 4])
            ta = np.arange(na) / SR
            arp[ia:ia + na] += np.sin(2 * np.pi * fa * ta) * _env(na, 0.002, 0.07) * 0.07
        t += compasso
        c += 1
    pad = _lp(pad, 1800)
    mix += pad + baixo + arp

    # whoosh nos cortes de plano
    for tc in cortes:
        wn = int(0.35 * SR)
        ruido = rng.standard_normal(wn)
        tw = np.arange(wn) / SR
        env = np.sin(np.pi * tw / 0.35) ** 2
        w = ruido - _lp(ruido, 1500)
        poe(w * env, max(0, tc - 0.2), 0.12)

    # fecho: entrada e saída suaves, saturação leve, normalização
    fi = int(0.03 * SR)
    fo = int(0.8 * SR)
    mix[:fi] *= np.linspace(0, 1, fi)
    mix[-fo:] *= np.linspace(1, 0, fo) ** 1.5
    mix = np.tanh(mix * 1.1)
    mix = mix / (np.max(np.abs(mix)) + 1e-9) * 0.6  # pico ~ -4,5 dBFS: fundo, não grito
    est = np.stack([mix, np.roll(mix, 40) * 0.98], axis=1)
    dados = (est * 32767).astype('<i2')
    with wave.open(caminho, 'wb') as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(SR)
        wf.writeframes(dados.tobytes())
    return caminho
