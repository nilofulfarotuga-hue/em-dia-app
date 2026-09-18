# B1 — Os seis defeitos provados pela Claude.ai a 17/09 (sessão 49feae11, 2026-09-18 07:00–09:30)

Estado desta prova: o CÓDIGO está feito e testado localmente (118 testes de unidade verdes, 35 testes Deno verdes,
`flutter analyze` só com o info antigo do `anonKey`). O que já está EM PRODUÇÃO: migrações 0030 e 0031 no Supabase e a
Edge Function `calcular-obrigacoes` v5. A app web/Android com estes seis arranjos só chega às pessoas no push (CI) do
fecho da missão — até lá, o site vivo continua a mostrar a build 32.

## 1. O onboarding não guardava nada
- `lib/services/rascunho_onboarding.dart` (novo): cada resposta fica no aparelho (`shared_preferences`, na web é o
  `localStorage`) com carimbo `guardado_em`.
- `profiles.onboarding_rascunho jsonb` (migração 0031, aplicada: `information_schema` devolve `jsonb`) e
  `PerfilStore.guardarRascunhoOnboarding`: a mesma cópia vai para o servidor ao sair de cada pergunta; os campos de
  texto (matrícula, rendimento) gravam 800 ms depois da última tecla.
- Ao reabrir, `OnboardingScreen` aplica o rascunho do servidor (já vem com o perfil) e depois o do aparelho se for mais
  novo; retoma no passo guardado; ao acabar, apaga os dois.
- Prova (teste de widget `test/unit/onboarding_guarda_test.dart`):
  - O03 «responde a 3 perguntas, "recarrega" e está na 4.ª» → verde (`Tens carro?` e `Pergunta 4 de 5` no ecrã novo).
  - O04 «matrícula escrita a meio também fica» → verde (`AA-12-BB` reaparece).
  - O05 «ao acabar, o rascunho é apagado» → verde.
  - Saída literal: `flutter test test/unit` → `OK 118 FALHOU 0` (eram 98 antes desta sessão).

## 2. A web parte ao mudar o tamanho da janela
- Diagnóstico (ver `b0-estado-real.md`): CanvasKit (Flutter 3.47.2; o renderer HTML já não existe). O motor só reage a
  `visualViewport.resize`; quando esse evento não chega, a `<flutter-view>` fica com o tamanho antigo e o canvas some
  até um clique. Reproduzido no navegador embutido (viewport 800x450 → 1100x700: canvas removido, página cinzenta;
  700x900: `flutter-view` presa em 1100x700 mais de 5 s). Um `visualViewport.dispatchEvent(new Event('resize'))` à
  mão fez a `flutter-view` passar de 0x0 a 600x400 e o canvas aparecer na hora.
- Correção em `web/index.html` (serve à app e ao painel): vigia que compara a `<flutter-view>` com a janela
  (ResizeObserver na raiz + olhadela de 700 ms + `resize`/`orientationchange`/`visibilitychange`) e, só quando há
  diferença, dá o empurrão pelo `visualViewport`. Contador em `window.__emDiaVigiaTamanho`.
- Semântica ligada por defeito: `SemanticsBinding.instance.ensureSemantics()` em `arrancar()` quando `kIsWeb`
  (lib/services/arranque.dart). Antes: `flt-semantics-host` com 0 filhos.
- O que falta provar (fica para o B6, na build publicada): 5 redimensionamentos sem partir e a árvore de
  acessibilidade com nós, no Chrome real; medir o tempo até ao primeiro ecrã antes/depois (antes: 711 ms quente,
  ≈3,1 s frio).

## 3. Prazos ao fim-de-semana e feriados («Segurança Social até domingo, dia 20»)
- Regra confirmada na fonte a 2026-09-18 (ver `docs/REGRAS-PT-2026.md` quando o B3 o escrever; aqui as citações):
  - AT, «Resumo anual — Obrigações de pagamento em 2026», nota a): «Nos meses que terminam em fim de semana ou
    feriado, a obrigação pode ser cumprida até ao dia útil seguinte.» — o próprio quadro da AT mostra os pagamentos
    por conta de IRS de 2026 a 20/07, **21/09** e **21/12** (20/9 e 20/12 são domingos).
  - Segurança Social, Guia Prático «Pagamento de Contribuições»: «Se o último dia de pagamento coincidir com um
    sábado, domingo ou feriado, o pagamento poderá ser efetuado no dia útil seguinte.»
  - CRC (Lei 110/2009, DRE consolidado) art. 155.º n.º 2: independentes pagam «entre o dia 10 e o dia 20 do mês
    seguinte» — NÃO mudou com o DL 127/2025 (esse alterou só os arts. 23.º-B, 29.º, 32.º, 40.º e 43.º: entidades
    empregadoras passam a pagar entre o dia 1 e o dia 25). Art. 151.º-A n.º 3: declaração trimestral até ao último
    dia de abril, julho, outubro e janeiro.
  - Feriados: Código do Trabalho art. 234.º (DRE consolidado) — a tabela `feriados` (26 linhas, 2026 e 2027) bate
    certo com a lei, Páscoa incluída (teste F02).
  - CIVA art. 41.º n.º 10 (redação do DL 49/2025): a declaração do 2.º trimestre entrega-se «até 20 de setembro», não
    em agosto; art. 27.º n.º 1 b): pagamento até dia 25. A app punha o T2 em agosto — corrigido (regra
    `iva_trimestre2_mes = 9`).
  - CIVA art. 53.º n.º 1 (redação do DL 35/2025): 15 000 € — o «não deixes 15.000 sem prova» está provado.
