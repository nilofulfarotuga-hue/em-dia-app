#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Põe a ficha da loja (PT-PT e PT-BR) e as imagens na Play Console, pela API.

Textos: docs/loja/descricao-play.md (contagens já provadas lá).
Imagens: docs/loja/play/ (geradas de capturas REAIS por tool/loja/capturas.py).

Uso:  python tool/play/ficha.py            # aplica e faz commit da edição
      python tool/play/ficha.py --ensaio   # faz tudo e descarta (não publica)

Escreve a prova em docs/provas/play/ficha-<data>.md com a resposta literal da API.
"""
from __future__ import annotations

import datetime as dt
import sys
from pathlib import Path

# A consola do Windows é cp1252 e rebenta em «→» — a prova não se perde por causa disso.
for fluxo in (sys.stdout, sys.stderr):
    try:
        fluxo.reconfigure(encoding="utf-8", errors="replace")
    except Exception:  # noqa: BLE001
        pass

sys.path.insert(0, str(Path(__file__).parent))
from api import ErroPlay, Play  # noqa: E402

RAIZ = Path(__file__).resolve().parents[2]
IMG = RAIZ / "docs" / "loja" / "play"
PROVAS = RAIZ / "docs" / "provas" / "play"

PT_LONGA = """Em Dia é o assistente do trabalhador independente em Portugal — motoristas TVDE, estafetas de plataforma, cabeleireiras, freelancers e quem só quer ter o carro em dia.

Nunca mais te esqueces de um prazo. O Em Dia lê o teu perfil e monta o teu calendário de obrigações: Segurança Social, IVA, IRS e tudo o que o teu carro precisa.

O QUE FAZES COM O EM DIA
• Calculadora de recibos verdes: sabes logo quanto fica para ti depois da retenção de IRS e do IVA.
• Vigia do IVA: um alerta antes de chegares aos 15.000 € (limite da isenção do artigo 53.º) para nunca levares uma multa das Finanças.
• Segurança Social sem sustos: sabes quanto pagar todos os meses e quando entregar a declaração trimestral.
• Calendário de obrigações: Segurança Social, IVA e IRS — cada prazo com o valor e o dia certo, com aviso antes de vencer.
• Assistente do carro: quando pagas o IUC, quando é a próxima inspeção (IPO), quando renova o seguro e a validade da tua carta.
• Assistente com Inteligência Artificial: pergunta o que quiseres, em português, e recebe uma resposta com o prazo certo.
• Feito para TVDE e estafetas: acompanha os teus rendimentos e sabe quanto guardar em cada mês.
• Feito também para quem não é motorista: cabeleireiras, freelancers e qualquer prestador de serviços com recibos verdes.
• Imigrante brasileiro em Portugal: a Segurança Social e o IRS explicados como para uma criança de 5 anos, sem jargão.

PORQUÊ USAR
A informação está espalhada por dez sítios — Segurança Social Direta, Portal das Finanças, IMT. O Em Dia junta tudo num só lugar e avisa-te antes do prazo, não depois.

Não substitui o teu contabilista — ajuda-te a chegar a ele já organizado, ou a perceber sozinho os prazos mais simples.

30 dias grátis, sem cartão de crédito."""

BR_LONGA = """O Em Dia é o assistente de quem trabalha por conta própria em Portugal — motoristas de TVDE, entregadores de aplicativo, cabeleireiras, freelancers e quem só quer manter o carro em dia.

Você nunca mais esquece um prazo. O Em Dia lê o seu perfil e monta o seu calendário de obrigações: Segurança Social, IVA, IRS e tudo o que o carro precisa.

