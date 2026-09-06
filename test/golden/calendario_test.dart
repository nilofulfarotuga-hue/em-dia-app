import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/obrigacao.dart';
import 'package:em_dia/screens/calendario/calendario_screen.dart';
import 'package:em_dia/screens/calendario/detalhe_obrigacao.dart';
import 'package:em_dia/screens/calendario/linha_obrigacao.dart';
import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// "Hoje" fixo para as fotos serem sempre iguais: segunda, 14 de setembro de 2026.
final DateTime hojeFoto = DateTime(2026, 9, 14);

const String _u = userIdTeste;

ObrigacaoItem _o(
  String id,
  String tipo,
  String descricao,
  DateTime data, {
  double? valor,
  String estado = 'pendente',
  String? regra,
  String? comoPagar,
}) =>
    ObrigacaoItem(
      id: id,
      userId: _u,
      tipo: tipo,
      descricao: descricao,
      dataLimite: data,
      avisoEm: data,
      valorEstimado: valor,
      estado: estado,
      origemRegra: regra,
      comoPagar: comoPagar,
      pagoEm: estado == 'pago' ? data : null,
    );

/// ~9 obrigações de exemplo: uma passada, uma hoje, duas esta semana (uma já
/// paga), uma este mês e as restantes mais tarde.
List<ObrigacaoItem> obrigacoesDeExemplo() => [
      _o('1', 'ss_pagamento', 'Contribuição de agosto para a Segurança Social.', DateTime(2026, 8, 20),
          valor: 165.30, regra: 'ss_pagamento_dia_fim'),
      _o('2', 'multa', 'Estacionamento na Guarda — notificação n.º 4471.', DateTime(2026, 9, 14),
          valor: 30, regra: 'manual'),
      _o('3', 'ss_pagamento', 'Contribuição de setembro para a Segurança Social.', DateTime(2026, 9, 20),
          valor: 165.30,
          regra: 'ss_pagamento_dia_fim',
          comoPagar:
              'Segurança Social Direta → Conta-corrente → Pagamentos → gera a referência Multibanco e paga na app do banco. Entre o dia 10 e o dia 20.'),
      _o('4', 'seguro', 'Renova o seguro do 12-AB-34. 45 dias antes é a altura de comparar preços.', DateTime(2026, 9, 21),
          valor: 410, estado: 'pago', regra: 'seguro_aviso_dias'),
      _o('5', 'iuc', 'IUC (imposto do carro) do 12-AB-34.', DateTime(2026, 9, 30), valor: 58, regra: 'iuc_regra'),
      _o('6', 'ss_declaracao', 'Declaração trimestral à Segurança Social: o que ganhaste nos últimos 3 meses.',
          DateTime(2026, 10, 31),
          regra: 'ss_declaracao_meses'),
      _o('7', 'ipo', 'Inspeção periódica do 12-AB-34.', DateTime(2026, 11, 12), valor: 35, regra: 'ipo_ligeiros_anos'),
      _o('8', 'residencia', 'Renovar a autorização de residência.', DateTime(2027, 1, 15),
          regra: 'troca_carta_estrangeira_prazo_anos'),
      _o('9', 'tvde_certificado', 'Renovar o certificado de motorista TVDE (vale 5 anos).', DateTime(2027, 3, 1),
          regra: 'tvde_certificado_validade_anos'),
    ];

/// Plano grátis: comprovativos só no Pro (mostra o cadeado no detalhe).
Widget _tela() => embrulhaStores(
      tela: CalendarioScreen(hoje: hojeFoto),
      obrigacoes: obrigacoesDeExemplo(),
      plano: 'free',
    );

void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  testWidgets('calendario: lista por horizontes, 3 tamanhos, PT e BR', (tester) async {
    await fotografaSuite(tester, nome: 'calendario', tela: _tela);
    expect(find.byType(CalendarioScreen), findsOneWidget);
    // Passou primeiro, depois Hoje, Esta semana, Este mês, Mais tarde.
    expect(find.text('PASSOU'), findsOneWidget);
    expect(find.text('HOJE'), findsOneWidget);
    expect(find.text('ESTA SEMANA'), findsOneWidget);
    expect(find.byKey(const ValueKey('obrig-1')), findsOneWidget);
  });

  testWidgets('calendario: detalhe aberto (Segurança Social a 6 dias)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'calendario_detalhe',
      tela: _tela,
      antes: (t) async {
        // O pumpWidget reaproveita a MaterialApp (mesmo tipo, sem key), logo o
        // Navigator — e o sheet da foto anterior — sobrevive. Fecha-se primeiro.
        final nav = t.state<NavigatorState>(find.byType(Navigator).first);
        while (nav.canPop()) {
          nav.pop();
        }
        await t.pumpAndSettle();
        // A ListView constrói as linhas preguiçosamente: rola até aparecer e
        // abre o detalhe pelo próprio callback da linha (o tap por coordenadas
        // falhava o hit-test no tamanho grande, sem abrir o sheet).
        final linha = find.byKey(const ValueKey('obrig-3'));
        await t.scrollUntilVisible(linha, 120, scrollable: find.byType(Scrollable).first);
        await t.pumpAndSettle();
        (t.widget(linha) as LinhaObrigacao).aoTocar();
        await t.pumpAndSettle();
        expect(find.byType(DetalheObrigacao), findsOneWidget, reason: 'o detalhe tem de estar aberto em todas as fotos');
      },
    );
    expect(find.byType(DetalheObrigacao), findsOneWidget);
    expect(find.text('Já paguei'), findsOneWidget);
  });
}
