# ⚠️ MODO PROTECÇÃO TOTAL ⚠️ — EM DIA — ACABAR E PÔR NA LOJA (missão única e fechada, noite de 21/09/2026)

> Ordem colada pelo Danilo no Claude Code às 03:5x de 21/09/2026 e guardada aqui SEM alterações pelo Claude Code, que
> por ordem dele NÃO executa esta missão: só guardou este ficheiro e lançou o OpenCode (`opencode run -m openai/gpt-5.5`)
> nesta pasta. Estado deixado pelo Claude Code: missão `em-dia-vender-2026-09-18` fechada (MARCOS, e2e_log 2100,
> push 382403d com CI verde nos 3 workflows); vigia `EmDia-Retomar` desliga-se sozinho ao ver o marcador.

## ADENDA DO DANILO (escrita à mão, na mesma mensagem, antes da ordem)
«tem que lançar nas 3 plataformas: Google, Apple e etc.» — A ordem abaixo cobre a Google Play. A web já está no ar
(app.emdia.boraguarda.com, PWA). A Apple (App Store) precisa de build iOS (Mac/Xcode ou serviço de build) e de conta
Apple Developer com o nome/morada certos — investiga o que já existe (a conta tem App Store Connect com a app Bora;
`~/.claude/contas/MAPA-CONTAS.json` diz que não há sessão Codemagic), escreve em `docs/DECISOES.md` o que falta e o que
custa, prepara o que não custa dinheiro, e NÃO gastes euros. Sem inventar: se não houver caminho gratuito para a Apple
esta noite, escreve-o como está.

---

MOTOR E PORTA — ordem do Danilo de hoje, cumpre à letra

* NADA DE CLAUDE CODE nesta missão. Nem a escrever, nem a "fazer de maestro". Ordem dele, 21/09: "Claude Code eu não quero que use." Isto suspende, só para esta missão, a regra "uma porta só / Claude Code é o chefe" de 17/09.
* PORTA: OpenCode. MOTOR PRINCIPAL: ChatGPT Plus `gpt-5.5`, pela sessão OAuth do Codex em `~/.codex/auth.json` (é a mesma conta Plus que o OpenCode usa). Arranca com `opencode run -m openai/gpt-5.5`, ou abre o OpenCode e escolhe o modelo com `/models`. Cuidado com a conta, porque isto já baralhou gente: o ChatGPT Plus é a conta `nilofulfaro@gmail.com`. Não é a conta Google do perfil do Chrome (`nilofulfarotuga@gmail.com`) nem a do perfil Bora (`boraappbora@gmail.com`, que no ChatGPT é Free e é proibida). A verdade está em `~/.codex/auth.json` — lê-o no primeiro minuto e confirma o e-mail e o plano.
* MOTOR DE VOLUME: GLM `glm-5.2` (plano Go). A Claude.ai provou às 22:4x de hoje que o Go responde e tem saldo (1,7 s). A linha "GLM sem quota semanal" de 20/09 está ultrapassada. Mas isso foi às 22h: se a meio da noite ele disser "weekly usage limit", não pares — passa o trabalho ao ChatGPT e regista.
* IMAGENS E VÍDEO: Gemini — primeiro a sessão paga no Chrome (perfil Bora, Google AI Plus); só se essa falhar é que usas a chave da API (`gemini_api_key`, já no Vault do projeto em-dia). Nunca pares por "quota grátis esgotada" sem tentar a paga. O ChatGPT também gera imagens: faz nos dois e fica com a melhor.
* NÃO EXISTEM AQUI (são coisas do Claude Code — não as procures nem as invoques): o orquestrador `CEO-AI` e os comandos `/ctx doctor` e `/ctx stats`. O que se lê nesta porta é o `AGENTS.md` do repo, `~/.agents/skills` (`contas-e-navegadores`, `distribuir-trabalho`, `protocolo-missao-bora`) e o Córtex por MCP.

SESSÃO
ABRE UMA SESSÃO NOVA no OpenCode, na pasta do projeto `em_dia`:

* Caminho provado na última missão: `C:\BoraLocal\projetosflutter\em_dia`
* Se não existir, a junção do QG: `C:\Users\danil\Desktop\projetosflutter\em_dia`

