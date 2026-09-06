import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/carro.dart';
import 'package:em_dia/models/obrigacao.dart';
import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/carro/carro_screen.dart';
import 'package:em_dia/screens/carro/lembretes_carro.dart';
import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// "Hoje" fixo para as fotos serem sempre iguais: segunda, 14 de setembro de 2026.
final DateTime hojeFoto = DateTime(2026, 9, 14);

const String _u = userIdTeste;
const String _carroId = 'c-aa11bb';

/// AA-11-BB, de dezembro de 2021, gasolina 1 199 cc, TVDE, 84 120 km.
Carro carroDeExemplo() => Carro(
      id: _carroId,
      userId: _u,
      nome: 'O Clio',
      matricula: 'AA-11-BB',
      dataMatricula: DateTime(2021, 12, 15),
      mesMatricula: 12,
      anoMatricula: 2021,
      usoTvde: true,
      combustivel: Combustivel.gasolina,
      cilindradaCc: 1199,
      co2: 118,
      seguradora: 'Fidelidade',
      seguroRenovaEm: DateTime(2026, 10, 4), // 20 dias
      ultimaIpo: DateTime(2025, 12, 20),
      kmAtual: 84120,
      cartaValidade: DateTime(2031, 5, 20),
      revisaoKm: 90000,
    );

/// As obrigações que o servidor já gerou para este carro: IPO a 40 dias,
/// seguro a 20 dias, IUC a 100 dias.
List<ObrigacaoItem> obrigacoesDoCarro() => [
      obrigacaoTeste(id: 'o-ipo', tipo: 'ipo', dataLimite: DateTime(2026, 10, 24), valor: 35, descricao: 'Inspeção periódica do AA-11-BB.'),
      obrigacaoTeste(id: 'o-seguro', tipo: 'seguro', dataLimite: DateTime(2026, 10, 4), valor: 410, descricao: 'Renova o seguro do AA-11-BB.'),
      obrigacaoTeste(id: 'o-iuc', tipo: 'iuc', dataLimite: DateTime(2026, 12, 23), valor: 58.40, descricao: 'IUC (imposto do carro) do AA-11-BB.'),
    ].map((o) => ObrigacaoItem(
          id: o.id,
          userId: o.userId,
          carroId: _carroId,
          tipo: o.tipo,
          descricao: o.descricao,
          dataLimite: o.dataLimite,
          avisoEm: o.avisoEm,
          valorEstimado: o.valorEstimado,
        )).toList();

/// 3 depósitos cheios com km: 920 km e 125,60 € entre o 1.º e o 3.º → 0,14 €/km.
List<Abastecimento> abastecimentosDeExemplo() => [
      Abastecimento(id: 'a1', carroId: _carroId, data: DateTime(2026, 8, 28), litros: 40, valorTotal: 62.40, km: 83200),
      Abastecimento(
          id: 'a2',
          carroId: _carroId,
          data: DateTime(2026, 9, 5),
          litros: 38.5,
          valorTotal: 60.10,
          km: 83700,
          posto: 'Galp Guarda',
          comNif: true),
      Abastecimento(id: 'a3', carroId: _carroId, data: DateTime(2026, 9, 12), litros: 42, valorTotal: 65.50, km: 84120),
    ];

List<DespesaCarro> despesasDeExemplo() => [
      DespesaCarro(id: 'd1', carroId: _carroId, data: DateTime(2026, 7, 10), tipo: 'seguro', valor: 410, comNif: true),
      DespesaCarro(
          id: 'd2',
          carroId: _carroId,
          data: DateTime(2026, 9, 8),
          tipo: 'portagem',
          valor: 12.50,
          descricao: 'A23, Guarda → Covilhã',
          comNif: true,
          dataLimite: DateTime(2026, 9, 29),
          pago: false),
    ];

Widget _telaComCarro() => embrulhaStores(
      tela: CarroScreen(hoje: hojeFoto),
      obrigacoes: obrigacoesDoCarro(),
      carros: [carroDeExemplo()],
      abastecimentos: abastecimentosDeExemplo(),
      despesas: despesasDeExemplo(),
    );

Widget _telaSemCarro() => embrulhaStores(tela: CarroScreen(hoje: hojeFoto));

