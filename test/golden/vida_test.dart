// Fábrica de fotos da tela "A minha vida" e das suas três abas (Entra, Sai,
// Sobra), mais as duas folhas que se abrem por cima dela: o registo do
// dinheiro que entrou e o detalhe de uma conta a pagar.
//
// As abas escolhem-se com um TOQUE no separador, dentro do `antes:` — e não
// fotografando `EntradasScreen`/`SaidasScreen` soltas num Scaffold. A razão é
// que a barra de título e a barra de separadores comem ~100 px de altura: uma
// aba fotografada sozinha teria mais espaço do que tem na app, e um estouro
// que só acontece com a barra lá nunca apareceria na foto.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:em_dia/models/entrada.dart';
import 'package:em_dia/models/saida.dart';
import 'package:em_dia/screens/vida/detalhe_conta.dart';
import 'package:em_dia/screens/vida/nova_entrada.dart';
import 'package:em_dia/screens/vida/vida_screen.dart';
import 'package:em_dia/stores/entradas_store.dart';
import 'package:em_dia/stores/resumo_store.dart';
import 'package:em_dia/stores/sessao_store.dart';
import 'package:em_dia/widgets/widgets.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// "Hoje" FIXO, para as fotos serem sempre as mesmas: segunda, 14 de setembro
/// de 2026. Nunca `DateTime.now()` — senão a foto de amanhã não é comparável
/// com a de hoje e o juiz de visão passa a ver diferenças que não existem.
final DateTime hojeFoto = DateTime(2026, 9, 14);

const String _u = userIdTeste;

// ---------------------------------------------------------------- stores

/// Sessão COM dono. A `SessaoStoreFalso` do apoio não tem ninguém autenticado
/// (`userId == null`), e há dois sítios desta tela que fecham a porta a quem
/// não tem sessão: a aba **Sobra** (mostra só "Entra na app…") e o botão
/// "Escrevi que ganhei" (mostra um aviso em vez de abrir a folha). Para
/// fotografar esses dois estados é preciso alguém lá dentro.
class _SessaoComDono extends SessaoStore {
  _SessaoComDono() : super.semServidor();
  @override
  String? get userId => _u;
  @override
  bool get autenticado => true;
}

/// Resumo já cheio e QUIETO.
///
/// A `ResumoScreen` pede os números ao servidor no primeiro quadro. Nos testes
/// não há Supabase: o pedido rebenta, a store guarda o erro, e a foto saía com
/// a barra vermelha de "Sem ligação" por cima de números que estão certos.
/// Aqui o `carregar` não faz nada — os números já vieram postos.
class _ResumoParado extends ResumoStore {
  _ResumoParado({ResumoMes? mes, ResumoAno? ano, bool aCarregar = false})
      : super.paraTeste(mes: mes, ano: ano, aCarregar: aCarregar);
  @override
  Future<void> carregar(String userId, {int? ano}) async {}
  @override
  Future<void> escolherAno(String userId, int ano) async {}
}

// ------------------------------------------------------------------ dados

/// Seis entradas de tipos diferentes, como um mês real de quem anda a recibos
/// verdes: três apps de trabalho (com km e semana toda), um recibo verde,
/// dinheiro à mão que NÃO conta para o IRS, e o salário do mês passado — que
/// entra na lista mas fica de fora do total de setembro.
List<Entrada> entradasDeExemplo() => [
      Entrada(
        id: 'e1',
        userId: _u,
        data: DateTime(2026, 9, 13),
        valor: 412.50,
        tipo: 'plataforma',
        plataforma: 'uber',
        periodo: 'semana',
        km: 940,
      ),
      Entrada(
        id: 'e2',
        userId: _u,
        data: DateTime(2026, 9, 11),
        valor: 180,
        tipo: 'recibo_verde',
        descricao: 'Consultoria à Silva Lda.',
      ),
      Entrada(
        id: 'e3',
        userId: _u,
        data: DateTime(2026, 9, 9),
        valor: 65,
        tipo: 'dinheiro_mao',
        descricao: 'Ajuda numa mudança',
        contaParaIrs: false,
      ),
      Entrada(
        id: 'e4',
        userId: _u,
        data: DateTime(2026, 9, 6),
        valor: 236.80,
        tipo: 'plataforma',
        plataforma: 'bolt',
        periodo: 'semana',
        km: 610,
      ),
      Entrada(
        id: 'e5',
        userId: _u,
        data: DateTime(2026, 9, 2),
        valor: 95.40,
        tipo: 'plataforma',
        plataforma: 'glovo',
        km: 74,
      ),
      // Mês passado: prova que a lista mostra a vida toda mas o número grande
      // do topo só soma o mês de hoje.
      Entrada(
        id: 'e6',
        userId: _u,
        data: DateTime(2026, 8, 28),
        valor: 1100,
        tipo: 'salario',
        periodo: 'mes',
        descricao: 'Meio horário no armazém',
      ),
    ];

