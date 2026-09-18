import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/screens/mais/mais_screen.dart';
import 'package:em_dia/widgets/palavras_dificeis.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// «O que é isto?» (B4): a folha das palavras difíceis, aberta a partir do
/// ecrã Mais, e o Mais com as linhas novas por baixo de cada título.
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  testWidgets('palavras difíceis: folha aberta a partir do Mais, 3 tamanhos, PT e BR', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'palavras_dificeis',
      tela: () => comStores(const MaisScreen(), perfil: perfilTeste()),
      antes: (t) async {
        // A folha abre-se UMA vez e fica aberta para as 6 fotos: o `pumpWidget`
        // da fábrica reaproveita o mesmo `MaterialApp` (e o Navigator), por isso
        // um segundo toque caía na cortina e fechava-a (cicatriz do cofre_folha).
        if (find.byKey(const Key('palavras_folha')).evaluate().isNotEmpty) return;
        await t.tap(find.byKey(const Key('palavras_cofre')));
        await t.pumpAndSettle();
      },
    );
    expect(find.byKey(const Key('palavras_folha')), findsOneWidget);
    // As cinco palavras do Mais, cada uma com o seu botão de ouvir.
    for (final termo in PalavrasDoEcra.mais) {
      expect(find.byKey(Key('ouvir_palavra-$termo')), findsOneWidget, reason: termo);
    }
  });

  testWidgets('palavras difíceis: a folha longa dos guias rola e não estoura no ecrã pequeno', (tester) async {
    await fotografaTela(
      tester,
      nome: 'palavras_dificeis_guias',
      tamanho: tamanhos.first,
      tela: () => comStores(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: BotaoPalavras(termos: PalavrasDoEcra.guias, comTexto: true),
            ),
          ),
        ),
        perfil: perfilTeste(),
      ),
      antes: (t) async {
        await t.tap(find.byKey(const Key('palavras_cae')));
        await t.pumpAndSettle();
      },
    );
    expect(find.byKey(const Key('palavras_folha')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
