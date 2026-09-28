#!/usr/bin/env python3
"""Ficha da App Store do Em Dia - verificacao de 6 em 6 horas (missao emdia-redes-2026-09-28, E0).

1. Le o estado das versoes iOS (apple_id 6814807320).
2. Quando a versao submetida ja estiver aprovada (na loja ou a sair), troca o Texto
   promocional pt-PT para TEXTO_PROMO. Se ja estiver igual, nao faz nada.
3. Se existir uma versao NOVA ainda editavel (em preparacao), tira-lhe da Descricao a
   frase que comeca por "Quando as assinaturas abrirem". Nunca mexe numa versao em revisao.

Imprime sempre o antes e o depois (le de volta da Apple). Sai com erro se a Apple nao
ficar como se pediu. Ambiente: ASC_KEY_ID, ASC_ISSUER_ID, ASC_P8 (caminho do .p8).
MODO=ler so mostra, nao escreve.
"""
import json
import os
import re
import sys
import time

import jwt
import requests

BASE = "https://api.appstoreconnect.apple.com"
KEY_ID = os.environ["ASC_KEY_ID"]
ISSUER = os.environ["ASC_ISSUER_ID"]
P8 = os.environ["ASC_P8"]
APP = os.environ.get("ASC_APP_ID", "6814807320")
SO_LER = os.environ.get("MODO", "") == "ler"

TEXTO_PROMO = ("Recibos verdes, prazos das Finanças e da Segurança Social e o carro, "
               "tudo num só sítio. Grátis, sem compras dentro da app.")
FRASE_A_TIRAR = "Quando as assinaturas abrirem"

# Aprovada (na loja, a sair ou a espera de lancamento).
APROVADA = {"READY_FOR_SALE", "READY_FOR_DISTRIBUTION", "PENDING_DEVELOPER_RELEASE",
            "PROCESSING_FOR_APP_STORE", "PROCESSING_FOR_DISTRIBUTION", "ACCEPTED",
            "PENDING_APPLE_RELEASE"}
EDITAVEL = {"PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED",
            "METADATA_REJECTED", "INVALID_BINARY"}


def _token():
    with open(P8, "r", encoding="utf-8") as f:
        chave = f.read()
    agora = int(time.time())
    return jwt.encode({"iss": ISSUER, "iat": agora, "exp": agora + 1100,
                       "aud": "appstoreconnect-v1"}, chave,
                      algorithm="ES256", headers={"kid": KEY_ID, "typ": "JWT"})


def _h():
    return {"Authorization": "Bearer " + _token(), "Content-Type": "application/json"}


def _resp(r):
    try:
        return r.status_code, r.json()
    except Exception:
        return r.status_code, {"raw": r.text[:500]}


def get(path, **params):
    return _resp(requests.get(BASE + path, headers=_h(), params=params, timeout=60))


def patch(path, data):
    return _resp(requests.patch(BASE + path, headers=_h(),
                                data=json.dumps({"data": data}), timeout=60))


def erro_apple(j):
    return "; ".join("%s: %s" % (e.get("title"), e.get("detail"))
                     for e in j.get("errors", [])) or json.dumps(j)[:300]


def morre(msg):
    print("::error::" + msg)
    sys.exit(1)


def estado(v):
    a = v["attributes"]
    return a.get("appVersionState") or a.get("appStoreState") or ""


def localizacoes(vid):
    c, j = get("/v1/appStoreVersions/%s/appStoreVersionLocalizations" % vid,
               **{"fields[appStoreVersionLocalizations]": "locale,promotionalText,description"})
    if c != 200:
        morre("nao li as localizacoes de %s (%s): %s" % (vid, c, erro_apple(j)))
    return j.get("data", [])


def tirar_frase(texto):
    """Tira a frase inteira que comeca em FRASE_A_TIRAR (ate ao ponto final/fim da linha)."""
    novo = re.sub(r"[ \t]*" + re.escape(FRASE_A_TIRAR) + r"[^\n]*?(?:[.!?](?=\s|$)|(?=\n)|$)[ \t]*",
                  "", texto)
    return re.sub(r"\n{3,}", "\n\n", novo).strip()


