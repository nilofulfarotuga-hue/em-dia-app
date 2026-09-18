# BLOCO 8 — Testes de ponta a ponta e provas (2026-09-18)

> Missão `em-dia-tudo-2026-09-17`. Ordem: «testes de integração Flutter a abrir TODOS os ecrãs nos 4 caminhos
> do onboarding; prova no emulador Android do PC (AVD `emdia`) com gravação; na web, Playwright a percorrer tudo
> com semântica ligada; correr como o Danilo com a conta de teste boraappbora+teste, deixando a conta dele intocada».

## 1. O percurso por todos os ecrãs (Flutter) — 78 ecrãs/estados, 6 testes

`test/integracao/percurso_todos_os_ecras.dart` (corpo) + `test/integracao/todos_os_ecras_test.dart` (VM) +
`integration_test/todos_os_ecras_test.dart` (aparelho). Sem servidor, com as stores do exemplo e das fotos (D72).

- **Os 4 caminhos do onboarding, com toques a sério** («Trabalhas como?» → recibos verdes / contrato / os dois /
  empresa): cada pergunta é um ecrã visto, as respostas são as do Danilo no caminho 1 (TVDE, janeiro de 2024,
  não faturou mais de 15.000 €, sem carro, 1.200 €/mês) e chega-se ao «Entrar na app» nos quatro.
- **A app inteira pelo exemplo (a Maria):** painel + palavras difíceis; recibos (calculadora com valor, cartões da
  SS e do IRS); dinheiro (entra, nova entrada, sai, nova saída, caixa das faturas, sobra, importar extrato,
  recorrentes); agenda (lista, detalhe de uma obrigação, nova obrigação); carro (+ palavras difíceis); Mais
  (vale a pena, fala, cofre, prova, radar, reforma, guias + um guia aberto, pergunta, ajuda, plano, definições).
- **O que a Maria não tem:** recibos de contrato (+ recibo de vencimento, desemprego, horas extra), recibos de
  empresa, o ecrã de entrada, e as 9 secções do painel admin.

### Prova na VM (saída literal, 2026-09-18 22:1x)

```
$ flutter test test/integracao -r compact
ECRAS_VISTOS=78: onboarding/boas-vindas | onboarding/trabalhas-como | onboarding/recibos/o-que-fazes |
onboarding/recibos/quando-abriste | onboarding/recibos/iva-15k | onboarding/recibos/tens-carro |
onboarding/recibos/quanto-ganhas | onboarding/recibos/fim | onboarding/boas-vindas | onboarding/trabalhas-como |
onboarding/contrato/salario | onboarding/contrato/nascimento | onboarding/contrato/tens-carro |
onboarding/contrato/fim | onboarding/boas-vindas | onboarding/trabalhas-como | onboarding/ambos/o-que-fazes |
onboarding/ambos/quando-abriste | onboarding/ambos/iva-15k | onboarding/ambos/salario |
onboarding/ambos/nascimento | onboarding/ambos/tens-carro | onboarding/ambos/quanto-ganhas | onboarding/ambos/fim |
onboarding/boas-vindas | onboarding/trabalhas-como | onboarding/empresa/tipo | onboarding/empresa/iva-periodo |
onboarding/empresa/tens-carro | onboarding/empresa/contabilista | onboarding/empresa/fim | painel |
painel/palavras-dificeis | recibos | recibos/calculadora-com-valor | recibos/seguranca-social | recibos/irs |
dinheiro/entra | dinheiro/nova-entrada | dinheiro/sai | dinheiro/nova-saida | dinheiro/caixa-das-faturas |
dinheiro/sobra | dinheiro/importar-extrato | dinheiro/recorrentes | agenda | agenda/detalhe-obrigacao |
agenda/nova-obrigacao | carro | carro/palavras-dificeis | mais | mais/vale_a_pena | mais/fala | mais/cofre |
mais/prova | mais/radar | mais/reforma | mais/guias | mais/guias/detalhe | mais/ia | mais/ajuda | mais/plano |
mais/definicoes | recibos/contrato | recibos/contrato/recibo_vencimento | recibos/contrato/desemprego |
recibos/contrato/horas_extra | recibos/empresa | entrada | admin/seccao-0 … admin/seccao-8
00:13 +6: All tests passed!
```

No CI: `olho_golden.yml` ganhou o passo «Percurso por todos os ecrãs (test/integracao)».

### Prova no emulador (AVD `emdia`, Pixel 6 1080×2400, Android 14, gravação dentro do aparelho)