/// Cinco contas que se repetem todos os meses, uma de cada meio de pagamento
/// que muda o ecrã: transferência, débito direto, referência Multibanco
/// (com fidelização a acabar) e cartão.
List<Saida> saidasDeExemplo() => [
      const Saida(
        id: 's-renda',
        userId: _u,
        nome: 'Renda da casa',
        categoria: 'renda',
        valor: 450,
        diaDoMes: 8,
        meio: 'transferencia',
      ),
      const Saida(
        id: 's-luz',
        userId: _u,
        nome: 'Luz de casa',
        categoria: 'luz',
        variavel: true,
        diaDoMes: 14,
        meio: 'debito_direto',
        fornecedor: 'EDP',
      ),
      Saida(
        id: 's-net',
        userId: _u,
        nome: 'Internet MEO',
        categoria: 'internet',
        valor: 39.99,
        diaDoMes: 20,
        meio: 'referencia_mb',
        entidade: '21212',
        referencia: '123456789',
        fornecedor: 'MEO',
        // 21 dias: dentro dos 30, logo a linha ganha o aviso "ainda dá para
        // mudar sem multa".
        fimFidelizacao: DateTime(2026, 10, 5),
      ),
      const Saida(
        id: 's-creche',
        userId: _u,
        nome: 'Creche do Tomás',
        categoria: 'creche',
        valor: 210,
        diaDoMes: 5,
        meio: 'debito_direto',
      ),
      const Saida(
        id: 's-ginasio',
        userId: _u,
        nome: 'Ginásio',
        categoria: 'ginasio',
        valor: 24.90,
        diaDoMes: 25,
        meio: 'cartao',
      ),
    ];

/// As contas de setembro, mais uma de agosto que ficou por pagar.
///
/// Estão cá de propósito os quatro estados que mudam o ecrã: **passada**
/// (renda, dia 8), **é hoje** (luz, dia 14), **daqui a dias** (internet,
/// dia 20 e ginásio, dia 25) e **paga** (creche). A luz é de valor variável e
/// ainda não tem número — é o que faz aparecer o "e ainda há contas que não
/// sabem o valor".
List<SaidaPagamento> pagamentosDeExemplo() => [
      // Ficou para trás: agosto por pagar.
      SaidaPagamento(
        id: 'p-ago-ginasio',
        userId: _u,
        saidaId: 's-ginasio',
        mes: DateTime(2026, 8, 1),
        dataLimite: DateTime(2026, 8, 25),
        valor: 24.90,
      ),
      SaidaPagamento(
        id: 'p-creche',
        userId: _u,
        saidaId: 's-creche',
        mes: DateTime(2026, 9, 1),
        dataLimite: DateTime(2026, 9, 5),
        valor: 210,
        estado: 'pago',
        pagoEm: DateTime(2026, 9, 4),
      ),
      SaidaPagamento(
        id: 'p-renda',
        userId: _u,
        saidaId: 's-renda',
        mes: DateTime(2026, 9, 1),
        dataLimite: DateTime(2026, 9, 8),
        valor: 450,
      ),
      // Valor por saber: conta variável ainda sem número.
      SaidaPagamento(
        id: 'p-luz',
        userId: _u,
        saidaId: 's-luz',
        mes: DateTime(2026, 9, 1),
        dataLimite: DateTime(2026, 9, 14),
      ),
      SaidaPagamento(
        id: 'p-net',
        userId: _u,
        saidaId: 's-net',
        mes: DateTime(2026, 9, 1),
        dataLimite: DateTime(2026, 9, 20),
        valor: 39.99,
      ),
      SaidaPagamento(
        id: 'p-ginasio',
        userId: _u,
        saidaId: 's-ginasio',
        mes: DateTime(2026, 9, 1),
        dataLimite: DateTime(2026, 9, 25),
        valor: 24.90,
      ),
    ];

