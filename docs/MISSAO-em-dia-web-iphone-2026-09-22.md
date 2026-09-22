# ⚠️ MODO PROTECÇÃO TOTAL ⚠️ — EM DIA — LANÇAR NA WEB E NO IPHONE, E COMEÇAR A DIVULGAR (missão única e fechada, 22/09/2026)

> Ordem colada pelo Danilo no Claude Code às 11:48 de 22/09/2026 e guardada aqui SEM alterações pelo Claude Code, que por
> ordem dele NÃO executa esta missão: só guardou este ficheiro e lançou `opencode run --auto -m openai/gpt-5.5` nesta pasta.
>
> Estado deixado ao lançar (medido pelo Claude Code às 11:48, não reinvestigues):
> - O `opencode run` da missão `em-dia-publicar-2026-09-21` terminou sozinho (stdout em `docs/opencode-publicar-2026-09-21.log`):
>   «I did not stage, commit, push, or clean the dirty worktree» — ficou POR COMMITAR: `docs/MARCA.md`, `docs/marca/`
>   (feature graphic, proposta 1r), `supabase/migrations/20260921_0042_cadeados_anon_e_search_path.sql` e
>   `20260921_0043_perto_de_mim_sem_anon.sql` (NÃO aplicadas por ele — confirma antes de assumir), `docs/RELATORIO-em-dia-publicar-2026-09-21.md`,
>   `docs/DIGEST-em-dia-publicar-2026-09-21.md`, `docs/provas/em-dia-publicar-2026-09-21/`, capturas da Play com moldura em
>   `docs/loja/play/`, edições em DECISOES/MARCOS/PENDENTE-DANILO/PLAY-FICHA-RESPOSTAS/KIT-DIVULGACAO. Lê o `git status` e o
>   relatório dele antes de mexer; commita o que for bom, ficheiro a ficheiro (NUNCA `git add -A`).
> - `git push` FUNCIONA nesta máquina pelo credential helper do Git (o Claude Code empurrou para `origin/main` às 03:5x de 22/09
>   sem `gh`); o que não existe no PATH é o `gh` (para ler CI/secrets). O CI faz `git commit` do `versionCode` na `main`:
>   antes de cada push faz `git pull --rebase origin main`.
> - Últimos commits: 6945c19 (ordem da missão anterior), 7582ec5 (CI: versionCode 40), 382403d (MISSAO-CONCLUIDA em-dia-vender).
> - O MCP Supabase do OpenCode está preso ao projeto do Bora (`ojykpzwqrtusfeakzrna`): e2e_log sim; SQL no em-dia NÃO — é da
>   Claude.ai, como a ordem diz (escreve o pedido em `docs/PARA-A-CLAUDE-AI.md`).

---

## MOTOR E PORTA

- **PORTA: OpenCode. MOTOR PRINCIPAL: ChatGPT Plus `gpt-5.5`** — `opencode run -m openai/gpt-5.5`, sessão OAuth do Codex em `~/.codex/auth.json` (conta **`nilofulfaro@gmail.com`**, que **não** é a conta Google do perfil do Chrome; confirma no ficheiro no primeiro minuto).
- **VOLUME: GLM `glm-5.2`** (plano Go, provado com saldo a 21/09).
- **IMAGENS: Gemini** — sessão paga no Chrome (perfil Bora) primeiro; se não der, a chave `gemini_api_key` já está no Vault do projeto em-dia. O ChatGPT também gera: faz nos dois e fica com a melhor.
- Claude Code fora, como na missão anterior.

## SESSÃO

**ABRE UMA SESSÃO NOVA no OpenCode**, pasta **`C:\BoraLocal\projetosflutter\em_dia`** (ou a junção `C:\Users\danil\Desktop\projetosflutter\em_dia`).
Repo `nilofulfarotuga-hue/em-dia-app` · package `pt.emdia.app` · Supabase `tgdmgtmknbwhcqoxtjbs` · versão atual `1.0.0+40`.
**RUN_ID / fluxo `e2e_log`** (no Supabase do Bora, `ojykpzwqrtusfeakzrna`): `em-dia-web-iphone-2026-09-22`

