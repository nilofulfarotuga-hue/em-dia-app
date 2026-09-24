#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Gera as 3 ferramentas públicas do site (site/ferramentas/*.html) e as imagens de
pré-visualização (site/assets/img/og-*.jpg, 1200x630) — missão em-dia-crescimento-organico
(2026-09-24). Sem registo, resultado na hora, botão «partilha com um colega» e, no fim,
«Guarda isto e recebe aviso dos prazos → Regista grátis».

As contas são as do site/assets/js/calc.js (porta exata dos cálculos da app, com os números
oficiais de 2026 e a fonte em cada um). Uso: python tool/site/gerar_ferramentas.py
"""
import os

from PIL import Image, ImageDraw, ImageFont

RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SITE = os.path.join(RAIZ, "site")
FER = os.path.join(SITE, "ferramentas")
IMG = os.path.join(SITE, "assets", "img")
FONTE = os.path.join(SITE, "assets", "fonts", "Inter-VariableFont.ttf")
APP = "https://app.emdia.boraguarda.com"
DOM = "https://emdia.boraguarda.com"

VERDE, VERDE_ESC, LARANJA, BRANCO, CINZA = (22, 163, 74), (6, 95, 70), (249, 115, 22), (255, 255, 255), (220, 252, 231)

FERRAMENTAS = [
    {
        "slug": "recibo-verde",
        "titulo": "Quanto fica mesmo do meu recibo verde?",
        "seo_titulo": "Calcular recibo verde 2026: quanto fica na conta com retenção de 23% e IVA — Em Dia",
        "descricao": "Calculadora de recibo verde grátis e sem registo: escreve o valor e vê na hora o IVA, a retenção na fonte (23%, 25% ou dispensa) e o que entra mesmo na tua conta. Números oficiais de 2026.",
        "og": "Quanto fica mesmo\ndo teu recibo verde?",
        "og_sub": "Retenção 23% · IVA · o que entra na conta — em 5 segundos, grátis",
        "chaves": "calcular recibo verde, retenção na fonte 23%, recibo verde IVA, quanto recebo recibo verde",
        "intro": "Escreve o valor do serviço e vê na hora quanto entra na tua conta, com a retenção na fonte e o IVA já contados. Grátis, sem registo, com os números oficiais de 2026.",
        "form": """
<label class="campo">Valor do serviço (sem IVA)
  <input id="valor" type="text" inputmode="decimal" placeholder="por exemplo 800" autocomplete="off">
</label>
<fieldset class="campo"><legend>Retenção na fonte</legend>
  <label><input type="radio" name="ret" value="padrao" checked> 23 % (padrão)</label>
  <label><input type="radio" name="ret" value="vinteCinco"> 25 % (por opção)</label>
  <label><input type="radio" name="ret" value="dispensa"> Dispensa (faturaste menos de 15 000 € no ano passado)</label>
</fieldset>
<fieldset class="campo"><legend>IVA</legend>
  <label><input type="radio" name="iva" value="isento" checked> Isento (artigo 53.º — até 15 000 €/ano)</label>
  <label><input type="radio" name="iva" value="normal"> 23 % (regime normal)</label>
</fieldset>""",
        "js": """
