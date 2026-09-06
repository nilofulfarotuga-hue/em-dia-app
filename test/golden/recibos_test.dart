import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/rendimento.dart';
import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/recibos/como_emitir_screen.dart';
import 'package:em_dia/screens/recibos/irs_card.dart';
import 'package:em_dia/screens/recibos/recibos_screen.dart';
import 'package:em_dia/stores/dados_store.dart';
import 'package:em_dia/widgets/widgets.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// Tela 2 — Recibos verdes: calculadora com 1000 € (com e sem teclado),
/// Segurança Social em isenção, IRS com rendimentos de exemplo, e o
/// sub-ecrã "Como emitir o recibo". "Hoje" fixo para as fotos serem iguais.
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  final hoje = DateTime(2026, 9, 6);

  // TVDE, abriu a 15/03/2026 (isento até 28/02/2027), isento de IVA, 23% de
  // retenção; três meses registados (média 1.593,33 €).
  List<Rendimento> rendimentos() => [
        Rendimento(id: 'r1', userId: userIdTeste, mes: DateTime(2026, 6, 1), valorBruto: 1450, plataforma: 'uber'),
        Rendimento(id: 'r2', userId: userIdTeste, mes: DateTime(2026, 7, 1), valorBruto: 1720, plataforma: 'bolt'),
        Rendimento(id: 'r3', userId: userIdTeste, mes: DateTime(2026, 8, 1), valorBruto: 1610, plataforma: 'uber', origem: 'foto'),
      ];

  Widget tela() => embrulhaStores(
        tela: RecibosScreen(hoje: hoje),
        perfil: perfilTeste(
          nome: 'Rui',
          tipoAtividade: TipoAtividade.tvde,
          rendimentoMensalEstimado: 1500,
          dataAbertura: DateTime(2026, 3, 15),
        ),
        plano: 'free', // "Ler extrato por foto" aparece com cadeado
        rendimentos: rendimentos(),
      );

  Future<void> irPara(WidgetTester t, Key k) async {
    await t.dragUntilVisible(find.byKey(k), find.byType(ListView), const Offset(0, -250));
    await t.pumpAndSettle(); // deixa a inércia do arrasto parar antes de alinhar
    await Scrollable.ensureVisible(find.byKey(k).evaluate().first, alignment: 0);
    await t.pumpAndSettle();
  }

  testWidgets('recibos: calculadora com 1000 €, com e sem teclado, PT e BR', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'recibos',
      comTeclado: true,
      tela: tela,
      antes: (t) async {
        await t.enterText(find.byKey(const Key('calc_valor')), '1000');
        await t.pump();
      },
    );
    // 1000 € · isento · retenção 23 %: recebes 770 € e 770 € é mesmo teu.
    expect(find.text('770,00 €'), findsNWidgets(2));
    expect(find.text('− 230,00 €'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget); // a frase M10 pronta a copiar
  });

  testWidgets('recibos: Segurança Social em isenção (faltam 6 meses)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'recibos_ss',
      tela: tela,
      antes: (t) => irPara(t, const Key('ss_card')),
    );
    expect(find.textContaining('6 meses'), findsOneWidget);
    expect(find.textContaining('28 de fevereiro de 2027'), findsOneWidget);
  });

  testWidgets('recibos: IRS com rendimentos de exemplo', (tester) async {
    // A secção IRS é a última do ecrã: em ecrãs médios/grandes o scroll acaba
    // antes de ela alinhar ao topo e a cauda do cartão anterior fica cortada
    // na borda (o juiz conta-o como corte). Fotografa-se a secção no mesmo
    // chrome (AppBar + ListView); o ecrã inteiro com SS+IRS está em recibos_ss.
    await fotografaSuite(
      tester,
      nome: 'recibos_irs',
      tela: () => comStores(Scaffold(
        appBar: AppBar(title: const Text('Recibos verdes')),
        body: ListView(
          padding: paddingEcra,
          children: [
            IrsCard(
              regras: RegrasLegais.padrao2026(),
              perfil: perfilTeste(tipoAtividade: TipoAtividade.tvde, rendimentoMensalEstimado: 1500, dataAbertura: DateTime(2026, 3, 15)),
              rendimentos: RendimentosStore.paraTeste(rendimentos()),
              hoje: hoje,
            ),
          ],
        ),
      )),
    );
    // 1.593,33 × 12 = 19.120 € → coletável 14.340 € → 2.080,80 €/ano → 173,40 €/mês
    expect(find.textContaining('173,40 €'), findsOneWidget);
    expect(find.text('450,84 €'), findsNWidgets(3)); // 3 pagamentos por conta
  });

  testWidgets('recibos: como emitir o recibo (sub-ecrã)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'recibos_emitir',
      tela: () => comStores(ComoEmitirScreen(
        isentoIva: true,
        descricaoSugerida: 'Prestação de serviços de transporte de passageiros em veículo descaracterizado (TVDE)',
        mencaoIsencao: RegrasLegais.padrao2026().txt('iva_mencao_isencao'),
      )),
    );
    // O botão fica abaixo da dobra (ListView preguiçosa): rola até ele.
    await tester.dragUntilVisible(find.byType(ElevatedButton), find.byType(ListView), const Offset(0, -300));
    await tester.pump();
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(SelectableText), findsAtLeastNWidgets(1)); // descrição e/ou frase M10
  });
}
