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
    for (final chave in ['reforma', 'guias', 'ia', 'ajuda', 'plano', 'definicoes']) {
      expect(find.byKey(Key('mais_$chave')), findsOneWidget, reason: 'tile $chave');
    }
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
}
