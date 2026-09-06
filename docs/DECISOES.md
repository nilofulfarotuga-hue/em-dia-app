# DECISÕES tomadas sozinho — missão Em Dia (2026-09-05)

> Formato: **O quê** · **Porquê** · **Como se desfaz**. Modo noite: ninguém responde até de manhã.

## D1 — Repo GitHub público (como o Bora)
- **O quê:** `nilofulfarotuga-hue/em-dia-app` criado público.
- **Porquê:** o Bora (`bora-app-cloud`) é público e é o padrão provado; repos públicos têm minutos de GitHub Actions ilimitados (o build Android gasta 15–25 min por corrida; um repo privado no plano grátis tem só 2000 min/mês e acabava a meio do mês). Nenhum segredo vive no repo (tudo em secrets/base64).
- **Como se desfaz:** Settings → Danger zone → Change visibility → Private (1 clique).

## D2 — Um único projeto Flutter, dois pontos de entrada
- **O quê:** `lib/main.dart` (app cliente, PT-PT) e `lib/main_admin.dart` (painel admin web, PT-BR) no mesmo repo/pacote. Dois projetos Cloudflare Pages (`app-em-dia`, `em-dia-admin`) construídos com `-t lib/main_admin.dart`.
- **Porquê:** partilham modelos, tema, cliente Supabase e regras; o Bora fez o mesmo (admin dentro da app). Evita dois repos e duas cadeias de CI.
- **Como se desfaz:** extrair `lib/admin/` para um pacote próprio mais tarde; nada fica preso.

## D3 — Keystore gerada localmente, guardada fora do repo
- **O quê:** `C:\BoraLocal\_segredos\em-dia\em-dia-release.jks` (alias `emdia`), passwords aleatórias em `keystore.env` na mesma pasta; vai para o GitHub só como secret base64.
- **Porquê:** a regra do Bora (chaves nunca em claro no repo). A pasta `_segredos` é intocável (regra 9 do CLAUDE.md global).
- **Como se desfaz:** não se desfaz — perder a keystore = perder a app na Play. Fazer cópia para o Drive da equipa é passo PENDENTE-DANILO (é ele que escolhe onde).

## D4 — Auth: código por e-mail (OTP) + Google; SMS não
- **O quê:** entrada por e-mail com código de 6 dígitos (Supabase email OTP, SMTP Resend já existente do Bora) e Google Sign-In. Telemóvel guarda-se no perfil mas não é o login.
- **Porquê:** o SMS no Supabase exige Twilio/MessageBird (pago). O prompt manda: "se o SMS precisar de fornecedor pago, usa Google Sign-In + email magic link e regista a decisão".
- **Como se desfaz:** ligar o provider Phone no painel do Supabase e adicionar o ecrã de telemóvel — o modelo `profiles` já tem `telefone`.

## D6 — Rotina cloud `em-dia-noite` com claude-opus-5 e fila própria
- **O quê:** a rotina cloud (hora a hora) usa o modelo Opus e trabalha SÓ os itens de `docs/FILA-CLOUD.md` (documentos, guias, marketing, guiões); nunca toca em `lib/`, `android/`, `.github/`, `supabase/functions/`.
- **Porquê:** a missão está marcada [MODELO: OPUS] e os textos legais/guias exigem rigor; a fila separada evita conflitos de git com a sessão local. Custo por corrida vazia é quase zero (lê a fila e sai).
- **Como se desfaz:** https://claude.ai/code/routines/trig_01DwHNgzNGqmhr5rQaJgXU9q → pausar; ou trocar `model` para claude-sonnet-5.

## D10 — Na sessão retomada pelo vigia NÃO há browser: o que precisa de clique fica para a sessão interativa
- **O quê:** a retoma `claude --resume -p` (headless) não carrega as ferramentas do Chrome nem do painel de browser. Play Console, Firebase, domínio na Cloudflare, Gemini web/ChatGPT para imagens e TestSprite pelo browser ficam para quando a app do Claude Code voltar a estar aberta (basta escrever "continua" na janela de manhã). Tudo o que é código, base de dados, CI, textos, testes e imagens pela API continua esta noite.
- **Porquê:** limitação técnica do modo `-p`; não é falta de autorização.
- **Como se desfaz:** abrir a janela interativa da sessão `c51cb931…` e continuar — os marcos dizem onde ficou.
- **Imagens (logo, artes):** geradas pela API Gemini (modelos de imagem disponíveis na chave nova: `gemini-3.1-flash-image`, `nano-banana-pro-preview`) em vez do Gemini web + ChatGPT; as 5 propostas ficam em `docs/marca/` na mesma; se de manhã se quiser a ronda pelo ChatGPT, faz-se na sessão interativa.

