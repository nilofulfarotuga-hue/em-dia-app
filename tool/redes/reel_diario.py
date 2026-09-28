#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Reel diário do Em Dia, feito sozinho (missão emdia-redes-2026-09-28, bloco E1).

Todos os dias (cron da VPS, de madrugada, um render de cada vez):
  1. escolhe o dia: o primeiro, de amanhã+1 a +30, sem reel no calendário nem publicação
     já agendada na página do Facebook (os 18 reels feitos à mão não se duplicam);
  2. escolhe o tema: o reel provado (conteudo.REELS) que não depende de data e que há
     mais tempo não serve de base;
  3. reescreve os textos pelo motor grátis (Motor Bora, perfil «volume», em rotação de
     fornecedores); um verificador por código recusa números que não estejam no original
     (os números legais nunca se inventam), palavras proibidas e textos compridos demais;
  4. monta o vídeo com o reel.py — ecrãs verdadeiros da app (modo exemplo), música nova,
     câmara em movimento (zoom 0,18 + deriva 0,5: é o que põe o movimento acima de 12);
  5. passa o fiscal de vídeo do Bora; só entra no calendário com nota >= 90;
  6. acrescenta a peça ao calendario.json às 20:30 desse dia — quem publica é o robô que
     já corre (emdia_redes.py hora), pela página «Em Dia: Recibos e Impostos» e pelo
     @em_dia_app, nunca pelas contas do Bora.

Corre DENTRO do contentor hermes (é lá que há Pillow), como root porque os ficheiros
do robô são do root:
  docker exec -u root hermes-agent-fvnc-hermes-agent-1 /opt/data/social/venv/bin/python \\
      /opt/data/emdia-redes/gerador/tool/redes/reel_diario.py [--ensaio] [--data AAAA-MM-DD]

