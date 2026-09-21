# Tarefa B9 — (1) revisão cruzada com contexto limpo, (2) relatório, digest e pendentes da missão `em-dia-vender-2026-09-18`

Estás na pasta do repositório da app «Em Dia». A missão «PRONTO A VENDER» (blocos B0–B9) foi executada por um maestro
(Claude Code) que delegou o trabalho pesado a motores (GLM sem quota → ChatGPT gpt-5.5). O teu trabalho tem duas partes.

## Material (só para ler)
- `docs/_material-vender/material/MARCOS-missao.md` — a linha de cada bloco (o que ficou feito, prova, próximo).
- `docs/_material-vender/material/DECISOES-D74-D75.md` — decisões novas.
- `docs/_material-vender/material/PENDENTE-DANILO-atual.md` — o que já está escrito como pendente.
- As provas de cada bloco (cópias em `docs/_material-vender/`): `b0-estado-real.md`, `b7a-funil.md`, `b7b-consentimento.md`,
  `b4a-papeis-site.md`, `b4b-b6-app.md`, `b5-fecho-mensal.md`, `b3-b8-ficha-kit.md`, `b2-precos-site.md`, e as
  `fontes-b4/`.
- O código e os docs que as provas citam (podes abrir qualquer ficheiro do repo para confirmar).

## Parte 1 — `docs/_material-vender/b9-revisao-cruzada.md` (tenta derrubar, não confirmar)
Para CADA bloco (B0, B2, B3, B4, B5, B6, B7, B8): lê a prova e verifica no repo o que dá para verificar sem rede
(ficheiros existem? o texto diz o que a prova diz? os testes citados existem? as chaves l10n existem nas duas línguas?
a migração tem o que a prova diz? há preços escritos à mão no site? há «em breve», emojis, inglês nos textos da app/site?
a plataforma ODR é citada em algum lado? há segredos no repo — procura `eyJ`, `sk_live`, `AIza`, `BEGIN PRIVATE`?).
Escreve uma tabela: bloco · afirmação da prova · o que verificaste (comando ou ficheiro:linha) · veredicto (confirmado /
não confirmado / contradiz) · gravidade. Depois uma lista «O que eu não consegui verificar aqui e porquê» (rede, consola,
browser). Sê seco e concreto; nada de elogios.

## Parte 2 — três ficheiros de texto em PT-PT simples (para o Danilo ouvir em voz alta)
1. `RELATORIO-em-dia-vender-2026-09-18.md` (raiz do repo): título; datas 18 a 21 de setembro de 2026; uma frase a dizer quem
   fez o quê (maestro Claude Code Opus 5; trabalho pesado ChatGPT Plus gpt-5.5 porque o GLM do plano Go ficou sem quota
   semanal; relatório escrito por ti); depois **uma linha por bloco, B0 a B9**, cada uma com três partes separadas por «·»:
   `Bloco N — <nome>: FEITO <1–2 frases> · PROVA <ficheiro ou número> · FICOU <o que falta e porquê; ou «nada ficou»>`.
   O B1 (marca: logo, capturas com moldura, vídeo, INPI) NÃO foi feito: precisa do Gemini no Chrome, que esta sessão não
   tinha — escreve isso como está. No B9 descreve este fecho e diz que o push final (CI: Android internal+alpha e web)
   é do Claude Code. Uma secção final «Para o Danilo» com UMA linha: aceitar o contrato de pagamentos da Google (Play Console
   → Definições → Perfil de pagamentos; o formulário fica preenchido e para no botão «Enviar»). E uma secção «Para a próxima
   sessão com o Chrome (não é do Danilo)» com as linhas que o material diz (id do bucket da Play, conta de serviço no Vault,
   permissão financeira, colar as respostas nas 6 tarefas da consola, Data Safety, produtos e prova de compra depois do
   contrato, B1 marca). Sem tabelas, sem emojis, sem inglês; números à portuguesa (1.234,56 €).
2. `docs/DIGEST-em-dia-vender-2026-09-18.md`: 10 a 20 linhas de texto corrido (sem títulos nem listas) para outros
   motores arrancarem sem ler tudo: o que está no ar (papéis em emdia.boraguarda.com/termos, /reclamacoes,
   /apagar-conta, /precos; funil no painel admin; estatísticas com consentimento na app; fecho de mês automático dia 1;
   respostas prontas da consola e kit em docs/), o que ficou (contrato de pagamentos = Danilo; produtos e compra a seguir;
   B1 marca; bucket da Play), onde estão as provas.
3. `docs/_material-vender/PENDENTE-DANILO-b9.md`: a secção «Missão em-dia-vender» reescrita: SÓ a linha do
   contrato de pagamentos para o Danilo, e por baixo «Não é teu — próxima sessão com Chrome» com as linhas acima.

## Critério de feito
Os 4 ficheiros existem; o relatório tem exatamente 10 linhas a começar por «Bloco 0» … «Bloco 9»; nenhum tem tabelas
(excepto a revisão cruzada, que é interna), emojis, «em breve» ou inglês. Não inventes nada que não esteja no material ou no
repo. Cola no fim da tua resposta a tabela de veredictos resumida (bloco → confirmados/não confirmados/contradiz).

## Proibido
Mexer em código, site, docs existentes, git; tocar em `docs/_material-vender/material/`.
