# -*- coding: utf-8 -*-
"""Le a lista oficial de centros de inspecao (CITV) do IMT e escreve-a em JSON.

    python tool/dados/centros_inspecao.py            -> docs/dados/centros_inspecao.json
    python tool/dados/centros_inspecao.py --sql      -> tambem escreve o INSERT

Porque um script e nao uma API: o IMT nao publica API nenhuma, nem CSV, nem
XLSX. A unica fonte oficial e um PDF ("Lista CITV atualizada"), gerado de um
Excel interno que nao esta publicado. O dados.gov.pt nao tem este conjunto — a
unica coisa que o IMT la tem sao paragens de autocarro.

Duas armadilhas, as duas ja pagas por quem investigou isto antes:

1. **O URL do PDF muda de pasta** quando o IMT o actualiza (/2026/02/...). Por
   isso nunca se escreve o URL a mao: descobre-se na pagina de pesquisa.
2. **As coordenadas vem em varios formatos** e muitas vezes SEM o sinal
   negativo na longitude — que em Portugal continental e sempre negativa. Se
   isso passar, o centro aparece na China. Normaliza-se e valida-se contra uma
   caixa geografica; o que ficar de fora fica a NULL, nao a adivinhar.

E um travao de queda: se o PDF de repente der muito menos centros do que a
ultima vez, o script recusa-se a escrever. Um parser que parte em silencio
devolve "OK" enquanto perde metade do pais.
"""
import argparse
import hashlib
import io
import json
import os
import re
import sys
import urllib.request

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

PAGINA = "https://www.imt-ip.pt/veiculos/pesquisa-centros-inspecao/"
AGENTE = "EmDia/1.0 (+https://em-dia-site.pages.dev; app dos recibos verdes)"
SAIDA = "docs/dados/centros_inspecao.json"
MINIMO = 180          # travao de queda: abaixo disto, o parser partiu

# Portugal continental. Os Acores e a Madeira nao constam desta lista do IMT.
CAIXA_LAT = (36.9, 42.2)
CAIXA_LON = (-9.7, -6.1)

DISTRITOS = [
    "Aveiro", "Beja", "Braga", "Bragança", "Castelo Branco", "Coimbra", "Évora",
    "Faro", "Guarda", "Leiria", "Lisboa", "Portalegre", "Porto", "Santarém",
    "Setúbal", "Viana do Castelo", "Vila Real", "Viseu",
]


def buscar(url):
    pedido = urllib.request.Request(url, headers={"User-Agent": AGENTE})
    with urllib.request.urlopen(pedido, timeout=90) as r:
        return r.read(), dict(r.headers)


def descobrir_pdf():
    html = buscar(PAGINA)[0].decode("utf-8", "replace")
    ligacoes = re.findall(r'href="([^"]*Lista[^"]*CITV[^"]*\.pdf)"', html, re.I)
    if not ligacoes:
        raise SystemExit("nao encontrei o link da Lista CITV na pagina do IMT")
    url = ligacoes[0]
    return url if url.startswith("http") else "https://www.imt-ip.pt" + url


# --- coordenadas -----------------------------------------------------------
# Todas as plicas e aspas do mundo viram a mesma coisa antes de se ler o que la
# esta. O PDF do IMT mistura varios simbolos de minuto e segundo na mesma pagina.
# Aspas e plicas "bonitas" viram as normais antes de se ler o que la esta.
_MINUTO = ['´', '`', '’', '‘', '′', "'"]
_SEGUNDO = ['”', '“', '″', '"']
_PLICAS = {}
for _c in _MINUTO:
    _PLICAS[ord(_c)] = "'"
for _c in _SEGUNDO:
    _PLICAS[ord(_c)] = '"'

