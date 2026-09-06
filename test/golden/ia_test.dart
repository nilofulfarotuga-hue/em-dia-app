import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/mensagem_ia.dart';
import 'package:em_dia/screens/ia/ia_screen.dart';
import 'package:em_dia/stores/ia_store.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// Tela 7 — Pergunta ao Em Dia (chat com o assistente).
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  List<MensagemIa> duasTrocas() => [
        MensagemIa.utilizador('Abri atividade em março, quando começo a pagar?', quando: DateTime(2026, 9, 5, 10, 0)),
        MensagemIa.emDia(
          'Nos primeiros 12 meses depois de abrir atividade não pagas Segurança Social — estás isento até fevereiro de 2027.\n'
          'O IVA só entra se passares os 15.000 € num ano. Até lá, recibos com a frase de isenção.\n'
          'Próximo passo: em março de 2027 começas a pagar SS todos os meses, até ao dia 20. Eu aviso-te 5 dias antes.',
          quando: DateTime(2026, 9, 5, 10, 0),
        ),
        MensagemIa.utilizador('E o IRS, tenho de guardar quanto?', quando: DateTime(2026, 9, 5, 10, 2)),
        MensagemIa.emDia(
          'Com 1.200 € por mês, guarda cerca de 10 % de cada recibo para o IRS de 2027.\n'
          'Próximo passo: põe esse valor numa conta à parte todos os meses.',
          foraDasRegras: true,
          quando: DateTime(2026, 9, 5, 10, 2),
        ),
      ];

  testWidgets('ia: chat com 2 trocas — 3 tamanhos, com e sem teclado, PT e BR', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'ia',
      comTeclado: true,
      tela: () => comStores(IaScreen(store: IaStore.paraTeste(duasTrocas(), usadas: 2, limiteValor: 5))),
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.textContaining('Próximo passo:'), findsWidgets);
    expect(find.text('Informação geral, não substitui contador.'), findsOneWidget);
  });

  testWidgets('ia_limite: plano grátis esgotado (402) — cadeado e CTA do plano', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'ia_limite',
      tela: () => comStores(
        IaScreen(store: IaStore.paraTeste(duasTrocas(), limite: true, usadas: 5, limiteValor: 5)),
        plano: 'free',
      ),
    );
    expect(find.byIcon(Icons.lock_rounded), findsWidgets);
    expect(find.textContaining('5'), findsWidgets);
  });

  testWidgets('ia_pensar: estado "a pensar" com os 3 pontos', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'ia_pensar',
      tela: () => comStores(IaScreen(store: IaStore.paraTeste(duasTrocas().take(3).toList(), aPensar: true))),
    );
    expect(find.bySemanticsLabel(RegExp('pensa', caseSensitive: false)), findsOneWidget);
  });

  testWidgets('ia_vazio: primeira vez, sem conversa — 4 perguntas prontas empilhadas', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'ia_vazio',
      tela: () => comStores(IaScreen(store: IaStore.paraTeste(const []))),
    );
    expect(find.text('Passei dos 15 mil, e agora?'), findsOneWidget);
  });

  test('IaStore.limparRodape tira o rodapé do servidor', () {
    expect(IaStore.limparRodape('Olá.\nInformação geral, não substitui contabilista.'), 'Olá.');
    expect(IaStore.limparRodape('Olá.'), 'Olá.');
  });
}
