// BLOCO 8 (2026-09-18) — Testes de integração: abrir TODOS os ecrãs da app.
//
// Duas partes:
//   1. Os 4 caminhos do onboarding («Trabalhas como?»: recibos verdes, contrato,
//      os dois, empresa), passo a passo, com toques a sério nas opções — cada
//      passo é um ecrã visto.
//   2. A app inteira pelo modo exemplo (a Maria, sem servidor): as 6 abas do
//      fundo, os ecrãs de dentro de cada uma, os 12 acessos do Mais, e as
//      folhas (detalhe de obrigação, nova entrada, palavras difíceis…). Mais os
//      ecrãs que a Maria não tem (contrato, empresa, entrada, admin) com stores
//      falsas.
//
// Sem servidor de propósito: as stores são as do exemplo/das fotos, iguais às
// dos golden. O que se prova aqui é que cada ecrã ABRE e mostra o que promete,
// no telemóvel (AVD emdia, com gravação) e na VM.
//
// Correr:  flutter test test/integracao                                        (VM, rápido, no CI)
//          flutter test integration_test/todos_os_ecras_test.dart -d emulator-5554   (AVD emdia, com gravação)
//
// O corpo vive aqui (test/integracao/percurso_todos_os_ecras.dart) para os dois
// arranques o partilharem: na VM o binding é o automático do flutter_test; no
// aparelho é o IntegrationTestWidgetsFlutterBinding.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:em_dia/admin/admin_dados.dart';
import 'package:em_dia/admin/admin_shell.dart';
import 'package:em_dia/exemplo/exemplo_screen.dart';
import 'package:em_dia/l10n/app_localizations.dart';
import 'package:em_dia/models/perfil.dart';
import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/calendario/calendario_screen.dart';
import 'package:em_dia/screens/calendario/linha_obrigacao.dart';
import 'package:em_dia/screens/carro/carro_screen.dart';
import 'package:em_dia/screens/login/login_screen.dart';
import 'package:em_dia/screens/mais/mais_screen.dart';
import 'package:em_dia/screens/onboarding/onboarding_screen.dart';
import 'package:em_dia/screens/painel/painel_screen.dart';
import 'package:em_dia/screens/recibos/recibos_screen.dart';
import 'package:em_dia/screens/vida/entradas_screen.dart';
import 'package:em_dia/screens/vida/resumo_screen.dart';
import 'package:em_dia/screens/vida/saidas_screen.dart';
import 'package:em_dia/screens/vida/vida_screen.dart';

import '../golden/_apoio.dart';
import '../golden/fabrica_de_fotos.dart' show embrulha, carregaFonteInter, carregaFontesSdk;

final l = lookupAppLocalizations(const Locale('pt'));
final hoje = DateTime(2026, 9, 18);

/// Ecrãs vistos (nome → prova que apareceu). Imprime-se no fim.
final vistos = <String>[];

Future<void> ecra(WidgetTester t, String nome, Finder prova) async {
  await t.pump(const Duration(milliseconds: 150));
  await t.pump(const Duration(milliseconds: 400));
  // Num aparelho a sério (AVD com desenho por software) uma folha pode demorar
  // mais do que meio segundo a abrir: espera-se até 6 s antes de dar por falhado.
  for (var i = 0; i < 20 && prova.evaluate().isEmpty; i++) {
    await t.pump(const Duration(milliseconds: 300));
  }
  if (prova.evaluate().isEmpty) {
    // Para o relatório dizer o que estava no ecrã em vez do «não encontrei».
    final textos = find.byType(Text).evaluate().map((e) => (e.widget as Text).data ?? '').where((x) => x.length > 2).take(25).join(' | ');
    // ignore: avoid_print
    print('ECRA_FALHOU «$nome» — no ecrã: $textos');
  }
  expect(prova, findsWidgets, reason: 'ecrã «$nome» não mostrou o que promete');
  vistos.add(nome);
}

