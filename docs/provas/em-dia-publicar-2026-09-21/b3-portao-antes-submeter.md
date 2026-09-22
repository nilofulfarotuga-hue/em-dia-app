# B3 - portao antes de submeter

## Fontes oficiais consultadas

Google/Android consultado por pagina publica:

```text
https://developer.android.com/google/play/requirements/target-sdk
https://developer.android.com/guide/practices/page-sizes
https://developer.android.com/build/releases/gradle-plugin
```

Leitura usada na decisao:

```text
Novas apps e atualizacoes na Play depois de 31/08/2026 precisam de target API 36.
Suporte a paginas de memoria de 16 KB e exigido para apps que apontam a API 35+ a partir de 01/02/2027.
```

## Projeto Android

Ficheiros lidos:

```text
android/app/build.gradle.kts: namespace/applicationId = pt.emdia.app
android/app/build.gradle.kts: ndkVersion = "28.2.13676358"
android/app/build.gradle.kts: targetSdk = flutter.targetSdkVersion
android/settings.gradle.kts: Android Gradle Plugin 9.1.0
android/settings.gradle.kts: Kotlin 2.4.0
android/gradle/wrapper/gradle-wrapper.properties: Gradle 9.3.1
```

Saida literal do Flutter:

```text
Flutter 3.47.2
Dart 3.13.2
```

Manifest local gerado no build debug confirma o valor efetivo do `flutter.targetSdkVersion` nesta instalacao:

```text
build/app/intermediates/manifest_merge_blame_file/debug/processDebugMainManifest/manifest-merger-blame-debug-report.txt:
android:targetSdkVersion="36"
```

Nota: nao consegui extrair o `targetSdkVersion` diretamente do AAB com `aapt/aapt2`, porque as ferramentas locais recusaram o formato AAB. A configuracao de release usa o mesmo `targetSdk = flutter.targetSdkVersion`.

## AAB local e 16 KB

AAB local encontrado fora do repo:

```text
aab_exists=True
aab_size=60012220
C:\Users\danil\AppData\Local\Android\Sdk\build-tools\36.0.0\zipalign.exe exists=True
bundletool_missing
```

Bibliotecas nativas dentro do AAB:

```text
so_count=12
\base\lib\arm64-v8a\libapp.so
\base\lib\arm64-v8a\libdartjni.so
\base\lib\arm64-v8a\libdatastore_shared_counter.so
\base\lib\arm64-v8a\libflutter.so
\base\lib\armeabi-v7a\libapp.so
\base\lib\armeabi-v7a\libdartjni.so
\base\lib\armeabi-v7a\libdatastore_shared_counter.so
\base\lib\armeabi-v7a\libflutter.so
\base\lib\x86_64\libapp.so
\base\lib\x86_64\libdartjni.so
\base\lib\x86_64\libdatastore_shared_counter.so
\base\lib\x86_64\libflutter.so
```

Verificacao com `llvm-objdump.exe -p` nos `.so` de 64 bits:

```text
\base\lib\arm64-v8a\libapp.so bad_align=False LOAD align 2**16
\base\lib\arm64-v8a\libdartjni.so bad_align=False LOAD align 2**14
\base\lib\arm64-v8a\libdatastore_shared_counter.so bad_align=False LOAD align 2**14
\base\lib\arm64-v8a\libflutter.so bad_align=False LOAD align 2**16
\base\lib\x86_64\libapp.so bad_align=False LOAD align 2**16
\base\lib\x86_64\libdartjni.so bad_align=False LOAD align 2**14
\base\lib\x86_64\libdatastore_shared_counter.so bad_align=False LOAD align 2**14
\base\lib\x86_64\libflutter.so bad_align=False LOAD align 2**16
```

Conclusao: as bibliotecas verificadas ficam alinhadas a 16 KB ou mais. Nao apareceu `2**12` nos `.so` de 64 bits.

## Testes

Saidas literais recolhidas nesta sessao:

```text
flutter analyze --no-fatal-infos
1 info: anonKey deprecated
```

```text
flutter test test/unit -r compact
182 All tests passed
```

```text
flutter test test/golden -r compact
141 All tests passed
```

Juiz visual:

```text
python tool/juiz/vision_judge.py
38 verdes, 41 amarelos, 1 vermelho
vermelho: admin_erro_detalhe_desktop_br.png - blocos pretos...
```

## Revisao cruzada

O modelo GLM falhou por 503. Pedi revisao curta ao Qwen. Pontos principais:

```text
Bloqueios reais: Play Console inacessivel; Auth Supabase falhada por captcha; CI/Secrets pendentes porque gh esta ausente.
Riscos: confirmar targetSdk efetivo; validar todos os .so; investigar o vermelho visual.
Verdes: unitarios/goldens, suporte a revisor, ficha gratis sem IAP.
```

## Estado real do B3

Nao esta verde para submissao.

Motivos:

- Play Console continua bloqueada desde B-1/B0, sem captura autenticada e sem possibilidade de submeter.
- `e2e_log` continua bloqueado por Auth/captcha.
- `gh` nao existe nesta maquina, por isso nao confirmei secrets/CI pelo GitHub CLI nesta sessao.
- Juiz visual encontrou 1 vermelho em `admin_erro_detalhe_desktop_br.png`.

Itens tecnicos favoraveis:

- `targetSdkVersion` efetivo local: 36.
- Flutter/AGP/Gradle/NDK recentes.
- AAB local existe.
- Alinhamento 16 KB verificado nos `.so` de 64 bits.
- Unitarios e goldens passaram.

## e2e_log

Nao gravado por esta sessao: a Auth local recusou login com `captcha_failed` no B-1.
