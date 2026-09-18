import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/recibos/contrato_seccao.dart';
import 'package:em_dia/screens/recibos/recibos_screen.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// B3 (2026-09-18): o separador Recibos de quem tem contrato («O meu
/// trabalho») e de quem tem empresa («A minha empresa»), e os ecrãs de dentro.
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  final hoje = DateTime(2026, 9, 18);
  final contrato = perfilTeste(nome: 'Rita', tipoAtividade: TipoAtividade.semAtividade, rendimentoMensalEstimado: null)
      .copyWith(tipoTrabalho: TipoTrabalho.contrato, salarioBrutoMensal: 1200, dataNascimento: DateTime(1998, 1, 1));
  final empresa = perfilTeste(nome: 'Paulo', tipoAtividade: TipoAtividade.semAtividade, rendimentoMensalEstimado: null).copyWith(
    tipoTrabalho: TipoTrabalho.empresa,
    empresaTipo: 'sociedade',
    ivaPeriodicidade: 'trimestral',
    contabilistaEmail: 'contas@exemplo.pt',
    pastaContabilistaAtiva: true,
  );

  testWidgets('contrato — «O meu trabalho»: recibo, IRS Jovem, faturas com NIF, desemprego, horas extra', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'recibos_contrato',
      tela: () => comStores(RecibosScreen(hoje: hoje), perfil: contrato),
    );
    expect(find.byKey(const Key('contrato_recibo_vencimento')), findsOneWidget);
    expect(find.byKey(const Key('irs_jovem_card')), findsOneWidget); // 28 anos em 2026
    expect(find.byKey(const Key('faturas_nif_card')), findsOneWidget);
    expect(find.byKey(const Key('ss_card')), findsNothing, reason: 'sem recibos verdes não há Segurança Social de independente');
  });

  testWidgets('contrato — o recibo de vencimento linha a linha (1.200 €, 96,50 € retidos → acerto)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'recibo_vencimento',
      tela: () => comStores(ReciboVencimentoScreen(hoje: hoje, brutoInicial: '1200', retidoInicial: '96,50'), perfil: contrato),
    );
    expect(find.text('971,50 €'), findsOneWidget); // líquido
    expect(find.textContaining('132,00'), findsOneWidget); // SS 11 %
    expect(find.byKey(const Key('recibo_irs_ano')), findsOneWidget);
    expect(find.textContaining('299,49'), findsOneWidget); // acerto a pagar (H03)
  });

  testWidgets('contrato — fiquei sem trabalho: 24 meses → tem direito, 780 €, pedir até 17/12/2026', (tester) async {
    await fotografaTela(
      tester,
      nome: 'desemprego',
      tamanho: tamanhos[1],
      tela: () => comStores(DesempregoScreen(hoje: hoje), perfil: contrato),
    );
    expect(find.textContaining('780,00'), findsOneWidget);
    expect(find.textContaining('17/12/2026'), findsOneWidget);
  });

  testWidgets('contrato — horas extra com 1.200 €: 8,65 / 9,52 / 10,38', (tester) async {
    await fotografaTela(
      tester,
      nome: 'horas_extra',
      tamanho: tamanhos[1],
      tela: () => comStores(HorasExtraScreen(hoje: hoje), perfil: contrato),
    );
    expect(find.text('8,65 €'), findsOneWidget);
    expect(find.text('9,52 €'), findsOneWidget);
    expect(find.text('10,38 €'), findsOneWidget);
  });

  testWidgets('empresa — «A minha empresa»: sociedade, o que vem a seguir, pasta do contabilista', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'recibos_empresa',
      tela: () => embrulhaStores(
        tela: RecibosScreen(hoje: hoje),
        perfil: empresa,
        obrigacoes: [
          obrigacaoTeste(id: 'o1', tipo: 'saft', dataLimite: DateTime(2026, 10, 5), descricao: 'Comunicar às Finanças as faturas de setembro (ficheiro SAF-T).'),
          obrigacaoTeste(id: 'o2', tipo: 'dmr', dataLimite: DateTime(2026, 10, 10), descricao: 'Declaração Mensal de Remunerações (salários de setembro).'),
          obrigacaoTeste(id: 'o3', tipo: 'ss_empresa', dataLimite: DateTime(2026, 10, 25), descricao: 'Pagar à Segurança Social as contribuições de setembro.'),
          obrigacaoTeste(id: 'o4', tipo: 'iva_declaracao', dataLimite: DateTime(2026, 11, 20), descricao: 'Declaração de IVA do 3.º trimestre de 2026.'),
        ],
      ),
    );
    expect(find.byKey(const Key('empresa_card')), findsOneWidget);
    expect(find.byKey(const Key('empresa_calendario')), findsOneWidget);
    expect(find.byKey(const Key('pasta_contabilista_card')), findsOneWidget);
    expect(find.text('contas@exemplo.pt'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });
}