function calcular(){
  var v=C.lerNumero(document.getElementById('valor').value); if(!(v>0)){mostrar('');return;}
  var ret=document.querySelector('input[name=ret]:checked').value;
  var isento=document.querySelector('input[name=iva]:checked').value==='isento';
  var r=C.calcularRecibo(v,ret,isento,C.REGRAS_SEED);
  var h='<div class="grande"><span>Entra na tua conta</span><strong>'+C.moeda(r.recebesNaConta,true)+'</strong></div>'
   +'<ul class="linhas"><li>Valor do serviço <b>'+C.moeda(r.valorSemIva,true)+'</b></li>'
   +'<li>IVA ('+r.taxaIvaPct+' %) <b>'+C.moeda(r.iva,true)+'</b></li>'
   +'<li>Total da fatura <b>'+C.moeda(r.totalFatura,true)+'</b></li>'
   +'<li>Retenção na fonte ('+r.taxaRetencaoPct+' %) <b>− '+C.moeda(r.retencao,true)+'</b></li>'
   +'<li>Fica teu, sem o IVA <b>'+C.moeda(r.ficaTeu,true)+'</b></li></ul>'
   +(r.mencaoIsencao?'<p class="nota">No recibo escreve: <code>'+r.mencaoIsencao+'</code></p>':'')
   +'<p class="nota">A retenção não é dinheiro perdido: é IRS pago à cabeça, que se acerta na declaração de abril a junho.</p>';
  mostrar(h);
}""",
        "faq": [
            ("A retenção de 23 % é obrigatória?", "É a regra quando o cliente é uma empresa com contabilidade organizada. Podes pedir dispensa se no ano anterior faturaste menos de 15 000 € (CIRS art. 101.º; DL 28/2019)."),
            ("Estou isento de IVA, o que escrevo?", "A menção obrigatória «IVA - regime de isenção [artigo 53.º do CIVA]». A isenção vale até 15 000 € de faturação por ano; acima de 18 750 € perde-se logo."),
            ("Isto substitui o contabilista?", "Não. É informação geral com os números oficiais de 2026 (fonte em cada regra). Casos especiais são para o contabilista."),
        ],
    },
    {
        "slug": "irs-do-mes",
        "titulo": "Quanto guardar para o IRS este mês?",
        "seo_titulo": "Quanto guardar para o IRS a recibos verdes (2026): calculadora grátis por mês — Em Dia",
        "descricao": "Diz quanto ganhas por mês a recibos verdes e vê quanto deves pôr de lado para o IRS, com os escalões de 2026 e o regime simplificado. Grátis, sem registo.",
        "og": "Quanto guardar\npara o IRS este mês?",
        "og_sub": "Recibos verdes · regime simplificado · escalões 2026 — grátis, sem registo",
        "chaves": "irs recibos verdes, quanto guardar irs, regime simplificado irs 2026, irs trabalhador independente",
        "intro": "Escreve o que ganhas por mês (média) a recibos verdes. A ferramenta estima o IRS do ano pelo regime simplificado e divide por 12: é o que deves guardar todos os meses para não levares susto em abril.",
        "form": """
<label class="campo">Quanto ganhas por mês, em média (sem IVA)
  <input id="valor" type="text" inputmode="decimal" placeholder="por exemplo 1200" autocomplete="off">
</label>
<fieldset class="campo"><legend>O que fazes</legend>
  <label><input type="radio" name="tipo" value="servicos" checked> Serviços (TVDE, estafeta, freelancer, cabeleireira, obras…)</label>
  <label><input type="radio" name="tipo" value="vendas"> Vendas de produtos</label>
</fieldset>""",
        "js": """