```
$ flutter test integration_test/todos_os_ecras_test.dart -d emulator-5554 --dart-define-from-file=.dart_defines   (7.ª corrida, 23:28)
02:32 +6: All tests passed!   ← os 6 testes; no aparelho o painel admin fica de fora de propósito (ADMIN_FORA: é de computador, 1280×800)
```
Gravação dentro do aparelho (`screenrecord`): a corrida de 23:14–23:20 ficou gravada e os fotogramas mostram o
onboarding (O que fazes? / Quanto ganhas / Em que ano nasceste? / Quando abriste atividade?), o exemplo (recibos,
caixa das faturas, agenda, Mais, guias) e a entrada — `provas/em-dia-tudo-2026-09-17/emulador/` (folha de
fotogramas). A corrida verde final (23:28) não ficou gravada: o laço de gravação morreu ao ser reiniciado (um `pkill`
apanhou o próprio laço) — cicatriz registada; a prova de que os 6 passam no aparelho é o log acima.

**Sessão duplicada:** enquanto a 1.ª build Gradle demorou 6,4 h, o vigia julgou a sessão morta e às 22:39 lançou um
segundo `claude --resume` da MESMA sessão; as duas escreveram nos mesmos ficheiros (o duplicado pôs o cabeçalho do
admin em `Wrap` e tirou o admin do aparelho — mudanças boas, ficaram; e escreveu D72/D73 repetidas — apagadas).
Parado às 23:31 por esta sessão.

## 2. Na web, com a semântica ligada (Playwright «como pessoa»)

`tool/provas/web_percorrer.py` na app publicada `https://app.emdia.boraguarda.com` (22:48): 20 ecrãs, cada um com
captura e com a contagem de nós `flt-semantics`, botões com nome e campos — relatório e fotos em
`provas/em-dia-tudo-2026-09-17/web/`.

| # | Ecrã | Nós | Botões | Campos |
|---|---|---|---|---|
| 1 | entrada | 24 | 3 | 1 |
| 4 | exemplo-painel | 33 | 12 | 0 |
| 5 | exemplo-recibos | 35 | 14 | 1 |
| 6 | exemplo-dinheiro | 59 | 21 | 0 |
| 7 | exemplo-agenda | 65 | 48 | 0 |
| 8 | exemplo-carro | 61 | 47 | 0 |
| 9 | exemplo-mais | 36 | 19 | 0 |
| 10–20 | vale a pena, fala, cofre, prova, radar, reforma, guias, pergunta, ajuda, plano, definições | 18–31 | 2–12 | 0–6 |

Os separadores do fundo aparecem à semântica como `role=tab` com `aria-label` (Painel, Recibos, Dinheiro, Agenda,
Carro, Mais); os botões como `role=button` com o texto dentro (não em `aria-label`) — o script procura das duas formas.

## 3. «Correr como o Danilo» com a conta de teste — parou no CAPTCHA, de propósito

Ao escrever `boraappbora+teste@gmail.com` e carregar em «Enviar código», o Turnstile **invisível falhou** no
Chromium automático (é para isso que serve) e a app mostrou a caixa «Confirme que é humano» com o aviso «Não
consegui confirmar que não és um robô. Tenta outra vez.» — captura `web/03-depois-de-pedir-turnstile_pediu_caixa.png`.
**Não se clica em CAPTCHAs** (regra da casa e da missão). O script regista o estado e segue pelo exemplo (D73).

O que fica para o Danilo (uma vez): `python tool/provas/web_percorrer.py --entrar` abre um Chromium visível já na
app; ele marca a caixa, escreve o código (chega ao boraappbora) e faz o onboarding como ele próprio; a sessão
fica em `C:\BoraLocal\_segredos\em-dia\sessao-teste.json` (fora do repo) e as corridas seguintes entram com a conta
sem CAPTCHA. Está em `docs/PENDENTE-DANILO.md`. **A conta real dele (`3acbfc8d-…`) não foi tocada** — nenhum
teste deste bloco fala com o servidor com sessão.

## Cicatrizes deste bloco (para não repetir)

- A primeira `assembleDebug` do Gradle no PC, com o AVD ligado, demorou **6,4 h** (22 977 s); a segunda 423 s.
  Fica na memória: construir o APK antes de arrancar o emulador.
- Nos testes de widget, depois de `enterText` é preciso um `pump` antes de tocar no botão: sem ele o toque cai
  no botão ainda desligado. E cada folha/rota precisa de dois frames (a rota entra no frame seguinte ao toque).
- O `IndexedStack` do fundo mantém as 6 abas vivas: um `find.text` solto apanha widgets das abas escondidas —
  todos os finders são «dentro desta aba» (`na(EntradasScreen, …)`).
- Na web, `IconButton`/`Cartao` com toque não põem o rótulo em `aria-label`; os separadores sim.

## Decisões

D72 (testes sem servidor, com as stores do exemplo) e D73 (CAPTCHA não se clica; sessão guardada pela pessoa) em
`docs/DECISOES.md`.
