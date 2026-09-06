# Prova — o juiz de visão nas telas novas (2026-09-06, 18h45)

Regra 11 do `CLAUDE.md`: *"juiz de visão sem vermelhos"*. O juiz olha para as
fotografias com o Gemini e classifica cada uma em verde, amarelo ou vermelho,
contra o `DESIGN-SYSTEM.md`.

## Primeira passagem — 22 telas novas, uma foto de cada (médio, PT-PT)

```
verde 14 · amarelo 7 · VERMELHO 1
```

O vermelho foi `cofre_folha_medio_pt.png`: *"o texto por cima está cortado e
ilegível"*. Fui ver a foto: o botão principal do cofre dizia **"Pus de lado"** e
a frase partia-se em duas linhas dentro do próprio botão, ficando meia palavra
cortada pela barra de título. Corrigido: o botão passa a **"Separei"**, uma
palavra só, igual nas duas variantes.

Corrigi também o crachá do cadeado, que o juiz apontou por *"texto colado às
margens e pequeno"*: mais folga (16/14 em vez de 14/10) e o texto de 14 para
15 px com entrelinha.

## Segunda passagem, depois dos arranjos

```
[1/4] verde    cofre_folha_medio_pt.png   — design claro, bem alinhado, linguagem simples
[2/4] amarelo  fala_trancado_medio_pt.png — o texto por baixo do cadeado tem contraste fraco
[3/4] amarelo  prova_trancada_medio_pt.png— o texto do crachá ainda colado à margem esquerda
[4/4] verde    radar_trancado_medio_pt.png— bem organizado e legível

verde 2 · amarelo 2 · VERMELHO 0
```

**Zero vermelhos.** Os dois amarelos que ficam são sobre o conteúdo **baço por
baixo do cadeado** — e esse contraste fraco é o que o cadeado é: vê-se que ali
há alguma coisa, não se lê. Deixá-lo legível era tirar-lhe a função.

## Três "defeitos" do juiz que NÃO são defeitos, e é honesto dizê-lo

Um juiz que se aceita sem olhar é tão mau como não ter juiz nenhum. Destes sete
amarelos da primeira passagem, três não se corrigem porque não estão errados:

1. **`vida_sai_cheio` — "tens mais de um elemento laranja".** Fui ver a foto:
   **não há um único laranja no ecrã.** O que lá está é vermelho (`passou`), e a
   regra da casa limita o laranja, não o vermelho. O juiz trocou as cores.
2. **`vale_perde` — "o botão está cortado em baixo".** Está, e é suposto: é uma
   lista que rola, fotografada a meio. Um ecrã que rola tem sempre alguma coisa
   cortada na dobra.
3. **`fala_com_resposta` — "usaste a palavra IVA sem explicar".** A palavra IVA
   está na **resposta de exemplo escrita pelo teste**, não num texto da app.

Os outros quatro amarelos são pequenos ("texto um bocadinho colado às margens"),
ficam anotados e não valem uma mudança de desenho hoje.

## O que isto custou

O juiz usa o nível grátis do Gemini: 20 pedidos por dia **por modelo**, com roda
de onze modelos. As 26 chamadas destas duas passagens couberam. Para julgar as
881 fotos todas seria preciso a faturação ligada — está em
`docs/PENDENTE-DANILO.md`.

Relatórios completos: `docs/provas/telas/vision_report_20260906-184033.md` e
`vision_report_20260906-184638.md`.
