# O que está pronto e desligado — e como se liga

> Escrito a 2026-09-06, no Bloco 5 da missão LOOP TOTAL.
> A regra que criou esta página: *"gastar dinheiro acima de 10 €/mês é a única
> coisa que não decido — isso implemento atrás de uma opção desligada e deixo
> pronto a ligar."* O mesmo vale para tudo o que precisa da assinatura, do
> cartão ou do login pessoal do Danilo.

Cada linha desta página é código **escrito e provado** que só não está a
funcionar porque falta um passo que só uma pessoa pode dar. Nenhuma é um plano:
todas têm o interruptor identificado e a prova de que funcionam sem ele.

---

## 1. Caixa de correio das faturas — falta ligar o subdomínio

**O que faz:** cada pessoa ganha um endereço `<nome>-<8 letras>@contas.<domínio>`
e reencaminha para lá as faturas que já lhe chegam por e-mail. Elas aparecem na
app, e daqui faz-se a conta com um toque.

**Interruptor:** a linha `caixa_faturas_dominio` em `regras_legais`, vazia.

**Está provado:** um PDF de 897 bytes entrou pela porta do Worker e ficou com
897 bytes no balde privado; caixa desconhecida dá 404; segredo errado dá 401;
outro utilizador vê zero linhas e zero ficheiros
(`docs/provas/caixa-de-correio-das-faturas-2026-09-06.md`).

**Porque não liguei:** o Email Routing da Cloudflare precisa de uma zona e mexe
nos registos MX dela. Na conta há `boraguarda.com`, `guardafcsad.com` e
`jaiagarwala.com` — nenhum é do Em Dia, e o primeiro é o que manda os códigos de
entrada da app. Pôr-lhe um catch-all arriscava o login de toda a gente.

**Decisão do Danilo (2026-09-07): não se compra domínio.** O Em Dia vive em
subdomínios de `boraguarda.com`: site `emdia.boraguarda.com`, app
`app.emdia.boraguarda.com`, painel `admin.emdia.boraguarda.com`, remetente
`emdia@boraguarda.com`. (A 6 de setembro tinha-se visto que `em-dia.pt` estava
livre e `emdia.pt` era de outra empresa; comprar deixou de ser plano.)

**O que falta:** a caixa das faturas fica num subdomínio dessa mesma zona — o
nome exacto (ex.: `contas.emdia.boraguarda.com`) está **por confirmar** pelo
Danilo, e é preciso confirmar que o Email Routing da Cloudflare aceita esse
subdomínio nesta conta. Liga-se só a esse subdomínio, nunca com catch-all na
raiz de `boraguarda.com`, para não tocar nos códigos de entrada. Os quatro
passos estão em `cloudflare/correio-faturas/LEIA-ME.md` e o último é uma linha
de SQL (`caixa_faturas_dominio`). A app acende sozinha, sem publicar versão nova.

---

## 2. Preços de combustível da DGEG — falta a autorização escrita

**O que faz:** os preços de todos os postos do continente, para o "vale a pena
esta corrida" saber quanto custa o combustível sem a pessoa escrever nada.

**Interruptor:** `feature_flags.precos_combustivel`, a falso.

**Está provado, hoje:** o robô correu **em seco** e viu **14.178 linhas de preço
em 3.131 postos, em 1,3 segundos** — e guardou **zero**. Está no registo:
`precos_combustivel_sync` com `gravou = false`, e as tabelas `postos_combustivel`
e `precos_combustivel` com 0 linhas.

**Porque não liguei:** não é um problema técnico. O portal da DGEG diz, com
todas as letras, que *"é proibida a sua utilização para fins comerciais"*, e o
Em Dia cobra 3,49 €/mês. Guardar aqueles preços para os vender dentro de uma
app paga é usar comercialmente uma coisa que ainda não é nossa.

**O que falta (Danilo):** o processo formal chama-se **"Partilha de
Informação"**. Há uma minuta em Word na página da DGEG que tem de ser assinada
e enviada por e-mail. **É uma assinatura tua** — não custa dinheiro, mas é um
compromisso da empresa e nenhum agente a pode fazer.

**Como se liga, depois:** pôr `free`/`pro`/`familia` a verdadeiro em
`feature_flags` na chave `precos_combustivel`. O robô passa a gravar na corrida
seguinte, sem publicar app nenhuma.

**Enquanto isso:** o "vale a pena esta corrida" usa o preço do último
abastecimento da própria pessoa, ou um que ela escreva. Funciona, e é dela.