- Código: `prazoEfetivo()` em `lib/regras/datas.dart` e `_shared/regras.ts`; `Obrigacao`/`ObrigacaoItem` ganham
  `prazoEfetivo` (dia útil seguinte só para os tipos do Estado; seguro/inspeção/carta ficam na data); `passou` e
  «faltam N dias» contam pelo efetivo; o aviso continua na véspera útil do dia legal. Coluna `obrigacoes.prazo_efetivo`
  (migração 0030, aplicada) e `marcar_obrigacoes_passadas()` a usar `coalesce(prazo_efetivo, data_limite)`.
- Frase certa no cartão de ação (`painelAcaoPrazoDiaNaoUtil`): «Dia 20 é domingo: tens até segunda, dia 21»; no
  detalhe da obrigação, linha «Esse dia é fim-de-semana ou feriado: tens até 21 de setembro de 2026».
- Edge Function `calcular-obrigacoes`: v4 (06:54:32Z) com o `regras.ts` novo, **v5** (07:02:52Z) com a porta de QA
  (`user_id` + `x-cron-secret`, para os testes de ponta a ponta não passarem pelo e-mail nem pelo Turnstile).
  `get_edge_function` v4: os 3 ficheiros no servidor são byte a byte iguais aos locais (sha 2b186e41…, fa2095bc…,
  431061490…). Chamada real (conta de teste `boraappbora+emulador@gmail.com`, nunca a do Danilo): sem segredo → 401;
  segredo errado → 401; com segredo → `200 {geradas: 11, atualizadas: 11}` e a tabela ficou com
  `2027-03-20 → 2027-03-22`, `2027-06-20 → 2027-06-21`, `2027-07-31 → 2027-08-02` (SELECT lido de volta).
- Contas já existentes: a app passa a pedir o recálculo ao servidor uma vez por dia ao abrir
  (`ObrigacoesStore.recalcularSeVelho`), por isso o «até domingo 20» do Danilo corrige-se sozinho na primeira abertura
  da build nova. (Um UPDATE em massa por SQL foi recusado pelo classificador de permissões desta sessão; não se
  insistiu — o recálculo diário faz o mesmo sem tocar em dados à mão.)
- Testes: `test/unit/prazos_dia_util_test.dart` (P01–P07, F01–F02, G01–G05, I01–I03) e C43/C49 no Deno.

## 4. A matrícula prometia e não cumpria
- Texto novo (`onbMatriculaAjuda`, PT e BR): «A matrícula é só para eu saber de que carro falo. O IUC paga-se todos
  os anos no mês da matrícula, e a inspeção depende da idade do carro — por isso peço-te o mês e o ano a seguir e
  faço as contas por ti.» A pergunta do mês/ano fica; o cálculo já existia (`calendarioIpo`: 4 anos, depois de 2 em
  2 até aos 8, depois anual; TVDE anual).
- Fontes confirmadas hoje: IMT «Tipos de inspeções» (ligeiros M1: «Quatro anos após a data da primeira matrícula e,
  em seguida, de dois em dois anos, até perfazerem oito anos, e, depois, anualmente.») e Lei 45/2018 art. 12.º n.º 5
  (TVDE: «um ano após a data da primeira matrícula e, em seguida, anualmente»; n.º 4: idade inferior a 7 anos).
  `ipo_tvde` deixou de ser «por confirmar»; regra nova `tvde_idade_max_anos = 7`.

## 5. «4 perguntas rápidas» e são 5
- `boasVindas` deixa de dizer um número: «Vamos começar com umas perguntas rápidas: leva 2 minutos, e podes mudar
  tudo depois.» (O número depende do caminho: 5 para quem tem atividade, 2 para quem só quer o carro; o B3 vai mudar
  a primeira pergunta.)

## 6. Dois cartões a dizer o mesmo
- `painel_screen.dart`: o semáforo laranja/vermelho só aparece quando há uma SEGUNDA coisa além da que está no
  cartão de ação, e passa a falar dessa: «Além desta, tens mais 1 coisa a vencer em 3 dias» (chaves
  `painelSemaforoAlem*`, PT e BR). O verde («Está tudo em dia») mantém-se.

## Ferramentas desta sessão
- Deno 2.9.7 instalado em `~/.deno` só para correr `_shared/regras_test.ts` (35 verdes) e `deno check` das funções.
- Vigia `EmDia-Retomar` re-registado (07:16, 07:36: «sessão viva, saio»); batimento pid 7372.
