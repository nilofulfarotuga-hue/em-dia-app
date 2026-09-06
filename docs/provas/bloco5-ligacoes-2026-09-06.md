# Prova — Bloco 5: as ligações ao mundo lá fora (2026-09-06, 18h)

## 1. Endereços do Estado — 14 na base, e um vigia que não mente

Catorze endereços em `ligacoes_estado`: onze das Finanças (fazer recibo, ver
recibos, o que devo, entregar IRS, despesas da atividade, pagamento por conta,
e-fatura ver e registar, atividade, IUC ver e pagar) e três da Segurança Social.

**Os dois lados do Estado não são iguais, e a app trata-os de maneira
diferente.** As Finanças têm endereço próprio por serviço e reencaminham para o
login guardando o caminho, por isso o botão leva mesmo à página certa. A
Segurança Social **não tem endereço estável** para dentro: a área com sessão é
`/ptss/pssd/home?dswid=<número gerado por sessão>` e o login tem reCAPTCHA. Por
isso há um só botão, o da porta, e a app mostra o caminho em passos antes de o
abrir. **Não se promete que o botão abre o formulário — não abre.**

### O vigia, e porque é que não é um ping

Provado ao vivo, hoje, com o redirecionamento desligado:

```
302 | https://irs.portaldasfinancas.gov.pt/recibos/portal/xxxx-nao-existe-zzz
      -> https://www.acesso.gov.pt/v2/loginForm;sireinter_JSessionID=...
302 | https://irs.portaldasfinancas.gov.pt/recibos/portal/emitir
      -> https://www.acesso.gov.pt/v2/loginForm;sireinter_JSessionID=...
200 | https://www.seg-social.pt/ptss/pssd/menu/xpto-nao-existe-zzz999
```

**O caminho inventado responde exactamente como o verdadeiro.** Um vigia que
olhe para o código HTTP fica verde para sempre num link morto — é o mesmo falso
positivo do robô do Bora que devolveu 200 durante oito dias a falhar por dentro.

O que se fez em vez disso: descarregar o mapa do site da AT (HTML servido pelo
servidor) e ver se os nossos endereços continuam lá.

```
POST /functions/v1/vigia-ligacoes   (pelo cron, com o segredo do Vault)
200 {"autenticado":"cron","mapa_bytes":515513,"mapa_ligacoes":1494,
     "verificadas":11,"em_falta":[],
     "nota":"Todos os endereços das Finanças continuam no mapa do site."}
```

**Teste anti-mentira.** Meti na tabela um endereço inventado — daqueles a que o
portal responde 302 na mesma — e corri outra vez:

```
200 {"verificadas":12,"em_falta":["PROVA_endereco_inventado"], …}
```

Apanhou. A linha de prova foi apagada a seguir.

**As duas travas de sanidade:** se o mapa vier com menos de 300 KB ou menos de
200 ligações, não se alarma nem se desliga nada — regista-se `saltado = true`.
Um vigia que grita quando a rede falha ensina toda a gente a ignorá-lo.

Agendado: `em-dia-vigia-ligacoes`, segundas às 07:20 UTC (jobid 2).

## 2. Centros de inspeção do IMT — 223 na base

A app diz "a tua inspeção é até 12/10". A pergunta a seguir é sempre "onde?".

Não há API, não há CSV, não há nada no dados.gov.pt. A única fonte é um PDF.
`tool/dados/centros_inspecao.py` descobre o link na página do IMT (o URL muda de
pasta a cada actualização), lê o PDF e normaliza as coordenadas.

```
223 centros | 219 com coordenadas | 4 sem | 18 distritos
Porto 43, Lisboa 35, Braga 19, Aveiro 17, Setúbal 17, Leiria 16, Coimbra 12,
Santarém 12, Faro 11, Viseu 8, Viana do Castelo 6, Évora 5, Beja 4,
Bragança 4, Castelo Branco 4, Guarda 4, Portalegre 3, Vila Real 3
```

**Três armadilhas apanhadas, com o número antes e depois:**

1. O "O" final de "PORTO 41°10'..." era lido como **Oeste** e punha o centro na
   latitude −41: mar aberto a sul de África. Obrigando a letra a estar sozinha:
   **163 → 218** centros com coordenadas.