function calcular(){
  var v=C.lerNumero(document.getElementById('valor').value); if(!(v>0)){mostrar('');return;}
  var tipo=document.querySelector('input[name=tipo]:checked').value;
  var r=C.calcularIrs(v*12,tipo,2026,C.REGRAS_SEED,C.ESCALOES_SEED);
  var h='<div class="grande"><span>Guarda por mês para o IRS</span><strong>'+C.moeda(r.guardarPorMes,true)+'</strong></div>'
   +'<ul class="linhas"><li>Rendimento do ano <b>'+C.moeda(r.rendimentoBrutoAnual,true)+'</b></li>'
   +'<li>Rendimento coletável (coeficiente '+String(r.coeficiente).replace('.',',')+') <b>'+C.moeda(r.rendimentoColetavel,true)+'</b></li>'
   +'<li>IRS estimado no ano <b>'+C.moeda(r.impostoEstimado,true)+'</b></li>'
   +'<li>Taxa efetiva <b>'+C.pct(r.taxaEfetivaPct,1)+'</b></li></ul>'
   +(r.abaixoMinimoExistencia?'<p class="nota">Abaixo do mínimo de existência (12 880 €): a estimativa de IRS é zero.</p>':'')
   +(r.justificarDespesas?'<p class="nota">Acima de 27 360 € tens de justificar 15 % de despesas com atividade — fala com o contabilista.</p>':'')
   +'<p class="nota">Estimativa pelo regime simplificado, sem deduções pessoais nem retenções já feitas. As tabelas de retenção e os escalões de 2026 podem ser confirmados no Portal das Finanças.</p>';
  mostrar(h);
}""",
        "faq": [
            ("O que é o regime simplificado?", "O Estado considera que só 75 % do que ganhas em serviços (15 % nas vendas) é lucro e aplica os escalões de IRS a essa parte (CIRS art. 31.º)."),
            ("Já me retêm 23 % nos recibos, guardo na mesma?", "A retenção conta como IRS já pago. Se a maior parte dos teus clientes retém, o que guardas pode ser menor — a app faz essa conta com os teus recibos reais."),
            ("Quando se paga?", "A declaração entrega-se de 1 de abril a 30 de junho; quem tem rendimentos altos paga por conta em julho, setembro e dezembro."),
        ],
    },
    {
        "slug": "seguranca-social",
        "titulo": "Quanto pago à Segurança Social?",
        "seo_titulo": "Segurança Social trabalhador independente 2026: quanto pagas por mês (21,4 %) — calculadora grátis — Em Dia",
        "descricao": "Calcula a contribuição mensal para a Segurança Social a recibos verdes: 21,4 % sobre 70 % do rendimento (serviços) ou 20 % (vendas), mínimo 20 €. Grátis, sem registo, números oficiais de 2026.",
        "og": "Quanto pagas\nà Segurança Social?",
        "og_sub": "Recibos verdes · 21,4 % sobre 70 % · mínimo 20 € — grátis, sem registo",
        "chaves": "segurança social trabalhador independente, contribuição segurança social recibos verdes, 21,4% segurança social, declaração trimestral",
        "intro": "Escreve o que faturaste nos últimos 3 meses (ou a média mensal) e vê quanto vais pagar por mês à Segurança Social, com a regra dos 21,4 % sobre 70 % do rendimento. Grátis, sem registo.",
        "form": """
<label class="campo">Rendimento por mês, em média (sem IVA)
  <input id="valor" type="text" inputmode="decimal" placeholder="por exemplo 1200" autocomplete="off">
</label>
<fieldset class="campo"><legend>O que fazes</legend>
  <label><input type="radio" name="tipo" value="servicos" checked> Serviços</label>
  <label><input type="radio" name="tipo" value="vendas"> Vendas de produtos</label>
</fieldset>
<label class="campo">Ajuste que escolheste na declaração trimestral (−25 % a +25 %)
  <input id="ajuste" type="number" min="-25" max="25" step="5" value="0">
</label>""",
        "js": """
