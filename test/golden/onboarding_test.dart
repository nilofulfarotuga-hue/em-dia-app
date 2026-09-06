import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/onboarding/onboarding_screen.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// Tela 0 — Onboarding: passos 0, 1, 2, 4 e 5 (com teclado nos que têm campos).
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  // "Hoje" fixo para as fotos serem sempre iguais.
  final hoje = DateTime(2026, 9, 6);

  Widget tela(int passo, DadosOnboarding dados) =>
      comStores(OnboardingScreen(passoInicial: passo, exemplo: dados, hoje: hoje));

  testWidgets('onboarding passo 0 — boas-vindas', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'onboarding_p0_boasvindas',
      tela: () => tela(0, const DadosOnboarding()),
    );
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('onboarding passo 1 — o que fazes (TVDE escolhido)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'onboarding_p1_atividade',
      tela: () => tela(1, const DadosOnboarding(tipoAtividade: TipoAtividade.tvde)),
    );
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('onboarding passo 2 — quando abriste (março 2026 → isento até fev 2027)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'onboarding_p2_abertura',
      tela: () => tela(
        2,
        const DadosOnboarding(tipoAtividade: TipoAtividade.tvde, mesAbertura: 3, anoAbertura: 2026),
      ),
    );
    expect(find.textContaining('28/02/2027'), findsOneWidget);
  });

  testWidgets('onboarding passo 4 — tens carro (com teclado)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'onboarding_p4_carro',
      comTeclado: true,
      tela: () => tela(
        4,
        const DadosOnboarding(
          tipoAtividade: TipoAtividade.tvde,
          mesAbertura: 3,
          anoAbertura: 2026,
          faturouMais15k: false,
          temCarro: true,
          matricula: 'AB-12-CD',
          mesMatricula: 5,
          anoMatricula: 2019,
          mesSeguro: 11,
          mesUltimaIpo: 5,
          anoUltimaIpo: 2025,
        ),
      ),
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('AB-12-CD'), findsOneWidget);
  });

  testWidgets('onboarding passo 5 — quanto ganhas (com teclado)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'onboarding_p5_rendimento',
      comTeclado: true,
      tela: () => tela(
        5,
        const DadosOnboarding(
          tipoAtividade: TipoAtividade.tvde,
          mesAbertura: 3,
          anoAbertura: 2026,
          faturouMais15k: false,
          temCarro: false,
          rendimentoMensal: 1200,
        ),
      ),
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(4));
  });
}
