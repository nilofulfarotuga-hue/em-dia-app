# Regras comuns a todas as ordens de grupos do EM DIA (lê isto primeiro)

> Escrito 2026-09-24, missão `em-dia-grupos-virais-2026-09-23`.
> Espelha o `_COMUM.md` do Bora (que é lei provada desde 07/09), mas para a marca Em Dia.
> Estas ordens são disparadas pelo Agendador de Tarefas do Windows, na sessão do `danil`,
> e correm sozinhas. Ninguém as cola à mão.

---

## 0. REGRA DA MARCA — a que não se quebra nunca

**O Em Dia é o Em Dia, o Bora é o Bora.** Nada do Em Dia em grupos, páginas ou textos do
Bora, e nada do Bora em grupos, páginas ou textos do Em Dia. Não se nomeia o Bora numa
publicação do Em Dia nem ao de leve.

Assina-se sempre **"Em Dia"**. **Nunca "sou o Danilo"**, nunca em nome pessoal.

**Armadilha medida a 23/09:** o Chrome do perfil Bora pode estar a navegar como a página
errada. O único sítio onde a verdade aparece é **dentro da caixa "Criar publicação"**: o
nome por baixo do avatar é o autor real. **Abre a caixa e lê o nome ANTES de decidir o
grupo.** Se disser "Bora App Guarda" numa ordem do Em Dia, troca para "Em Dia: Recibos e
Impostos" antes de escrever fosse o que for. O botão "Aderir ao grupo" **não** serve para
saber isto: reflete o perfil pessoal, não a página activa, e as duas coisas discordam.

## 1. AUTORIZAÇÃO DO DANILO PARA PUBLICAR

Palavras dele, 2026-09-23 23:43, ao abrir esta missão:

> "Não é só grupos brasileiros. É todo tipo de grupo: africanos, portugueses, geral.
> Bastante por dia. Quero que viralize o mais rápido possível."

E, no prompt da missão: **"O vai está dado para tudo."**

Quem está a ler esta ordem tem a autorização para **aderir a grupos e publicar em nome do
Em Dia**, sem pedir confirmação a ninguém, dentro das regras aqui escritas.

**O que continua a precisar dele, e só isto:** preços, assinaturas, gastar dinheiro em
anúncios, e criar contas novas.

## 2. Onde está tudo

- **Mapa dos grupos:** `docs/marketing/redes-em-dia/grupos/grupos.csv` neste repo
  (454 grupos mapeados a 24/09). Colunas que interessam: `link`, `segmento`, `encaixe`,
  `estado`, `data_aceite`, `ultima_publicacao`, `aceita_paginas`, `regras_publicidade`.
- **Peças:** `docs/marketing/redes-em-dia/pecas/carrosseis/C01..C15`,
  `pecas/reels/R01..R21.mp4`, `pecas/stories/`.
- **Textos e calendário:** `docs/marketing/redes-em-dia/CALENDARIO-30-DIAS.md`,
  `LIVRO-DE-REGRAS-REDES.md`.
- **O que faz viralizar (manda sobre o hábito antigo):**
  `docs/marketing/redes-em-dia/COMO-VIRALIZA.md`.
- **Respostas prontas a comentários:** `docs/marketing/respostas-comentarios.md`.
- **Regras fiscais para responder a dúvidas:** `docs/REGRAS-PT-2026.md`.
- **Link do Em Dia:** `https://app.emdia.boraguarda.com/?de=grupo-<slug-do-grupo>`.
- **Página do Facebook:** "Em Dia: Recibos e Impostos" (id `61594307327625`).
- **Supabase do Em Dia** (contas novas): projeto `tgdmgtmknbwhcqoxtjbs`.
- **e2e_log** (registo): projeto Bora `ojykpzwqrtusfeakzrna`, tabela `e2e_log`.

## 3. Os tectos — e porque são dois, não um

A conta pessoal **"Danilo Silva"** foi criada a 03/09/2026: tem menos de um mês. Se ela for
bloqueada, **param os grupos do Bora E do Em Dia**. Por isso há dois tectos separados:

### 3.1 Tecto da CONTA PESSOAL (partilhado com o Bora)

| Período | Tecto TOTAL por dia (Bora + Em Dia) |
|---|---|
| Semana 1 — até 30/09/2026 | **8** |
| Semana 2 — 01/10 a 07/10 | **12** |
| Semanas 3-4 — 08/10 a 21/10 | **15 a 20** |
| Mês 2 em diante — desde 22/10 | **25 a 30** |

