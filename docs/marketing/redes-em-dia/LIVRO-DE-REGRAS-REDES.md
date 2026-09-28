# LIVRO DE REGRAS — redes sociais do Em Dia

> Missão `redes-em-dia-2026-09-23`. Marca separada do Bora («o Em Dia é o Em Dia, o Bora é o Bora»).
> Página do Facebook: «Em Dia: Recibos e Impostos» (id 61594307327625). Instagram: a criar.
> Tudo o que está em `pecas/` sai de código (`tool/redes/`), com os ecrãs verdadeiros da app no modo exemplo.

## 0. Como foi feita a pesquisa (e o que ficou por ver)

- A rede desta sessão bloqueou `facebook.com`, `instagram.com`, a Biblioteca de Anúncios da Meta e os sites das marcas
  (resposta do proxy: `EGRESS_BLOCKED` / `403`). **Não foi possível abrir nem capturar perfis ou anúncios.**
- O que está abaixo vem de resultados de pesquisa (resumos indexados), com a fonte ao lado. O número de seguidores é uma ordem
  de grandeza (a data do índice não é conhecida). O que não se conseguiu confirmar diz **não confirmado**.
- **Capturas de referência que temos:** os ecrãs das apps concorrentes já guardados no repo (`docs/referencias/mei-facil/`,
  `docs/referencias/maismei/`, `docs/referencias/drivvo/`, `docs/referencias/rocket-money/`) e os 19 ecrãs verdadeiros do
  Em Dia em `capturas/` (tirados por `tool/redes/capturas_test.dart`, modo exemplo, 1170×2532).