--ensaio: faz tudo menos escrever no calendário (o mp4 fica em pecas/reels/ensaio-*).
"""
import datetime as dt
import json
import os
import random
import re
import subprocess
import sys
import urllib.request
import zoneinfo

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import conteudo  # noqa: E402
import reel  # noqa: E402

BASE = os.environ.get("EMDIA_REDES_DIR", "/opt/data/emdia-redes")
CAL = os.path.join(BASE, "calendario.json")
GERADOS = os.path.join(BASE, "gerados.json")
REELS_DIR = os.path.join(BASE, "pecas", "reels")
LOG = os.path.join(BASE, "log.md")
ENVF = os.path.join(BASE, ".env")
MOTOR = os.environ.get("MOTOR_URL", "http://172.16.1.1:8792/v1/chat/completions")
FISCAL = ["/opt/data/social/venv/bin/python", "/opt/data/social/fiscal_video.py"]
GRITAR = "/opt/data/scripts/gritar.sh"
GRAPH = "https://graph.facebook.com/v21.0"
LISBOA = zoneinfo.ZoneInfo("Europe/Lisbon")
NOTA_MINIMA = 90
HORA = "20:30"
CAMARA, DERIVA = 0.18, 0.5

# Campos de texto que o motor pode reescrever, por tipo de plano.
CAMPOS = {"gancho": ("texto", "sub"), "ecra": ("legenda",), "numero": ("antes", "legenda"), "lista": ("titulo",)}
PROIBIDAS = re.compile(r"m[eê]s gr[aá]tis|per[ií]odo de teste|\bteste gr|\btrial\b|assinatura|\bpro\b|\bplano\b|"
                       r"pre[çc]o|promo|garant|milion|\brico\b|segredo|ningu[eé]m te conta", re.I)
DATADO = re.compile(r"\b\d{1,2}/\d{1,2}\b|janeiro|fevereiro|mar[çc]o|abril|maio|junho|julho|agosto|setembro|"
                    r"outubro|novembro|dezembro|feriado|\bhoje\b|este m[eê]s", re.I)
NUM = re.compile(r"\d+(?:[.,]\d+)*")


def log(msg):
    linha = "- [%s] reel-diario: %s" % (dt.datetime.now(LISBOA).isoformat(timespec="seconds"), msg)
    print(linha, flush=True)
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(linha + "\n")


def avisar(txt):
    try:
        subprocess.run([GRITAR, "Em Dia (reel diario): " + txt], timeout=60)
    except Exception as ex:  # noqa: BLE001
        log("aviso Telegram falhou: %s" % ex)


def env():
    e = {}
    if os.path.exists(ENVF):
        for ln in open(ENVF, encoding="utf-8"):
            ln = ln.strip()
            if ln and not ln.startswith("#") and "=" in ln:
                k, v = ln.split("=", 1)
                e[k.strip()] = v.strip().strip('"').strip("'")
    return e


# ------------------------------------------------------------------ que dia
def dias_ocupados():
    """Datas com reel no calendário + datas com publicação agendada na página (Meta)."""
    cal = json.load(open(CAL, encoding="utf-8"))
    ocup = {p["data"] for p in cal if p.get("tipo_meta") == "Reel"}
    e = env()
    page, tok = e.get("EMDIA_META_PAGE_ID"), e.get("EMDIA_META_TOKEN")
    if page and tok:
        url = "%s/%s/scheduled_posts?fields=scheduled_publish_time&limit=100&access_token=%s" % (GRAPH, page, tok)
        try:
            r = json.load(urllib.request.urlopen(url, timeout=60))
            for d in r.get("data", []):
                t = dt.datetime.fromtimestamp(int(d["scheduled_publish_time"]), LISBOA)
                ocup.add(t.date().isoformat())
        except Exception as ex:  # noqa: BLE001
            # sem a lista da Meta não se arrisca duplicar: usa só o calendário e diz porquê
            log("agendados da Meta indisponiveis (%s): conto so o calendario" % str(ex)[:120])
    return ocup


def escolher_dia(forcado=None):
    if forcado:
        return forcado
    ocup = dias_ocupados()
    hoje = dt.datetime.now(LISBOA).date()
    for k in range(2, 31):
        d = (hoje + dt.timedelta(days=k)).isoformat()
        if d not in ocup:
            return d
    return None


# ------------------------------------------------------------------ que tema
def evergreen(r):
    textos = [r.get("gancho", ""), r.get("corpo", "")]
    for p in r["planos"]:
        if p.get("tipo") == "lista":
            return False
        textos += [str(p.get(c, "")) for c in ("texto", "sub", "legenda", "antes", "numero")]
    return not DATADO.search(" ".join(textos))


def escolher_tema(gerados):
    temas = [r for r in conteudo.REELS if evergreen(r)]
    usos = {}
    for g in gerados:
        usos[g["tema"]] = max(usos.get(g["tema"], ""), g["criado_em"])
    temas.sort(key=lambda r: (usos.get(r["id"], ""), random.random()))
    return temas


# ------------------------------------------------------------------ textos novos
def campos_de(r):
    out = [("gancho", None, r["gancho"]), ("corpo", None, r["corpo"])]
    for i, p in enumerate(r["planos"]):
        for c in CAMPOS.get(p.get("tipo"), ()):
            if p.get(c):
                out.append((c, i, p[c]))
    return out


PLAYBOOK = os.path.join(BASE, "playbook-emdia.json")
# Regras do playbook (bloco E3, 28/09) que mexem no texto do reel e da legenda.
REGRAS_PLAYBOOK = ("R02", "R06", "R08", "R19", "R20", "R34", "R40")


def regras_playbook():
    try:
        d = json.load(open(PLAYBOOK, encoding="utf-8"))
        return [x["texto"] for x in d.get("regras", []) if x.get("id") in REGRAS_PLAYBOOK]
    except Exception:  # noqa: BLE001 — sem playbook o reel sai na mesma, só com as regras da casa
        return []


def pedir_motor(r, br):
    campos = campos_de(r)
    lingua = "português do Brasil, tratando por «você»" if br else "português de Portugal (PT-PT), tratando por «tu»"
    pedido = {
        "regras_do_playbook": regras_playbook(),
        "regras": [
            "Reescreve cada texto com palavras novas, mesmo sentido, para um reel de Instagram.",
            "Escreve em %s. Frases curtas, linguagem simples." % lingua,
            "NÃO acrescentes números, percentagens, valores, datas nem prazos que não estejam no texto original.",
            "Mantém os números do original exatamente como estão.",
            "Mantém um trecho entre **asteriscos duplos** (o destaque) sempre que o original tiver.",
            "Nunca fales de mês grátis, teste, assinatura, planos, preços nem promessas de dinheiro.",
            "Cada texto novo no máximo com o mesmo tamanho do original mais 20%.",
            "Responde SÓ com JSON: uma lista de strings, pela mesma ordem, com o mesmo número de itens.",
        ],
        "textos": [t for _, _, t in campos],
    }
    corpo = {"model": "perfil:volume", "temperature": 0.9, "max_tokens": 1200,
             "messages": [{"role": "system", "content": "És o redator das redes do Em Dia, uma app portuguesa grátis para quem trabalha a recibos verdes."},
                          {"role": "user", "content": json.dumps(pedido, ensure_ascii=False)}]}
    req = urllib.request.Request(MOTOR, data=json.dumps(corpo).encode("utf-8"),
                                 headers={"Content-Type": "application/json", "X-Motor-Origem": "emdia-reel-diario"})
    resp = json.load(urllib.request.urlopen(req, timeout=180))
    txt = resp["choices"][0]["message"]["content"]
    m = re.search(r"\[.*\]", txt, re.S)
    if not m:
        raise ValueError("motor sem lista JSON: " + txt[:160])
    novos = json.loads(m.group(0))
    return campos, [str(x).strip() for x in novos], resp.get("model", "?")


def validar(campos, novos):
    if len(novos) != len(campos):
        return "numero de textos %d != %d" % (len(novos), len(campos))
    for (c, _, orig), novo in zip(campos, novos):
        if not novo:
            return "%s vazio" % c
        if PROIBIDAS.search(novo) and not PROIBIDAS.search(orig):
            return "%s com palavra proibida: %s" % (c, novo[:60])
        if not set(NUM.findall(novo)) <= set(NUM.findall(orig)):
            return "%s inventou numeros %s" % (c, sorted(set(NUM.findall(novo)) - set(NUM.findall(orig))))
        if len(novo) > len(orig) * 1.3 + 12:
            return "%s comprido demais (%d > %d)" % (c, len(novo), len(orig))
        if "**" in orig and novo.count("**") < 2:
            return "%s perdeu o destaque **" % c
        if novo.count("**") % 2:
            return "%s com ** desemparelhado" % c
    return None


def aplicar(r, campos, novos):
    novo = json.loads(json.dumps(r))  # cópia funda (os planos são dicionários simples)
    for (c, i, _), txt in zip(campos, novos):
        if i is None:
            novo[c] = txt
        else:
            novo["planos"][i][c] = txt
    return novo


# ------------------------------------------------------------------ fiscal
def fiscal(mp4):
    r = subprocess.run(FISCAL + ["--peca", mp4, "--so-maquina"], capture_output=True, text=True, timeout=900,
                       cwd="/opt/data/social")
    txt = (r.stdout + r.stderr)[-1500:]
    m = re.search(r"MAQUINA\s+(\d+)/(\d+)", txt)
    if not m:
        return None, "fiscal sem nota: " + txt[-300:].replace("\n", " ")
    return round(int(m.group(1)) * 100 / int(m.group(2))), txt[-300:].replace("\n", " ")


# ------------------------------------------------------------------ principal
def main():
    ensaio = "--ensaio" in sys.argv
    forcado = sys.argv[sys.argv.index("--data") + 1] if "--data" in sys.argv else None
    gerados = json.load(open(GERADOS, encoding="utf-8")) if os.path.exists(GERADOS) else []
    dia = escolher_dia(forcado)
    if not dia:
        log("sem dia livre nos proximos 30 dias; nada a fazer")
        return 0
    pid = ("ENSAIO-" if ensaio else "") + "G" + dia.replace("-", "")
    mp4 = os.path.join(REELS_DIR, pid + ".mp4")
    capa = os.path.join(REELS_DIR, pid + "-capa.jpg")
    motivos = []
    for tema in escolher_tema(gerados)[:4]:
        br = bool(tema.get("br"))
        novo, motor_usado = None, None
        for tentativa in range(3):
            try:
                campos, novos, motor_usado = pedir_motor(tema, br)
            except Exception as ex:  # noqa: BLE001
                motivos.append("%s t%d motor: %s" % (tema["id"], tentativa + 1, str(ex)[:100]))
                continue
            erro = validar(campos, novos)
            if erro:
                motivos.append("%s t%d recusado: %s" % (tema["id"], tentativa + 1, erro))
                continue
            novo = aplicar(tema, campos, novos)
            break
        if not novo:
            continue
        semente = random.randint(1, 10 ** 6)
        dur = reel.monta(novo["planos"], mp4, semente=semente, br=br, capa=capa, camara=CAMARA, deriva=DERIVA)
        nota, det = fiscal(mp4)
        log("%s: tema %s, motor %s, %.1f s, fiscal %s (%s)" % (pid, tema["id"], motor_usado, dur, nota, det[:120]))
        if nota is None or nota < NOTA_MINIMA:
            motivos.append("%s fiscal %s" % (tema["id"], nota))
            continue
        peca = {"id": pid, "data": dia, "hora": HORA, "rede": "Instagram + Facebook", "formato": "Reel 9:16 com som",
                "publico": tema.get("publico", ""), "gancho": novo["gancho"],
                "hashtags": " ".join(tema.get("hashtags", "").split()[:3]),  # playbook R20: no máximo 3
                "texto": conteudo.legenda(novo["corpo"], br=br, fonte=tema.get("fonte")),
                "ficheiros": ["pecas/reels/%s.mp4" % pid], "capa": "pecas/reels/%s-capa.jpg" % pid,
                "tipo_meta": "Reel", "origem": "reel_diario", "tema": tema["id"], "nota_fiscal": nota}
        if ensaio:
            log("ENSAIO: %s pronto para %s (nao entrou no calendario)" % (pid, dia))
            print(json.dumps(peca, ensure_ascii=False, indent=1))
            return 0
        cal = json.load(open(CAL, encoding="utf-8"))
        if any(p["id"] == pid for p in cal):
            log("%s ja estava no calendario; nao duplico" % pid)
            return 0
        cal.append(peca)
        json.dump(cal, open(CAL, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        gerados.append({"id": pid, "tema": tema["id"], "data": dia, "nota": nota, "motor": motor_usado,
                        "criado_em": dt.datetime.now(LISBOA).isoformat(timespec="seconds")})
        json.dump(gerados, open(GERADOS, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        log("%s no calendario para %s %s (nota %s)" % (pid, dia, HORA, nota))
        return 0
    log("nenhum reel passou hoje: " + " | ".join(motivos)[:600])
    avisar("nenhum reel novo passou hoje (%s). O dia %s fica por preencher." % ("; ".join(motivos)[:300], dia))
    return 1


if __name__ == "__main__":
    sys.exit(main())
