# Prompt longo — site público Em Dia (passo 3 do funil `site-premio`)

> Escrito 2026-09-06 antes do HTML. Guarda-se porque a segunda ronda (passo 6) precisa dele.
> Referências (passo 1): `docs/referencias/` (MEI Fácil, MaisMei, Drivvo, Rocket Money) e o texto de
> appartur.pt indexado (concorrente direto; ver `site/referencias/LEIA-ME.md`).

## Classificador (§2 da skill)

```
NÍVEL: 2 (profissional) + calculadora funcional (é o que traz gente da Google)
BLOCOS OBRIGATÓRIOS: herói com vídeo e 2 CTA iguais · 4 sustos com números da tabela regras_legais ·
  calculadora (recibo + quanto guardar) · como funciona (3 passos) · capturas reais com moldura ·
  preços (Grátis/Pro/Família lidos de regras_legais) · FAQ 6 perguntas com JSON-LD · rodapé legal + privacidade
FICA DE FORA: multi-idioma, blog, login no site, chat IA no site, domínio próprio, vídeo definitivo (Bora Studio)
ELEMENTO ASSINATURA: o herói em vídeo (capturas reais da app a sangrar) — um só
```

## Quem, o quê, para quem, onde
Em Dia — app do trabalhador independente a recibos verdes e do carro, Portugal. Público: TVDE, estafetas,
serviços, freelancers, brasileiros recém-chegados. **Pouco digital**: letras grandes, um CTA por bloco,
tom "tu", frases de criança de 5 anos, jargão só com explicação entre parênteses.
**Objetivo comercial em uma frase:** a pessoa calcula o recibo (confia) e carrega num dos dois botões
(Play Store ou app web) — os dois com o MESMO peso.

## Regra do Danilo para o copy
Vender o susto evitado, nunca a app. Cada bloco = uma dor + um número real + o que o Em Dia faz.
Números legais SÓ os de `supabase/migrations/20260905_0003_seed.sql` (tabela `regras_legais`).

## Design system (passo 2 — extraído das referências e de docs/DESIGN-SYSTEM.md)
1. Cores: `--verde #16A34A` (primário, "em dia"), `--verde-esc #15803D` (hover/texto sobre verde claro),
   `--verde-noite #065F46` (véu do herói, bloco final), `--verde-claro #DCFCE7` / `--verde-fundo #F0FDF4`,
   `--laranja #F97316` (1 por ecrã: o ponto "sem rede" e o aviso), `--vermelho #DC2626` (topo dos 4 sustos),
   `--fundo #F6F7F4`, `--tinta #111827/#4B5563/#6B7280`, `--linha #E5E7EB`, info `#2563EB/#DBEAFE` (menção M10).
2. Tipografia: Inter local (woff2 subset + TTF fallback), `font-display: swap`. Display 900 `-.035em`
   clamp(40–84 px); H2 800 clamp(30–44); corpo 18 px (19 em desktop), altura 1.5; etiqueta 13 px 700 `.14em` maiúsculas.
3. Espaços: 4/8/12/16/20/24/32/48/72/104. Secções 72 (mobile) / 104 (desktop). Cartões 24 de padding.
4. Cantos: 16 (cartões, botões), 12 (inputs, chips), 24 (caixa da calculadora), 999 (selos), 34/26 (moldura telemóvel).
5. Sombras: `0 2 8 rgba(15,23,42,.08)` e `0 8 24 rgba(15,23,42,.12)`. Nunca mais do que estas duas.
6. Botões: cheios verde (secções claras), cheios brancos sobre o verde-noite (herói e bloco final), contorno verde
   nos planos secundários. Altura mínima 56, largura total no telemóvel. Hover: sobe 2 px + sombra grande.
7. Grelha: 1120 max; 4 sustos → 1/2/4 colunas (700/1040); calculadora 2 colunas a 800; capturas: tira com
   scroll-snap no telemóvel, 6 colunas a 1100.
