# Prova — as funções do servidor depois de mexer nas permissões (2026-09-06, noite)

A migração `20260906_0009` tirou a `anon` e ao `public` a permissão de executar
`plano_efetivo`, `feature_permitida` e `feature_limite`. Duas funções do servidor
usam essas RPC (`avisos-cron`), por isso não bastava confiar: fui verificar.

## As que correram

**`calcular-obrigacoes`** (com o token de um utilizador normal):

```
POST /functions/v1/calcular-obrigacoes
HTTP 200
{"geradas":17,"novas":0,"atualizadas":17,"apagadas":0,"hoje":"2026-09-06",
 "itens":[{"tipo":"irs_pagamento_conta","descricao":"Pagamento por conta de IRS (setembro).",
           "data_limite":"2026-09-20","aviso_em":"2026-09-18","valor_estimado":412.26, …}]}
```

**`avisos-cron`** (com o segredo do cron). Primeiro respeitou a hora, como deve:

```
HTTP 200  {"saltado":true,"hora_lisboa":13,"data_lisboa":"2026-09-06","hora_push":9}
```

Depois, forçado, correu o trabalho todo — e é aqui que se vê que as RPC
continuam a funcionar pela service role:

```
HTTP 200
{"hora_lisboa":13,"forcado":true,"autenticado":"cron","fcm_configurado":false,
 "utilizadores":7,"eventos_criados":0,"enviados":0,"sem_fcm":0,"sem_token":0,
 "limite_plano":0,"erros":0,"passadas_marcadas":0}
```

Sete utilizadores processados, **zero erros**. Nada partiu.

**`suporte-auto`** (token de utilizador):

```
HTTP 200
{"ticket_id":"18eca49f-14f8-43ca-ae56-cc879d21232a",
 "resposta":"Olá! O suporte da app \"Em Dia\" está a funcionar perfeitamente. …
             Próximo passo: pagar o pagamento por conta de IRS até 2026-09-20
             (irs_pagamentos_conta_datas). Informação geral, não substitui contabilista.",
 "escalado":false,"estado":"aberto"}
```

`validar-compra-play` **não foi chamada** — é zona de dinheiro (regra 12 do
`CLAUDE.md`).

## A que falhou, e porquê isso valeu a pena

**`ia-responder`** devolveu `HTTP 502`:

```
{"erro":"gemini_erro",
 "detalhe":"HTTP 503: {\"error\":{\"code\":503,
    \"message\":\"This model is currently experiencing high demand. Spikes in demand
                 are usually temporary. Please try again later.\",
    \"status\":\"UNAVAILABLE\"}}",
 "mensagem":"O assistente devolveu um erro. Tenta outra vez."}
```

Não é regressão da migração — é a Gemini a dizer que **aquele** modelo está com
muita procura. Mas destapou um buraco a sério: em
`supabase/functions/_shared/gemini.ts` existe uma roda de 8 modelos, e ela só
trocava de modelo em **429**. Num **503** parava logo e a pessoa levava um erro,
quando o modelo seguinte responderia bem — e prova-se que responderia: o
`suporte-auto`, que usa exactamente o mesmo cliente, respondeu no mesmo minuto.

Arranjado: a roda passa a trocar de modelo em **429, 503, 500** e no 404 de
modelo que já não existe (em nenhum destes a resposta foi gerada, por isso não
se gasta quota), e quando a roda toda falha a app diz *"está com muitos pedidos,
tenta daqui a um minuto"* em vez de *"devolveu um erro"*.

## O arranjo ainda NÃO está no servidor — e a razão

O código está commitado, mas publicar as funções não foi feito esta noite:

- a CLI do Supabase está instalada (**2.116.0**) mas **não há token de acesso**
  neste PC (`~/.supabase/` só tem telemetria; `SUPABASE_ACCESS_TOKEN` não existe
  no ambiente; nenhum `sbp_…` guardado);
- pelo MCP dava, mas obrigava a copiar à mão ~65 KB de TypeScript de produção
  (`index.ts` + `cors.ts` + `segredos.ts` + `contexto_ia.ts` + `gemini.ts`, vezes
  três funções). Um carácter trocado parte o assistente de uma app que já está no
  teste interno. Não se faz isso sozinho de madrugada.

O que isto custa até lá: de vez em quando o assistente responde *"devolveu um
erro. Tenta outra vez"* num pico da Gemini, e a pessoa repete. Não se perde nada
nem se abre nada.

**Fecha-se com um comando**, assim que houver token (está em PENDENTE-DANILO):

```bash
export SUPABASE_ACCESS_TOKEN=$(cat C:/BoraLocal/_segredos/em-dia/supabase-access-token.txt)
for f in ia-responder suporte-auto ler-extrato; do
  supabase functions deploy "$f" --project-ref tgdmgtmknbwhcqoxtjbs
done
```

E prova-se com uma pergunta ao assistente: tem de responder 200 mesmo quando o
primeiro modelo da roda estiver em baixo.
