#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Robô diário das redes do Em Dia (Instagram @em_dia_app + Facebook «Em Dia: Recibos e Impostos»).

Ordem do Danilo (24/09/2026): uma publicação por dia em cada rede, separado do Bora; cada
vídeo passa primeiro pelo fiscal de vídeo e só sai com nota 90 ou mais (senão não publica e
avisa no Telegram); manter 14 dias de peças prontas e avisar quando baixar de 7; registar
tudo (publicado / agendado / falhou) para o painel admin «Redes Em Dia».

Corre na VPS (host, python3 + curl + jq como os social-*.sh do Bora):
  python3 emdia_redes.py hora        # de hora a hora pelo cron: publica o que o calendário marca para esta hora
  python3 emdia_redes.py hoje        # às 21:00: se hoje ainda não saiu nada de feed, publica a próxima peça pronta
  python3 emdia_redes.py stock       # conta os dias de peças prontas e avisa se < 7
  python3 emdia_redes.py publicar R01 [--hoje]   # uma peça à mão (ex.: a de hoje pedida pelo Danilo)
  python3 emdia_redes.py agendar R02 2026-09-25T20:30   # marca no registo (o robô publica à hora)
  python3 emdia_redes.py fb-agendados               # o que a página do Facebook já tem agendado (Meta)

