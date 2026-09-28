#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""grupos_emdia_registar.py -- regista o que a PESSOA fez nos grupos do Em Dia.

Escrito 2026-09-28, missao emdia-redes-2026-09-28 (bloco E2). A maquina nunca
adere nem publica; isto so apontamenta o que foi feito a mao, para o plano de
amanha saber o que escolher.

USO
  grupos_emdia_registar.py aderi <link_do_grupo>
  grupos_emdia_registar.py aceite <link_do_grupo>
  grupos_emdia_registar.py publiquei <link_do_grupo> <url_do_post> ["texto que saiu"]
  grupos_emdia_registar.py regras <link_do_grupo> sim|nao
  grupos_emdia_registar.py aviso "<texto do aviso>" [link_do_grupo]   -> trava o dia + Telegram
  grupos_emdia_registar.py ver [link_do_grupo]

Cada accao fica no estado (grupos_emdia_estado.json) e numa linha do registo.jsonl.
"""
import os
import sys
from datetime import timedelta

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from grupos_emdia_comum import (ESTADO, agora, avisar, carregar_estado, chave, gravar_json,  # noqa: E402
                                iso, ler_dt, registar_linha)


def grupo(est, link):
    k = chave(link)
    if not k.startswith("groups/"):
        sys.exit("ERRO: isto nao parece um link de grupo do Facebook: %s" % link)
    g = est["grupos"].get(k)
    if g is None:  # grupo fora do CSV: entra na mesma
        g = est["grupos"][k] = {
            "nome": "(fora do mapa) " + k, "link": link, "segmento": "?", "lingua": "", "encaixe": 0,
            "membros": 0, "distrito": "nacional", "slug": k.split("/")[-1][:30],
            "pedido_adesao_em": None, "aceite_em": None, "ultima_publicacao_em": None,
            "publicacoes": [], "regras": {"permite_publicidade": "por_confirmar"}, "avisos_facebook": [],
        }
        print("AVISO: grupo que nao estava no grupos.csv -- acrescentado ao estado.")
    return k, g


def main(argv):
    if not argv or argv[0] in ("-h", "--help"):
        print(__doc__)
        return 0
    cmd, args = argv[0].lower(), argv[1:]
    est = carregar_estado()
    agora_iso = iso()

    if cmd == "ver":
        if args:
            k, g = grupo(est, args[0])
            print(k, {x: g.get(x) for x in ("nome", "pedido_adesao_em", "aceite_em", "ultima_publicacao_em", "regras")})
        else:
            gs = est["grupos"].values()
            print("grupos=%d pedidos=%d aceites=%d com_publicacao=%d avisos=%d dias_limpos=%d" % (
                len(est["grupos"]), sum(1 for g in gs if g.get("pedido_adesao_em")),
                sum(1 for g in gs if g.get("aceite_em")), sum(1 for g in gs if g.get("ultima_publicacao_em")),
                len(est.get("avisos_facebook", [])), est.get("dias_limpos", 0)))
        return 0

    if cmd == "aviso":
        if not args:
            sys.exit("ERRO: falta o texto do aviso")
        texto = args[0]
        a = {"em": agora_iso, "texto": texto}
        if len(args) > 1:
            k, g = grupo(est, args[1])
            a["grupo"] = k
            g.setdefault("avisos_facebook", []).append({"em": agora_iso, "texto": texto})
        est.setdefault("avisos_facebook", []).append(a)
        est["dias_limpos"] = 0
        gravar_json(ESTADO, est)
        registar_linha("aviso", texto=texto, grupo=a.get("grupo"))
        ok = avisar("PARAR TUDO HOJE nos grupos do Em Dia (e cuidado com os do Bora: a conta pessoal e' a mesma). "
                    "Aviso do Facebook registado: \"%s\"" % texto[:400])
        print("aviso registado; travao do dia ligado; telegram=%s" % ("ok" if ok else "FALHOU"))
        return 0 if ok else 1

    if cmd in ("aderi", "aceite", "regras", "publiquei") and not args:
        sys.exit("ERRO: falta o link do grupo")

    if cmd == "aderi":
        k, g = grupo(est, args[0])
        g["pedido_adesao_em"] = g.get("pedido_adesao_em") or agora_iso
        extra = {}
    elif cmd == "aceite":
        k, g = grupo(est, args[0])
        g["pedido_adesao_em"] = g.get("pedido_adesao_em") or agora_iso
        g["aceite_em"] = agora_iso
        extra = {"pode_publicar_a_partir": iso(agora() + timedelta(hours=72))}
        print("Aceite. Primeira publicacao so a partir de %s (72 h). Ate la le e responde sem link." % extra["pode_publicar_a_partir"][:16])
    elif cmd == "regras":
        if len(args) < 2 or args[1].lower() not in ("sim", "nao", "não"):
            sys.exit("ERRO: uso: regras <link> sim|nao")
        k, g = grupo(est, args[0])
        v = "sim" if args[1].lower() == "sim" else "nao"
        g["regras"] = {"permite_publicidade": v, "confirmado_em": agora_iso}
        extra = {"permite_publicidade": v}
    elif cmd == "publiquei":
        if len(args) < 2:
            sys.exit("ERRO: uso: publiquei <link_do_grupo> <url_do_post>")
        k, g = grupo(est, args[0])
        ac = ler_dt(g.get("aceite_em"))
        if not ac:
            print("ATENCAO: este grupo nao tem 'aceite' registado. Fica registado na mesma.")
        elif agora() - ac < timedelta(hours=72):
            print("ATENCAO: publicado antes das 72 h depois de aceite -- e' o padrao que o Facebook castiga.")
        if (g.get("regras") or {}).get("permite_publicidade") == "nao":
            print("ATENCAO: este grupo esta marcado como 'proibe publicidade'.")
        pub = {"em": agora_iso, "url": args[1]}
        if len(args) > 2:
            pub["texto"] = args[2]
        g.setdefault("publicacoes", []).append(pub)
        g["ultima_publicacao_em"] = agora_iso
        extra = {"url": args[1]}
    else:
        sys.exit("ERRO: comando desconhecido '%s' (aderi|aceite|publiquei|regras|aviso|ver)" % cmd)

    gravar_json(ESTADO, est)
    registar_linha(cmd, grupo=k, nome=g.get("nome"), **extra)
    print("ok: %s %s (%s)" % (cmd, g.get("nome"), k))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
