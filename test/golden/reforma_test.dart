import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/screens/reforma/reforma_screen.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// Tela 5 — Reforma e direitos: com tudo aberto (trial) e com o cadeado
/// `reforma_completa` (plano grátis). "Hoje" fixo para as fotos serem iguais.
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  final hoje = DateTime(2026, 9, 6);

  // TVDE a ganhar 1.200 €/mês: 1.200 × 70 % × 21,4 % = 179,76 €/mês de
  // Segurança Social; 20 anos de descontos → 840 € × 40 % = 336,00 € de reforma.
  Widget tela(String plano) => embrulhaStores(
        tela: ReformaScreen(hoje: hoje),
        perfil: perfilTeste(rendimentoMensalEstimado: 1200),
        plano: plano,
      );

  testWidgets('reforma: tudo aberto (trial), 3 tamanhos, PT e BR', (tester) async {
    await fotografaSuite(tester, nome: 'reforma', tela: () => tela('trial'));
    expect(find.textContaining('179,76 €'), findsOneWidget);
    expect(find.text('336,00 €'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsNothing);
    expect(find.byKey(const Key('reforma_acordo_link')), findsOneWidget);
  });

  testWidgets('reforma: plano grátis — só a primeira linha aberta, o resto com cadeado', (tester) async {
    await fotografaSuite(tester, nome: 'reforma_cadeado', tela: () => tela('free'));
    expect(find.text('336,00 €'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
  });

  testWidgets('reforma: o seletor de anos muda a estimativa (5..45)', (tester) async {
    await tester.pumpWidget(embrulha(tela('trial'), const Locale('pt')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('reforma_mais')));
    await tester.pump();
    expect(find.text('420,00 €'), findsOneWidget); // 25 anos → 50 %
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byKey(const Key('reforma_menos')));
      await tester.pump();
    }
    expect(find.text('84,00 €'), findsOneWidget); // mínimo 5 anos → 10 %
  });
}