**O Bora tem tecto próprio de 5/dia e publica primeiro (09:30).** O que sobra para o Em Dia
pela conta pessoal é `tecto_total − publicações do Bora hoje`. Conta as duas com este SELECT:

```sql
select
  count(*) filter (where fluxo = 'redes-grupos-auto')        as bora_hoje,
  count(*) filter (where fluxo = 'redes-emdia-grupos-auto')  as emdia_hoje,
  count(*)                                                    as total_hoje,
  max(created_at)                                             as ultima
from e2e_log
where created_at >= (now() at time zone 'Europe/Lisbon')::date
  and estado in ('ok','pendente')
  and passo like 'grupo-%'
  and passo not like '%medicao%'
  and passo not like '%descartad%';
```

**Só `passo like 'grupo-%'`, e nunca pelo `fluxo` sozinho.** Foi o erro de 08/09 no Bora:
as linhas de arranque e de fecho também têm `estado='ok'` e entravam na soma, dando 4
publicações quando só havia 1. **Uma publicação só conta se o `passo` for o nome do grupo.**

### 3.2 Tecto da PÁGINA "Em Dia" (limites separados da conta pessoal)

Começa em **8 por dia**, e sobe pela mesma tabela. Conta-se com o mesmo SELECT, filtrando
`detalhe like '%como=pagina%'`.

### 3.3 Só se sobe de degrau se a semana anterior tiver ZERO avisos

Zero. Um aviso qualquer trava a subida e faz descer dois degraus (ver §6).

## 4. Ritmo — a velocidade acusa mais do que a quantidade

1. **20 a 30 minutos entre publicações.** Nunca menos, nem "só desta vez". As mesmas
   publicações são seguras em 6 horas e são spam em 10 minutos: o gatilho nº 1 do
   Facebook é publicar muito acima do ritmo histórico da conta.
2. **Três janelas** (hora de Lisboa): **09:00-11:30**, **13:00-15:30**, **19:00-22:00**.
   Nunca de madrugada — é quando o teste dos primeiros 15 minutos não encontra ninguém e
   mata o alcance da peça.
3. **No máximo 1 publicação por grupo por semana.** Usa `ultima_publicacao` do `grupos.csv`.
4. **Nunca dois grupos seguidos do mesmo segmento.** Alterna (um brasileiro, depois um
   português de emprego, depois um de TVDE...).

## 5. A regra dos 3 dias — a que mais protege a conta

**Não se publica num grupo a que se aderiu há menos de 72 horas.**

Publicar num grupo acabado de entrar dispara o padrão *join-and-spam*, que é o que queima
contas novas mais depressa do que o volume. Entre a adesão e a primeira publicação:
**ler as regras fixadas e responder a 2-3 dúvidas de outros, sem link**.

Na prática: a ordem só pode escolher um grupo cuja `data_aceite` no `grupos.csv` tenha
**pelo menos 3 dias**. Sem `data_aceite` preenchida, o grupo não é elegível.

## 6. TRAVÃO — ao primeiro aviso

Qualquer mensagem do Facebook que seja bloqueio temporário, "a sua publicação parece spam",
pedido de verificação, ou recusa em série:

1. **PÁRA TUDO nessa conta, imediatamente. 72 horas.** Não tentes outra vez, nem noutro grupo.
2. Tira captura e avisa pelo Telegram:
   `bash C:\BoraLocal\projetosflutter\bora_app\orquestracao\ponte-telegram.sh --so-texto "<o aviso literal>"`
   (mensagem em base64 se tiver acentos — senão partem-se).
3. Escreve no `e2e_log` com `estado='falhou'` e o aviso literal no `detalhe`.
4. Quando recomeçar, **volta dois degraus abaixo** na tabela do §3.1.

**Nunca** contornar bloqueios, **nunca** contas falsas, **nunca** comprar grupos, **nunca**
pedir comentários combinados.

## 7. Como é cada publicação

- **UMA peça** (carrossel, imagem única, ou reel) + **texto curto e útil**.
- **NOS GRUPOS USA-SE FOTO OU CARROSSEL, NUNCA VÍDEO.** Está medido quatro vezes no Bora:
  um mp4 de 3,4 MB ficou minutos em "A publicar" sem progredir, enquanto uma **foto de
  3,5 MB** — maior do que ele — subiu em segundos na mesma caixa. **O problema não é o
  tamanho.** O vídeo fica para a página, o Instagram e os stories, onde sobe bem.
