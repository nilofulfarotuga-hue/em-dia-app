#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""B8 — Percorrer a app na web com a semântica ligada (Playwright, Chromium
«como pessoa»: User-Agent de Chrome e `--disable-blink-features=AutomationControlled`).

Duas partes:

  1. Entrar como o Danilo entraria, com a conta de teste boraappbora+teste:
     escreve o e-mail, pede o código, deixa o Turnstile INVISÍVEL trabalhar. Se
     ele pedir uma caixa para carregar («Verify you are human»), PARA — a regra
     da casa (e a do Danilo) é não completar CAPTCHAs; fica registado e passa-se
     à parte 2. Se o código chegar (lido pela API da Resend, com a chave que já
     é da app), escreve-o, faz o onboarding com o perfil do Danilo (TVDE,
     janeiro de 2024, isento de IVA, sem carro, 1.200 €/mês) e percorre a app.
  2. Percorrer a app inteira pelo modo exemplo («Vê como fica»), sem conta: as
     6 abas, os acessos do Mais, e as folhas — cada ecrã com captura e com a
     contagem de nós de semântica (flt-semantics) e de botões com nome.

Uso: python tool/provas/web_percorrer.py [--url https://app.emdia.boraguarda.com] [--email boraappbora+teste@gmail.com] [--sem-conta]
     python tool/provas/web_percorrer.py --entrar     <- abre um Chromium VISIVEL para a pessoa
        marcar a caixa do Turnstile e escrever o codigo; quando a app chegar ao painel
        guarda a sessao em C:/BoraLocal/_segredos/em-dia/sessao-teste.json (fora do repo).
     Com esse ficheiro presente, as corridas seguintes entram com a conta sem CAPTCHA.
Sai 0 se percorreu tudo (com ou sem conta); 2 se a parte 2 falhou.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import sys
import time
import urllib.request
from pathlib import Path

from playwright.sync_api import Page, sync_playwright

RAIZ = Path(__file__).resolve().parents[2]
UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
RESEND_KEY = Path(r"C:\BoraLocal\_segredos\em-dia\resend.key")
SESSAO = Path(r"C:\BoraLocal\_segredos\em-dia\sessao-teste.json")  # tokens: nunca no repo


def semantica(page: Page) -> dict:
    return page.evaluate(
        """() => ({
             nos: document.querySelectorAll('flt-semantics').length,
             botoes: Array.from(document.querySelectorAll("flt-semantics[role=button], flt-semantics[role=tab], flt-semantics[role=link], flt-semantics[flt-tappable]")).map(e => (e.getAttribute('aria-label') || e.textContent || '').trim()).filter(x => x).slice(0, 80),
             campos: document.querySelectorAll('flt-semantics input, flt-semantics textarea').length,
           })"""
    )


def espera_primeiro_frame(page: Page, timeout_ms: int = 60000) -> int | None:
    t0 = time.time()
    while (time.time() - t0) * 1000 < timeout_ms:
        try:
            if page.evaluate("!!window.__emDiaPrimeiroFrame"):
                return int((time.time() - t0) * 1000)
        except Exception:  # noqa: BLE001
            pass
        page.wait_for_timeout(200)
    return None


# No Flutter 3.47 (web) o rótulo de um botão NÃO vai em aria-label: fica como
# texto dentro do nó (<flt-semantics role="button"><span>Enviar código</span>).
TOCAVEIS = "flt-semantics[role='button'], flt-semantics[role='tab'], flt-semantics[role='link'], flt-semantics[flt-tappable]"


def nos_com_texto(page: Page, nome: str, prefixo: bool = False):
    """Botões pelo texto de dentro; separadores (role=tab) e nós com rótulo pelo aria-label."""
    padrao = re.compile("^" + re.escape(nome) + ("" if prefixo else "$"))
    por_texto = page.locator(TOCAVEIS, has_text=padrao)
    por_rotulo = page.locator(f"flt-semantics[aria-label{'^' if prefixo else ''}='{nome}']")
    return por_rotulo.or_(por_texto)


def botao(page: Page, nome: str, timeout_ms: int = 15000, prefixo: bool = False):
    """O nó de semântica tocável com este texto (botão, separador ou ligação)."""
    loc = nos_com_texto(page, nome, prefixo).first
    loc.wait_for(state="attached", timeout=timeout_ms)
    return loc


def clica(page: Page, nome: str, espera_ms: int = 900):
    b = botao(page, nome)
    b.scroll_into_view_if_needed(timeout=5000)
    b.click(timeout=10000, force=True)
    page.wait_for_timeout(espera_ms)


def clica_se_houver(page: Page, nome: str, espera_ms: int = 900, prefixo: bool = False) -> bool:
    try:
        loc = nos_com_texto(page, nome, prefixo).first
        loc.wait_for(state="attached", timeout=4000)
        loc.scroll_into_view_if_needed(timeout=3000)
        loc.click(timeout=5000, force=True)
        page.wait_for_timeout(espera_ms)
        return True
    except Exception:  # noqa: BLE001
        return False


def escreve(page: Page, texto: str):
    # O primeiro campo de texto da semântica (o Flutter põe um <input> por campo).
    campo = page.locator("flt-semantics input, flt-semantics textarea").first
    campo.wait_for(state="attached", timeout=15000)
    campo.click(force=True)
    campo.fill(texto)
    page.wait_for_timeout(400)


def codigo_na_resend(email: str, desde_ts: float) -> str | None:
    if not RESEND_KEY.exists():
        return None
    k = RESEND_KEY.read_text(encoding="utf-8").strip()
    req = urllib.request.Request("https://api.resend.com/emails?limit=10", headers={"Authorization": "Bearer " + k, "User-Agent": "em-dia-prova/1"})
    d = json.load(urllib.request.urlopen(req, timeout=20))
    for e in d.get("data", []):
        destinos = [t.lower() for t in (e.get("to") or [])]
        if email.lower() not in destinos:
            continue
        criado = e.get("created_at", "")[:19].replace("T", " ")
        try:
            ts = time.mktime(time.strptime(criado, "%Y-%m-%d %H:%M:%S")) - time.timezone
        except ValueError:
            ts = 0
        if ts < desde_ts - 60:
            continue
        r2 = urllib.request.Request("https://api.resend.com/emails/" + e["id"], headers={"Authorization": "Bearer " + k, "User-Agent": "em-dia-prova/1"})
        c = json.load(urllib.request.urlopen(r2, timeout=20))
        corpo = (c.get("text") or "") + " " + re.sub(r"<[^>]+>", " ", c.get("html") or "")
        m = re.search(r"\b(\d{6})\b", corpo)
        if m:
            return m.group(1)
    return None


def turnstile_pediu_caixa(page: Page) -> bool:
    """O invisível falhou e a app mostrou a caixa «Confirme que é humano»? A app
    diz-o por palavras («Não consegui confirmar que não és um robô») e a caixa
    vive num iframe da Cloudflare. Não se clica nela: regra da casa."""
    try:
        if page.locator("flt-semantics", has_text=re.compile("Não consegui confirmar que não és um robô")).count() > 0:
            return True
        for f in page.frames:
            if "challenges.cloudflare.com" in (f.url or ""):
                if f.locator("input[type=checkbox], #challenge-stage, .cb-lb").count() > 0:
                    return True
    except Exception:  # noqa: BLE001
        pass
    return False


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    ap.add_argument("--url", default="https://app.emdia.boraguarda.com")
    ap.add_argument("--email", default="boraappbora+teste@gmail.com")
    ap.add_argument("--sem-conta", action="store_true")
    ap.add_argument("--entrar", action="store_true", help="browser visível: a pessoa passa o Turnstile e o código; guarda a sessão")
    ap.add_argument("--saida", default=str(RAIZ / "provas" / "em-dia-tudo-2026-09-17" / "web"))
    a = ap.parse_args()
    saida = Path(a.saida)
    saida.mkdir(parents=True, exist_ok=True)
    ts = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    r: dict = {"quando": ts, "url": a.url, "conta": None, "ecras": [], "falhas": []}
    n = [0]

    def foto(page: Page, nome: str):
        n[0] += 1
        f = f"{n[0]:02d}-{nome}.png"
        page.screenshot(path=str(saida / f))
        s = semantica(page)
        r["ecras"].append({"ecra": nome, "foto": f, "semantica_nos": s["nos"], "botoes": len(s["botoes"]), "campos": s["campos"]})
        print(f"[{n[0]:02d}] {nome}: {s['nos']} nós, {len(s['botoes'])} botões, {s['campos']} campos")

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=not a.entrar, args=["--disable-blink-features=AutomationControlled"])
        ctx = browser.new_context(
            user_agent=UA, viewport={"width": 412, "height": 915}, locale="pt-PT",
            storage_state=str(SESSAO) if SESSAO.exists() else None,
        )
        page = ctx.new_page()
        page.goto(a.url + "/", wait_until="domcontentloaded")
        ttff = espera_primeiro_frame(page)
        r["ttff_ms"] = ttff
        page.wait_for_timeout(1500)
        foto(page, "entrada")

        if a.entrar:
            # A pessoa faz o que só a pessoa pode: a caixa do Turnstile e o código.
            print("Chromium aberto. Escreve o e-mail, marca a caixa «Confirme que é humano», envia e escreve o código. Eu espero até 10 min pelo painel…")
            for _ in range(600):
                if page.locator("flt-semantics[role=tab]").count() > 0:
                    break
                page.wait_for_timeout(1000)
            SESSAO.parent.mkdir(parents=True, exist_ok=True)
            ctx.storage_state(path=str(SESSAO))
            print(f"Sessão guardada em {SESSAO} (fora do repo).")
            r["conta"] = {"estado": "sessao_guardada"}
            a.sem_conta = True

        if SESSAO.exists() and not a.entrar and page.locator("flt-semantics[role=tab]").count() > 0:
            # Já entrou com a sessão guardada: percorre com a conta.
            r["conta"] = {"estado": "com_sessao_guardada"}
            foto(page, "conta-painel")
            for aba, nome in [("Recibos", "conta-recibos"), ("Dinheiro", "conta-dinheiro"), ("Agenda", "conta-agenda"), ("Carro", "conta-carro"), ("Mais", "conta-mais")]:
                if clica_se_houver(page, aba, 1500):
                    foto(page, nome)
            a.sem_conta = True
            ctx.clear_cookies()
            page.goto(a.url + "/", wait_until="domcontentloaded")
            espera_primeiro_frame(page)
            page.wait_for_timeout(1500)

        # ---------------- 1. entrar como o Danilo entraria ----------------
        if not a.sem_conta:
            t0 = time.time()
            try:
                escreve(page, a.email)
                foto(page, "entrada-email-escrito")
                clica(page, "Enviar código", 1500)
                # até 45 s: ou aparece o ecrã do código, ou o Turnstile pede a caixa
                estado = "a_esperar"
                for _ in range(45):
                    if turnstile_pediu_caixa(page):
                        estado = "turnstile_pediu_caixa"
                        break
                    if "verify" in page.url or nos_com_texto(page, "Entrar").count() > 0:
                        estado = "pede_codigo"
                        break
                    page.wait_for_timeout(1000)
                foto(page, f"depois-de-pedir-{estado}")
                r["conta"] = {"estado": estado}
                if estado == "turnstile_pediu_caixa":
                    r["conta"]["nota"] = "O Turnstile mostrou a caixa «Verify you are human». Não se clica em CAPTCHAs (regra): a entrada com conta fica para o Danilo/Chrome a sério."
                elif estado == "pede_codigo":
                    codigo = None
                    for _ in range(12):
                        codigo = codigo_na_resend(a.email, t0)
                        if codigo:
                            break
                        page.wait_for_timeout(5000)
                    r["conta"]["codigo_chegou"] = bool(codigo)
                    if codigo:
                        escreve(page, codigo)
                        clica_se_houver(page, "Entrar", 4000) or clica_se_houver(page, "Confirmar", 4000)
                        foto(page, "codigo-escrito")
                        # onboarding como o Danilo
                        if clica_se_houver(page, "Começar", 1200):
                            clica_se_houver(page, "Recibos verdes")
                            clica_se_houver(page, "Motorista TVDE (Uber, Bolt)")
                            foto(page, "onboarding-quando-abriste")
                            r["conta"]["nota"] = "Chegou ao onboarding com a conta de teste; os seletores de mês/ano são nativos do Flutter e ficam para a prova no emulador."
                else:
                    r["conta"]["nota"] = "Nem código nem caixa em 45 s (o invisível ainda a correr?)."
            except Exception as e:  # noqa: BLE001
                r["conta"] = {"estado": "erro", "erro": str(e)[:200]}
            page.goto(a.url + "/", wait_until="domcontentloaded")
            espera_primeiro_frame(page)
            page.wait_for_timeout(1500)

        # ---------------- 2. a app inteira pelo exemplo ----------------
        try:
            clica(page, "Vê como fica, com um exemplo", 2500)
            foto(page, "exemplo-painel")
            for aba, nome in [("Recibos", "exemplo-recibos"), ("Dinheiro", "exemplo-dinheiro"), ("Agenda", "exemplo-agenda"), ("Carro", "exemplo-carro"), ("Mais", "exemplo-mais")]:
                if clica_se_houver(page, aba, 1500):
                    foto(page, nome)
                else:
                    r["falhas"].append(f"aba {aba} não encontrada na semântica")
            for tile, nome in [("Vale a pena esta corrida?", "mais-vale-a-pena"), ("Fala comigo", "mais-fala"), ("O cofre do imposto", "mais-cofre"), ("Prova de rendimento", "mais-prova"), ("Fim da fidelização", "mais-radar"), ("Reforma e direitos", "mais-reforma"), ("Guias de 1 minuto", "mais-guias"), ("Pergunta ao Em Dia", "mais-pergunta"), ("Ajuda", "mais-ajuda"), ("O teu plano", "mais-plano"), ("Definições", "mais-definicoes")]:
                achou = clica_se_houver(page, tile, 1500, prefixo=True)
                if achou:
                    foto(page, nome)
                    page.go_back()
                    page.wait_for_timeout(900)
                    if not clica_se_houver(page, "Mais", 900):
                        pass
                else:
                    r["falhas"].append(f"acesso «{tile}» não encontrado na semântica")
        except Exception as e:  # noqa: BLE001
            r["falhas"].append(f"exemplo: {str(e)[:200]}")
        browser.close()

    ok = not r["falhas"]
    md = [f"# Percurso na web — {ts} ({'PASSOU' if ok else 'COM FALHAS'})", "", f"URL: `{a.url}` · primeiro ecrã aos {r['ttff_ms']} ms · Chromium do Playwright, UA de Chrome, sem `navigator.webdriver`.", ""]
    md += ["## Conta de teste", "", f"`{json.dumps(r['conta'], ensure_ascii=False)}`", ""]
    md += ["## Ecrãs percorridos (semântica ligada)", "", "| # | Ecrã | Nós flt-semantics | Botões com nome | Campos | Foto |", "|---|---|---|---|---|---|"]
    md += [f"| {i + 1} | {e['ecra']} | {e['semantica_nos']} | {e['botoes']} | {e['campos']} | `{e['foto']}` |" for i, e in enumerate(r["ecras"])]
    md += [""]
    if r["falhas"]:
        md += ["## Falhas", ""] + [f"- {f}" for f in r["falhas"]] + [""]
    (saida / "RELATORIO.md").write_text("\n".join(md), encoding="utf-8")
    (saida / "resultado.json").write_text(json.dumps(r, ensure_ascii=False, indent=2), encoding="utf-8")
    print("\n".join(md))
    return 0 if ok else 2


if __name__ == "__main__":
    sys.exit(main())
