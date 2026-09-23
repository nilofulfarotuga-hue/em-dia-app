# Fecho do Claude Code — missão `em-dia-web-iphone-2026-09-22` (23/09/2026, 00:0x)

> A missão foi executada pelo OpenCode/ChatGPT gpt-5.5 (ordem do Danilo: «Claude Code fora»), que a fechou e empurrou
> (commit `b72eb9d`, MARCOS com MISSAO-CONCLUIDA, Telegram 8215/8216, Córtex ref-322585).
> Depois o Danilo disse «termina tudo agora». O Claude Code voltou só para fechar as pontas soltas. Isto é o que fez,
> com prova, e o que encontrou por verificar o trabalho do motor em vez de o aceitar.

## 1. Árvore local divergente — arrumada
`main` estava `ahead 1, behind 2`: o motor commitou `37e0ccc` mas, como havia ficheiros alheios por commitar, empurrou
por um worktree temporário (cherry-pick → `b72eb9d`). Conferido que o publicado contém o local:
```
git diff 37e0ccc origin/main --stat → pubspec.yaml | 2 +- (só o versionCode 41 do CI)
```
`git reset --hard origin/main`, ramo `push-em-dia-web-iphone` apagado, `git worktree prune`. Local = remoto.

## 2. CI do iOS estava VERMELHO — causa encontrada e corrigida
A corrida `.github/workflows/build_ios.yml` de `b72eb9d` falhou **sem job nenhum** (`total_count 0`, nome da corrida =
caminho do ficheiro) — assinatura de *startup failure*: o GitHub recusou o ficheiro inteiro. Causa: três passos com
`if: ${{ secrets.X != '' }}`. **O contexto `secrets` não existe no `if:` de um passo.** Os cinco segredos passaram a
`env:` do job (que o `if:` conhece) — commit `31451c1`. Depois disso o GitHub aceita o ficheiro: a corrida de validação
vermelha deixou de aparecer e os outros três workflows ficaram verdes.
(Como o workflow só corre em `workflow_dispatch`, o IPA continua por gerar até alguém o disparar com os segredos postos.)

## 3. A web não estava lançada — estava
O repo tinha o interruptor, mas o site no ar era o antigo: `emdia.boraguarda.com/precos` ainda mostrava «Assinar» e não
tinha `planos_a_venda`. O site não sai pelo CI (o workflow ignora `site/**`); publica-se com `tool/site/publicar.ps1`.
Publicado. Prova no ar:
```
no ar tem interruptor: True | botões de compra escondidos por omissão: 2
REST anónimo: planos_a_venda = nao
               promessa_gratis_texto = Por agora está tudo aberto e não se paga nada. Quando as assinaturas abrirem,
               avisamos com 30 dias de antecedência e ninguém é cobrado sem dizer que sim.
```

## 4. Verificador do site posto na verdade nova — 62/62
Quatro asserções estavam presas ao mundo antigo (exigiam o botão «Descarregar na Play Store» e a palavra «Google Play»
em /precos). Reescritas para a decisão de 22/09: o botão da web tem de aparecer no herói e no bloco final com o mesmo
peso; se um dia voltar o botão da Play, tem de ter o mesmo peso; `/precos` tem de trazer o interruptor; e uma asserção
nova que tranca a regra do Danilo — **nenhum `data-compra` visível por omissão**.
```
node site/testes/verifica.mjs https://emdia.boraguarda.com → 62 asserções passaram / 0 falharam
```

## 5. O que foi conferido do trabalho do motor (não foi aceite pela palavra dele)
- `lib/screens/plano/plano_screen.dart:93-161`: o botão de comprar depende de `planosAVenda`; a promessa vem da base de
  dados (`regras.txt('promessa_gratis_texto')`), não está escrita no código. Confere com a ordem.
- `ios/`: existe, bundle `pt.emdia.app`, `CFBundleDisplayName = Em Dia`, e as seis chaves de permissão em PT-PT —
  incluindo `NSFaceIDUsageDescription`, que era a cicatriz da Bora.
- CI de `b72eb9d`: olho-golden, web e Android verdes.

## 6. Reparo, não corrigido (fica para decisão, como manda a regra)
`carroEmBreve` = «Em breve» continua no l10n (PT e BR). **Não está a ser usada por nenhum ecrã** (grep sem resultados
fora dos ficheiros gerados), e há um texto de guia por escrever com a mesma expressão. Não lhes toquei: são anteriores a
esta missão e mexer em textos parte goldens. Se o Danilo quiser a casa limpa da expressão, é uma linha de trabalho.
