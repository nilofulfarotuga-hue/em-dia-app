// Fábrica de fotos do cofre do imposto e do radar da fidelização.
//
// Duas telas que existem para a mesma coisa — não ser apanhado de surpresa —
// e que partilham a regra mais apertada do design system: UMA cor forte por
// ecrã. Por isso as fotos daqui não são só "o feliz": são os três estados do
// semáforo do cofre e a lista do radar com o passado e o futuro juntos, que é
// onde a regra do laranja se parte se alguém mexer.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/config/app_colors.dart';
import 'package:em_dia/models/cofre_movimento.dart';
import 'package:em_dia/models/fidelizacao.dart';
import 'package:em_dia/models/perfil.dart';
import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/cofre/cofre_screen.dart';
import 'package:em_dia/screens/cofre/novo_movimento.dart';
import 'package:em_dia/screens/radar/radar_screen.dart';
import 'package:em_dia/stores/cofre_store.dart';
import 'package:em_dia/stores/radar_store.dart';
import 'package:em_dia/stores/sessao_store.dart';
import 'package:em_dia/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// "Hoje" fixo, para as fotos serem sempre as mesmas: segunda, 14 de setembro
/// de 2026. Nunca `DateTime.now()` — um radar fotografado com a data de hoje
/// dizia "faltam 12 dias" numa corrida e "faltam 11" na seguinte, e a foto
/// deixava de servir de prova.
final DateTime hojeFoto = DateTime(2026, 9, 14);

/// O ano das contas do cofre, escrito à mão pela mesma razão: a store, sem
/// ano, ia buscar o do relógio da máquina.
const int anoFoto = 2026;

// ---------------------------------------------------------------------------
// Duas stores que o `_apoio.dart` não sabe dar (e não posso lá mexer)
// ---------------------------------------------------------------------------

/// Sessão com dono.
///
/// **Porque é que isto existe:** o `SessaoStoreFalso` do `_apoio.dart` não tem
/// utilizador nenhum (`userId` a nulo), e a primeira coisa que o
/// `CofreScreen` faz é `if (semSessao) ... só a nota azul`. Sem isto, TODAS as
/// fotos do cofre saíam iguais: uma caixa azul a dizer "entra na app". Está
/// escrito no relatório como falha do apoio, não da tela.
class _SessaoComDono extends SessaoStore {
  _SessaoComDono() : super.semServidor();
  @override
  String? get userId => userIdTeste;
  @override
  bool get autenticado => true;
}

/// Cofre já carregado que se recusa a ir ao servidor.
///
/// **Porquê:** o ecrã pede sempre os dados depois da primeira pintura
/// (`carregarSePreciso`). Nas fotos não há Supabase nenhum, essa chamada
/// rebentava por dentro e o ecrã ganhava um aviso vermelho de "sem ligação"
/// por cima do estado que se queria fotografar. Os dados continuam a vir do
/// `CofreStore.paraTeste` da casa — só se cala a ida à rede.
class _CofreParado extends CofreStore {
  // Não podem ser `super.`: o construtor de cima leva também um `ano` que é
  // escrito aqui (anoFoto), e o Dart não deixa misturar as duas coisas.
  // ignore: use_super_parameters
  _CofreParado(
    List<CofreMovimento> movimentos, {
    double entrouParaIrs = 0,
    bool aCarregar = false,
    String? erro,
  }) : super.paraTeste(movimentos,
            entrouParaIrs: entrouParaIrs, ano: anoFoto, aCarregar: aCarregar, erro: erro);

  @override
  Future<void> carregar(String userId, {int? ano}) async {}
  @override
  Future<void> carregarSePreciso(String userId, {int? ano}) async {}
}

// ---------------------------------------------------------------------------
// Os dados
// ---------------------------------------------------------------------------

/// Quem abriu atividade em 2020 já não tem a isenção do 1.º ano: os 12 meses
/// de Segurança Social contam, e o "devias ter" é um número a sério.
Perfil perfilDoCofre() => perfilTeste(
      nome: 'Danilo',
      tipoAtividade: TipoAtividade.tvde,
      dataAbertura: DateTime(2020, 1, 1),
    );