---

## QUEM FAZ O QUÊ — lê isto antes de começar, poupa-te a noite passada

A missão de ontem à noite falhou por três coisas. Já estão repartidas:

| Trabalho | Quem faz |
|---|---|
| Código, build, testes, CI, git | **TU** (esta sessão) |
| Play Console e App Store Connect | **A Claude.ai**, no Chrome do Danilo. **Não tentes.** |
| SQL no Supabase do **em-dia** | **A Claude.ai**, por MCP. O teu MCP está preso ao projeto do Bora. |
| Falar com o Danilo | **A Claude.ai.** Tu reportas pelo Telegram. |

Se precisares de algo da consola ou da base de dados do em-dia, **escreve o pedido em `docs/PARA-A-CLAUDE-AI.md`** e segue em frente. Não pares.

---

## B-1 · AS TRÊS COISAS QUE MATARAM A NOITE PASSADA — resolve primeiro, com prova

1. **`git push` tem de funcionar.** Ontem falhou por falta do `gh` e perdeu-se tudo o que foi feito. Instala/autentica (`gh auth login`, ou credential helper) e **prova com um push a vazio num ramo de teste**. Sem isto não escreves uma linha de código.
   ⚠️ **Há trabalho da noite de ontem por commitar nesta pasta.** Vê o que está no `git status` antes de mexer: se houver coisa boa (provas, relatório, migrações), **commita e empurra primeiro**, antes de começar o que é novo.
2. **O PC não pode adormecer:** `powercfg /change standby-timeout-ac 0` e `monitor-timeout-ac 0`.
3. **Telegram responde?** Manda mensagem de teste. Se não, escreves em `docs/AVISOS-DA-NOITE.md` e fazes push a cada bloco.

---

## A DECISÃO QUE MANDA NESTA MISSÃO

O Danilo decidiu hoje: **lança na web e no iPhone, com TUDO GRÁTIS por agora.** A Play Store fica para depois (está trancada pelos 12 testadores × 14 dias, confirmado no painel dele). As assinaturas só ligam quando o pagamento estiver resolvido.

**A Claude.ai já pôs na base de dados, em `regras_legais`, as duas chaves que mandam nisto** (não as recries, lê-as):

- `planos_a_venda` = `nao` — enquanto for "nao", **não aparece botão de comprar em lado nenhum**.
- `promessa_gratis_texto` = *"Por agora está tudo aberto e não se paga nada. Quando as assinaturas abrirem, avisamos com 30 dias de antecedência e ninguém é cobrado sem dizer que sim."*

Essa frase é **uma promessa legal**, não é publicidade: quem entrar agora **não pode** ser cobrado automaticamente depois. Escreve-a tal e qual, sem inventar variantes, em todos os sítios onde aparecer preço ou plano.

Os preços (3,49 · 29,90 · 5,99 · 49,90) **ficam guardados na base de dados como estão** — não os apagues.

---

## B0 · ESTADO REAL

Mede e escreve antes de mexer: o que está no ar (`emdia.boraguarda.com`, `app.emdia.boraguarda.com`, `admin.emdia.boraguarda.com`), a build web atual, os testes a passar (referência: 182 unitários, 141 goldens, 78 ecrãs), e o que existe de iOS no repo — **hoje não existe nada: não há pasta `ios/`, não há `build_ios.yml`.**

Facto já verificado pela Claude.ai, não reinvestigues: **o registo na web já está ABERTO**. A antiga lista de convidados e a chave `registo_aberto` já não existem na base de dados; o único filtro que resta recusa endereços inventados (`recusa_email_que_nao_recebe`), e isso fica como está.

---

## B1 · WEB — pôr de pé para receber gente de fora (é o que sai hoje)