/// O mês que acaba a sobrar: entrou mais do que sai, o cartão de cima fica
/// verde e o único laranja do ecrã é o aviso do que ainda falta pagar.
ResumoMes mesBom() => ResumoMes(
      mes: DateTime(2026, 9, 1),
      entrou: 2180,
      saiu: 940,
      faltaPagarContas: 514.89,
      faltaPagarEstado: 149.80,
      comoAcabaOMes: 2180 - 940 - 514.89 - 149.80,
      noCofre: 620,
    );

/// O mês que acaba a faltar: o cartão de cima fica vermelho e o laranja
/// desaparece (dois alarmes ao mesmo tempo só confundem).
ResumoMes mesMau() => ResumoMes(
      mes: DateTime(2026, 9, 1),
      entrou: 860,
      saiu: 1140,
      faltaPagarContas: 514.89,
      faltaPagarEstado: 149.80,
      comoAcabaOMes: 860 - 1140 - 514.89 - 149.80,
      noCofre: 0,
    );

/// O ano para o IRS: quatro origens de dinheiro e doze meses com buracos.
ResumoAno anoCheio() => const ResumoAno(
      ano: 2026,
      entrouTotal: 18420.50,
      entrouParaIrs: 17960.50,
      porTipo: {
        'plataforma': 9120.0,
        'recibo_verde': 7340.50,
        'dinheiro_mao': 1460.0,
        'subsidio': 500.0,
      },
      porMes: [0.0, 0.0, 1240.50, 1980.0, 2310.0, 2050.0, 2480.0, 2160.0, 989.70, 0.0, 0.0, 0.0],
      saiuTotal: 9210.40,
    );

/// Mês e ano a zeros: é o que faz a aba Sobra convidar a escrever a primeira
/// coisa em vez de mostrar uma parede de "0,00 €".
ResumoMes mesVazio() => ResumoMes(
      mes: DateTime(2026, 9, 1),
      entrou: 0,
      saiu: 0,
      faltaPagarContas: 0,
      faltaPagarEstado: 0,
      comoAcabaOMes: 0,
      noCofre: 0,
    );

ResumoAno anoVazio() => const ResumoAno(
      ano: 2026,
      entrouTotal: 0,
      entrouParaIrs: 0,
      porTipo: {},
      porMes: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      saiuTotal: 0,
    );

// ------------------------------------------------------------------ telas

/// A tela inteira com a vida cheia. Sem sessão de propósito nas abas Entra e
/// Sai: assim nenhuma delas tenta ir buscar nada ao servidor e a foto mostra
/// só os dados que este ficheiro pôs lá.
Widget _telaCheia() => embrulhaStores(
      tela: VidaScreen(hoje: hojeFoto),
      perfil: perfilTeste(nome: 'Danilo'),
      entradas: entradasDeExemplo(),
      saidas: saidasDeExemplo(),
      pagamentos: pagamentosDeExemplo(),
    );

/// Tudo vazio: primeiro dia de quem acabou de instalar a app.
Widget _telaVazia() => embrulhaStores(
      tela: VidaScreen(hoje: hojeFoto),
      perfil: perfilTeste(nome: 'Danilo'),
    );

/// Sem rede na aba Entra: a store traz o erro já posto (o `embrulhaStores` não
/// tem porta para isso, por isso a store entra aqui por cima).
Widget _telaEntradasSemRede() => embrulhaStores(
      tela: ChangeNotifierProvider<EntradasStore>(
        create: (_) => EntradasStore.paraTeste(const [], erro: 'SocketException: sem rede'),
        child: VidaScreen(hoje: hojeFoto),
      ),
      perfil: perfilTeste(nome: 'Danilo'),
    );

/// A tela com sessão e com o resumo já posto — é assim que se fotografa a aba
/// Sobra e a folha de registo.
Widget _telaComDono({ResumoMes? mes, ResumoAno? ano, bool aCarregar = false}) => embrulhaStores(
      tela: MultiProvider(
        providers: [
          ChangeNotifierProvider<SessaoStore>(create: (_) => _SessaoComDono()),
          ChangeNotifierProvider<ResumoStore>(
            create: (_) => _ResumoParado(mes: mes, ano: ano, aCarregar: aCarregar),
          ),
        ],
        child: VidaScreen(hoje: hojeFoto),
      ),
      perfil: perfilTeste(nome: 'Danilo'),
      entradas: entradasDeExemplo(),
      saidas: saidasDeExemplo(),
      pagamentos: pagamentosDeExemplo(),
    );

