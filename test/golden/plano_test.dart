import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/screens/plano/plano_screen.dart';
import 'package:em_dia/services/compras.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// Tela 9 — O teu plano: em trial (faltam 25 dias) e no plano grátis (com os
/// limites), com a loja falsa (nunca fala com a Google Play nas fotos).
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  final hoje = DateTime(2026, 9, 6);

  Widget tela(String plano) => embrulhaStores(
        tela: PlanoScreen(hoje: hoje, compras: Compras.paraTeste()),
        perfil: perfilTeste(trialAte: DateTime(2026, 9, 30)),
        plano: plano,
      );

  testWidgets('plano: em trial (faltam 25 dias), 3 tamanhos, PT e BR', (tester) async {
    await fotografaSuite(tester, nome: 'plano', tela: () => tela('trial'));
    expect(find.byKey(const Key('plano_estado_trial')), findsOneWidget);
    expect(find.textContaining('25'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('plano_ativar_pro')), findsOneWidget);
    expect(find.byKey(const Key('plano_ativar_familia')), findsOneWidget);
    expect(find.text('3,49 €/mês'), findsOneWidget);
    expect(find.text('5,99 €/mês'), findsOneWidget);
  });

  testWidgets('plano: grátis com limites (3 avisos, 1 carro, 5 perguntas)', (tester) async {
    await fotografaSuite(tester, nome: 'plano_gratis', tela: () => tela('free'));
    expect(find.byKey(const Key('plano_estado_free')), findsOneWidget);
    expect(find.textContaining('3 avisos'), findsOneWidget);
    expect(find.textContaining('1 carro'), findsOneWidget);
    expect(find.textContaining('5 perguntas'), findsOneWidget);
    // O botão "gerir" está no fim da lista: fora do ecrã não é construído.
    await tester.scrollUntilVisible(find.byKey(const Key('plano_gerir')), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('plano_gerir')), findsOneWidget);
  });

  testWidgets('plano: por ano mostra 29,90 € e 49,90 € e a poupança', (tester) async {
    await tester.pumpWidget(embrulha(tela('free'), const Locale('pt')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('plano_ano')));
    await tester.pump();
    expect(find.text('29,90 €/ano'), findsOneWidget);
    expect(find.textContaining('11,98 €'), findsOneWidget); // 3,49 × 12 − 29,90
    // O cartão Família fica mais abaixo: fora do ecrã não é construído.
    await tester.scrollUntilVisible(find.text('49,90 €/ano'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('49,90 €/ano'), findsOneWidget);
  });

  testWidgets('plano: sem loja (web/desktop) mostra a mensagem e não deixa comprar', (tester) async {
    // Nos testes a plataforma por omissão é Android (e aí a tela cria a loja
    // real). Aqui finge-se um computador: sem loja → mensagem da web.
    // (o flutter_test exige que a variável volte a null ANTES de o teste acabar)
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      await tester.pumpWidget(embrulha(
        embrulhaStores(tela: PlanoScreen(hoje: hoje), perfil: perfilTeste(), plano: 'free'),
        const Locale('pt'),
      ));
      await tester.pump();
      expect(find.textContaining('telemóvel Android'), findsOneWidget);
      final botao = tester.widget<ElevatedButton>(
        find.descendant(of: find.byKey(const Key('plano_ativar_pro')), matching: find.byType(ElevatedButton)),
      );
      expect(botao.onPressed, isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
