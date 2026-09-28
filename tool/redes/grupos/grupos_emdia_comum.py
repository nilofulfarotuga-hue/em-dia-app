#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""grupos_emdia_comum.py -- pecas partilhadas da maquina de plano dos grupos do Em Dia.

Escrito 2026-09-28, missao emdia-redes-2026-09-28 (bloco E2).

ESTA MAQUINA NAO ADERE, NAO PUBLICA, NAO COMENTA, NAO CLICA EM NADA NO FACEBOOK.
Os Termos da Meta proibem automatizar a interacao com grupos, e a conta pessoal
usada e' a mesma que sustenta os grupos do Bora. A maquina escolhe e escreve;
uma pessoa carrega em Aderir/Publicar e depois regista com grupos_emdia_registar.py.

So stdlib: corre com /usr/bin/python3 no host da VPS.
"""
import csv
import json
import os
import re
import subprocess
import tempfile
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

LISBOA = ZoneInfo("Europe/Lisbon")
PASTA = os.environ.get("EMDIA_GRUPOS_DIR", os.path.dirname(os.path.abspath(__file__)))
CSV = os.path.join(PASTA, "grupos.csv")
ESTADO = os.path.join(PASTA, "grupos_emdia_estado.json")
REGISTO = os.path.join(PASTA, "registo.jsonl")
PLANOS = os.path.join(PASTA, "planos")
LOG = os.path.join(PASTA, "log.md")
PLAYBOOK = os.environ.get("EMDIA_PLAYBOOK", "/opt/data/emdia-redes/playbook-emdia.json")
GRITAR = "/opt/data/scripts/gritar.sh"
LINK_APP = "https://emdia.boraguarda.com/?de=grupo-%s"

DISTRITOS = [
    "aveiro", "beja", "braga", "braganca", "castelo branco", "coimbra", "evora", "faro",
    "algarve", "guarda", "leiria", "lisboa", "portalegre", "porto", "santarem", "setubal",
    "viana do castelo", "vila real", "viseu", "madeira", "funchal", "acores", "azores",
    "cascais", "sintra", "almada", "amadora", "oeiras", "loures", "odivelas", "matosinhos",
    "gaia", "maia", "gondomar", "guimaraes", "barcelos", "covilha", "fundao", "seixal",
]
MAPA_DISTRITO = {"algarve": "faro", "funchal": "madeira", "azores": "acores",
                 "cascais": "lisboa", "sintra": "lisboa", "amadora": "lisboa", "oeiras": "lisboa",
                 "loures": "lisboa", "odivelas": "lisboa", "almada": "setubal", "seixal": "setubal",
                 "matosinhos": "porto", "gaia": "porto", "maia": "porto", "gondomar": "porto",
                 "guimaraes": "braga", "barcelos": "braga", "covilha": "castelo branco",
                 "fundao": "castelo branco"}


def agora():
    return datetime.now(LISBOA)


def iso(dt=None):
    return (dt or agora()).isoformat(timespec="seconds")


def ler_dt(txt):
    if not txt:
        return None
    try:
        d = datetime.fromisoformat(txt)
    except ValueError:
        return None
    if d.tzinfo is None:
        d = d.replace(tzinfo=LISBOA)
    return d


def sem_acentos(t):
    t = t.lower()
    for a, b in (("áàâã", "a"), ("éê", "e"), ("í", "i"), ("óôõ", "o"), ("ú", "u"), ("ç", "c")):
        for c in a:
            t = t.replace(c, b)
    return t


def chave(link):
    """groups/<id-ou-nome> -- a mesma chave para o link do CSV e o que a pessoa colar."""
    m = re.search(r"facebook\.com/groups/([^/?#\s]+)", link or "", re.I)
    if m:
        return "groups/" + m.group(1).lower()
    return (link or "").strip().lower().rstrip("/")


def slug(nome, k):
    s = re.sub(r"[^a-z0-9]+", "-", sem_acentos(nome or "")).strip("-")[:30].strip("-")
    return s or k.split("/")[-1][:30]


def distrito(nome):
    n = " " + re.sub(r"[^a-z ]+", " ", sem_acentos(nome or "")) + " "
    for d in DISTRITOS:
        if " %s " % d in n:
            return MAPA_DISTRITO.get(d, d)
    return "nacional"


def log(txt):
    linha = "- [%s] %s\n" % (iso(), txt)
    try:
        with open(LOG, "a", encoding="utf-8") as f:
            f.write(linha)
    except OSError:
        pass
    print(linha.rstrip())


def gravar_json(caminho, dados):
    d = os.path.dirname(caminho)
    fd, tmp = tempfile.mkstemp(dir=d, prefix=".tmp-", suffix=".json")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(dados, f, ensure_ascii=False, indent=1)
    os.replace(tmp, caminho)


def registar_linha(accao, **campos):
    campos.update({"em": iso(), "accao": accao})
    with open(REGISTO, "a", encoding="utf-8") as f:
        f.write(json.dumps(campos, ensure_ascii=False) + "\n")


def carregar_estado():
    """Estado por grupo, acrescentando os grupos novos do CSV sem mexer no que ja la esta."""
    if os.path.exists(ESTADO):
        with open(ESTADO, encoding="utf-8") as f:
            est = json.load(f)
    else:
        est = {"versao": 1, "criado_em": iso(), "avisos_facebook": [], "dias_limpos": 0,
               "planos": {}, "grupos": {}}
    grupos = est.setdefault("grupos", {})
    if os.path.exists(CSV):
        with open(CSV, encoding="utf-8") as f:
            for r in csv.DictReader(f):
                k = chave(r.get("link"))
                if not k:
                    continue
                g = grupos.setdefault(k, {
                    "pedido_adesao_em": None, "aceite_em": None, "ultima_publicacao_em": None,
                    "publicacoes": [], "regras": {"permite_publicidade": "por_confirmar"},
                    "avisos_facebook": [],
                })
                g.update({
                    "nome": r.get("nome", ""), "link": r.get("link", ""),
                    "segmento": r.get("segmento", ""), "lingua": r.get("lingua", ""),
                    "privacidade": r.get("privacidade", ""),
                    "encaixe": int(r.get("encaixe") or 0), "membros": int(r.get("membros") or 0),
                })
                g.setdefault("distrito", distrito(g["nome"]))
                g.setdefault("slug", slug(g["nome"], k))
    est["dias_limpos"] = dias_limpos(est)
    return est


def avisos_do_dia(est, dia):
    return [a for a in est.get("avisos_facebook", [])
            if (ler_dt(a.get("em")) or agora()).date() == dia]


def dias_limpos(est, hoje=None):
    """Dias seguidos sem aviso do Facebook (desde o ultimo aviso, ou desde que o estado nasceu)."""
    hoje = hoje or agora().date()
    marcos = [ler_dt(a.get("em")) for a in est.get("avisos_facebook", [])]
    marcos = [m.date() for m in marcos if m]
    if marcos:
        return max(0, (hoje - max(marcos)).days - 1 if max(marcos) < hoje else 0)
    nasc = ler_dt(est.get("criado_em"))
    return max(0, (hoje - nasc.date()).days) if nasc else 0


def avisar(texto, ensaio=False):
    """Telegram pelo gritar.sh da VPS. Devolve True so se o Telegram disse ok:true (rc 0)."""
    if ensaio:
        print("\n===== [ENSAIO] mensagem que iria para o Telegram (%d car.) =====\n%s\n" % (len(texto), texto))
        return True
    if not os.path.exists(GRITAR):
        log("SEM gritar.sh -- ficou so no log: " + texto[:200])
        return False
    r = subprocess.run(["bash", GRITAR, "[Em Dia grupos] " + texto], capture_output=True, text=True)
    log("telegram rc=%s %s" % (r.returncode, (r.stdout + r.stderr)[-200:].replace("\n", " ")))
    return r.returncode == 0


def partir(texto, limite=3500):
    """O Telegram corta aos 4096; parte por blocos (linha em branco) sem partir um texto a meio."""
    partes, atual = [], ""
    for bloco in texto.split("\n\n"):
        if atual and len(atual) + len(bloco) + 2 > limite:
            partes.append(atual)
            atual = bloco
        else:
            atual = (atual + "\n\n" + bloco) if atual else bloco
    if atual:
        partes.append(atual)
    return partes
