// F-OLHO — fábrica de fotos de duas telas: "Vale a pena esta corrida?" e
// "Fala comigo".
//
// São as duas portas da app: uma para quem escreve números, outra para quem
// não escreve nada. Por isso interessam os estados feios tanto como o feliz —
// a corrida que fica a perder, o carro que ainda não tem números, o telemóvel
// sem microfone, o assistente sem rede e o cadeado do plano grátis.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/carro.dart';
import 'package:em_dia/models/mensagem_ia.dart';
import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/fala/fala_screen.dart';
import 'package:em_dia/screens/vale_a_pena/vale_a_pena_screen.dart';
import 'package:em_dia/services/ouvir.dart';
import 'package:em_dia/stores/ia_store.dart';
import 'package:em_dia/widgets/widgets.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// "Hoje" FIXO, para as fotos serem sempre iguais: segunda, 14 de setembro de
/// 2026. Nunca `DateTime.now()` — senão a foto de amanhã não é igual à de hoje
/// e o juiz de visão nunca compara nada.
final DateTime hojeFoto = DateTime(2026, 9, 14);

const String _carroId = 'c-vale-01';

// ───────────────────────────── Vale a pena ─────────────────────────────

/// O carro de quem faz TVDE: gasolina, para o ecrã falar de litros e não de
/// kWh (o caso do elétrico troca os rótulos e fica para outra foto).
Carro carroDoVale() => Carro(
      id: _carroId,
      userId: userIdTeste,
      nome: 'O Clio',
      matricula: 'AA-11-BB',
      dataMatricula: DateTime(2021, 12, 15),
      mesMatricula: 12,
      anoMatricula: 2021,
      usoTvde: true,
      combustivel: Combustivel.gasolina,
      cilindradaCc: 1199,
      kmAtual: 84120,
    );

/// Três depósitos cheios com quilómetros: dão 8,8 L/100 km de consumo e
/// 1,560 €/L do último abastecimento. É daqui que a tela preenche sozinha os
/// dois campos do carro — e é por isso que existem estas linhas.
List<Abastecimento> abastecimentosDoVale() => [
      Abastecimento(id: 'a1', carroId: _carroId, data: DateTime(2026, 8, 28), litros: 40, valorTotal: 62.40, km: 83200),
      Abastecimento(id: 'a2', carroId: _carroId, data: DateTime(2026, 9, 5), litros: 38.5, valorTotal: 60.10, km: 83700),
      Abastecimento(id: 'a3', carroId: _carroId, data: DateTime(2026, 9, 12), litros: 42, valorTotal: 65.50, km: 84120),
    ];

/// Perfil aberto em 2023: já passou o primeiro ano, logo PAGA Segurança
/// Social. É de propósito — com a isenção do 1.º ano a linha da SS ia a zero e
/// a foto não mostrava a conta toda.
Widget _valeComCarro() => embrulhaStores(
      tela: ValeAPenaScreen(hoje: hojeFoto),
      perfil: perfilTeste(dataAbertura: DateTime(2023, 5, 10)),
      carros: [carroDoVale()],
      abastecimentos: abastecimentosDoVale(),
    );

/// Sem carro nenhum: os campos do consumo e do preço nascem vazios e a tela
/// tem de avisar que lhe faltam dois números.
Widget _valeSemCarro() => embrulhaStores(
      tela: ValeAPenaScreen(hoje: hojeFoto),
      perfil: perfilTeste(dataAbertura: DateTime(2023, 5, 10)),
    );

/// O campo "Quanto te pagam" é o único sem `Key` na tela — é um [CampoValor],
/// e apanha-se pelo tipo (não por índice, que muda quando alguém acrescenta um
/// campo acima). Fica dito como RISCO: se um dia entrar um segundo [CampoValor]
/// nesta tela, este apontador passa a apanhar dois e o teste rebenta.
Finder get _campoPagam =>
    find.descendant(of: find.byType(CampoValor), matching: find.byType(TextField));

