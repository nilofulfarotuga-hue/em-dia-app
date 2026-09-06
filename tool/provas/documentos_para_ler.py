#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Faz cinco documentos de despesa para provar a leitura por foto.

HONESTIDADE, primeiro: estes documentos NÃO são faturas reais do Danilo. São
feitos aqui, com os campos e o desenho das faturas portuguesas a sério — nome
de quem emite, data, total, número de contribuinte, e a caixa de "Pagamento por
referência" com entidade e referência. Servem para provar que a Edge Function
`ler-documento` tira os campos certos de uma imagem tremida.

Quando o Danilo tirar cinco fotos verdadeiras, corre-se o mesmo teste com elas
e substitui-se a prova. Está pedido em `docs/PENDENTE-DANILO.md`.

Cada documento sai duas vezes: limpo (como um PDF descarregado) e "fotografado"
— rodado meio grau, com sombra, ruído e compressão, que é como as fotos chegam
de um telemóvel dentro de um carro.

Uso: python tool/provas/documentos_para_ler.py
Saída: docs/provas/ocr/<nome>.jpg e docs/provas/ocr/esperado.json
"""
from __future__ import annotations

import io
import json
import random
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

for fluxo in (sys.stdout, sys.stderr):
    try:
        fluxo.reconfigure(encoding="utf-8", errors="replace")
    except Exception:  # noqa: BLE001
        pass

RAIZ = Path(__file__).resolve().parents[2]
SAIDA = RAIZ / "docs" / "provas" / "ocr"
FONTES = Path("C:/Windows/Fonts")

random.seed(20260906)  # sempre as mesmas fotos, para a prova ser repetível


def fonte(nome: str, tamanho: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONTES / nome), tamanho)


N = lambda t: fonte("arial.ttf", t)      # noqa: E731  normal
B = lambda t: fonte("arialbd.ttf", t)    # noqa: E731  negrito
M = lambda t: fonte("consola.ttf", t)    # noqa: E731  monoespaçada (talões)


class Folha:
    """Uma folha A5 em pé onde se escreve linha a linha."""

    def __init__(self, largura=1000, altura=1414, fundo=(252, 252, 250)):
        self.img = Image.new("RGB", (largura, altura), fundo)
        self.d = ImageDraw.Draw(self.img)
        self.y = 60
        self.larg = largura

    def linha(self, texto, f=None, cor=(20, 20, 20), x=60, salto=None, centro=False):
        f = f or N(26)
        if centro:
            larguraTexto = self.d.textlength(texto, font=f)
            x = (self.larg - larguraTexto) / 2
        self.d.text((x, self.y), texto, font=f, fill=cor)
        self.y += salto if salto is not None else int(f.size * 1.55)

    def espaco(self, px=20):
        self.y += px

    def risco(self, cor=(190, 190, 190), margem=60):
        self.d.line([(margem, self.y), (self.larg - margem, self.y)], fill=cor, width=2)
        self.y += 18

    def caixa(self, altura, cor=(245, 245, 245), borda=(150, 150, 150), margem=60):
        self.d.rectangle([margem, self.y, self.larg - margem, self.y + altura],
                         fill=cor, outline=borda, width=2)

    def par(self, esquerda, direita, f=None, fd=None):
        f = f or N(26)
        fd = fd or f
        self.d.text((60, self.y), esquerda, font=f, fill=(20, 20, 20))
        larguraDireita = self.d.textlength(direita, font=fd)
        self.d.text((self.larg - 60 - larguraDireita, self.y), direita, font=fd, fill=(20, 20, 20))
        self.y += int(f.size * 1.55)


def como_foto(img: Image.Image, angulo: float, escuro: float = 0.92) -> Image.Image:
    """Faz a folha parecer uma foto tirada à pressa: torta, com sombra e ruído."""
    img = img.rotate(angulo, expand=True, fillcolor=(35, 35, 38), resample=Image.BICUBIC)
    # uma sombra oblíqua, como a mão a tapar a luz
    sombra = Image.new("L", img.size, 255)
    ds = ImageDraw.Draw(sombra)
    ds.polygon([(0, 0), (img.width, 0), (img.width, int(img.height * 0.25)), (0, int(img.height * 0.55))], fill=215)
    sombra = sombra.filter(ImageFilter.GaussianBlur(60))
    img = Image.composite(img, Image.new("RGB", img.size, (0, 0, 0)), sombra.point(lambda v: int(v * escuro)))
    # ruído fino do sensor
    px = img.load()
    for _ in range(int(img.width * img.height * 0.02)):
        x = random.randrange(img.width)
        y = random.randrange(img.height)
        r, g, b = px[x, y]
        n = random.randint(-16, 16)
        px[x, y] = (max(0, min(255, r + n)), max(0, min(255, g + n)), max(0, min(255, b + n)))
    img = img.filter(ImageFilter.GaussianBlur(0.6))
    buf = io.BytesIO()
    img.save(buf, "JPEG", quality=72)
    buf.seek(0)
    return Image.open(buf).convert("RGB")


# ---------------------------------------------------------------- documentos

def fatura_luz() -> tuple[Image.Image, dict]:
    f = Folha()
    f.linha("EDP COMERCIAL", B(46), cor=(0, 90, 60))
    f.linha("Comercialização de Energia, S.A.", N(22), cor=(90, 90, 90))
    f.linha("Av. 24 de Julho, 12 · 1249-300 Lisboa", N(20), cor=(120, 120, 120))
    f.linha("NIF 503 504 564", N(20), cor=(120, 120, 120))
    f.espaco(10); f.risco(); f.espaco(6)
    f.linha("FATURA / RECIBO  FT 2026/1180453", B(30))
    f.espaco(6)
    f.par("Data do documento", "14/08/2026")
    f.par("Data de vencimento", "05/09/2026")
    f.par("Período faturado", "12/07/2026 a 11/08/2026")
    f.espaco(10); f.risco(); f.espaco(6)
    f.linha("CLIENTE", B(24), cor=(90, 90, 90))
    f.linha("Danilo Alves Ferreira", N(26))
    f.linha("Rua Dr. Francisco dos Prazeres, 14, 2.º Esq.", N(24))
    f.linha("6300-654 Guarda", N(24))
    f.linha("Contribuinte n.º 274 819 553", N(26))
    f.espaco(10); f.risco(); f.espaco(6)
    f.par("Energia ativa (consumo 214 kWh)", "38,42 €")
    f.par("Potência contratada (6,90 kVA)", "12,17 €")
    f.par("Taxa DGEG", "0,07 €")
    f.par("Imposto especial de consumo", "1,04 €")
    f.par("IVA", "9,20 €")
    f.espaco(6); f.risco(); f.espaco(6)
    f.par("TOTAL A PAGAR", "60,90 €", B(34), B(34))
    f.espaco(24)
    topo = f.y
    f.caixa(190, cor=(240, 246, 255), borda=(120, 150, 200))
    f.y = topo + 22
    f.linha("PAGAMENTO POR REFERÊNCIA MULTIBANCO", B(24), cor=(40, 70, 140), x=86)
    f.espaco(6)
    f.linha("Entidade        10963", M(34), x=86)
    f.linha("Referência      417 903 258", M(34), x=86)
    f.linha("Valor           60,90 €", M(34), x=86)
    esperado = {
        "tipo": "fatura",
        "entidade_nome_contem": "EDP",
        "nif": "274819553",
        "data_documento": "2026-08-14",
        "valor_total": 60.90,
        "entidade_pagamento": "10963",
        "referencia_pagamento": "417903258",
        "conta_para_irs": True,
    }
    return f.img, esperado


def fatura_telemovel() -> tuple[Image.Image, dict]:
    f = Folha()
    f.linha("MEO", B(56), cor=(0, 60, 130))
    f.linha("Altice Portugal, S.A. · NIF 504 615 947", N(20), cor=(120, 120, 120))
    f.espaco(10); f.risco(); f.espaco(6)
    f.linha("FATURA FT 26/0009914772", B(30))
    f.par("Data", "01/09/2026")
    f.par("Conta", "M-4417-88231")
    f.espaco(10); f.risco(); f.espaco(6)
    f.linha("Danilo Alves Ferreira", N(26))
    f.linha("NIF: 274819553", N(26))
    f.espaco(10); f.risco(); f.espaco(6)
    f.par("Pacote Fibra + TV + Telemóvel", "44,99 €")
    f.par("Chamadas fora do pacote", "2,15 €")
    f.par("IVA (23%)", "10,86 €")
    f.espaco(6); f.risco(); f.espaco(6)
    f.par("TOTAL", "58,00 €", B(34), B(34))
    f.espaco(30)
    topo = f.y
    f.caixa(150, cor=(245, 250, 245), borda=(140, 180, 140))
    f.y = topo + 24
    f.linha("PAGAMENTO POR DÉBITO DIRETO", B(26), cor=(30, 110, 60), x=86)
    f.espaco(4)
    f.linha("Este valor será debitado na sua conta", N(24), x=86)
    f.linha("no dia 08/09/2026. Não precisa de fazer nada.", N(24), x=86)
    esperado = {
        "tipo": "fatura",
        "entidade_nome_contem": "MEO",
        "nif": "274819553",
        "data_documento": "2026-09-01",
        "valor_total": 58.00,
        "entidade_pagamento": None,   # débito direto: não há referência
        "referencia_pagamento": None,
        "conta_para_irs": True,
    }
    return f.img, esperado


def talao_combustivel() -> tuple[Image.Image, dict]:
    f = Folha(largura=760, altura=1180, fundo=(254, 254, 252))
    f.linha("GALP ENERGIA", B(38), centro=True)
    f.linha("Posto Guarda Norte", N(24), centro=True)
    f.linha("Av. Rainha D. Amélia · 6300-749 Guarda", N(20), centro=True, cor=(110, 110, 110))
    f.linha("NIF 504 499 777", N(20), centro=True, cor=(110, 110, 110))
    f.espaco(8); f.risco(margem=40); f.espaco(6)
    f.linha("FATURA SIMPLIFICADA", B(28), centro=True)
    f.linha("FS 2026/GN/44127", M(24), centro=True)
    f.espaco(8)
    f.linha("Data: 05/09/2026   Hora: 07:12", M(24), x=40)
    f.linha("Bomba: 4          Cartão: --", M(24), x=40)
    f.espaco(8); f.risco(margem=40); f.espaco(6)
    f.linha("GASOLEO SIMPLES", B(28), x=40)
    f.espaco(4)
    f.linha("Litros ............  41,27 L", M(26), x=40)
    f.linha("Preco/litro .......  1,589 EUR", M(26), x=40)
    f.linha("Valor .............  65,58 EUR", M(26), x=40)
    f.espaco(8); f.risco(margem=40); f.espaco(6)
    f.linha("IVA 23% ...........  12,26 EUR", M(24), x=40)
    f.linha("TOTAL .............  65,58 EUR", B(30), x=40)
    f.espaco(10); f.risco(margem=40); f.espaco(6)
    f.linha("CONTRIBUINTE: 274819553", B(26), x=40)
    f.espaco(10)
    f.linha("Obrigado pela sua preferencia", N(22), centro=True, cor=(120, 120, 120))
    f.linha("Documento processado por programa", N(18), centro=True, cor=(150, 150, 150))
    f.linha("certificado n.º 1420/AT", N(18), centro=True, cor=(150, 150, 150))
    esperado = {
        "tipo": "combustivel",
        "entidade_nome_contem": "GALP",
        "nif": "274819553",
        "data_documento": "2026-09-05",
        "valor_total": 65.58,
        "litros": 41.27,
        "preco_litro": 1.589,
        "conta_para_irs": True,
    }
    return f.img, esperado


def talao_compra() -> tuple[Image.Image, dict]:
    f = Folha(largura=720, altura=1100, fundo=(255, 255, 253))
    f.linha("CONTINENTE", B(38), centro=True, cor=(180, 30, 30))
    f.linha("Modelo Continente Hipermercados, S.A.", N(18), centro=True, cor=(110, 110, 110))
    f.linha("Loja Guarda · NIF 502 011 475", N(18), centro=True, cor=(110, 110, 110))
    f.espaco(8); f.risco(margem=40); f.espaco(6)
    f.linha("FATURA SIMPLIFICADA FS 4471/26", M(22), x=40)
    f.linha("2026-09-03  18:44   Caixa 07", M(22), x=40)
    f.espaco(8); f.risco(margem=40); f.espaco(6)
    for artigo, preco in [("LEITE UHT MEIO GORDO 6X1L", "5,34"),
                          ("PAO DE FORMA INTEGRAL", "1,49"),
                          ("FRANGO INTEIRO KG", "6,12"),
                          ("ARROZ CAROLINO 1KG", "1,79"),
                          ("DETERGENTE LOICA 1L", "2,29"),
                          ("CAFE MOIDO 250G", "3,99")]:
        f.linha(f"{artigo:<28}{preco:>7}", M(22), x=40)
    f.espaco(8); f.risco(margem=40); f.espaco(6)
    f.linha(f"{'TOTAL':<28}{'21,02':>7}", B(30), x=40)
    f.linha(f"{'IVA INCLUIDO':<28}{'1,84':>7}", M(22), x=40)
    f.espaco(10); f.risco(margem=40); f.espaco(6)
    f.linha("NIF CLIENTE: 274819553", B(24), x=40)
    f.espaco(8)
    f.linha("Cartao Continente: **** 4412", M(20), x=40, cor=(120, 120, 120))
    esperado = {
        "tipo": "talao",
        "entidade_nome_contem": "CONTINENTE",
        "nif": "274819553",
        "data_documento": "2026-09-03",
        "valor_total": 21.02,
        "conta_para_irs": True,
    }
    return f.img, esperado


def fatura_agua() -> tuple[Image.Image, dict]:
    f = Folha()
    f.linha("ÁGUAS DA GUARDA, E.M.", B(40), cor=(20, 90, 150))
    f.linha("Praça do Município · 6300-854 Guarda", N(20), cor=(120, 120, 120))
    f.espaco(10); f.risco(); f.espaco(6)
    f.linha("FATURA N.º 2026/A/551204", B(30))
    f.par("Emitida em", "28/08/2026")
    f.par("Pagar até", "18/09/2026")
    f.par("Contrato", "GRD-2019-44120")
    f.espaco(10); f.risco(); f.espaco(6)
    f.linha("Danilo Alves Ferreira", N(26))
    f.linha("Rua Dr. Francisco dos Prazeres, 14", N(24))
    f.espaco(10); f.risco(); f.espaco(6)
    f.par("Água (9 m³)", "8,91 €")
    f.par("Saneamento", "4,05 €")
    f.par("Resíduos sólidos", "3,62 €")
    f.par("Taxa de recursos hídricos", "0,54 €")
    f.par("IVA", "0,89 €")
    f.espaco(6); f.risco(); f.espaco(6)
    f.par("TOTAL", "18,01 €", B(34), B(34))
    f.espaco(26)
    topo = f.y
    f.caixa(200, cor=(240, 248, 252), borda=(120, 170, 200))
    f.y = topo + 22
    f.linha("DADOS PARA PAGAMENTO", B(24), cor=(20, 90, 150), x=86)
    f.espaco(4)
    f.linha("Entidade    21344", M(32), x=86)
    f.linha("Referência  902 118 447", M(32), x=86)
    f.linha("Montante    18,01 EUR", M(32), x=86)
    f.espaco(4)
    f.linha("(sem número de contribuinte associado)", N(20), x=86, cor=(130, 130, 130))
    esperado = {
        "tipo": "fatura",
        "entidade_nome_contem": "GUARDA",
        "nif": None,                  # de propósito: não traz NIF do cliente
        "data_documento": "2026-08-28",
        "valor_total": 18.01,
        "entidade_pagamento": "21344",
        "referencia_pagamento": "902118447",
        "conta_para_irs": False,
    }
    return f.img, esperado


DOCUMENTOS = [
    ("1-fatura-luz-com-referencia", fatura_luz, -0.8),
    ("2-fatura-telemovel-debito-direto", fatura_telemovel, 1.1),
    ("3-talao-combustivel", talao_combustivel, -1.6),
    ("4-talao-compra-com-nif", talao_compra, 2.0),
    ("5-fatura-agua-sem-nif", fatura_agua, -0.5),
]


def main() -> int:
    SAIDA.mkdir(parents=True, exist_ok=True)
    esperados = {}
    for nome, fabrica, angulo in DOCUMENTOS:
        limpo, esperado = fabrica()
        foto = como_foto(limpo, angulo)
        caminho = SAIDA / f"{nome}.jpg"
        foto.save(caminho, "JPEG", quality=78)
        esperados[nome] = esperado
        print(f"{nome:<38} {caminho.stat().st_size // 1024:>4} KB  {foto.width}x{foto.height}")
    (SAIDA / "esperado.json").write_text(
        json.dumps(esperados, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"\nesperado.json com {len(esperados)} documentos")
    return 0


if __name__ == "__main__":
    sys.exit(main())
