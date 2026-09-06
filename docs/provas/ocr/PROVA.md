# Prova — ler faturas e talões por foto (2026-09-06, 15h45 Lisboa)

O Danilo acrescentou à missão: *"Ao fotografar, a IA lê e preenche sozinha: nome
da loja ou entidade, data, valor total, e quando existirem, NIF, entidade e
referência Multibanco. Não leias produto a produto. (…) Prova com cinco fotos
reais de tipos diferentes e guarda as saídas em docs/provas/ocr."*

## Primeiro, a parte honesta

**Estas cinco imagens não são faturas reais do Danilo.** Procurei no computador
todo (Transferências, Ambiente de Trabalho, Documentos, Imagens) e não há lá
faturas nem talões — só ficheiros do BoraStudio com "luz" no nome.

Por isso fiz cinco documentos com o desenho e os campos das faturas portuguesas
a sério, e "fotografei-os": rodados entre meio grau e dois graus, com sombra
oblíqua, ruído de sensor e compressão a 72% — que é como as fotos chegam de um
telemóvel dentro de um carro. O gerador está em `tool/provas/documentos_para_ler.py`
e é repetível (semente fixa).

**Falta a prova com fotos verdadeiras.** Está pedida em `docs/PENDENTE-DANILO.md`:
bastam cinco fotografias tiradas com o telemóvel — uma conta da luz ou da água
com referência Multibanco, uma conta por débito direto, um talão de combustível,
um talão de compras com o contribuinte, e uma conta qualquer sem contribuinte.

## Os cinco documentos

| # | Documento | O que tem de difícil |
|---|---|---|
| 1 | Fatura da luz | entidade e referência Multibanco em caixa própria, contribuinte do cliente |
| 2 | Fatura do telemóvel | débito direto — **não tem** referência, e não pode inventar uma |
| 3 | Talão de combustível | litros e preço por litro, letras monoespaçadas de impressora térmica |
| 4 | Talão de supermercado | seis artigos que **não** deve ler, só o total e o contribuinte |
| 5 | Fatura da água | referência **sem** contribuinte do cliente — não conta para o IRS |

## O que saiu

Cada imagem foi enviada à Edge Function `ler-documento`, publicada e ativa, com
uma sessão de utilizador a sério (código de e-mail 577219, às 14:35 UTC).

**38 campos comparados, 38 certos.**

| Documento | HTTP | Entidade | Data | Total | Ent./Ref. MB | Litros | €/L | IRS | Confiança |
|---|---|---|---|---|---|---|---|---|---|
| 1 luz | 200 | EDP COMERCIAL | 2026-08-14 | 60,90 € | 10963 / 417903258 | — | — | sim | 1,00 |
| 2 telemóvel | 200 | MEO | 2026-09-01 | 58,00 € | nenhuma | — | — | sim | 1,00 |
| 3 combustível | 200 | GALP ENERGIA | 2026-09-05 | 65,58 € | — | 41,27 | 1,589 | sim | 0,95 |
| 4 supermercado | 200 | CONTINENTE | 2026-09-03 | 21,02 € | — | — | — | sim | 1,00 |
| 5 água | 200 | ÁGUAS DA GUARDA, E.M. | 2026-08-28 | 18,01 € | 21344 / 902118447 | — | — | **não** | 1,00 |

O documento 2 é o mais importante da lista: **não inventou referência nenhuma**,
que era o risco. O 5 também: leu a referência mas percebeu que não havia
contribuinte do cliente, e por isso `conta_para_irs` ficou a falso — que é a
diferença entre "gastei" e "gastei e vou receber parte de volta".

Nenhum leu produto a produto. O talão do Continente tem seis artigos e a resposta
não traz nenhum: só o total, a data e o contribuinte.

As leituras ficaram guardadas na tabela `leituras_ocr`, cinco linhas, lidas de
volta da base de dados. As respostas completas estão em `lido.json`, os valores
que eu esperava em `esperado.json`.

## Dois defeitos que só apareceram por correr isto a sério

**1. A roda de modelos parava no 503.** O quarto documento levou, tal e qual:

```
HTTP 503: {"error":{"code":503,"message":"This model is currently experiencing
high demand. Spikes in demand are usually temporary. Please try again later.",
"status":"UNAVAILABLE"}}
```

A roda só trocava de modelo em 429 e 404, por isso a pessoa levava um erro
quando havia mais oito modelos livres à espera. Corrigido em
`_shared/gemini.ts`: passa ao seguinte também em 503 e 500. À segunda tentativa
o mesmo documento leu tudo certo, em 3,5 segundos.

**2. `Number(null)` é zero.** Os campos `litros` e `preco_litro` ficavam gravados
a **0,00** nos documentos que não são de combustível — e "zero litros" lê-se como
uma medição a sério, não como "isto não tem litros". Corrigido: agora vai a nulo.

## Tempos

Entre 3,4 e 4,7 segundos por documento, do telemóvel à resposta. É o tempo de
escrever o valor à mão — a vantagem não é a velocidade, é não haver enganos a
copiar uma referência de nove números.
