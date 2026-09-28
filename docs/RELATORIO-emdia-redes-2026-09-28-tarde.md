# Relatório — missão `emdia-redes-2026-09-28` (sessão da tarde)

**Quando:** 28/09/2026, das 15:00 às 16:40 (hora de Lisboa). **Motor:** Opus 5.5, Claude Code no PC.
**Ordem do Danilo nesta sessão:** «vai E0 E1 E3. Grupos: b». Nos grupos, o Danilo quer um «sim» por cada ação, pedido tudo junto ao fim da tarde.
**RAM:** 866 MB no arranque, 643 MB antes da parte Flutter, 462 MB depois. Não compilei Flutter no PC, porque estava abaixo dos 800 MB: a compilação e os testes correram no CI do GitHub.

A sessão da manhã (11:07–11:37) já tinha fechado o E1 (reel diário sozinho), o E3 (playbook) e a máquina do plano dos grupos. Não refiz nada disso. Esta sessão fez o que faltava.

## Uma linha por bloco

| Bloco | Estado | Prova |
|---|---|---|
| E0 — ficha da loja | ✅ no ar | Workflow `ios-ficha-emdia` no `bora-app-cloud` (commit `0b41efcb`). Corrida de teste 36441136238: `versao 1.0.0 -> WAITING_FOR_REVIEW`, «ainda não aprovada, nada a fazer». Vigia na VPS (`apple_vigia.sh`, a cada 6 h) com `resultCount=0` hoje. |
| E1 — reels | ✅ (manhã) | 4 reels gerados sozinhos, todos com nota 100 no fiscal, no calendário para 29/09, 03/10, 06/10 e 10/10 às 20:30. Os links saem a partir de 29/09. |
| E3 — como o mundo faz | ✅ (manhã) | Córtex `memoria-claude-ai-playbook-redes-emdia` (40 regras) e `docs/marketing/redes-em-dia/PLAYBOOK-REDES-EMDIA.md`. |
| E2 — lista de grupos | ✅ | 454 grupos na tabela `grupos_divulgacao` (SELECT: 454 candidatos, regras por confirmar). |
| E2 — pausar | ✅ provado | 1 grupo pausado: o plano fica com 453 e ele sai. «Pausar tudo»: sai só a mensagem «Pausado no painel admin». Testes desfeitos (0 pausados). |
| E2 — painel admin | ⚠️ pronto, **não está no ar** | Ramo `redes-grupos-painel-2026-09-28` (`0627530`, `89245a2`). CI olho-golden 36441389158: 144 + 6 testes verdes. Foto em `docs/provas/grupos-painel-2026-09-28/`. Ver «Para o Danilo», ponto 1. |
| E2 — «sim» do dia | ✅ agendado | Tarefa `emdia-grupos-sim-do-dia`, todos os dias às 18:30 (a primeira é hoje). Hoje pede 5 adesões e nenhuma publicação, porque nenhum grupo foi aceite há 72 h. |

## Como funciona agora

**E0.** A cada 6 horas, o GitHub lê o estado da versão na Apple.
- Quando ela ficar aprovada, troca o texto promocional para o novo e lê-o de volta para confirmar.
- Quando houver uma versão nova em preparação, tira da descrição a frase «Quando as assinaturas abrirem…».
- Se a Apple não ficar como se pediu, falha.
- A VPS avisa-te no Telegram uma só vez, no dia em que a app aparecer na loja.
- A chave da Apple só existe no repositório do Bora (é de lá que sai a build iOS do Em Dia), por isso o agendamento vive lá. Só lê e escreve a ficha do Em Dia.

**E2, modo (b).**
1. Às 08:40, a VPS faz o plano: 5 adesões e até 3 publicações, com textos escritos de raiz e as pausas do painel já respeitadas.
2. Às 18:30, a tarefa do Claude neste PC:
   - lê o lote;
   - confere as regras de cada grupo no Chrome (perfil Bora, onde está a tua conta pessoal do Facebook);
   - mostra-te a lista numerada (A1… para adesões, P1… para publicações, com o texto completo);
   - dá-te um toque no Telegram.
3. Respondes numa só mensagem nessa sessão, por exemplo «sim A1 A2 P1, não A3», ou «sim a tudo».
4. Só depois ela faz, um a um: as adesões com 2 a 5 minutos entre elas, as publicações com 30 a 60 minutos. Regista cada publicação com o link.
5. Ao primeiro aviso do Facebook pára tudo e avisa-te.

Mantém-se: nada de publicar antes de passarem 72 h desde a aceitação, uma publicação por grupo por semana, e o limite sobe de 5 para 7 ao fim de 7 dias sem avisos.

**Painel (quando estiver no ar):** em Redes Em Dia, por baixo das publicações, aparece o bloco «Grupos do Facebook». Tem os números do dia, o limite de hoje, o botão «Pausar tudo», um filtro por estado e a tabela com «Pausar» ou «Retomar» em cada grupo.

## Achados pelo caminho (reportados, não corrigidos)

1. **10 commits no `main` do PC que nunca foram para o GitHub.** Entre eles estão a secção Redes Em Dia do painel, o «Convida e ganha», a barra lateral do painel e o reel diário. O site no ar não os tem (confirmei no código publicado do painel e da app). Do outro lado, o GitHub tem 6 commits que o PC não tinha (iOS e «sem planos à venda»).
2. **Falso positivo no CI.** O primeiro teste do E0 no repositório do Em Dia deu «success» com o script a rebentar: os segredos estavam vazios e o `| tee` escondia o erro. Corrigido: o workflow saiu de lá e o do Bora tem `pipefail` e trava se os segredos estiverem vazios.
3. **Da manhã, continua por fazer:** 7 reels agendados à mão na Meta (R01, R02, R05, R08, R12, R14 e R16) mostram «Mês grátis até 23/10». As versões corrigidas estão em `pecas/reels-v2`, para trocar no Business Suite.

## PARA O DANILO

1. **Publicar o painel dos grupos obriga a publicar também os 10 commits que estavam só no PC.** Isso inclui o «Convida e ganha», que vai para o Android e para a web. Diz «publica o Em Dia» e eu junto tudo ao `main`: resolvo os conflitos com os 6 commits do GitHub e confirmo o CI. Até lá, a pausa funciona na mesma pela base de dados. Se quiseres pausar tudo antes disso, diz-me e eu faço.
2. **Hoje às 18:37 chega o primeiro pedido de «sim»:** 5 grupos para pedir adesão (Viver em Portugal, Motoristas Profissionais, Freelance in Portugal, Brasileiros em Portugal e Bolt Food Estafetas Porto).
3. **A tarefa das 18:30 só corre com a app Claude aberta no PC.** Se o PC estiver desligado, corre quando voltares a abrir a app.
