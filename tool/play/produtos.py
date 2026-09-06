#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Cria as 4 subscrições do Em Dia na Play Console, pela API.

⚠️ ISTO MEXE EM PAGAMENTO/DINHEIRO. Os preços são os que o Danilo escreveu no
prompt da missão (secção 2, Tela 9) — não são decisão minha:

    pro_mensal      3,49 €/mês       pro_anual       29,90 €/ano
    familia_mensal  5,99 €/mês       familia_anual   49,90 €/ano

Por isso o comportamento por omissão é **ENSAIO**: mostra o que ia criar e não
cria nada. Só cria com `--criar`, e mesmo aí os planos base ficam em RASCUNHO
(`DRAFT`) — ninguém consegue comprar até alguém os ativar na consola. Ativar é
o "vai" do Danilo.

Uso:  python tool/play/produtos.py            # ensaio (não toca em nada)
      python tool/play/produtos.py --criar    # cria em rascunho
      python tool/play/produtos.py --listar   # o que já existe
"""
from __future__ import annotations

import datetime as dt
import sys
from pathlib import Path

for fluxo in (sys.stdout, sys.stderr):
    try:
        fluxo.reconfigure(encoding="utf-8", errors="replace")
    except Exception:  # noqa: BLE001
        pass

sys.path.insert(0, str(Path(__file__).parent))
from api import ErroPlay, Play  # noqa: E402

RAIZ = Path(__file__).resolve().parents[2]
PROVAS = RAIZ / "docs" / "provas" / "play"

# (produto, nome PT-PT, nome PT-BR, período ISO-8601, preço em micros de EUR)
PRODUTOS = [
    ("pro_mensal", "Em Dia Pro (mensal)", "Em Dia Pro (mensal)", "P1M", 3_490_000),
    ("pro_anual", "Em Dia Pro (anual)", "Em Dia Pro (anual)", "P1Y", 29_900_000),
    ("familia_mensal", "Em Dia Família (mensal)", "Em Dia Família (mensal)", "P1M", 5_990_000),
    ("familia_anual", "Em Dia Família (anual)", "Em Dia Família (anual)", "P1Y", 49_900_000),
]

DESCRICAO = {
    "pro_mensal": ("Avisos sem limite, assistente sem limite, leitura de extratos por foto, "
                   "comprovativos guardados, vários carros e exportação para o contabilista."),
    "pro_anual": ("Um ano de Em Dia Pro: avisos sem limite, assistente sem limite, extratos por foto, "
                  "comprovativos guardados, vários carros e exportação para o contabilista."),
    "familia_mensal": "Tudo o que o Pro tem, para até 5 pessoas ou 5 carros na mesma conta.",
    "familia_anual": "Um ano de Em Dia Família: tudo o que o Pro tem, para até 5 pessoas ou 5 carros.",
}


def corpo(produto: str, nome_pt: str, nome_br: str, periodo: str, micros: int) -> dict:
    return {
        "packageName": "pt.emdia.app",
        "productId": produto,
        "listings": [
            {"languageCode": "pt-PT", "title": nome_pt, "benefits": [], "description": DESCRICAO[produto]},
            {"languageCode": "pt-BR", "title": nome_br, "benefits": [], "description": DESCRICAO[produto]},
        ],
        "basePlans": [{
            "basePlanId": produto.replace("_", "-"),
            "state": "DRAFT",
            "autoRenewingBasePlanType": {
                "billingPeriodDuration": periodo,
                "gracePeriodDuration": "P7D",
                "accountHoldDuration": "P30D",
                "resubscribeState": "RESUBSCRIBE_STATE_ACTIVE",
                "prorationMode": "SUBSCRIPTION_PRORATION_MODE_CHARGE_ON_NEXT_BILLING_DATE",
                "legacyCompatible": True,
            },
            "regionalConfigs": [{
                "regionCode": "PT",
                "newSubscriberAvailability": True,
                "price": {"currencyCode": "EUR", "units": str(micros // 1_000_000),
                          "nanos": (micros % 1_000_000) * 1000},
            }],
        }],
    }


def main() -> int:
    criar = "--criar" in sys.argv
    p = Play()
    PROVAS.mkdir(parents=True, exist_ok=True)
    linhas = [f"# Prova — subscrições da Play ({dt.datetime.now():%Y-%m-%d %H:%M})", "",
              f"Modo: **{'CRIAR (planos base em DRAFT)' if criar else 'ENSAIO — não toca em nada'}**", ""]

    existentes = {s["productId"] for s in p.subscricoes().get("subscriptions", [])}
    linhas.append(f"- `subscriptions.list` → {len(existentes)} já existem: {sorted(existentes) or '(nenhuma)'}")
    print(linhas[-1])

    if "--listar" in sys.argv:
        (PROVAS / f"produtos-{dt.datetime.now():%Y%m%d-%H%M%S}.md").write_text("\n".join(linhas) + "\n", encoding="utf-8")
        return 0

    for produto, nome_pt, nome_br, periodo, micros in PRODUTOS:
        euros = f"{micros / 1_000_000:.2f} €".replace(".", ",")
        if produto in existentes:
            linha = f"- `{produto}` já existe — não mexo."
        elif not criar:
            linha = f"- ENSAIO `{produto}` · {nome_pt} · {periodo} · **{euros}** · plano base em DRAFT (não criado)"
        else:
            try:
                r = p.cria_subscricao(produto, corpo(produto, nome_pt, nome_br, periodo, micros))
                bp = (r.get("basePlans") or [{}])[0]
                linha = (f"- CRIADO `{r['productId']}` · plano base `{bp.get('basePlanId')}` "
                         f"estado **{bp.get('state')}** · {euros} · períodos {periodo}")
            except ErroPlay as e:
                linha = f"- ERRO `{produto}`: {e}"
        print(linha)
        linhas.append(linha)

    if not criar:
        linhas += ["", "> ⚠️ ISTO MEXE EM PAGAMENTO/DINHEIRO. Está tudo pronto — confirma que eu aplico.",
                   "> (`python tool/play/produtos.py --criar` cria com os planos base em rascunho; "
                   "ativar cada plano base na consola é o passo que abre as compras.)"]
    (PROVAS / f"produtos-{dt.datetime.now():%Y%m%d-%H%M%S}.md").write_text("\n".join(linhas) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