Repo `nilofulfarotuga-hue/em-dia-app` · package `pt.emdia.app` · Supabase próprio `tgdmgtmknbwhcqoxtjbs`. Não é o bora-app-cloud. Não toques no Bora.
RUN_ID / fluxo no `e2e_log` (que vive no Supabase do Bora, `ojykpzwqrtusfeakzrna`, como sempre): `em-dia-publicar-2026-09-21`

O QUE É "MISSÃO CUMPRIDA" — lê isto antes de começar
A app não fica visível na loja esta noite, e isso não é falha tua: a primeira versão de produção de uma app nova vai a revisão da Google, que demora dias. Não fiques a tentar, não interpretes "Em revisão" como erro, não repitas envios.
Cumprida = a versão está SUBMETIDA e em revisão, com captura do estado, e não falta nada nosso para ela ser aprovada. Tudo o que se testa de verdade esta noite testa-se na faixa interna e na app web, que são imediatas.

CARTA DE AUTONOMIA — ele vai dormir, a missão corre a noite toda

* O Danilo deu o "vai" hoje: acabar tudo o que falta e pôr na loja — "ele tem que preencher, fazer tudo e até clicar no botão de publicar."
* Nunca perguntas. Nunca terminas o turno à espera de resposta. Se um item bloquear: escreves porquê, registas, e passas ao seguinte. Voltas ao bloqueado no fim.
* Uma linha no `e2e_log` no fim de cada bloco (o B0 é a exceção: esse regista antes de mexeres em nada). Sem linha, o bloco não existe. Provas em `provas/em-dia-publicar-2026-09-21/`.
* Reportas pelo Telegram (Emerson, chat `6731890157`), uma linha por bloco. Não reportas no chat dele.
* Quando o contexto acabar: escreves o estado em `docs/MARCOS.md`, fazes push, e escreves a ordem de continuação — não o chamas para colar nada.
* Decisões ficam em `docs/DECISOES.md`, nunca numa pergunta a ele.
* Zero euros novos. Onde houver custo, preparas e paras no botão de pagar.
* NOMEIA O QUE MEXES. Em cada alteração escreve, com todas as letras, qual é a função, tabela ou ecrã e porquê. E se encontrares pelo caminho outro erro, bug ou coisa fora do âmbito: REPORTA. Não corrijas por tua conta e não fiques calado. Decidimos depois.
* REGRA DE PRODUTO: a app é para quem não percebe nada disto. Uma coisa de cada vez, sem números que a pessoa não escreveu, e em cada obrigação um botão que leva à página certa do Estado.
* PAINEL ADMIN: toda a funcionalidade nova tem correspondência no painel admin (ver, editar, criar, banir, configurar, exportar, auditar), em PT-BR. A app é PT-PT.

O QUE FICA PARA O DANILO — lista fechada, são estes e mais nenhum

1. Aceitar o contrato do perfil de pagamentos da Google (e mostrar documento, se pedirem).
2. O clique "Permitir" do depurador do Chrome — só se a cópia do perfil falhar (ver secção do Chrome).
3. O código de SMS de uma rede social nova — só se decidirmos criar; por agora não criamos.
4. O pagamento do registo da marca no INPI (≈130 €), se o nome estiver livre.
5. Escolher o nome, se o INPI mostrar colisão séria.

Se aparecer mais alguma coisa para ele, escreve-a com a razão exata de não teres conseguido fazer tu.

COMO CONDUZES O CHROME SEM O CLAUDE CODE
A extensão "Claude in Chrome" é do Claude e não serve aqui. Usa o Playwright, que já está instalado e provado neste repo (`tool/provas/pwa_prova.py`, `tool/provas/web_percorrer.py`).
Perfis: Bora (`Profile 1`, `boraappbora@gmail.com`) → Play Console, Gemini AI Plus, Gmail, Resend. Danilo (`Default`, `nilofulfarotuga@gmail.com`) → Supabase, Cloudflare, GitHub, e o ChatGPT no navegador.
Caminho 1 — cópia do perfil. Fecha o Chrome desse perfil, copia `C:\Users\danil\AppData\Local\Google\Chrome\User Data` com `robocopy /B` para uma pasta temporária, apaga os ficheiros `Singleton*` da cópia, e lança com `channel="chrome"`, `headless=False`, `--profile-directory=Profile 1`, `ignore_default_args=["--enable-automation"]`. ⚠️ Isto falha com frequência: em Windows os cookies estão cifrados ligados à aplicação, e a Google mostra "Verifica que és tu" quando a sessão aparece de um sítio novo.
Caminho 2 — ligar ao Chrome vivo. `chrome://inspect/#remote-debugging` no Chrome dele e ligar por CDP. ⚠️ Desde o Chrome 136 o depurador é recusado no diretório de dados por omissão, e pede um clique "Permitir" — que é dele.
🔴 TESTE DE FUMO, NO PRIMEIRO MINUTO, ANTES DE QUALQUER BLOCO: abre `play.google.com/console` pelo Caminho 1 e tira captura com o nome da conta visível. Se não entrar, tenta o Caminho 2 uma vez. Se também não der: escreve já a linha no `PENDENTE-DANILO.md`, avisa no Telegram, e reorganiza a noite para tudo o que não precisa de navegador (build, testes, marca pela API, migrações, documentos). Descobrir isto às 3h depois de três blocos perdidos é o pior desfecho possível.
Nunca tentes palavras-passe. Nunca peças token a ninguém. E a Play Console é AngularDart compilado: ler texto mente. A prova válida é captura de ecrã, sempre.