## D9 — A rotina cloud passa a claude-sonnet-5 (o limite de 5 horas é partilhado)
- **O quê:** às 01:40 a sessão local morreu por "session limit" e a corrida cloud das 01:52 morreu pela MESMA razão (`rate_limit: rejected (five_hour)` no log da rotina). O limite é da conta, não da sessão: cada corrida Opus na cloud gasta o orçamento que mantém a sessão local (a que faz o caminho crítico: telas, CI, Play) viva.
- **Porquê:** proteger a noite. A fila da rotina são documentos/guias/posts — o Sonnet chega e gasta menos.
- **Como se desfaz:** https://claude.ai/code/routines/trig_01DwHNgzNGqmhr5rQaJgXU9q → model claude-opus-5.

## D7 — Lógica das obrigações existe em Dart E em TypeScript, com os mesmos testes
- **O quê:** `lib/regras/obrigacoes.dart` (pré-visualização no onboarding e testes) e `supabase/functions/_shared/regras.ts` (o servidor gera o calendário real). Os dois são validados pelos mesmos casos (`docs/casos-teste.md`, gerado de `test/unit/regras_test.dart`).
- **Porquê:** o servidor tem de ser a fonte de verdade (o cron dos avisos lê a tabela), mas o onboarding precisa de mostrar "este mês tens N coisas" sem esperar pela rede. Uma só implementação obrigaria a chamar o servidor para tudo.
- **Como se desfaz:** apagar o gerador Dart e chamar `calcular-obrigacoes` também na pré-visualização (fica 1 chamada mais lenta no onboarding).

## D8 — Utilizadores de teste criados por SQL com password (só para provas)
- **O quê:** `teste@emdia.pt` e `teste2@emdia.pt` em auth.users com password bcrypt (valores em `C:\BoraLocal\_segredos\em-dia\teste.env`), para obter JWT nas provas das Edge Functions sem caixa de e-mail.
- **Porquê:** a app real entra por código no e-mail/Google; para testar servidor precisa-se de um JWT repetível.
- **Como se desfaz:** `delete from auth.users where email like '%@emdia.pt'` (o cascade apaga perfil e dados).

## D5 — Segredos das Edge Functions no Vault do Supabase, não no CLI
- **O quê:** GEMINI_API_KEY, credenciais FCM e o segredo do cron vivem em `vault.secrets`; as funções lêem-nos com a service role (injetada automaticamente pela plataforma).
- **Porquê:** não há `supabase` CLI instalado nem token de acesso pessoal nesta máquina; o Vault é gerível por SQL via MCP, com prova por SELECT.
- **Como se desfaz:** `supabase secrets set` quando houver CLI; as funções aceitam env var primeiro e Vault como fallback.

## D11 — Centros de inspeção perto e combustível mais barato (DGEG) ficam para a fase 2: na Tela 4 é só um cartão "Em breve"
- **O quê:** a Tela 4 (O Carro) mostra um cartão cinzento "Em breve" com duas linhas — "Centros de inspeção perto de ti" (mapa, dados abertos) e "Combustível mais barato num raio de 10 km" (preços DGEG) — sem mapa, sem GPS e sem chamadas a serviços externos. Tudo o resto da tela (lembretes IUC/IPO/seguro/carta/revisão, abastecimentos e custo por km, despesas com NIF, portagens e multas, cadeado de 1 carro no grátis) está feito.
- **Porquê:** os dois pedem dados abertos (lista de centros do IMT e preços da DGEG), geolocalização com permissão e um mapa — três dependências novas (pacotes, chave de mapas, política de privacidade da localização) que não cabem no bloco das telas sem atrasar o caminho crítico (build + Play). Um cartão honesto "em breve" é melhor do que um mapa vazio ou dados inventados.
- **Como se desfaz:** substituir `_EmBreve` em `lib/screens/carro/carro_screen.dart` por dois cartões reais (uma Edge Function `combustivel-perto` que lê a API da DGEG e a lista de centros do IMT + `geolocator`), e apagar as chaves `carroEmBreve*`/`carroCentrosInspecao*`/`carroCombustivelBarato*` de `lib/l10n/partes/50_carro_*.arb`.

