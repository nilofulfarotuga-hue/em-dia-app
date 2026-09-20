# Tarefa B4a — Papéis para vender em Portugal: termos, condições da assinatura, reclamações, apagar conta, RGPD, regras com fonte

Projeto «Em Dia» (app para trabalhadores independentes em Portugal; assinatura vendida pela Google Play). O site público
vive em `site/` (HTML estático, publicado em https://emdia.boraguarda.com; `site/privacidade.html` é o modelo de estilo e
de tom — copia-lhe a cabeça, o CSS, o redirect e a linguagem). Escreve **em PT-PT, tratamento por «tu», frases curtas,
linguagem simples**; jargão só com explicação entre parênteses. Sem emojis. Sem inglês (fora nomes próprios).

## Fontes (LÊ-AS; só podes afirmar o que lá está)
Pasta `provas/em-dia-vender-2026-09-18/fontes-b4/`:
- `dl-24-2014.md` — DL 24/2014 (contratos à distância): art. 4.º (informação pré-contratual), 10.º (14 dias de livre
  resolução), 11.º (como se exerce), 12.º (reembolso em 14 dias), 15.º (serviço a começar dentro do prazo), 17.º
  (exceções — alínea l: conteúdos digitais sem suporte material com consentimento expresso), 29.º (imperatividade).
- `diretiva-2011-83-consolidada.md` — a diretiva de origem (arts. 6, 8, 9, 11, 14, 16).
- `diretiva-2013-11-ral.md` — art. 13.º: o comerciante informa o consumidor da(s) entidade(s) de RAL (resolução alternativa
  de litígios) de que depende, com o sítio web, no site e nas condições gerais. Em Portugal é a Lei 144/2015 (art. 18.º)
  — o texto nacional não foi lido (página só com JavaScript): diz «Lei n.º 144/2015, de 8 de setembro» sem citar o número
  do artigo nacional como certo.
- `rgpd-2016-679.md` — RGPD arts. 6, 7, 12, 13, 15, 17, 20, 30.
- `play-subscricoes.md`, `play-cancelar-subscricao.md`, `play-reembolsos.md`, `play-apagar-conta.md` — páginas de ajuda
  da Google Play (pt).

Factos fixos (fonte: `docs/PENDENTE-DANILO.md`, `docs/DECISOES.md`, `site/privacidade.html`): responsável = Danilo
Fulfaro da Silva, Guarda, Portugal; e-mail de apoio `emdia@boraguarda.com`; dados na Supabase (UE, Paris);
avisos por Firebase Cloud Messaging; a app não usa localização em segundo plano; apagar a conta faz-se em
«Mais → Definições → Apagar a conta» ou por e-mail (5 dias úteis); autoridade de dados = CNPD (https://www.cnpd.pt).

Livro de reclamações eletrónico: https://www.livroreclamacoes.pt/ (é a plataforma oficial; não cites o número do
decreto-lei porque não foi lido). Entidade de RAL: **CNIACC — Centro Nacional de Informação e Arbitragem de Conflitos de
Consumo**, https://www.cniacc.pt (competência: «todo o território nacional nas zonas não abrangidas por outras entidades»;
escritório em Viseu 232 451 135, viseu@cniacc.pt) — escreve «POR CONFIRMAR na lista da Direção-Geral do Consumidor se a
Guarda tem centro regional próprio». A plataforma europeia de resolução de litígios em linha (ODR) foi ENCERRADA
(Regulamento (UE) 2024/3228) — **não a cites** nem ponhas o link ec.europa.eu/odr.

Preços: NÃO escrevas valores; diz «o preço aparece na app e na Google Play antes de confirmares». Planos: «Pro» e
«Família/Frota» (mensal e anual), mês grátis inicial gerido pela Google Play. Cancelar: na Google Play (Play Store →
Pagamentos e subscrições → Subscrições), como diz `play-cancelar-subscricao.md`.

## O que escrever

### 1. `site/termos.html` — Termos de utilização e condições da assinatura
Secções (h2): Quem somos · O que a app faz (e o que NÃO é: «não é aconselhamento fiscal nem contabilidade; os números
vêm de fontes oficiais e podem mudar; confirma com o teu contabilista, a Segurança Social ou as Finanças») · A tua
conta · O mês grátis e a assinatura (o que inclui, quem cobra = Google Play, renovação automática, como cancelar, o que
acontece quando cancelas: fica até ao fim do período pago) · **Desistir em 14 dias (livre resolução)** — «Tens 14 dias
depois de assinares para desistir sem dar razões (DL 24/2014, art. 10.º). Pede na Google Play ou escreve-nos para
emdia@boraguarda.com; devolvemos tudo o que pagaste nesse período, no máximo em 14 dias (art. 12.º). Como a app começa a
funcionar logo, ao assinares aceitas que comece dentro destes 14 dias — mesmo assim honramos a devolução total.» Inclui um
modelo de mensagem de desistência de 3 linhas · Reembolsos fora dos 14 dias (política nossa: erro nosso ou app sem
funcionar → devolvemos; pedido pela Google Play segue as regras da Google, `play-reembolsos.md`) · Suporte (dentro da app
em «Mais → Ajuda» ou e-mail; respondemos em 2 dias úteis) · Reclamações e litígios (livro de reclamações eletrónico +
CNIACC com link + POR CONFIRMAR) · Dados pessoais (link para privacidade) · Mudanças a estes termos (avisamos na app
com 30 dias) · Lei aplicável (portuguesa; tribunais portugueses, sem prejuízo dos direitos do consumidor) · Data e versão.