Ambiente (/opt/data/emdia-redes/.env):
  EMDIA_META_PAGE_ID, EMDIA_IG_USER_ID, EMDIA_META_TOKEN (token da página Em Dia),
  REDES_ROBOT_KEY (chave do Vault do Supabase Em Dia), EMDIA_SUPABASE_URL, EMDIA_SUPABASE_ANON_KEY,
  PUBLICO_URL (https://social.srv1786862.hstgr.cloud), PUBLICO_DIR (/opt/data/social/publico).
Peças e calendário: /opt/data/emdia-redes/pecas/…  e  /opt/data/emdia-redes/calendario.json
(o calendário é o docs/marketing/redes-em-dia/calendario.json gerado por gerar.py).
"""
import datetime as dt
import json
import os
import re
import shutil
import subprocess
import sys
import time
import urllib.parse
import urllib.request
import zoneinfo

BASE = os.environ.get("EMDIA_REDES_DIR", "/opt/data/emdia-redes")
ENVF = os.path.join(BASE, ".env")
CAL = os.path.join(BASE, "calendario.json")
PECAS = os.path.join(BASE, "pecas")
LOG = os.path.join(BASE, "log.md")
FISCAL = "/opt/data/social/fiscal_video.py"
FISCAL_PY = "/opt/data/social/venv/bin/python"
GRITAR = "/opt/data/scripts/gritar.sh"
LISBOA = zoneinfo.ZoneInfo("Europe/Lisbon")
GRAPH = "https://graph.facebook.com/v21.0"
NOTA_MINIMA = 90
STOCK_MINIMO_DIAS = 7
STOCK_ALVO_DIAS = 14


def env():
    e = {}
    if os.path.exists(ENVF):
        for ln in open(ENVF, encoding="utf-8"):
            ln = ln.strip()
            if ln and not ln.startswith("#") and "=" in ln:
                k, v = ln.split("=", 1)
                e[k.strip()] = v.strip().strip('"').strip("'")
    for k, v in os.environ.items():
        e.setdefault(k, v)
    return e


E = env()


def agora():
    return dt.datetime.now(LISBOA)


def log(msg):
    linha = "- [%s] emdia-redes: %s\n" % (agora().strftime("%Y-%m-%dT%H:%M:%S%z"), msg)
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(linha)
    print(linha.strip())


def avisar(texto):
    """Telegram do Danilo pelo gritar.sh da VPS (lê a prova 'ok':true); se não houver, só log."""
    if os.path.exists(GRITAR):
        r = subprocess.run(["bash", GRITAR, "[Em Dia redes] " + texto], capture_output=True, text=True)
        log("aviso telegram rc=%s %s" % (r.returncode, (r.stdout + r.stderr)[-160:].replace("\n", " ")))
    else:
        log("AVISO (sem gritar.sh): " + texto)


# ------------------------------------------------------------------ HTTP
def http(url, dados=None, headers=None, metodo=None, timeout=120):
    h = {"User-Agent": "emdia-redes/1.0"}
    h.update(headers or {})
    body = None
    if dados is not None:
        if isinstance(dados, (dict, list)):
            body = json.dumps(dados, ensure_ascii=False).encode("utf-8")
            h.setdefault("Content-Type", "application/json")
        else:
            body = dados
    req = urllib.request.Request(url, data=body, headers=h, method=metodo or ("POST" if body is not None else "GET"))
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            raw = r.read().decode("utf-8", "replace")
            return r.status, (json.loads(raw) if raw.strip().startswith(("{", "[")) else raw)
    except urllib.error.HTTPError as ex:
        raw = ex.read().decode("utf-8", "replace")
        try:
            return ex.code, json.loads(raw)
        except Exception:
            return ex.code, raw
    except Exception as ex:  # noqa: BLE001
        return 0, {"erro": "%s: %s" % (type(ex).__name__, str(ex)[:200])}


def graph(caminho, params=None, metodo="GET", token=None):
    tok = token or E.get("EMDIA_META_TOKEN", "")
    p = dict(params or {})
    p["access_token"] = tok
    q = urllib.parse.urlencode(p)
    if metodo == "GET":
        return http("%s/%s?%s" % (GRAPH, caminho, q))
    return http("%s/%s" % (GRAPH, caminho), dados=q.encode("utf-8"),
                headers={"Content-Type": "application/x-www-form-urlencoded"}, metodo="POST")


# ------------------------------------------------------------------ registo (Supabase Em Dia)
def registar(linha):
    """Grava/atualiza uma linha em redes_publicacoes pela RPC redes_registar (chave no Vault)."""
    url = E.get("EMDIA_SUPABASE_URL", "").rstrip("/") + "/rest/v1/rpc/redes_registar"
    st, r = http(url, {"p_chave": E.get("REDES_ROBOT_KEY", ""), "p_linha": linha},
                 headers={"apikey": E.get("EMDIA_SUPABASE_ANON_KEY", ""),
                          "Authorization": "Bearer " + E.get("EMDIA_SUPABASE_ANON_KEY", "")})
    if st != 200:
        log("registo FALHOU http=%s %s" % (st, str(r)[:200]))
        return None
    return r


def registadas():
    """Lê o registo (só o que o admin vê é pela RPC admin_redes; o robô usa a sua cópia local)."""
    p = os.path.join(BASE, "registo.json")
    if os.path.exists(p):
        return json.load(open(p, encoding="utf-8"))
    return {}


def guardar_registo(reg):
    json.dump(reg, open(os.path.join(BASE, "registo.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)


def marcar(reg, peca, rede, dados):
    chave = "%s|%s" % (peca, rede)
    linha = reg.get(chave, {})
    linha.update(dados)
    linha["peca"] = peca
    linha["rede"] = rede
    reg[chave] = linha
    guardar_registo(reg)
    registar(linha)


# ------------------------------------------------------------------ calendário e peças
def calendario():
    pubs = json.load(open(CAL, encoding="utf-8"))
    return [p for p in pubs if p["tipo_meta"] in ("Reel", "Carrossel")]  # stories só à mão (autocolantes)


def formato_de(p):
    return {"Reel": "reel", "Carrossel": "carrossel", "Story": "story"}.get(p["tipo_meta"], "imagem")


def quando(p):
    d = dt.date.fromisoformat(p["data"])
    h, m = [int(x) for x in p["hora"].split(":")]
    return dt.datetime(d.year, d.month, d.day, h, m, tzinfo=LISBOA)


def ficheiros(p):
    return [os.path.join(BASE, f) for f in p["ficheiros"]]


def legenda(p):
    return (p["texto"].rstrip() + "\n\n" + p.get("hashtags", "")).strip()


def publicadas_hoje(reg, rede):
    hoje = agora().date().isoformat()
    return [v for v in reg.values() if v.get("rede") == rede and v.get("estado") == "publicada"
            and str(v.get("publicada_em", "")).startswith(hoje)]


def chumbou_fiscal(reg, pid):
    """True se o fiscal já deu nota abaixo do mínimo a esta peça (não se volta a tentar)."""
    for r in ("instagram", "facebook"):
        n = reg.get("%s|%s" % (pid, r), {}).get("nota_fiscal")
        if n is not None and n < NOTA_MINIMA:
            return True
    return False


def por_publicar(reg):
    """Peças do calendário ainda sem publicação em nenhuma rede e não chumbadas no fiscal, por ordem."""
    out = []
    for p in calendario():
        if any(reg.get("%s|%s" % (p["id"], r), {}).get("estado") == "publicada" for r in ("instagram", "facebook")):
            continue
        if chumbou_fiscal(reg, p["id"]):
            continue
        if all(os.path.exists(f) for f in ficheiros(p)):
            out.append(p)
    return out


# ------------------------------------------------------------------ fiscal
def fiscal(mp4):
    """Nota 0-100 a partir do fiscal de vídeo do Bora (--so-maquina: n/45)."""
    if not (os.path.exists(FISCAL) and os.path.exists(FISCAL_PY)):
        return None, "fiscal indisponivel"
    r = subprocess.run(["docker", "exec", "-u", "hermes", "hermes-agent-fvnc-hermes-agent-1", "bash", "-lc",
                        "cd /opt/data/social && ./venv/bin/python fiscal_video.py --peca %s --so-maquina" % mp4],
                       capture_output=True, text=True, timeout=600)
    txt = (r.stdout + r.stderr)[-1200:]
    m = re.search(r"MAQUINA\s+(\d+)/(\d+)", txt)
    if not m:
        return None, "fiscal sem nota: " + txt[-300:].replace("\n", " ")
    nota = round(int(m.group(1)) * 100 / int(m.group(2)))
    return nota, txt[-300:].replace("\n", " ")


# ------------------------------------------------------------------ publicar
def servir(caminho):
    """Copia para a pasta pública do nginx e devolve o URL (verificado com 200)."""
    pub = E.get("PUBLICO_DIR", "/opt/data/social/publico")
    os.makedirs(pub, exist_ok=True)
    nome = "emdia-" + os.path.basename(caminho)
    shutil.copyfile(caminho, os.path.join(pub, nome))
    url = E.get("PUBLICO_URL", "https://social.srv1786862.hstgr.cloud").rstrip("/") + "/" + nome
    st, _ = http(url, metodo="HEAD", timeout=40)
    if st != 200:
        raise RuntimeError("URL publico %s devolve %s" % (url, st))
    return url


def ig_publicar(p, agendar_ts=None):
    ig = E.get("EMDIA_IG_USER_ID", "")
    if not ig:
        raise RuntimeError("EMDIA_IG_USER_ID em falta")
    leg = legenda(p)
    if p["tipo_meta"] == "Reel":
        url = servir(ficheiros(p)[0])
        st, r = graph("%s/media" % ig, {"media_type": "REELS", "video_url": url, "caption": leg,
                                        "share_to_feed": "true"}, "POST")
    else:
        filhos = []
        for f in ficheiros(p):
            u = servir(f)
            st, r = graph("%s/media" % ig, {"image_url": u, "is_carousel_item": "true"}, "POST")
            if st != 200 or "id" not in r:
                raise RuntimeError("IG lamina falhou: %s" % str(r)[:200])
            filhos.append(r["id"])
        st, r = graph("%s/media" % ig, {"media_type": "CAROUSEL", "children": ",".join(filhos), "caption": leg}, "POST")
    if st != 200 or "id" not in r:
        raise RuntimeError("IG contentor falhou: %s" % str(r)[:200])
    cid = r["id"]
    for _ in range(40):
        st, s = graph(cid, {"fields": "status_code"})
        code = s.get("status_code") if isinstance(s, dict) else None
        if code == "FINISHED":
            break
        if code == "ERROR":
            raise RuntimeError("IG contentor em ERROR")
        time.sleep(10)
    st, r = graph("%s/media_publish" % ig, {"creation_id": cid}, "POST")
    if st != 200 or "id" not in r:
        raise RuntimeError("IG publicar falhou: %s" % str(r)[:200])
    mid = r["id"]
    st, pl = graph(mid, {"fields": "permalink"})
    return mid, (pl.get("permalink") if isinstance(pl, dict) else "")


def fb_publicar(p, agendar_ts=None):
    page = E.get("EMDIA_META_PAGE_ID", "")
    if not page:
        raise RuntimeError("EMDIA_META_PAGE_ID em falta")
    leg = legenda(p)
    extra = {}
    if agendar_ts:
        extra = {"published": "false", "scheduled_publish_time": str(int(agendar_ts.timestamp()))}
    if p["tipo_meta"] == "Reel":
        url = servir(ficheiros(p)[0])
        st, r = graph("%s/videos" % page, dict({"file_url": url, "description": leg, "title": p["gancho"][:90]}, **extra), "POST")
        if st != 200 or "id" not in r:
            raise RuntimeError("FB video falhou: %s" % str(r)[:200])
        return r["id"], "https://www.facebook.com/%s" % r["id"]
    fotos = []
    for f in ficheiros(p):
        u = servir(f)
        st, r = graph("%s/photos" % page, {"url": u, "published": "false"}, "POST")
        if st != 200 or "id" not in r:
            raise RuntimeError("FB foto falhou: %s" % str(r)[:200])
        fotos.append(r["id"])
    params = {"message": leg}
    for i, fid in enumerate(fotos):
        params["attached_media[%d]" % i] = json.dumps({"media_fbid": fid})
    params.update(extra)
    st, r = graph("%s/feed" % page, params, "POST")
    if st != 200 or "id" not in r:
        raise RuntimeError("FB feed falhou: %s" % str(r)[:200])
    return r["id"], "https://www.facebook.com/%s" % r["id"]


def publicar_peca(p, reg, redes=("instagram", "facebook"), agendar_ts=None):
    """Fiscal (vídeo) → publica em cada rede → regista. Nunca levanta: regista 'falhou' e avisa."""
    nota, det = (None, None)
    if p["tipo_meta"] == "Reel":
        nota, det = fiscal(ficheiros(p)[0])
        if nota is None or nota < NOTA_MINIMA:
            for rede in redes:
                marcar(reg, p["id"], rede, {"formato": formato_de(p), "estado": "falhou", "nota_fiscal": nota,
                                            "fiscal_detalhe": det, "legenda": legenda(p),
                                            "agendada_para": (agendar_ts or agora()).isoformat(),
                                            "erro": "fiscal abaixo de %d" % NOTA_MINIMA if nota is not None else det})
            avisar("%s NAO publicada: fiscal deu %s (minimo %d). %s" % (p["id"], nota, NOTA_MINIMA, (det or "")[:120]))
            return False
    ok_todas = True
    for rede in redes:
        try:
            mid, link = (ig_publicar if rede == "instagram" else fb_publicar)(p, agendar_ts)
            marcar(reg, p["id"], rede, {"formato": formato_de(p), "estado": "agendada" if agendar_ts and rede == "facebook" else "publicada",
                                        "nota_fiscal": nota, "fiscal_detalhe": det, "legenda": legenda(p),
                                        "agendada_para": (agendar_ts or agora()).isoformat(),
                                        "publicada_em": None if (agendar_ts and rede == "facebook") else agora().isoformat(),
                                        "id_externo": mid, "link": link, "erro": None})
            log("%s %s OK id=%s %s" % (p["id"], rede, mid, link))
        except Exception as ex:  # noqa: BLE001
            ok_todas = False
            marcar(reg, p["id"], rede, {"formato": formato_de(p), "estado": "falhou", "nota_fiscal": nota,
                                        "fiscal_detalhe": det, "legenda": legenda(p),
                                        "agendada_para": (agendar_ts or agora()).isoformat(), "erro": str(ex)[:300]})
            log("%s %s FALHOU: %s" % (p["id"], rede, str(ex)[:200]))
            avisar("%s falhou no %s: %s" % (p["id"], rede, str(ex)[:160]))
    return ok_todas


# ------------------------------------------------------------------ modos
def peca_por_id(pid):
    for p in calendario():
        if p["id"] == pid:
            return p
    raise SystemExit("peca desconhecida: " + pid)


def modo_hora():
    """Publica o que o registo tem 'agendada' para esta hora (agendado por nós) ou o calendário marca agora."""
    reg = registadas()
    ag = agora()
    feitas = 0
    # 1) agendamentos nossos (Instagram não agenda pela API: somos nós que publicamos à hora)
    for chave, v in list(reg.items()):
        if v.get("estado") != "agendada" or v.get("origem") == "agendado_meta":
            continue
        t = dt.datetime.fromisoformat(v["agendada_para"])
        if t <= ag < t + dt.timedelta(minutes=59):
            p = peca_por_id(v["peca"])
            publicar_peca(p, reg, redes=(v["rede"],))
            feitas += 1
    # 2) calendário: peças marcadas para esta hora que ainda não saíram
    for p in calendario():
        t = quando(p)
        if t <= ag < t + dt.timedelta(minutes=59):
            if any(reg.get("%s|%s" % (p["id"], r), {}).get("estado") in ("publicada", "falhou") for r in ("instagram", "facebook")):
                continue
            publicar_peca(p, reg)
            feitas += 1
    log("hora: %d peca(s) tratadas" % feitas)


def modo_hoje():
    """Ao fim do dia: se ainda não saiu nada de feed hoje, publica a próxima peça pronta (1/dia)."""
    reg = registadas()
    if publicadas_hoje(reg, "instagram") or publicadas_hoje(reg, "facebook"):
        log("hoje: ja saiu uma peca; nada a fazer")
        return
    fila = por_publicar(reg)
    if not fila:
        avisar("sem pecas prontas para publicar hoje (fila vazia)")
        return
    # vídeo chumbado no fiscal → passa à peça seguinte; falha da Meta/rede → pára (não publica outra)
    for p in fila:
        if publicar_peca(p, reg):
            return
        if not chumbou_fiscal(reg, p["id"]):
            return
    avisar("nenhuma peca passou hoje (todas chumbadas no fiscal)")


def modo_stock():
    reg = registadas()
    dias = len(por_publicar(reg))  # 1 peça de feed = 1 dia
    log("stock: %d dias de pecas prontas" % dias)
    if dias < STOCK_MINIMO_DIAS:
        avisar("so ha %d dias de pecas prontas (alvo %d). E preciso gerar mais (tool/redes/gerar.py)." % (dias, STOCK_ALVO_DIAS))
    return dias


def modo_publicar(pid):
    reg = registadas()
    return publicar_peca(peca_por_id(pid), reg)


def modo_agendar(pid, quando_iso, redes=("instagram", "facebook")):
    reg = registadas()
    p = peca_por_id(pid)
    t = dt.datetime.fromisoformat(quando_iso).replace(tzinfo=LISBOA)
    for rede in redes:
        marcar(reg, pid, rede, {"formato": formato_de(p), "estado": "agendada", "agendada_para": t.isoformat(),
                                "legenda": legenda(p), "origem": "robo"})
    log("agendada %s para %s (%s)" % (pid, t.isoformat(), ",".join(redes)))


def modo_fb_agendados():
    page = E.get("EMDIA_META_PAGE_ID", "")
    st, r = graph("%s/scheduled_posts" % page, {"fields": "id,message,scheduled_publish_time,created_time", "limit": "50"})
    print(json.dumps(r, ensure_ascii=False, indent=1)[:4000])
    return r


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    m = sys.argv[1]
    if m == "hora":
        modo_hora()
    elif m == "hoje":
        modo_hoje()
    elif m == "stock":
        modo_stock()
    elif m == "publicar":
        redes = ("instagram", "facebook")
        if "--so-ig" in sys.argv:
            redes = ("instagram",)
        if "--so-fb" in sys.argv:
            redes = ("facebook",)
        ok = publicar_peca(peca_por_id(sys.argv[2]), registadas(), redes=redes)
        raise SystemExit(0 if ok else 1)
    elif m == "agendar":
        redes = ("instagram", "facebook")
        if "--so-ig" in sys.argv:
            redes = ("instagram",)
        modo_agendar(sys.argv[2], sys.argv[3], redes)
    elif m == "fb-agendados":
        modo_fb_agendados()
    else:
        raise SystemExit(__doc__)


if __name__ == "__main__":
    main()