/// O que entrou este ano e conta para o IRS.
///
/// 24.000 € de serviços em 2026 dão, com as regras do espelho local:
///   Segurança Social  24000/4 → 6000/trimestre → 1400 €/mês × 21,4% = 299,60
///                     × 12 meses = 3.595,20 €
///   IRS               24000 × 0,75 = 18.000 € → escalão 4 (24,1 %) − 1.476,58
///                     = 2.861,42 €
///   devias ter        6.456,62 €   (10 % disso = 645,66 €, a régua do laranja)
const double rendimentoDoAno = 24000;

CofreMovimento _mov(String id, DateTime data, double valor,
        {String motivo = 'guardar', String? nota}) =>
    CofreMovimento(
        id: id, userId: userIdTeste, data: data, valor: valor, motivo: motivo, nota: nota);

/// 6.800 € no cofre: mais do que os 6.456,62 € da conta → sobram 343,38 €.
List<CofreMovimento> cofreQueChega() => [
      _mov('m1', DateTime(2026, 3, 15), 1800),
      _mov('m2', DateTime(2026, 5, 20), 2200),
      _mov('m3', DateTime(2026, 7, 20), -480, motivo: 'pagar_imposto', nota: 'ss'),
      _mov('m4', DateTime(2026, 9, 8), 3280),
    ];

/// 6.000 € no cofre: faltam 456,62 €, abaixo da régua dos 10 % → o estado do
/// meio, o ÚNICO que pode pintar de laranja.
List<CofreMovimento> cofreQueFaltaPouco() => [
      _mov('m1', DateTime(2026, 3, 15), 1800),
      _mov('m2', DateTime(2026, 5, 20), 2200),
      _mov('m3', DateTime(2026, 7, 20), -480, motivo: 'pagar_imposto', nota: 'ss'),
      _mov('m4', DateTime(2026, 9, 8), 2480),
    ];

/// 1.500 € no cofre: faltam 4.956,62 € → vermelho. Leva um "precisei" para a
/// lista mostrar também o ícone e o sinal de quem tirou dinheiro de lá.
List<CofreMovimento> cofreQueFaltaMuito() => [
      _mov('m1', DateTime(2026, 4, 2), 1200),
      _mov('m2', DateTime(2026, 6, 18), 900),
      _mov('m3', DateTime(2026, 8, 5), -600, motivo: 'tirar'),
    ];

/// Quatro contratos presos, vistos a 14/09/2026: um que já acabou, o que acaba
/// amanhã (é este que ganha a única cor forte), e dois no futuro. Um sem valor
/// escrito e outro com valor de quatro dígitos, que é onde a coluna do preço
/// aperta o nome.
List<Fidelizacao> contratosDoRadar() => [
      Fidelizacao(
        saidaId: 'f-telemovel',
        nome: 'Telemóvel',
        categoria: 'telemovel',
        fornecedor: 'MEO',
        fimFidelizacao: DateTime(2026, 9, 9),
        diasParaAcabar: -5,
        valorMensal: 29.99,
      ),
      Fidelizacao(
        saidaId: 'f-internet',
        nome: 'Internet e TV de casa',
        categoria: 'internet',
        fornecedor: 'NOS',
        fimFidelizacao: DateTime(2026, 9, 15),
        diasParaAcabar: 1,
        valorMensal: 44.90,
      ),
      Fidelizacao(
        saidaId: 'f-ginasio',
        nome: 'Ginásio',
        categoria: 'ginasio',
        fornecedor: 'Fitness Hut',
        fimFidelizacao: DateTime(2026, 10, 2),
        diasParaAcabar: 18,
        // Sem valor escrito: a app diz isso em vez de inventar um preço.
        valorMensal: null,
      ),
      Fidelizacao(
        saidaId: 'f-saude',
        nome: 'Seguro de saúde da família toda',
        categoria: 'saude',
        fornecedor: 'Médis — Companhia Portuguesa de Seguros de Saúde',
        fimFidelizacao: DateTime(2026, 11, 20),
        diasParaAcabar: 67,
        valorMensal: 1234.56,
      ),
    ];

// ---------------------------------------------------------------------------
// As telas
// ---------------------------------------------------------------------------