8. Fotos: capturas REAIS (golden `_medio_pt`) em WebP, dentro de moldura de telemóvel em CSS (fundo #111827,
   entalhe superior), `loading="lazy"`. No herói: vídeo a sangrar com véu verde-noite em gradiente.
9. Movimento: revelação suave ao scroll (IntersectionObserver) + vídeo ken-burns. Com `prefers-reduced-motion`
   TUDO desliga (vídeo `display:none` + pause, revela sem transição, scroll sem smooth).

## Secções por ordem (conteúdo real)
1. **Topo** fixo: marca, âncoras (Os 4 sustos, Como funciona, Preços, Perguntas), atalho "Calculadora grátis".
2. **Herói** (100vh antes de 100svh): vídeo muted/autoplay/loop/playsinline/preload=metadata/poster;
   H1 "Nunca mais levas multa da Segurança Social."; sub "A app que te avisa antes de cada prazo: Segurança
   Social, IVA, IRS e o carro. Em português simples, sem letras miúdas."; 2 botões iguais (Play Store · iPhone/
   computador → app.emdia.boraguarda.com); nota "Grátis 30 dias com tudo aberto. Sem cartão."
3. **Os 4 sustos**: SS (dia 20; trimestral jan/abr/jul/out; 21,4% × 70%, mín. 20 €), IVA (15.000 €; 18.750 €
   perde já; 23%), IRS (20 jul/set/dez; coef. 0,75; entrega 1 abr–30 jun), Carro (IPO 4/6/8 anos depois anual;
   TVDE anual a confirmar; IUC mês da matrícula; avisos 30/7 e seguro 45 dias). CTA → calculadora.
4. **Calculadora** (caixa branca, 2 separadores): "O recibo" (valor · retenção 23/25/dispensa · IVA isento/23%)
   → no recibo, IVA, total, retenção, **O que recebes na conta**, **O que é teu**, menção M10 com "Copiar";
   "Quanto guardar por mês" (rendimento · serviços/vendas) → SS, IRS, **Guarda todos os meses**, **Fica mesmo
   para ti**, notas (isenção 12 meses; mínimo de existência; justificar despesas > 27.360; escalões 2026 por
   confirmar). Rodapé: "valores 2026 · atualizados dd/mm/aaaa · fonte oficial" (lido do REST anónimo, com
   fallback embebido) + "Informação geral. Não substitui o teu contabilista." CTA → #descarregar.
5. **Como funciona**: 3 passos (dizes o que fazes → monta o calendário → avisa antes, marcas "já paguei").
6. **Capturas reais**: 6 telemóveis (painel verde, recibos, calendário, quanto guardar, carro, painel laranja).
7. **Preços**: Grátis 0 € · Pro 3,49 €/mês ou 29,90 €/ano (destaque) · Família 5,99 €/mês ou 49,90 €/ano;
   valores com `data-regra` para serem substituídos pelo que vier de `regras_legais`.
8. **FAQ** 6 perguntas (`<details>`) + JSON-LD FAQPage com o mesmo texto.
9. **Descarregar**: fundo verde-noite, H2 "Confirma se estás em dia. Hoje.", os 2 botões iguais outra vez.
10. **Rodapé**: "Informação geral, não substitui contabilista", privacidade, contacto (Mais → Ajuda), UE/Paris.

## Proibido neste site
Emoji a fazer de imagem · fundo creme com serifada · quase-preto com verde-ácido · jornal sem raio · Google
Fonts/CDN · bibliotecas JS · números legais fora da tabela · dois elementos assinatura · dois CTA no mesmo bloco ·
herói sem vídeo/imagem a sangrar · texto < 13 px · botão < 56 px · mais de um laranja por ecrã.

## Segunda ronda (passo 6) — perguntas a fazer com o site na mão
1. Onde é que a hierarquia falha? 2. Que secção está fina de conteúdo? 3. O que é que um estranho não percebe
em cinco segundos? Comparar herói contra herói com appartur.pt a 1440 e 390 (teste dos 3 segundos).
