// Capturas da App Store (missão em-dia-ios-2026-09-22, bloco 3).
//
// Corre no simulador do CI (`.github/workflows/build_ios.yml`, job A), uma vez
// no iPhone de 6,9" e outra no de 6,5". O driver `test_driver/capturas_driver.dart`
// grava cada `takeScreenshot` em PNG, no tamanho real do ecrã do simulador.
//
// O que se fotografa é a app a sério no modo «Vê como fica, com um exemplo»
// (a Maria): o mesmo modo que qualquer pessoa abre no ecrã de entrada, com a
// faixa laranja a dizer que é um exemplo. Nada desenhado à parte para a loja.
// A ordem segue as frases de docs/APPLE-FICHA-RESPOSTAS.md («Capturas»).
//
// Os passos reaproveitam os do percurso por todos os ecrãs
// (test/integracao/percurso_todos_os_ecras.dart), que já correm verdes na VM e
// no AVD.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:em_dia/exemplo/exemplo_screen.dart';
import 'package:em_dia/screens/calendario/calendario_screen.dart';
import 'package:em_dia/screens/carro/carro_screen.dart';
import 'package:em_dia/screens/mais/mais_screen.dart';
import 'package:em_dia/screens/recibos/recibos_screen.dart';

import '../test/golden/fabrica_de_fotos.dart' show carregaFonteInter, carregaFontesSdk;
import '../test/integracao/percurso_todos_os_ecras.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> foto(WidgetTester t, String nome) async {
    await t.pump(const Duration(milliseconds: 600));
    await binding.takeScreenshot(nome);
    // ignore: avoid_print
    print('[capturas] $nome');
  }

  Future<void> aba(WidgetTester t, IconData icone, String nome, Finder prova) async {
    await toca(t, find.byIcon(icone));
    await ecra(t, nome, prova);
  }

  Future<void> doMais(WidgetTester t, String chave, Finder prova) async {
    await aba(t, Icons.more_horiz_rounded, 'mais', na(MaisScreen, find.byKey(const Key('mais_vale_a_pena'))));
    await rolaAte(t, na(MaisScreen, find.byKey(Key('mais_$chave'))), lista: na(MaisScreen, find.byType(Scrollable)).first);
    await toca(t, na(MaisScreen, find.byKey(Key('mais_$chave'))));
    await ecra(t, 'mais/$chave', prova);
  }

  testWidgets('capturas da App Store (modo exemplo)', (t) async {
    await abre(t, ExemploScreen(hoje: hoje));
    await ecra(t, 'painel', find.textContaining('Maria'));
    await foto(t, '01-painel');

    await aba(t, Icons.receipt_long_outlined, 'recibos', na(RecibosScreen, find.byKey(const Key('calc_valor'))));
    await t.enterText(na(RecibosScreen, find.byKey(const Key('calc_valor'))), '1000');
    await ecra(t, 'recibos/calculadora-com-valor', na(RecibosScreen, find.textContaining('€')));
    // Esconde o teclado para a foto mostrar o resultado da conta.
    FocusManager.instance.primaryFocus?.unfocus();
    await foto(t, '02-recibo');

    await doMais(t, 'cofre', find.text(l.cofreTitulo));
    await foto(t, '03-cofre');
    await recua(t);

    await aba(t, Icons.calendar_month_outlined, 'agenda', na(CalendarioScreen, find.text(l.calTitulo)));
    await foto(t, '04-agenda');

    await aba(t, Icons.directions_car_outlined, 'carro', na(CarroScreen, find.text(l.carroTitulo)));
    await foto(t, '05-carro');

    await doMais(t, 'ia', find.text(l.iaTitulo));
    await foto(t, '06-assistente');
    await recua(t);
  });
}
