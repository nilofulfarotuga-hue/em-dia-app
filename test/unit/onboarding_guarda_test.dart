import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:em_dia/config/app_theme.dart';
import 'package:em_dia/l10n/app_localizations.dart';
import 'package:em_dia/models/perfil.dart';
import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/onboarding/onboarding_screen.dart';
import 'package:em_dia/services/fala.dart';
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

  Future<PerfilStoreEspia> abre(WidgetTester tester) async {
    final espia = PerfilStoreEspia(perfilVazio());
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
    expect(find.text('O que fazes?'), findsOneWidget);

    final botao = tester.widget<ElevatedButton>(
      find.ancestor(of: find.text('Continuar'), matching: find.byType(ElevatedButton)),
    );
    expect(botao.onPressed, isNull,
        reason: 'com o botão activo dava para passar sem escolher, e o perfil ficava sem ofício');
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
}

/// Não fala com servidor nenhum: o recálculo do calendário diz que correu bem.
class ObrigacoesStoreMuda extends ObrigacoesStore {
  @override
  Future<bool> recalcular(String userId) async => true;
  @override
  Future<void> carregar(String userId) async {}
}