2. O cabeçalho e o rodapé do PDF colavam-se ao fim da última linha de cada
   página, e comiam catorze coordenadas.
3. As quatro que ficam sem coordenada **não são bug nosso**: três têm latitude
   27 e 29 graus no próprio PDF do IMT (mar alto, ao pé da Madeira) e uma vem
   num formato ilegível. Ficam a NULL. Mandar alguém a um sítio errado é pior do
   que não dizer nada.

Leitura anónima, provada com a chave pública da app:

```
HTTP 200
258 BETOREL - GUARDA (SÃO MIGUEL DA GUARDA) | GUARDA | 40.5525 -7.247258
093 CIMA - GUARDA (GUARDA)                  | GUARDA | 40.536667 -7.243889
065 CIMA - SEIA                             | SEIA   | 40.427222 -7.712778
250 TORRES & FILHO - TRANCOSO (SANTA MARIA) | TRANCOSO | 40.766889 -7.357111
```

E escrita anónima recusada:

```
POST /rest/v1/centros_inspecao -> 401
{"code":"42501","message":"new row violates row-level security policy…"}
```

**Travão de queda:** abaixo de 180 centros o script recusa-se a escrever. Um
parser partido devolveria "OK" a perder metade do país.

## 3. Preços de combustível da DGEG — provado a funcionar, e desligado

```
POST /functions/v1/sync-precos-combustiveis
200 {"seco":true,"ligada":false,"linhas":14178,"postos":3131,"ms":1308,
     "nota":"Corrida em seco: … não guardou preço nenhum. Falta a autorização
             escrita da DGEG — o portal proíbe uso comercial sem ela."}
```

E a seguir, na base:

```
postos_guardados 0 | precos_guardados 0 | corridas 1 | ultima_gravou false
ultima_viu 14178
```

**Viu catorze mil cento e setenta e oito preços e guardou zero.** É esse o
ponto: o travão não é técnico, é legal. O portal diz que é proibido o uso
comercial, e o Em Dia cobra 3,49 €/mês. Falta uma assinatura do Danilo no
processo "Partilha de Informação" da DGEG — não custa dinheiro, mas é um
compromisso da empresa e nenhum agente o pode assumir.

Enquanto isso, o "vale a pena esta corrida" usa o preço do último abastecimento
da própria pessoa. Funciona, e é dela.

## 4. Faturação certificada e banco — ficam escritos, não ficam inventados

Estes dois **não têm código novo**, e isso é uma decisão, não um esquecimento:
sem uma conta e uma chave, qualquer função que escrevesse era código que nunca
correu — e um ficheiro que nunca correu não é trabalho feito, é dívida
disfarçada. O que ficou foi a decisão tomada, a razão, e a lista exacta do que
falta, em `docs/PARA-LIGAR.md`:

- **Fatura-recibo pela app:** InvoiceXpress Multiconta (é o único que cria a
  conta do utilizador por API e liga a comunicação à AT por API). Falta abrir
  conta paga e o contacto comercial. Armadilha confirmada: no trial de 30 dias
  a comunicação à AT está desligada, por isso nem com conta grátis se prova.
- **Movimentos do banco:** Enable Banking em Restricted Production, grátis e sem
  contrato, com as contas do próprio Danilo. Falta criar a conta, o KYB, e ligar
  as contas — que exige login no banco e confirmação no telemóvel. **Nenhum
  agente entra em bancos, e não deve.**

## Onde ficou

- `supabase/migrations/20260906_0024_centros_de_inspecao.sql` (aplicada)
- `supabase/migrations/20260906_0025_ligacoes_do_estado.sql` (aplicada)
- `supabase/migrations/20260906_0026_precos_de_combustivel.sql` (aplicada)
- `supabase/functions/vigia-ligacoes/` (ACTIVE) e `sync-precos-combustiveis/` (ACTIVE)
- `tool/dados/centros_inspecao.py` e `docs/dados/centros_inspecao.json`
- `docs/PARA-LIGAR.md` — os quatro interruptores e o que falta em cada um