### 2. `site/reclamacoes.html` — Reclamações
Curto: 1) fala connosco primeiro (app/e-mail, 2 dias úteis); 2) livro de reclamações eletrónico (link);
3) CNIACC (link, contactos, POR CONFIRMAR); 4) CNPD para dados. Sem citar a plataforma ODR.

### 3. `site/apagar-conta.html` — Apagar a conta (URL fora da app, exigido pela Play, `play-apagar-conta.md`)
Passos dentro da app; caminho por e-mail para quem não consegue entrar (assunto «Apagar a minha conta Em Dia», do e-mail
com que entrava; 5 dias úteis); o que se apaga (tudo: perfil, recibos, carro, fotos, perguntas, avisos) e o que fica
(nada, fora cópias técnicas até 30 dias); a assinatura cancela-se na Google Play (apagar a conta não cancela a cobrança
da Google — diz isto claramente).

### 4. `site/privacidade.html` — atualizar, sem partir o que existe
- Corrige o erro «manda um e-mail de boraappbora@gmail.com» → «manda um e-mail para emdia@boraguarda.com, a partir do
  endereço com que entravas na app».
- Acrescenta «Estatísticas de utilização» (interruptor nas Definições, desligado por defeito; conta só 6 tipos de
  evento: abrir a app, acabar o início, ver o plano, começar/acabar uma compra, cancelar; sem valores nem textos; base
  legal = consentimento, art. 6.º-1-a e 7.º do RGPD; podes desligar quando quiseres).
- Acrescenta «Compras» (a Google Play trata o pagamento; nós só recebemos o comprovativo técnico da compra e o estado da
  assinatura; não vemos o teu cartão).
- Liga «Os teus direitos» aos artigos (acesso 15.º, apagamento 17.º, portabilidade 20.º) e a `/apagar-conta`.
- Mantém o redirect e o estilo. Atualiza a data.

### 5. `docs/RGPD-REGISTO-TRATAMENTOS.md` — registo das atividades de tratamento (RGPD art. 30.º)
Tabela por tratamento: finalidade · categorias de dados · titulares · base legal · destinatários (Supabase UE, Google FCM,
Google Play, Gemini para a IA — só o texto da pergunta, sem nome) · prazo de conservação · medidas de segurança
(RLS, Vault, TLS). Um bloco por: conta/perfil, recibos e dinheiro, carro, fotos de faturas (OCR), perguntas à IA,
avisos push, assinaturas, estatísticas de utilização (consentimento), suporte/tickets, painel admin (auditoria).
Marca «POR CONFIRMAR» no que não conseguires ver no código.

### 6. `docs/REGRAS-PT-2026.md` — cada regra legal usada nos papéis, com fonte e data
Tabela: regra · onde se aplica (termos/reclamações/privacidade/app) · fonte (ficheiro em `fontes-b4/` + URL) ·
data em que foi lida (2026-09-20) · confiança (confirmada / por confirmar). Inclui: 14 dias; devolução em 14 dias;
exceção dos conteúdos digitais (17.º-1-l) e a nossa opção de honrar a devolução; informação pré-contratual (4.º);
dever de informar a entidade de RAL (Diretiva 2013/11 art. 13.º / Lei 144/2015); ODR encerrada (Reg. 2024/3228);
livro de reclamações eletrónico; RGPD 6/7/13/15/17/20/30; Play: cancelar, reembolsos, apagar conta.

### 7. Ligações
- `site/index.html`: no rodapé, ao lado de «Política de privacidade», acrescenta «Termos», «Reclamações» e «Apagar a conta».
- `site/sitemap.xml`: as 3 páginas novas.
- `site/testes/verifica.mjs`: acrescenta asserções para `/termos`, `/reclamacoes`, `/apagar-conta` (200, título certo,
  contêm «14 dias» / «livroreclamacoes.pt» / «emdia@boraguarda.com») seguindo o padrão das de `/privacidade`.

## Critério de feito
Os 3 HTML novos + privacidade atualizada + 2 docs + rodapé + sitemap + testes. `node site/testes/verifica.mjs` NÃO se corre
aqui (é contra o site no ar — quem publica corre). Confirma com `node --check site/testes/verifica.mjs` e verifica que
cada HTML novo tem `<title>`, `<h1>` e fecha `</html>`. Cola a lista de ficheiros tocados e as primeiras 10 linhas de
`docs/REGRAS-PT-2026.md` na resposta final.

## Proibido
Inventar prazos, taxas, valores, artigos ou entidades que não estejam nas fontes; citar a plataforma ODR; escrever preços;
mexer em `lib/`, `supabase/`, git, ou publicar. Não uses «em breve».