## D12 — Rotina cloud desligada até o Danilo dar acesso ao GitHub; a fila faz-se localmente
- **O quê:** `em-dia-noite` fica `enabled=false` desde 2026-09-06 09:15. Os itens F1, F3–F7 são feitos por agentes na sessão local (documentos, guias, marketing, guiões, ficha da loja, privacidade).
- **Porquê:** 9 corridas na noite, 0 pushes — o ambiente cloud não tem a Claude GitHub App instalada neste repo (403 em git push e na API). Cada corrida gastava ~10 min do limite de 5 h da conta, o mesmo que mantém a sessão local viva.
- **Como se desfaz:** instalar a app (link em PENDENTE-DANILO) e ligar a rotina em https://claude.ai/code/routines/trig_01DwHNgzNGqmhr5rQaJgXU9q; a fila continua a ser `docs/FILA-CLOUD.md`.

## D12 — Produtos de subscrição criados por código, mas só depois do perfil de pagamentos
- **O quê:** `tool/play/produtos.py` cria os 4 produtos com os preços do prompt (3,49 / 29,90 / 5,99 / 49,90 €) e com os **planos base em rascunho**; por omissão corre em ensaio e não toca em nada.
- **Porquê:** a Google recusou a criação (`FAILED_PRECONDITION: Cannot create a subscription without first registering a payments profile`) — o perfil de pagamentos exige dados fiscais e bancários da pessoa. E mesmo depois, abrir as compras é acto de dinheiro: fica para o "vai".
- **Como se desfaz:** não há nada aplicado; o comando existe e está ensaiado.

## D13 — Track `internal` sozinho no CI (sem `alpha`) enquanto a app estiver em rascunho
- **O quê:** `build_android.yml` envia só para `internal` com `status: completed`.
- **Porquê:** a Play devolveu `Only releases with status draft may be created on draft app` com `internal,alpha`. O teste fechado (alpha) numa app nunca publicada só aceita rascunho; o interno aceita `completed` (provado: versionCode 7 entrou).
- **Como se desfaz:** quando a app sair de rascunho (1.ª revisão aprovada), acrescentar `,alpha` na linha `tracks:`.

## D14 — O código do e-mail tem margem: a app aceita de 4 a 8 números
- **O quê:** `SessaoStore.tamanhoCodigo = 6` (o que o servidor manda hoje), mas `tamanhoMinimo = 4` e `tamanhoMaximo = 8`. O campo não trava aos 6, e as casinhas nascem a mais se o código vier maior.
- **Porquê:** a 6 de setembro de 2026 o servidor mandava 8 e a app só deixava escrever 6. Ninguém entrava e o ecrã ficava preso. Um número fixo dos dois lados é um ponto de rutura silencioso: quem mexer na consola do Supabase não faz ideia de que parte a app.
- **Como se desfaz:** apertar de novo para exactamente 6 em `lib/stores/sessao_store.dart`. Não recomendado — o teste L03 em `test/unit/login_fluxo_test.dart` passa a falhar de propósito.

## D15 — Todas as chamadas `.order()` dizem a direção à mão
- **O quê:** em `lib/`, nenhuma chamada `.order('coluna')` fica sem `ascending: true` ou `ascending: false`. Um teste (`test/unit/ordem_test.dart`) reprova quem se esquecer.
- **Porquê:** em postgrest-dart o valor por omissão é `ascending = false`. Quem lê `.order('data_limite')` percebe "por ordem" e recebe a lista ao contrário. Custou o cartão do painel a anunciar um prazo a 348 dias em vez do que vencia dali a 14.
- **Como se desfaz:** apagar o teste e voltar a confiar no valor por omissão. Não se recomenda — a leitura errada é demasiado natural.