ESTADO REAL — JÁ VERIFICADO PELA CLAUDE.AI HOJE. NÃO REINVESTIGUES
Feito e no ar (missões `em-dia-tudo-2026-09-17` e `em-dia-vender-2026-09-18`, ambas fechadas):

* App web `app.emdia.boraguarda.com`, painel `admin.emdia.boraguarda.com`, site `emdia.boraguarda.com` com `/termos`, `/reclamacoes`, `/apagar-conta`, `/privacidade`, `/precos` (verificador 61/61).
* Três perfis (recibos verdes / contrato / os dois / empresa), regras com fonte em `docs/REGRAS-PT-2026.md`, PWA, funil no admin com consentimento, fecho de mês automático, pasta do contabilista.
* Testes: 182 unitários, 78 ecrãs de ponta a ponta, 141 goldens, juiz de visão 7 verdes / 0 vermelhos.
* Supabase `tgdmgtmknbwhcqoxtjbs`: ACTIVE_HEALTHY, 12 utilizadores, 0 assinaturas, 14 Edge Functions ativas, 5 `cron` ativos.

Play Console, medido a 18/09 (conta `5372142912736686834`, app `4973228433822861554`):

* Faixa interna: `1.0.0`, versionCode 39. alpha / beta / produção: sem releases nenhuns.
* Ficha `pt-PT` + `pt-BR` escritas · 1 ícone · 1 gráfico de destaque · 8 capturas cruas.
* Subscrições: NENHUMA. Perfil de pagamentos: NENHUM ligado (o seletor mostra o perfil individual `6137-6414-7724`).
* Checklist de configuração: 5 de 11 — faltam classificação de conteúdo, público-alvo, declarações governamentais/financeiras/saúde, categoria e contactos.
* Segurança dos dados preenchida mas desatualizada (falta a localização aproximada). Verificação de programador: `pt.emdia.app` Registada.

Falta no Vault do em-dia (só lá estão `correio_secret`, `cron_secret`, `gemini_api_key`, `resend_api_key`): `play_service_account`, `play_relatorios_bucket`, `invoicexpress_account`, `invoicexpress_api_key`. Consequência já provada: `validar-compra-play` devolve 503 `sem_play_service_account` e `fecho-mensal` grava "sem extrato" — e está certo gravarem isso enquanto faltarem.
Migração aplicada AGORA pela Claude.ai, por MCP, em produção — `20260921_0042_cadeados_anon_e_search_path` (provada por SELECT): tirou o `EXECUTE` do papel `anon` a `admin_apagar_conta_simular`, `admin_assinaturas`, `admin_erros`, `admin_fechos_mensais` e `admin_funil`, e fixou o `search_path` em `distancia_km` e `dia_util_seguinte_ou_igual`. Vai para o B7. Não voltes a aplicar.

B-1 · ARRANQUE — as três coisas que fazem uma noite desaparecer em silêncio
Antes de tudo, prova estas três e escreve a prova:

1. O PC não pode adormecer. `powercfg /change standby-timeout-ac 0` e `monitor-timeout-ac 0`. Com o ecrã bloqueado o navegador visível morre.
2. O `git push` funciona fora do navegador. Cookies do Chrome não servem para o git. Faz um push a vazio num ramo de teste. Se falhar, resolve com `gh auth` antes de escrever uma linha de código — senão trabalhas a noite toda e perde-se tudo.
3. O Telegram responde. Manda uma mensagem de teste. Se não responder, toda a comunicação da noite desaparece sem ninguém saber: nesse caso escreves os avisos em `docs/AVISOS-DA-NOITE.md` e fazes push a cada bloco.