O QUE VOCÊ FAZ COM O EM DIA
• Calculadora de recibos verdes: você vê na hora quanto sobra para você depois da retenção de IRS e do IVA.
• Vigia do IVA: um aviso antes de chegar aos 15.000 € (limite da isenção do artigo 53.º) para nunca levar multa das Finanças.
• Segurança Social sem susto: você sabe quanto pagar todo mês e quando entregar a declaração trimestral.
• Calendário de obrigações: Segurança Social, IVA e IRS — cada prazo com o valor e o dia certo, avisado antes de vencer.
• Assistente do carro: quando paga o IUC (o imposto do carro), quando é a próxima inspeção (IPO), quando renova o seguro e a validade da carteira.
• Assistente com Inteligência Artificial: pergunte o que quiser, em português, e receba a resposta com o prazo certo.
• Feito para TVDE e entregadores: acompanhe seus rendimentos e saiba quanto guardar por mês.
• Feito também para quem não é motorista: cabeleireiras, freelancers e qualquer prestador de serviços com recibos verdes.
• Brasileiro em Portugal: a Segurança Social e o IRS explicados como para uma criança de 5 anos, sem jargão.

POR QUE USAR
A informação está espalhada em dez lugares — Segurança Social Direta, Portal das Finanças, IMT. O Em Dia junta tudo num lugar só e avisa antes do prazo, não depois.

Não substitui o seu contador — ajuda você a chegar nele já organizado, ou a entender sozinho os prazos mais simples.

30 dias grátis, sem cartão de crédito."""

FICHAS = {
    "pt-PT": ("Em Dia: Recibos e Impostos",
              "Recibos verdes, IVA, Segurança Social e o teu carro sempre em dia, em português.",
              PT_LONGA),
    "pt-BR": ("Em Dia: Impostos em Portugal",
              "Recibos verdes, IVA, Segurança Social e o seu carro sempre em dia, em português.",
              BR_LONGA),
}


def main() -> int:
    ensaio = "--ensaio" in sys.argv
    p = Play()
    PROVAS.mkdir(parents=True, exist_ok=True)
    linhas = [f"# Prova — ficha da Play pela API ({dt.datetime.now():%Y-%m-%d %H:%M})", "",
              f"Pacote `{p.pacote}` · service account `{p.sa['client_email']}` · "
              f"{'ENSAIO (descarta)' if ensaio else 'a sério (commit)'}", ""]
    capturas = sorted(IMG.glob("captura-*.png"), key=lambda f: int(f.stem.split("-")[1]))
    try:
        with p.edicao(submeter=not ensaio) as ed:
            for lingua, (titulo, curta, completa) in FICHAS.items():
                r = p.listagem(ed, lingua, titulo, curta, completa)
                linha = (f"- `listings.update {lingua}` → título «{r['title']}» ({len(r['title'])} car.), "
                         f"curta {len(r['shortDescription'])} car., completa {len(r['fullDescription'])} car.")
                print(linha)
                linhas.append(linha)
            # imagens: só na ficha PT-PT (a PT-BR herda quando não tem próprias)
            for tipo, ficheiros in (("icon", [IMG / "icone-512.png"]),
                                    ("featureGraphic", [IMG / "feature-1024x500.png"]),
                                    ("phoneScreenshots", capturas)):
                p.apaga_imagens(ed, "pt-PT", tipo)
                for f in ficheiros:
                    r = p.imagem(ed, "pt-PT", tipo, f)
                    im = r.get("image", {})
                    linha = f"- `images.upload {tipo}` ← {f.name} ({f.stat().st_size // 1024} KB) → id `{im.get('id','?')}` sha1 `{im.get('sha1','?')[:12]}…`"
                    print(linha)
                    linhas.append(linha)
                lista = p.imagens(ed, "pt-PT", tipo).get("images", [])
                linhas.append(f"- `images.list {tipo}` → **{len(lista)} imagem(ns) na edição**")
                print(f"  {tipo}: {len(lista)} na edição")
    except ErroPlay as e:
        linhas.append(f"\n**ERRO**: {e}")
        (PROVAS / f"ficha-{dt.datetime.now():%Y%m%d-%H%M%S}.md").write_text("\n".join(linhas) + "\n", encoding="utf-8")
        print("ERRO:", e)
        return 1
    linhas.append("\nEdição submetida (ou descartada, em ensaio). A ficha fica pronta na Vista geral da publicação.")
    (PROVAS / f"ficha-{dt.datetime.now():%Y%m%d-%H%M%S}.md").write_text("\n".join(linhas) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
