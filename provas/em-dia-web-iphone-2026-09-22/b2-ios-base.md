# B2 - iPhone de raiz

## Criacao iOS

Comando:

```text
flutter create --platforms=ios .
```

Saida literal relevante:

```text
Recreating project ....
Wrote 41 files.
flutter_create_ios_exit=0
```

## Bundle, nome e permissoes

Verificacao:

```text
PRODUCT_BUNDLE_IDENTIFIER = pt.emdia.app;
PRODUCT_BUNDLE_IDENTIFIER = pt.emdia.app.RunnerTests;
```

`ios/Runner/Info.plist` tem:

```text
CFBundleDisplayName = Em Dia
CFBundleName = Em Dia
NSLocationWhenInUseUsageDescription
NSCameraUsageDescription
NSPhotoLibraryUsageDescription
NSMicrophoneUsageDescription
NSSpeechRecognitionUsageDescription
NSFaceIDUsageDescription
```

## Chaves por xcconfig

`ios/Flutter/Debug.xcconfig` e `Release.xcconfig` incluem:

```text
#include? "Secrets.xcconfig"
```

`ios/.gitignore` ignora:

```text
Flutter/Secrets.xcconfig
```

O workflow escreve `ios/Flutter/Secrets.xcconfig` a partir dos secrets antes do build.

## Apagar conta dentro da app

Existe na app:

```text
lib/screens/mais/definicoes_screen.dart: Definicoes -> Apagar a minha conta
descricao: Pedido feito na app (Definicoes -> Apagar a minha conta). Apagar a conta e os dados em ate 30 dias.
```

## Entrar com Apple / Google

Decisao D77 em `docs/DECISOES.md`: no iOS o botao Google fica desligado. O iPhone entra por e-mail + codigo, sem obrigar Sign in with Apple nesta missao.

Codigo alterado:

```text
bool get googleDisponivel => googleWebClientId.isNotEmpty && (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS);
```

## Compras

Sem StoreKit configurado nesta missao. `planos_a_venda=nao` esconde compra e a ficha iOS deve declarar sem compras dentro da app.

## Push iOS / Firebase

Workflow preparado para restaurar `GOOGLE_SERVICE_INFO_PLIST_B64` se existir. Se o segredo nao existir, a build avisa que push iOS fica desligado; isto nao bloqueia a submissao.

## Linha de montagem

Criado `.github/workflows/build_ios.yml` com `workflow_dispatch`, runner `macos-latest`, `pod install`, build IPA e upload opcional para TestFlight se os secrets Apple existirem. Nao foi executado nesta sessao.

## Provas locais

```text
flutter pub get
generated_xcconfig=exists
```

```text
pod_missing
```

```text
flutter build ios --no-codesign
Could not find an option named "--no-codesign".
build_ios_local_exit=64
```

```text
flutter build ipa --release
Could not find an option named "--release".
build_ipa_local_exit=64
```

```text
dart run flutter_launcher_icons
Overwriting default iOS launcher icon with new icon
Successfully generated launcher icons
launcher_icons_exit=0
```

Conclusao: a base iOS ficou no repo; `pod install` e build IPA precisam do runner macOS, nao deste Windows.

## Telegram

Pendente de envio no fecho B1/B2 conjunto.

## e2e_log

Linha material pendente para Claude.ai, como registado em `docs/PARA-A-CLAUDE-AI.md`.
