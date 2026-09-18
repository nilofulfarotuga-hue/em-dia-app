import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:em_dia/config/app_theme.dart';
import 'package:em_dia/l10n/app_localizations.dart';
import 'package:em_dia/models/perfil.dart';
import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/onboarding/onboarding_screen.dart';
import 'package:em_dia/services/fala.dart';
import 'package:em_dia/services/rascunho_onboarding.dart';
import 'package:em_dia/stores/dados_store.dart';
import 'package:em_dia/stores/perfil_store.dart';
import 'package:em_dia/stores/regras_store.dart';
import 'package:em_dia/stores/sessao_store.dart';

/// O onboarding tem de GRAVAR o que a pessoa escolheu.
///
/// Cicatriz de 2026-09-06: fiz o onboarding a sério no browser, escolhi
/// "Motorista TVDE" e março de 2026, e no fim a base de dados tinha
/// `tipo_atividade = sem_atividade` e `data_abertura` a nulo — mas o rendimento
/// de 1800 € tinha ficado gravado. Sem estes dois campos não há calendário
/// nenhum: zero obrigações geradas. Este teste conduz o onboarding pelo teclado
/// e pelos toques, como uma pessoa, e olha para o que foi entregue ao servidor.
void main() {
  Perfil perfilVazio() => Perfil(
        userId: 'u1',
        email: 'teste@exemplo.pt',
        trialAte: DateTime(2026, 10, 6),
        criadoEm: DateTime(2026, 9, 6),
      );

  Future<PerfilStoreEspia> abre(WidgetTester tester, {PerfilStoreEspia? reabrir}) async {
    final espia = reabrir ?? PerfilStoreEspia(perfilVazio());
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SessaoStore>(create: (_) => SessaoStore.semServidor()),
          ChangeNotifierProvider<PerfilStore>.value(value: espia),
          ChangeNotifierProvider<RegrasStore>(create: (_) => RegrasStore()),
          ChangeNotifierProvider<ObrigacoesStore>(create: (_) => ObrigacoesStoreMuda()),
          ChangeNotifierProvider<CarrosStore>(create: (_) => CarrosStore.paraTeste(const [])),
          ChangeNotifierProvider<Fala>.value(value: Fala.instancia),
        ],
        child: MaterialApp(
          theme: AppTheme.claro,
          locale: const Locale('pt'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return espia;
  }

  Future<void> toca(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('O01 CICATRIZ: o ofício e a data de abertura chegam ao servidor', (tester) async {
    final espia = await abre(tester);

    // 1. Boas-vindas
    await toca(tester, find.text('Começar'));

    // 1b. Trabalhas como? — recibos verdes (B3)
    expect(find.text('Trabalhas como?'), findsOneWidget);
    await toca(tester, find.text('Recibos verdes'));

    // 2. O que fazes? — motorista
    expect(find.text('O que fazes?'), findsOneWidget);
    await toca(tester, find.text('Motorista TVDE (Uber, Bolt)'));

    // 3. Quando abriste atividade? — março de 2026
    expect(find.text('Quando abriste atividade?'), findsOneWidget,
        reason: 'esta pergunta só aparece a quem escolheu um ofício');
    await toca(tester, find.text('Mês'));
    await toca(tester, find.text('março').last);
    await toca(tester, find.text('Ano'));
    await toca(tester, find.text('2026').last);
    await toca(tester, find.text('Continuar'));

    // 4. Faturaste mais de 15.000 €? — não
    await toca(tester, find.text('Não').first);
    await toca(tester, find.text('Continuar'));

    // 5. Tens carro? — não
    await toca(tester, find.text('Não').first);
    await toca(tester, find.text('Continuar'));

    // 6. Quanto ganhas por mês? — 1.800 €
    await tester.enterText(find.byType(TextField).first, '1800');
    await tester.pumpAndSettle();
    await toca(tester, find.text('Continuar'));

    // 7. Fim
    await toca(tester, find.text('Entrar na app'));

    // ---- o que foi mesmo entregue ao servidor ----
    expect(espia.guardados, isNotEmpty, reason: 'o onboarding tem de gravar o perfil');
    final ultimo = espia.guardados.last;
    expect(ultimo.tipoAtividade, TipoAtividade.tvde,
        reason: 'escolhi motorista e tem de ser motorista que fica gravado');
    expect(ultimo.dataAbertura, DateTime(2026, 3, 1),
        reason: 'sem data de abertura não há calendário de Segurança Social');
    expect(ultimo.rendimentoMensalEstimado, 1800);
    expect(ultimo.onboardingConcluido, isTrue);

    // E o que vai no pedido HTTP, que é o que o servidor vê de verdade.
    final mapa = ultimo.toUpdate();
    expect(mapa['tipo_atividade'], 'tvde');
    expect(mapa['data_abertura'], '2026-03-01');
    expect(mapa['rendimento_mensal_estimado'], 1800);
  });

  testWidgets('O02 sem escolher ofício não se passa da primeira pergunta', (tester) async {
    await abre(tester);
    await toca(tester, find.text('Começar'));
    expect(find.text('Trabalhas como?'), findsOneWidget);
    await toca(tester, find.text('Recibos verdes'));
    expect(find.text('O que fazes?'), findsOneWidget);

    final botao = tester.widget<ElevatedButton>(
      find.ancestor(of: find.text('Continuar'), matching: find.byType(ElevatedButton)),
    );
    expect(botao.onPressed, isNull,
        reason: 'com o botão activo dava para passar sem escolher, e o perfil ficava sem ofício');
  });

  // Defeito 1 da missão em-dia-tudo-2026-09-17: responder a 4 perguntas,
  // recarregar a página, voltar à pergunta 1. Agora cada resposta é guardada ao
  // sair da pergunta (aparelho + servidor) e a app retoma onde ficou.
  testWidgets('O03 responde a 3 perguntas, "recarrega" e está na 4.ª com as respostas guardadas', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final espia = await abre(tester);
    await toca(tester, find.text('Começar'));
    await toca(tester, find.text('Recibos verdes'));                        // Trabalhas como? (B3)
    await toca(tester, find.text('Motorista TVDE (Uber, Bolt)'));          // 1.ª pergunta respondida
    await toca(tester, find.text('Mês'));
    await toca(tester, find.text('março').last);
    await toca(tester, find.text('Ano'));
    await toca(tester, find.text('2026').last);
    await toca(tester, find.text('Continuar'));                             // 2.ª
    await toca(tester, find.text('Não').first);
    await toca(tester, find.text('Continuar'));                             // 3.ª → estamos na 4.ª (carro)
    expect(find.text('Tens carro?'), findsOneWidget);

    // O rascunho chegou aos dois sítios.
    expect(espia.rascunhos, isNotEmpty, reason: 'cada resposta tem de ir para o servidor');
    final servidor = espia.rascunhos.last!;
    expect(servidor['passo'], 'carro');
    expect(servidor['tipo'], 'tvde');
    expect(servidor['mesAbertura'], 3);
    expect(servidor['anoAbertura'], 2026);
    expect(servidor['faturouMais15k'], false);
    final aparelho = await RascunhoOnboarding.ler('u1');
    expect(aparelho?['passo'], 'carro', reason: 'e para o aparelho (localStorage na web)');

    // "Recarregar": um ecrã novo, com o mesmo perfil (que já traz o rascunho do servidor).
    await tester.pumpWidget(const SizedBox());
    await abre(tester, reabrir: espia);
    expect(find.text('Tens carro?'), findsOneWidget, reason: 'tem de retomar na 4.ª pergunta');
    expect(find.text('Pergunta 5 de 6'), findsOneWidget); // B3: «Trabalhas como?» é a 1.ª pergunta
    // E ao voltar atrás, as respostas estão lá.
    await toca(tester, find.text('Voltar'));
    expect(find.text('No ano passado faturaste mais de 15.000 €?'), findsOneWidget);
  });

  testWidgets('O04 a matrícula escrita a meio da pergunta também fica guardada', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final espia = await abre(tester);
    await toca(tester, find.text('Começar'));
    await toca(tester, find.text('Recibos verdes'));
    await toca(tester, find.text('Motorista TVDE (Uber, Bolt)'));
    await toca(tester, find.text('Mês'));
    await toca(tester, find.text('março').last);
    await toca(tester, find.text('Ano'));
    await toca(tester, find.text('2026').last);
    await toca(tester, find.text('Continuar'));
    await toca(tester, find.text('Não').first);
    await toca(tester, find.text('Continuar'));
    await toca(tester, find.text('Sim').first);                             // tem carro
    await tester.enterText(find.byType(TextField).first, 'AA-12-BB');
    await tester.pump(const Duration(seconds: 1));                          // o guardar de 800 ms
    await tester.pumpAndSettle();
    expect(espia.rascunhos.last!['matricula'], 'AA-12-BB');
    expect(espia.rascunhos.last!['temCarro'], true);

    await tester.pumpWidget(const SizedBox());
    await abre(tester, reabrir: espia);
    expect(find.text('Tens carro?'), findsOneWidget);
    expect(find.text('AA-12-BB'), findsOneWidget, reason: 'a matrícula escrita antes de recarregar não se perde');
  });

  testWidgets('O05 ao acabar, o rascunho é apagado (o perfil a sério é o que manda)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final espia = await abre(tester);
    await toca(tester, find.text('Começar'));
    await toca(tester, find.text('Recibos verdes'));
    // A última opção está fora do ecrã na lista: primeiro rola até ela.
    await tester.scrollUntilVisible(find.text('Só quero o carro'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await toca(tester, find.text('Só quero o carro'));
    await toca(tester, find.text('Não').first);
    await toca(tester, find.text('Continuar'));
    await toca(tester, find.text('Entrar na app'));
    expect(espia.rascunhos.last, isNull);
    expect(await RascunhoOnboarding.ler('u1'), isNull);
  });
}

/// Guarda tudo o que lhe mandam gravar, e diz sempre que sim.
class PerfilStoreEspia extends PerfilStore {
  Perfil _p;
  final List<Perfil> guardados = [];
  PerfilStoreEspia(this._p);

  @override
  Perfil? get perfil => _p;
  @override
  bool get temPerfil => true;
  @override
  Future<void> carregar(String userId) async {}
  @override
  Future<bool> guardar(Perfil novo) async {
    guardados.add(novo);
    _p = novo;
    notifyListeners();
    return true;
  }

  /// O rascunho «no servidor»: fica no perfil, como a coluna `onboarding_rascunho`.
  final List<Map<String, dynamic>?> rascunhos = [];
  @override
  Future<bool> guardarRascunhoOnboarding(Map<String, dynamic>? rascunho) async {
    rascunhos.add(rascunho);
    _p = rascunho == null ? _p.copyWith(limparRascunho: true) : _p.copyWith(onboardingRascunho: rascunho);
    return true;
  }
}

/// Não fala com servidor nenhum: o recálculo do calendário diz que correu bem.
class ObrigacoesStoreMuda extends ObrigacoesStore {
  @override
  Future<bool> recalcular(String userId) async => true;
  @override
  Future<void> carregar(String userId) async {}
}
