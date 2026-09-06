# Resend — os testes deixaram de mandar para endereços mortos? (2026-09-06)

> Auditoria feita às **2026-09-06T20:37:31Z** (21:37 em Lisboa), hora lida do relógio do PC com `date -u`.
> Lisboa = UTC+1 neste dia. Nas tabelas, a hora UTC vem primeiro e a de Lisboa entre parênteses.
> Fonte única: a API da Resend, com a chave que está em `C:/BoraLocal/_segredos/em-dia/resend.key`
> (a chave **não** está neste ficheiro). Não toquei em nada: só li.

## Verificação com contexto limpo (2026-09-06T20:48:17Z, 21:48 Lisboa)

> Feita por outro executor, que refez as chamadas à API da Resend com a mesma chave e tentou derrubar os números.

- **Tudo o que estava no relatório bate.** `GET /emails?limit=100` → HTTP 200, agora **78** e-mails, `has_more: false`; `after=` do mais antigo (`cdb7228e…`) → 0; `before=` do mais novo → 0. Dos 78, os **77 até às 20:37:31Z são exactamente os do relatório**: contagens por origem (Em Dia 42 = 25/4/11/2 · Bora 35 = 23/11/0/1), por dia, por hora (43 hoje = 25/4/11/3), a janela desde 17:00Z (9 e-mails, 7 entregues, 2 devolvidos, 0 do Bora), os 12 ids do Bora a `e2e_client_a@boraapp.test` (o último às 16:35:25Z, `delivery_delayed`), a tabela dos inventados (incluindo `maria.ferreira` e `testa.silva` a zero) e o último bounce (17:58:33Z, `joao.silva@gmail.com`, `edac9244…`) — todos iguais ao recalculado a partir do JSON bruto. As horas das migrações que o relatório cita (15:54:06Z, 17:58:21Z, 20:29:55Z, 20:30:34Z) batem com `list_migrations` do projeto `tgdmgtmknbwhcqoxtjbs`.
- **Uma coisa nova, 9 minutos depois da auditoria:** às **20:46:44Z (21:46 Lisboa)** saiu mais um e-mail do Em Dia («O teu codigo do Em Dia») para **`explorer@gmail.com`**, estado **`suppressed`** (a Resend não o enviou), id `8cdc3fdc-86ef-4e95-b993-7a81c73de934`. Este endereço nunca tinha aparecido na conta (0 em 77). No Supabase do Em Dia a conta existe: `auth.users` id `fca7e8cf-289b-428d-8367-72779852a132`, `created_at 2026-09-06 20:46:43.700278+00`, `email_confirmed_at null`, `last_sign_in_at null`, `deleted_at null`.
- **O que isto muda no relatório:** a frase «zero falhas novas desde as 17:58:33Z» valeu até às 20:46:44Z e aí deixou de ser verdade. A **última falha de qualquer tipo** passa a ser essa (`suppressed`); o **último bounce** continua a ser o das 17:58:33Z (`suppressed` não é bounce). Continua a **não haver nenhum** envio novo a `.test`, `.invalid`, `example.com`, `testuser*`, `joao.silva`, `maria.ferreira`, `explorador.emdia` ou `e2e_*` depois das horas que o relatório dá — o do Bora às 16:35:25Z continua a ser o último do Bora.
- **A guarda 0029/0029b não apanhou `explorer`** — e pela regra escrita em `supabase/migrations/20260906_0029_caixas_inventadas_com_numeros.sql` não tinha de apanhar: o padrão é «nome de teste (+ segunda palavra) + números» ou «user + números», e `explorer` não tem números nem está na lista exacta. É da mesma família do `explorador.emdia` das 17:56Z (um robô a explorar). Fica em aberto se se quer alargar a lista; isso é decisão, não erro do relatório.
- Nota para quem repetir a chamada: a API da Resend devolveu um erro sem corpo JSON ao pedido **sem** cabeçalho `User-Agent`; com `User-Agent: curl/8.0` deu 200.
- Não toquei em nada: só li (Resend, `auth.users`, `list_migrations`, o ficheiro da migração 0029). Ficheiros brutos em `scratchpad/verif/` (`v_page1.json`, `v_page2.json`, `v_page3.json`, `v_det_*.json`, `analisa.py`), fora do repo.

## Resposta curta