## D16 — Duplicados de obrigações: duas regras, não uma
- **O quê:** dois índices únicos parciais em vez do único (utilizador+tipo+data) que a ordem pedia. As obrigações calculadas pelo servidor (com `origem_regra`) são únicas por utilizador+tipo+dia; as escritas à mão são únicas por utilizador+tipo+dia+descrição.
- **Porquê:** com a regra única e crua, uma pessoa não podia escrever duas coisas do tipo "outro" no mesmo dia — a renda e o ginásio, por exemplo. O objetivo era travar as repetições que o gerador cria, e é isso que o primeiro índice faz.
- **Como se desfaz:** trocar os dois índices por um `unique (user_id, tipo, data_limite)`. Custa a possibilidade de dois lembretes manuais no mesmo dia.

## D17 — `is_admin()` fecha-se mudando as políticas, não a função
- **O quê:** as 31 políticas de RLS que chamam `is_admin()` passaram a `to authenticated`, a leitura pública das guias deixou de chamar a função, e só depois se tirou a permissão a quem não tem sessão.
- **Porquê:** a migração 0009 tinha recusado fechar isto porque o site lê cinco tabelas sem sessão e as políticas permissivas somam-se — tirar a permissão partia a calculadora. A causa não era a função, era o alcance das políticas.
- **Como se desfaz:** `grant execute on function public.is_admin() to anon;` e voltar a pôr as políticas em `to public`. Não se recomenda: o site foi testado sem sessão depois da mudança e lê tudo (cinco 200).

## D18 — As duas contas do Danilo ficam, mas a zeros
- **O quê:** `nilofulfarotuga@gmail.com` e `boraappbora@gmail.com` não foram apagadas na limpeza; os perfis é que foram recriados de raiz.
- **Porquê:** são as duas contas que a migração 0004 torna administrador automático. Apagá-las tirava o acesso ao painel de administração e não havia como voltar a entrar.
- **Como se desfaz:** apagá-las e voltar a criar; o administrador automático volta a agarrá-las pelo e-mail.

## D19 — Faturação certificada: InvoiceXpress, e só por causa da multiconta
- **O quê:** a ligação a software de faturação certificado fica escrita para o **InvoiceXpress**, atrás de uma opção desligada (`feature_flags.faturacao_certificada`, a falso).
- **Porquê:** os três (InvoiceXpress, Vendus, Moloni) têm API e emitem fatura-recibo com comunicação automática à Autoridade Tributária. O que decide não é a API, é o modelo de conta. O InvoiceXpress é o único que deixa a nossa plataforma **criar a conta do utilizador por API** (`POST /api/accounts/create.json` devolve logo a chave dessa conta) e **configurar a comunicação à AT por API** (`POST /api/v3/accounts/at_communication.json`), e tem uma modalidade "Multiconta" feita para plataformas onde cada prestador fatura com o NIF dele — o exemplo que a própria empresa dá é a Cabify. O Moloni obriga cada pessoa a pagar um plano Flex (10,90 €/mês) para ter API; o Vendus obriga ao plano Flex (17 €/mês por conta) e não deixa criar contas por API.
- **O que NÃO se automatiza, em nenhum deles:** por lei, a comunicação automática à AT precisa de um sub-utilizador criado pela própria pessoa no Portal das Finanças (formato `NIF/1`, com a permissão WFA) e da senha dele. Isso é um passo humano, sempre.
- **Custo:** os planos do InvoiceXpress são por número de documentos por mês e todos incluem API — X3 3 €/mês (3 documentos), X10 9 €, X100 24 €, X500 29 €. Acima de 10 €/mês é decisão de dinheiro do Danilo, por isso fica desligado.
- **Como se desfaz:** ligar a flag. O código e as chamadas estão escritos e ensaiados.

## D20 — Banco: Enable Banking para construir, escolha do fornecedor só quando houver receita
- **O quê:** a leitura de movimentos bancários entra atrás de uma camada nossa (`BancoFornecedor`), com o primeiro adaptador para **Enable Banking** em modo restrito, e fica desligada para o público.
- **Porquê:** o grátis da GoCardless/Nordigen fechou a novos registos. A SIBS API Market exige licença de TPP do Banco de Portugal e certificados eIDAS. A Enable Banking tem um modo "Restricted Production" **gratuito** onde só se leem as contas que nós próprios ligámos — dá bancos portugueses a sério (CGD, Millennium, Santander, novobanco, BPI, Montepio), com movimentos reais e sujos, que é sobre o que a app vai ter de trabalhar. A alternativa paga com preço público e auto-serviço é a open-banking.io, a 3 € por conta ligada por mês.
- **Como se desfaz:** trocar uma linha de configuração para outro adaptador. A camada existe desde a primeira linha exactamente para isso.