def main():
    c, j = get("/v1/apps/%s/appStoreVersions" % APP,
               **{"filter[platform]": "IOS",
                  "fields[appStoreVersions]": "versionString,appStoreState,appVersionState,createdDate",
                  "limit": "10"})
    if c != 200:
        morre("nao li as versoes (%s): %s" % (c, erro_apple(j)))
    versoes = j.get("data", [])
    for v in versoes:
        print("versao %s -> %s" % (v["attributes"]["versionString"], estado(v)))

    aprovadas = [v for v in versoes if estado(v) in APROVADA]
    editaveis = [v for v in versoes if estado(v) in EDITAVEL]

    # -- Texto promocional na versao aprovada --------------------------------
    if not aprovadas:
        print("RESULTADO promo: ainda nao aprovada - nada a fazer.")
    else:
        v = aprovadas[0]
        for loc in localizacoes(v["id"]):
            at = loc["attributes"]
            if not at["locale"].lower().startswith("pt"):
                continue
            antes = at.get("promotionalText") or ""
            print("promo %s ANTES: %r" % (at["locale"], antes))
            if antes == TEXTO_PROMO:
                print("RESULTADO promo: ja estava certo em %s." % at["locale"])
                continue
            if SO_LER:
                print("MODO=ler: trocaria para %r" % TEXTO_PROMO)
                continue
            c, r = patch("/v1/appStoreVersionLocalizations/" + loc["id"],
                         {"type": "appStoreVersionLocalizations", "id": loc["id"],
                          "attributes": {"promotionalText": TEXTO_PROMO}})
            if c >= 300:
                morre("nao troquei o texto promocional (%s): %s" % (c, erro_apple(r)))
        for loc in localizacoes(v["id"]):
            at = loc["attributes"]
            if at["locale"].lower().startswith("pt"):
                depois = at.get("promotionalText") or ""
                print("promo %s DEPOIS: %r" % (at["locale"], depois))
                if not SO_LER and depois != TEXTO_PROMO:
                    morre("a Apple nao ficou com o texto promocional novo em %s" % at["locale"])
                if depois == TEXTO_PROMO:
                    print("RESULTADO promo: OK em %s (versao %s)."
                          % (at["locale"], v["attributes"]["versionString"]))

    # -- Descricao da proxima versao ------------------------------------------
    if not editaveis:
        print("RESULTADO descricao: sem versao nova em preparacao - fica para quando houver.")
        return
    v = editaveis[0]
    for loc in localizacoes(v["id"]):
        at = loc["attributes"]
        desc = at.get("description") or ""
        if FRASE_A_TIRAR not in desc:
            print("RESULTADO descricao %s (v%s): frase ja nao esta."
                  % (at["locale"], v["attributes"]["versionString"]))
            continue
        nova = tirar_frase(desc)
        print("descricao %s ANTES (%d car.) -> DEPOIS (%d car.)" % (at["locale"], len(desc), len(nova)))
        if SO_LER:
            continue
        c, r = patch("/v1/appStoreVersionLocalizations/" + loc["id"],
                     {"type": "appStoreVersionLocalizations", "id": loc["id"],
                      "attributes": {"description": nova}})
        if c >= 300:
            morre("nao troquei a descricao (%s): %s" % (c, erro_apple(r)))
    for loc in localizacoes(v["id"]):
        at = loc["attributes"]
        ainda = FRASE_A_TIRAR in (at.get("description") or "")
        print("RESULTADO descricao %s (v%s): %s" % (at["locale"], v["attributes"]["versionString"],
                                                   "AINDA TEM a frase" if ainda else "OK sem a frase"))
        if ainda and not SO_LER:
            morre("a frase continua na descricao em %s" % at["locale"])


if __name__ == "__main__":
    main()