# Um par de coordenadas pode vir de sete maneiras neste PDF. Vistas todas:
#   38 graus 36' 18.27" N   8 graus 54' 44.51" W   -> letra DEPOIS
#   N 38 graus 37' 57,26"   W 9 graus 8' 27,75"    -> letra ANTES
#   N37...46.60...  O8...51.62...                  -> sem espacos, e "O" de Oeste
#   N39 graus 45`42,56``                           -> crase a fazer de plica
#   40 graus 57' 4,17'' N; 9 graus 9' 28'' W       -> ponto e virgula pelo meio
#   41.1234 -8.5678                                -> decimal
# Por isso nao se parte a linha em duas: procuram-se TODAS as coordenadas que
# la estao e decide-se qual e a latitude pela letra (N/S) — e so pela ordem
# quando nao ha letra nenhuma.
_COORD = re.compile(
    # A letra so conta se estiver sozinha. Sem esta guarda, o "O" final de
    # "PORTO 41 graus 10' ..." era lido como Oeste e o centro do Porto ia
    # parar a latitude -41: mar aberto a sul de Africa.
    r"(?:(?<![A-Za-zÀ-ÿ])(?P<antes>[NSEWO])\s*)?"
    r"(?P<g>-?\d{1,3})\s*[º°]\s*"
    r"(?P<m>\d{1,2})\s*'\s*"
    r"(?P<s>[\d.,]+)?\s*(?:''|\")?\s*"
    r"(?P<depois>[NSEWO])?",
    re.I,
)
_DECIMAL = re.compile(r"(?<![\d.,])(-?\d{1,3}[.,]\d{3,})")


def _valor(g, m, seg, letra):
    v = abs(float(g)) + float(m) / 60 + float((seg or "0").replace(",", ".")) / 3600
    if str(g).startswith("-") or (letra or "").upper() in ("S", "W", "O"):
        v = -v
    return v


def coordenadas(texto):
    """Devolve (lat, lng) ou (None, None) quando nao ha, ou quando o que la esta
    cai fora de Portugal continental.

    Nao se "arranja" o que esta errado na fonte. Ha centros no PDF do IMT com a
    latitude a 29 e a 27 graus — sao erros de quem escreveu o Excel, e ficam a
    NULL. Inventar-lhes um valor era pior: a app mandava a pessoa a um sitio
    que nao existe.
    """
    t = texto.translate(_PLICAS)
    achados = []
    for m in _COORD.finditer(t):
        letra = (m.group("antes") or m.group("depois") or "").upper()
        achados.append((_valor(m.group("g"), m.group("m"), m.group("s"), letra), letra))
    if len(achados) < 2:
        achados = [(float(x.replace(",", ".")), "") for x in _DECIMAL.findall(t)]
    if len(achados) < 2:
        return None, None

    latitudes = [v for v, letra in achados if letra in ("N", "S")]
    longitudes = [v for v, letra in achados if letra in ("E", "W", "O")]
    if latitudes and longitudes:
        lat, lng = latitudes[0], longitudes[0]
    else:
        lat, lng = achados[0][0], achados[1][0]

    # Em Portugal continental a longitude e SEMPRE negativa. O PDF perde o sinal
    # em muitas linhas — forca-se, senao o centro vai parar a outro continente.
    if lng > 0:
        lng = -lng
    if not (CAIXA_LAT[0] <= lat <= CAIXA_LAT[1] and CAIXA_LON[0] <= lng <= CAIXA_LON[1]):
        return None, None
    return round(lat, 6), round(lng, 6)


# --- extracao --------------------------------------------------------------
LINHA = re.compile(
    r"^(?P<distrito>" + "|".join(DISTRITOS) + r")\s+"
    r"(?P<citv>\d{3,4})\s+"
    r"(?P<resto>.+)$"
)
POSTAL = re.compile(r"(\d{4}-\d{3})")

# Cabecalho e rodape do PDF, que se repetem em todas as paginas e se colam
# ao fim da ultima linha de dados quando o pypdf extrai o texto.
RUIDO = re.compile(
    r"\(?\s*Lista CITV atualizada\.xlsx\s*/\s*[\d/]+\s*\d+\s*/\s*\d+\s*\)?"
    r"|Distrito\s+C[o\u00f3]digo CITV.*$"
    r"|Coordenadas GPS.*$"
    r"|^e Segundos\).*$"
    r"|CENTRO DE INSPE[C\u00c7][A\u00c3]O.*$",
    re.I,
)


