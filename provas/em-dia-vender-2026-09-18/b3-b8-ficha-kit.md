# B3 + B8 — Respostas prontas para a Play Console e kit de divulgação — 2026-09-21

> Missão `em-dia-vender-2026-09-18`. Blocos 3 (ficha da loja) e 8 (kit; a publicação em produção fica para depois do
> contrato de pagamentos — ordem obrigatória: perfil → produtos → papéis → produção).

## Quem fez o quê
- **ChatGPT Plus (gpt-5.5, opencode)**: `delegar.ps1 chatgpt … -Id b3-b8-ficha-kit` (301 s, anti-mentira PASSOU) escreveu
  `docs/PLAY-FICHA-RESPOSTAS.md` (514 linhas) e `docs/KIT-DIVULGACAO.md` (122 linhas) — mas SEM acentos. Segunda
  delegação `b3-b8-acentos` (294 s, anti-mentira PASSOU) repôs a ortografia: mesmas 514/122 linhas, 558/93 caracteres
  acentuados, sem BOM.
- **Claude Code**: conferiu contra o código o que o doc afirma — `EMAIL_REVISOR` existe (`lib/services/arranque.dart:36`,
  `login_screen.dart:26`; credencial em `_segredos/em-dia/revisor.env` de 6/09), localização só em primeiro plano com
  `LocationAccuracy.low` (`perto_store.dart:165`) mas o manifesto declara `ACCESS_FINE_LOCATION` além de COARSE (o doc
  marca «POR CONFIRMAR» se a Play exige declarar «precisa» pelo tipo de permissão — está certo marcar), ids das
  subscrições iguais aos de `compras.dart`; sem preços (0 «€», 0 «3,49»), sem «em breve», 10 «POR CONFIRMAR» honestos.

## O que ficou
- `docs/PLAY-FICHA-RESPOSTAS.md`: ficha pt-PT/pt-BR (nome ≤30, curta ≤80, longa), categoria «Finanças» + etiquetas,
  contactos, política de privacidade e URL de apagar conta, «Acesso à app» (modo «Vê como fica» + conta de revisor),
  anúncios (não), classificação IARC (PEGI 3 esperado), público-alvo 18+, notícias/COVID/governamental (não),
  funcionalidades financeiras (gestão pessoal; não é banco), saúde (não), Segurança dos dados tipo a tipo com «o que
  muda face ao declarado», notas ao revisor, os 4 produtos com nome/descrição sem preços.
- `docs/KIT-DIVULGACAO.md`: mensagem de uma linha PT/BR, 5 publicações Facebook (TVDE, estafetas, freelancers,
  brasileiros, carro), locução do vídeo 20–30 s com 4 cenas, link da loja, código promocional «__», 3 respostas prontas.
  **Nada foi publicado.**

## O que fica para a sessão com Chrome (não é do Danilo)
Colar as respostas nas 6 tarefas da consola e atualizar a Segurança dos dados; confirmar «localização precisa vs
aproximada» no formulário; conferir a lista de etiquetas disponíveis.