/// Volta a lista ao topo.
///
/// A fábrica tira 6 (ou 12) fotos seguidas com `pumpWidget`, e o Flutter
/// REAPROVEITA o `State` entre elas — logo a posição do scroll da foto anterior
/// vinha atrás. Na 2.ª foto o campo de cima já estava fora do ecrã, a `ListView`
/// nem o construía, e o `enterText` rebentava com "Bad state: No element".
Future<void> _voltarAoTopo(WidgetTester tester) async {
  final posicao = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
  if (posicao.pixels != 0) {
    posicao.jumpTo(0);
    await tester.pump();
  }
}

/// Escreve uma corrida nos campos. Devolve um `antes:` para a fábrica.
Future<void> Function(WidgetTester) escreveCorrida({
  required String pagam,
  required String km,
  String? minutos,
  bool rolarAteAResposta = false,
}) =>
    (tester) async {
      await _voltarAoTopo(tester);
      await tester.enterText(_campoPagam, pagam);
      await tester.enterText(find.byKey(const Key('vp_km')), km);
      if (minutos != null) {
        await tester.enterText(find.byKey(const Key('vp_minutos')), minutos);
      }
      await tester.pump();
      if (rolarAteAResposta) {
        // O cartão da resposta nasce abaixo da dobra nos três tamanhos. Rola-se
        // uma distância FIXA (nada de `ensureVisible`, que encosta o alvo ao
        // topo e corta-lhe o cabeçalho) para a foto trazer o cartão inteiro.
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }
    };

/// Desenha a tela outra vez em PT-PT, para os `expect` poderem falar português
/// de Portugal.
///
/// A fábrica acaba sempre em PT-BR (é o último `locale` do ciclo), por isso o
/// que fica no ecrã quando o `fotografaSuite` devolve é o brasileiro. Sem isto,
/// `find.text('Falar')` procurava um texto que já não estava lá.
Future<void> conferirEmPortugues(
  WidgetTester tester,
  Widget Function() tela, {
  Future<void> Function(WidgetTester)? antes,
}) async {
  await tester.pumpWidget(embrulha(tela(), const Locale('pt')));
  await tester.pump(const Duration(milliseconds: 100));
  if (antes != null) await antes(tester);
  await tester.pump(const Duration(milliseconds: 300));
}

// ─────────────────────────────── Fala ───────────────────────────────

/// Uma conversa já feita: a pergunta da pessoa e a resposta do Em Dia.
///
/// A pergunta é de propósito DIFERENTE dos três exemplos da tela — esses
/// continuam no ecrã por baixo da resposta, e uma pergunta igual a um exemplo
/// aparecia duas vezes na foto.
List<MensagemIa> conversaDeExemplo() => [
      MensagemIa.utilizador('Tenho de guardar dinheiro para o IVA?',
          quando: DateTime(2026, 9, 14, 10, 30)),
      MensagemIa.emDia(
        'Este mês tens duas coisas a pagar. A Segurança Social, 87,54 €, '
        'até dia 20. E o IVA do trimestre, 412,00 €, até dia 20 de outubro. '
        'Guarda já o do IVA — é o que costuma apanhar toda a gente de surpresa.',
        quando: DateTime(2026, 9, 14, 10, 30),
      ),
    ];

/// Constrói a tela da fala com o ouvido e a conversa que se quiserem.
/// `aoAbrirPlano` é vazio de propósito: numa foto ninguém navega para lado
/// nenhum, e sem isto o cadeado empurrava a `PlanoScreen` para cima da foto.
Widget _fala({
  Ouvir? ouvir,
  IaStore? store,
  String plano = 'trial',
}) =>
    embrulhaStores(
      plano: plano,
      perfil: perfilTeste(),
      tela: FalaScreen(
        ouvir: ouvir ?? Ouvir.paraTeste(),
        store: store ?? IaStore.paraTeste(const []),
        aoAbrirPlano: () {},
      ),
    );

