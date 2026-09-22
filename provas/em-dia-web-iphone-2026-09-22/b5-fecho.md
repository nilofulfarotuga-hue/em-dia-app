# B5 — portao e fecho

Data: 2026-09-22.

## Testes finais

`flutter analyze --no-fatal-infos`

Saida literal:

```text
Analyzing em_dia...
No issues found! (ran in 24.8s)
```

`flutter test test/unit -r compact`

Saida literal final:

```text
00:47 +182: All tests passed!
```

`flutter test test/golden -r compact`

Saida literal final:

```text
02:42 +141: All tests passed!
```

`flutter test test/integracao/todos_os_ecras_test.dart -r compact`

Saida literal final:

```text
ECRAS_VISTOS=78: onboarding/boas-vindas | onboarding/trabalhas-como | onboarding/recibos/o-que-fazes | onboarding/recibos/quando-abriste | onboarding/recibos/iva-15k | onboarding/recibos/tens-carro | onboarding/recibos/quanto-ganhas | onboarding/recibos/fim | onboarding/boas-vindas | onboarding/trabalhas-como | onboarding/contrato/salario | onboarding/contrato/nascimento | onboarding/contrato/tens-carro | onboarding/contrato/fim | onboarding/boas-vindas | onboarding/trabalhas-como | onboarding/ambos/o-que-fazes | onboarding/ambos/quando-abriste | onboarding/ambos/iva-15k | onboarding/ambos/salario | onboarding/ambos/nascimento | onboarding/ambos/tens-carro | onboarding/ambos/quanto-ganhas | onboarding/ambos/fim | onboarding/boas-vindas | onboarding/trabalhas-como | onboarding/empresa/tipo | onboarding/empresa/iva-periodo | onboarding/empresa/tens-carro | onboarding/empresa/contabilista | onboarding/empresa/fim | painel | painel/palavras-dificeis | recibos | recibos/calculadora-com-valor | recibos/seguranca-social | recibos/irs | dinheiro/entra | dinheiro/nova-entrada | dinheiro/sai | dinheiro/nova-saida | dinheiro/caixa-das-faturas | dinheiro/sobra | dinheiro/importar-extrato | dinheiro/recorrentes | agenda | agenda/detalhe-obrigacao | agenda/nova-obrigacao | carro | carro/palavras-dificeis | mais | mais/vale_a_pena | mais/fala | mais/cofre | mais/prova | mais/radar | mais/reforma | mais/guias | mais/guias/detalhe | mais/ia | mais/ajuda | mais/plano | mais/definicoes | recibos/contrato | recibos/contrato/recibo_vencimento | recibos/contrato/desemprego | recibos/contrato/horas_extra | recibos/empresa | entrada | admin/seccao-0 | admin/seccao-1 | admin/seccao-2 | admin/seccao-3 | admin/seccao-4 | admin/seccao-5 | admin/seccao-6 | admin/seccao-7 | admin/seccao-8
01:40 +6: All tests passed!
```

## Correcao feita no portao

O `flutter create --platforms=ios .` tinha criado `test/widget_test.dart`, o teste padrao do contador Flutter. Esse teste chamava `MyApp`, que nao existe no Em Dia, e fazia o analyze/test falhar. Foi removido.

Os goldens de plano e suporte ainda esperavam botoes de compra, gestao de subscricoes e termos de compra. Isso contrariava a decisao desta missao: `planos_a_venda = nao`. Os testes foram atualizados para provar o comportamento correto: precos podem aparecer como referencia, mas botoes de comprar, gerir subscricoes e abrir subscricoes nao aparecem.

O aviso antigo do analyzer sobre `anonKey` foi fechado trocando a inicializacao do Supabase para `publishableKey`, a API nova equivalente.

## Revisao cruzada

Pedido de revisao a `glm-5.2` falhou com erro real:

```text
HTTP 503 (oai): todos os fornecedores falharam para glm-5.2
```

Foi usada a segunda tentativa com `qwen3.7-plus`. Achados aproveitados: especificar que o identificador de utilizador e UUID do Supabase; acrescentar retencao/apagamento de documentos; deixar a Claude.ai confirmar a conta do revisor, `EMAIL_REVISOR`, ausencia do Google no iOS e pedido de notificacoes so se APNs/Firebase iOS estiverem configurados.

Discordei de um achado da revisao: ela tratou e-mail+codigo como se obrigasse Sign in with Apple. A regra Apple 4.8 aplica-se a logins sociais/de terceiro; por isso a decisao D77 mantem-se: no iOS nao aparece Google, e a entrada principal e e-mail+codigo da propria app.

## Bloqueios assumidos

`pod install` nao correu porque `pod` nao existe neste Windows.

Build iOS local nao foi provada neste PC. As tentativas devolveram:

```text
flutter build ios --no-codesign -> Could not find an option named "--no-codesign".
flutter build ipa --release -> Could not find an option named "--release".
```

O build iOS ficou para o runner macOS criado em `.github/workflows/build_ios.yml` e para a Claude.ai/App Store Connect.

O `e2e_log` nao foi escrito diretamente porque o OpenCode nao tem SQL seguro no Supabase do Em Dia e o MCP local esta preso ao projeto do Bora. O pedido ficou em `docs/PARA-A-CLAUDE-AI.md`.

## Ficheiros locais nao incluidos

`provas/em-dia-tudo-2026-09-17/prova-rendimento-12m.pdf` ja estava modificado fora desta missao. Nao foi tocado para o fecho.

`AGENTS.md`, `docs/opencode-*.err` e `docs/opencode-*.launch.ps1` aparecem como ficheiros locais/untracked de arranque/contexto. Nao fazem parte do produto entregue.
