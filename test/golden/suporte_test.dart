import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/ticket_suporte.dart';
import 'package:em_dia/screens/suporte/suporte_screen.dart';
import 'package:em_dia/stores/suporte_store.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// Tela 8 — Ajuda (menu, formulário de bug, reembolso).
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  List<TicketSuporte> tickets() => [
        TicketSuporte(
          id: '5cfa39f8-81b1-4709-90b2-73260e45552a',
          tipo: 'reembolso',
          assunto: 'Quero cancelar a assinatura',
          estado: 'fechado',
          respostaIa: 'Os reembolsos e cancelamentos tratam-se na Google Play.\nPróximo passo: abre a Google Play e faz o pedido lá.',
          criadoEm: DateTime(2026, 9, 2, 9, 30),
        ),
        TicketSuporte(
          id: '85f6a3cb-83a6-49e2-a567-701df9223e73',
          tipo: 'bug',
          assunto: 'A app fecha ao abrir o calendário',
          estado: 'em_curso',
          escalarHumano: true,
          criadoEm: DateTime(2026, 9, 5, 18, 12),
        ),
      ];

  testWidgets('suporte: menu com 3 portas e os meus pedidos', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'suporte',
      tela: () => comStores(SuporteScreen(store: SuporteStore.paraTeste(tickets()))),
    );
    expect(find.text('Tenho uma dúvida'), findsOneWidget);
    expect(find.text('Algo não funciona'), findsOneWidget);
    expect(find.text('Reembolso ou cancelar'), findsOneWidget);
    expect(find.textContaining('suporte@emdia.pt'), findsOneWidget);
  });

  testWidgets('suporte_vazio: sem pedidos ainda', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'suporte_vazio',
      tela: () => comStores(SuporteScreen(store: SuporteStore.paraTeste(const []))),
    );
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('suporte_bug: formulário com teclado', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'suporte_bug',
      comTeclado: true,
      tela: () => comStores(SuporteBugScreen(store: SuporteStore.paraTeste(const []))),
    );
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('suporte_reembolso: 3 linhas + abrir subscrições', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'suporte_reembolso',
      tela: () => comStores(SuporteReembolsoScreen(store: SuporteStore.paraTeste(const []))),
    );
    expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
  });
}
