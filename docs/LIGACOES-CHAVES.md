# Ligações e chaves — InvoiceXpress, Enable Banking e DGEG

> Escrito a 2026-09-06 (noite), por um agente, só a ler. **Não criei conta
> nenhuma, não guardei segredo nenhum, não liguei nada.** Este ficheiro é o
> plano exacto para o dia em que houver contas e chaves.
>
> Fontes: o código deste repositório, a base de dados do Em Dia
> (`tgdmgtmknbwhcqoxtjbs`, só SELECT), e os sites oficiais lidos hoje
> (os endereços e códigos HTTP estão no fim, em «Fontes»).
> Tudo o que não consegui ver com os meus olhos está marcado **POR CONFIRMAR**.
>
> **Verificação (2026-09-06, noite, segundo agente, contexto limpo):** cada
> ficheiro, flag, segredo e função citados foram reabertos; a base foi lida de
> novo (só SELECT); os sites foram lidos outra vez (WebFetch, `curl` e um
> browser real). O que estava errado foi corrigido no próprio texto e está
> listado no fim, em «Correções da verificação».

---

## 0. A regra comum — como se guarda uma chave e como se liga uma opção

**Onde vivem as chaves.** No Vault do Supabase, nunca no repositório. Criam-se
por SQL (no MCP ou no SQL Editor), com a função que já existe desde a migração
`20260906_0004_vault_cron_admin.sql`:

```sql
select public.guardar_segredo('nome_do_segredo', '<valor>', 'descrição curta');
```

As Edge Functions lêem com `lerSegredo('nome_do_segredo')` de
`supabase/functions/_shared/segredos.ts` — primeiro tenta a variável de
ambiente em MAIÚSCULAS, depois `public.ler_segredo(nome)` com o service role.
Os nomes são em minúsculas com `_`. Os que existem hoje (SELECT em
`vault.secrets`, 2026-09-06):

| nome | para quê |
|---|---|
| `cron_secret` | header `x-cron-secret` do pg_cron para as funções |
| `correio_secret` | segredo partilhado com o Worker da Cloudflare das faturas |
| `gemini_api_key` | chave Gemini do projeto Google Cloud `em-dia-507723` |

