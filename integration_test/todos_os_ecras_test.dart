// B8 (2026-09-18): o mesmo percurso por todos os ecrãs, mas num aparelho a sério
// (AVD emdia, com gravação de ecrã). O corpo é partilhado com a VM:
// test/integracao/percurso_todos_os_ecras.dart.
//
// Correr: flutter test integration_test/todos_os_ecras_test.dart -d emulator-5554
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/integracao/percurso_todos_os_ecras.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  definirTestes();
}