Widget _cofre({
  List<CofreMovimento> movimentos = const [],
  double entrouParaIrs = rendimentoDoAno,
  bool aCarregar = false,
  String? erro,
  bool comSessao = true,
}) {
  Widget tela = CofreScreen(hoje: hojeFoto, aoEscreverPrimeira: () {});
  tela = ChangeNotifierProvider<CofreStore>(
    create: (_) => _CofreParado(movimentos,
        entrouParaIrs: entrouParaIrs, aCarregar: aCarregar, erro: erro),
    child: tela,
  );
  if (comSessao) {
    tela = ChangeNotifierProvider<SessaoStore>(create: (_) => _SessaoComDono(), child: tela);
  }
  return embrulhaStores(tela: tela, perfil: perfilDoCofre(), plano: 'trial');
}

Widget _radar({
  List<Fidelizacao> contratos = const [],
  String plano = 'trial',
  String? erro,
}) {
  Widget tela = const RadarScreen();
  if (erro != null) {
    tela = ChangeNotifierProvider<RadarStore>(
      create: (_) => RadarStore.paraTeste(erro: erro),
      child: tela,
    );
  }
  return embrulhaStores(
    tela: tela,
    perfil: perfilDoCofre(),
    plano: plano,
    fidelizacoes: contratos,
  );
}

/// Rola até [chave] ficar à vista.
///
/// **Porque é preciso:** estes dois ecrãs são `ListView`, e o que está abaixo
/// da dobra nem chega a ser construído — um `find` não o encontra e um `tap`
/// rebenta. Não é um capricho do teste: é a prova de que aquilo está mesmo
/// fora do ecrã (ver o relatório).
Future<void> _rolarAte(WidgetTester t, Key chave) async {
  await t.scrollUntilVisible(find.byKey(chave), 200, scrollable: find.byType(Scrollable).first);
  await t.pumpAndSettle();
}

/// Quantas caixas de aviso laranja há no ecrã. É a conta crítica do cofre: só
/// pode haver uma, e só no estado do meio.
int _quantosLaranjas(WidgetTester tester) => tester
    .widgetList<Aviso>(find.byType(Aviso))
    .where((a) => a.tom == Semaforo.amarelo)
    .length;

/// Quantas linhas do radar estão pintadas (laranja de "está a acabar" ou
/// vermelho de "já acabou"). Também só pode ser uma.
int _quantasLinhasPintadas(WidgetTester tester) => tester
    .widgetList<Cartao>(find.byType(Cartao))
    .where((c) => c.cor == AppColors.aVencerClaro || c.cor == AppColors.passouClaro)
    .length;

