# Prova — a caixa de correio das faturas (2026-09-06, 17h30)

Ponto 14 do Bloco 3, decisão **D24**. A app **não** pede a palavra-passe do
e-mail a ninguém e **não** liga à API do Gmail. Cada pessoa tem um endereço só
dela e reencaminha para lá as faturas que já lhe chegam.

## As peças, e onde estão

| Peça | Onde | Estado |
|---|---|---|
| `faturas_recebidas` + balde privado `faturas` | migração 0023 | aplicada |
| `minha_caixa_de_faturas()` | migração 0023 (+0023b) | aplicada |
| Edge Function `receber-fatura` | Supabase | ACTIVE, versão 1 |
| Segredo `correio_secret` | Vault | criado |
| Worker de e-mail | `cloudflare/correio-faturas/` | escrito, **por publicar** |
| Ecrã, store e modelo | `lib/screens/vida/caixa_faturas.dart` | feito |
| Interruptor `caixa_faturas_dominio` | `regras_legais` | **vazio = desligado** |

## O endereço nasce sozinho, e o interruptor manda

```
select * from minha_caixa_de_faturas();   -- com a sessão do utilizador de teste
conta-l45je3gx@ainda-sem-dominio | ligada = false
```

As oito letras ao acaso são a fechadura: sem elas, um estranho adivinhava a
caixa de outra pessoa a partir do nome. E `ligada = false` porque a linha
`caixa_faturas_dominio` está vazia — a app diz *"ainda não está pronta"* em vez
de mostrar um endereço que não recebe nada.

## Uma fatura a sério a entrar

Fiz um PDF de 897 bytes com o texto de uma fatura da EDP e mandei-o pela porta
por onde o Worker vai mandar, com o segredo do Vault:

```
POST /functions/v1/receber-fatura
200 {"ok":true,"fatura_id":"d7650eda-…","estado":"nova","anexo":true,"erro":null}
```

E do outro lado, lido de volta da base:

```
remetente        faturas@edp.pt
assunto          A sua fatura de eletricidade de agosto
estado           nova
anexo_nome       fatura-edp-agosto.pdf
anexo_bytes      897
anexo_caminho    500f99a2-…/73c15e3c-….pdf
ficheiro_no_balde  true
bytes_no_balde     897        <- os mesmos 897 que entraram
tipo_no_balde      application/pdf
```

## As portas que têm de estar fechadas, e estão

| O que tentei | Resposta |
|---|---|
| Caixa que não existe (`conta-inventada@…`) | **404** `{"erro":"caixa_desconhecida"}` |
| Segredo errado no cabeçalho | **401** `{"erro":"nao_autorizado"}` |
| E-mail sem anexo nenhum | 200, `estado: "falhou"`, e a frase *"O e-mail veio sem anexo. Reencaminha o original, com a fatura agarrada."* |

O 404 não é um pormenor: é ele que faz o Worker **devolver** o e-mail a quem o
mandou. Aceitar em silêncio um e-mail que ninguém vai ler é mentir a quem o
enviou.

## E as faturas de um não se veem do outro

Com a sessão de outro utilizador (`b05a7458…`), a falar direto com a base:

```
faturas que o intruso vê ....... 0
ficheiros que o intruso vê ..... 0
faturas que o dono vê .......... 2
ficheiros que o dono vê ........ 1
```

E nem o próprio dono consegue escrever na sua caixa a partir da app:

```
insert into faturas_recebidas … -> recusado: new row violates row-level
security policy for table "faturas_recebidas" (42501)
```

É de propósito: **só o servidor põe faturas aqui.** Sem política de INSERT, o
RLS recusa a toda a gente menos ao service role.

## O Worker, testado sem instalar nada

As peças que não precisam de rede vivem à parte (`src/pecas.js`) e testam-se com
`node teste.mjs`:

```
escolherAnexo
  ok   escolhe o PDF
  ok   salta a assinatura e apanha o PDF a seguir
  ok   só um, mesmo com dois bons
  ok   sem anexos devolve null
  ok   sem lista nenhuma devolve null
  ok   anexo vazio nao serve
  ok   maiusculas no mime tambem servem
  ok   sem nome fica "fatura"
  ok   maior que 10 MB nao passa
paraBase64
  ok   "%PDF-1.4" da JVBERi0xLjQ=
  ok   aguenta mais de 32k de uma vez (sem rebentar a pilha)

11 passaram, 0 falharam
```

## O que NÃO ficou ligado, e porquê

**Falta o domínio, e isso é dinheiro do Danilo.** O Email Routing da Cloudflare
precisa de uma zona e mexe nos registos MX dela. Na conta há três domínios:
`boraguarda.com`, `guardafcsad.com` e `jaiagarwala.com` — nenhum é do Em Dia, e
o primeiro é o que manda os códigos de entrada da app. Pôr-lhe um catch-all era
arriscar o login de toda a gente por causa de uma funcionalidade nova. Não se
faz, e não fiz.

Os quatro passos para ligar, no dia em que o domínio existir, estão escritos em
`cloudflare/correio-faturas/LEIA-ME.md`. O último é uma linha de SQL — a app
acende sozinha, sem publicar versão nenhuma.

## Uma escolha que registo, porque custa dinheiro a quem usa

**A leitura da fatura não é automática.** O servidor guarda o PDF e mais nada; é
a pessoa que carrega em *"Fazer conta com esta"*. A leitura por IA tem limite de
5 por mês no plano grátis, e gastá-la sem ninguém pedir era roubar-lhe as
leituras — e pagar a conta da Gemini por documentos que talvez ninguém queira.

## O que ficou na base, e é honesto dizê-lo

A fatura da EDP dos 897 bytes **ficou** na conta de teste
(`boraappbora@gmail.com`), de propósito: é o que dá conteúdo ao ecrã quando o
Danilo o abrir. O e-mail sem anexo foi apagado. Nenhum utilizador novo vê nada
disto — as duas linhas são só desta conta, e o RLS acima prova-o.