A cópia local de cada chave fica em `C:\BoraLocal\_segredos\em-dia\` (pasta
intocável, fora do repo).

**Onde vivem os interruptores.** Na tabela `feature_flags` (colunas `free`,
`pro`, `familia`). A app lê-os do servidor em `lib/stores/regras_store.dart`
(`PlanoStore.permitida(chave)`; em trial está tudo aberto; flag desconhecida
não tranca). Nos preços da DGEG a trava está também na política RLS, por isso
ligar a flag abre a leitura na base no mesmo segundo, sem publicar app.

**Estado hoje, literal (SELECT feito a 2026-09-06):**

```
flag  banco_movimentos        free=false pro=false familia=false
flag  faturacao_certificada   free=false pro=false familia=false
flag  precos_combustivel      free=false pro=false familia=false
cron  em-dia-avisos-hora      5 * * * *   | active=true
cron  em-dia-vigia-ligacoes   20 7 * * 1  | active=true
sync  precos_combustivel_sync corridas=1  gravou_alguma=false
tabela precos_combustivel     linhas=0
```

Ou seja: **não há cron para os preços da DGEG**, e nenhum segredo dos três
serviços existe ainda.

---

## 1. DGEG — preços dos combustíveis

### O que já está feito no código

| Peça | Onde | Estado |
|---|---|---|
| Tabelas `postos_combustivel`, `precos_combustivel`, `precos_combustivel_sync` | `supabase/migrations/20260906_0026_precos_de_combustivel.sql` | aplicadas, vazias (0 linhas) |
| RLS: só lê quem tem sessão **e** só quando `feature_flags.precos_combustivel` estiver ligada | mesma migração (políticas `postos_leitura`, `precos_leitura`) | aplicada |
| Flag `precos_combustivel` | `supabase/migrations/20260906_0016_cadeados_e_avisos.sql` | falso nos três planos |
| Robô `sync-precos-combustiveis` | `supabase/functions/sync-precos-combustiveis/index.ts` | escrito e **provado em seco**: 14.178 linhas, 3.131 postos, 1,3 s, guardou zero (`docs/provas/bloco5-ligacoes-2026-09-06.md`) |
| Autenticação do robô | header `x-cron-secret` = `cron_secret` do Vault, **ou** JWT de admin | feito |
| Travão de queda | menos de 5.000 linhas → não grava, regista `saltado` | feito |
| Na app | `lib/regras/vale_a_pena.dart` usa o preço do último abastecimento da pessoa; `lib/screens/carro/carro_screen.dart` mostra o cartão `_EmBreve` (decisão D11) | **nenhum Dart lê ainda as tabelas** |
| Minuta preenchida | `docs/loja/dgeg/minuta-partilha-informacao-em-dia.docx` | falta NIF, morada, assinatura e rubrica |
| E-mail | rascunho no Gmail de `boraappbora@gmail.com` para `precoscombustiveis@dgeg.gov.pt`, assunto «Pedido de subscrição do Documento «Partilha de Informação» — preços dos combustíveis (app Em Dia)» (id `r9185747425691357001`, visto hoje) | tem `NIF [preencher]` no corpo |

**Importante:** o robô de hoje lê a API pública do portal
(`/api/PrecoComb/PesquisarPostos`), sem chave. O que a DGEG dá depois da
autorização é **outra coisa** — ver abaixo.

### O que confirmei no site (2026-09-06, `precoscombustiveis.dgeg.gov.pt/apresentacao/`, HTTP 200)

- «A informação disponível neste sítio é gratuita, podendo ser utilizada
  livremente. **É proibida a sua utilização para fins comerciais.**»
- **Não há registo online para entidades.** O separador «Registo» do portal é
  para donos de postos. O caminho é este, com as palavras deles:
  1. «A entidade que pretende subscrever o Documento envia o pedido, **por
     correio ou email (precoscombustiveis@dgeg.gov.pt)**, dirigido ao
     Diretor-Geral de Energia e Geologia, solicitando o acesso à informação,
     bem como a descrição do projeto a desenvolver e a forma de divulgação do
     mesmo, indicando inequivocamente que toda e qualquer divulgação é gratuita
     e universal;»
  2. «O pedido deve ser acompanhado de dois exemplares do documento "Partilha
     de Informação", **devidamente assinado e rubricado, sem preenchimento de
     data** (um exemplar, caso o pedido seja feito por email);»
  3. «a DGEG analisa-o e, em caso de deferimento, assinará e datará o mesmo,
     enviando depois um exemplar para a Requerente **conjuntamente com o Manual
     de Utilizador**;»
  4. «Por fim, a DGEG procede ao registo da entidade requerente e **envia para
     o email da entidade as credenciais de acesso ao Portal.**»
- O Anexo II da minuta (li o `.docx`) diz o que são essas credenciais: «As
  operações definidas neste **Web Service** só podem ser acedidas através de
  canal seguro com autenticação por **utilizador (username) e senha de acesso
  (password), que serão atribuídos pela DGEG.**» E avisa: «O acesso aos dados
  do sistema é diário podendo estar restringido aos seguintes períodos: 03:00
  às 04:00 horas; 13:00 às 14:00 horas; 20:00 às 21:00 horas.»
- Condição de fundo (já decidida em D40): os preços têm de ficar **grátis para
  toda a gente** na app, com a DGEG como fonte. A minuta obriga a «não fazer
  qualquer exploração económica».

**Pede cartão?** Não. Não custa dinheiro.
**Pede assinatura?** **Sim** — assinatura à mão e rubrica em todas as páginas,
sem data, mais NIF e morada. É um compromisso da empresa; nenhum agente o faz.

### O que falta

**Da pessoa (Danilo):**
1. Abrir `docs/loja/dgeg/minuta-partilha-informacao-em-dia.docx`, preencher
   **NIF** e **morada** (a do rascunho do e-mail é «Rua do Torreão 14, 6300-610
   Guarda» — confirma), assinar e rubricar todas as páginas, **sem data**.
2. No rascunho do Gmail (boraappbora), trocar `NIF [preencher]` pelo número,
   anexar o documento assinado (PDF), enviar.
3. Esperar a resposta. Vêm por e-mail: o exemplar assinado pela DGEG, o
   **Manual de Utilizador** e as **credenciais** (utilizador + senha).
4. Guardar o exemplar assinado e o Manual em
   `C:\BoraLocal\_segredos\em-dia\dgeg\` — **não** no repo (tem NIF e
   assinatura).

**Segredos a criar no Vault (nomes escolhidos agora, não existem ainda):**

| nome | valor |
|---|---|
| `dgeg_utilizador` | o username que a DGEG enviar |
| `dgeg_senha` | a password que a DGEG enviar |

**Código que ainda falta (não se escreve antes de ter o Manual — regra D37, «O que não se pode provar não se escreve»):**
- **POR CONFIRMAR com o Manual:** se a DGEG exigir que os dados venham do Web
  Service (e não da API pública que o robô usa hoje), adaptar
  `sync-precos-combustiveis` para ler `dgeg_utilizador`/`dgeg_senha` com
  `lerSegredo` e chamar o endereço que o Manual indicar. O resto da função
  (mapear, travão de queda, gravar aos pedaços de 500, registo) mantém-se.
- Um cron diário — hoje não existe. Se o Manual confirmar as janelas horárias,
  a corrida tem de cair dentro de uma delas **em hora de Lisboa**. O pg_cron
  conta em UTC, por isso a forma segura é o truque da `avisos-cron` (que corre
  de hora a hora, `5 * * * *`, e só trabalha quando `agoraLisboa()` dá a hora
  certa em `Europe/Lisbon`): aqui basta agendar às duas horas UTC possíveis e
  a função só trabalhar quando forem 03:xx em Lisboa.
- Na app: trocar o `_EmBreve` de `carro_screen.dart` por um cartão real
  (é o «como se desfaz» da decisão D11) e, opcionalmente, deixar o «vale a pena
  esta corrida» sugerir o preço do posto mais perto. **Fora de qualquer
  cadeado** (D40).

### Como se liga (SQL, pela ordem)

```sql
-- 1. as credenciais (só depois de as receber por e-mail)
select public.guardar_segredo('dgeg_utilizador', '<utilizador>', 'DGEG Web Service — utilizador (Partilha de Informação)');
select public.guardar_segredo('dgeg_senha',      '<senha>',      'DGEG Web Service — senha (Partilha de Informação)');

-- 2. o interruptor — os três a verdadeiro, porque a DGEG exige grátis e universal (D40)
update public.feature_flags
   set free = true, pro = true, familia = true
 where chave = 'precos_combustivel';

-- 3. o cron diário (mesmo molde do em-dia-avisos-hora da migração 0004;
--    a hora final depende do Manual — ver nota acima)
select cron.unschedule(jobid) from cron.job where jobname = 'em-dia-precos-combustivel';
select cron.schedule(
  'em-dia-precos-combustivel',
  '20 2,3 * * *',   -- 02:20 e 03:20 UTC = 03:20 de Lisboa no verão e no inverno; a função escolhe
  $$
  select net.http_post(
    url := 'https://tgdmgtmknbwhcqoxtjbs.supabase.co/functions/v1/sync-precos-combustiveis',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || '<chave anon do projeto — a mesma da migração 0004>',
      'x-cron-secret', coalesce((select decrypted_secret from vault.decrypted_secrets where name = 'cron_secret'), '')
    ),
    body := '{"origem":"pg_cron"}'::jsonb
  );
  $$
);
```

**Prova de que ligou (o que tem de sair):**

```sql
select corrido_em, gravou, linhas, postos, ms, nota
  from public.precos_combustivel_sync order by corrido_em desc limit 1;
