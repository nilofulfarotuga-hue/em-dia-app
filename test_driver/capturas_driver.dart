// Driver do `flutter drive` que grava as capturas da App Store em disco
// (missão em-dia-ios-2026-09-22, bloco 3; receita copiada do Bora).
//
// A pasta vem de CAPTURAS_DIR (o CI usa uma por tamanho de ecrã:
// artefactos/capturas/6.9 e artefactos/capturas/6.5).
//
// Uso (no CI, simulador iOS já arrancado):
//   CAPTURAS_DIR=artefactos/capturas/6.9 flutter drive \
//     --driver=test_driver/capturas_driver.dart \
//     --target=integration_test/capturas_loja_test.dart -d "$UDID"
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final pasta = Directory(Platform.environment['CAPTURAS_DIR'] ?? 'artefactos/capturas');
  if (!pasta.existsSync()) pasta.createSync(recursive: true);
  await integrationDriver(
    onScreenshot: (String nome, List<int> bytes, [Map<String, Object?>? args]) async {
      final ficheiro = File('${pasta.path}/$nome.png');
      ficheiro.writeAsBytesSync(bytes);
      // ignore: avoid_print
      print('CAPTURA_GRAVADA ${ficheiro.path} (${bytes.length} bytes)');
      return true;
    },
  );
}