/// Toca e dá dois frames (a rota entra no frame seguinte ao toque). O frame
/// ANTES do toque também conta: depois de escrever num campo o botão só fica
/// ativo no rebuild seguinte — sem este pump o toque caía num botão desligado.
Future<void> toca(WidgetTester t, Finder f) async {
  await t.pump(const Duration(milliseconds: 100));
  await t.ensureVisible(f.first);
  await t.tap(f.first);
  await t.pump();
  await t.pump(const Duration(milliseconds: 450));
}

/// Recua um ecrã: o Navigator mais fundo que tiver para onde recuar (no modo
/// exemplo há dois — o da app e o de dentro do exemplo).
Future<void> recua(WidgetTester t) async {
  final navs = find.byType(Navigator).evaluate().toList();
  var popou = false;
  for (final e in navs.reversed) {
    final nav = (e as StatefulElement).state as NavigatorState;
    if (nav.canPop()) {
      nav.pop();
      popou = true;
      break;
    }
  }
  if (!popou) {
    // ignore: avoid_print
    print('RECUAR_FALHOU: nenhum Navigator tinha para onde recuar');
  }
  await t.pump();
  await t.pump(const Duration(milliseconds: 450));
}

/// Abre uma tela com as stores falsas POR CIMA do MaterialApp — como na app
/// real: as rotas que a tela empurra (Navigator.push) ficam por baixo dos
/// providers e encontram-nos.
Future<void> abre(WidgetTester t, Widget tela, {Perfil? perfil, Size tamanho = const Size(390, 844)}) async {
  // Na VM finge-se um telemóvel de 390×844 (ou o ecrã do admin). Num aparelho a
  // sério deixa-se o ecrã que ele tem, para a gravação mostrar a app (forçar
  // outro tamanho desenhava fora do vidro — 2026-09-18).
  if (t.binding is! LiveTestWidgetsFlutterBinding) {
    t.view.physicalSize = tamanho * 3;
    t.view.devicePixelRatio = 3;
  }
  // UniqueKey: cada `abre` é uma árvore nova. Sem ela o pumpWidget reaproveitava
  // o MaterialApp (e o Navigator, com as rotas que a tela anterior empurrou).
  await t.pumpWidget(KeyedSubtree(key: UniqueKey(), child: comStores(embrulha(tela, const Locale('pt')), perfil: perfil)));
  await t.pump(const Duration(milliseconds: 150));
  await t.pump(const Duration(milliseconds: 400));
}

/// Rola a lista até o widget existir e estar à vista (as ListView só constroem o
/// que se vê: um botão no fim da lista não existe antes de se rolar até lá).
Future<void> rolaAte(WidgetTester t, Finder f, {Finder? lista}) async {
  if (f.evaluate().isEmpty || !t.any(f)) {
    var scrollable = lista ?? find.byType(Scrollable).first;
    if (scrollable.evaluate().isEmpty) scrollable = find.byType(Scrollable).first;
    if (scrollable.evaluate().isEmpty) {
      final textos = find.byType(Text).evaluate().map((e) => (e.widget as Text).data ?? '').where((x) => x.length > 2).take(20).join(' | ');
      // ignore: avoid_print
      print('ROLAR_FALHOU sem lista para rolar — no ecrã: $textos');
    }
    await t.scrollUntilVisible(f, 300, scrollable: scrollable, maxScrolls: 30);
  }
  await t.ensureVisible(f.first);
  await t.pump(const Duration(milliseconds: 200));
}

/// Fecha a folha «Palavras difíceis» pelo botão do fim (a lista só constrói o
/// que se vê: com muitas palavras o botão está lá em baixo).
Future<void> fechaPalavras(WidgetTester t) async {
  final lista = find.descendant(of: find.byKey(const Key('palavras_folha')), matching: find.byType(Scrollable)).first;
  await rolaAte(t, find.byKey(const Key('palavras_fechar')), lista: lista);
  await toca(t, find.byKey(const Key('palavras_fechar')));
}

/// Finder com âmbito numa aba: o IndexedStack do fundo mantém as 6 abas vivas,
/// e um `find.text` solto apanhava widgets das abas escondidas.
Finder na(Type aba, Finder f) => find.descendant(of: find.byType(aba), matching: f);

