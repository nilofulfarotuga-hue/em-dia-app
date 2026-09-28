// Redes Em Dia (2026-09-23): fotografa os ecrãs VERDADEIROS da app no modo
// exemplo (a Maria, dados inventados, nada do servidor) para as peças das
// redes. Não faz parte da suíte do CI: corre-se à mão.
//
//   flutter test tool/redes/capturas_test.dart
//
// Há stores que leem DateTime.now() (agenda, dinheiro): o «hoje» do exemplo
// tem de ser o dia em que se corre, senão os ecrãs contam histórias diferentes.
//
// Saída: docs/marketing/redes-em-dia/capturas/<nome>.png (1170×2532, 390×844 @3x).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/exemplo/exemplo_screen.dart';

import '../../test/golden/_apoio.dart';
import '../../test/golden/fabrica_de_fotos.dart';

const _dir = 'docs/marketing/redes-em-dia/capturas';

/// O «hoje» das fotos: o dia em que se corre (as fotos das redes foram
/// tiradas a 23/09/2026; o próximo prazo da Maria é o pagamento de outubro
/// à Segurança Social e a declaração trimestral até 31/10).
final DateTime? _hoje = null;

Future<void> _foto(
  WidgetTester tester,
  String nome, {
  Locale locale = const Locale('pt'),
  Future<void> Function(WidgetTester)? antes,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(embrulha(comStores(ExemploScreen(hoje: _hoje)), locale));
  await tester.pump(const Duration(milliseconds: 200));
  if (antes != null) await antes(tester);
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
  Directory(_dir).createSync(recursive: true);
  final caminho = '$_dir/$nome.png';
  await tester.runAsync(() async {
    final elemento = find.byType(MaterialApp).evaluate().first;
    final ui.Image imagem = await captureImage(elemento);
    final bytes = await imagem.toByteData(format: ui.ImageByteFormat.png);
    await File(caminho).writeAsBytes(bytes!.buffer.asUint8List());
  });
}

Future<void> Function(WidgetTester) _aba(IconData icone, {double scroll = 0}) => (t) async {
      await t.tap(find.byIcon(icone));
      await t.pump(const Duration(milliseconds: 500));
      if (scroll > 0) {
        await t.drag(find.byType(Scrollable).last, Offset(0, -scroll));
        await t.pump(const Duration(milliseconds: 500));
      }
    };

Future<void> Function(WidgetTester) _mais(IconData icone, {double scroll = 0}) => (t) async {
      await t.tap(find.byIcon(Icons.more_horiz_rounded));
      await t.pump(const Duration(milliseconds: 500));
      final alvo = find.byIcon(icone);
      await t.ensureVisible(alvo.first);
      await t.pump(const Duration(milliseconds: 300));
      await t.tap(alvo.first);
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(milliseconds: 300));
      }
      if (scroll > 0) {
        await t.drag(find.byType(Scrollable).last, Offset(0, -scroll));
        await t.pump(const Duration(milliseconds: 500));
      }
    };

void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  final fotos = <String, Future<void> Function(WidgetTester)?>{
    'painel': null,
    'painel-baixo': (t) async {
      await t.drag(find.byType(Scrollable).first, const Offset(0, -520));
      await t.pump(const Duration(milliseconds: 500));
    },
    'recibos': _aba(Icons.receipt_long_outlined),
    'recibos-baixo': _aba(Icons.receipt_long_outlined, scroll: 520),
    'dinheiro': _aba(Icons.account_balance_wallet_outlined),
    'dinheiro-baixo': _aba(Icons.account_balance_wallet_outlined, scroll: 520),
    'agenda': _aba(Icons.calendar_month_outlined),
    'agenda-baixo': _aba(Icons.calendar_month_outlined, scroll: 520),
    'carro': _aba(Icons.directions_car_outlined),
    'carro-baixo': _aba(Icons.directions_car_outlined, scroll: 520),
    'mais': _aba(Icons.more_horiz_rounded),
    'vale-a-pena': _mais(Icons.calculate_rounded),
    'cofre': _mais(Icons.savings_outlined),
    'prova': _mais(Icons.description_rounded),
    'radar': _mais(Icons.link_off_rounded),
    'reforma': _mais(Icons.savings_rounded),
    'guias': _mais(Icons.menu_book_rounded),
  };
  for (final e in fotos.entries) {
    testWidgets('redes — ${e.key}', (t) => _foto(t, e.key, antes: e.value));
  }
  testWidgets('redes — painel (pt-BR)', (t) => _foto(t, 'painel-br', locale: const Locale('pt', 'BR')));
  testWidgets('redes — recibos (pt-BR)',
      (t) => _foto(t, 'recibos-br', locale: const Locale('pt', 'BR'), antes: _aba(Icons.receipt_long_outlined)));
}