// ------------------------------------------------------------------ gestos

/// Fecha as folhas que ficaram abertas da foto ANTERIOR.
///
/// CICATRIZ (2026-09-06, ao escrever este ficheiro): a fábrica chama
/// `pumpWidget` outra vez para cada tamanho e cada língua, mas o widget de
/// topo é sempre um `MaterialApp` — o Flutter reaproveita a árvore de
/// elementos e, com ela, o Navigator. A folha aberta na foto 1 continuava lá
/// na foto 2, e o toque no separador ia bater na folha em vez do separador
/// (o `flutter_test` avisava "would not hit test"). As fotos saíam com a
/// folha da medida errada por cima.
Future<void> fecharFolhas(WidgetTester t) async {
  final nav = t.state<NavigatorState>(find.byType(Navigator).first);
  // Limite de 4 voltas: se alguma coisa se recusar a fechar, mais vale a foto
  // sair errada do que o teste ficar preso num ciclo sem fim.
  for (var i = 0; i < 4 && nav.canPop(); i++) {
    nav.pop();
    await t.pumpAndSettle();
  }
}

/// Toca no separador e espera pela animação das abas.
Future<void> Function(WidgetTester) abrirAba(Key aba) => (t) async {
      await fecharFolhas(t);
      await t.tap(find.byKey(aba));
      await t.pumpAndSettle();
    };