/// Define os testes. Quem chama é `test/integracao/todos_os_ecras_test.dart`
/// (VM, `flutter test`) e `integration_test/todos_os_ecras_test.dart` (AVD).
void definirTestes() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  // O onboarding guarda cada resposta num rascunho (B1) e retoma-o: entre
  // caminhos o rascunho tem de nascer vazio.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  tearDownAll(() {
    // Fica no relatório do teste: a lista literal do que se viu.
    // ignore: avoid_print
    print('ECRAS_VISTOS=${vistos.length}: ${vistos.join(' | ')}');
  });

  // ------------------------------------------------------------ 1. onboarding
  group('onboarding — os 4 caminhos', () {
    Future<void> comeca(WidgetTester t) async {
      await abre(t, OnboardingScreen(hoje: hoje));
      await ecra(t, 'onboarding/boas-vindas', find.text(l.onbComecar));
      await toca(t, find.text(l.onbComecar));
      await ecra(t, 'onboarding/trabalhas-como', find.text(l.onbTrabalhasComo));
    }

    // A ordem dos passos é a do enum PassoOnboarding: atividade → abertura →
    // iva → (empresa, ivaPeriodo) → (salario, nascimento) → carro → rendimento
    // → (contabilista) → fim.
    Future<void> atividadeAbertura(WidgetTester t, String caminho) async {
      await ecra(t, '$caminho/o-que-fazes', find.text(l.onbOQueFazes));
      await toca(t, find.text(l.onbTvde));
      await ecra(t, '$caminho/quando-abriste', find.text(l.onbQuandoAbriste));
      // mês e ano: dois seletores (janeiro de 2024, como o Danilo)
      await toca(t, find.byType(DropdownButton<int>).first);
      await toca(t, find.text('janeiro').last);
      await toca(t, find.byType(DropdownButton<int>).last);
      await toca(t, find.text('2024').last);
      await toca(t, find.text(l.onbContinuar));
      await ecra(t, '$caminho/iva-15k', find.text(l.onbFaturouMais15k));
      await toca(t, find.text(l.onbNao));
      await toca(t, find.text(l.onbContinuar));
    }

    Future<void> semCarro(WidgetTester t, String caminho) async {
      await ecra(t, '$caminho/tens-carro', find.text(l.onbTensCarro));
      await toca(t, find.text(l.onbNao));
      await toca(t, find.text(l.onbContinuar));
    }

    Future<void> rendimentoEFim(WidgetTester t, String caminho) async {
      await ecra(t, '$caminho/quanto-ganhas', find.text(l.onbQuantoGanhas));
      await t.enterText(find.byType(TextField).first, '1200');
      await toca(t, find.text(l.onbContinuar));
      await ecra(t, '$caminho/fim', find.text(l.onbEntrarNaApp));
    }

    Future<void> recibosVerdes(WidgetTester t, String caminho) async {
      await atividadeAbertura(t, caminho);
      await semCarro(t, caminho);
      await rendimentoEFim(t, caminho);
    }

    testWidgets('caminho 1 — recibos verdes (o perfil do Danilo: TVDE, jan/2024, isento, sem carro, 1.200 €)', (t) async {
      await comeca(t);
      await toca(t, find.text(l.onbTrabalhoIndependente));
      await recibosVerdes(t, 'onboarding/recibos');
    });

    testWidgets('caminho 2 — contrato (salário, ano de nascimento, carro, fim)', (t) async {
      await comeca(t);
      await toca(t, find.text(l.onbTrabalhoContrato));
      await ecra(t, 'onboarding/contrato/salario', find.text(l.onbSalarioTitulo));
      await t.enterText(find.byType(TextField).first, '1350');
      await toca(t, find.text(l.onbContinuar));
      await ecra(t, 'onboarding/contrato/nascimento', find.text(l.onbNascimentoTitulo));
      await toca(t, find.byType(DropdownButtonFormField<int>));
      await toca(t, find.text('1998').last);
      await toca(t, find.text(l.onbContinuar));
      await ecra(t, 'onboarding/contrato/tens-carro', find.text(l.onbTensCarro));
      await toca(t, find.text(l.onbNao));
      await toca(t, find.text(l.onbContinuar));
      await ecra(t, 'onboarding/contrato/fim', find.text(l.onbEntrarNaApp));
    });

    testWidgets('caminho 3 — os dois (recibos verdes + salário)', (t) async {
      await comeca(t);
      await toca(t, find.text(l.onbTrabalhoAmbos));
      await atividadeAbertura(t, 'onboarding/ambos');
      await ecra(t, 'onboarding/ambos/salario', find.text(l.onbSalarioTitulo));
      await t.enterText(find.byType(TextField).first, '1000');
      await toca(t, find.text(l.onbContinuar));
      await ecra(t, 'onboarding/ambos/nascimento', find.text(l.onbNascimentoTitulo));
      await toca(t, find.text(l.onbSaltar));
      await semCarro(t, 'onboarding/ambos');
      await rendimentoEFim(t, 'onboarding/ambos');
    });

    testWidgets('caminho 4 — empresa (ENI/sociedade, IVA, contabilista, carro, fim)', (t) async {
      await comeca(t);
      await toca(t, find.text(l.onbTrabalhoEmpresa));
      await ecra(t, 'onboarding/empresa/tipo', find.text(l.onbEmpresaTitulo));
      await toca(t, find.text(l.onbEmpresaSociedade));
      await ecra(t, 'onboarding/empresa/iva-periodo', find.text(l.onbIvaPeriodoTitulo));
      await toca(t, find.text(l.onbIvaMensal));
      await semCarro(t, 'onboarding/empresa');
      await ecra(t, 'onboarding/empresa/contabilista', find.text(l.onbContabilistaTitulo));
      await t.enterText(find.byType(TextField).first, 'contas@exemplo.pt');
      await toca(t, find.text(l.onbContinuar));
      await ecra(t, 'onboarding/empresa/fim', find.text(l.onbEntrarNaApp));
    });
  });

  // ------------------------------------------------------------ 2. a app toda
  group('a app inteira (modo exemplo, sem servidor)', () {
    Future<void> exemplo(WidgetTester t) async {
      await abre(t, ExemploScreen(hoje: hoje));
      await ecra(t, 'painel', find.textContaining('Maria'));
    }

    Future<void> aba(WidgetTester t, IconData icone, String nome, Finder prova) async {
      await toca(t, find.byIcon(icone));
      await ecra(t, nome, prova);
    }

    testWidgets('as 6 abas e os ecrãs de dentro', (t) async {
      await exemplo(t);
      // Painel: o «O que é isto?» no fim da lista
      await rolaAte(t, find.byKey(const Key('palavras_ss')), lista: na(PainelScreen, find.byType(Scrollable)).first);
      await toca(t, find.byKey(const Key('palavras_ss')));
      await ecra(t, 'painel/palavras-dificeis', find.byKey(const Key('palavras_folha')));
      await fechaPalavras(t);

      // Recibos (a Maria é TVDE a recibos verdes): a calculadora em cima faz a
      // conta ao escrever; os cartões da Segurança Social e do IRS vêm por baixo.
      await aba(t, Icons.receipt_long_outlined, 'recibos', na(RecibosScreen, find.byKey(const Key('calc_valor'))));
      await t.enterText(na(RecibosScreen, find.byKey(const Key('calc_valor'))), '1000');
      await ecra(t, 'recibos/calculadora-com-valor', na(RecibosScreen, find.textContaining('€')));
      for (final (chave, nome) in [('ss_card', 'seguranca-social'), ('irs_card', 'irs')]) {
        await rolaAte(t, na(RecibosScreen, find.byKey(Key(chave))), lista: na(RecibosScreen, find.byType(Scrollable)).first);
        await ecra(t, 'recibos/$nome', na(RecibosScreen, find.byKey(Key(chave))));
      }

      // Dinheiro: 3 abas + folhas
      // Dinheiro: 3 abas (cada uma com a sua lista, que só constrói o que se vê)
      await aba(t, Icons.account_balance_wallet_outlined, 'dinheiro/entra', na(EntradasScreen, find.byType(Scrollable)));
      await rolaAte(t, na(EntradasScreen, find.byKey(const Key('entradas_novo'))), lista: na(EntradasScreen, find.byType(Scrollable)).first);
      await toca(t, na(EntradasScreen, find.byKey(const Key('entradas_novo'))));
      await ecra(t, 'dinheiro/nova-entrada', find.byKey(const Key('nova_entrada_valor')));
      await recua(t);
      await toca(t, na(VidaScreen, find.byKey(const Key('aba_sai'))));
      await ecra(t, 'dinheiro/sai', na(SaidasScreen, find.byType(Scrollable)));
      await rolaAte(t, na(SaidasScreen, find.byKey(const Key('saidas_nova'))), lista: na(SaidasScreen, find.byType(Scrollable)).first);
      await toca(t, na(SaidasScreen, find.byKey(const Key('saidas_nova'))));
      await ecra(t, 'dinheiro/nova-saida', find.byKey(const Key('saida_guardar')));
      await recua(t);
      await rolaAte(t, na(SaidasScreen, find.byKey(const Key('saidas_atalho_caixa'))), lista: na(SaidasScreen, find.byType(Scrollable)).first);
      await toca(t, na(SaidasScreen, find.byKey(const Key('saidas_atalho_caixa'))));
      await ecra(t, 'dinheiro/caixa-das-faturas', find.byKey(const Key('caixa_endereco')));
      await recua(t);
      await toca(t, na(VidaScreen, find.byKey(const Key('aba_sobra'))));
      await ecra(t, 'dinheiro/sobra', na(ResumoScreen, find.byType(Scrollable)));
      await rolaAte(t, na(ResumoScreen, find.text(l.sobraImportarBotao)), lista: na(ResumoScreen, find.byType(Scrollable)).first);
      await toca(t, na(ResumoScreen, find.text(l.sobraImportarBotao)));
      await ecra(t, 'dinheiro/importar-extrato', find.text(l.importarTitulo));
      await recua(t);
      await rolaAte(t, na(ResumoScreen, find.text(l.sobraRecorrentesBotao)), lista: na(ResumoScreen, find.byType(Scrollable)).first);
      await toca(t, na(ResumoScreen, find.text(l.sobraRecorrentesBotao)));
      await ecra(t, 'dinheiro/recorrentes', find.text(l.recorrentesTitulo));
      await recua(t);

      // Agenda: lista + detalhe de uma obrigação + nova obrigação
      await aba(t, Icons.calendar_month_outlined, 'agenda', na(CalendarioScreen, find.text(l.calTitulo)));
      // No AVD (411×914) a primeira linha ficava rente ao fundo, por baixo de
      // quem apanha os toques primeiro; sobe-se a lista antes de tocar.
      await t.drag(na(CalendarioScreen, find.byType(Scrollable)).first, const Offset(0, -240));
      await t.pump(const Duration(milliseconds: 400));
      await toca(t, na(CalendarioScreen, find.byType(LinhaObrigacao)));
      await ecra(t, 'agenda/detalhe-obrigacao', find.descendant(of: find.byType(BottomSheet), matching: find.text(l.calJaPaguei)));
      await recua(t);
      await toca(t, na(CalendarioScreen, find.text(l.calAdicionar)));
      await ecra(t, 'agenda/nova-obrigacao', find.byType(TextField));
      await recua(t);

      // Carro: lembretes + palavras difíceis
      await aba(t, Icons.directions_car_outlined, 'carro', na(CarroScreen, find.text(l.carroTitulo)));
      await toca(t, na(CarroScreen, find.byKey(const Key('palavras_tvde'))));
      await ecra(t, 'carro/palavras-dificeis', find.byKey(const Key('palavras_folha')));
      await fechaPalavras(t);

      // Mais: os acessos
      await aba(t, Icons.more_horiz_rounded, 'mais', na(MaisScreen, find.byKey(const Key('mais_vale_a_pena'))));
      for (final (chave, prova) in <(String, Finder)>[
        ('vale_a_pena', find.text(l.vpTitulo)),
        ('fala', find.text(l.falaTitulo)),
        ('cofre', find.text(l.cofreTitulo)),
        ('prova', find.text(l.provaTitulo)),
        ('radar', find.text(l.radarTitulo)),
        ('reforma', find.text(l.reformaTitulo)),
        ('guias', find.text(l.guiasTitulo)),
        ('ia', find.text(l.iaTitulo)),
        ('ajuda', find.byType(Scaffold)),
        ('plano', find.text(l.planoTitulo)),
        ('definicoes', find.byKey(const Key('defs_sair'))),
      ]) {
        await rolaAte(t, na(MaisScreen, find.byKey(Key('mais_$chave'))), lista: na(MaisScreen, find.byType(Scrollable)).first);
        await toca(t, na(MaisScreen, find.byKey(Key('mais_$chave'))));
        await ecra(t, 'mais/$chave', prova);
        if (chave == 'guias') {
          final primeiro = find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key as ValueKey<String>).value.startsWith('guia_'));
          if (primeiro.evaluate().isNotEmpty) {
            await toca(t, primeiro);
            await ecra(t, 'mais/guias/detalhe', find.byType(Scaffold));
            await recua(t);
          }
        }
        await recua(t);
      }
    });

    testWidgets('os ecrãs que a Maria não tem: contrato, empresa, entrada e admin', (t) async {
      final contrato = perfilTeste(tipoAtividade: TipoAtividade.semAtividade).copyWith(
        tipoTrabalho: TipoTrabalho.contrato,
        salarioBrutoMensal: 1350,
        dataNascimento: DateTime(1998, 1, 1),
      );
      await abre(t, RecibosScreen(hoje: hoje), perfil: contrato);
      await ecra(t, 'recibos/contrato', find.text(l.recibosTituloContrato));
      for (final (chave, prova) in <(String, Finder)>[
        ('recibo_vencimento', find.text(l.contratoReciboTitulo)),
        ('desemprego', find.text(l.contratoDesempregoTitulo)),
        ('horas_extra', find.text(l.contratoHorasExtraTitulo)),
      ]) {
        await rolaAte(t, find.byKey(Key('contrato_$chave')));
        await toca(t, find.byKey(Key('contrato_$chave')));
        await ecra(t, 'recibos/contrato/$chave', prova);
        await recua(t);
      }

      final empresa = perfilTeste(tipoAtividade: TipoAtividade.semAtividade).copyWith(
        tipoTrabalho: TipoTrabalho.empresa,
        empresaTipo: 'sociedade',
        ivaPeriodicidade: 'mensal',
      );
      await abre(t, RecibosScreen(hoje: hoje), perfil: empresa);
      await ecra(t, 'recibos/empresa', find.byKey(const Key('empresa_card')));
      expect(find.byKey(const Key('pasta_contabilista_card')), findsOneWidget);

      await abre(t, const LoginScreen());
      await ecra(t, 'entrada', find.byType(TextField));

      // Painel admin (PT-BR): as 9 secções, com dados de exemplo. É um painel
      // de computador (só o Danilo o usa, no PC): num telemóvel a sério o
      // tamanho pedido (1280×800) não se aplica e a barra do cabeçalho estoura
      // — por isso no aparelho fica de fora, com aviso; na VM vê-se todo.
      final dados = AdminDados.paraTeste(DadosTeste());
      if (WidgetsBinding.instance is! AutomatedTestWidgetsFlutterBinding) {
        // ignore: avoid_print
        print('ADMIN_FORA: num aparelho a sério o painel admin (1280×800, só o Danilo, no PC) fica de fora; as 9 secções veem-se na VM e nos golden');
      } else {
        for (var i = 0; i < 9; i++) {
          await abre(t, AdminMoldura(dados: dados, seccao: i, aoEscolher: (_) {}), tamanho: const Size(1280, 800));
          await ecra(t, 'admin/seccao-$i', find.byType(Scaffold));
        }
      }
    });
  });
}