- **Último bounce (devolução): 2026-09-06 17:58:33Z (18:58 Lisboa)** — `joao.silva@gmail.com`, Em Dia, id `edac9244-cc78-4e72-8d8c-7661d0d08964`.
- **Última falha de qualquer tipo** (bounced, suppressed ou delivery_delayed): a mesma, 17:58:33Z. **[Corrigido às 20:48Z: passou a ser 20:46:44Z, `explorer@gmail.com`, `suppressed` — ver «Verificação com contexto limpo».]**
- **Último envio a endereço morto (que não recebe): 17:58:33Z** (Em Dia). No **Bora**: **16:35:25Z (17:35 Lisboa)** para `e2e_client_a@boraapp.test`, id `22f43659-29e3-413c-bf52-1d35941d95c8`, estado `delivery_delayed`.
- **Último envio a endereço inventado mas que recebeu: 20:09:19Z (21:09 Lisboa)** para `testuser12345@gmail.com` — entregue (`delivered`). É um nome inventado por um robô da Google (ver secção 3), mas a caixa existe, por isso não conta como falha na Resend.
- **Conclusão: zero falhas novas desde as 17:58:33Z (18:58 Lisboa)** — 2 h 39 min até à hora da auditoria. Depois dessa hora saíram 5 e-mails e os 5 foram entregues. **[Corrigido às 20:48Z: valeu até às 20:46:44Z; aí entrou uma falha nova (`explorer@gmail.com`, `suppressed`). Ver «Verificação com contexto limpo».]**
- **O que isto NÃO prova:** que o Bora deixou de mandar para `.test`. O último envio do Bora a `boraapp.test` foi às 16:35:25Z, **dentro das últimas 6 horas**. Desde aí o Bora esteve 4 h 02 min sem mandar nada — mas o padrão dos dias anteriores tem buracos maiores do que isso (de 2 para 4 de setembro esteve 31 h calado), logo 4 horas de silêncio não são prova de que o teste E2E mudou.

## Como foi lido (para quem quiser repetir)

| Passo | Pedido | Resposta |
|---|---|---|
| 1 | `GET https://api.resend.com/emails?limit=100` | HTTP 200, **77 e-mails**, `has_more: false` |
| 2 | `GET https://api.resend.com/emails?limit=100&after=cdb7228e-7cea-4d4f-ae32-501a0b2600b5` (o mais antigo dos 77) | HTTP 200, **0 e-mails**, `has_more: false` |
| 3 | `GET https://api.resend.com/emails/{id}` para 4 ids suspeitos | HTTP 200 nos 4; os campos batem com a lista |

Ou seja: **os 77 são a conta inteira**, do primeiro e-mail (2026-08-28 07:50:14Z) ao último (2026-09-06 20:09:19Z). A doc da Resend diz que `limit` vai no máximo a 100, que a paginação é por `after`/`before` com o id, e que **não há filtro por data** — por isso li tudo e filtrei aqui. A doc diz também que esta lista só tem e-mails enviados pela equipa (a conta é a mesma para o Em Dia e para o Bora: os dois saem de `boraguarda.com`).

Ficheiros brutos da leitura ficaram no scratchpad da sessão (`page1.json`, `page2.json`, `det_*.json`, `analisa.py`), fora do repo.

## 1. Desde as 17:00Z (18:00 Lisboa) até agora

**9 e-mails**, todos do Em Dia. Do Bora: **0**.

| created_at UTC (Lisboa) | para | de | assunto | last_event |
|---|---|---|---|---|
| 17:55:48 (18:55) | nilofulfarotuga@gmail.com | em-dia@boraguarda.com | O teu codigo do Em Dia | delivered |
| 17:56:16 (18:56) | **explorador.emdia@gmail.com** | em-dia@boraguarda.com | O teu codigo do Em Dia | **bounced** |
| 17:56:31 (18:56) | boraappbora@gmail.com | em-dia@boraguarda.com | O teu codigo do Em Dia | delivered |
| 17:58:33 (18:58) | **joao.silva@gmail.com** | em-dia@boraguarda.com | O teu codigo do Em Dia | **bounced** |
| 17:58:34 (18:58) | boraappbora+provafinal@gmail.com | em-dia@boraguarda.com | O teu codigo do Em Dia | delivered |
| 18:24:26 (19:24) | boraappbora@gmail.com | em-dia@boraguarda.com | O teu codigo do Em Dia | delivered |
| 19:24:12 (20:24) | boraappbora+turnstile@gmail.com | em-dia@boraguarda.com | O teu codigo do Em Dia | delivered |
| 19:35:04 (20:35) | boraappbora+video@gmail.com | em-dia@boraguarda.com | O teu codigo do Em Dia | delivered |
| 20:09:19 (21:09) | testuser12345@gmail.com | em-dia@boraguarda.com | O teu codigo do Em Dia | delivered |

**Contagem por `last_event` na janela:** delivered **7** · bounced **2** · suppressed **0** · delivery_delayed **0** · sent **0**.