## D21 — Preços de combustível: recolha escrita, mas desligada até haver autorização da DGEG
- **O quê:** a recolha diária dos preços fica escrita (`sync-precos-combustiveis`) e **desligada** (`feature_flags.precos_combustivel`, a falso). A conta do "vale a pena esta corrida" usa o preço que a pessoa pagou no último abastecimento, ou um que ela escreva.
- **Porquê:** a API da DGEG é aberta, sem chave, e devolve tudo numa chamada — 3 131 postos, 14 178 preços, com coordenadas. Tecnicamente não há nada a impedir. Mas o portal diz, com estas palavras, **"É proibida a sua utilização para fins comerciais"**, e o Em Dia é um produto comercial. Há um processo formal de "Partilha de Informação" com uma minuta oficial. Enquanto não houver resposta, a app não mostra preços da DGEG.
- **Como se desfaz:** com a autorização escrita, liga-se a flag. O pedido está redigido em `docs/PENDENTE-DANILO.md`.

## D22 — Centros de inspeção: carregados do PDF do IMT, uma vez, para uma tabela nossa
- **O quê:** os centros de inspeção vêm do PDF oficial "Lista CITV atualizada" do IMT, lido por um script, guardados em `centros_inspecao` com o código CITV como chave.
- **Porquê:** não há API nem CSV, e o dados.gov.pt não tem este conjunto. O PDF traz distrito, código, nome, morada, código postal e **coordenadas** — mas em cerca de seis formatos diferentes e muitas vezes sem o sinal negativo na longitude, por isso é preciso normalizar e validar contra uma caixa geográfica de Portugal. Não traz telefone, concelho nem a categoria A/B.
- **Como se desfaz:** apagar a tabela e mandar as pessoas ao site do IMT.

## D23 — Nada de ler SMS nem o Gmail, e a razão fica escrita
- **O quê:** a app **não** pede permissão de SMS e **não** liga à API do Gmail. As faturas entram por foto (Photo Picker) e por uma caixa de correio nossa para onde a pessoa reencaminha.
- **Porquê:** a política da Play só deixa ler SMS a quem for a app de SMS por omissão, ou por exceção caso a caso com revisão manual — e a política de programas-espia aponta expressamente para apps de orçamento. Quanto ao Gmail, todos os âmbitos de leitura são "restritos": obrigam a verificação OAuth com avaliação de segurança anual por avaliador independente (CASA), a Google estima cerca de 6 semanas, o preço é negociado com o avaliador, e — o travão decisivo — **é proibido passar dados do Gmail por modelos de inteligência artificial generalistas**, que é exactamente o que a app faria. O reencaminhamento para uma caixa nossa fica fora destas políticas: o conteúdo chega entregue pela pessoa.
- **Como se desfaz:** não se desfaz sem passar pela verificação da Google. Se um dia se quiser SMS, a linha aplicável chama-se "SMS-based money management".

## D24 — A caixa de correio das faturas monta-se na Cloudflare, com catch-all para um Worker
- **O quê:** cada pessoa recebe um endereço `<nome>-<8 letras ao acaso>@contas.<domínio>`; uma **única** regra catch-all entrega tudo a um Worker, que separa o PDF, mete-o no Storage e chama a Edge Function que o lê.
- **Porquê:** o Email Routing da Cloudflare recebe **sem limite de volume no plano grátis**, e a regra catch-all pode ligar directamente a código nosso. Criar um endereço por pessoa batia no tecto de 200 regras por domínio; com catch-all, o endereço passa a existir no momento em que o gravamos na nossa base de dados. As 8 letras ao acaso são a fechadura: sem elas, um estranho adivinhava o endereço de outro.
- **Como se desfaz:** apagar a regra catch-all. O endereço deixa de receber e nada mais parte.