Depois: o teste de fumo do Chrome (secção acima).

B0 · PORTÃO — o que é que a consola nos deixa fazer
A pergunta que manda na noite toda: esta app pode ir a produção já?
Abre o painel da app e tira captura de (a) o Painel de Controlo, à procura de qualquer pedido de "acesso à produção" ou de teste fechado; (b) o separador Produção, a ver se o botão de criar lançamento está ativo.

* O que o Danilo já disse (18/09) e é para respeitar: a Bora está pública na Play desde 31/07/2026, a conta já tem acesso à produção, e ele não quer ouvir falar outra vez em 12 testadores × 14 dias.
* Mas a consola manda mais do que qualquer um de nós. Olha, não adivinhes.
   * Produção aberta → segue o plano todo.
   * Consola a exigir teste fechado para esta app → não discutes e não paras: publicas na faixa mais avançada disponível, deixas a produção a um passo, guardas a prova (captura + texto literal) e avisas no Telegram em palavras simples: "a Google está a pedir X para esta app; pus em Y e a produção fica a um clique."

Regista no `e2e_log` antes de mexer em qualquer coisa.

B1 · A MARCA — é a cara do negócio (o bloco que ficou por fazer)
Ele pediu, com estas palavras, um logo bem chamativo e de nível. Não entregues o primeiro que sair.

1. Referências primeiro. Olha as melhores apps de dinheiro (Revolut, Monzo, Rocket Money, MEI Fácil, Artur) e escreve em 5 linhas a direção escolhida e porquê.
2. Pelo menos 10 propostas, no Gemini pago e no ChatGPT, com a app real como referência. Marca existente: verde `#16A34A`, laranja `#F97316`, fonte Inter.
3. Juiz de imagem em 3 conversas limpas, com esta pergunta exata: "isto parece a marca de uma empresa a sério ou um desenho genérico feito por computador?" Guarda os vereditos à letra. Só passa o que convence.
4. Entrega: logo principal, versão horizontal, símbolo sozinho, ícone 512 legível a 48 píxeis (testa encolhido), gráfico de destaque 1024×500, cores e fonte em `docs/MARCA.md`.
5. Capturas da loja com moldura e uma frase em cada uma (as 8 que lá estão são cruas).
6. Vídeo de 20 a 30 segundos. ⚠️ A Play não aceita ficheiro de vídeo, só um endereço do YouTube — portanto: carrega o vídeo no canal do YouTube da conta `boraappbora` como não listado, e cola esse endereço na ficha. Se não conseguires, deixa o campo vazio: isso não impede a submissão e não vale parar por causa disso.
7. Nome: confirma no INPI e na Play se "Em Dia" está livre na classe certa em Portugal. Se estiver, deixa o pedido preenchido e para no botão de pagar. Se houver colisão séria, propõe 3 nomes com o porquê — não mudes nada sozinho.

B2 · A FICHA DA LOJA, E A PORTA ABERTA PARA QUEM VAI REVER
As respostas já estão escritas em `docs/PLAY-FICHA-RESPOSTAS.md` (514 linhas). O trabalho é colá-las na consola, não reescrevê-las.

* Classificação de conteúdo (questionário IARC), público-alvo (18+), declarações governamentais / financeiras / saúde, categoria (Finanças), contactos.
* Segurança dos dados: acrescenta a localização aproximada — recolhida, não partilhada, opcional, só em primeiro plano, para mostrar postos e centros perto. A app já se comporta assim; falta declarar. Sem isto a Google chumba.
* Confirma o endereço de apagar conta e dados fora da app (`emdia.boraguarda.com/apagar-conta`) no campo certo, e a política de privacidade em `emdia.boraguarda.com/privacidade`.

🔴 O REVISOR DA GOOGLE TEM DE CONSEGUIR ENTRAR — isto sozinho chumba a app
Hoje a entrada é por código de 6 números enviado por e-mail, e só cria conta quem estiver na tabela `emails_convidados`. O revisor não tem acesso a caixa de correio nenhuma. Se submeteres assim, ele não entra e a app é recusada.
Antes de submeter (aqui, no B2 — não depois):

