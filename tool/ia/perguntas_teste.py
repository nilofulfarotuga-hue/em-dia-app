#!/usr/bin/env python3
"""
Prova do assistente IA (Edge Function `ia-responder`) com as 30 perguntas de docs/perguntas-teste.md.

Uso:
    python tool/ia/perguntas_teste.py                # corre as 30 e escreve docs/provas/ia/
    python tool/ia/perguntas_teste.py --so 4,18      # só algumas
    python tool/ia/perguntas_teste.py --intervalo 3  # segundos entre perguntas (defeito 3)

Lê:
  - docs/perguntas-teste.md (as perguntas, variante, regras a citar, esperado)
  - C:/BoraLocal/_segredos/em-dia/teste.env (TESTE_EMAIL, TESTE_PASSWORD)
  - <repo>/.dart_defines (SUPABASE_URL, SUPABASE_ANON_KEY)
Escreve (só aqui):
  - docs/provas/ia/<ii>-<slug>.md (uma prova por pergunta)
  - docs/provas/ia/RESUMO.md (tabela + totais; o SELECT de prova é colado à mão pelo executor)
  - docs/provas/ia/_run.log (log da corrida)

NUNCA escreve tokens, passwords ou chaves em ficheiro nem no log.
Só usa a biblioteca padrão (urllib) — o curl está bloqueado na sessão.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.request
from datetime import datetime, timezone, timedelta
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
PERGUNTAS_MD = REPO / 'docs' / 'perguntas-teste.md'
SAIDA = REPO / 'docs' / 'provas' / 'ia'
TESTE_ENV = Path(r'C:/BoraLocal/_segredos/em-dia/teste.env')
DART_DEFINES = REPO / '.dart_defines'
PROJETO = 'tgdmgtmknbwhcqoxtjbs'

RODAPE = 'Informação geral, não substitui contabilista.'
FRASE_NAO_CONFIRMADA = 'não tenho essa regra confirmada'

# ----------------------------------------------------------------------------
# Valores esperados por pergunta (calculados a partir de docs/perguntas-teste.md e
# supabase/migrations/20260905_0003_seed.sql). Cada grupo é uma lista de regex
# alternativas; a verificação (a) passa se TODOS os grupos tiverem pelo menos uma
# alternativa encontrada no texto da resposta (sem distinguir maiúsculas).
# ----------------------------------------------------------------------------
NUM_15000 = r'15\s?000|15\.000|15 mil|iva_isencao_limite'
NUM_18750 = r'18\s?750|18\.750|iva_isencao_perda_imediata'
ESPERADO: dict[int, list[list[str]]] = {
    1: [[r'12 meses', r'ss_isencao_meses'], [r'2027'], [r'dia 20', r'ss_pagamento_dia_fim']],
    2: [[NUM_15000], [NUM_18750], [r'15 dias úteis', r'iva_isencao_comunicacao_dias_uteis'], [r'23\s?%', r'iva_taxa_normal']],
    3: [[r'25\s?%', r'ss_ajuste_max'], [r'20\s?€', r'20 euros', r'ss_minimo_mensal']],
    4: [[r'ipo_ligeiros_anos', r'4, 6 e 8', r'4 anos', r'aos 4'], [r'2025', r'2027', r'2029'], [r'30 dias', r'30 e 7', r'ipo_avisos_dias']],
    5: [[r'M10', r'iva_mencao_isencao', r'artigo 53'], [r'23\s?%', r'retencao_padrao'], [NUM_15000.replace('iva_isencao_limite', 'retencao_dispensa_limite')]],
    6: [[r'23\s?%', r'retencao_padrao'], [r'25\s?%', r'retencao_opcao']],
    7: [[r'mês da matrícula', r'mes_da_matricula', r'iuc_regra']],
    8: [[r'75\s?%', r'0[.,]75', r'irs_coef_servicos'], [r'12\s?880', r'12\.880', r'irs_minimo_existencia']],
    9: [[r'M10', r'iva_mencao_isencao'], [r'artigo 53', r'art\.?\s?53', r'53\.º']],
    10: [[r'1 de abril', r'04-01', r'irs_entrega_inicio'], [r'30 de junho', r'06-30', r'irs_entrega_fim'], [r'25 de fevereiro', r'02-25', r'efatura_validar_ate']],
    11: [[r'15 anos', r'carta_validade'], [r'5 anos'], [r'2 anos', r'70']],
    12: [[r'dia 10', r'ss_pagamento_dia_inicio', r'dia 20', r'ss_pagamento_dia_fim'], [FRASE_NAO_CONFIRMADA]],
    13: [[NUM_15000], [NUM_18750]],
    14: [[r'20 de julho', r'07-20', r'irs_pagamentos_conta_datas'], [r'20 de setembro', r'09-20'], [r'20 de dezembro', r'12-20'], [r'65\s?%', r'irs_pagamentos_conta_pct']],
    15: [[r'15 dias úteis', r'multa_pagamento_voluntario_dias_uteis']],
    16: [[r'acordo', r'acordo_pt_br_url'], [r'15 anos', r'reforma_carreira_minima_anos'], [r'66 anos e 9 meses', r'66[.,]75', r'reforma_idade']],
    17: [[r'12 meses', r'ss_isencao_meses', r'13[.º°]?\s?mês']],
    18: [[FRASE_NAO_CONFIRMADA]],
    19: [[r'25 de fevereiro', r'02-25', r'efatura_validar_ate']],
    20: [[r'21[.,]4\s?%', r'ss_taxa'], [r'70\s?%', r'ss_base_servicos']],
    21: [[r'25\s?%', r'ss_ajuste_max'], [r'20\s?€', r'20 euros', r'ss_minimo_mensal']],
    22: [[NUM_15000], [NUM_18750], [r'15 dias úteis', r'iva_isencao_comunicacao_dias_uteis']],
    23: [[r'75\s?%', r'0[.,]75', r'irs_coef_servicos'], [r'15\s?%', r'0[.,]15', r'irs_coef_vendas']],
    24: [[r'45 dias', r'seguro_aviso_dias']],
    25: [[r'66 anos e 9 meses', r'66[.,]75', r'reforma_idade'], [r'15 anos', r'reforma_carreira_minima_anos']],
    26: [[r'11[.º°]?\s?dia', r'dia 11', r'baixa_doenca_dia_inicio'], [r'6 meses', r'baixa_doenca_prazo_garantia_meses']],
    27: [[r'360 dias', r'cessacao_atividade_prazo_garantia_dias'], [r'24 meses']],
    28: [[r'dia 5', r'recibos_comunicar_dia']],
    29: [[r'2022'], [r'2024'], [r'2026'], [r'anual', r'todos os anos', r'ipo_apos_8_anos']],
    30: [[r'5 anos', r'tvde_certificado_validade_anos']],
}

# Marcas de prazo/data para a verificação (b) — "Próximo passo:" tem de ter uma
PRAZO_RE = re.compile(
    r'(\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{2}-\d{2}|\d{1,2} de (janeiro|fevereiro|março|abril|maio|junho|julho|agosto|setembro|outubro|novembro|dezembro)'
    r'|\b(janeiro|fevereiro|março|abril|maio|junho|julho|agosto|setembro|outubro|novembro|dezembro)\b( de \d{4})?'
    r'|\d+\s?(dias?( úteis)?|semanas?|meses|mês|anos?)\b|\bdia \d{1,2}\b|\baté\b|\bantes d[eo]\b|\bhoje\b|\bamanhã\b|\bagora\b|\bjá\b'
    r'|\bquanto antes\b|\best[ae] (semana|mês|ano)\b|\bpróxim[oa] (semana|mês|ano|trimestre)\b|\bfim d[eo]\b|\bem \d+\b)',
    re.IGNORECASE,
)
PRAZO_FORTE_RE = re.compile(
    r'(\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{2}-\d{2}|\d{1,2} de (janeiro|fevereiro|março|abril|maio|junho|julho|agosto|setembro|outubro|novembro|dezembro)( de \d{4})?'
    r'|\b(janeiro|fevereiro|março|abril|maio|junho|julho|agosto|setembro|outubro|novembro|dezembro) de \d{4}'
    r'|\d+\s?(dias?( úteis)?|semanas?|meses|mês|anos?)\b|\bdia \d{1,2}\b)',
    re.IGNORECASE,
)
VOCE_RE = re.compile(r'\bvocê\b', re.IGNORECASE)
TU_RE = re.compile(r'\b(tu|tens|teu|tua|teus|tuas|tiveres|podes|deves|fazes|ficas|estás|abriste|passaste)\b', re.IGNORECASE)


# ----------------------------------------------------------------------------
def ler_env(caminho: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    for linha in caminho.read_text(encoding='utf-8').splitlines():
        linha = linha.strip()
        if not linha or linha.startswith('#') or '=' not in linha:
            continue
        k, v = linha.split('=', 1)
        out[k.strip()] = v.strip().strip('"').strip("'")
    return out


def ler_perguntas() -> list[dict]:
    """Lê as linhas da tabela de docs/perguntas-teste.md."""
    perguntas = []
    for linha in PERGUNTAS_MD.read_text(encoding='utf-8').splitlines():
        if not linha.startswith('|'):
            continue
        celulas = [c.strip() for c in linha.strip().strip('|').split('|')]
        if len(celulas) < 6 or not celulas[0].isdigit():
            continue
        n = int(celulas[0])
        pergunta = celulas[3].strip().strip('"')
        # tira os colchetes de contexto do guião ("[de 2026]") — a pergunta real vai sem eles
        pergunta_envio = re.sub(r'\s*\[[^\]]*\]', '', pergunta).strip()
        chaves = re.findall(r'`([a-z0-9_]+)`', celulas[4])
        perguntas.append({
            'n': n,
            'variante': 'br' if 'BR' in celulas[1].upper() else 'pt',
            'perfil': celulas[2],
            'pergunta_guiao': pergunta,
            'pergunta': pergunta_envio,
            'chaves': chaves,
            'esperado': celulas[5],
        })
    return perguntas


def slug(texto: str, max_palavras: int = 5) -> str:
    t = unicodedata.normalize('NFKD', texto).encode('ascii', 'ignore').decode()
    palavras = [p for p in re.sub(r'[^a-zA-Z0-9 ]', ' ', t).lower().split() if len(p) > 1]
    return '-'.join(palavras[:max_palavras]) or 'pergunta'


def agora_lisboa() -> str:
    # Europe/Lisbon em setembro = UTC+1 (hora de verão)
    return (datetime.now(timezone.utc) + timedelta(hours=1)).strftime('%Y-%m-%d %H:%M:%S') + ' (Lisboa)'


def http_json(url: str, corpo: dict | None, headers: dict, metodo: str = 'POST', timeout: int = 120):
    dados = json.dumps(corpo).encode('utf-8') if corpo is not None else None
    req = urllib.request.Request(url, data=dados, method=metodo)
    for k, v in headers.items():
        req.add_header(k, v)
    if dados is not None:
        req.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, r.read().decode('utf-8', 'replace')
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode('utf-8', 'replace')
    except Exception as e:  # timeout, rede
        return 0, f'EXCECAO {type(e).__name__}: {e}'


def login(base: str, anon: str, email: str, password: str) -> str:
    st, txt = http_json(f'{base}/auth/v1/token?grant_type=password', {'email': email, 'password': password}, {'apikey': anon})
    if st != 200:
        raise SystemExit(f'login falhou: HTTP {st} {txt[:300]}')
    tok = json.loads(txt).get('access_token')
    if not tok:
        raise SystemExit('login sem access_token')
    return tok


def perguntar(base: str, anon: str, jwt: str, pergunta: str, log, tentativas: int = 3, espera: int = 20):
    """Devolve (status, texto, tentativas_feitas, duracao_s). Em 429/503 espera e repete."""
    url = f'{base}/functions/v1/ia-responder'
    h = {'apikey': anon, 'Authorization': f'Bearer {jwt}'}
    st, txt, t = 0, '', 0
    for t in range(1, tentativas + 1):
        ini = time.time()
        st, txt = http_json(url, {'pergunta': pergunta}, h)
        dur = time.time() - ini
        log(f'    tentativa {t}: HTTP {st} em {dur:.1f}s')
        if st == 200:
            return st, txt, t, dur
        if st in (429, 503, 0) or st >= 500:
            if t < tentativas:
                log(f'    a esperar {espera}s antes de repetir…')
                time.sleep(espera)
            continue
        break  # 4xx que não vale a pena repetir
    return st, txt, t, 0.0


# ----------------------------------------------------------------------------
def verificar(p: dict, resposta: str, variante_api: str | None) -> dict:
    texto = resposta or ''
    baixo = texto.lower()
    # (a) valores/chaves esperados
    grupos = ESPERADO.get(p['n'], [])
    grupos_ok, grupos_falta, encontrados = 0, [], []
    for grupo in grupos:
        hit = None
        for alt in grupo:
            m = re.search(alt, texto, re.IGNORECASE)
            if m:
                hit = m.group(0)
                break
        if hit:
            grupos_ok += 1
            encontrados.append(hit)
        else:
            grupos_falta.append(' / '.join(grupo))
    chaves_citadas = [c for c in p['chaves'] if c in texto]
    a_ok = bool(grupos) and not grupos_falta

    # (b) "Próximo passo:" com prazo/data
    linhas = [l.strip() for l in texto.splitlines() if l.strip()]
    linha_pp = next((l for l in linhas if l.lower().startswith('próximo passo:') or l.lower().startswith('**próximo passo')), None)
    # a frase do próximo passo pode continuar na linha seguinte; junta até ao rodapé
    prazo = None
    if linha_pp:
        idx = linhas.index(linha_pp)
        bloco = ' '.join(l for l in linhas[idx:] if RODAPE not in l)
        alvo = bloco.split(':', 1)[1] if ':' in bloco else bloco
        # primeiro uma data/prazo explícito (forte); só depois as palavras fracas ("até", "já", …)
        m = PRAZO_FORTE_RE.search(alvo) or PRAZO_RE.search(alvo)
        prazo = m.group(0) if m else None
    b_ok = linha_pp is not None and prazo is not None

    # (c) variante
    esperada = p['variante']
    tem_voce = bool(VOCE_RE.search(texto))
    marcas_tu = TU_RE.findall(texto)
    if esperada == 'pt':
        c_ok = (variante_api == 'pt') and not tem_voce
    else:
        c_ok = (variante_api == 'br') and (tem_voce or not marcas_tu)
    # (d) rodapé
    d_ok = texto.rstrip().endswith(RODAPE)

    motivos = []
    if not a_ok:
        motivos.append('(a) faltam valores esperados: ' + ('; '.join(grupos_falta) if grupos_falta else 'sem grupos definidos'))
    if not b_ok:
        motivos.append('(b) ' + ('sem linha "Próximo passo:"' if not linha_pp else 'o "Próximo passo:" não tem prazo/data'))
    if not c_ok:
        motivos.append(f'(c) variante errada: esperada {esperada}, API devolveu {variante_api}, "você" no texto={tem_voce}, marcas tu={len(marcas_tu)}')
    if not d_ok:
        motivos.append('(d) não termina com o rodapé')
    return {
        'a_ok': a_ok, 'a_encontrados': encontrados, 'a_falta': grupos_falta, 'a_grupos': f'{grupos_ok}/{len(grupos)}',
        'chaves_citadas': chaves_citadas,
        'b_ok': b_ok, 'b_linha': linha_pp, 'b_prazo': prazo,
        'c_ok': c_ok, 'c_voce': tem_voce, 'c_tu': len(marcas_tu),
        'd_ok': d_ok,
        'veredito': 'PASSA' if (a_ok and b_ok and c_ok and d_ok) else 'FALHA',
        'motivos': motivos,
    }


def sim_nao(v: bool) -> str:
    return 'sim' if v else 'NÃO'


def escrever_prova(p: dict, hora: str, st: int, txt: str, tentativas: int, dur: float, ficheiro: Path) -> dict:
    """Escreve o .md da pergunta e devolve a linha de resumo."""
    corpo_json = None
    try:
        corpo_json = json.loads(txt) if txt else None
    except json.JSONDecodeError:
        corpo_json = None
    resumo = {'n': p['n'], 'pergunta': p['pergunta'], 'variante_esp': p['variante'], 'chaves': p['chaves'],
              'ficheiro': ficheiro.name, 'http': st, 'variante_api': None, 'fora': None, 'usadas': None, 'limite_valor': None}

    L = []
    L.append(f'# Pergunta {p["n"]:02d} — {p["pergunta_guiao"]}')
    L.append('')
    L.append(f'- **Data/hora:** {hora}')
    L.append(f'- **Perfil do guião:** {p["perfil"]} · **variante esperada:** {p["variante"].upper()}')
    L.append(f'- **Pergunta enviada (literal):** `{p["pergunta"]}`')
    L.append(f'- **Regras a citar (guião):** {", ".join("`" + c + "`" for c in p["chaves"]) or "—"}')
    L.append(f'- **Esperado (guião):** {p["esperado"]}')
    L.append(f'- **Chamada:** `POST /functions/v1/ia-responder` (apikey anon + Bearer JWT de teste@emdia.pt) · tentativas: {tentativas} · duração da última: {dur:.1f}s')
    L.append('')

    if st == 200 and isinstance(corpo_json, dict) and 'resposta' in corpo_json:
        resposta = corpo_json.get('resposta') or ''
        variante_api = corpo_json.get('variante')
        fora = corpo_json.get('fora_das_regras')
        resumo.update({'variante_api': variante_api, 'fora': fora, 'usadas': corpo_json.get('usadas'),
                       'limite_valor': corpo_json.get('limite_valor', corpo_json.get('limite')), 'cortada': corpo_json.get('cortada')})
        v = verificar(p, resposta, variante_api)
        resumo.update(v)
        L.append(f'## Resposta — HTTP {st}')
        L.append('')
        L.append(f'- **variante detetada:** `{variante_api}` · **fora_das_regras:** `{fora}` · **usadas:** `{corpo_json.get("usadas")}` · **limite_valor:** `{corpo_json.get("limite_valor", corpo_json.get("limite"))}`'
                 + (f' · **cortada:** `{corpo_json.get("cortada")}`' if 'cortada' in corpo_json else ''))
        extras = {k: corpo_json[k] for k in corpo_json if k not in ('resposta', 'variante', 'fora_das_regras', 'usadas', 'limite', 'limite_valor', 'cortada')}
        if extras:
            L.append(f'- **outros campos:** `{json.dumps(extras, ensure_ascii=False)}`')
        L.append('')
        L.append('### Resposta literal')
        L.append('')
        L.append('```text')
        L.append(resposta)
        L.append('```')
        L.append('')
        L.append('### JSON literal')
        L.append('')
        L.append('```json')
        L.append(json.dumps(corpo_json, ensure_ascii=False, indent=2))
        L.append('```')
        L.append('')
        L.append('## Verificação')
        L.append('')
        L.append(f'- **(a) cita as chaves/valores esperados?** {sim_nao(v["a_ok"])} — grupos encontrados {v["a_grupos"]}; encontrados: {", ".join("`" + e + "`" for e in v["a_encontrados"]) or "—"}'
                 + (f'; **em falta:** {"; ".join(v["a_falta"])}' if v['a_falta'] else '')
                 + f'; chaves do guião citadas no texto: {", ".join("`" + c + "`" for c in v["chaves_citadas"]) or "nenhuma"}')
        L.append(f'- **(b) termina com "Próximo passo:" e prazo/data?** {sim_nao(v["b_ok"])} — linha: `{v["b_linha"] or "—"}` · prazo detetado: `{v["b_prazo"] or "—"}`')
        L.append(f'- **(c) variante certa ({p["variante"].upper()})?** {sim_nao(v["c_ok"])} — API: `{variante_api}` · "você" no texto: {v["c_voce"]} · marcas de "tu" (tens/teu/podes…): {v["c_tu"]}')
        L.append(f'- **(d) rodapé "{RODAPE}"?** {sim_nao(v["d_ok"])}')
        L.append('')
        L.append(f'## Veredito: **{v["veredito"]}**')
        if v['motivos']:
            L.append('')
            for m in v['motivos']:
                L.append(f'- {m}')
    else:
        resumo['veredito'] = 'SEM RESPOSTA (quota)' if st in (429, 503, 0) else f'SEM RESPOSTA (HTTP {st})'
        resumo['motivos'] = [f'HTTP {st} após {tentativas} tentativas']
        L.append(f'## Resposta — HTTP {st} (sem resposta do modelo)')
        L.append('')
        L.append('```text')
        L.append(txt[:3000])
        L.append('```')
        L.append('')
        L.append(f'## Veredito: **{resumo["veredito"]}**')
        L.append('')
        L.append(f'- Não há resposta para verificar: HTTP {st} depois de {tentativas} tentativas (espera de 20 s entre elas). Nada foi inventado.')
    L.append('')
    ficheiro.write_text('\n'.join(L), encoding='utf-8')
    return resumo


def carregar_existente(p: dict, reescrever: bool = False) -> dict | None:
    """Se já existe uma prova com HTTP 200 para esta pergunta, reconstrói o resumo a partir
    do bloco "JSON literal" do ficheiro (poupa quota da Gemini ao retomar uma corrida)."""
    candidatos = sorted(SAIDA.glob(f'{p["n"]:02d}-*.md'))
    if not candidatos:
        return None
    ficheiro = candidatos[-1]
    texto = ficheiro.read_text(encoding='utf-8')
    m = re.search(r'### JSON literal\s*```json\n(.*?)\n```', texto, re.DOTALL)
    if not m:
        return None
    try:
        corpo = json.loads(m.group(1))
    except json.JSONDecodeError:
        return None
    if not isinstance(corpo, dict) or 'resposta' not in corpo:
        return None
    if reescrever:
        # refaz o .md com o mesmo JSON (verificação nova, sem gastar quota); mantém hora e tentativas originais
        mh = re.search(r'\*\*Data/hora:\*\* (.+)', texto)
        mt = re.search(r'tentativas: (\d+) · duração da última: ([\d.]+)s', texto)
        hora = mh.group(1).strip() if mh else agora_lisboa()
        tent = int(mt.group(1)) if mt else 1
        dur = float(mt.group(2)) if mt else 0.0
        r = escrever_prova(p, hora, 200, json.dumps(corpo, ensure_ascii=False), tent, dur, ficheiro)
        r['reaproveitada'] = True
        return r
    r = {'n': p['n'], 'pergunta': p['pergunta'], 'variante_esp': p['variante'], 'chaves': p['chaves'],
         'ficheiro': ficheiro.name, 'http': 200, 'variante_api': corpo.get('variante'), 'fora': corpo.get('fora_das_regras'),
         'usadas': corpo.get('usadas'), 'limite_valor': corpo.get('limite_valor', corpo.get('limite')), 'cortada': corpo.get('cortada'),
         'reaproveitada': True}
    r.update(verificar(p, corpo.get('resposta') or '', corpo.get('variante')))
    return r


def escrever_resumo(resumos: list[dict], inicio: str, fim: str, conversas: list[dict] | None):
    passa = sum(1 for r in resumos if r.get('veredito') == 'PASSA')
    falha = sum(1 for r in resumos if r.get('veredito') == 'FALHA')
    sem = sum(1 for r in resumos if str(r.get('veredito', '')).startswith('SEM RESPOSTA'))
    L = []
    L.append('# Prova — Assistente IA (`ia-responder`) com as 30 perguntas de `docs/perguntas-teste.md`')
    L.append('')
    L.append(f'- **Corrida:** {inicio} → {fim} · projeto `{PROJETO}` · utilizador `teste@emdia.pt` (plano efetivo `trial`, sem limite mensal)')
    L.append(f'- **Script:** `tool/ia/perguntas_teste.py` (Python, urllib; 3 s entre perguntas; em 429/503 espera 20 s e repete até 3×)')
    L.append(f'- **Critérios por pergunta:** (a) cita valores/chaves esperados · (b) linha "Próximo passo:" com prazo/data · (c) variante certa (PT-PT sem "você" / PT-BR com "você") · (d) rodapé "{RODAPE}". PASSA = os quatro.')
    L.append('')
    L.append('## Totais')
    L.append('')
    L.append(f'| PASSA | FALHA | SEM RESPOSTA |')
    L.append(f'|---|---|---|')
    L.append(f'| **{passa}** | **{falha}** | **{sem}** |')
    L.append('')
    L.append('## Tabela das 30')
    L.append('')
    L.append('| # | pergunta (curta) | variante esp./API | regra(s) esperada(s) | encontrada? | próximo passo? | veredito | prova |')
    L.append('|---|---|---|---|---|---|---|---|')
    for r in resumos:
        curta = r['pergunta'] if len(r['pergunta']) <= 55 else r['pergunta'][:52] + '…'
        chaves = ', '.join('`' + c + '`' for c in r['chaves'])
        if str(r.get('veredito', '')).startswith('SEM'):
            enc, pp = '—', '—'
        else:
            enc = f'{sim_nao(r["a_ok"])} ({r["a_grupos"]})'
            pp = sim_nao(r['b_ok']) + (f' ({r["b_prazo"]})' if r.get('b_prazo') else '')
        L.append(f'| {r["n"]} | {curta} | {r["variante_esp"]} / {r.get("variante_api") or "—"} | {chaves} | {enc} | {pp} | **{r.get("veredito")}** | [{r["ficheiro"]}]({r["ficheiro"]}) |')
    L.append('')
    falhas = [r for r in resumos if r.get('veredito') != 'PASSA']
    if falhas:
        L.append('## Perguntas que não passaram (motivo literal)')
        L.append('')
        for r in falhas:
            L.append(f'- **#{r["n"]}** ({r.get("veredito")}): ' + ' · '.join(r.get('motivos') or ['—']))
        L.append('')
    if conversas is not None:
        L.append('## `conversas_ia` lidas pelo próprio utilizador (PostgREST com o JWT de teste, RLS) — modelo e custo por pergunta')
        L.append('')
        if conversas:
            L.append('| criado_em (UTC) | modelo | variante | tokens_entrada | tokens_saida | custo_tokens (€) | fora_das_regras | pergunta |')
            L.append('|---|---|---|---|---|---|---|---|')
            for c in conversas:
                L.append(f'| {c.get("criado_em")} | {c.get("modelo")} | {c.get("variante")} | {c.get("tokens_entrada")} | {c.get("tokens_saida")} | {c.get("custo_tokens")} | {c.get("fora_das_regras")} | {str(c.get("pergunta"))[:60]} |')
            total = sum(float(c.get('custo_tokens') or 0) for c in conversas)
            L.append('')
            L.append(f'- Linhas: {len(conversas)} · custo somado: **{total:.6f} €**')
        else:
            L.append('_(a leitura por PostgREST não devolveu linhas — ver o SELECT abaixo, feito por SQL)_')
        L.append('')
    L.append('## SELECT de prova (executado por SQL no projeto, colado pelo executor)')
    L.append('')
    L.append('```sql')
    L.append("select count(*), sum(custo_tokens), min(criado_em), max(criado_em) from conversas_ia where criado_em > now() - interval '2 hours';")
    L.append('```')
    L.append('')
    L.append('<!-- RESULTADO_SQL -->')
    L.append('')
    (SAIDA / 'RESUMO.md').write_text('\n'.join(L), encoding='utf-8')
    return passa, falha, sem


def ler_conversas(base: str, anon: str, jwt: str, desde_iso: str) -> list[dict] | None:
    url = (f'{base}/rest/v1/conversas_ia?select=criado_em,modelo,variante,tokens_entrada,tokens_saida,custo_tokens,fora_das_regras,pergunta,modo'
           f'&modo=eq.chat&criado_em=gte.{desde_iso}&order=criado_em.asc')
    st, txt = http_json(url, None, {'apikey': anon, 'Authorization': f'Bearer {jwt}'}, metodo='GET')
    if st != 200:
        return None
    try:
        return json.loads(txt)
    except json.JSONDecodeError:
        return None


# ----------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--so', help='lista de números, ex. 1,2,18')
    ap.add_argument('--intervalo', type=float, default=3.0)
    ap.add_argument('--tentativas', type=int, default=3)
    ap.add_argument('--espera', type=int, default=20)
    ap.add_argument('--refazer', action='store_true', help='volta a perguntar mesmo que já exista prova com HTTP 200')
    ap.add_argument('--reescrever', action='store_true', help='refaz os .md e o RESUMO a partir do JSON já guardado (sem gastar quota)')
    ap.add_argument('--desde', help='ISO UTC (ex. 2026-09-06T08:25:00Z) a partir do qual ler conversas_ia; defeito = início desta corrida')
    args = ap.parse_args()

    # consola do Windows é cp1252 — força UTF-8 para não rebentar com "→", "…", etc.
    for canal in (sys.stdout, sys.stderr):
        try:
            canal.reconfigure(encoding='utf-8', errors='replace')
        except Exception:
            pass

    SAIDA.mkdir(parents=True, exist_ok=True)
    log_f = open(SAIDA / '_run.log', 'a', encoding='utf-8')

    def log(msg: str):
        linha = f'[{agora_lisboa()}] {msg}'
        print(linha, flush=True)
        log_f.write(linha + '\n')
        log_f.flush()

    env = ler_env(TESTE_ENV)
    dd = ler_env(DART_DEFINES)
    base = dd.get('SUPABASE_URL', f'https://{PROJETO}.supabase.co').rstrip('/')
    anon = dd['SUPABASE_ANON_KEY']
    email, password = env['TESTE_EMAIL'], env['TESTE_PASSWORD']

    perguntas = ler_perguntas()
    if args.so:
        quer = {int(x) for x in args.so.split(',')}
        perguntas = [p for p in perguntas if p['n'] in quer]
    log(f'início · {len(perguntas)} perguntas · base {base} · utilizador {email}')
    inicio = agora_lisboa()
    inicio_utc = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

    jwt = login(base, anon, email, password)
    log(f'login ok (JWT len={len(jwt)}, não se grava)')

    resumos = []
    for i, p in enumerate(perguntas):
        if not args.refazer:
            r = carregar_existente(p, reescrever=args.reescrever)
            if r is not None:
                resumos.append(r)
                log(f'#{p["n"]:02d} [{p["variante"]}] já tem prova com HTTP 200 ({r["ficheiro"]}) -> reaproveitada, veredito {r["veredito"]}')
                continue
        log(f'#{p["n"]:02d} [{p["variante"]}] {p["pergunta"]}')
        hora = agora_lisboa()
        st, txt, tent, dur = perguntar(base, anon, jwt, p['pergunta'], log, args.tentativas, args.espera)
        ficheiro = SAIDA / f'{p["n"]:02d}-{slug(p["pergunta"])}.md'
        r = escrever_prova(p, hora, st, txt, tent, dur, ficheiro)
        resumos.append(r)
        log(f'    -> {r.get("veredito")} · variante API={r.get("variante_api")} · fora={r.get("fora")} · {ficheiro.name}'
            + (f' · motivos: {" | ".join(r.get("motivos") or [])}' if r.get('motivos') else ''))
        if i < len(perguntas) - 1:
            time.sleep(args.intervalo)

    fim = agora_lisboa()
    conversas = ler_conversas(base, anon, jwt, args.desde or inicio_utc)
    passa, falha, sem = escrever_resumo(resumos, inicio, fim, conversas)
    log(f'fim · PASSA {passa} · FALHA {falha} · SEM RESPOSTA {sem} · RESUMO em {SAIDA / "RESUMO.md"}')
    log_f.close()


if __name__ == '__main__':
    main()