-- esperado: gravou = true, linhas > 5000
select count(*) from public.precos_combustivel;   -- esperado: > 5000
```

E na app, com uma conta **grátis** (não trial), a tabela tem de responder —
a RLS abre sozinha com a flag.

**Como se desliga:** `update public.feature_flags set free=false, pro=false,
familia=false where chave='precos_combustivel';` — a RLS fecha a leitura no
mesmo instante e o robô volta a correr em seco. Se um dia se quiser sair do
acordo, é por escrito à DGEG com 15 dias de antecedência (cláusula da minuta).

---

## 2. InvoiceXpress — emitir fatura-recibo pela app

### O que já está feito no código

| Peça | Onde | Estado |
|---|---|---|
| Flag `faturacao_certificada` | `supabase/migrations/20260906_0016_cadeados_e_avisos.sql` | falso nos três planos |
| Decisão do fornecedor e da modalidade (Multiconta) | `docs/DECISOES.md` D19; razão de não haver código em D37 | escrito — **atenção:** a D19 diz «o código e as chamadas estão escritos e ensaiados»; não estão (linha abaixo), e a D37 explica porquê |
| Código Dart ou Edge Function com «invoicexpress» | — | **zero** (`grep -ril invoicexpress lib/ supabase/` não devolve nada) |
| O que a app faz hoje | botão «Fazer um recibo verde» abre o portal da AT (`ligacoes_estado.recibo_emitir`, migração 0025) | a funcionar |

Não há segredo, tabela, função nem ecrã. Foi de propósito: sem conta e sem
chave, era código que nunca correu.

### O que confirmei no site (2026-09-06; reverificado à noite por um segundo agente)

**Há duas páginas de preços vivas, e a primeira versão deste ficheiro tinha
lido a errada.** `invoicexpress.com/precos` responde hoje com **302 para
`/recursos/`** (a página de webinars e ebooks — nem um preço; `curl` e um
browser real dão o mesmo). O menu do site aponta para
`invoicexpress.com/planos-e-precos/` → `invoicexpress.com/planos-precos/`
(HTTP 200, título «InvoiceXpress - Planos e Preços»). A página
`invoicexpress.com/planos-precos-old/` (HTTP 200, título «Planos e Preços
**OLD**») é a que tem os planos XS/S/M/L, o «Stripe» e o «Subscrição mensal
indisponível» — foi daí que saíram os números da primeira versão. Fica
registado o que diz cada uma; **manda a do menu**.

**Preços — página do menu (`/planos-precos/`; «*Todos os preços apresentados
acrescem de IVA à taxa em vigor»; ciclo de renovação «Mensal / Semestral /
Anual / Bienal»; todos os planos com «Utilizadores ILIMITADOS» e «Acesso à API
para integração»):**

| plano | preço | documentos/mês |
|---|---|---|
| X3 | 3 €/mês | 3 |
| X10 | 9 €/mês | 10 |
| X20 | 14 €/mês | 20 |
| X30 | 18 €/mês | 30 |
| X100 | 24 €/mês | 100 |
| X500 | 29 €/mês | 500 |
| X750 | 34 €/mês | 750 |

Ou seja: os números da D19 (X3 a 3 €, X10 a 9 €, X100 a 24 €, X500 a 29 €)
**são os do site de hoje**. A primeira versão deste ficheiro dizia o contrário
porque tinha lido a página «OLD».

**Preços — página «OLD» (`/planos-precos-old/`), só para não se perder:** XS
6 €/mês («*Subscrição mensal indisponível.*», 5 documentos, 2 utilizadores);
S 12 €/mês com subscrição anual (20 documentos, 3 utilizadores); M 24 €/mês
anual (500 documentos, 5 utilizadores); L 45 €/mês ou 35 €/mês anual (1.500
documentos, 10 utilizadores); «Precisa de um Plano XL com + de 1500 doc/mês ou
um plano Multi-Conta? Fale Connosco.»

**Multiconta (página do menu):** «Precisa de um plano de faturação
personalizado ou um plano multi-conta? (…) dê-nos a conhecer a realidade do
seu negócio e em troca receberá a melhor proposta da nossa equipa. Fale
Connosco» — **não é auto-serviço**, é proposta comercial. Os endereços das
duas páginas de preços estão escondidos pelo Cloudflare
(`/cdn-cgi/l/email-protection#…`); decifrados, são
`comercial@invoicexpress.com` (é o `href` do botão «Enviar email» da página
«OLD», e o mesmo endereço está na página do menu), `suporte@invoicexpress.com`
e `support@invoicexpress.com`. Logo o `comercial@invoicexpress.com` do
`PARA-LIGAR.md` **está confirmado** — é o contacto comercial do site.

**Trial (página do menu, palavras deles):** «Ao fazer o registo no
InvoiceXpress, tem direito a 30 dias grátis para experimentar a aplicação.
Pode criar os documentos que quiser, mas a configuração da comunicação da sua
faturação à Autoridade Tributária **não está disponível durante o período
experimental gratuito**. No final dos 30 dias, se não subscrever nenhum plano,
a sua conta ficará **suspensa** até efetuar um pagamento **ou mudar para o
plano grátis**.» — ou seja, não cobra sozinho. Esse «plano grátis» não aparece
na tabela de planos; o que é e o que deixa fazer fica **POR CONFIRMAR** dentro
da conta.
**Pede cartão no registo?** **Não no primeiro ecrã** — visto num browser real
em `web.invoicexpress.com/signup` (a página é JavaScript; o HTML cru tem 1,6 KB
sem formulário): o ecrã pede «País onde está sediado o seu negócio» (Portugal /
Outro), «Email», a caixa «Li e concordo com os Termos e Condições e com a
Política de Privacidade», a caixa opcional de marketing e um botão
«Continuar». **Não se carregou em «Continuar»** (criar contas é da pessoa),
por isso os ecrãs seguintes não foram vistos.
Pagamento depois do trial (página do menu): «aceitamos pagamentos por Cartão de
Crédito para todo o tipo de renovações (mensais, semestrais, anuais ou bienais)
e por Multibanco e MB WAY para renovações a partir de 6 meses. Não aceitamos
pagamento por dinheiro, cheque ou transferência bancária.» (o «através do
Stripe» só está na página «OLD»). Sem fidelização: «não implica nenhum contrato
com períodos de permanência ou compromisso da sua parte»; reembolso do período
não usado «até 30 dias após o pagamento (a novas subscrições de novos
clientes)».