---

## 3. Emitir fatura-recibo pela app — falta a conta e o contacto comercial

**O que faz:** a pessoa faz o recibo verde dentro do Em Dia, sem entrar no
Portal das Finanças.

**Interruptor:** `feature_flags.faturacao_certificada`, a falso.

**O que a investigação decidiu:** **InvoiceXpress, na modalidade Multiconta.** É
o único dos três (InvoiceXpress, Moloni, Vendus) em que a nossa plataforma cria
a conta do utilizador por API (`POST /api/accounts/create.json` devolve logo a
`api_key` dessa conta) e liga a comunicação à AT também por API
(`POST /api/v3/accounts/at_communication.json`). O exemplo que eles próprios dão
é a Cabify — motoristas a faturar cada um com o seu NIF debaixo de uma
subscrição da plataforma. É literalmente o nosso caso.

**Porque não escrevi o código:** sem uma conta e uma chave, qualquer função que
escrevesse era código que nunca correu. E há uma armadilha confirmada: **durante
o trial gratuito de 30 dias a comunicação à AT está desligada**, por isso nem
com conta grátis se prova o circuito até ao fim.

**O que falta (Danilo), por ordem:**
1. Abrir uma conta InvoiceXpress paga (X3 a 3 €/mês ou X10 a 9 €/mês) —
   **pagamento com cartão, é teu**.
2. Enviar um e-mail a `comercial@invoicexpress.com` a pedir proposta Multiconta.
   A modalidade **não é auto-serviço**.
3. Confirmar o número de certificado da AT na lista oficial
   (`portaldasfinancas.gov.pt/pt/consultaProgCertificadosM24.action`).

**E há um passo que é de cada utilizador, não nosso:** por exigência da AT, cada
pessoa tem de criar um sub-utilizador no Portal das Finanças com a operação WFA
activada. Nenhum dos três fornecedores evita isto. **Decisão tua, quando lá
chegarmos:** guardamos a senha desse sub-utilizador (cifrada, RLS apertada,
nunca em registos) ou mandamo-la uma vez ao InvoiceXpress e deitamo-la fora?
A segunda é mais segura e obriga a pessoa a repetir se algo falhar.

---

## 4. Ler os movimentos do banco — falta a conta e o KYB

**O que faz:** a app vê o dinheiro a entrar e a sair sem a pessoa escrever nada.

**Interruptor:** `feature_flags.banco_movimentos`, a falso.

**O que a investigação decidiu:** **não sermos TPP.** Fase 0 (já, grátis, sem
contrato): **Enable Banking em Restricted Production**, com as contas do próprio
Danilo ligadas — dá bancos portugueses a sério (CGD, Millennium BCP, Santander
Totta, novobanco, BPI, Montepio), JSON real e descrições reais de movimentos
Uber e Bolt, a zero euros. Fase 1, quando houver utilizadores: comparar com o
Partner Program da open-banking.io (3 € por conta ligada por mês, preço público)
antes de fechar.

**Regra de arquitetura que fica escrita desde já:** o adaptador vive nas Edge
Functions, **nunca no Flutter**. A chave privada `.pem` não pode tocar no
telemóvel — um APK é um ficheiro zip que qualquer pessoa abre.

**O que falta (Danilo):**
1. Criar conta na Enable Banking e registar a aplicação. O browser descarrega a
   chave privada `.pem` **uma única vez** — tem de ir para
   `C:\BoraLocal\_segredos\em-dia\`, nunca para o repositório.
2. Completar o KYB (dados da empresa, provavelmente documentos).
3. Ligar as tuas próprias contas bancárias: **exige login no banco e a
   confirmação no telemóvel.** Nenhum agente entra em bancos, e não deve.

---

## O que já ficou ligado, para não haver dúvida

| Peça | Estado |
|---|---|
| Endereços do Estado (14, Finanças + Segurança Social) | **na base, a funcionar** |
| Vigia semanal desses endereços | **a correr**, segundas às 07:20 UTC |
| Centros de inspeção do IMT (223) | **na base, leitura pública** |
| Avisos das contas de casa | **a correr**, de hora a hora |

---

## Uma pergunta que fica para ti

No ecrã-guia da Segurança Social, queres que a app diga os prazos (último dia
de janeiro, abril, julho e outubro) **e a coima de 50 a 250 €**? Assusta, mas é
o que faz a pessoa carregar no botão. Eu meto — o tom da marca é teu.
