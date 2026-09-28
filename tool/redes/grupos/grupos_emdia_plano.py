#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""grupos_emdia_plano.py -- o plano do dia para os grupos de Facebook do Em Dia.

Escrito 2026-09-28, missao emdia-redes-2026-09-28 (bloco E2). Copia o desenho do
grupos_plano.py do Bora (/opt/data/social): a maquina escolhe e escreve, uma pessoa
carrega em Aderir/Publicar.

NAO ADERE, NAO PUBLICA, NAO COMENTA, NAO CLICA. Manda UM plano ao Telegram:
  a) ate 5 grupos para PEDIR ADESAO (maior encaixe, ainda sem pedido; no maximo um
     por segmento e um por distrito, ate faltar escolha);
  b) ate 5 grupos para PUBLICAR (aceites ha >= 72 h, 1x por grupo por semana, que nao
     proibam publicidade), 30-60 min entre cada, cada um com TEXTO PROPRIO escrito de
     raiz pelo motor gratis da VPS;
  c) o tecto sobe de 5 para 7 ao fim de 7 dias seguidos sem aviso do Facebook;
     e nunca passa o que sobra do tecto da CONTA PESSOAL partilhada com o Bora
     (_COMUM-EMDIA.md 3.1: tecto total do dia menos as 5 do Bora);
  d) aviso/bloqueio registado hoje -> "PARAR TUDO HOJE" e mais nada.

USO
  grupos_emdia_plano.py [--ensaio] [--cron] [--forcar] [--data AAAA-MM-DD] [--exemplo]
    --ensaio   imprime o que iria para o Telegram; nao manda nem grava o plano
    --cron     so corre se forem 08:xx em Lisboa (o cron chama as 07:40 e 08:40 UTC,
               assim a hora de verao/inverno nunca desalinha)
    --forcar   manda mesmo que o plano de hoje ja tenha saido
    --exemplo  gera tambem um texto de exemplo para o grupo n.o 1 da lista de adesao
