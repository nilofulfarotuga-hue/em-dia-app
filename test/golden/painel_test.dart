import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/painel/cartao_heroi.dart';
import 'package:em_dia/screens/painel/cartoes_painel.dart';
import 'package:em_dia/screens/painel/painel_screen.dart';
import 'package:em_dia/widgets/widgets.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// Tela 1 — Painel "Estás em dia?": verde (sem nada), laranja (2 a vencer em
/// 3 dias), vermelho (1 passada). "Hoje" fixo para as fotos serem iguais.
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  final hoje = DateTime(2026, 9, 7);

  testWidgets('painel verde — sem prazos, trial, TVDE com rendimentos', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'painel_verde',
      tela: () => embrulhaStores(
        tela: PainelScreen(hoje: hoje),
        perfil: perfilTeste(nome: 'Danilo Silva', tipoAtividade: TipoAtividade.tvde),
        plano: 'trial',
        obrigacoes: const [],
        rendimentos: [
          // média 2.000 €/mês → 24.000 €/ano → há IRS a guardar (número real no cartão)
          rendimentoTeste(mes: DateTime(2026, 8), valor: 2000),
          rendimentoTeste(mes: DateTime(2026, 7), valor: 1900),
          rendimentoTeste(mes: DateTime(2026, 6), valor: 2100),
        ],
      ),
    );
    expect(find.byType(SemaforoGrande), findsOneWidget);
    expect(find.byType(CartaoHeroi), findsOneWidget);
    expect(find.byType(CartaoVigiaIva), findsOneWidget);
    expect(find.text('Está tudo em dia'), findsOneWidget);
  });

  testWidgets('painel laranja — 2 pendentes a 3 dias', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'painel_laranja',
      tela: () => embrulhaStores(
        tela: PainelScreen(hoje: hoje),
        perfil: perfilTeste(nome: 'Danilo', tipoAtividade: TipoAtividade.tvde),
        plano: 'pro',
        obrigacoes: [
          obrigacaoTeste(id: 'o1', tipo: 'ss_pagamento', dataLimite: hoje.add(const Duration(days: 3)), valor: 149.80),
          obrigacaoTeste(id: 'o2', tipo: 'iuc', dataLimite: hoje.add(const Duration(days: 3)), valor: 64.92),
          obrigacaoTeste(id: 'o3', tipo: 'recibos_comunicar', dataLimite: hoje.add(const Duration(days: 20))),
        ],
        rendimentos: [
          rendimentoTeste(mes: DateTime(2026, 8), valor: 4500),
          rendimentoTeste(mes: DateTime(2026, 7), valor: 4500),
          rendimentoTeste(mes: DateTime(2026, 6), valor: 4500),
        ],
      ),
    );
    expect(find.text('Em 3 dias'), findsOneWidget);
    expect(find.byType(CartaoEsteMes), findsOneWidget);
    expect(find.text('214,72 €'), findsOneWidget); // total do mês
  });

  testWidgets('painel vermelho — 1 passada, plano grátis, sem rendimentos registados', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'painel_vermelho',
      tela: () => embrulhaStores(
        tela: PainelScreen(hoje: hoje),
        perfil: perfilTeste(nome: 'Maria', tipoAtividade: TipoAtividade.estafeta, rendimentoMensalEstimado: 900),
        plano: 'free',
        obrigacoes: [
          obrigacaoTeste(id: 'o1', tipo: 'ss_pagamento', dataLimite: hoje.subtract(const Duration(days: 2)), valor: 149.80),
          obrigacaoTeste(id: 'o2', tipo: 'seguro', dataLimite: hoje.add(const Duration(days: 12)), valor: 210),
        ],
      ),
    );
    // Aparece no herói e na linha de "Este mês pagas".
    expect(find.text('Passou há 2 dias'), findsNWidgets(2));
    // A última foto da suíte é PT-BR: verifica o estado, não o texto.
    expect(find.byWidgetPredicate((w) => w is SemaforoGrande && w.estado == Semaforo.vermelho), findsOneWidget);
  });

  testWidgets('painel a carregar — esqueleto', (tester) async {
    await fotografaTela(
      tester,
      nome: 'painel_skeleton',
      tamanho: tamanhos[1],
      tela: () => embrulhaStores(
        tela: PainelScreen(hoje: hoje),
        perfil: perfilTeste(),
        obrigacoesACarregar: true,
      ),
    );
    expect(find.byType(SkeletonPainel), findsOneWidget);
  });

  testWidgets('painel sem rede — aviso e tentar outra vez', (tester) async {
    await fotografaTela(
      tester,
      nome: 'painel_erro',
      tamanho: tamanhos[1],
      tela: () => embrulhaStores(
        tela: PainelScreen(hoje: hoje),
        perfil: perfilTeste(),
        obrigacoesErro: 'SocketException',
      ),
    );
    expect(find.byType(Aviso), findsOneWidget);
    expect(find.text('Sem ligação. Tenta outra vez daqui a bocado.'), findsOneWidget);
  });
}
