[MODELO: OPUS]

ORDEM FIXA — EM DIA, A PRIMEIRA HORA (dispara às 21:15, Agendador de Tarefas do Windows)

Lê primeiro `C:\BoraLocal\projetosflutter\em_dia\orquestracao\ordens-fixas\_COMUM-EMDIA.md`.

Esta ordem **não faz publicações novas**. É a volta aos comentários — e é ela que faz
espalhar. Ver `docs/marketing/redes-em-dia/COMO-VIRALIZA.md` §2.2 e §2.3.

PORQUE EXISTE: a publicação é testada num grupo pequeno logo a seguir a sair; se não houver
reacção, o alcance morre ali. Um comentário respondido gera outro comentário, e quando
alguém comenta, os **amigos dessa pessoa** passam a poder ver a publicação. A primeira hora
é trabalho, não é espera.

O QUE TENS DE FAZER:

1. JUNTA AS PUBLICAÇÕES DAS ÚLTIMAS 2 HORAS.
   No `e2e_log`, `fluxo='redes-emdia-grupos-auto'`, `passo like 'grupo-%'`, estado `ok`,
   das últimas 2 horas. O link de cada uma está no `detalhe`.
   Junta também as publicações da **página** e do **Instagram** do Em Dia
   (Business Suite → Caixa de entrada).

2. RESPONDE A TODOS OS COMENTÁRIOS.
   A todos, sem escolher. Cada resposta tem duas partes:
   - **útil** — a resposta concreta à dúvida, com a regra e o número certo
     (fonte: `docs/REGRAS-PT-2026.md`; respostas prontas em
     `docs/marketing/respostas-comentarios.md`);
   - **uma pergunta que puxe conversa** — "em que mês é que começaste?", "já tinhas feito
     a declaração trimestral antes?", "estás no primeiro ano ou já saíste da isenção?".

   Dá gosto a todos os comentários. Quando alguém pedir o link, põe-no **na resposta**
   (`https://app.emdia.boraguarda.com/?de=grupo-<slug>`).

   Se a dúvida for de contabilista a sério (caso concreto, dívida, penhora), responde o que
   é geral e diz que **não substitui um contabilista**. Não inventes números.

3. NUNCA:
   - responder com o mesmo texto a comentários diferentes;
   - discutir com quem critica — agradece e sai;
   - pedir a ninguém para comentar ou partilhar de propósito.

4. MEDE, por publicação: comentários, partilhas, e cliques no link
   (conta os `?de=grupo-...` no funil do admin do Em Dia).

5. FECHO.
   Uma linha no `e2e_log` por publicação visitada, com `passo='comentario-<slug>'` e no
   `detalhe` quantos comentários respondeste. Se não havia comentários nenhuns, diz isso —
   é informação, não é falha.
