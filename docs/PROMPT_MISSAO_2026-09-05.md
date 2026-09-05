# PROMPT DA MISSÃO — em-dia-missao-total-2026-09-05

> Guardado tal e qual chegou, no primeiro commit, como manda a secção 1 do prompt.
> Duas partes: o prompt original e a adenda (modo noite) que chegou na mesma sessão.

---

## PARTE 1 — PROMPT ORIGINAL

[MODELO: OPUS] — Claude Code, janela Pro, SESSÃO NOVA
Pasta ao abrir: `C:\Users\danil\Desktop\projetosflutter` (a missão cria lá dentro `em_dia\`)
Sessão: `em-dia-missao-total-2026-09-05`
⚠️ MODO PROTECÇÃO TOTAL ⚠️
Invoca o orquestrador CEO-AI em `.claude/skills/ceo-ai/` (global em `~/.claude`, funciona em qualquer pasta desde o QG) e deixa-o conduzir a missão inteira. Nunca chames skills diretas por `SKILL: xyz`. Usa TODAS as skills e agentes globais do QG que fizerem sentido (site-premio, juiz, olho/golden, roteador, os agentes de teste, o Bora Studio para vídeo), o plugin CTX, e os MCPs (Supabase, Stripe, GitHub via gh, Cloudflare via wrangler). Esta missão é uma APP NOVA, separada do Bora. Não tocas no repo `bora-app-cloud` nem no projeto Supabase do Bora (`ojykpzwqrtusfeakzrna`) em nada, exceto para COPIAR padrões (workflows, tema, estrutura de pastas, service account da Play, scripts de deploy).

### 0. O QUE É ESTA MISSÃO (lê tudo antes de tocar em código)

Criar, testar, publicar e preparar a divulgação da app Em Dia — assistente do trabalhador independente a recibos verdes + assistente do carro, para Portugal. Clone melhorado do MEI Fácil (Brasil), do Drivvo (Brasil) e do Artur (Portugal, único concorrente direto, 5€/mês, feito para freelancer de escritório e computador).
O Danilo quer entregar ESTE prompt e não fazer mais nada. Regras absolutas da missão:

1. Zero trabalho manual para o Danilo. Tudo o que for painel web (Play Console, Cloudflare, AI Studio, Google Cloud) fazes tu com o agente de clique/browser do PC. Se no fim faltar uma autorização que só a pessoa pode dar, deixas a página certa aberta no ecrã e avisas no relatório "só falta o teu clique em X". Nunca escreves "vai a Y, depois a Z".
2. Faz uma coisa, testa, prova, só depois a seguinte. Cada bloco termina com prova material (comando corrido com saída, captura, SELECT, ficheiro com timestamp). Sem prova, o bloco não está feito. Nunca declarar feito o que não foi feito (padrão ZERO MENTIRAS).
3. Pensa no futuro em cada decisão: a app vai crescer (iOS pela web, painel admin, contabilistas parceiros, mais módulos). Nada hardcoded que amanhã custe refazer: valores legais em tabela editável, textos em ficheiros de tradução, feature flags para o plano.
4. Idioma: app em PT-PT (português europeu, tratamento por "tu" simples e humano); o painel admin em PT-BR; a IA responde na variante que o utilizador escrever (PT-PT ou PT-BR).
5. Linguagem da app: como para uma criança de 5 anos. Zero jargão sem explicação entre parênteses.
6. Motor de IA da app: Gemini Flash (barato). Chave nova num PROJETO NOVO do AI Studio (o projeto antigo está preso a teto de gasto — cria projeto novo pelo menu Projetos e gera a chave lá, com o agente de clique). REGRA GEMINI PELO CLIQUE: se a API der 403 "spend cap"/429, não paras nem pedes para subir teto — usas o Gemini web (gemini.google.com, sessão iniciada) pelo clique para o que for geração de imagem/texto da missão.
7. Imagens e artes (logo, ícone, capturas da loja, artes dos posts): geras no Gemini web E no ChatGPT (chatgpt.com, sessão iniciada no Chrome), escolhes o melhor; padrão do Danilo: imagem impressionante de cinema, não cartaz plano. Nunca imagem genérica de banco.
8. Vídeos: pelo Bora Studio (sistema do Danilo, Wan no Kaggle) — nunca serviço pago. Se faltar capacidade, ferramenta grátis e integra-la.
9. Uma sessão, um repo. Se precisares de dividir, escreve marcos em disco e continua na MESMA sessão.
10. Ao fim de cada bloco: commit + push + linha no relatório. Relatório final SEMPRE em ficheiro.

### 1. FUNDAÇÃO (bloco 1)

Repo: cria `C:\Users\danil\Desktop\projetosflutter\em_dia\` e o repositório GitHub `nilofulfarotuga-hue/em-dia-app` (gh já autenticado). Branch principal `main`. Guarda no primeiro commit este prompt em `docs/PROMPT_MISSAO_2026-09-05.md`.
Flutter: um só app (cliente) + painel admin Flutter Web. Copia do Bora o que já está provado: estrutura de pastas, tema com fonte Inter (a lição dos botões com `fontFamily: null` — todos os estilos com Inter explícito), `background_location` NÃO é preciso aqui (não pedir permissão de localização em segundo plano — evita a política que rejeitou o Bora), Photo Picker do Android para fotos (não o seletor antigo). Package: `pt.emdia.app`. Design system: verde `#16A34A` como cor "em dia", laranja `#F97316` como "a vencer", vermelho `#DC2626` como "passou", fundo claro, cantos 16, Inter.
Supabase (JÁ CRIADO pela Claude.ai — não cries outro): projeto `em-dia`, ref `tgdmgtmknbwhcqoxtjbs`, região eu-west-3, plano grátis, na organização "Bora app". Cria migrations (via MCP ou CLI) para:

* `profiles` (user_id, tipo_atividade [tvde|estafeta|servicos|freelancer|sem_atividade|so_carro], data_abertura, regime_iva [isento_53|normal], faturou_mais_15k_ano_anterior bool, variante_pt [pt|br], plano [free|pro|familia], trial_ate timestamptz, criado_em)
* `rendimentos` (user_id, mes, valor_bruto, origem [manual|foto], comprovativo_url)
* `obrigacoes` (user_id, tipo, descricao, data_limite, valor_estimado, estado [pendente|pago|passado], comprovativo_url, origem_regra)
* `carros` (user_id, matricula, mes_matricula, ano_matricula, seguradora, seguro_renova_em, ultima_ipo, proxima_ipo, km_atual, categoria [proprio|alugado_frota])
* `abastecimentos`, `despesas_carro`
* `regras_legais` (chave, valor numérico/texto, ano, fonte_url, verificado_em) — carregada com a secção 4 deste prompt
* `guias` (slug, titulo, corpo_pt, corpo_br, audio_url)
* `conversas_ia` (user_id, pergunta, resposta, custo_tokens, criado_em)
* `tickets_suporte`, `eventos_push`, `assinaturas` (user_id, produto_id, estado, comprovativo_play, renova_em)
* RLS em TODAS as tabelas (utilizador só vê o seu; admin vê tudo por claim `role=admin`). Edge Functions: `calcular-obrigacoes` (gera/atualiza `obrigacoes` a partir do perfil + regras), `ia-responder` (Gemini com base de conhecimento + dados do utilizador), `ler-extrato` (OCR Gemini de foto de extrato Uber/Bolt/Glovo → rendimento), `avisos-cron` (pg_cron diário 09:00 Lisboa → push FCM com as mensagens da secção 6), `validar-compra-play` (verifica recibo da Play Billing), `suporte-auto`.
* Prova: `SELECT` às tabelas, chamada real a cada Edge Function com saída.

Auth: telemóvel + código SMS (Supabase phone auth — se o SMS precisar de fornecedor pago, usa Google Sign-In + email magic link e regista a decisão) e Google. Sem palavra-passe.
FCM: novo projeto Firebase `em-dia` (agente de clique), `google-services.json` no repo por secret, nunca em claro.
CI: copia `build_android.yml` do Bora → `em-dia-app`. GitHub Actions, versionCode auto-incrementado pelo CI (NUNCA à mão no pubspec), keystore nova `em-dia-release.jks` guardada em secret, service account da Play reutilizada (a mesma do Bora — tem acesso à conta developer nilofulfarotuga@gmail.com). Tracks: `internal,alpha` (produção só depois de aprovado — NÃO copies a regra do Bora de publicar direto em produção). `build_web_deploy.yml` para o painel admin e a app web → Cloudflare Pages `em-dia-admin.pages.dev` e `app-em-dia.pages.dev` (token Cloudflare já existe em `bora-site/.env`; a app web é o caminho do iPhone, como no Bora). Prova: run verde ao nível de step, bundle no track interno.

### 2. AS TELAS (bloco 2 — cada tela: constrói → golden test em 3 tamanhos → juiz de visão → corrige → próxima)

Tela 0 — Onboarding (2 min, botões grandes, uma pergunta por ecrã)
"O que fazes?" → Motorista TVDE / Estafeta / Serviços (cabelo, obras, limpeza…) / Freelancer / Ainda não abri atividade / Só quero o carro "Quando abriste atividade?" (data) → deduz isenção do 1.º ano de Segurança Social e o fim dela "No ano passado faturaste mais de 15.000€?" → regime de IVA "Tens carro?" → matrícula (deduz mês do IUC e idade → inspeção), seguro (mês), última inspeção, próprio ou alugado à frota "Quanto ganhas por mês, mais ou menos?" → primeira simulação Fim: "Pronto. Este mês tens [N] coisas: […]. Eu aviso-te. Nos próximos 30 dias tens tudo aberto, sem cartão."

Tela 1 — Painel "Estás em dia?" (a tela de todos os dias)
Semáforo grande: VERDE "Está tudo em dia" / AMARELO "Tens 1 coisa a vencer em 5 dias" / VERMELHO "Tens 1 prazo passado — resolve agora". Três cartões: Este mês pagas (lista com valor e dia), Guardar para o IRS (valor sugerido este mês), Próximo prazo (contagem regressiva). Botão "Já paguei" em cada item → verde + foto do comprovativo (Photo Picker). Frase humana em baixo que muda.

Tela 2 — Recibos Verdes

* Calculadora: valor do recibo → bruto, retenção (23% padrão, 25% por opção, ou dispensa se ano anterior < 15.000€ e cliente com contabilidade organizada), IVA (23% ou isento art. 53.º com a menção M10 pronta a copiar), líquido real.
* Registo de rendimento mensal (manual ou foto do extrato Uber/Bolt/Glovo → `ler-extrato`).
* Vigia do IVA: barra "estás em X€ de 15.000€"; aviso aos 12.000, alarme aos 15.000, crítico aos 18.750 (perde a isenção de imediato, fatura seguinte já com IVA, comunicar às Finanças em 15 dias úteis).
* Segurança Social trimestral: o que declarar em jan/abr/jul/out e quanto paga nos 3 meses seguintes (21,4% sobre 70% para serviços, sobre 20% para venda de bens; mínimo 20€/mês; base máxima 12×IAS); botão "quero pagar 25% a menos / a mais" (a lei deixa ajustar até 25%).
* Isenção do 1.º ano: contagem regressiva dos 12 meses; aviso 30 dias antes com o valor que vai passar a pagar.
* Provisão de IRS: regime simplificado (coeficiente 0,75 serviços / 0,15 vendas), escalões 2026, mínimo de existência 12.880€; nota: acima de ~27.000€/ano tem de justificar 15% de despesas com faturas com NIF (marcar "verificar com contabilista").
* Pagamentos por conta de IRS: 20 jul / 20 set / 20 dez, 65% do calculado.
* "Como emitir o recibo": guia com capturas do Portal das Finanças, passo a passo, e textos prontos a copiar.

Tela 3 — Calendário de Obrigações (gerado do perfil; nada em falta)
Segurança Social (declaração trimestral até ao último dia de jan/abr/jul/out; pagamento entre 10 e 20 de cada mês) · IVA se regime normal (declaração trimestral até dia 20 do 2.º mês após o trimestre, pagamento até dia 25) · IRS (entrega 1 abr–30 jun; pagamentos por conta; validar faturas no e-fatura até 25 fev) · Finanças (comunicar recibos até dia 5 do mês seguinte se usar software de faturação; declaração de alterações ao mudar de regime) · Carro (IUC mês da matrícula; IPO; seguro; revisão; validade da carta) · Imigrante (renovação da autorização de residência; troca da carta estrangeira — 2 anos após residência, marcar "confirmar no IMT") · TVDE (certificado de motorista 5 anos; licença/dístico do carro). Cada item: data, valor estimado, "como pagar" (referência MB / onde clicar), botão "já paguei".

Tela 4 — O Carro (Drivvo adaptado a Portugal)
Vários carros · IUC (mês da matrícula, valor aproximado por tabela 2026, onde pagar) · IPO ligeiros: 4 / 6 / 8 anos e depois anual (TVDE/táxi: anual — confirmar), avisos 30 e 7 dias, centros de inspeção perto (mapa, dados abertos) · Seguro (aviso 45 dias antes: "é agora que comparas") · Carta (15 anos até aos 60; depois 5; depois 2) · Combustível mais barato num raio de 10 km (dados abertos DGEG) · Abastecimentos e custo por km (para o TVDE saber se a corrida compensa) · Portagens e multas (lembrete de pagar em 15 dias úteis) · Despesas com NIF guardadas para o IRS.

Tela 5 — Reforma e Direitos
"Descontas X€/mês — vale ≈ Y€ de reforma" (estimativa simples) · Idade da reforma 2026: 66 anos e 9 meses; 15 anos mínimos · Direitos de quem paga: baixa por doença (a partir do 11.º dia, 6 meses de descontos), parentalidade, cessação de atividade (o "desemprego" dos independentes, 360 dias de descontos), assistência a filhos · O que perdes se não pagares · Acordo Portugal–Brasil (conta o tempo dos dois países) — explicação simples e link oficial.

Tela 6 — Guias (1 minuto cada, botão "ouvir" com texto-para-voz)
Abrir atividade (CAE certo para TVDE, estafeta, cabeleireiro…) · Simplificado vs organizada · Isenção art. 53.º · Retenção 23/25/dispensa · Segurança Social Direta passo a passo · IRS do independente (anexo B, despesas, mínimo de existência) · TVDE: o que é preciso · Estafeta de plataforma: recibos vs contrato (presunção de laboralidade, explicar sem assustar) · Encerrar atividade sem dívida · Imigrante: NIF, NISS, SNS, morada na AIMA, troca da carta · Carro: IUC, IPO, seguro, carta, multas. Cada guia com fonte oficial e data de verificação no rodapé.

Tela 7 — Assistente IA
Chat; deteta PT-PT/PT-BR e responde na variante; contexto = `regras_legais` + guias + perfil e números do utilizador; resposta sempre termina com o passo concreto e o prazo; se for jurídico a sério, responde o básico e diz que precisa de contabilista/advogado (contacto parceiro — campo no admin); rodapé fixo "Informação geral, não substitui contabilista". Limite no plano grátis: 5 perguntas/mês (ilimitado no trial e no Pro).

Tela 8 — Suporte automático
Dúvidas → IA em modo suporte · Reembolso/cancelamento → automático pela Play · Bug → utilizador descreve, app junta logs, cria `tickets_suporte` → e-mail para o Danilo só se houver dinheiro em disputa ou as palavras advogado/AIMA/processo · E-mail de suporte (`suporte@` do domínio) respondido por IA com regras fixas.

Tela 9 — Plano e pagamento (Google Play Billing, dentro da app)

* Trial: 30 dias com TUDO aberto, sem cartão (o grátis É o teste). Aviso no dia 25. No dia 31 fecha para o plano grátis.
* Grátis (depois do trial): painel, calendário com só 3 avisos/mês, calculadora, 1 carro, 5 perguntas/mês à IA. Tudo o resto aparece com cadeado e explicação de uma linha.
* Pro: 3,49€/mês ou 29,90€/ano (produtos `pro_mensal`, `pro_anual`) — avisos ilimitados, IA ilimitada, leitura de extratos por foto, comprovativos guardados, vários carros, exportar para o contabilista (PDF/CSV), Reforma completa.
* Família/Frota: 5,99€/mês ou 49,90€/ano (`familia_mensal`, `familia_anual`) — até 5 pessoas/carros.
* Cria os produtos na Play Console (agente de clique), valida recibos em `validar-compra-play`, guarda em `assinaturas`. iOS/computador: a app web com o mesmo login (pagamento web fica para fase 2 — deixa o gancho Stripe preparado, Stripe do Danilo já existe).

Painel admin (Flutter Web, PT-BR) — autoridade total
Utilizadores, planos, receita, tickets, perguntas mais feitas à IA (para criar guias novos), editar `regras_legais` sem código (IAS, limites, taxas, datas), aviso em massa ("o IAS mudou, os teus valores foram atualizados"), banir, exportar CSV, auditoria.

### 3. IA, SUPORTE E AUTOMAÇÕES (bloco 3)

Base de conhecimento = secção 4 + guias + FAQs geradas. Testa 30 perguntas reais (lista em `docs/perguntas-teste.md` que tu escreves: "abri atividade em março, quando começo a pagar?", "passei os 15 mil, e agora?", "posso pagar menos à segurança social?", "quando é a inspeção do meu carro de 2021?", "sou brasileiro, o tempo do INSS conta?"…) e prova que as 30 respostas citam a regra certa e o prazo certo. Guarda as 30 saídas em `docs/provas/ia/`.

### 4. REGRAS LEGAIS 2026 (carregar em `regras_legais` com fonte e data; atualizar todo janeiro)

* IAS 2026: 537,13€
* Isenção IVA art. 53.º: 15.000€/ano; perda imediata acima de 18.750€ (+25%); comunicação 15 dias úteis
* Retenção na fonte cat. B: 23% padrão (desde 2025), opção 25%; dispensa se ano anterior < 15.000€ (art. 101.º-B CIRS)
* Segurança Social independentes: 21,4%; base = 70% serviços / 20% bens do rendimento trimestral; ajuste ±25%; mínimo 20€/mês; máximo 12×IAS; isenção 12 primeiros meses; declaração trimestral jan/abr/jul/out; pagamento dia 10–20
* IRS simplificado: coef. 0,75 serviços / 0,15 vendas; mínimo de existência 12.880€; pagamentos por conta 65% em 20 jul/20 set/20 dez; escalões 2026 (carrega a tabela oficial)
* Reforma 2026: 66 anos e 9 meses; carreira mínima 15 anos
* IPO ligeiros: 4/6/8 anos, depois anual · IUC: mês da matrícula · Carta: 15/5/2 anos
* Multas de estacionamento/trânsito: pagamento voluntário 15 dias úteis Cada valor com `fonte_url` (Segurança Social, Portal das Finanças, IMT, DGEG, Diário da República) e `verificado_em`. A IA nunca inventa um número: só lê desta tabela.

### 5. MARCA, LOJA E MATERIAL (bloco 5)

* Nome: Em Dia. Domínio: verifica `emdia.pt`, `em-dia.pt`, `emdia.app`; compra o melhor disponível na Cloudflare (mesma conta do token) se ≤ 15€/ano; senão reporta e usa `.pages.dev`.
* Logo e ícone: 5 propostas geradas (Gemini web + ChatGPT), tema: um visto verde dentro de um calendário ou de um semáforo, moderno, legível a 48px. Escolhes a melhor pelo fiscal visual e deixas as 5 em `docs/marca/` para o Danilo ver.
* Capturas para a loja: 8 capturas reais da app (não maquetes), cada uma com uma frase por cima ("Nunca mais levas multa da Segurança Social", "Sabe quanto guardar para o IRS", "A inspeção do carro avisa-te sozinha", "Pergunta o que quiseres, em português"). Feature graphic 1024×500. Descrição da loja PT-PT com as palavras que as pessoas procuram (recibos verdes, segurança social, IVA, IRS, IUC, inspeção, TVDE, estafeta).
* Site (skill site-premio, nível 2, público pouco digital: letras grandes, um CTA): uma página com a calculadora de recibo verde ABERTA na web (é o que traz gente da Google), os dois botões com o mesmo peso "Descarregar na Play Store" e "Usar no iPhone/computador" (app web), vídeo de herói (muted/autoplay/playsinline/poster), favicon, OG, sitemap, robots, 404, JSON-LD. Testa com prefers-reduced-motion ligado E desligado. TestSprite com asserções provadas (contar asserções, nunca aceitar "passed").
* Vídeos (Bora Studio): (1) 30 s vertical para Facebook/Instagram/TikTok: "eu sou motorista TVDE e fiz isto porque levei uma multa" — guião + storyboard + render com capturas reais da app e voz PT-BR; (2) 15 s de loja (Play Store); (3) 60 s explicativo para o site. Guiões em `docs/videos/`.
* Kit de divulgação (`docs/marketing/`): 20 posts prontos para grupos de Facebook (TVDE Portugal, estafetas Glovo/Uber Eats, brasileiros em Portugal, cabeleireiras/manicures, mães empreendedoras), cada um = UMA dor + UM print + link; regra do Danilo: nunca vender a app, vender o susto evitado ("este prazo passa despercebido a 80% das pessoas — confirma se estás em dia"). 5 anúncios pagos (texto + arte) para o Meta Ads. Calendário de 30 dias (1 post/dia, rotativo). Mensagens prontas de resposta a comentários. Texto para convidar os 12 testadores.

### 6. MENSAGENS DA APP (PT-PT, curtas, humanas — carregar em ficheiro de tradução, nunca no código)

Boas-vindas: "Olá! Eu sou o Em Dia. A partir de agora não te esqueces de nada: Segurança Social, IVA, IRS, carro. Vamos começar com 4 perguntas rápidas." Fim do onboarding: "Pronto. Este mês só tens uma coisa: Segurança Social, {valor}, até dia 20. Eu aviso-te no dia 15." 5 dias antes: "Faltam 5 dias para {obrigação} ({valor}). Toca aqui para ver como pagar." Dia do prazo: "É hoje. {obrigação}, {valor}, até à meia-noite. Já pagaste? Toca em Já paguei." Prazo passado: "Passou o dia {dia} e não marcaste como pago. Não é o fim do mundo: paga hoje, os juros são pequenos. Se já pagaste, toca aqui." Vigia IVA: "Atenção: já vais em {valor} este ano. Se passares os 15.000€, no próximo ano tens de cobrar IVA. Queres perceber o que muda?" Fim da isenção: "Daqui a 30 dias acaba a tua isenção de Segurança Social. A partir de {mês} vais pagar cerca de {valor}/mês. Já estás avisado, sem sustos." Carro: "A inspeção do teu carro ({matrícula}) é até {data}. Marca já — os centros enchem no fim do mês." Reforma (trimestral): "Este trimestre descontaste {valor}. São mais 3 meses a contar para a tua reforma. Continua." Trial dia 25: "Faltam 5 dias para o teu mês grátis acabar. Depois disso o Em Dia continua a avisar-te, mas com limites. Por 3,49€/mês (ou 29,90€/ano) fica tudo como está." Trial dia 31: "Hoje evitaste multas durante um mês. Para continuar assim é 3,49€ por mês — menos que uma multa. Toca para ativar." Reativação (7 dias sem abrir): "Está tudo em dia do teu lado. Não precisas de fazer nada. Eu avisarei."

### 7. PUBLICAÇÃO (bloco 7 — agente de clique na Play Console, conta nilofulfarotuga@gmail.com)

1. Criar a app `Em Dia` na Play Console (package `pt.emdia.app`), ficha da loja completa (capturas, feature graphic, descrição, categoria Finanças, PT-PT + PT-BR), política de privacidade publicada no site, Data Safety preenchido com CUIDADO (a lição do Bora: declarar tudo o que se transmite; só firebase_core + firebase_messaging + Supabase; sem IDs de dispositivo não declarados), conteúdo classificado, público-alvo, permissões mínimas (sem localização em segundo plano).
2. Notas de lançamento dentro das etiquetas `<pt-PT>…</pt-PT>` (senão dá erro).
3. Bundle no track interno + lista de testadores com `boraappbora@gmail.com` (ser dono da conta não faz de ninguém testador). Link de adesão registado no relatório.
4. Se a Google exigir teste fechado com 12 testadores × 14 dias para esta app nova: cria a faixa fechada, gera o link universal `play.google.com/apps/testing/pt.emdia.app`, e deixa no relatório o texto pronto de convite para os grupos (o Danilo só cola). Se não exigir, submete a produção com rollout a 10%.
5. Produtos de assinatura criados e ativos (4 produtos). Comprovativo por captura.
6. A Play Console é AngularDart: `innerText` mente nas tabelas — só a captura prova.

### 8. TESTES E PROVAS (aplica-se a TODOS os blocos)

* `flutter analyze` 0 erros; testes unitários das regras (calculadora, obrigações, IVA, SS, IRS, IPO, IUC) com os 30 casos de `docs/casos-teste.md` que tu escreves com resultado esperado à mão; golden tests em 3 tamanhos + teclado (workflow `olho_golden.yml` copiado do Bora); juiz de visão nas capturas; Edge Functions chamadas com entrada real; pg_cron disparado à mão uma vez com push a chegar ao telemóvel do Danilo (Android por USB, `adb devices`); fluxo completo gravado: instalar → onboarding → painel → aviso → "já paguei" → trial → compra de teste na Play (licença de teste) → cadeado no dia 31 (simula com `trial_ate` no passado).
* Cada bloco fechado escreve linha no `e2e_log` do projeto novo (cria a tabela igual à do Bora) e em `docs/RELATORIO.md`.

### 9. FECHO

* `docs/RELATORIO.md`: o que ficou feito (com provas), o que ficou a faltar de clique do Danilo (com a página já aberta no ecrã), links clicáveis (loja/teste, site, admin), custos gastos (domínio, nada mais), e as decisões que tomaste sozinho.
* Digest de 6 linhas em bloco de código para o Danilo colar no @BoraHermesbot.
* Registo no vault Obsidian `C:\Users\danil\Desktop\Bora\EM-DIA\` (prompt + relatório + provas).
* Atualiza o CLAUDE.md do repo com as regras desta app (idiomas, regras legais em tabela, nunca versionCode à mão, tracks internal/alpha).

`/ctx doctor` `/ctx stats`

---

## PARTE 2 — ADENDA À MISSÃO EM DIA (chegou às 23:35 na mesma sessão)

ADENDA À MISSÃO EM DIA — colar NA MESMA janela onde a missão já corre (não abrir sessão nova)
Lê isto agora, antes de continuares o bloco em que estás. Acrescenta ao plano do CEO-AI e continua.

### A. MODO NOITE — o Danilo vai dormir; ninguém responde até de manhã

1. NUNCA pares à espera de resposta. Se houver ambiguidade, decides tu, escreves a decisão em `docs/DECISOES.md` (o quê, porquê, como se desfaz) e continuas.
2. Passos que exigem clique do Danilo (autorização Google, pagamento, aceitar termos): NÃO bloqueiam a noite. Anotas em `docs/PENDENTE-DANILO.md`, deixas a página aberta no ecrã no fim, e saltas para o bloco seguinte.
3. MARCOS EM DISCO: a cada passo fechado, escreves em `docs/MARCOS.md` uma linha `[data hora] FEITO: <passo> | PRÓXIMO: <passo> | PROVA: <ficheiro/comando>`. Qualquer retoma começa por ler este ficheiro e continua do PRÓXIMO. Nunca recomeças do zero.
4. CONTINUIDADE AUTOMÁTICA QUANDO O LIMITE DO PLANO ACABAR (é o ponto mais importante da noite):
   * O plano Pro tem limite de 5 horas e esta sessão vai morrer com "usage limit reached, resets at …". Isso NÃO pode parar a missão.
   * ANTES de continuares a construir, cria o vigia: tarefa agendada do Windows `EmDia-Retomar` que corre de 20 em 20 minutos e lança `claude --resume <ID desta sessão> -p "Lê docs/MARCOS.md e continua do PRÓXIMO. Modo noite."` no diretório `C:\Users\danil\Desktop\projetosflutter\em_dia`, com o token OAuth já gravado no PC (`CLAUDE_CODE_OAUTH_TOKEN`, o mesmo que o loop usa). Se a sessão ainda estiver viva, a tarefa deteta (ficheiro-tranca `docs/.sessao-viva` renovado por ti a cada 5 min) e sai sem fazer nada. Se a sessão morreu por limite, a tarefa tenta; enquanto o limite não repõe, falha e tenta de novo daí a 20 min — quando repuser, retoma sozinha.
   * Regras provadas nesta máquina para a tarefa: `AllowStartIfOnBatteries` + `DontStopIfGoingOnBatteries` + `StartWhenAvailable`, e confirmar lendo de volta que `DisallowStartIfOnBatteries=false`. "Result 0" não é prova: prova é o log `docs/vigia.log` com linhas novas escritas pela corrida disparada PELO agendador. Testa uma vez agora, com a sessão viva (tem de escrever "sessão viva, saio") e regista.
   * Segunda perna, para não depender do PC: cria uma rotina cloud do Claude Code (`/schedule`) chamada `em-dia-noite`, de hora a hora, no repo `nilofulfarotuga-hue/em-dia-app`, com a instrução "lê docs/MARCOS.md; faz APENAS blocos de código/documentos/testes que não precisem do PC nem de painéis web; commit + push; escreve o marco". A sessão local, ao retomar, faz `git pull` primeiro e continua. Zonas que ficam SÓ para a sessão local: Play Console, Cloudflare, AI Studio, Firebase, agente de clique, Bora Studio, telemóvel por USB.
   * O vigia e a rotina desligam-se sozinhos quando `docs/MARCOS.md` tiver a linha `MISSAO-CONCLUIDA`.
5. AVISO AO TELEMÓVEL: a cada bloco fechado, manda mensagem pelo bot de Telegram já existente do Bora (mesmo token/chat dos alertas) — 3 linhas: bloco, prova, próximo. Se algo travar mais de 30 min sem saída nova, manda "TRAVADO em X, tentando Y". De manhã ele lê o Telegram, não o terminal.
6. Ordem dos blocos esta noite (o que NÃO depende de clique dele primeiro): fundação → telas → regras legais → IA/suporte → testes → site → marca/capturas/posts/guiões → só depois Play Console (o que puder ser feito pelo clique, faz; o que exigir a pessoa, fica em PENDENTE-DANILO com a página aberta).

### B. REFERÊNCIAS (nunca construir às cegas — mesmo método dos sites)

Antes da Tela 0, monta `docs/referencias/` com capturas REAIS (Play Store / sites), e extrai delas um design system escrito (`docs/DESIGN-SYSTEM.md`: paleta, tipografia, espaçamentos, cantos, sombras, botões, cartões, semáforo, tom das mensagens) ANTES de escrever a primeira tela:

* MEI Fácil (Brasil): painel de situação, calendário de obrigações, "quanto guardar", chat de dúvidas.
* Drivvo (Brasil): cadastro de carros, lembretes por data/km, abastecimentos, relatório.
* Artur (appartur.pt): cálculo de IVA + Segurança Social + IRS por fatura, "quanto podes gastar".
* Rocket Money (EUA): aviso de cobrança recorrente, ecrã de "total mensal".
* Segurança Social Direta e Portal das Finanças: só para os guias "como pagar" (capturas dos passos reais). Regra: copiar a ESTRUTURA e a clareza, nunca o visual literal — marca própria (verde em dia / laranja a vencer / vermelho passou, Inter). Fiscal visual compara cada tela contra a referência da mesma função e reprova se ficar mais confusa que a original.

### C. DETALHES QUE FAZEM SAIR ERRADO (fixar agora)

* Fuso `Europe/Lisbon` em tudo (prazos à meia-noite de Lisboa); moeda `1.234,56 €`; datas `dd/mm/aaaa`.
* Datas legais calculadas por função única testada: mês da matrícula → IUC; ano da matrícula → IPO (4/6/8/anual); data de abertura → fim da isenção (+12 meses) e primeiro trimestre a declarar; prazo que cai a fim-de-semana/feriado → aviso na véspera útil. Casos de teste com carro de fevereiro, atividade aberta a 31/12, ano bissexto.
* Push: nunca mais de 1 aviso por obrigação por dia; horário 09:00 Lisboa; agrupar quando há vários no mesmo dia.
* Trial: `trial_ate = criado_em + 30 dias` no servidor, nunca no telemóvel (senão muda-se a hora e engana).
* Cadeados: cada funcionalidade tem uma flag em `feature_flags` (grátis/pro/família) lida do servidor — mudar limites amanhã sem publicar versão nova.
* IA: temperatura baixa; se a pergunta sair das regras carregadas, responde "não tenho essa regra confirmada" e cria ticket para guia novo. Custo por conversa registado; alarme no admin se passar 0,50€/dia.
* Nada de chaves em claro no repo (Gemini, Supabase service role, FCM, keystore): secrets do GitHub e `.env` ignorado, e prova por `git grep` a zero ocorrências no histórico.
* Golden tests em PT-PT e PT-BR (textos maiores partem layouts).
* App web: mesmo build, mesmo login, sem Play Billing — mostra "assinar pelo telemóvel Android por agora".

### D. COMO TEM DE ESTAR NO FIM (é isto que fecha a missão — sem tudo isto não escreves MISSAO-CONCLUIDA)

1. App instalada no telemóvel do Danilo (Android por USB) pelo track interno da Play, com link de adesão clicável no relatório.
2. Onboarding → painel → aviso push recebido no telemóvel → "já paguei" → cadeado depois do trial (simulado) → compra de teste na Play a passar. Vídeo do fluxo gravado (`docs/provas/fluxo-completo.mp4`).
3. Os 30 casos de teste das regras a verde e as 30 perguntas à IA com resposta certa, ambos em `docs/provas/`.
4. CI verde ao nível de step, versionCode pelo CI, secrets fora do repo.
5. Painel admin no ar (link), com `regras_legais` editáveis e a lista de utilizadores.
6. Site no ar (link) com calculadora aberta, dois botões, vídeo de herói, TestSprite com asserções contadas.
7. Ficha da Play Console completa (capturas, feature graphic, descrição, Data Safety, privacidade), 4 produtos de assinatura criados. O que exigir clique dele: página aberta + linha em PENDENTE-DANILO.
8. `docs/marca/` com 5 logos; `docs/videos/` com os 3 guiões e os renders (ou o estado do render no Bora Studio se ainda a correr); `docs/marketing/` com 20 posts, 5 anúncios, calendário de 30 dias, convite aos testadores.
9. `docs/RELATORIO.md` em texto simples corrido (ele ouve em voz alta): o que está pronto, links clicáveis, o que falta do clique dele (mínimo de cliques), decisões tomadas sozinho, custos. Digest de 6 linhas em bloco de código para o Telegram. Cópia no vault `C:\Users\danil\Desktop\Bora\EM-DIA\`.
10. Última linha de `docs/MARCOS.md`: `MISSAO-CONCLUIDA` → vigia e rotina cloud desligam-se sozinhos.

Retoma agora do ponto onde estavas, começando pelo vigia (A.4) para a noite ficar coberta.