**A armadilha do trial, confirmada nas duas páginas:** a comunicação à AT não
está disponível no período grátis. Logo, com conta grátis prova-se a API mas
**não** o recibo a chegar à AT.

**API** (`docs.invoicexpress.com` e `invoicexpress.com/api-v2/getting-started/`,
HTTP 200; o `developers.invoicexpress.com` **não respondeu** deste PC — erro de
SSL, código 000):
- A chave obtém-se dentro da conta: «You can find your ACCOUNT_NAME and API_KEY
  here: **https://www.app.invoicexpress.com/users/api**».
- Formato: `https://ACCOUNT_NAME.app.invoicexpress.com/invoices.json?api_key=API_KEY`
  — o `ACCOUNT_NAME` é o subdomínio escolhido no registo; a chave vai na query
  string; `Content-Type: application/json` em POST/PUT.
- Contas (o que interessa à Multiconta):
  - `POST /api/accounts/create.json` — corpo `account`: `first_name`,
    `last_name`, `organization_name` (obrigatório, ≤ 100 — «Values longer than
    100 characters are rejected with HTTP 422»), `phone`, `email`
    (obrigatório), **`password` e `password_confirmation` (obrigatórios —
    faltavam na primeira versão deste ficheiro)**, `fiscal_id`, `tax_country`
    (enum `"1"`/`"2"`/`"3"`), `language`, `terms` (obrigatório, enum
    `"1"`/`"0"` — aceitar é `"1"`), `marketing`. Resposta **201**:
    `{"account":{"id":"12345","name":"mycompany","url":"https://mycompany.app.invoicexpress.com","api_key":"…","state":"active"}}`
    — devolve logo a chave da conta nova.
  - `POST /api/accounts/create_already_user.json` — o mesmo para quem já tem
    utilizador (resposta **200**, não 201).
  - `GET /api/accounts/{id}/get.json` → `organization_name`, `fiscal_id`,
    `email`, `state`, **`at_configured`**, **`trial`** (serve de prova).
  - `POST /api/v3/accounts/at_communication.json` — corpo `at_communication`:
    `at_subuser` (ex.: `"500100200/1"`), `at_password`, `communication_type`
    (`auto` | `manual` | `guides` | `portal_at`). É aqui que entra o
    sub-utilizador do Portal das Finanças de cada pessoa.

**Pede cartão?** No trial, **não no primeiro ecrã** (visto; os ecrãs a seguir
ao «Continuar» não). Para usar a sério, **sim**: cartão de crédito em qualquer
ciclo, ou Multibanco/MB WAY a partir de 6 meses — e o mais barato é o **X3 a
3 €/mês + IVA, com renovação mensal** (3 documentos/mês; o X10 a 9 €/mês dá 10).
**Pede assinatura?** Não há contrato nem fidelização. A Multiconta é uma
proposta comercial — pode trazer condições próprias (POR CONFIRMAR quando
responderem).

### O que falta

**Da pessoa (Danilo):**
1. Criar a conta em `https://web.invoicexpress.com/signup` com o e-mail
   `boraappbora@gmail.com`. O nome de conta (subdomínio) sugerido: `emdia`.
   Grátis 30 dias.
2. Ir a `https://www.app.invoicexpress.com/users/api` e copiar `ACCOUNT_NAME`
   e `API_KEY`. Guardar em `C:\BoraLocal\_segredos\em-dia\invoicexpress.env`
   (fora do repo).
3. Carregar em «Fale Connosco» em `invoicexpress.com/planos-precos/` (ou
   escrever a `comercial@invoicexpress.com`) a pedir a
   **proposta Multiconta**, explicando: plataforma com N prestadores, cada um a
   faturar com o seu NIF, contas criadas por API.
4. Escolher e pagar um plano (cartão — **dinheiro, é teu**). Sem plano pago
   **não há comunicação à AT**, e sem isso não se prova o circuito.
5. Certificado da AT — **já confirmado** (2026-09-06, HTTP 200): a lista em
   `portaldasfinancas.gov.pt/pt/consultaProgCertificadosM24.action` tem a
   linha «Invoicexpress | 1.0 | INVOICEXPRESS, LDA | **192** | Certificado |
   2010-11-09», e o rodapé do site diz «Certificado pela Autoridade Tributária
   N.º 192». (A mesma empresa tem também o «Fatura+ | Online | 1317».)

**Segredos a criar no Vault (nomes escolhidos agora):**

| nome | valor |
|---|---|
| `invoicexpress_conta` | o `ACCOUNT_NAME` da conta-mãe (o subdomínio, ex.: `emdia`) |
| `invoicexpress_api_key` | a `API_KEY` da conta-mãe (a que cria as contas dos utilizadores) |

As chaves **de cada utilizador** (a `api_key` que o `create.json` devolve)
**não vão para estes dois nomes**. Proposta: uma por pessoa no mesmo Vault,
`invoicexpress_conta_<user_id>` (só o service role lê), ou uma tabela
`faturacao_contas` com a chave cifrada — **decisão a tomar quando se escrever
o código**, ver «PARA O DANILO».

