#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""grupos_emdia_sync.py -- espelha a lista dos grupos do Em Dia no painel admin e le as pausas.

Escrito 2026-09-28, missao emdia-redes-2026-09-28 (E2, controlo no painel). So stdlib.
  - manda o grupos_emdia_estado.json para a tabela grupos_divulgacao (RPC grupos_sincronizar,
    chave REDES_ROBOT_KEY do /opt/data/emdia-redes/.env -- a mesma do robo das redes);
  - recebe de volta o que o Danilo pausou no painel (um grupo, ou tudo) e grava em pausas.json,
    que o plano do dia e a tarefa do fim da tarde leem antes de propor seja o que for.
USO: grupos_emdia_sync.py        (imprime o resultado; sai 1 se falhar)
"""
import json
import os
import sys
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from grupos_emdia_comum import PASTA, ESTADO, carregar_estado, gravar_json, iso, log  # noqa: E402

ENVF = "/opt/data/emdia-redes/.env"
PAUSAS = os.path.join(PASTA, "pausas.json")


def _env():
    e = {}
    for ln in open(ENVF, encoding="utf-8"):
        ln = ln.strip()
        if ln and not ln.startswith("#") and "=" in ln:
            k, v = ln.split("=", 1)
            e[k.strip()] = v.strip().strip('"').strip("'")
    return e


def _estado_de(g):
    if (g.get("regras") or {}).get("permite_publicidade") == "nao" or g.get("saiu"):
        return "proibe"
    if g.get("publicacoes"):
        return "publicado"
    if g.get("aceite_em"):
        return "aceite"
    if g.get("pedido_adesao_em"):
        return "pedido"
    return "candidato"


def linhas(est):
    out = []
    for g in est.get("grupos", {}).values():
        r = g.get("regras") or {}
        pubs = g.get("publicacoes") or []
        ultimo = pubs[-1] if pubs else {}
        out.append({
            "link": g.get("link"), "nome": g.get("nome"), "segmento": g.get("segmento"),
            "distrito": g.get("distrito"), "lingua": g.get("lingua"),
            "membros": g.get("membros"), "encaixe": g.get("encaixe"), "estado": _estado_de(g),
            "permite_publicidade": r.get("permite_publicidade") or "por_confirmar",
            "regras_texto": r.get("texto") or r.get("resumo"),
            "pedido_adesao_em": g.get("pedido_adesao_em"), "aceite_em": g.get("aceite_em"),
            "ultima_publicacao_em": g.get("ultima_publicacao_em"),
            "ultimo_post_url": ultimo.get("url") if isinstance(ultimo, dict) else None,
            "publicacoes": len(pubs),
        })
    return out


def sincronizar(est=None):
    est = est or carregar_estado()
    e = _env()
    url = e["EMDIA_SUPABASE_URL"].rstrip("/") + "/rest/v1/rpc/grupos_sincronizar"
    av = est.get("avisos_facebook") or []
    hoje = sorted(est.get("planos", {}).keys())[-1:] or [None]
    plano = est.get("planos", {}).get(hoje[0] or "", {})
    cfg = {"dias_limpos": est.get("dias_limpos"), "tecto_hoje": plano.get("tecto"), "ultimo_plano": hoje[0],
           "ultimo_aviso": av[-1].get("texto") if av else None, "ultimo_aviso_em": av[-1].get("em") if av else None}
    corpo = json.dumps({"p_chave": e["REDES_ROBOT_KEY"], "p_grupos": linhas(est), "p_config": cfg}).encode()
    req = urllib.request.Request(url, data=corpo, method="POST", headers={
        "apikey": e["EMDIA_SUPABASE_ANON_KEY"], "Authorization": "Bearer " + e["EMDIA_SUPABASE_ANON_KEY"],
        "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=60) as r:
        res = json.loads(r.read().decode())
    if not isinstance(res, dict) or "total" not in res:
        raise RuntimeError("resposta inesperada: %r" % (res,))
    gravar_json(PAUSAS, {"em": iso(), "pausado_tudo": bool(res.get("pausado_tudo")),
                         "pausados": res.get("pausados") or []})
    return res


def ler_pausas():
    try:
        return json.load(open(PAUSAS, encoding="utf-8"))
    except Exception:
        return {"pausado_tudo": False, "pausados": []}


if __name__ == "__main__":
    try:
        r = sincronizar()
    except Exception as ex:
        log("sync painel FALHOU: %s" % ex)
        print("FALHOU: %s" % ex)
        sys.exit(1)
    log("sync painel: %s grupos, %s mudados, pausado_tudo=%s, pausados=%d"
        % (r["total"], r["mudados"], r["pausado_tudo"], len(r.get("pausados") or [])))
    print(json.dumps(r, ensure_ascii=False))
