import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/painel/cartao_acao.dart';
import 'package:em_dia/screens/painel/cartao_heroi.dart';
import 'package:em_dia/screens/painel/cartoes_painel.dart';
import 'package:em_dia/screens/painel/painel_screen.dart';
import 'package:em_dia/widgets/widgets.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// Tela 1 — Painel "Estás em dia?": verde (sem nada), laranja (2 a vencer em
/// 3 dias), vermelho (1 passada). "Hoje" fixo para as fotos serem iguais.

/// Rola o painel ate ao que se quer ver.
///
/// Numa ListView o que esta abaixo da dobra nem chega a ser construido, por
/// isso `find` nao o encontra. Desde que o cartao de acao entrou no topo
/// (2026-09-06), metade do painel ficou abaixo da dobra nos tamanhos pequenos.
Future<void> rolarAte(WidgetTester tester, Finder alvo) => tester.dragUntilVisible(
      alvo,
      find.byType(ListView).first,
      const Offset(0, -300),
    );

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
    expect(find.text('Está tudo em dia'), findsOneWidget);
    // Sem obrigações nenhumas não há "próximo prazo" para mostrar, e um cartão
    // vazio a dizer que está vazio só ocupa ecrã. O cartão de ação em cima já
    // diz que está tudo tratado.
    expect(find.byType(CartaoHeroi), findsNothing);
    expect(find.byType(CartaoAcao), findsOneWidget);
    // A vigia do IVA vive no fundo da lista e, desde que o cartão de ação
    // entrou no topo (2026-09-06), fica abaixo da dobra. Numa ListView o que
    // está abaixo da dobra nem chega a ser construído — daí ter de se rolar
    // até lá antes de perguntar por ele.
    await rolarAte(tester, find.byType(CartaoVigiaIva));
    expect(find.byType(CartaoVigiaIva), findsOneWidget);
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
    // Duas obrigações no mesmo dia: a Segurança Social (149,80 €) vai para o
    // cartão de ação, e o cartão de baixo mostra a SEGUINTE — o imposto do
    // carro (64,92 €) — em vez de repetir a mesma três vezes.
    expect(find.byType(CartaoAcao), findsOneWidget);
    // A última foto da suíte é a de PT-BR, por isso o texto que fica no ecrã
    // no fim é o do Brasil ("Pague", não "Paga").
    expect(find.text('Pague a Segurança Social'), findsOneWidget);
    expect(find.byType(CartaoHeroi), findsOneWidget);
    expect(find.text('Em 3 dias'), findsOneWidget);
    await rolarAte(tester, find.byType(CartaoEsteMes));
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
    // A obrigação passada foi para o cartão de ação ("Já passou há 2 dias") e
    // o cartão de baixo mostra o que vem a seguir, o seguro. A linha de
    // "Este mês pagas" continua a marcar a passada a vermelho.
    expect(find.text('Já passou faz 2 dias'), findsOneWidget); // PT-BR, a última foto
    expect(find.byType(CartaoHeroi), findsOneWidget);
    await rolarAte(tester, find.byType(CartaoEsteMes));
    expect(find.text('Passou há 2 dias'), findsOneWidget); // na linha de "Este mês paga"
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