void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  // ══════════════════════ Vale a pena esta corrida? ══════════════════════

  /// O convite. É a primeira coisa que qualquer pessoa vê ao abrir a app, e é
  /// a foto que prova que o ecrã vazio não é um ecrã morto: já traz o carro
  /// preenchido e a frase "escreve para ver".
  testWidgets('vale_vazio — antes de escrever nada', (tester) async {
    await fotografaSuite(tester, nome: 'vale_vazio', tela: _valeComCarro);
    await conferirEmPortugues(tester, _valeComCarro);
    expect(find.byType(ValeAPenaScreen), findsOneWidget);
    // Sem números escritos não há resposta nenhuma: só o convite.
    expect(find.text('Escreve quanto te pagam e os quilómetros. A conta aparece aqui.'),
        findsOneWidget);
    // Os dois campos do carro já vêm preenchidos pelos abastecimentos —
    // é isto que poupa a conta a quem não sabe o consumo de cor.
    expect(find.text('8,8'), findsOneWidget);
    expect(find.text('1,560'), findsOneWidget);
    // E o desgaste nasce com o palpite da casa (5 cêntimos por km).
    expect(find.text('0,05'), findsOneWidget);
  });

  /// A corrida que compensa: 18 € por 12 km em 25 minutos.
  /// 18,00 − 1,65 (combustível) − 0,60 (desgaste) − 2,70 (SS) − 4,14 (IRS
  /// retido a 23 %) = 8,91 €, que é 49 % do que pagam → cartão VERDE.
  /// Com teclado também: é a tela onde a pessoa está mesmo a escrever, e é com
  /// o teclado aberto que o espaço encolhe e o layout parte, se partir.
  testWidgets('vale_sobra_bem — corrida que compensa (cartão verde)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vale_sobra_bem',
      tela: _valeComCarro,
      comTeclado: true,
      antes: escreveCorrida(pagam: '18', km: '12', minutos: '25'),
    );
    await conferirEmPortugues(tester, _valeComCarro,
        antes: escreveCorrida(pagam: '18', km: '12', minutos: '25'));
    expect(find.text('Esta corrida vale a pena.'), findsOneWidget);
    expect(find.byKey(const Key('vp_sobra')), findsOneWidget);
    expect(find.text('8,91 €'), findsWidgets);
  });

  /// A mesma corrida, com o ecrã rolado até ao cartão da resposta caber
  /// inteiro. Sem esta foto, o juiz de visão só via os campos: o cartão que é
  /// a razão de a tela existir ficava sempre fora do enquadramento.
  testWidgets('vale_sobra_bem_resposta — o cartão verde inteiro', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vale_sobra_bem_resposta',
      tela: _valeComCarro,
      antes: escreveCorrida(pagam: '18', km: '12', minutos: '25', rolarAteAResposta: true),
    );
    await conferirEmPortugues(tester, _valeComCarro,
        antes: escreveCorrida(pagam: '18', km: '12', minutos: '25', rolarAteAResposta: true));
    // "Para onde foi o dinheiro", parcela a parcela. O sinal de menos é o
    // MESMO do resto do cartão: o hífen que o moeda() usa. Era o menos
    // tipográfico (U+2212) e viam-se dois traços de larguras diferentes no
    // mesmo cartão — corrigido a 2026-09-06 depois de a foto o mostrar.
    expect(find.text('Pagam-te'), findsOneWidget);
    expect(find.text('18,00 €'), findsOneWidget);
    expect(find.text('-1,65 €'), findsOneWidget); // combustível
    expect(find.text('-0,60 €'), findsOneWidget); // desgaste
    expect(find.text('-2,70 €'), findsOneWidget); // Segurança Social
    expect(find.text('-4,14 €'), findsOneWidget); // IRS retido na hora
    // 8,91 € em 25 minutos = 21,38 € por hora.
    expect(find.text('São 21,38 € por hora'), findsOneWidget);
  });

  /// A corrida que fica a perder: 6 € por 30 km. O combustível e o desgaste
  /// sozinhos levam 5,62 €, e ainda falta o Estado → sobra −1,90 €, cartão
  /// VERMELHO. É a foto que justifica a app inteira.
  testWidgets('vale_perde — corrida que tira dinheiro do bolso (cartão vermelho)',
      (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vale_perde',
      tela: _valeComCarro,
      antes: escreveCorrida(pagam: '6', km: '30', minutos: '45', rolarAteAResposta: true),
    );
    await conferirEmPortugues(tester, _valeComCarro,
        antes: escreveCorrida(pagam: '6', km: '30', minutos: '45', rolarAteAResposta: true));
    expect(find.text('Esta corrida tira-te dinheiro do bolso.'), findsOneWidget);
    expect(find.text('-1,90 €'), findsWidgets);
  });

  /// Quem ainda não tem carro nenhum na app não tem consumo nem preço do
  /// combustível — e sem esses dois números não há conta possível. A tela tem
  /// de o DIZER, e é o único laranja que pode aparecer neste ecrã.
  testWidgets('vale_falta_carro — sem preço nem consumo, o aviso laranja', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vale_falta_carro',
      tela: _valeSemCarro,
      antes: escreveCorrida(pagam: '18', km: '12'),
    );
    await conferirEmPortugues(tester, _valeSemCarro, antes: escreveCorrida(pagam: '18', km: '12'));
    expect(find.byType(Aviso), findsOneWidget);
    expect(
        find.text(
            'Faltam duas coisas do teu carro: quanto gasta aos 100 quilómetros e o preço do combustível. Escreve-as aqui em baixo.'),
        findsOneWidget);
    // Sem os dois números não há cartão de resposta nenhum.
    expect(find.byKey(const Key('vp_sobra')), findsNothing);
  });

  // ═══════════════════════════ Fala comigo ═══════════════════════════

  /// Parado, à espera. O botão grande e os três exemplos — é tudo o que uma
  /// pessoa que não sabe o que perguntar tem para se agarrar.
  testWidgets('fala_parado — o botão grande e os três exemplos', (tester) async {
    await fotografaSuite(tester, nome: 'fala_parado', tela: _fala);
    await conferirEmPortugues(tester, _fala);
    expect(find.byKey(const Key('fala_microfone')), findsOneWidget);
    expect(find.byKey(const Key('fala_exemplo_1')), findsOneWidget);
    expect(find.byKey(const Key('fala_exemplo_2')), findsOneWidget);
    expect(find.byKey(const Key('fala_exemplo_3')), findsOneWidget);
    // O botão redondo NÃO tem letras: o rótulo "Falar" é só a etiqueta de
    // acessibilidade (`Semantics`). Quem lê o ecrã guia-se pela frase de baixo.
    expect(find.text('Carrega no botão e fala. Larga quando acabares.'), findsOneWidget);
  });

  /// A ouvir, com as palavras já a cair no ecrã. É a prova de que a app está
  /// mesmo a apanhar a voz — sem isto, um botão a pulsar não diz nada a
  /// ninguém. O volume a meio deixa o anel aberto na foto.
  testWidgets('fala_a_ouvir — palavras a aparecer enquanto a pessoa fala', (tester) async {
    tela() => _fala(
          ouvir: Ouvir.paraTeste(
            estado: EstadoOuvir.aOuvir,
            texto: 'quanto é que eu tenho de pagar de segurança social este mês',
            volume: 0.55,
          ),
        );
    await fotografaSuite(tester, nome: 'fala_a_ouvir', tela: tela);
    await conferirEmPortugues(tester, tela);
    expect(find.byKey(const Key('fala_palavras')), findsOneWidget);
    expect(find.text('Estou a ouvir-te. Larga o dedo, ou toca outra vez, quando acabares.'),
        findsOneWidget);
    // Enquanto ouve, os exemplos saem da frente: o ecrã é da voz.
    expect(find.byKey(const Key('fala_exemplo_1')), findsNothing);
  });

  /// Pergunta e resposta na tela. A resposta é longa de propósito (é o que a
  /// IA devolve na vida real) — é o texto comprido que faz o cartão crescer e
  /// empurrar o botão do microfone para fora.
  testWidgets('fala_com_resposta — a pergunta e a resposta', (tester) async {
    tela() => _fala(store: IaStore.paraTeste(conversaDeExemplo()));
    await fotografaSuite(tester, nome: 'fala_com_resposta', tela: tela);
    await conferirEmPortugues(tester, tela);
    expect(find.byKey(const Key('fala_resposta')), findsOneWidget);
    expect(find.text('Perguntaste-me isto:'), findsOneWidget);
    expect(find.text('Tenho de guardar dinheiro para o IVA?'), findsOneWidget);
  });

  /// A carregar: a pergunta já saiu e a resposta ainda não chegou. Sem esta
  /// foto ninguém sabe se o ecrã de espera cabe ou se estica.
  testWidgets('fala_a_pensar — a espera pela resposta', (tester) async {
    tela() => _fala(
          store: IaStore.paraTeste(
            [MensagemIa.utilizador('O que é o IVA?', quando: DateTime(2026, 9, 14, 10, 30))],
            aPensar: true,
          ),
        );
    await fotografaSuite(tester, nome: 'fala_a_pensar', tela: tela);
    await conferirEmPortugues(tester, tela);
    expect(find.byKey(const Key('fala_a_pensar')), findsOneWidget);
    expect(find.text('Já ouvi. Estou a pensar na resposta…'), findsOneWidget);
  });

  /// Erro: o telemóvel ficou sem rede a meio. O aviso é VERMELHO (e é o único
  /// elemento de cor no ecrã) — a pergunta não chegou a lado nenhum.
  testWidgets('fala_sem_rede — o erro de rede', (tester) async {
    tela() => _fala(store: IaStore.paraTeste(const [], erro: 'sem rede'));
    await fotografaSuite(tester, nome: 'fala_sem_rede', tela: tela);
    await conferirEmPortugues(tester, tela);
    expect(find.byType(Aviso), findsOneWidget);
  });

  /// O plano grátis esgotou as perguntas do mês: cartão do cadeado dentro da
  /// conversa, e o botão do microfone apagado.
  testWidgets('fala_limite — acabaram as perguntas do mês', (tester) async {
    tela() => _fala(store: IaStore.paraTeste(const [], limite: true, usadas: 10, limiteValor: 10));
    await fotografaSuite(tester, nome: 'fala_limite', tela: tela);
    await conferirEmPortugues(tester, tela);
    expect(find.text('Acabaram as perguntas deste mês.'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
  });

  /// Telemóvel sem microfone (a pessoa disse "não", ou nunca lhe perguntaram).
  /// O recado é AZUL de propósito: não é urgência nenhuma e culpar o aparelho
  /// a laranja fazia a pessoa achar que fez asneira.
  testWidgets('fala_sem_microfone — o recado de que não há microfone', (tester) async {
    tela() => _fala(ouvir: Ouvir.paraTeste(estado: EstadoOuvir.semPermissao));
    await fotografaSuite(tester, nome: 'fala_sem_microfone', tela: tela);
    await conferirEmPortugues(tester, tela);
    expect(find.byKey(const Key('fala_sem_microfone')), findsOneWidget);
    expect(
        find.text(
            'Sem o microfone não te consigo ouvir. Podes escrever a pergunta — respondo na mesma.'),
        findsOneWidget);
  });

  /// O caminho de quem escreve: o mesmo telemóvel sem microfone, já com o
  /// bloco de escrita à frente. É o ÚNICO estado desta tela com campo de
  /// texto — por isso é o único que leva teclado.
  testWidgets('fala_escrita — o caminho de quem tem de escrever', (tester) async {
    tela() => _fala(ouvir: Ouvir.paraTeste(estado: EstadoOuvir.semPermissao));
    // O `State` da tela sobrevive entre fotos, e com ele o modo de escrita: da
    // 2.ª foto em diante o botão "Prefiro escrever" já não existe. Por isso só
    // se toca nele quando ele lá está.
    Future<void> passarAEscrita(WidgetTester t) async {
      final botao = find.byKey(const Key('fala_prefiro_escrever'));
      if (botao.evaluate().isEmpty) return;
      await t.tap(botao);
      await t.pump();
    }

    await fotografaSuite(
      tester,
      nome: 'fala_escrita',
      tela: tela,
      comTeclado: true,
      antes: passarAEscrita,
    );
    await conferirEmPortugues(tester, tela, antes: passarAEscrita);
    expect(find.byKey(const Key('fala_campo_escrita')), findsOneWidget);
    expect(find.byKey(const Key('fala_voltar_a_falar')), findsOneWidget);
  });

  /// Plano grátis: a tela inteira baça por trás do cadeado, com a linha que
  /// diz o que é preciso para a abrir. É funcionalidade do Pro.
  testWidgets('fala_trancado — cadeado do plano grátis', (tester) async {
    tela() => _fala(plano: 'free');
    await fotografaSuite(tester, nome: 'fala_trancado', tela: tela);
    await conferirEmPortugues(tester, tela);
    expect(find.byType(Cadeado), findsOneWidget);
    expect(find.text('Ativa o Pro para falares com a app.'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
  });
}