function calcular(){
  var v=C.lerNumero(document.getElementById('valor').value); if(!(v>0)){mostrar('');return;}
  var tipo=document.querySelector('input[name=tipo]:checked').value;
  var aj=parseInt(document.getElementById('ajuste').value||'0',10)||0;
  var r=C.estimarSSMensal(v,tipo,aj,C.REGRAS_SEED);
  var h='<div class="grande"><span>Pagas por mês à Segurança Social</span><strong>'+C.moeda(r.contribuicaoMensal,true)+'</strong></div>'
   +'<ul class="linhas"><li>Rendimento relevante (70 % ou 20 %) <b>'+C.moeda(r.rendimentoMensalRelevante,true)+'</b></li>'
   +'<li>Base de incidência (com o ajuste de '+r.ajustePct+' %) <b>'+C.moeda(r.baseIncidencia,true)+'</b></li>'
   +'<li>Taxa <b>21,4 %</b></li><li>No trimestre <b>'+C.moeda(r.contribuicaoTrimestre,true)+'</b></li></ul>'
   +(r.bateuNoMinimo?'<p class="nota">Ficaste no mínimo legal de 20 € por mês.</p>':'')
   +(r.bateuNoMaximo?'<p class="nota">Bateste no teto (12 vezes o IAS).</p>':'')
   +'<p class="nota">Paga-se entre o dia 10 e o dia 20 do mês seguinte. A declaração trimestral é até ao último dia de janeiro, abril, julho e outubro. No 1.º ano de atividade há isenção de 12 meses.</p>';
  mostrar(h);
}""",
        "faq": [
            ("Abri atividade há pouco: já pago?", "Não. No primeiro ano há isenção de 12 meses (CRC art. 145.º). Mas o prazo acaba — e ninguém avisa; a app avisa."),
            ("Como se faz a conta?", "21,4 % sobre 70 % do rendimento médio mensal do trimestre (serviços) ou 20 % (vendas), com ajuste de ±25 % à escolha; mínimo 20 €/mês; teto 12 vezes o IAS (CRC art. 162.º e 168.º)."),
            ("Quando pago?", "Entre o dia 10 e o dia 20 de cada mês (CRC art. 155.º). A declaração trimestral é em janeiro, abril, julho e outubro."),
        ],
    },
]

CSS = """
@font-face{font-family:Inter;src:url(/assets/fonts/Inter.woff2) format("woff2"),url(/assets/fonts/Inter-VariableFont.ttf) format("truetype");font-weight:100 900;font-display:swap}
*{box-sizing:border-box}
body{margin:0;font-family:Inter,system-ui,sans-serif;font-size:19px;line-height:1.55;color:#111827;background:#F6F7F4}
.topo{border-bottom:1px solid #E5E7EB;background:#fff}
.topo .c{display:flex;align-items:center;justify-content:space-between;min-height:68px}
.c{width:min(860px,100% - 40px);margin-inline:auto}
.marca{display:inline-flex;align-items:center;gap:10px;font-weight:800;font-size:22px;text-decoration:none;color:#111827}
.marca img{width:36px;height:36px;border-radius:10px}
.topo a.volta{color:#15803D;font-weight:700;text-decoration:none;min-height:48px;display:inline-flex;align-items:center}
main{padding:36px 0 80px}
h1{font-size:clamp(32px,6vw,52px);font-weight:900;letter-spacing:-.035em;line-height:1.05;margin:0 0 12px}
h2{font-size:26px;font-weight:800;letter-spacing:-.02em;margin:40px 0 12px}
p,li{margin:0 0 12px;color:#1F2937}
a{color:#15803D}
:focus-visible{outline:3px solid #111827;outline-offset:3px;border-radius:6px}
.lead{font-size:clamp(19px,2.6vw,24px);color:#065F46;font-weight:700;margin-bottom:24px}
.caixa{background:#fff;border:1px solid #E5E7EB;border-radius:20px;padding:22px;box-shadow:0 2px 8px rgba(15,23,42,.08)}
.campo{display:block;margin:0 0 16px;font-weight:700}
.campo input[type=text],.campo input[type=number]{display:block;width:100%;margin-top:6px;font:inherit;font-size:24px;font-weight:800;padding:12px 14px;border:2px solid #D1D5DB;border-radius:14px}
.campo input:focus{border-color:#16A34A}
fieldset.campo{border:0;padding:0}
fieldset.campo legend{font-weight:800;margin-bottom:6px}
fieldset.campo label{display:flex;gap:10px;align-items:center;font-weight:600;padding:6px 0;min-height:44px}
fieldset.campo input{width:22px;height:22px;accent-color:#16A34A}
.resultado{margin-top:8px}
.grande{background:#DCFCE7;border-radius:16px;padding:18px 20px;margin:8px 0 14px;display:flex;flex-direction:column}
.grande span{font-size:15px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;color:#065F46}
.grande strong{font-size:clamp(34px,7vw,50px);font-weight:900;letter-spacing:-.04em;color:#111827;line-height:1.1}
.linhas{list-style:none;padding:0;margin:0 0 10px;display:grid;gap:6px}
.linhas li{display:flex;justify-content:space-between;gap:12px;border-bottom:1px dashed #E5E7EB;padding:6px 0}
.nota{font-size:15px;color:#4B5563;margin:8px 0 0}
code{background:#F3F4F6;padding:2px 6px;border-radius:6px;font-size:15px}
.cta{background:#ECFDF5;border:2px solid #16A34A;border-radius:18px;padding:20px;margin:28px 0}
.cta p{font-weight:800;color:#065F46;font-size:21px}
.btn{display:inline-flex;align-items:center;justify-content:center;min-height:56px;padding:12px 22px;border-radius:16px;font-weight:800;text-decoration:none;border:2px solid #16A34A;color:#15803D;background:#fff;gap:8px;cursor:pointer;font:inherit;font-size:18px;font-weight:800}
.btn.verde{background:#16A34A;color:#fff}
.btns{display:flex;flex-wrap:wrap;gap:12px}
.faq details{border-bottom:1px solid #E5E7EB;background:#fff;padding:0 18px}
.faq details:first-child{border-radius:16px 16px 0 0}
.faq details:last-child{border-radius:0 0 16px 16px;border-bottom:0}
.faq summary{list-style:none;cursor:pointer;padding:16px 0;font-weight:800;display:flex;justify-content:space-between;gap:16px}
.faq summary::-webkit-details-marker{display:none}
.faq summary::after{content:"+";font-size:26px;color:#16A34A}
.faq details[open] summary::after{content:"−"}
.faq .resposta{padding:0 0 16px;color:#4B5563}
.outras a{display:block;padding:12px 0;border-bottom:1px solid #E5E7EB;font-weight:700;text-decoration:none}
.rodape{font-size:14px;color:#6B7280;margin-top:40px}
"""


def pagina(f):
    url = "%s/ferramentas/%s.html" % (DOM, f["slug"])
    og = "%s/assets/img/og-%s.jpg" % (DOM, f["slug"])
    faq_json = ",".join(
        '{"@type":"Question","name":%s,"acceptedAnswer":{"@type":"Answer","text":%s}}' % (j(q), j(a)) for q, a in f["faq"])
    faq_html = "".join('<details><summary>%s</summary><div class="resposta">%s</div></details>' % (q, a) for q, a in f["faq"])
    outras = "".join('<a href="/ferramentas/%s.html">%s →</a>' % (o["slug"], o["titulo"]) for o in FERRAMENTAS if o["slug"] != f["slug"])
    txt_partilha = "%s Vê aqui, é grátis e sem registo: %s" % (f["titulo"], url)
    return """<!DOCTYPE html>
<html lang="pt-PT">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script>(function(){if(location.hostname==='em-dia-site.pages.dev'){location.replace('https://emdia.boraguarda.com'+location.pathname+location.search+location.hash);}})();</script>
<title>%(seo_titulo)s</title>
<meta name="description" content="%(descricao)s">
<meta name="keywords" content="%(chaves)s">
<link rel="canonical" href="%(url)s">
<link rel="icon" href="/assets/img/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/img/favicon-32.png" sizes="32x32">
<link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png">
<meta property="og:type" content="website">
<meta property="og:locale" content="pt_PT">
<meta property="og:site_name" content="Em Dia">
<meta property="og:title" content="%(titulo)s">
<meta property="og:description" content="%(descricao)s">
<meta property="og:url" content="%(url)s">
<meta property="og:image" content="%(og)s">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="%(titulo)s">
<meta name="twitter:description" content="%(descricao)s">
<meta name="twitter:image" content="%(og)s">
<meta name="theme-color" content="#16A34A">
<script type="application/ld+json">{"@context":"https://schema.org","@graph":[{"@type":"WebApplication","name":%(titulo_j)s,"url":"%(url)s","applicationCategory":"FinanceApplication","operatingSystem":"Web","offers":{"@type":"Offer","price":"0","priceCurrency":"EUR"},"inLanguage":"pt-PT","publisher":{"@type":"Organization","name":"Em Dia","url":"%(dom)s/"}},{"@type":"FAQPage","mainEntity":[%(faq_json)s]}]}</script>
<style>%(css)s</style>
</head>
<body>
<header class="topo"><div class="c">
  <a class="marca" href="/"><img src="/assets/img/icon-512.png" alt="" width="36" height="36">Em Dia</a>
  <a class="volta" href="/#calculadora">Todas as ferramentas</a>
</div></header>
<main><div class="c">
  <h1>%(titulo)s</h1>
  <p class="lead">%(intro)s</p>
  <div class="caixa">
    <form id="f" onsubmit="event.preventDefault();calcular();">
      %(form)s
      <button class="btn verde" type="submit">Ver o resultado</button>
    </form>
    <div class="resultado" id="res" aria-live="polite"></div>
  </div>
  <div class="cta">
    <p>Guarda isto e recebe aviso dos prazos da Segurança Social, do IVA e do IRS — antes de levares multa.</p>
    <div class="btns">
      <a class="btn verde" href="%(app)s/?de=ferramenta-%(slug)s">Regista grátis, sem cartão</a>
      <button class="btn" type="button" id="partilha">Partilha com um colega</button>
    </div>
  </div>
  <h2>Perguntas de quem faz esta conta</h2>
  <div class="faq">%(faq_html)s</div>
  <h2>Outras contas rápidas</h2>
  <div class="outras">%(outras)s</div>
  <p class="rodape">Números oficiais de 2026 (Código Contributivo, CIRS, CIVA; fonte em cada regra na app). Informação geral: não substitui o contabilista. Em Dia — Guarda, Portugal.</p>
</div></main>
<script src="/assets/js/calc.js"></script>
<script>
var C=window.EmDiaCalc;
function mostrar(h){document.getElementById('res').innerHTML=h;}
%(js)s
document.getElementById('f').addEventListener('input',calcular);
document.getElementById('partilha').addEventListener('click',function(){
  var t=%(txt_partilha_j)s;
  if(navigator.share){navigator.share({title:%(titulo_j)s,text:t,url:%(url_j)s}).catch(function(){});}
  else{location.href='https://wa.me/?text='+encodeURIComponent(t);}
});
</script>
</body>
</html>
""" % dict(f, url=url, og=og, dom=DOM, app=APP, css=CSS, faq_json=faq_json, faq_html=faq_html, outras=outras,
           titulo_j=j(f["titulo"]), url_j=j(url), txt_partilha_j=j(txt_partilha))


def j(s):
    import json
    return json.dumps(s, ensure_ascii=False)


def fonte(tam, peso=800):
    f = ImageFont.truetype(FONTE, tam)
    try:
        f.set_variation_by_axes([peso])
    except Exception:
        pass
    return f


def og_imagem(f):
    im = Image.new("RGB", (1200, 630), VERDE_ESC)
    d = ImageDraw.Draw(im)
    # faixa verde clara à esquerda + bolha laranja
    d.rounded_rectangle([40, 40, 1160, 590], radius=40, fill=VERDE)
    d.ellipse([980, -80, 1300, 240], fill=LARANJA)
    y = 120
    for ln in f["og"].split("\n"):
        d.text((90, y), ln, font=fonte(78, 900), fill=BRANCO)
        y += 92
    d.text((90, y + 26), f["og_sub"], font=fonte(30, 700), fill=CINZA)
    # rodapé: marca + promessa
    d.rounded_rectangle([90, 470, 560, 540], radius=35, fill=BRANCO)
    d.text((118, 484), "Em Dia · grátis, sem registo", font=fonte(30, 800), fill=VERDE_ESC)
    d.text((600, 486), "emdia.boraguarda.com", font=fonte(28, 700), fill=BRANCO)
    im.save(os.path.join(IMG, "og-%s.jpg" % f["slug"]), "JPEG", quality=90)


def main():
    os.makedirs(FER, exist_ok=True)
    for f in FERRAMENTAS:
        with open(os.path.join(FER, f["slug"] + ".html"), "w", encoding="utf-8", newline="\n") as fh:
            fh.write(pagina(f))
        og_imagem(f)
        print("ferramenta", f["slug"])
    # índice das ferramentas
    with open(os.path.join(FER, "index.html"), "w", encoding="utf-8", newline="\n") as fh:
        lista = "".join('<a href="/ferramentas/%s.html">%s →</a>' % (f["slug"], f["titulo"]) for f in FERRAMENTAS)
        fh.write("""<!DOCTYPE html><html lang="pt-PT"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Ferramentas grátis para recibos verdes: recibo, IRS e Segurança Social — Em Dia</title>
<meta name="description" content="Três contas rápidas, grátis e sem registo, para quem trabalha a recibos verdes em Portugal: quanto fica do recibo, quanto guardar para o IRS e quanto pagar à Segurança Social.">
<link rel="canonical" href="%s/ferramentas/"><meta property="og:image" content="%s/assets/img/og-recibo-verde.jpg"><style>%s</style></head>
<body><header class="topo"><div class="c"><a class="marca" href="/"><img src="/assets/img/icon-512.png" alt="" width="36" height="36">Em Dia</a></div></header>
<main><div class="c"><h1>Contas rápidas, grátis e sem registo</h1><p class="lead">Para quem trabalha por conta própria em Portugal. Escreve um número e vê o resultado na hora.</p>
<div class="outras">%s</div></div></main></body></html>
""" % (DOM, DOM, CSS, lista))
    print("indice ok")


if __name__ == "__main__":
    main()