1. **Ecrã dos planos na app e página `/precos` do site passam a ler `planos_a_venda`.** Com "nao": **sem botão de comprar**, e no topo a `promessa_gratis_texto` vinda da base de dados (nunca escrita à mão). A página continua a explicar o que a app faz; os preços podem aparecer como "o que vai custar quando abrir", desde que a promessa esteja por cima e não haja botão.
   **Proibido escrever "em breve"** — diz o que é, com a frase que já existe.
2. **Nada de botão morto em lado nenhum.** Varre a app: qualquer sítio que leve a comprar, assinar ou desbloquear tem de respeitar o mesmo interruptor. Um cadeado que não abre é pior do que não ter cadeado.
3. **Instalar no telemóvel tem de ser óbvio.** A app já é PWA e abre sem rede. Acrescenta, no site e na primeira visita pela web, o passo a passo curto de "pôr no ecrã inicial" — Android e iPhone separados, porque são diferentes. É daqui que vêm os avisos.
4. **Prova como uma pessoa de fora:** conta nova de raiz, endereço real, código no e-mail, onboarding, painel, pôr no ecrã inicial. Captura de cada passo. **A conta real do Danilo fica intocada.**
5. **Confirma que o site é encontrável:** `emdia.boraguarda.com` já permite indexação (o `robots.txt` só fecha `/testes/`); confirma que o `sitemap` está certo e que não sobrou `noindex` em nenhuma página pública. A app em `app.emdia.` continua fechada aos motores de busca, e está certo assim.

## B2 · IPHONE — de raiz, e é aqui que está o trabalho

A Apple **não tem** regra de 12 testadores. A conta de programador do Danilo está ativa e paga. O caminho é conhecido (foi feito para a Bora) mas **este projeto não tem nada de iOS**.

1. **Criar o projeto iOS** (`flutter create --platforms=ios .`), bundle `pt.emdia.app`, nome "Em Dia", `pod install` a passar com os ~30 plugins.
2. **`Info.plist` — as permissões, em PT-PT, uma frase honesta cada.** Faltando uma, a app fecha-se sozinha no arranque e a Apple chumba:
   - localização quando em uso (`NSLocationWhenInUseUsageDescription`) — postos e centros perto
   - câmara e fotos (`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`) — foto da fatura
   - microfone e reconhecimento de voz (`NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`) — o "fala comigo"
   - ⚠️ **Lição da Bora, não a repitas:** Face ID fechava a app por faltar `NSFaceIDUsageDescription`, e o simulador nunca apanha isso. Se houver biometria, declara.
3. **Chaves que não chegam ao IPA.** Foi a bomba da Bora: o `--dart-define` **não** define a variável do Xcode. Passa `TURNSTILE_SITE_KEY` e o que mais existir **por `xcconfig`**, e prova num aparelho, não só no simulador.
4. **Apagar a conta DENTRO da app** (regra 5.1.1(v) da Apple) — existe a página web `/apagar-conta`, mas a Apple exige o caminho de dentro. Confirma que existe e funciona; se não existir, **implementa**. Isto sozinho chumba a submissão.
5. **Entrar com a Apple.** A app oferece "Entrar com Google". Se esse botão estiver ativo no iPhone, a regra 4.8 obriga a oferecer também **Sign in with Apple**. Duas saídas, escolhe e regista em `DECISOES.md`: desligar o Google no iOS e deixar só o código por e-mail (mais simples, e é o caminho principal da app), **ou** implementar o Sign in with Apple. **Não submetas com Google e sem Apple.**
6. **Compras:** o `in_app_purchase` está montado para a Play. Como `planos_a_venda` = "nao", **não há compras no iPhone** e a ficha da loja **não declara compras dentro da app**. Não configures StoreKit agora.
7. **Avisos (push):** app iOS no Firebase do projeto certo, `GoogleService-Info.plist`, chave APNs da equipa. Se não der para fechar hoje, **a app vai à loja sem push** e regista-se o porquê — não é motivo para travar a submissão.
8. **Linha de montagem:** `build_ios.yml` nos *runners* `macos` do GitHub Actions (como se fez na Bora), a gerar o IPA assinado e a subir ao TestFlight. Certificados e perfis pelo caminho automático, guardados nos *secrets* — **nunca no repo**.
9. **Provas sem iPhone à mão:** simulador para as capturas 6.9"; o Danilo **tem** iPhone e aceita instalar por **link do TestFlight** (nunca por cabo, nunca ir procurar ficheiros). Deixa o link pronto.

