# B0 - estado real antes de mexer

Run: `em-dia-web-iphone-2026-09-22`.

## O que esta no ar

Comando executado:

```text
Invoke-WebRequest aos tres dominios publicos
```

Saida literal:

```text
url=https://emdia.boraguarda.com status=200 length=57300 title=Em Dia - Calculadora de recibo verde gratis e avisos de Seguranca Social, IVA, IRS e carro
url=https://app.emdia.boraguarda.com status=200 length=6857 title=Em Dia
url=https://admin.emdia.boraguarda.com status=200 length=6857 title=Em Dia
```

## Flutter local

Saida literal:

```text
Flutter 3.47.2
Dart 3.13.2
```

## iOS no repo

Saida literal:

```text
ios_dir=missing
build_ios_yml=missing
.github/workflows/build_android.yml
.github/workflows/build_web_deploy.yml
.github/workflows/olho_golden.yml
```

Conclusao: antes do B2 nao ha pasta `ios/` nem workflow `build_ios.yml`.

## Testes de referencia

Unitarios:

```text
flutter test test/unit -r compact
00:45 +182: All tests passed!
unit_exit=0
```

Goldens:

```text
flutter test test/golden -r compact
02:01 +141: All tests passed!
golden_exit=0
```

Integracao / percurso por ecras:

```text
flutter test test/integracao/todos_os_ecras_test.dart -r compact
ECRAS_VISTOS=78: onboarding/boas-vindas | onboarding/trabalhas-como | ... | admin/seccao-8
01:02 +6: All tests passed!
integracao_exit=0
```

## Telegram

Saida literal:

```text
ok=True msg_id=8204 erro=None
```

## e2e_log

Sem linha material gravada por esta sessao ate aqui. Deixei pedido em `docs/PARA-A-CLAUDE-AI.md` para a Claude.ai inserir as linhas do RUN_ID `em-dia-web-iphone-2026-09-22` no Supabase certo, porque esta sessao nao deve fazer SQL no Supabase do Em Dia e nao encontrei utilitario local seguro para o `e2e_log`.