void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  // -------------------------------------------------------------------------
  // Cofre
  // -------------------------------------------------------------------------

  testWidgets('cofre chega — 6.800 € para 6.456,62 € de conta (verde)', (tester) async {
    await fotografaSuite(tester,
        nome: 'cofre_chega', tela: () => _cofre(movimentos: cofreQueChega()));
    expect(find.byKey(const Key('cofre_cartao')), findsOneWidget);
    expect(find.byKey(const Key('cofre_saldo')), findsOneWidget);
    expect(find.text('6.800,00 €'), findsOneWidget); // o número grande
    expect(find.text('6.456,62 €'), findsWidgets); // o "devias ter"
    // Verde: nem uma caixa laranja no ecrã.
    expect(_quantosLaranjas(tester), 0, reason: 'o estado "chega" não pode ter laranja nenhum');
    expect(find.byWidgetPredicate((w) => w is Aviso && w.tom == Semaforo.verde), findsOneWidget);
  });

  testWidgets('cofre falta pouco — o ÚNICO estado com laranja', (tester) async {
    await fotografaSuite(tester,
        nome: 'cofre_falta_pouco', tela: () => _cofre(movimentos: cofreQueFaltaPouco()));
    expect(find.text('6.000,00 €'), findsOneWidget);
    // A conta crítica da casa: um laranja, e só um.
    expect(_quantosLaranjas(tester), 1,
        reason: 'só a linha do resultado pode ser laranja neste ecrã');
    expect(find.byWidgetPredicate((w) => w is Aviso && w.tom == Semaforo.vermelho), findsNothing);
  });

  testWidgets('cofre falta muito — 1.500 € para 6.456,62 € (vermelho)', (tester) async {
    await fotografaSuite(tester,
        nome: 'cofre_falta_muito', tela: () => _cofre(movimentos: cofreQueFaltaMuito()));
    expect(find.text('1.500,00 €'), findsOneWidget);
    expect(_quantosLaranjas(tester), 0, reason: 'o vermelho não divide o ecrã com o laranja');
    expect(find.byWidgetPredicate((w) => w is Aviso && w.tom == Semaforo.vermelho), findsOneWidget);
  });

  testWidgets('cofre vazio — sem movimentos e sem rendimento escrito', (tester) async {
    await fotografaSuite(tester, nome: 'cofre_vazio', tela: () => _cofre(entrouParaIrs: 0));
    expect(find.byKey(const Key('cofre_vazio')), findsOneWidget);
    // Sem rendimento não há resultado nenhum: nem verde, nem laranja, nem
    // vermelho — inventar um "faltam 0,00 €" era mentir a quem ainda não
    // escreveu nada.
    expect(find.byType(Aviso), findsNothing);
    expect(find.byKey(const Key('cofre_escrever_primeira')), findsOneWidget);
    expect(find.byKey(const Key('cofre_conta')), findsNothing);
  });

  testWidgets('cofre caderno — "como contei" e a lista dos movimentos', (tester) async {
    // O fundo do ecrã (a conta parcela a parcela e as linhas do caderno) nunca
    // aparece nas fotos de cima: fica abaixo da dobra nos três tamanhos. É
    // onde os textos PT-BR são mais compridos, por isso tem foto própria.
    await fotografaSuite(
      tester,
      nome: 'cofre_caderno',
      tela: () => _cofre(movimentos: cofreQueFaltaMuito()),
      antes: (t) => _rolarAte(t, const Key('cofre_conta')),
    );
    expect(find.byKey(const Key('cofre_conta')), findsOneWidget);
    // O caderno mostra o que se pôs e o que se tirou, com sinal antes do
    // número (quem não distingue cores tem de perceber na mesma).
    expect(find.textContaining('+ '), findsWidgets);
    expect(find.textContaining('− '), findsWidgets);
  });

  testWidgets('cofre folha — a folha de "pus de lado" aberta, com teclado', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'cofre_folha',
      tela: () => _cofre(movimentos: cofreQueFaltaPouco()),
      // Tem campo de texto: é das poucas telas onde o teclado faz sentido.
      comTeclado: true,
      antes: (t) async {
        // A folha abre-se UMA vez e fica aberta para as 12 fotos: o
        // `pumpWidget` da fábrica reaproveita o mesmo `MaterialApp`, e com ele
        // o mesmo Navigator — a rota da folha sobrevive à foto seguinte. Se se
        // tocasse outra vez, o toque caía na cortina da folha já aberta e
        // fechava-a. A folha rebuilda-se sozinha quando o tamanho e a língua
        // mudam, que é o que interessa fotografar.
        if (find.byType(NovoMovimento).evaluate().isNotEmpty) return;
        // Rolar antes de tocar não é enfeite: no 360×780 os dois botões ficam
        // ABAIXO da dobra, ao contrário do que o comentário do ecrã promete
        // ("à vista sem rolar o ecrã"). Está no relatório.
        await _rolarAte(t, const Key('cofre_por'));
        await t.tap(find.byKey(const Key('cofre_por')));
        await t.pumpAndSettle();
      },
    );
    expect(find.byType(NovoMovimento), findsOneWidget);
    expect(find.byKey(const Key('novo_movimento_valor')), findsOneWidget);
    expect(find.byKey(const Key('novo_movimento_guardar')), findsOneWidget);
    // As quatro razões estão sempre à vista: quem entrou pelo botão errado
    // corrige com um toque, sem fechar a folha.
    for (final chave in ['guardei', 'paguei_ss', 'paguei_irs', 'precisei']) {
      expect(find.byKey(Key('razao_$chave')), findsOneWidget, reason: 'falta a razão $chave');
    }
  });

  testWidgets('cofre a carregar — esqueleto da primeira leitura', (tester) async {
    await fotografaTela(tester,
        nome: 'cofre_a_carregar', tamanho: tamanhos[1], tela: () => _cofre(aCarregar: true));
    expect(find.byKey(const Key('cofre_cartao')), findsNothing);
    expect(find.byType(Aviso), findsNothing);
  });

  testWidgets('cofre sem rede — falhou antes de ter fosse o que fosse', (tester) async {
    await fotografaTela(tester,
        nome: 'cofre_erro', tamanho: tamanhos[1], tela: () => _cofre(erro: 'SocketException'));
    expect(find.byWidgetPredicate((w) => w is Aviso && w.tom == Semaforo.vermelho), findsOneWidget);
    expect(find.byKey(const Key('cofre_cartao')), findsNothing);
  });

  testWidgets('cofre sem sessão — o que o ecrã mostra a quem não entrou', (tester) async {
    await fotografaTela(tester,
        nome: 'cofre_sem_sessao',
        tamanho: tamanhos[1],
        tela: () => _cofre(movimentos: cofreQueChega(), comSessao: false));
    expect(find.byKey(const Key('cofre_sem_sessao')), findsOneWidget);
    // Azul, não laranja: "entra na app" é informação, não alarme.
    expect(find.byType(Aviso), findsNothing);
  });

  // -------------------------------------------------------------------------
  // Radar
  // -------------------------------------------------------------------------

  testWidgets('radar lista — um acabado, um a acabar amanhã e dois no futuro', (tester) async {
    await fotografaSuite(tester,
        nome: 'radar_lista', tela: () => _radar(contratos: contratosDoRadar()));
    expect(find.byKey(const Key('radar_explicacao')), findsOneWidget);
    expect(find.text('4 contratos'), findsOneWidget);
    // Sem rolar só se veem as três primeiras: a quarta fica abaixo da dobra
    // até no 430×932 (está no relatório).
    for (final id in ['f-telemovel', 'f-internet', 'f-ginasio']) {
      expect(find.byKey(Key('radar_linha_$id')), findsOneWidget, reason: 'falta a linha $id');
    }
    // O destaque é o primeiro que ainda NÃO acabou — o que obriga a pegar no
    // telefone antes de a empresa renovar sozinha.
    expect(find.text('Acaba amanhã'), findsOneWidget);
    // A regra do laranja: quatro linhas, uma cor.
    expect(_quantasLinhasPintadas(tester), 1,
        reason: 'só a linha em destaque pode ter cor de fundo');
    // E a quarta existe mesmo — só está mais abaixo.
    await _rolarAte(tester, const Key('radar_linha_f-saude'));
    expect(find.byKey(const Key('radar_linha_f-saude')), findsOneWidget);
  });

  testWidgets('radar lista, fundo — os contratos de baixo, sem cor nenhuma', (tester) async {
    // A metade de baixo da lista nunca aparece na foto de cima, e é lá que o
    // nome comprido com o preço de quatro dígitos aperta a linha.
    await fotografaSuite(
      tester,
      nome: 'radar_lista_fim',
      tela: () => _radar(contratos: contratosDoRadar()),
      antes: (t) => _rolarAte(t, const Key('radar_linha_f-saude')),
    );
    // A linha de baixo não tem cor de fundo nenhuma — a cor é só do destaque.
    expect(tester.widget<Cartao>(find.byKey(const Key('radar_linha_f-saude'))).cor, isNull);
    // E continua a haver, no máximo, UMA linha pintada em todo o ecrã (no
    // tamanho grande o destaque ainda se vê depois de rolar).
    expect(_quantasLinhasPintadas(tester), lessThanOrEqualTo(1),
        reason: 'nunca mais do que uma cor forte por ecrã');
  });

  testWidgets('radar vazio — ninguém escreveu ainda o fim de contrato nenhum', (tester) async {
    await fotografaSuite(tester, nome: 'radar_vazio', tela: () => _radar());
    expect(find.byType(Vazio), findsOneWidget);
    expect(_quantasLinhasPintadas(tester), 0);
  });

  testWidgets('radar trancado — plano grátis mostra o cadeado do Pro', (tester) async {
    await fotografaSuite(tester,
        nome: 'radar_trancado',
        tela: () => _radar(contratos: contratosDoRadar(), plano: 'free'));
    expect(find.byKey(const Key('radar_cadeado')), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    // Trancado é trancado: nem uma linha de contrato passa.
    expect(find.byKey(const Key('radar_linha_f-internet')), findsNothing);
  });

  testWidgets('radar sem rede — aviso vermelho em vez da lista', (tester) async {
    await fotografaTela(tester,
        nome: 'radar_erro', tamanho: tamanhos[1], tela: () => _radar(erro: 'SocketException'));
    expect(find.byWidgetPredicate((w) => w is Aviso && w.tom == Semaforo.vermelho), findsOneWidget);
    expect(find.byType(Vazio), findsNothing);
  });
}