"""
import argparse
import json
import os
import random
import re
import sys
import urllib.request
from datetime import date, datetime, timedelta

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from grupos_emdia_comum import (LINK_APP, PLANOS, PLAYBOOK, agora, avisar, avisos_do_dia,  # noqa: E402
                                carregar_estado, gravar_json, ESTADO, iso, ler_dt, log, partir)

MOTOR = os.environ.get("EMDIA_MOTOR", "http://127.0.0.1:8792/v1/chat/completions")
N_ADESAO = 5
TECTO_BASE, TECTO_SUBIDO, DIAS_PARA_SUBIR = 5, 7, 7
ESPERA_ACEITE_H = 72
DIAS_ENTRE_PUBLICACOES = 7
PRIMEIRA_HORA = 12          # o Bora publica primeiro (09:30); o Em Dia arranca ao meio-dia
BORA_POR_DIA = 5

# Angulos uteis-primeiro. O motor recebe UM por grupo e escreve de raiz.
# Cada angulo leva os UNICOS factos que o texto pode usar -- tirados de docs/REGRAS-PT-2026.md
# do repo em_dia (verificados a 2026-09-06/18). O motor inventava estatisticas ("1 em cada 3",
# "30 mil brasileiros") no primeiro ensaio; por isso ha tambem a verificacao de numeros abaixo.
ANGULOS = [
    ("o prazo do IVA trimestral",
     "A declaracao periodica do IVA trimestral entrega-se ate dia 20 do 2.o mes seguinte ao trimestre "
     "(o trimestre de julho a setembro entrega-se ate 20 de novembro) e o imposto paga-se ate dia 25."),
    ("a declaracao trimestral da Seguranca Social de quem passa recibos verdes",
     "A declaracao trimestral da Seguranca Social entrega-se ate ao ultimo dia de janeiro, abril, julho e outubro."),
    ("a retencao na fonte nos recibos verdes e a dispensa",
     "A retencao na fonte nos recibos verdes e de 23 por cento por regra (25 por cento se a pessoa optar). "
     "Quem nao passou dos 15 mil euros no ano anterior pode ficar dispensado de retencao."),
    ("guardar faturas para as deducoes do IRS",
     "No IRS, saude deduz 15 por cento ate mil euros; educacao 30 por cento ate 800 euros; rendas 15 por cento ate 800 euros; "
     "faturas de oficina, restauracao, cabeleireiro, ginasio e veterinario deduzem 15 por cento do IVA ate 250 euros. "
     "As faturas validam-se no e-Fatura ate 25 de fevereiro."),
    ("o primeiro ano de atividade",
     "Quem abre atividade pela primeira vez fica isento de contribuicoes para a Seguranca Social durante os primeiros 12 meses."),
    ("o limite de isencao de IVA do artigo 53",
     "A isencao de IVA do artigo 53 vale ate 15 mil euros por ano; quem passa dos 18 750 euros perde-a logo; "
     "a mudanca comunica-se as Financas em 15 dias uteis."),
    ("organizar recibos e faturas durante o ano em vez de correr em junho",
     "O IRS entrega-se de 1 de abril a 30 de junho. Quem guarda recibos e faturas ao longo do ano nao perde deducoes nem prazos."),
    ("motoristas TVDE e estafetas a recibos verdes",
     "Quem trabalha a recibos verdes declara a Seguranca Social por trimestre, ate ao ultimo dia de janeiro, abril, julho e outubro; "
     "nos primeiros 12 meses de atividade ha isencao de contribuicoes; a retencao na fonte e de 23 por cento por regra, "
     "com dispensa possivel para quem nao passou dos 15 mil euros no ano anterior."),
]
ACCOES = [
    "pergunta final que puxe resposta nos comentarios",
    "pede para marcar alguem que acabou de abrir atividade",
    "pede para guardar a publicacao para quando chegar o prazo",
    "pede para mandar a quem trabalha a recibos verdes",
]
PROIBIDO = re.compile(r"(gr[aá]tis|gratuit|m[eê]s gr|teste|trial|assinatura|subscri|pre[cç]o|"
                      r"planos?\b|premium|\bbora\b|#\w|https?://|www\.)", re.I)


def tecto_conta(dia):
    """_COMUM-EMDIA.md 3.1 -- tecto TOTAL por dia da conta pessoal (Bora + Em Dia)."""
    if dia <= date(2026, 9, 30):
        return 8
    if dia <= date(2026, 10, 7):
        return 12
    if dia <= date(2026, 10, 21):
        return 15
    return 25


def carregar_playbook():
    if not os.path.exists(PLAYBOOK):
        return [], []
    try:
        with open(PLAYBOOK, encoding="utf-8") as f:
            pb = json.load(f)
    except (OSError, ValueError) as e:
        log("playbook ilegivel (%s) -- sigo sem ele" % e)
        return [], []

    def txt(x, chaves):
        if isinstance(x, str):
            return x
        if isinstance(x, dict):
            partes = [str(x[c]) for c in chaves if x.get(c)]
            return " | ".join(partes) if partes else json.dumps(x, ensure_ascii=False)
        return str(x)
    modelos = [txt(m, ("publico", "texto")) for m in (pb.get("modelos_grupos") or [])]
    regras = [txt(r, ("como_grupos", "texto")) for r in (pb.get("regras") or [])
              if isinstance(r, dict) and r.get("aplica_grupos") is True]
    random.Random(agora().date().toordinal()).shuffle(modelos)  # cada dia inspira-se noutros modelos
    return modelos, regras


PAUSADOS = set()  # links pausados no painel admin (grupos_emdia_sync.py -> pausas.json)


def escolher_adesao(est):
    livres = [(k, g) for k, g in est["grupos"].items()
              if not g.get("pedido_adesao_em") and not g.get("aceite_em") and not g.get("saiu")
              and g.get("link") not in PAUSADOS]
    livres.sort(key=lambda kg: (-kg[1].get("encaixe", 0), -kg[1].get("membros", 0)))
    escolha, segs, dists = [], set(), set()
    for rigor in (2, 1, 0):  # 2 = segmento E distrito novos; 1 = so segmento; 0 = qualquer
        for k, g in livres:
            if len(escolha) >= N_ADESAO:
                break
            if k in [e[0] for e in escolha]:
                continue
            d = g.get("distrito", "nacional")
            if rigor >= 1 and g.get("segmento") in segs:
                continue
            if rigor == 2 and d != "nacional" and d in dists:
                continue
            escolha.append((k, g))
            segs.add(g.get("segmento"))
            dists.add(d)
    return escolha, len(livres)


def escolher_publicacao(est, tecto, hoje_dt):
    aptos, saltados = [], {"sem_aceite": 0, "menos_72h": 0, "publicado_semana": 0, "proibe": 0, "pausado": 0}
    for k, g in est["grupos"].items():
        if g.get("link") in PAUSADOS:
            saltados["pausado"] += 1
            continue
        ac = ler_dt(g.get("aceite_em"))
        if not ac:
            saltados["sem_aceite"] += 1
            continue
        if hoje_dt - ac < timedelta(hours=ESPERA_ACEITE_H):
            saltados["menos_72h"] += 1
            continue
        up = ler_dt(g.get("ultima_publicacao_em"))
        if up and hoje_dt - up < timedelta(days=DIAS_ENTRE_PUBLICACOES):
            saltados["publicado_semana"] += 1
            continue
        if (g.get("regras") or {}).get("permite_publicidade") == "nao" or g.get("saiu"):
            saltados["proibe"] += 1
            continue
        aptos.append((k, g))
    # quem nunca publicou primeiro, depois o que esta ha mais tempo sem publicacao; encaixe desempata
    aptos.sort(key=lambda kg: (kg[1].get("ultima_publicacao_em") or "", -kg[1].get("encaixe", 0)))
    return aptos[:tecto], len(aptos), saltados


def lingua_instr(g):
    lg = (g.get("lingua") or "").lower()
    if g.get("segmento") == "brasileiros" or lg == "pt-br":
        return "portugues do Brasil, tratando o leitor por 'voce'"
    if lg.startswith("en"):
        return "ingles simples e curto"
    return "portugues de Portugal (PT-PT: 'tu' ou impessoal, 'telemovel', 'recibos verdes'; nunca 'voce')"


def pedir_motor(prompt, max_tokens=420):
    corpo = json.dumps({"model": "perfil:volume", "max_tokens": max_tokens,
                        "messages": [{"role": "user", "content": prompt}]}).encode()
    req = urllib.request.Request(MOTOR, data=corpo, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=120) as r:
        d = json.loads(r.read().decode())
    return (d["choices"][0]["message"]["content"] or "").strip()


def limpar(t):
    t = t.strip().strip('"').strip()
    linhas = []
    for ln in t.splitlines():
        ln = re.sub(r"^\s*([-–—•*]+|\d+[.)])\s*", "", ln.rstrip())  # sem hifens/marcas no inicio
        linhas.append(ln)
    t = "\n".join(linhas)
    t = re.sub(r"\*\*|__", "", t)
    return re.sub(r"\n{3,}", "\n\n", t).strip()


def palavras(t):
    return set(re.findall(r"[a-zà-ú]{4,}", t.lower()))


def parecido(a, b):
    pa, pb = palavras(a), palavras(b)
    return len(pa & pb) / max(1, len(pa | pb))


RODAPE = "Não substitui um contabilista."
NUMEROS_LIVRES = {"1", "2", "3", "2026"}


def numeros(t):
    return set(re.findall(r"\d+(?:[ .]\d{3})*", t.replace(" ", " ")))


def gerar_texto(g, angulo, accao, ja_escritos, modelos, regras):
    assunto, factos = angulo
    permitidos = {n.replace(" ", "").replace(".", "") for n in numeros(factos + " " + accao)} | NUMEROS_LIVRES
    base = ("Escreve uma publicacao para um grupo de Facebook chamado \"%s\" (tema: %s).\n"
            "Lingua: %s.\n"
            "Assunto util (primeiro ajudar, so depois mostrar): %s.\n"
            "FACTOS -- sao os UNICOS numeros e regras que podes usar; nao inventes estatisticas, percentagens,"
            " multas, contagens de pessoas nem datas que aqui nao estejam: %s\n"
            "Comeca com um gancho concreto e diferente (uma situacao do dia a dia, uma profissao ou uma cidade"
            " portuguesa), explica a regra em 2 ou 3 frases simples, e so no fim diz numa frase que a app Em Dia"
            " lembra estes prazos e organiza os recibos. Termina com UMA acao: %s.\n"
            "Regras duras: 60 a 110 palavras; texto corrido em 2 ou 3 paragrafos; nenhuma linha comeca"
            " com hifen, travessao, numero ou marcador; sem hashtags; sem links; sem emojis a mais (0 ou 1);"
            " nao falar de precos, planos, assinaturas, testes nem de 'gratis'. Nas duas ultimas linhas poe"
            " exatamente: '%s' e depois 'Em Dia'.\n"
            "Devolve so o texto da publicacao, sem titulo nem comentarios teus."
            % (g.get("nome"), g.get("segmento"), lingua_instr(g), assunto, factos, accao, RODAPE))
    if modelos:
        base += "\nModelos de referencia (inspira-te no tom; NAO copies frases):\n" + "\n".join(
            "* " + m[:300] for m in modelos[:4])
    if regras:
        base += "\nRegras do playbook para grupos:\n" + "\n".join("* " + r[:200] for r in regras[:8])
    ultimo_erro = ""
    for tentativa in range(4):
        extra = ("\nA tentativa anterior foi recusada: %s. Escreve outra, de raiz." % ultimo_erro) if ultimo_erro else ""
        try:
            t = limpar(pedir_motor(base + extra))
        except Exception as e:  # rede/motor em baixo: nao ha texto de reserva -- diz-se
            ultimo_erro = "motor falhou: %s" % e
            continue
        # rodape sempre igual e em linhas proprias, seja como for que o motor o escreveu
        corpo = re.sub(r"\s*Em Dia\.?\s*$", "", t).rstrip()
        corpo = re.sub(r"\s*N[ãa]o substitui (um|o) contabilista\.?", "", corpo, flags=re.I).rstrip()
        t = corpo + "\n\n" + RODAPE + "\nEm Dia"
        n = len(corpo.split())
        m = PROIBIDO.search(t)
        inventados = {x.replace(" ", "").replace(".", "") for x in numeros(t)} - permitidos
        if m:
            ultimo_erro = "tinha palavra proibida '%s'" % m.group(0)
        elif not re.search(r"\bapp\b|aplica[cç]", corpo, re.I):
            ultimo_erro = "nao disse numa frase que a app Em Dia lembra os prazos"
        elif inventados:
            ultimo_erro = "tinha numeros que nao estao nos factos (%s) -- usa so os factos dados" % ", ".join(sorted(inventados))
        elif not (55 <= n <= 150):
            ultimo_erro = "tinha %d palavras" % n
        elif any(parecido(t, j) > 0.45 for j in ja_escritos):
            ultimo_erro = "parecido demais com outro texto de hoje ou recente"
        else:
            return t, None
    return None, ultimo_erro


def angulo_para(g, i):
    """O angulo dos motoristas/estafetas so vai para esses grupos; os outros nunca o recebem."""
    if g.get("segmento") in ("tvde", "estafetas") and i % 2 == 0:
        return ANGULOS[-1]
    gerais = ANGULOS[:-1]
    return gerais[i % len(gerais)]


def horas_do_dia(n, seed):
    rnd = random.Random(seed)
    t = datetime(2000, 1, 1, PRIMEIRA_HORA, rnd.choice([0, 10, 20]))
    out = []
    for _ in range(n):
        out.append(t.strftime("%H:%M"))
        t += timedelta(minutes=rnd.randint(30, 60))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ensaio", action="store_true")
    ap.add_argument("--cron", action="store_true")
    ap.add_argument("--forcar", action="store_true")
    ap.add_argument("--exemplo", action="store_true")
    ap.add_argument("--data")
    a = ap.parse_args()

    agora_dt = agora()
    if a.cron and agora_dt.hour != 8:
        return 0  # a outra das duas chamadas do cron e' a certa
    hoje_dt = agora_dt
    if a.data:
        hoje_dt = datetime.fromisoformat(a.data).replace(hour=8, minute=40, tzinfo=agora_dt.tzinfo)
    hoje = hoje_dt.date()
    est = carregar_estado()
    # pausas do painel admin (Redes > Grupos do Facebook): sincroniza antes de escolher;
    # sem rede segue com a ultima copia das pausas (pausas.json).
    from grupos_emdia_sync import sincronizar, ler_pausas
    try:
        if not a.ensaio:
            sincronizar(est)
    except Exception as ex:
        log("sync painel falhou antes do plano: %s" % ex)
    pz = ler_pausas()
    PAUSADOS.update(pz.get("pausados") or [])
    if pz.get("pausado_tudo"):
        log("grupos PAUSADOS no painel admin -- sem plano hoje")
        avisar("PLANO DOS GRUPOS DO EM DIA -- %s\nPausado no painel admin (Redes > Grupos do Facebook). Hoje nao ha adesoes nem publicacoes." % hoje.strftime("%d/%m/%Y"), a.ensaio)
        return 0
    ja = est.setdefault("planos", {}).get(hoje.isoformat())
    if ja and ja.get("enviado") and not a.forcar and not a.ensaio:
        log("plano de %s ja saiu as %s -- nao repito (usa --forcar)" % (hoje, ja.get("em")))
        return 0

    cab = "PLANO DOS GRUPOS DO EM DIA -- %s\nA maquina so escolhe e escreve. Aderir e Publicar carregas tu." % hoje.strftime("%d/%m/%Y")

    # d) travao do dia
    av = avisos_do_dia(est, hoje)
    if av:
        msg = (cab + "\n\nPARAR TUDO HOJE.\nHa aviso do Facebook registado hoje: \"%s\".\n"
               "Nem aderir, nem publicar, nem comentar em grupos ate amanha. Amanha o plano volta a meio gas."
               % av[-1].get("texto", "")[:300])
        ok = avisar(msg, a.ensaio)
        if not a.ensaio:
            est["planos"][hoje.isoformat()] = {"em": iso(), "parar": True, "enviado": ok}
            gravar_json(ESTADO, est)
        return 0 if ok else 1

    # c) tecto
    limpos = est.get("dias_limpos", 0)
    tecto_emdia = TECTO_SUBIDO if limpos >= DIAS_PARA_SUBIR else TECTO_BASE
    ontem = hoje - timedelta(days=1)
    if avisos_do_dia(est, ontem):
        tecto_emdia = max(1, tecto_emdia // 2)
    sobra_conta = max(0, tecto_conta(hoje) - BORA_POR_DIA)
    tecto = min(tecto_emdia, sobra_conta)

    adesao, n_livres = escolher_adesao(est)
    pub, n_aptos, saltados = escolher_publicacao(est, tecto, hoje_dt)
    modelos, regras = carregar_playbook()

    recentes = []
    for g in est["grupos"].values():
        for p in (g.get("publicacoes") or [])[-3:]:
            if p.get("texto"):
                recentes.append(p["texto"])
    for p in est["planos"].values():
        recentes.extend(p.get("textos", [])[-10:])
    recentes = recentes[-60:]

    rnd = random.Random(hoje.toordinal())
    horas = horas_do_dia(len(pub), hoje.toordinal())
    blocos_pub, textos_hoje = [], []
    for i, (k, g) in enumerate(pub):
        angulo = angulo_para(g, hoje.toordinal() + i * 3)
        accao = ACCOES[rnd.randrange(len(ACCOES))]
        t, erro = gerar_texto(g, angulo, accao, recentes + textos_hoje, modelos, regras)
        regras_g = (g.get("regras") or {}).get("permite_publicidade", "por_confirmar")
        cabeca = "%d) %s -- %s\n%s\n" % (i + 1, horas[i], g.get("nome"), g.get("link"))
        if regras_g != "sim":
            cabeca += ("Regras por confirmar: abre as regras fixadas primeiro; se proibir divulgacao, "
                       "nao publiques e marca: grupos_emdia_registar.py regras %s nao\n" % g.get("link"))
        if t:
            textos_hoje.append(t)
            corpo = "TEXTO (so para este grupo; le antes de colar, o motor gratis as vezes acrescenta frases fora dos factos):\n%s\n\n1.o comentario, logo a seguir a publicar:\n%s" % (
                t, LINK_APP % g.get("slug"))
        else:
            corpo = "SEM TEXTO: o motor nao entregou um texto valido (%s). Escreve um de raiz ou salta este grupo." % erro
        blocos_pub.append(cabeca + corpo + "\nDepois: grupos_emdia_registar.py publiquei %s <link_do_post>" % g.get("link"))

    linhas_ad = ["%d) %s [%s, %s, encaixe %s, %s membros]\n%s" % (
        i + 1, g.get("nome"), g.get("segmento"), g.get("distrito"), g.get("encaixe"),
        g.get("membros"), g.get("link")) for i, (k, g) in enumerate(adesao)]

    resumo = ("Candidatos a adesao (sem pedido): %d. Aptos a publicar: %d. "
              "Tecto de publicacoes hoje: %d (Em Dia %d, %d dias limpos; a conta pessoal deixa %d depois das %d do Bora)."
              % (n_livres, n_aptos, tecto, tecto_emdia, limpos, sobra_conta, BORA_POR_DIA))
    sec_a = ("A) PEDIR ADESAO (%d)\nNestes grupos NAO se publica nada durante 72 h depois de aceite; "
             "le e responde a 2 ou 3 duvidas sem link.\n\n" % len(adesao)) + "\n\n".join(linhas_ad) + (
        "\n\nDepois de pedir: grupos_emdia_registar.py aderi <link>\nQuando aceitarem: grupos_emdia_registar.py aceite <link>")
    if pub:
        sec_b = "B) PUBLICAR (%d), com 30 a 60 min entre cada, foto ou carrossel (nunca video)." % len(pub)
    else:
        sec_b = ("B) PUBLICAR (0). Nenhum grupo aceite ha 72 h ou mais (sem aceite: %d; aceites ha menos de 72 h: %d; "
                 "ja publicados esta semana: %d; proibem: %d). Hoje so se pede adesao."
                 % (saltados["sem_aceite"], saltados["menos_72h"], saltados["publicado_semana"], saltados["proibe"]))
    fim = ("Os registos correm na VPS: /usr/bin/python3 /opt/data/emdia-redes/grupos/grupos_emdia_registar.py <comando>\n"
           "Se o Facebook der QUALQUER aviso: grupos_emdia_registar.py aviso \"texto do aviso\" -- para tudo no mesmo dia.")

    msg = "\n\n".join([cab, resumo, sec_a, sec_b] + blocos_pub + [fim])
    exemplo = None
    if a.exemplo and adesao:
        g = adesao[0][1]
        exemplo, err = gerar_texto(g, angulo_para(g, hoje.toordinal()), ACCOES[0], recentes, modelos, regras)
        print("\n===== EXEMPLO de texto gerado (grupo: %s; nao vai no plano) =====\n%s\n" % (g.get("nome"), exemplo or "FALHOU: %s" % err))

    os.makedirs(PLANOS, exist_ok=True)
    if a.ensaio:
        for p in partir(msg):
            avisar(p, ensaio=True)
        print("playbook: %d modelos, %d regras de grupos" % (len(modelos), len(regras)))
        return 0

    with open(os.path.join(PLANOS, "plano-%s.txt" % hoje.isoformat()), "w", encoding="utf-8") as f:
        f.write(msg + "\n")
    oks = [avisar(p) for p in partir(msg)]
    est["planos"][hoje.isoformat()] = {
        "em": iso(), "enviado": all(oks), "partes": len(oks),
        "adesao": [g.get("link") for _, g in adesao], "publicar": [g.get("link") for _, g in pub],
        "textos": textos_hoje, "tecto": tecto,
    }
    gravar_json(ESTADO, est)
    log("plano %s: adesao=%d publicar=%d tecto=%d candidatos=%d telegram=%s" % (
        hoje, len(adesao), len(pub), tecto, n_livres, oks))
    return 0 if all(oks) else 1


if __name__ == "__main__":
    sys.exit(main())