**Código que ainda falta (não se escreve antes de haver chave — D37):**
Edge Function `faturacao-invoicexpress` (criar a conta da pessoa, configurar a
comunicação à AT, emitir a fatura-recibo, guardar o PDF no balde privado),
tabelas `faturacao_contas` e `faturas_emitidas`, e o ecrã. Regra de segurança
já decidida: a chave nunca vai ao telemóvel — tudo passa pela função.

### Como se liga (SQL, pela ordem)

```sql
-- 1. as chaves da conta-mãe
select public.guardar_segredo('invoicexpress_conta',   '<ACCOUNT_NAME>', 'InvoiceXpress — nome da conta-mãe (subdomínio)');
select public.guardar_segredo('invoicexpress_api_key', '<API_KEY>',      'InvoiceXpress — chave da API da conta-mãe (Multiconta)');
```

**Prova da chave antes de ligar seja o que for** (num terminal, só leitura):

```
curl "https://<ACCOUNT_NAME>.app.invoicexpress.com/api/accounts/<id>/get.json?api_key=<API_KEY>"
-- esperado: HTTP 200 e, na resposta, "trial": false e "at_configured": true.
-- Se vier "trial": true, ainda não dá para provar a AT. Se vier 401, a chave está errada.
```

```sql
-- 2. o interruptor — só depois da função existir e estar provada.
--    free fica a falso (é funcionalidade paga; ver PARA O DANILO)
update public.feature_flags
   set pro = true, familia = true
 where chave = 'faturacao_certificada';
```

**Como se desliga:** a mesma linha com `false`. A conta InvoiceXpress
continua a existir; cancela-se no menu Conta deles.

---

## 3. Enable Banking — ler os movimentos do banco

### O que já está feito no código

| Peça | Onde | Estado |
|---|---|---|
| Flag `banco_movimentos` | `supabase/migrations/20260906_0016_cadeados_e_avisos.sql` | falso nos três planos |
| Decisão (não ser TPP; Enable Banking em Restricted Production; camada `BancoFornecedor`) | `docs/DECISOES.md` D20; sem código por D37 | escrito |
| Código com «enablebanking» ou `BancoFornecedor` | — | **zero** (`grep` em `lib/` e `supabase/` não devolve nada) |
| Regra de arquitetura | `docs/PARA-LIGAR.md` §4 | a chave privada vive nas Edge Functions, **nunca** no Flutter |
| O que existe parecido | `supabase/functions/ler-extrato` lê extratos Uber/Bolt por foto | é outra coisa, não é banco |

### O que confirmei no site (2026-09-06, `enablebanking.com/docs/...`, HTTP 200)

- **Painel:** `https://enablebanking.com/cp/applications` (respondeu 200).
  Primeiro cria-se a conta de utilizador do painel («Signing up for an
  account»). O `/apply-now` da página inicial devolve **404** e **não existe
  página de preços** — o preço é por pedido.
- **Registar a aplicação:** escolhe-se **Sandbox** ou **Production**; o
  browser **gera a chave privada** («If you chose to generate the private key,
  it will be saved into your downloads folder. Name of the file will be the
  same as the ID assigned to the newly registered application (e.g.
  `aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee.pem`)») — ou gera-se fora (OpenSSL) e
  entrega-se só a pública. A aplicação recebe um **ID em UUID**. A
  documentação **não diz** se se pode trocar a chave de uma aplicação já
  registada (a secção «Editing an Application» só fala em «make the desired
  changes») — **POR CONFIRMAR no painel**; até lá trata-se o `.pem` como
  descarregado uma vez e, se se perder, regista-se outra aplicação.
  Em Production o formulário pede: nome e descrição, **e-mail de proteção de
  dados**, **URL da política de privacidade** e **URL dos termos de serviço**.
  A FAQ diz que, com a aplicação activada em modo restrito, «the terms and
  privacy links and the data protection email **are not checked**» — mas os
  campos existem.
- **Activar em Production, dois caminhos:**
  - «**Unrestricted Mode**: Requesting full activation requires manual review
    by our personnel, who will (…) verify your **contract** and completion of
    "**Know-Your-Customer**" process, and associate it with your **billing
    account**.»
  - «**Restricted Mode (Account Linking)**: You can activate an application by
    linking your own bank accounts for internal testing. (…) data retrieval is
    strictly limited to the whitelisted, linked accounts.» A página das contas
    ligadas diz para que serve: «enabling evaluation in real-life scenarios
    **before a contract** for full production usage (…) has been signed, as
    well as **individual non-commercial use**» e «The application will stay in
    this state until an agreement has been signed.»
- **FAQ, preço e contrato:** «You can create an Enable Banking account and
  access both mock and production environments **before signing a contract**,
  but applications **can't be made available to the public** before a contract
  is signed.» / «Our pricing is volume based. (…) There is a **minimum
  invoicing per month** (…) For a quota please contact sales at
  info@enablebanking.com.»
- **Autenticação da API** (`/docs/api/reference/`): JWT assinado **RS256** com
  a chave privada; header `{"typ":"JWT","alg":"RS256","kid":"<ID da
  aplicação>"}`; claims `iss: "enablebanking.com"`, `aud:
  "api.enablebanking.com"`, `iat`, `exp` («Maximum allowed time-to-live for
  token is 86400 seconds»). Vai em `Authorization: Bearer <jwt>`. Base:
  `https://api.enablebanking.com`. Chamadas que interessam: `GET /application`
  (prova de vida), `POST /auth` (começa a autorização no banco), `POST
  /sessions` (troca o código por sessão), `GET /accounts/{id}/transactions`.
- Ligar as contas próprias: botão «Activate by linking accounts» no painel →
  página de autorização do banco → **login no banco e confirmação no
  telemóvel**. Só a pessoa.
- MFA no painel: no separador Profiles, com número de telefone. Recomendado.

**Pede cartão?** Não — em lado nenhum da documentação. Em restrito é grátis.
**Pede assinatura?** Em restrito, **não**. Para abrir ao público, **sim**:
contrato + KYB + conta de faturação, com preço por pedido a
`info@enablebanking.com`.