def ler_pdf(dados):
    from pypdf import PdfReader

    texto = []
    for pagina in PdfReader(io.BytesIO(dados)).pages:
        texto.extend((pagina.extract_text() or "").splitlines())

    # O cabecalho e o rodape repetem-se em cada pagina e colam-se ao FIM da
    # ultima linha de dados de cada pagina — foi assim que catorze centros
    # ficaram sem coordenadas na primeira tentativa. Tiram-se antes de tudo.
    texto = [RUIDO.sub(" ", l) for l in texto]

    # O PDF parte moradas compridas em duas linhas: junta-se a continuacao a
    # linha de cima sempre que ela nao comeca por um distrito.
    juntas = []
    for bruta in texto:
        linha = " ".join(bruta.split())
        if not linha:
            continue
        if LINHA.match(linha) or not juntas:
            juntas.append(linha)
        else:
            juntas[-1] += " " + linha

    centros = []
    for linha in juntas:
        m = LINHA.match(linha)
        if not m:
            continue
        resto = m.group("resto")
        p = POSTAL.search(resto)
        if p:
            nome_morada = resto[: p.start()].strip()
            depois = resto[p.end():].strip()
            postal = p.group(1)
        else:
            # Uma linha por pagina fica partida pela mudanca de folha e perde o
            # codigo postal. Nao se deita fora um centro por causa disso: se as
            # coordenadas la estao, ele entra sem morada e com o postal a NULL.
            corte = _COORD.search(resto)
            if not corte:
                continue
            nome_morada = resto[: corte.start()].strip()
            depois = resto[corte.start():].strip()
            postal = None
        lat, lng = coordenadas(depois)
        # A localidade e o que vem entre o codigo postal e as coordenadas.
        localidade = re.split(r"-?\d{1,3}\s*[º°]|-?\d{1,2}[.,]\d{4}", depois)[0].strip(" ,;")
        # Duas limpezas, por esta ordem:
        #   1. nenhuma localidade portuguesa tem algarismos — quando aparecem,
        #      e uma coordenada em formato esquisito que escapou ao corte
        #      ("OUREM N 39,41,002 / W 8,33,752"); corta-se no primeiro;
        #   2. so DEPOIS se tira a letra do hemisferio que fica pendurada.
        #      Ao contrario nao funciona: a letra ainda tem numeros a seguir.
        localidade = re.split(r"\d", localidade)[0].strip(" ,;/-")
        localidade = re.sub(r"[\s,;]+[NSEWO]$", "", localidade, flags=re.I).strip(" ,;/-")

        centros.append({
            "codigo_citv": m.group("citv"),
            "distrito": m.group("distrito"),
            "nome_morada": nome_morada,
            "codigo_postal": postal,
            "localidade": localidade or None,
            "lat": lat,
            "lng": lng,
        })
    return centros


# Onde e que uma morada portuguesa comeca. Duas armadilhas ja pagas:
#   - uma fronteira de palavra no FIM nao serve: "AV." acaba num ponto, e
#     entre "." e " " nao ha fronteira nenhuma. Com ela, "AV." nunca casava e
#     o nome do centro de Trancoso ficava com um "AV." pendurado. Troca-se por
#     "nao venha ja uma letra a seguir".
#   - palavras como Bairro, Vale, Casal ou Quinta aparecem em nomes de terras
#     ("OLIVEIRA DO BAIRRO") e cortavam o nome ao meio. Ficaram de fora.
INICIO_MORADA = re.compile(
    r"\b(Rua|R\.|Avenida|Av\.|Estrada|Estr\.|Travessa|Tv\.|Largo|Praceta|Praça|"
    r"Zona Industrial|Zona Ind\.|Parque Industrial|Lugar|Sitio|Sítio|Alameda|"
    r"EN\s?\d|E\.?N\.?\s?\d|IC\s?\d|Loteamento|Edificio|Edifício)"
    r"(?![A-Za-zÀ-ÿ])",
    re.I,
)


