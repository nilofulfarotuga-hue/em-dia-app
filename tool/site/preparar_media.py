# -*- coding: utf-8 -*-
"""Prepara os media do site público (site/assets/):
- copia a fonte Inter (assets/fonts → site/assets/fonts)
- converte capturas golden (test/golden/_fotos/*_medio_pt.png) para WebP
- desenha o ícone provisório (favicon.svg/.png, apple-touch, 512) e a imagem OG 1200×630
- gera o vídeo de herói (8 s, ken-burns sobre 4 capturas reais) e o poster com o ffmpeg do BoraStudio

Correr: python tool/site/preparar_media.py  (Python 3.12 com Pillow)
Tudo o que sai daqui é regenerável.
"""
import os, shutil, subprocess, sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

RAIZ = Path(__file__).resolve().parents[2]
SITE = RAIZ / "site"
FOTOS = RAIZ / "test" / "golden" / "_fotos"
FFMPEG = Path(r"C:\BoraLocal\BoraStudio\_bin\ffmpeg.exe")
FONTE = RAIZ / "assets" / "fonts" / "Inter-VariableFont.ttf"

VERDE = (22, 163, 74)
VERDE_ESCURO = (6, 95, 70)
TINTA = (17, 24, 39)
FUNDO = (246, 247, 244)

CAPTURAS = [
    ("painel_verde", "Painel: está tudo em dia"),
    ("recibos", "Calculadora do recibo verde"),
    ("calendario", "Calendário de prazos"),
    ("carro", "O carro: seguro, inspeção, IUC"),
    ("recibos_irs", "Quanto guardar para o IRS"),
    ("painel_laranja", "Aviso: tens 1 coisa a vencer"),
]
VIDEO_FOTOS = ["painel_verde", "recibos", "calendario", "carro"]


def fonte(tamanho, peso="Bold"):
    f = ImageFont.truetype(str(FONTE), tamanho)
    try:
        f.set_variation_by_name(peso)
    except Exception:
        pass
    return f


def icone(tamanho):
    """Quadrado verde, canto 16/64 do lado, visto branco grosso. Provisório até haver logo aprovado."""
    escala = 4
    s = tamanho * escala
    im = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle([0, 0, s - 1, s - 1], radius=s // 4, fill=VERDE)
    w = s * 0.11
    pts = [(s * 0.26, s * 0.52), (s * 0.43, s * 0.69), (s * 0.75, s * 0.33)]
    d.line(pts, fill=(255, 255, 255), width=int(w), joint="curve")
    for p in pts:
        d.ellipse([p[0] - w / 2, p[1] - w / 2, p[0] + w / 2, p[1] + w / 2], fill=(255, 255, 255))
    return im.resize((tamanho, tamanho), Image.LANCZOS)


def texto_quebrado(d, txt, f, largura):
    linhas, atual = [], ""
    for palavra in txt.split():
        teste = (atual + " " + palavra).strip()
        if d.textlength(teste, font=f) <= largura:
            atual = teste
        else:
            linhas.append(atual)
            atual = palavra
    if atual:
        linhas.append(atual)
    return linhas


def og():
    im = Image.new("RGB", (1200, 630), FUNDO)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 0, 1200, 14], fill=VERDE)
    im.paste(icone(96), (72, 72), icone(96))
    d.text((190, 84), "Em Dia", font=fonte(52, "ExtraBold"), fill=TINTA)
    f = fonte(66, "ExtraBold")
    y = 220
    for l in texto_quebrado(d, "Nunca mais levas multa da Segurança Social.", f, 1060):
        d.text((72, y), l, font=f, fill=TINTA)
        y += 78
    d.text((72, y + 24), "Calculadora de recibo verde grátis · Segurança Social, IVA, IRS e o carro",
           font=fonte(30, "Medium"), fill=(107, 114, 128))
    d.rounded_rectangle([72, 530, 520, 592], radius=16, fill=VERDE)
    d.text((100, 545), "Grátis 30 dias, sem cartão", font=fonte(28, "Bold"), fill=(255, 255, 255))
    im.save(SITE / "assets" / "img" / "og.jpg", quality=88, optimize=True)


def capturas():
    for nome, _ in CAPTURAS:
        src = FOTOS / f"{nome}_medio_pt.png"
        im = Image.open(src).convert("RGB")
        im = im.resize((780, int(780 * im.height / im.width)), Image.LANCZOS)
        im.save(SITE / "assets" / "img" / f"{nome}.webp", "WEBP", quality=78, method=6)


def video():
    out = SITE / "assets" / "video"
    entradas = [FOTOS / f"{n}_medio_pt.png" for n in VIDEO_FOTOS]
    d_frames = 60  # 2,4 s a 25 fps
    dur = d_frames / 25.0
    xf = 0.5
    args = [str(FFMPEG), "-y", "-loglevel", "error"]
    for e in entradas:
        args += ["-loop", "1", "-t", "1", "-i", str(e)]
    fc = []
    for i in range(len(entradas)):
        fc.append(
            f"[{i}:v]scale=2560:1440:force_original_aspect_ratio=increase,crop=2560:1440,"
            f"boxblur=30:6,eq=brightness=-0.28:saturation=0.9[bg{i}];"
            f"[{i}:v]scale=-1:1360[fg{i}];"
            f"[bg{i}][fg{i}]overlay=(W-w)/2:(H-h)/2,trim=end_frame=1,"
            f"zoompan=z='min(zoom+0.0012,1.16)':d={d_frames}:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1280x720:fps=25,"
            f"format=yuv420p[z{i}]"
        )
    ultimo = "z0"
    for i in range(1, len(entradas)):
        offset = i * (dur - xf)
        saida = f"x{i}"
        fc.append(f"[{ultimo}][z{i}]xfade=transition=fade:duration={xf}:offset={offset:.2f}[{saida}]")
        ultimo = saida
    args += ["-filter_complex", ";".join(fc), "-map", f"[{ultimo}]",
             "-c:v", "libx264", "-profile:v", "main", "-level", "3.1", "-preset", "slow", "-crf", "30",
             "-pix_fmt", "yuv420p", "-movflags", "+faststart", "-an", str(out / "heroi.mp4")]
    subprocess.run(args, check=True)
    subprocess.run([str(FFMPEG), "-y", "-loglevel", "error", "-ss", "0.6", "-i", str(out / "heroi.mp4"),
                    "-frames:v", "1", "-q:v", "4", str(out / "heroi-poster.jpg")], check=True)


def main():
    for p in ["assets/fonts", "assets/img", "assets/video", "assets/js", "testes"]:
        (SITE / p).mkdir(parents=True, exist_ok=True)
    shutil.copy2(FONTE, SITE / "assets" / "fonts" / "Inter-VariableFont.ttf")
    for t, nome in [(32, "favicon-32.png"), (180, "apple-touch-icon.png"), (512, "icon-512.png")]:
        icone(t).save(SITE / "assets" / "img" / nome, optimize=True)
    og()
    capturas()
    if "--sem-video" not in sys.argv:
        video()
    for f in sorted((SITE / "assets").rglob("*")):
        if f.is_file():
            print(f"{f.relative_to(SITE)}  {f.stat().st_size / 1024:.1f} KB")


if __name__ == "__main__":
    main()