### O que falta

**Da pessoa (Danilo):**
1. Criar a conta do painel em `https://enablebanking.com/cp/` (e-mail
   `boraappbora@gmail.com`); ligar o MFA no Profiles.
2. Registar uma aplicação **Production** (não Sandbox — o objetivo é ver
   movimentos reais das tuas contas): nome «Em Dia», descrição curta, e-mail
   de proteção de dados `boraappbora@gmail.com`, política de privacidade
   `https://em-dia-site.pages.dev/privacidade` (existe, HTTP 200), termos de
   serviço → **não existe página de termos ainda** (`/termos` deu 404) —
   **falta uma**, mesmo que em restrito não a verifiquem. URL de retorno
   (redirect): a decidir quando se escrever a função; sugestão
   `https://app-em-dia.pages.dev/banco/retorno`.
3. Deixar o browser gerar a chave. O ficheiro `<ID>.pem` cai em Transferências:
   mover **de imediato** para `C:\BoraLocal\_segredos\em-dia\enable-banking\`.
   Nunca para o repo.
4. «Activate by linking accounts» com as tuas contas (CGD, Millennium, etc.) —
   login no banco + app do banco no telemóvel.

**Segredos a criar no Vault (nomes escolhidos agora):**

| nome | valor |
|---|---|
| `enable_banking_app_id` | o UUID da aplicação (é o `kid` do JWT) |
| `enable_banking_private_key` | o **texto inteiro** do `.pem`, com as linhas `-----BEGIN PRIVATE KEY-----` / `-----END PRIVATE KEY-----` e as quebras de linha |
| `enable_banking_redirect_url` | não é segredo, mas vive aqui por conveniência: o URL de retorno registado no painel |

**Código que ainda falta (não se escreve antes de haver chave — D37):**
Edge Function `banco-enable` (assinar o JWT com WebCrypto `RS256`/`pkcs8`,
`POST /auth`, `POST /sessions`, `GET /accounts/{id}/transactions`), tabelas
`banco_ligacoes` (utilizador, sessão, conta, válido até) e `banco_movimentos`,
e o ecrã. Enquanto a aplicação estiver em modo restrito, só as contas do
Danilo respondem — por isso o ecrã tem de ficar **só para admin**
(`is_admin()`), e a flag pública continua a falso.

### Como se liga (SQL, pela ordem)

```sql
-- 1. as chaves (o .pem inteiro vai como texto; no SQL Editor usa $pem$ ... $pem$ para não escapar as quebras)
select public.guardar_segredo('enable_banking_app_id',      '<uuid da aplicação>', 'Enable Banking — ID da aplicação (kid do JWT)');
select public.guardar_segredo('enable_banking_private_key', $pem$-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----$pem$, 'Enable Banking — chave privada RSA da aplicação (gerada no painel, descarregada uma vez)');
select public.guardar_segredo('enable_banking_redirect_url', 'https://app-em-dia.pages.dev/banco/retorno', 'Enable Banking — URL de retorno registado no painel');
```

**Prova das chaves antes de ligar seja o que for:** assinar um JWT com a chave
e chamar `GET https://api.enablebanking.com/application` — esperado **HTTP
200** com o nome da aplicação. 401 = chave ou `kid` errados.

```sql
-- 2. o interruptor — SÓ depois do contrato assinado com a Enable Banking
--    (em modo restrito, abrir ao público é proibido pelos termos deles)
update public.feature_flags
   set pro = true, familia = true
 where chave = 'banco_movimentos';
```

**Como se desliga:** a mesma linha com `false`; e no painel deles, desativar
a aplicação.

---

## 4. Resumo numa tabela

| serviço | cartão? | assinatura? | segredos que faltam (Vault) | o que já existe no código |
|---|---|---|---|---|
| **DGEG** | não | **sim** — minuta assinada e rubricada, sem data, + NIF/morada; envio por e-mail a `precoscombustiveis@dgeg.gov.pt` | `dgeg_utilizador`, `dgeg_senha` (chegam por e-mail depois do deferimento) | tabelas, RLS, flag, robô provado em seco (14.178 linhas, guardou 0), minuta preenchida, e-mail em rascunho; **falta cron e o cartão na app** |
| **InvoiceXpress** | trial: não no primeiro ecrã (visto; ecrãs seguintes não); a sério: **sim** (cartão em qualquer ciclo, ou Multibanco/MB WAY a partir de 6 meses; o mais barato é X3 a 3 €/mês + IVA, mensal) | não (sem fidelização); Multiconta é proposta comercial, POR CONFIRMAR | `invoicexpress_conta`, `invoicexpress_api_key` (+ uma por utilizador, a decidir) | só a flag e a decisão; **zero código** (de propósito) |
| **Enable Banking** | não | restrito: **não**; público: **sim** (contrato + KYB, preço por pedido) | `enable_banking_app_id`, `enable_banking_private_key`, `enable_banking_redirect_url` | só a flag e a decisão; **zero código** (de propósito); falta página de termos no site |

---

## 5. PARA O DANILO — decisões que só tu dás (não travam o resto)

1. **InvoiceXpress — que plano?** Na página do menu o mais barato é o **X3 a
   3 €/mês + IVA, mensal** (3 documentos/mês — pouco para vários
   utilizadores); X10 a 9 € (10 docs), X100 a 24 € (100), X500 a 29 € (500),
   todos com utilizadores ilimitados e API. Ou esperar pela proposta Multiconta
   antes de pagar seja o que for — é ela que diz como se paga por cada
   prestador.
2. **A fatura-recibo pela app é só Pro/Família?** No SQL acima deixei `free`
   a falso. Se quiseres no grátis, é mais uma linha.
