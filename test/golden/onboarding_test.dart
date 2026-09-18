import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/onboarding/onboarding_screen.dart';
import 'package:em_dia/widgets/widgets.dart';

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
      tela: () => tela(PassoOnboarding.atividade.index, const DadosOnboarding(tipoAtividade: TipoAtividade.tvde)),
    );
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('onboarding passo 2 — quando abriste (março 2026 → isento até fev 2027)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'onboarding_p2_abertura',
      tela: () => tela(
        PassoOnboarding.abertura.index,
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
        PassoOnboarding.carro.index,
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
        PassoOnboarding.rendimento.index,
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

  // ---- B3 (2026-09-18): «Trabalhas como?» e os caminhos do contrato e da empresa ----

  testWidgets('onboarding — trabalhas como? (contrato escolhido)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'onboarding_trabalho',
      tela: () => tela(PassoOnboarding.trabalho.index, const DadosOnboarding(tipoTrabalho: TipoTrabalho.contrato)),
    );
    expect(find.textContaining('trabalha'), findsOneWidget); // PT «Trabalhas como?» / BR «Você trabalha como?»
    expect(find.byType(BotaoEscolha), findsNWidgets(4));
  });

  testWidgets('onboarding — contrato: quanto ganhas (1.200 € → SS 132,00)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'onboarding_salario',
      comTeclado: true,
      tela: () => tela(PassoOnboarding.salario.index, const DadosOnboarding(tipoTrabalho: TipoTrabalho.contrato, salarioMensal: 1200)),
    );
    expect(find.textContaining('132,00'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(4));
  });

  testWidgets('onboarding — contrato: ano de nascimento (IRS Jovem)', (tester) async {
    await fotografaTela(
      tester,
      nome: 'onboarding_nascimento',
      tamanho: tamanhos[1],
      tela: () => tela(PassoOnboarding.nascimento.index, const DadosOnboarding(tipoTrabalho: TipoTrabalho.contrato, salarioMensal: 1200, anoNascimento: 1998)),
    );
    expect(find.textContaining('IRS Jovem'), findsWidgets);
  });

  testWidgets('onboarding — empresa: ENI ou sociedade, IVA e contabilista', (tester) async {
    await fotografaTela(
      tester,
      nome: 'onboarding_empresa',
      tamanho: tamanhos[1],
      tela: () => tela(PassoOnboarding.empresa.index, const DadosOnboarding(tipoTrabalho: TipoTrabalho.empresa, empresaTipo: 'sociedade')),
    );
    expect(find.byType(BotaoEscolha), findsNWidgets(2));
  });

  // Cada passo no seu testWidgets: dois pumpWidget do mesmo OnboardingScreen no
  // mesmo teste reaproveitam o State (e o passo) do primeiro.
  testWidgets('onboarding — empresa: IVA mensal ou trimestral', (tester) async {
    await fotografaTela(
      tester,
      nome: 'onboarding_iva_periodo',
      tamanho: tamanhos[1],
      tela: () => tela(PassoOnboarding.ivaPeriodo.index, const DadosOnboarding(tipoTrabalho: TipoTrabalho.empresa, empresaTipo: 'sociedade', ivaPeriodo: 'trimestral')),
    );
    expect(find.text('De 3 em 3 meses'), findsOneWidget);
  });

  testWidgets('onboarding — empresa: contabilista (pasta mensal)', (tester) async {
    await fotografaTela(
      tester,
      nome: 'onboarding_contabilista',
      tamanho: tamanhos[1],
      teclado: true,
      tela: () => tela(PassoOnboarding.contabilista.index, const DadosOnboarding(tipoTrabalho: TipoTrabalho.empresa, empresaTipo: 'sociedade', ivaPeriodo: 'trimestral', contabilistaEmail: 'contas@exemplo.pt')),
    );
    expect(find.text('contas@exemplo.pt'), findsOneWidget);
  });
}