**Todos os que NÃO são delivered/sent na janela (2):**

| hora UTC (Lisboa) | destinatário | estado | id |
|---|---|---|---|
| 2026-09-06 17:56:16 (18:56) | explorador.emdia@gmail.com | bounced | 5b409ad0-073b-4a51-80e8-e9e995e55677 |
| 2026-09-06 17:58:33 (18:58) | joao.silva@gmail.com | bounced | edac9244-cc78-4e72-8d8c-7661d0d08964 |

Depois das 17:58:33Z: **5 e-mails, 5 entregues, 0 falhas.**

## 2. Em Dia e Bora, separados (conta inteira, 77 e-mails)

| origem | de | e-mails | delivered | bounced | suppressed | delivery_delayed |
|---|---|---|---|---|---|---|
| Em Dia | `"Em Dia" <em-dia@boraguarda.com>` | 42 | 25 | 4 | 11 | 2 |
| Bora | `"Bora" <nao-responder@boraguarda.com>` (34) + `"Bora App" <onboarding@resend.dev>` (1) | 35 | 23 | 11 | 0 | 1 |
| **total** | | **77** | **48** | **15** | **11** | **3** |

Assuntos: «O teu codigo do Em Dia» 39 · «Confirm your email address» 3 (Em Dia, de manhã, antes do modelo em PT) · «Definir uma palavra-passe nova — Bora» 34 · «Redefinir palavra-passe -Bora - App» 1.

### 2a. Bora — envios para domínio `.test` ou endereço inventado

**12 envios, todos para `e2e_client_a@boraapp.test`** (um domínio que não existe na internet). Não há outro endereço inventado do lado do Bora; os restantes 23 do Bora foram para caixas reais (nilofulfarotuga, boraappbora, ramosjuniorwaldyr, francielly2310) e foram todos entregues.

| # | created_at UTC | last_event | id |
|---|---|---|---|
| 1 | 2026-09-01 16:43:14 | bounced | 49394c90-e3b8-40fb-b3aa-dafa50f64635 |
| 2 | 2026-09-02 09:29:34 | bounced | e73ea28d-1fa8-45df-a0bf-540b82cf7447 |
| 3 | 2026-09-02 10:37:44 | bounced | 3f1e5d32-391b-44d9-8543-3a44af48e8f8 |
| 4 | 2026-09-02 11:25:14 | bounced | 7e511f40-069d-497d-96e7-d44b1c9c1cad |
| 5 | 2026-09-02 23:38:56 | bounced | 01a0647d-6ae0-767f-9ac0-821295d2515b |
| 6 | 2026-09-04 07:02:42 | bounced | 8506e4a6-97f0-4e9e-bda9-32948ab9dfb9 |
| 7 | 2026-09-05 11:21:01 | bounced | f63ec5e7-8a25-4c44-a8dc-d98eaa62b9d2 |
| 8 | 2026-09-05 15:11:38 | bounced | fb6aeac5-2c4b-441a-81a4-75d3d09156d8 |
| 9 | 2026-09-05 15:23:37 | bounced | 72b4ec91-cdf7-42c0-ab36-d02957dd8eab |
| 10 | 2026-09-05 15:42:02 | bounced | 5ea970e3-033c-498d-9d91-8b666afc0d2b |
| 11 | 2026-09-05 19:53:13 | bounced | 6edf86b1-e3de-4a0c-a13f-16fee400a008 |
| 12 | **2026-09-06 16:35:25** (17:35 Lisboa) | **delivery_delayed** | 22f43659-29e3-413c-bf52-1d35941d95c8 |

- **Último envio do Bora a `.test`: 2026-09-06 16:35:25Z (17:35 Lisboa).** Ainda está `delivery_delayed` — a Resend está a tentar outra vez; como o domínio não existe, vai acabar em devolução como os 11 anteriores.
- **Nas últimas 6 horas (desde as 14:37:31Z)? SIM, este.** É também o último envio do Bora de qualquer tipo.
- Desde aí (4 h 02 min até à auditoria) o Bora não mandou nada. Como fica dito em cima, isso não chega para dizer que parou.
- Não toquei no Bora (repositório nem Supabase): é zona que só se lê.

## 3. Em Dia — endereços inventados

Último envio a cada um e o estado em que ficou:

| endereço | envios | último envio UTC (Lisboa) | last_event do último | id do último |
|---|---|---|---|---|
| test@emdia.pt | 1 | 2026-09-06 10:48:22 (11:48) | delivery_delayed | 2b68780d-ebd0-4af0-94c9-56306b5e2a23 |
| demo@emdia.pt | 1 | 2026-09-06 10:49:59 (11:49) | delivery_delayed | 38f1d9e5-3f28-4d1f-ae77-c3a14b36d886 |
| newuser@gmail.com | 1 | 2026-09-06 14:35:21 (15:35) | bounced | d4afba06-03ef-4894-9569-644c91ddb8d3 |
| test@gmail.com | 11 | 2026-09-06 15:40:04 (16:40) | suppressed | 443e0920-2084-45a8-9ee7-162563b06d90 |
| test@emdia.app | 1 | 2026-09-06 15:41:44 (16:41) | delivered | 86a8f10a-e493-4d72-9abf-2fd6f1ba09db |
| testuser1234@gmail.com | 2 | 2026-09-06 15:58:22 (16:58) | delivered | f101f233-200a-488e-84bd-a4e01841c7dd |
| explorador.emdia@gmail.com | 1 | 2026-09-06 17:56:16 (18:56) | **bounced** | 5b409ad0-073b-4a51-80e8-e9e995e55677 |
| joao.silva@gmail.com | 2 | 2026-09-06 17:58:33 (18:58) | **bounced** (o anterior, às 16:52:49Z, também) | edac9244-cc78-4e72-8d8c-7661d0d08964 |
| testuser12345@gmail.com | 1 | 2026-09-06 20:09:19 (21:09) | delivered | d0dda5f4-1d52-432e-af14-2c109d569e4c |
| maria.ferreira@… | **0** | — | nunca chegou à Resend | — |
| testa.silva@… | **0** | — | nunca chegou à Resend | — |

Notas, sem inventar:

- Os 11 `suppressed` são todos `test@gmail.com`: a Resend tem esse endereço numa lista de bloqueio depois de devolver, e o servidor respondia 200 na mesma. O último foi às 15:40:04Z; a trava do servidor (migração `trava_no_servidor_para_enderecos_que_nao_recebem`) foi aplicada às **15:54:06Z** (hora lida em `list_migrations` do projeto `tgdmgtmknbwhcqoxtjbs`) — e desde aí **não há mais nenhum** `test@`/`newuser@`/`demo@` na Resend. Bate certo.
- `joao.silva` e `explorador.emdia` são nomes de gente, a trava não os apanha nem devia. O `joao.silva` das 17:58:33Z saiu 12 segundos **depois** da migração `registo_por_convite_ate_ao_lancamento` (17:58:21Z): o gatilho é BEFORE INSERT e a conta já existia. As três contas foram apagadas a seguir (docs/provas/registo-por-convite-2026-09-06.md). Desde aí, **nenhum** dos dois voltou a aparecer.
- `testuser12345@gmail.com` às 20:09:19Z foi **entregue**: a caixa existe (é de um desconhecido). Veio de um IP da Google a passar pelo Turnstile (docs/provas/turnstile-2026-09-06.md). A guarda que apanha «nome de teste + números» é a migração 0029/0029b, aplicada às **20:29:55Z / 20:30:34Z** — 20 minutos depois desse envio. Entre a aplicação e a auditoria passaram só 7 minutos sem nada na Resend; **isso ainda não é prova de que a 0029 funciona ao vivo**, é só ausência de envios.
- `testuser1234@gmail.com` (15:57 e 15:58Z) também foi entregue: outra caixa de um desconhecido. Igual ao de cima, mas antes de haver Turnstile.
- `test@emdia.app` foi entregue: o domínio `emdia.app` não é nosso e aceita correio. `test@emdia.pt` e `demo@emdia.pt` ficaram em `delivery_delayed` desde as 10:48Z e nunca saíram daí (10 horas); as contas foram apagadas às 13:56 (bloco 1).
- `maria.ferreira` e `testa.silva` **não têm nenhuma linha na Resend** — a primeira foi recusada com `registo_fechado` antes de haver conta (MARCOS 19:05), a segunda só existe como caso de teste da guarda 0029 (é apelido, tem de passar). Nenhuma das duas gastou o domínio.

## 4. Tabela por hora — hoje, 2026-09-06 (43 e-mails)