3. **Onde guardar a chave de cada utilizador do InvoiceXpress:** Vault (uma
   entrada por pessoa) ou tabela com cifra. E a **senha do sub-utilizador da
   AT**: guardar cifrada, ou mandar uma vez ao InvoiceXpress e deitar fora
   (mais seguro; a pessoa repete se falhar) — a pergunta já está em
   `PARA-LIGAR.md` §3.
4. **Enable Banking — quando assinar o contrato?** Em restrito é grátis e só
   vê as tuas contas; para utilizadores reais é contrato + KYB + mínimo mensal
   (sem preço público). A D20 diz: comparar com a open-banking.io (3 €/conta/mês)
   antes de fechar.
5. **DGEG — a morada** no documento e no e-mail: confirma que é a que queres
   que fique no acordo.

---

## 6. O que NÃO consegui verificar (e porquê)

- O formulário de registo do InvoiceXpress (`web.invoicexpress.com/signup`):
  é JavaScript, o texto não vem no HTML. Visto depois num browser real: o
  primeiro ecrã pede país, e-mail e a aceitação dos termos — **sem cartão**.
  O que vem depois do «Continuar» não se viu (não se cria conta nenhuma).
- Os ecrãs de pagamento do InvoiceXpress e o «plano grátis» que a FAQ deles
  menciona: só se veem dentro de uma conta.
- `developers.invoicexpress.com`: não respondeu deste PC (erro SSL
  `TLSV1_ALERT_UNRECOGNIZED_NAME`, código 000). A documentação viva está em
  `docs.invoicexpress.com`.
- O endereço de e-mail comercial do InvoiceXpress: **já não é dúvida** — está
  nas duas páginas de preços, escondido pelo Cloudflare e decifrado:
  `comercial@invoicexpress.com`.
- Enable Banking: `/apply-now` deu 404 e não há página de preços — é por
  pedido. Não vi o formulário de criação de conta do painel (precisa de sessão).
- DGEG: o endereço do Web Service e o formato das chamadas só vêm no Manual,
  depois do deferimento. O robô de hoje usa a API pública do portal.

---

## Fontes (lidas a 2026-09-06)

| URL | HTTP | o que se tirou |
|---|---|---|
| https://precoscombustiveis.dgeg.gov.pt/apresentacao/ | 200 | processo «Partilha de Informação», proibição de uso comercial, e-mail, Manual e credenciais |
| `docs/loja/dgeg/minuta-partilha-informacao-em-dia.docx` (Anexo II) | — | Web Service com username/password da DGEG; janelas horárias |
| https://www.invoicexpress.com/precos | 302 → `/recursos/` | **já não é a página de preços** (reverificado à noite: `curl` e browser real dão a página «Recursos») |
| https://invoicexpress.com/planos-precos/ (a do menu, via `/planos-e-precos/`) | 200 | X3 3 € … X750 34 €/mês, utilizadores ilimitados, 30 dias grátis, AT desligada no trial, cartão em qualquer ciclo + Multibanco/MB WAY a partir de 6 meses, multi-conta por «Fale Connosco», e-mails escondidos pelo Cloudflare (decifrados) = `comercial@`, `suporte@`, `support@invoicexpress.com` |
| https://invoicexpress.com/planos-precos-old/ | 200 | título «Planos e Preços OLD»: XS/S/M/L, «Subscrição mensal indisponível», «Cartão de Crédito (através do Stripe)», «Plano XL (…) Multi-Conta»; botão «Enviar email» → `comercial@invoicexpress.com` (decifrado) |
| https://web.invoicexpress.com/signup (browser real) | 200 | primeiro ecrã: país, e-mail, termos, marketing, «Continuar» — sem cartão |
| https://www.portaldasfinancas.gov.pt/pt/consultaProgCertificadosM24.action | 200 | «Invoicexpress \| 1.0 \| INVOICEXPRESS, LDA \| 192 \| Certificado \| 2010-11-09» |
| https://invoicexpress.com/api-v2/getting-started/ | 200 | `api_key` na query string, `ACCOUNT_NAME.app.invoicexpress.com`, chave em `/users/api` |
| https://docs.invoicexpress.com/accounts | 200 | `accounts/create.json` (incl. `password`/`password_confirmation` obrigatórios), `create_already_user.json`, `get.json`, `at_communication.json` (enum `auto`/`manual`/`guides`/`portal_at`) e os campos |
| https://developers.invoicexpress.com/ | 000 | não respondeu (SSL) |
| https://enablebanking.com/ | 200 | só «Get started»/«Contact us»; sem preços |
| https://enablebanking.com/apply-now | 404 | — |
| https://enablebanking.com/cp/applications | 200 | o painel existe |
| https://enablebanking.com/docs/api/control-panel/ | 200 | registo da app, `.pem` gerado no browser e guardado em Transferências, Unrestricted vs Restricted, MFA; **não** diz se a chave se pode trocar depois |
| https://enablebanking.com/docs/api/linked-accounts/ | 200 | modo restrito = contas próprias, até haver contrato |
| https://enablebanking.com/docs/faq/ | 200 | preço por volume e mínimo mensal, contrato + KYB para produção pública, «are not checked» em modo restrito |
| https://enablebanking.com/docs/api/reference/ | 200 | JWT RS256, `kid`, `iss`/`aud`, 86400 s, `api.enablebanking.com` |
| https://em-dia-site.pages.dev/privacidade · /termos | 200 · 404 | há política de privacidade; não há termos |
| Base `tgdmgtmknbwhcqoxtjbs` (SELECT) | — | flags a falso, 2 crons, 3 segredos no Vault, 0 preços guardados, 1 corrida em seco |
| Gmail `boraappbora@gmail.com` (rascunhos) | — | rascunho para a DGEG existe, com `NIF [preencher]` |

---

## Correções da verificação (2026-09-06, noite — segundo agente, contexto limpo)