- **Por fazer por quem tem sessão no Facebook (5 minutos):** abrir a Biblioteca de Anúncios
  (https://www.facebook.com/ads/library/?country=PT) e procurar «Artur», «InvoiceXpress», «Moloni», «Doutor Finanças»,
  «Taxfix», «Keeper». Guardar 2-3 capturas de cada em `docs/marketing/redes-em-dia/referencias/` e corrigir a tabela.

## 1. As referências — o que fazem e o que o Em Dia copia

| Marca | Onde está | O que se viu | O que o Em Dia copia |
|---|---|---|---|
| **Artur** (PT, concorrente direto) | appartur.pt · Instagram oficial **não encontrado** | Promessa «quanto reservar para IVA, SS e IRS a cada fatura»; «saber ao cêntimo o que é teu». 6,99 €/mês + IVA, 1.º mês grátis. Cresce por **guias e simuladores** (SEO) e imprensa (Leak.pt). | A frase «nem tudo é teu»; guias curtos; **o espaço nas redes está livre** — o Artur não está lá. |
| **InvoiceXpress** (PT) | @invoicexpress (~1,5 mil) | Faturação certificada, «desde 3 €/mês». Pouca tração no Instagram. | Nada de visual: prova de que software de faturação em PT não domina redes. |
| **Moloni** (PT) | @moloni_software (~1 mil, 619 posts) | Muitos posts, pouco envolvimento (inferência). | O aviso: publicar muito sem gancho não chega. |
| **TOConline** (PT) | sem Instagram encontrado | Vende-se através de contabilistas (B2B2C). | — |
| **Doutor Finanças** (PT) | @doutorfinancas.pt (~125 mil) | Reels institucionais; o motor é o site («Calendário fiscal 2026: as datas que não pode mesmo falhar»). | O gancho **«datas que não podes falhar»** (carrosséis C02 e C15). |
| **MEI Fácil** (BR) | @meifacil (~203 mil) | Hoje dentro do app Neon. Cartão «PRÓXIMO DAS — Em 11 dias» (ver `docs/referencias/mei-facil/01.png`). | Contagem regressiva para o prazo (stories «14 dias», «7 dias», «4 dias»). |
| **MaisMei** (BR) | @maismeioficial (~94 mil) | Posts que **chamam o público pelo nome na 1.ª palavra** («Ei, MEI, já pagou o DAS?»), lembretes de prazo com feriado, carrosséis «para guardar». | Chamar pelo nome: «Trabalhas a recibos verdes?», «Fazes entregas?», «Tens contrato?»; o feriado de 5/10 (R06, S08). |
| **Contabilizei** (BR) | @contabilizei (~164 mil) | Muitos posts, gancho de calendário («Reta final do ano!»). | Série de fim de mês/ano. |
| **Declarando** (ES) | @declarando_es (~14 mil) | Nome do app = gancho de poupança («dedúcete ese IVA»). | Carrossel de deduções do IRS (C12). |
| **Holded** (ES) | @holded.io (~46 mil) | **Série numerada fixa** («Holded Magazine Nº xx»). | Carrosséis numerados 1, 2, 3… e a série «Recibos verdes · 101». |
| **Keeper** (EUA) | @keeper.tax (~120 mil) | Gancho com **número em dinheiro** («$1.249/ano em deduções perdidas»); criadores no TikTok com #ad; SEO por profissão. | Gancho com número em euros (R02 «179,76 €», R19 «770 €»). Criadores: fase 2, com contrato e a marca #publicidade. |
| **Taxfix** (DE/IT/ES) | @taxfix | «Em média 1.063 € de volta», influencers com código. | Mesmo princípio do número; **nós só usamos números da lei**, nunca «médias» sem fonte. |
| **QuickBooks Self-Employed** (EUA) | descontinuado em 2024 → QuickBooks Solopreneur | — | Não serve de referência. |

Fontes (links completos no relatório de pesquisa da sessão, copiados para `RELATORIO-redes-em-dia-2026-09-23.md`):
appartur.pt, appartur.pt/precos, instagram.com/{invoicexpress, moloni_software, doutorfinancas.pt, meifacil, maismeioficial,
contabilizei, declarando_es, holded.io, keeper.tax, taxfix}, keepertax.com/partner/freelancers-union,
quickbooks.intuit.com/r/product-update/quickbooks-self-employed-vs-quickbooks-solopreneur.

## 2. Formatos (o que se faz e porquê)

| Formato | Medida | Regra | Porquê |
|---|---|---|---|
| **Carrossel** | 1080×1350 (4:5), 5 a 8 lâminas | 1 ideia por lâmina; capa com gancho enorme; número grande à esquerda; **fonte oficial no rodapé**; última lâmina = CTA + promessa | É o formato com mais envolvimento (Socialinsider 2.º trim. 2026: 0,50 % vs 0,48 % reels; Buffer por alcance: 6,90 % vs 3,31 %) e o que se **guarda e envia**. |
| **Reel** | 1080×1920 (9:16), **7 a 20 s**, 30 fps, H.264 + AAC | **Nenhum plano com mais de 4 s**; gancho nos primeiros 2-3 s; texto curto a acompanhar; música própria (sem direitos de terceiros); último plano = CTA + promessa | Os reels chegam a quem ainda não segue (~36 % mais alcance). A retenção dos primeiros 3 s é o que conta. |
| **Story** | 1080×1920 | Quase diário; contagem regressiva para os prazos; sondagens e caixa de perguntas; botão «grátis, sem cartão · link» | Mantém quem já segue; 1-2 por dia é a referência (Buffer). |
| **Capa FB** | 1640×624 (e 851×315) | O essencial no centro (o telemóvel corta os lados) | Aparece a 820×312 no computador, 640×360 no telemóvel. |
| **Foto de perfil** | 1080×1080 | Símbolo ao centro (o Instagram corta em círculo) | Carregar a ≥ 320×320. |
| **Destaques IG** | 1080×1920 | Símbolo desenhado no círculo central | Prazos · Recibos · Carro · IVA · Brasil · Ajuda. |
| **Impressão** | A5 300 dpi | **QR** para `https://app.emdia.boraguarda.com` | Cartaz para balcões, associações, cafés de motoristas. |

**Zonas seguras (reels):** texto entre y = 250 e y = 1480; nada importante à direita de x = 960 (botões) nem nos últimos
~440 px (legenda e nome). **Stories:** livres os 250 px de cima e os ~340 px de baixo.

## 3. Ganchos que se usam (e os que não se usam)

Usam-se — todos testados nas referências:
1. **Chamar o público na 1.ª frase:** «Trabalhas a recibos verdes?», «Fazes entregas?», «Tens contrato?», «Chegou em Portugal…».
2. **Número com fonte:** «179,76 € por mês» (21,4 % × 70 % × 1.200 €), «770 € de um recibo de 1.000 €», «15.000 €».
3. **Prazo real com contagem:** «Faltam 4 dias», «Amanhã é o último dia», «31 é sábado: trata até sexta».
4. **Pergunta que a pessoa já faz:** «Vale a pena esta corrida?», «Quanto fica mesmo para ti?».
5. **Explicado a uma criança de 5 anos:** «3 caixinhas, 2 prazos, 1 regra de ouro».
6. **Guardar/enviar:** «Guarda este post», «Manda a quem acabou de abrir atividade».

Não se usam: medo («vais ser multado!»), números sem fonte («poupa 500 €»), testemunhos, «a app nº 1», promessas de
reembolso, marcas de terceiros (Uber, Bolt, Glovo) em destaque, falar em nome de uma pessoa. Assina sempre **Em Dia**.

## 4. Visual

- **Cores** (`docs/DESIGN-SYSTEM.md`): verde `#16A34A` (fundo de marca e «em dia»), verde fundo `#063C1E` (contraste),
  creme `#F6F7F4` (lâminas de conteúdo), laranja `#F97316` **só para urgência** (prazo a chegar), vermelho só para «passou».
- **Letra:** Inter (a da app), Black 900 nos ganchos, ExtraBold 800 nos títulos, Regular 400 no corpo. Corpo ≥ 40 px no
  carrossel (lê-se no telemóvel sem ampliar).
- **Ecrãs:** sempre verdadeiros, do modo exemplo (faixa laranja «Isto é um exemplo: a Maria…» visível), com a etiqueta
  «Ecrã real · modo exemplo (a Maria)». **Nunca dados de pessoas reais.** Nunca se retoca um ecrã; só se corta.
- **Logótipo:** o ícone da app (calendário com visto) + «Em Dia» por código, nunca pedido a uma IA.
- **Imagens de IA:** não foram usadas nesta leva (o texto, os ecrãs e o logótipo nunca podem vir da IA; cenários
  fotográficos ficam para uma fase 2, com a chave do Gemini do projeto Em Dia).

## 5. Ritmo e horas (Portugal)

- **Por semana:** 5 reels + 3-4 carrosséis + 1 story por dia.
- **Horas:** reels às **20:30** (Swonkie, 83 mil posts em PT: depois das 20h é o melhor em qualquer dia);
  carrosséis **3.ª 13:30, 5.ª 14:00, 6.ª 16:00, sáb. 11:00** (5.ª 14h e 6.ª 16h são os picos de carrossel em PT);
  stories às **09:00** (08:30 no dia de um prazo).
- A hora muda a **25/10/2026**: o Business Suite agenda na hora local da página; confirmar que está «Lisboa».
- Grupos do Facebook: **à mão**, 1 grupo por dia, ritmo humano (ver `GRUPOS-PORTUGAL.md`).

## 6. O que converte (e como se mede)

- Envios e guardados > gostos. Cada carrossel pede «guarda» ou «manda a…».
- Um só link: `https://app.emdia.boraguarda.com` (e o site `https://emdia.boraguarda.com`). No Instagram: link na bio
  e autocolante de link nos stories.
- A cada 7 dias: ver no Business Suite alcance, guardados, envios e cliques no link por peça; repetir o formato que ganhar.
- Métrica que interessa: **contas novas no Em Dia** (painel admin) na semana — hoje 12 contas e nenhuma nova desde 17/09.

## 7. Honestidade (inviolável)

- **Promessa em todo o lado** (legendas, última lâmina, fim do reel, cartaz):
  «Por agora está tudo aberto e não se paga nada. Quando as assinaturas abrirem, avisamos com 30 dias de antecedência e
  ninguém é cobrado sem dizer que sim.» + «grátis, sem cartão».
- Cada regra fiscal tem a fonte oficial (`docs/REGRAS-PT-2026.md`) na lâmina e na legenda. «Não substitui um contabilista»
  onde a peça explica impostos.
- Regras `por_confirmar` na app não entram nas peças (ex.: inspeção anual TVDE, CAE por ofício, troca de carta).
- PT-PT com acentos; as peças `br` (C03, R05, R20, S05) falam com «você», sem mudar o PT-PT da app.

## 8. Juiz — o que foi reprovado antes de sair

Comparado lado a lado com o padrão das referências (capa com gancho de 1 frase, 1 ideia por lâmina, letra grande,
contraste), reprovei e refiz:

| Versão | Problema | Correção |
|---|---|---|
| v1 lâminas | Caixas brancas opacas no fundo verde (a translucidez não misturava) | `Pincel` que mistura RGBA |
| v1 lâminas | Meia lâmina vazia nas lâminas de texto (texto colado ao topo, corpo 40 px) | bloco centrado na vertical, título 88, corpo 46 |
| v1 capa | «Desliza» escondido atrás do telemóvel | «Desliza» à esquerda quando há ecrã |
| v1 textos | «1.200» numa linha e «€» na seguinte | espaço inquebrável antes de € e % e depois de «art.» |
| v1 stories | Telemóvel por cima do botão do link | o ecrã corta-se para acabar antes do botão |
| v1 capa FB | Telemóvel fora da zona que o telemóvel mostra | movido para dentro do centro |
| ecrã do painel | A etiqueta «Mês grátis até…» da app contradiz «não se paga nada» | nas peças, o painel corta-se abaixo do cabeçalho; **reportado como fora-de-scope** |

As folhas de revisão estão em `revisao/` (uma por carrossel, stories e capas dos reels).

## 9. Como se refaz tudo

```bash
flutter test tool/redes/capturas_test.dart      # 19 ecrãs reais do modo exemplo → capturas/
pip install pillow numpy imageio-ffmpeg qrcode
python tool/redes/gerar.py                      # peças, calendário, CSV, folhas de revisão
python tool/redes/csv_meta.py exemplo-da-meta.csv   # CSV com os cabeçalhos exatos da Meta
```

O conteúdo (textos, datas, fontes) está todo em `tool/redes/conteudo.py`. Muda-se lá e volta-se a gerar.