1. Abre o registo: `update regras_legais set valor_txt = 'sim' where chave = 'registo_aberto';`
2. Cria a conta de revisor, já dentro de `emails_convidados`, com uma forma de entrar que não dependa de ler e-mail: código fixo para esse endereço, ou palavra-passe só para essa conta. Escolhe, implementa, prova que entra, e regista a decisão.
3. Escreve o endereço e o código/palavra-passe literais no campo de instruções ao revisor da consola, mais a frase de que também pode ver tudo sem conta pelo botão "Vê como fica".
4. Prova o registo aberto a sério: cria uma conta nova de raiz com um endereço que exista (nunca inventado — endereço inventado devolve e queima o domínio por onde sai o código), recebe o código, faz o onboarding, chega ao painel. Captura de cada passo.

B3 · O PORTÃO ANTES DE SUBMETER — é aqui que a noite pode e deve parar
Nada é submetido sem isto tudo verde, com prova escrita.

1. A build tem de ser aceitável para a loja em 2026. Confirma na página oficial da Google (não de cor) os requisitos em vigor e depois confirma-os no projeto, com a saída literal:
   * nível de API alvo — o prazo de Agosto de 2026 já passou, portanto confirma o que a Google exige hoje e que o `targetSdkVersion` bate certo;
   * suporte a páginas de memória de 16 KB — obrigatório desde Novembro de 2025; verifica o alinhamento das bibliotecas nativas do `.aab`;
   * versões de Flutter, AGP e NDK compatíveis. Se falhar aqui, é aqui que se corrige — não na consola, com a build recusada.
2. Testes verdes: `flutter test test/unit` (182), goldens (141), percurso pelos 78 ecrãs, os 4 caminhos do onboarding. Nenhuma build vai à loja com um teste vermelho.
3. Reconfirma as contas contra a fonte oficial — os testes provam o código, não a lei. Em especial, e com a ligação guardada nas provas: a taxa do trabalhador independente (21,4 %) não é a mesma do empresário em nome individual (25,2 %) e a app tem perfil "empresa"; a base de 70 % aplica-se ao rendimento do trimestre anterior; o limiar do art. 53.º do IVA e as percentagens do IRS Jovem mudam a cada Orçamento. Se algum valor não bater com a fonte, corrige e diz o que mudou.
4. Revisão cruzada, agora e não depois: manda o GLM (ou, se estiver sem quota, o Gemini pago ou o ChatGPT numa conversa limpa — nunca o mesmo motor que escreveu) reler a checklist e a ficha da loja como crítico, à procura de erros. Corrige o que apontar.
5. Build nova pelo CI — nunca à mão; o `versionCode` é do CI, nunca se toca no `pubspec`. E escreve como é que o `.aab` chega à consola: ou o CI publica (e então a conta de serviço da Play e a chave de assinatura têm de estar nos secrets do repo — confirma que estão), ou é envio pela consola com o ficheiro local. Decide, prova, escreve.

B4 · SUBMETER

1. Checklist da consola 11 de 11.
2. Lançamento de produção, Portugal primeiro, notas dentro das etiquetas `<pt-PT>…</pt-PT>` (fora delas a consola dá erro).
3. Carrega em enviar. Se travar, lê o erro literal, corrige a causa e repete. Só desistes ao fim de três tentativas com causas diferentes — e aí escreves a causa provada.
4. Prova: captura do estado "Em revisão". É esta captura que fecha a missão.
5. E confirma o `noindex`/`robots` do site: se a app vai para a loja, o site tem de poder ser encontrado no Google. Se ainda bloquear, tira e regista.

B5 · O DINHEIRO — e a decisão que já está tomada, não a tomes outra vez
DECISÃO (escreve-a em `docs/DECISOES.md` como D76): a app vai para a loja GRÁTIS, com os planos pagos desligados por interruptor. Enquanto não existirem produtos na Play, o botão de comprar não aparece — ninguém bate num botão morto. A página dos planos continua a explicar o que é grátis e o que fica para depois, sem escrever "em breve". No dia em que os produtos existirem, liga-se o interruptor e publica-se uma atualização. Ajusta a ficha da loja a isto: não declares compras dentro da app enquanto não houver produtos.