def separar_nome_e_morada(centros):
    """O PDF junta nome e morada na mesma celula. Corta-se onde a morada comeca.

    Nao ha separador nenhum, por isso usam-se as palavras com que uma morada
    portuguesa comeca (Rua, Av., Zona Industrial, EN 10, Lugar de...). O que
    nao casar fica com a celula inteira no nome — e honesto, e le-se na mesma.
    """
    for c in centros:
        texto = c.pop("nome_morada")
        m = INICIO_MORADA.search(texto)
        if m and m.start() > 3:
            c["nome"] = texto[: m.start()].strip(" ,-–")
            c["morada"] = texto[m.start():].strip(" ,-–")
        else:
            c["nome"] = texto.strip(" ,-–")
            c["morada"] = None
        if not c["nome"]:
            # Uma linha por PDF fica sem nome, partida pela mudanca de folha.
            # Fica com o codigo oficial em vez de um espaco em branco: e o que
            # o IMT usa, e a pessoa consegue procura-lo.
            c["nome"] = "CITV " + c["codigo_citv"]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--sql", action="store_true", help="escreve tambem o INSERT")
    args = ap.parse_args()

    url = descobrir_pdf()
    print("PDF:", url)
    dados, cabecalhos = buscar(url)
    sha = hashlib.sha256(dados).hexdigest()
    print("%d bytes | sha256 %s | Last-Modified %s"
          % (len(dados), sha[:16], cabecalhos.get("Last-Modified")))

    centros = ler_pdf(dados)
    separar_nome_e_morada(centros)

    # sem duplicados: o codigo CITV e a chave natural
    por_codigo = {}
    for c in centros:
        por_codigo[c["codigo_citv"]] = c
    centros = sorted(por_codigo.values(), key=lambda c: (c["distrito"], c["codigo_citv"]))

    com_coord = sum(1 for c in centros if c["lat"] is not None)
    print("%d centros | %d com coordenadas | %d sem" % (len(centros), com_coord, len(centros) - com_coord))
    contagem = {}
    for c in centros:
        contagem[c["distrito"]] = contagem.get(c["distrito"], 0) + 1
    print("por distrito:", ", ".join("%s %d" % (d, n) for d, n in sorted(contagem.items(), key=lambda x: -x[1])))

    if len(centros) < MINIMO:
        print("\nRECUSO ESCREVER: so %d centros, esperava pelo menos %d." % (len(centros), MINIMO))
        print("O PDF do IMT provavelmente mudou de formato. Ve o parser antes de confiar nisto.")
        return 1

    os.makedirs(os.path.dirname(SAIDA), exist_ok=True)
    pacote = {
        "fonte_url": url,
        "fonte_sha256": sha,
        "fonte_last_modified": cabecalhos.get("Last-Modified"),
        "total": len(centros),
        "com_coordenadas": com_coord,
        "centros": centros,
    }
    with io.open(SAIDA, "w", encoding="utf-8", newline="\n") as f:
        json.dump(pacote, f, ensure_ascii=False, indent=1)
    print("escrito:", SAIDA)

    if args.sql:
        caminho = SAIDA.replace(".json", ".sql")

        def txt(v):
            return "null" if v is None else "'" + str(v).replace("'", "''") + "'"

        def num(v):
            return "null" if v is None else str(v)

        valores = []
        for c in centros:
            valores.append(
                "(%s,%s,%s,%s,%s,%s,%s,%s)"
                % (txt(c["codigo_citv"]), txt(c["nome"]), txt(c["morada"]),
                   txt(c["codigo_postal"]), txt(c["localidade"]), txt(c["distrito"]),
                   num(c["lat"]), num(c["lng"]))
            )
        linhas = [
            "-- gerado por tool/dados/centros_inspecao.py — nao editar a mao",
            "-- a fonte e a data sao iguais para todas as linhas: poem-se de uma vez no fim,",
            "-- em vez de repetir 60 caracteres de URL 223 vezes.",
            "insert into public.centros_inspecao "
            "(codigo_citv, nome, morada, codigo_postal, localidade, distrito, lat, lng) values",
            ",\n".join(valores),
            "on conflict (codigo_citv) do update set nome = excluded.nome, morada = excluded.morada,",
            "  codigo_postal = excluded.codigo_postal, localidade = excluded.localidade,",
            "  distrito = excluded.distrito, lat = excluded.lat, lng = excluded.lng,",
            "  atualizado_em = now();",
            "update public.centros_inspecao set fonte_url = %s, fonte_data = current_date;" % txt(url),
        ]
        with io.open(caminho, "w", encoding="utf-8", newline="\n") as f:
            f.write("\n".join(linhas) + "\n")
        print("escrito:", caminho)
    return 0


if __name__ == "__main__":
    sys.exit(main())
