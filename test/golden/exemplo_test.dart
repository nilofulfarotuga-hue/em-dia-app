import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/exemplo/dados_exemplo.dart';
import 'package:em_dia/exemplo/exemplo_screen.dart';
import 'package:em_dia/regras/regras_legais.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// B2f (2026-09-18): «Vê como fica» — a app inteira com a Maria de exemplo,
/// faixa laranja em cima, sem servidor e sem gravar nada.
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  test('os dados do exemplo saem do gerador a sério e batem certo', () {
    final d = DadosExemplo.montar(hoje: DateTime(2026, 9, 18), regras: RegrasLegais.padrao2026());
    expect(d.perfil.nome, 'Maria');
    // Obrigações pelo gerador (12 meses): tem SS, IRS, IUC e inspeção do carro.
    final tipos = d.obrigacoes.map((o) => o.tipo).toSet();
    expect(tipos, containsAll(['ss_declaracao', 'ss_pagamento', 'iuc', 'ipo', 'seguro', 'irs_entrega']));
    expect(d.obrigacoes.every((o) => o.userId == userIdExemplo), isTrue);
    // Um mês de trabalho lançado só até hoje (dia 18 → 10 dias de trabalho).
    expect(d.entradas.length, 10);
    expect(d.entradas.every((e) => !e.data.isAfter(DateTime(2026, 9, 18))), isTrue);
    // O cofre automático apontou uma fatia por cada dia (a Maria já paga SS).
    expect(d.cofre.length, d.entradas.length);
    expect(d.cofre.every((c) => c.valor > 0 && c.nota == 'auto'), isTrue);
    // As contas do mês: o que entrou é a soma das entradas.
    final entrou = d.entradas.fold<double>(0, (t, e) => t + e.valor);
    expect(d.resumoMes.entrou, closeTo(entrou, 0.01));
    expect(d.resumoMes.noCofre, closeTo(d.cofre.fold<double>(0, (t, c) => t + c.valor), 0.01));
    // Duas fidelizações a acabar (MEO e ginásio) e três meses de extrato.
    expect(d.fidelizacoes.length, 2);
    expect(d.movimentosBanco.length, 15);
  });

  testWidgets('exemplo — painel cheio com a faixa e o botão de sair', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'exemplo_painel',
      tela: () => comStores(ExemploScreen(hoje: DateTime(2026, 9, 18))),
    );
    expect(find.textContaining('exemplo'), findsWidgets);
    expect(find.text('Sair'), findsOneWidget);
    expect(find.textContaining('Maria'), findsWidgets);
  });

  testWidgets('exemplo — as abas de dentro veem as stores de exemplo', (tester) async {
    await fotografaTela(
      tester,
      nome: 'exemplo_vida',
      tamanho: tamanhos[1],
      tela: () => comStores(ExemploScreen(hoje: DateTime(2026, 9, 18))),
      antes: (t) async {
        await t.tap(find.byIcon(Icons.account_balance_wallet_outlined));
        await t.pump(const Duration(milliseconds: 400));
      },
    );
    // «O meu dinheiro» com o dinheiro do mês (nunca a mensagem de vazio).
    expect(find.text('Sair'), findsOneWidget);
    expect(find.textContaining('€'), findsWidgets);
  });

  testWidgets('exemplo — o carro da Maria aparece na aba Carro', (tester) async {
    await fotografaTela(
      tester,
      nome: 'exemplo_carro',
      tamanho: tamanhos[1],
      tela: () => comStores(ExemploScreen(hoje: DateTime(2026, 9, 18))),
      antes: (t) async {
        await t.tap(find.byIcon(Icons.directions_car_outlined));
        await t.pump(const Duration(milliseconds: 400));
      },
    );
    expect(find.textContaining('AB-12-CD'), findsWidgets);
  });
}
