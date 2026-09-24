"""Reescreve o CSV das redes com os cabeçalhos EXATOS do ficheiro de exemplo da Meta.

Porquê: nesta sessão o facebook.com estava bloqueado e não foi possível ler os
nomes das colunas do «carregamento em massa» do Meta Business Suite. O nosso
CSV (`docs/marketing/redes-em-dia/meta-carregamento-em-massa.csv`) usa nomes
descritivos; este script lê o ficheiro de exemplo que o Business Suite dá
(Planeador → Carregamento em massa → Transferir ficheiro de exemplo) e copia
cada coluna para o cabeçalho certo, por palavras-chave. Colunas que não
reconhecer ficam vazias e são listadas no fim (para decidir à mão).

    python tool/redes/csv_meta.py caminho/do/exemplo-da-meta.csv [formato-da-data]

formato-da-data (opcional, por omissão copia o do exemplo se o reconhecer):
    "%m/%d/%Y %H:%M"  ou  "%Y-%m-%d %H:%M"  ou  "%d/%m/%Y %H:%M"
"""
from __future__ import annotations

import csv
import datetime as dt
import os
import re
import sys

BASE = os.path.join(os.path.dirname(__file__), '..', '..', 'docs', 'marketing', 'redes-em-dia')
ORIGEM = os.path.join(BASE, 'meta-carregamento-em-massa.csv')

# palavra-chave no cabeçalho da Meta → coluna nossa
MAPA = [
    (r'(description|descri|text|texto|caption|legenda|message|mensagem)', 'Description'),
    (r'(title|t[ií]tulo)', 'Title'),
    (r'(cover|capa|thumbnail|miniatura)', 'Cover image URL'),
    (r'(media|m[ée]dia|image|imagem|photo|foto|video|v[ií]deo|file|ficheiro|url)', 'Media URL'),
    (r'(link)', 'Link'),
    (r'(type|tipo|format)', 'Post type'),
    (r'(platform|plataforma|account|conta|placement|posicionamento)', 'Platforms'),
    (r'(date|data|time|hora|schedul|agend|publish|publica)', '_quando'),
]


def _formato_data(amostra: str) -> str:
    amostra = amostra.strip()
    if re.match(r'\d{4}-\d{2}-\d{2}', amostra):
        return '%Y-%m-%d %H:%M'
    if re.match(r'\d{1,2}/\d{1,2}/\d{4}', amostra):
        return '%m/%d/%Y %H:%M'  # o Business Suite está em inglês dos EUA
    return '%Y-%m-%d %H:%M'


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    exemplo = sys.argv[1]
    with open(exemplo, encoding='utf-8-sig', newline='') as f:
        leitor = csv.reader(f)
        cab = next(leitor)
        amostras = next(leitor, [''] * len(cab))
    fmt = sys.argv[2] if len(sys.argv) > 2 else None
    alvo = {}
    for i, c in enumerate(cab):
        for rx, nosso in MAPA:
            if re.search(rx, c, re.I):
                alvo[c] = nosso
                if nosso == '_quando' and not fmt and i < len(amostras):
                    fmt = _formato_data(amostras[i])
                break
    fmt = fmt or '%Y-%m-%d %H:%M'
    with open(ORIGEM, encoding='utf-8-sig', newline='') as f:
        linhas = list(csv.DictReader(f))
    saida = os.path.join(BASE, 'meta-carregamento-em-massa-FORMATO-META.csv')
    with open(saida, 'w', encoding='utf-8-sig', newline='') as f:
        w = csv.writer(f, quoting=csv.QUOTE_ALL)
        w.writerow(cab)
        for l in linhas:
            quando = dt.datetime.strptime(f"{l['Scheduled date']} {l['Scheduled time']}", '%Y-%m-%d %H:%M')
            linha = []
            for c in cab:
                nosso = alvo.get(c)
                if nosso == '_quando':
                    if re.search(r'(time|hora)', c, re.I) and not re.search(r'(date|data)', c, re.I):
                        linha.append(quando.strftime('%H:%M'))
                    elif re.search(r'(date|data)', c, re.I) and not re.search(r'(time|hora)', c, re.I):
                        linha.append(quando.strftime(fmt.split(' ')[0]))
                    else:
                        linha.append(quando.strftime(fmt))
                elif nosso:
                    linha.append(l.get(nosso, ''))
                else:
                    linha.append('')
            w.writerow(linha)
    print('escrito:', saida)
    sem = [c for c in cab if c not in alvo]
    if sem:
        print('colunas da Meta sem correspondência (ficaram vazias):', ', '.join(sem))
    print('mapa usado:', {k: v for k, v in alvo.items()})


if __name__ == '__main__':
    main()