void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  // ------------------------------------------------------------ aba Entra

  testWidgets('vida entra cheio — 5 entradas de setembro + o salário de agosto', (tester) async {
    await fotografaSuite(tester, nome: 'vida_entra_cheio', tela: _telaCheia);
    expect(find.byType(VidaScreen), findsOneWidget);
    // 412,50 + 180 + 65 + 236,80 + 95,40 = 989,70. O salário de agosto (1.100 €)
    // está na lista mas NÃO entra no número grande do mês.
    expect(find.byKey(const Key('entradas_total_mes')), findsOneWidget);
    expect(find.text('989,70 €'), findsOneWidget);
    // Os km de quem anda na estrada aparecem na sub-linha.
    expect(find.textContaining('940 km'), findsOneWidget);
  });

  testWidgets('vida entra vazio — quem acabou de instalar a app', (tester) async {
    await fotografaSuite(tester, nome: 'vida_entra_vazio', tela: _telaVazia);
    expect(find.byKey(const Key('entradas_vazio')), findsOneWidget);
    expect(find.text('0,00 €'), findsOneWidget);
    // O botão grande está sempre lá, mesmo sem nada escrito.
    expect(find.byKey(const Key('entradas_novo')), findsOneWidget);
  });

  testWidgets('vida entra sem rede — aviso vermelho por cima da lista', (tester) async {
    // Só no tamanho médio e nas duas línguas: o estado de erro é uma barra de
    // texto, não muda de forma com o tamanho do ecrã.
    for (final locale in locales) {
      await fotografaTela(
        tester,
        nome: 'vida_entra_erro',
        tamanho: tamanhos[1],
        tela: _telaEntradasSemRede,
        locale: locale,
      );
    }
    expect(find.byType(Aviso), findsOneWidget);
  });

  // -------------------------------------------------------------- aba Sai

  testWidgets('vida sai cheio — passada, hoje, por vir, uma paga e uma de agosto', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vida_sai_cheio',
      tela: _telaCheia,
      antes: abrirAba(const Key('aba_sai')),
    );
    // Falta pagar = renda 450 + internet 39,99 + ginásio 24,90 (a luz é
    // variável e ainda não tem valor, por isso não entra na soma).
    expect(find.text('514,89 €'), findsOneWidget);
    // A creche está paga e a renda passou do dia: os dois estados no mesmo ecrã.
    expect(find.text('Creche do Tomás'), findsWidgets);
    expect(find.text('Renda da casa'), findsWidgets);
    // Agosto por pagar aparece na secção "Ficou para trás".
    expect(find.text('Ginásio'), findsWidgets);
  });

  testWidgets('vida sai vazio — nenhuma conta escrita', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vida_sai_vazio',
      tela: _telaVazia,
      antes: abrirAba(const Key('aba_sai')),
    );
    expect(find.byType(Vazio), findsOneWidget);
    expect(find.byKey(const Key('saidas_nova')), findsOneWidget);
    // A porta da caixa de correio fica no fundo mesmo quando não há contas.
    expect(find.byKey(const Key('saidas_atalho_caixa')), findsOneWidget);
  });

  // ------------------------------------------------------------ aba Sobra

  testWidgets('vida sobra bom — o mês acaba a sobrar (cartão verde + aviso laranja)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vida_sobra_bom',
      tela: () => _telaComDono(mes: mesBom(), ano: anoCheio()),
      antes: abrirAba(const Key('aba_sobra')),
    );
    // 2.180 − 940 − 514,89 − 149,80 = 575,31 a sobrar.
    expect(find.byWidgetPredicate((w) => w is SemaforoGrande && w.estado == Semaforo.verde),
        findsOneWidget);
    expect(find.textContaining('575,31 €'), findsWidgets);
  });

  testWidgets('vida sobra mau — o mês acaba a faltar (cartão vermelho, sem laranja)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vida_sobra_mau',
      tela: () => _telaComDono(mes: mesMau(), ano: anoCheio()),
      antes: abrirAba(const Key('aba_sobra')),
    );
    // 860 − 1.140 − 514,89 − 149,80 = −944,69.
    expect(find.byWidgetPredicate((w) => w is SemaforoGrande && w.estado == Semaforo.vermelho),
        findsOneWidget);
    expect(find.textContaining('944,69 €'), findsWidgets);
  });

  testWidgets('vida sobra vazio — convite a escrever a primeira coisa', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vida_sobra_vazio',
      tela: () => _telaComDono(mes: mesVazio(), ano: anoVazio()),
      antes: abrirAba(const Key('aba_sobra')),
    );
    expect(find.byType(Vazio), findsOneWidget);
  });

  testWidgets('vida sobra a carregar — esqueleto cinzento, nunca uma roda a girar', (tester) async {
    for (final locale in locales) {
      await fotografaTela(
        tester,
        nome: 'vida_sobra_carregar',
        tamanho: tamanhos[1],
        tela: () => _telaComDono(aCarregar: true),
        locale: locale,
        antes: abrirAba(const Key('aba_sobra')),
      );
    }
    // Sem números não há semáforo nenhum: só os blocos cinzentos.
    expect(find.byType(SemaforoGrande), findsNothing);
  });

  // ------------------------------------------------ folhas por cima da tela

  testWidgets('vida nova entrada — a folha de registo aberta, com teclado', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vida_nova_entrada',
      tela: () => _telaComDono(mes: mesBom(), ano: anoCheio()),
      // A ÚNICA tela deste ficheiro com campos de texto: é aqui que o teclado
      // pode tapar o botão de guardar.
      comTeclado: true,
      antes: (t) async {
        await fecharFolhas(t);
        await t.tap(find.byKey(const Key('entradas_novo')));
        await t.pumpAndSettle();
      },
    );
    expect(find.byType(NovaEntrada), findsOneWidget);
    expect(find.byKey(const Key('nova_entrada_valor')), findsOneWidget);
    // O perfil é de TVDE, por isso o campo dos km aparece.
    expect(find.byKey(const Key('nova_entrada_guardar')), findsOneWidget);
    // Os oito sítios de onde o dinheiro pode vir, todos na folha.
    expect(find.byKey(const Key('tipo_recibo_verde')), findsOneWidget);
    expect(find.byKey(const Key('tipo_plataforma')), findsOneWidget);
  });

  testWidgets('vida detalhe conta — entidade e referência Multibanco à vista', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vida_detalhe_conta',
      tela: _telaCheia,
      antes: (t) async {
        await fecharFolhas(t);
        await t.tap(find.byKey(const Key('aba_sai')));
        await t.pumpAndSettle();
        // A internet é a 4.ª conta do mês: nos ecrãs pequenos fica abaixo da
        // dobra e numa ListView o que está abaixo da dobra pode nem existir.
        await t.ensureVisible(find.text('Internet MEO').first);
        await t.pumpAndSettle();
        await t.tap(find.text('Internet MEO').first);
        await t.pumpAndSettle();
      },
    );
    expect(find.byType(DetalheConta), findsOneWidget);
    // A caixa da referência: entidade de 5 números e referência de 9,
    // agrupada de três em três para quem a copia à mão.
    expect(find.byType(CaixaReferencia), findsOneWidget);
    expect(find.text('21212'), findsOneWidget);
    expect(find.text('123 456 789'), findsOneWidget);
    expect(find.byKey(const Key('conta_ja_paguei')), findsOneWidget);
  });
}