**Confirmado letra por letra, sem mexer:** `guardar_segredo(nome, valor,
descricao)` e `ler_segredo(nome)` na migração 0004 (e na base, `pg_proc` devolve
as duas com estes argumentos); `lerSegredo` em `_shared/segredos.ts` (env em
MAIÚSCULAS, depois RPC `ler_segredo`); `PlanoStore.permitida` em
`lib/stores/regras_store.dart` (trial → `true`; flag desconhecida → `true`);
as três flags na 0016 e na base (`free=false pro=false familia=false`); tabelas
e políticas `postos_leitura`/`precos_leitura` na 0026 (`for select to
authenticated`, `using` sobre `feature_flags`); o robô
(`/api/PrecoComb/PesquisarPostos`, `MINIMO_LINHAS = 5000`, `PEDACO = 500`,
`x-cron-secret` = `lerSegredo('cron_secret')`, `rpc('is_admin')`, corrida «em
seco» quando a flag está a falso); `precoDoUltimoAbastecimento` em
`vale_a_pena.dart`; `_EmBreve` em `carro_screen.dart`; nenhum Dart lê
`precos_combustivel`/`postos_combustivel`; `grep -ril` de `invoicexpress`,
`enablebanking` e `BancoFornecedor` a zero em `lib/` e `supabase/`;
`ligacoes_estado.recibo_emitir` na 0025; `ler-extrato` lê extratos por foto;
`avisos-cron` filtra por `Europe/Lisbon`; na base os dois crons
(`5 * * * *`, `20 7 * * 1`), os três segredos do Vault, 0 postos, 0 preços,
1 corrida com `gravou=false`; o `.docx` (Anexo II: username/password, janelas
03:00–04:00 / 13:00–14:00 / 20:00–21:00; «prazo de um ano, renovando-se
automática e sucessivamente»; denúncia «com uma antecedência mínima de quinze
dias»); o rascunho do Gmail `r9185747425691357001` (para
`precoscombustiveis@dgeg.gov.pt`, assunto certo, «NIF [preencher]», morada
«Rua do Torreão 14, 6300-610 Guarda»); DGEG `/apresentacao/` (todas as
citações); Enable Banking (painel, contas ligadas, FAQ, referência da API:
RS256, `kid`, `iss`/`aud`, 86400 s, `GET /application`, `POST /auth`,
`POST /sessions`, `GET /accounts/{id}/transactions`; `/apply-now` 404);
`em-dia-site.pages.dev/privacidade` 200 e `/termos` 404;
`developers.invoicexpress.com` continua a dar `TLSV1_ALERT_UNRECOGNIZED_NAME`.

**Corrigido no texto:**
1. **D38 → D37** em cinco sítios. A D38 é «Quem tira as fotografias não corrige
   os defeitos»; a regra «sem chave não se escreve código» é a **D37** («O que
   não se pode provar não se escreve»).
2. **InvoiceXpress, preços:** `invoicexpress.com/precos` dá hoje **302 →
   `/recursos/`**. A tabela XS/S/M/L, o «Stripe», o «Subscrição mensal
   indisponível» e o «XS só anual, 72 €» vinham da página
   **`/planos-precos-old/`** («Planos e Preços OLD»). A página do menu
   (`/planos-precos/`) tem **X3 3 € … X750 34 €/mês**, utilizadores ilimitados
   e renovação mensal — os números da D19 **estão certos**, e não «já não são
   os do site». Secção 2, resumo (§4), «PARA O DANILO» (§5) e Fontes refeitos.
3. **InvoiceXpress, cartão no trial:** deixou de ser dedução. Visto num browser
   real: o primeiro ecrã do `signup` pede país, e-mail e termos — sem cartão.
   Os ecrãs seguintes não se viram (não se criou conta).
4. **InvoiceXpress, pagamento:** «Cartão de Crédito para todo o tipo de
   renovações (mensais, semestrais, anuais ou bienais) e Multibanco e MB WAY
   para renovações a partir de 6 meses» — sem «Stripe» na página do menu. No
   fim do trial a conta fica «suspensa até efetuar um pagamento **ou mudar para
   o plano grátis**» (plano grátis que não está na tabela — POR CONFIRMAR).
5. **InvoiceXpress, `create.json`:** faltavam `password` e
   `password_confirmation` (obrigatórios); `terms` é enum `"1"`/`"0"`;
   `tax_country` é enum `"1"`/`"2"`/`"3"`; `create_already_user.json` responde
   200. `communication_type` (`auto`/`manual`/`guides`/`portal_at`) confirmado.
6. **InvoiceXpress, e-mail comercial:** `comercial@invoicexpress.com`
   **existe** — está escondido pelo Cloudflare nas duas páginas de preços (é o
   `href` do botão «Enviar email» da página OLD). Deixa de ser POR CONFIRMAR.
7. **Certificado da AT:** n.º **192** («Invoicexpress | 1.0 | INVOICEXPRESS,
   LDA | 192 | Certificado | 2010-11-09»; rodapé do site igual). Já não é
   passo do Danilo.
8. **Enable Banking:** a frase «are not checked» é da **FAQ**, não do painel
   (atribuição corrigida); «descarrega uma vez — se se perder, regista-se outra
   aplicação» **não está na documentação** (a secção «Editing an Application»
   não fala da chave) — ficou como precaução e POR CONFIRMAR no painel;
   acrescentado que a chave pode ser gerada fora (OpenSSL), entregando só a
   pública.
9. **Cron da DGEG:** a `avisos-cron` corre **de hora a hora** (`5 * * * *`) e
   filtra pela hora de Lisboa — não «às duas horas UTC possíveis». O molde
   proposto (`20 2,3 * * *` + verificação em `Europe/Lisbon`) mantém-se; só a
   descrição estava errada.
10. **Nota na D19:** diz «o código e as chamadas estão escritos e ensaiados» —
    não estão (grep a zero). A linha da tabela da secção 2 avisa; a D19 em si
    não foi tocada (é do `DECISOES.md`, fora desta ordem).