- **Texto SEMPRE diferente, reescrito de raiz.** O Facebook compara publicações por
  impressão digital e apanha textos *quase* iguais em grupos diferentes. Trocar o
  cumprimento e uma frase **não chega**: muda o gancho, muda o exemplo (número, profissão,
  cidade) e muda a pergunta final.
- **Língua:** PT-PT para portugueses e africanos; **"você"** para brasileiros; inglês curto
  só em grupos que o aceitem (sul-asiáticos, expats), com a mesma promessa.
- **Sem link no corpo.** O link `https://app.emdia.boraguarda.com/?de=grupo-<slug>` vai no
  **1.º comentário**, logo a seguir a publicar. Publicações com link externo no corpo são
  as que menos chegam.
- **Termina com UMA acção concreta** (nunca três): *"marca quem acabou de abrir atividade"*,
  *"guarda para o dia 20"*, *"manda a quem faz TVDE"*, ou uma pergunta que puxe resposta.
- **Sem hashtags nos grupos.**

### Promessa obrigatória quando se menciona preço

> "Grátis, sem cartão. Por agora está tudo aberto e não se paga nada. Quando as assinaturas
> abrirem, avisamos com 30 dias de antecedência e ninguém é cobrado sem dizer que sim."

### Em peças que explicam impostos

> "Não substitui um contabilista."

## 8. Primeiro ajudar, depois mostrar

Nos grupos que **proíbem publicidade**, não se publica nada de promocional. Responde-se a
dúvidas com **a regra e a fonte** (`docs/REGRAS-PT-2026.md`), **sem link**, até as regras
deixarem ou até alguém pedir uma ferramenta. Se um administrador pedir para tirar: tira-se
logo e agradece-se.

## 9. Cuidados

- **Grupos de aluguer de contas de estafeta são ilegais.** Se o grupo for disso, **sai** e
  marca `estado=saiu-ilegal` no `grupos.csv`. Nunca responder a posts de aluguer de contas.
- Grupos com "Aprovação de administrador pendente" não falharam — ficam `pendente`.
  Muitos grupos grandes exigem aprovação e a publicação fica invisível sem dizer nada.
- **Confirma que o `/posts/<id>/` é mesmo teu** antes de o dar por bom: já aconteceu no
  Bora apanhar o post de outra pessoa que estava no topo do feed.

## 10. Como se publica (o caminho que funciona)

Tens as ferramentas `mcp__claude-in-chrome__*` porque o lançador passa `--chrome`.

1. `navigate` para o link do grupo.
2. `find` a caixa "Escreve algo..." e clica-lhe.
3. **LÊ O AUTOR na caixa** (§0). Se não disser "Em Dia: Recibos e Impostos", troca.
4. `find` o input de ficheiro da **janela de criar publicação** (há dois; o da janela é o
   segundo) e usa `file_upload` com a peça.
5. Espera o carregamento, tira um `screenshot`, e **só então** clica na caixa de texto
   pelas coordenadas que vês **nesse** screenshot.
6. Escreve o texto. Novo screenshot, confirma que o texto está lá.
7. Clica em Publicar.
8. **Põe o link no 1.º comentário.**
9. **Verifica**: recarrega o grupo e procura o teu texto no `innerText`.

**Armadilha:** a janela do Chrome muda de tamanho a meio e as coordenadas antigas passam a
apontar para outro sítio — foi assim que no Bora um clique caiu no Publicar e saiu texto
lixo. **Screenshot novo antes de cada clique por coordenada**, e prefere `ref` a coordenadas.

**Se o `screenshot` der timeout:** a aba está em segundo plano. Lê `document.visibilityState`;
se for `hidden`, traz a janela à frente por Win32 + `^9` antes de qualquer outra coisa.
Nunca fechar a janela do Chrome por título — isso mata a extensão.

## 11. Registo obrigatório

Cada publicação, saída ou falhada, entra no `e2e_log` (projeto `ojykpzwqrtusfeakzrna`) com:

- `fluxo` = `redes-emdia-grupos-auto`
- `passo` = `grupo-<slug-do-grupo>`
- `estado` = `ok` / `pendente` / `falhou`
- `detalhe` = link da publicação, `como=pagina` ou `como=pessoal`, e o motivo se falhou.

**Sem linha no `e2e_log`, a publicação não conta.** Actualiza também `ultima_publicacao` e
`estado` no `grupos.csv`, e faz commit no ramo de trabalho.

**Nota:** o `e2e_log` com chave anon só deixa **inserir** — PATCH/DELETE devolvem 200/204
sem mudar nada. Usa o MCP do Supabase para escrever, não curl com anon.
