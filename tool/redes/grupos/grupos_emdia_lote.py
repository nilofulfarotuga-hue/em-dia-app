#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""grupos_emdia_lote.py -- o lote do dia para o pedido de SIM das 18:30 (modo b, ordem do Danilo 28/09/2026).

Le o plano de hoje (grupos_emdia_estado.json) + pausas do painel (sincroniza antes) + avisos do dia, e
imprime em JSON so o que ainda falta fazer hoje:
  adesao:   grupos do plano ainda sem pedido e nao pausados
  publicar: grupos do plano ainda sem publicacao hoje e nao pausados, com texto e 1.o comentario
  parar:    true se houver aviso do Facebook hoje ou "pausar tudo" no painel (entao nao se pede nada)
Nao adere, nao publica, nao escreve nada no estado (so pausas.json via sync).
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from grupos_emdia_comum import agora, avisos_do_dia, carregar_estado, chave, ler_dt  # noqa: E402
from grupos_emdia_sync import ler_pausas, sincronizar  # noqa: E402


def main():
    est = carregar_estado()
    try:
        sincronizar(est)
        sync = "ok"
    except Exception as ex:
        sync = "falhou: %s (uso a ultima copia das pausas)" % ex
    pz = ler_pausas()
    pausados = set(pz.get("pausados") or [])
    hoje = agora().date()
    plano = est.get("planos", {}).get(hoje.isoformat())
    av = avisos_do_dia(est, hoje)
    out = {"data": hoje.isoformat(), "sync_painel": sync, "pausado_tudo": bool(pz.get("pausado_tudo")),
           "avisos_hoje": [a.get("texto") for a in av], "plano_existe": bool(plano), "tecto": (plano or {}).get("tecto"),
           "adesao": [], "publicar": []}
    out["parar"] = bool(av) or out["pausado_tudo"] or bool((plano or {}).get("parar"))
    if plano and not out["parar"]:
        for link in plano.get("adesao", []):
            g = est["grupos"].get(chave(link)) or {}
            if link in pausados or g.get("pedido_adesao_em") or g.get("aceite_em"):
                continue
            out["adesao"].append({"link": link, "nome": g.get("nome"), "segmento": g.get("segmento"),
                                  "membros": g.get("membros"), "regras": (g.get("regras") or {}).get("permite_publicidade")})
        for it in plano.get("itens_pub", []):
            g = est["grupos"].get(chave(it["link"])) or {}
            up = ler_dt(g.get("ultima_publicacao_em"))
            if it["link"] in pausados or (up and up.date() == hoje) or not it.get("texto"):
                continue
            out["publicar"].append(it)
    print(json.dumps(out, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