1. Perfil de pagamentos: preenche tudo — nome e morada exatamente como no cartão de cidadão e nas Finanças (Danilo Fulfaro da Silva, Rua do Torreão 14, 1.º andar, 6300-610 Guarda; foi pelo nome sem o "da" e pela morada sem o andar que a Apple chumbou). Para no botão "Enviar". Deixa a página aberta. Acrescenta uma linha no `PENDENTE-DANILO.md` a avisar, sem drama, que a Google mostra publicamente a morada dos programadores que vendem — a mesma que já aparece na App Store. É informação, não é bloqueio.
2. Os 4 produtos prontos a nascer num comando (`python tool/play/produtos.py --criar`, já escrito): `pro_mensal` 3,49 € · `pro_anual` 29,90 € · `familia_mensal` 5,99 € · `familia_anual` 49,90 €, primeiro mês grátis na própria Play, impostos como a Google manda para Portugal. Não tentes criá-los antes do contrato — a Google devolve `FAILED_PRECONDITION` e é tempo perdido.
3. Segredos no Vault (isto é teu, não dele): `play_service_account` e `play_relatorios_bucket`, e dá à conta de serviço a permissão "Ver dados financeiros". Prova depois: `validar-compra-play` deixa de dar 503 e `fecho-mensal` deixa de escrever "sem extrato".

B6 · DIVULGAÇÃO — ele pediu hoje: "imagens, divulgações, é, tudo"
O texto já está em `docs/KIT-DIVULGACAO.md`. Falta transformá-lo em peças a sério:

* Imagens de propaganda de nível cinema, não cartazes planos (é o padrão dele). Geradas no Gemini pago e no ChatGPT, escolhida a melhor pelo juiz, com a app real como referência.
* 5 publicações para Facebook prontas, uma delas para grupos de motoristas e estafetas.
* ⚠️ O link da loja e o código promocional só existem depois de B4 e B5. Deixa nos textos um marcador claro (`[LINK-DA-LOJA]`, `[CODIGO]`) e uma linha a dizer onde se preenche.
* Redes sociais do Em Dia: não existem e não crias nenhuma (pede código de SMS, que é dele). Se der para preparar a partir do que já existe (Business Manager `1401256558818980`, página `1230974540107256`), deixa em rascunho, sem data marcada — agendar publica sozinho, e isso ele não autorizou.
* Não mandes e-mails a ninguém, contabilista incluída. O que ele quer é a pasta do fecho do mês, que já sai sozinha.

B7 · ARRUMAR O QUE FICOU A MEIO

1. Escreve `supabase/migrations/20260921_0042_cadeados_anon_e_search_path.sql` com exatamente o SQL que a Claude.ai já aplicou (está descrito em ESTADO REAL), para o repo não divergir da produção. Não voltes a aplicar.
2. Investiga e decide: `postos_perto`, `centros_perto`, `centro_do_municipio` e `combustiveis_disponiveis` são chamáveis por anónimo e aparecem nos avisores. Vê no código quem as chama. Se só a app com sessão as usa, tira o `anon` numa migração `0043` e prova. Se o site as usa sem sessão, deixa e escreve porquê.

B8 · FECHO

1. Checklist item a item dos blocos B2, B3, B4 e B5, cada linha com a captura ou a saída literal que a prova.
2. `RELATORIO-em-dia-publicar-2026-09-21.md` no repo e cópia em `C:\Users\danil\Desktop\Bora\Projetos\` — texto simples corrido, sem tabelas e sem emojis (ele ouve os relatórios em voz alta).
3. Digest em `claude_ai_memoria`, nota no Córtex, Telegram.
4. `docs/PENDENTE-DANILO.md` só com a lista fechada da carta de autonomia, cada linha com a página já aberta.
5. `MISSAO-CONCLUIDA em-dia-publicar-2026-09-21` em `docs/MARCOS.md` e linha final no `e2e_log`.

O QUE NÃO FAZER

* Não uses o Claude Code. É a ordem do dia.
* Não inventes prazos, taxas, limiares nem entidades legais: sem fonte oficial, não entra.
* Não gastes dinheiro, não cries contas pagas, não contrates nada, não tentes palavras-passe.
* Não toques no Bora, no `bora-app-cloud` nem no site do clube.
* Não toques na conta real do Danilo dentro da app.
* Não publiques nada nas redes sociais nem mandes e-mails.
* Não deixes "em breve" nem "para decidir depois" em lado nenhum sem o motivo escrito e provado.
* Não incrementes o `versionCode` à mão — é do CI.
