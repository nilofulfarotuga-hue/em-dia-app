import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/screens/mais/definicoes_screen.dart';
import 'package:em_dia/screens/mais/mais_screen.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// Mais — a grelha 2×N de acessos rápidos (MaisMei) e as Definições.
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  testWidgets('mais: grelha 2×N, 3 tamanhos, PT e BR', (tester) async {
    await fotografaSuite(tester, nome: 'mais', tela: () => comStores(const MaisScreen(), perfil: perfilTeste()));
    for (final chave in ['reforma', 'guias', 'ia', 'ajuda', 'definicoes']) {
      expect(find.byKey(Key('mais_$chave')), findsOneWidget, reason: 'tile $chave');
    }
    // regras_legais.planos_a_venda = «nao»: nada à venda, o «Plano» não aparece.
    expect(find.byKey(const Key('mais_plano')), findsNothing);
  });

  testWidgets('mais: com planos à venda aparece o «Plano»', (tester) async {
    await tester.pumpWidget(embrulha(comStores(const MaisScreen(), perfil: perfilTeste(), planosAVenda: true), const Locale('pt')));
    await tester.pump();
    await tester.scrollUntilVisible(find.byKey(const Key('mais_plano')), 300, scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('mais_plano')), findsOneWidget);
  });

  testWidgets('mais: definições (PT/BR, sair, apagar conta)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'mais_definicoes',
      tela: () => comStores(const DefinicoesScreen(), perfil: perfilTeste()),
    );
    expect(find.byKey(const Key('defs_pt')), findsOneWidget);
    expect(find.byKey(const Key('defs_br')), findsOneWidget);
    expect(find.byKey(const Key('defs_sair')), findsOneWidget);
    expect(find.byKey(const Key('defs_apagar')), findsOneWidget);
  });

  testWidgets('mais: definições estatísticas (PT/BR)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'mais_definicoes_estatisticas',
      tela: () => comStores(const DefinicoesScreen(), perfil: perfilTeste(consentiuEstatisticas: true)),
    );
    expect(find.byKey(const Key('defs_estatisticas')), findsOneWidget);
  });
}