| hora UTC (Lisboa) | total | delivered | bounced | suppressed | delivery_delayed | quem falhou |
|---|---|---|---|---|---|---|
| 10h (11h) | 4 | 2 | 0 | 0 | 2 | test@emdia.pt, demo@emdia.pt |
| 11h (12h) | 6 | 4 | 0 | 2 | 0 | test@gmail.com ×2 |
| 12h (13h) | 4 | 1 | 0 | 3 | 0 | test@gmail.com ×3 |
| 13h (14h) | 1 | 1 | 0 | 0 | 0 | — |
| 14h (15h) | 9 | 4 | 1 | 4 | 0 | test@gmail.com ×4, newuser@gmail.com |
| 15h (16h) | 8 | 6 | 0 | 2 | 0 | test@gmail.com ×2 |
| 16h (17h) | 2 | 0 | 1 | 0 | 1 | joao.silva@gmail.com (Em Dia), e2e_client_a@boraapp.test (Bora) |
| 17h (18h) | 5 | 3 | 2 | 0 | 0 | explorador.emdia@gmail.com, joao.silva@gmail.com |
| 18h (19h) | 1 | 1 | 0 | 0 | 0 | — |
| 19h (20h) | 2 | 2 | 0 | 0 | 0 | — |
| 20h (21h) | 1 | 1 | 0 | 0 | 0 | — |
| **hoje** | **43** | **25** | **4** | **11** | **3** | 18 por entregar (42 %) |

Das 18:00Z (19:00 Lisboa) em diante: 4 e-mails, 4 entregues, **0 falhas**.

## 5. Tabela por dia — conta inteira (77 e-mails, 28/08 a 06/09)

| dia | total | delivered | bounced | suppressed | delivery_delayed |
|---|---|---|---|---|---|
| 2026-08-28 | 15 | 15 | 0 | 0 | 0 |
| 2026-08-29 | 1 | 1 | 0 | 0 | 0 |
| 2026-08-30 | 3 | 3 | 0 | 0 | 0 |
| 2026-09-01 | 2 | 1 | 1 | 0 | 0 |
| 2026-09-02 | 4 | 0 | 4 | 0 | 0 |
| 2026-09-04 | 1 | 0 | 1 | 0 | 0 |
| 2026-09-05 | 8 | 3 | 5 | 0 | 0 |
| 2026-09-06 | 43 | 25 | 4 | 11 | 3 |
| **total** | **77** | **48** | **15** | **11** | **3** |

29 dos 77 (38 %) não foram entregues. Dos 15 bounces, 11 são do Bora (`boraapp.test`) e 4 do Em Dia (newuser, joao.silva ×2, explorador.emdia). Os 11 suppressed são todos do Em Dia (`test@gmail.com`).

## O que ficou feito, a prova, e o que não se pode dizer

- **Feito:** lida a conta inteira da Resend (77 e-mails, 2 páginas, `has_more: false` nas duas), 4 detalhes lidos, migrações do Em Dia listadas. Prova: as chamadas e códigos HTTP na secção «Como foi lido»; os ids estão em cada tabela e abrem-se com `GET /emails/{id}`.
- **Em Dia:** as três travas (15:54Z, 17:58Z, 20:30Z) batem com o registo — cada família de endereço morto deixa de aparecer depois da sua trava. **Zero falhas desde as 17:58:33Z.** **[Corrigido às 20:48Z: até às 20:46:44Z — aí saiu `explorer@gmail.com`, `suppressed`, que nenhuma das três travas cobre.]**
- **Bora:** continua a mandar para `e2e_client_a@boraapp.test`; o último foi às 16:35:25Z (17:35 Lisboa), dentro das últimas 6 horas. Não se pode dizer que parou. Continua em PENDENTE-DANILO.
- **Não se pode dizer:** que a guarda 0029 apanha o próximo `testuser…` ao vivo — só passaram 7 minutos desde que foi aplicada. Prova-se quando o próximo robô tentar, ou com um pedido de teste que NÃO passe pela Resend (INSERT com rollback, como já foi feito às 21:55 no MARCOS).
- **Saltado:** nada. Não corri build nem testes (RAM ocupada pelo emulador), não instalei nada, não toquei no Bora.

## Adenda da sessão interactiva (2026-09-06, 22:15 Lisboa)

Depois da verificação das 20:48Z a Resend registou mais dois pedidos de código a endereços que já estão na **lista de supressão** (por isso não saíram, não devolveram e não gastam o domínio): `explorer@gmail.com` às 20:46:44Z e `explorador.emdia@gmail.com` às 20:54:12Z, ambos `suppressed`. Vieram pelo formulário da app web com o captcha ligado, ou seja, de um browser que passa o Turnstile (o renderizador da Google, como a sessão da noite provou às 20:09Z). **Contas novas de teste do Em Dia e do Bora: zero envios a endereços mortos desde as 17:58:33Z** (última devolução) — os únicos envios do Em Dia depois disso foram para `boraappbora+…@gmail.com` (turnstile, video, emulador, emulador2), todos `delivered`. O Bora não enviou nada depois das 16:35:25Z.