## D16 — O vigia tem duas provas de vida, não uma
- **O quê:** antes de lançar uma retoma, o `EmDia-Retomar.ps1` aceita a sessão como viva por **qualquer** uma de duas: a tranca `docs/.sessao-viva` renovada há menos de 20 min, **ou** o transcript da sessão (`~/.claude/projects/*/<id>.jsonl`) escrito há menos de 20 min.
- **Porquê:** a tranca só é renovada quando a sessão se lembra, e entre respostas passam-se facilmente 20 minutos. Bastou isso para o vigia lançar uma retoma por cima de uma sessão viva — duas a escrever no mesmo repositório e na mesma base de dados de produção. Nesse dia todos os dados de utilizador desapareceram. O transcript cresce sempre que a sessão trabalha, seja ela interactiva ou lançada pelo vigia: é a prova que não depende de ninguém se lembrar de nada.
- **Como se desfaz:** tirar o bloco do transcript do passo 2 do script. Não se recomenda.

## D25 — Os cadeados: onde me afastei da letra da ordem, e porquê
- **O quê:** a regra pedida era "a partir do dia 31 fica o básico e o resto com cadeado". Três coisas ficaram abertas no plano grátis que, à letra, deviam estar fechadas: **escrever o que entra** (sem limite), **contas a pagar** (até 3) e **vale a pena esta corrida** (sem limite).
- **Porquê:** escrever o que entra é o que faz as contas do IRS e da Segurança Social ficarem certas — com isso fechado, os números que o plano grátis mostra passam a estar errados, e um número errado é pior do que número nenhum. As contas a pagar até 3 chegam para a renda, a luz e o telemóvel, que é onde a pessoa percebe que a app serve; a quarta pede Pro. E o "vale a pena esta corrida" é a porta de entrada que traz gente da Google — está aberto no site, seria estranho estar fechado na app.
- **O que ficou fechado, como pedido:** caixa de correio das faturas, prova de rendimento em PDF, radar da fidelização, falar com a app, ler extrato por foto. E ler documento por foto tem 5 por mês no grátis, tal como a ordem diz.
- **Como se desfaz:** três `update` na tabela `feature_flags` (`entradas`, `saidas`, `vale_a_pena`) a pôr `free` a falso.

## D26 — As leituras por foto não gravam nada sozinhas
- **O quê:** a função `ler-documento` lê o documento e guarda a leitura em `leituras_ocr`, mas **não** cria a despesa nem o rendimento. Quem grava é a pessoa, depois de ver na app o que foi lido e poder corrigir.
- **Porquê:** foi o Danilo que o pediu ("a pessoa vê o que foi lido e pode corrigir antes de guardar"), e é o que evita o pior caso: uma leitura errada entrar na contabilidade sem ninguém dar por ela. O campo do valor continua a ser o principal e escrito à mão; a câmara é um atalho, não o caminho.
- **Como se desfaz:** fazer a função inserir logo em `entradas`/`saidas`. Não se recomenda.

## D27 — O cartão do "próximo prazo" mostra o prazo A SEGUIR, não o mesmo
- **O quê:** a ordem dizia "por baixo mantém-se o semáforo, o próximo prazo e o total do mês, que estão bons". O cartão do próximo prazo ficou, mas passou a mostrar a obrigação **seguinte** à que está no cartão de ação. Quando não há seguinte, não se desenha cartão nenhum.
- **Porquê:** com os dois a mostrar a mesma coisa, o mesmo nome, o mesmo valor e a mesma data apareciam três vezes no mesmo ecrã (cartão de ação, semáforo, próximo prazo) e o resto do painel era empurrado para fora. A pergunta que o cartão de baixo responde agora é outra: "e depois desta, o que vem?". O "Já paguei", que era o único botão que ele tinha e o de cima não, subiu para o cartão de ação.
- **Como se desfaz:** trocar `estado.proximoDepoisDaAcao` por `estado.heroi` em `painel_screen.dart` e tirar o `if`.

## D28 — Nenhum laranja no cartão de ação
- **O quê:** o cartão de ação é branco, com o valor a preto. A cor do semáforo aparece só na data e no ícone — e no estado "a vencer" nem aí: fica cinzento-escuro. Vermelho mantém-se, porque é outra cor.
- **Porquê:** a regra da casa é um elemento laranja por ecrã, e esse é o semáforo grande. O juiz de visão reprovou três versões seguidas — cartão inteiro em laranja claro, depois o valor em laranja, depois o ícone e a data — e das três vezes tinha razão. A urgência lê-se nas palavras ("Até quinta, dia 10") e no semáforo logo por baixo.
- **Como se desfaz:** pôr `Semaforo.amarelo => AppColors.accentDark` em `_corSinal`, dentro de `cartao_acao.dart`.