/// Plano grátis com o limite de 1 carro já usado: "Adicionar carro" mostra o cadeado.
Widget _telaCadeado() => embrulhaStores(
      tela: CarroScreen(hoje: hojeFoto),
      obrigacoes: obrigacoesDoCarro(),
      carros: [carroDeExemplo()],
      abastecimentos: abastecimentosDeExemplo(),
      despesas: despesasDeExemplo(),
      plano: 'free',
      limites: const {'carros': 1},
    );

void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  testWidgets('carro: AA-11-BB com lembretes, abastecimentos e despesas, 3 tamanhos, PT e BR', (tester) async {
    await fotografaSuite(tester, nome: 'carro', tela: _telaComCarro);
    expect(find.byType(CarroScreen), findsOneWidget);
    expect(find.text('O Clio'), findsOneWidget);
    // Lembretes ordenados por data: seguro (20 d) → inspeção (40 d) → IUC (100 d) → carta → revisão (por km).
    expect(find.byKey(const ValueKey('lembrete-seguro')), findsOneWidget);
    expect(find.byKey(const ValueKey('lembrete-ipo')), findsOneWidget);
    expect(find.byKey(const ValueKey('lembrete-iuc')), findsOneWidget);
    final seguro = tester.widget<CartaoLembrete>(find.byKey(const ValueKey('lembrete-seguro')));
    final ipo = tester.widget<CartaoLembrete>(find.byKey(const ValueKey('lembrete-ipo')));
    final iuc = tester.widget<CartaoLembrete>(find.byKey(const ValueKey('lembrete-iuc')));
    expect(seguro.lembrete.dias(hojeFoto), 20);
    expect(ipo.lembrete.dias(hojeFoto), 40);
    expect(iuc.lembrete.dias(hojeFoto), 100);
    // Seguro dentro dos 45 dias fica laranja; inspeção a 40 dias (aviso aos 30) e IUC ficam verdes.
    expect(seguro.lembrete.cor(hojeFoto), const Color(0xFFF97316));
    expect(ipo.lembrete.cor(hojeFoto), const Color(0xFF16A34A));
    expect(iuc.lembrete.cor(hojeFoto), const Color(0xFF16A34A));
    expect(iuc.lembrete.obrigacao, isNotNull, reason: 'abre o detalhe da obrigação do calendário');
  });

  /// Rola a lista até [chave] ficar alinhada ao topo (a ListView constrói
  /// preguiçosamente; o `scrollUntilVisible` termina com `ensureVisible`, que
  /// alinha ao topo — por isso rola-se até ao TÍTULO da secção, para o cartão
  /// inteiro ficar por baixo).
  Future<void> Function(WidgetTester) rolarAte(Key chave) => (t) async {
        await t.scrollUntilVisible(find.byKey(chave), 200, scrollable: find.byType(Scrollable).first);
        await t.pumpAndSettle();
      };

  testWidgets('carro: abastecimentos (resumo do mês + linha do tempo)', (tester) async {
    await fotografaSuite(tester,
        nome: 'carro_abastecimentos', tela: _telaComCarro, antes: rolarAte(const ValueKey('sec-abastecimentos')));
    // 3 depósitos cheios: 920 km, 125,60 € → 0,14 €/km e 8,8 L/100 km.
    expect(find.text('0,14'), findsOneWidget);
    expect(find.text('8,8'), findsOneWidget);
  });

  testWidgets('carro: despesas com NIF + portagens e multas por pagar', (tester) async {
    await fotografaSuite(tester, nome: 'carro_despesas', tela: _telaComCarro, antes: rolarAte(const ValueKey('sec-despesas')));
    // Total do ano com NIF: 410 + 12,50.
    expect(find.text('422,50 €'), findsOneWidget);
  });

  testWidgets('carro: sem carro (estado vazio + botão)', (tester) async {
    await fotografaSuite(tester, nome: 'carro_vazio', tela: _telaSemCarro);
    expect(find.byType(CarroScreen), findsOneWidget);
    expect(find.text('Adicionar carro'), findsOneWidget);
  });

  testWidgets('carro: plano grátis com 1 carro mostra o cadeado em "Adicionar carro"', (tester) async {
    await fotografaSuite(tester, nome: 'carro_cadeado', tela: _telaCadeado);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
  });
}
