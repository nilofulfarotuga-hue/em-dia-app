# Tarefa B3 + B8 — Respostas prontas para a Play Console (ficha, questionários, Data Safety, notas ao revisor) e kit de divulgação (sem publicar)

Projeto «Em Dia»: app Android (`pt.emdia.app`) + PWA, para trabalhadores independentes a recibos verdes em Portugal
(TVDE, estafetas, freelancers, imigrantes brasileiros): calcula recibos verdes, Segurança Social, IRS e IVA, agenda de
prazos com avisos, dinheiro que entra/sai, carro (inspeção, seguro, combustível), cofre do imposto, prova de rendimento em
PDF, perguntas à IA, guias. Grátis 30 dias; depois assinatura Pro ou Família/Frota pela Google Play (mês grátis inicial).
Lê primeiro para saber o que a app faz e recolhe: `README.md`, `docs/DESIGN-SYSTEM.md`, `site/index.html`,
`site/privacidade.html`, `docs/provas/play/ficha-20260906-112014.md` e `docs/provas/play/data-safety-20260907-010943.md`
(o que já está declarado), `provas/em-dia-vender-2026-09-18/b0-estado-real.md` (estado na consola: 5 de 11 tarefas
feitas; faltam classificação de conteúdo, público-alvo, apps governamentais, funcionalidades financeiras, saúde,
categoria + contactos), `lib/services/` (o que a app envia para fora: Supabase UE, Firebase Messaging, Gemini pela
Edge Function, Google Play Billing, Photo Picker para fotos de faturas, localização aproximada só em primeiro plano
para «perto de mim» do combustível — confirma no código antes de escrever; se não encontrares, escreve POR CONFIRMAR).
Escreve em PT-PT simples (o que vai para a ficha da loja em pt-PT com «tu»; a versão pt-BR com «você»). Sem emojis nos
textos oficiais. Nada de promessas que a app não cumpre. Não inventes números de utilizadores nem prémios.

## 1. `docs/PLAY-FICHA-RESPOSTAS.md` — tudo o que se vai clicar/colar na Play Console, secção a secção
Para cada secção: o caminho na consola, e a resposta exata (para colar), com uma linha «porquê» quando a escolha não é
óbvia.
- **Ficha da loja principal** (pt-PT) e tradução pt-BR: nome (≤30), descrição curta (≤80), descrição longa (≤4000, sem
  HTML, com parágrafos curtos e uma lista do que faz), o que dizer sobre o preço («grátis 30 dias; depois assinatura»).
- **Categoria**: Aplicação → «Finanças» (porquê); **etiquetas** (até 5, da lista da Play: escolhe as mais próximas —
  «Finanças pessoais», «Impostos», «Faturação»… escreve as que existirem como POR CONFIRMAR na lista).
- **Detalhes de contacto**: e-mail `emdia@boraguarda.com`, site `https://emdia.boraguarda.com`, telefone: não pôr.
- **Política de privacidade**: `https://emdia.boraguarda.com/privacidade`.
- **Acesso à app** (instruções para o revisor): a app pede um código por e-mail (sem palavra-passe). Escreve as
  instruções: «Use a conta de teste boraappbora+teste@gmail.com; o código chega ao e-mail… » — como o revisor não tem a
  caixa de correio, propõe a alternativa: **um modo «Vê como fica» sem conta** (existe: botão na entrada) e explica que
  todas as funcionalidades se veem aí; e pede que se crie na consola uma credencial de revisor (POR CONFIRMAR se o
  código pode ser fixo para um e-mail de teste — se sim, diz que fica a fazer no servidor; não inventes que já existe).
- **Anúncios**: não tem anúncios.
- **Classificação de conteúdo (IARC)**: categoria «Utilitário, produtividade, comunicação ou outro»; respostas Não a
  violência, sexo, linguagem, drogas, jogo; «a app permite compras digitais» Sim (assinatura); «partilha localização» Sim
  se o código confirmar a localização aproximada (POR CONFIRMAR); resultado esperado PEGI 3.
- **Público-alvo e conteúdo**: 18 anos ou mais (é para quem trabalha e paga impostos); não é para crianças; sem
  apelo a crianças.
- **Apps de notícias**: Não. **Apps de rastreio de contactos COVID**: Não. **Apps governamentais**: Não.
- **Funcionalidades financeiras**: a app NÃO é banco, NÃO dá empréstimos, NÃO faz pagamentos entre pessoas; é
  «gestão de finanças pessoais / impostos» — escolhe a opção correspondente e explica que a única compra é a assinatura
  pela Play.
- **Saúde**: nenhuma funcionalidade de saúde.
- **Segurança dos dados (Data Safety)**: lista completa, tipo a tipo, do que se recolhe, se é obrigatório, se é partilhado,
  finalidade, e se é encriptado em trânsito e se se pode pedir a eliminação: dados pessoais (nome, e-mail), informação
  financeira (rendimentos, despesas — introduzidos pela pessoa; extratos bancários importados de ficheiro; fotos de
  faturas), localização aproximada (só se o código confirmar), fotos (faturas, pelo Photo Picker), mensagens (perguntas à
  IA), identificadores do dispositivo (token de push), informação da app (tickets com dados técnicos). Práticas: dados
  encriptados em trânsito; a pessoa pode pedir a eliminação (URL `https://emdia.boraguarda.com/apagar-conta`); não se
  vende nem partilha para publicidade. Escreve o que muda face ao que está em `data-safety-20260907-010943.md`.
- **Notas ao revisor** (campo «Notas para a revisão»): 6–10 linhas.
- **Produtos**: os 4 ids que vão existir (`pro_mensal`, `pro_anual`, `familia_mensal`, `familia_anual`) com nome de
  loja e descrição de cada um (≤55/≤200 chars), sem preços.

## 2. `docs/KIT-DIVULGACAO.md` — kit para o Danilo usar quando quiser (NÃO publicar nada)
- Mensagem de uma linha (para WhatsApp) em PT-PT e PT-BR.
- 5 publicações para Facebook (uma por semana, cada com título, 3–5 frases, chamada para a loja, 3 hashtags), dirigidas
  a: TVDE, estafetas, freelancers, brasileiros recém-chegados, quem tem carro para o trabalho. Sem preços.
- Texto de 20–30 s para o vídeo (locução, PT-PT), com marcação de 4 cenas (o que aparece no ecrã).
- Link da loja (formato `https://play.google.com/store/apps/details?id=pt.emdia.app`) e o que dizer sobre o código
  promocional (a Play permite códigos de promoção para subscrições — POR CONFIRMAR na consola; deixa o campo «CÓDIGO: __»).
- 3 respostas prontas a comentários (é seguro? quanto custa? substitui o contabilista?).

## Critério de feito
Os dois ficheiros, sem inglês, sem preços, com POR CONFIRMAR onde não tens a certeza, e sem nada inventado sobre o que
a app faz (só o que está no código e no site). Cola a lista de secções do primeiro ficheiro na resposta.

## Proibido
Mexer em `lib/`, `supabase/`, `site/`, git; publicar; escrever preços; prometer funcionalidades que não existem.