## B3 · FICHA DA APP STORE — tu escreves, a Claude.ai cola

Escreve em `docs/APPLE-FICHA-RESPOSTAS.md`, pronto a colar: nome, subtítulo, descrição PT-PT (e PT-BR), palavras-chave, categoria **Finanças**, classificação etária, URL de suporte e de privacidade, **etiquetas de privacidade** tipo a tipo (o que a app recolhe, igual ao que já está declarado na Play mais a localização aproximada em primeiro plano), notas ao revisor e **como é que ele entra**: o modo **"Vê como fica"** não precisa de conta nenhuma — diz isso em primeiro lugar — mais uma conta de revisor com forma de entrar que não dependa de ler e-mail.
Capturas 6.9" com moldura e uma frase cada. **Nada é submetido por ti.**

## B4 · DIVULGAÇÃO — para as pessoas instalarem

O texto base já está em `docs/KIT-DIVULGACAO.md`. Falta torná-lo real:

1. **Imagens de propaganda de nível cinema**, não cartazes planos (é o padrão dele), com a app real como referência. Geradas no Gemini pago **e** no ChatGPT, escolhida a melhor por um juiz em conversa limpa.
2. **5 publicações para Facebook**, uma delas para grupos de motoristas e estafetas, todas com **"grátis, sem cartão"** e a promessa dos 30 dias.
3. **Um cartão curto "como instalar"** com os dois caminhos: iPhone (link da loja, quando existir) e qualquer telemóvel (link da web + pôr no ecrã inicial).
4. **Marcadores para o que ainda não existe:** `[LINK-APP-STORE]` fica por preencher até a app ser aprovada. O link da web já existe e entra a sério.
5. **Não publicas nada nas redes. Não crias contas. Não mandas e-mails.** Deixas pronto.

## B5 · PORTÃO E FECHO

1. Testes verdes antes de qualquer build: unitários, goldens, os 78 ecrãs, os 4 caminhos do onboarding.
2. **Revisão cruzada** por outro motor, com contexto limpo, à ficha da Apple e ao texto do grátis — quem escreveu não verifica.
3. `RELATORIO-em-dia-web-iphone-2026-09-22.md` no repo e cópia em `C:\Users\danil\Desktop\Bora\Projetos\` — **texto corrido, sem tabelas e sem emojis** (ele ouve em voz alta).
4. Digest em `claude_ai_memoria`, nota no Córtex, Telegram, linha final no `e2e_log`, `MISSAO-CONCLUIDA` em `docs/MARCOS.md`.
5. `docs/PARA-A-CLAUDE-AI.md` com o que ficou para mim, e `docs/PENDENTE-DANILO.md` só com cliques dele.

---

## O QUE NÃO FAZER

- Não uses o Claude Code.
- Não tentes a Play Console nem a App Store Connect — são da Claude.ai.
- Não ligues compras nem StoreKit: `planos_a_venda` está em "nao".
- Não escrevas "em breve" em lado nenhum.
- Não inventes prazos, taxas nem limiares: sem fonte oficial, não entra.
- Não toques no Bora, no `bora-app-cloud` nem no site do clube.
- Não toques na conta real do Danilo dentro da app.
- Não mexas no `versionCode` à mão — é do CI.
- Não submetas nada a nenhuma loja.
