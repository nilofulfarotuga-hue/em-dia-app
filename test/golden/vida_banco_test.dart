import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/movimento_banco.dart';
import 'package:em_dia/regras/extrato_banco.dart';
import 'package:em_dia/screens/vida/importar_extrato_screen.dart';
import 'package:em_dia/screens/vida/recorrentes_screen.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// B2a/B2c (2026-09-18): importar o extrato do banco e as coisas que se repetem.
void main() {
  final hoje = DateTime(2026, 9, 18);
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  ExtratoLido extratoExemplo() => lerExtratoCsv(latin1.encode([
        'Data Operação;Data Valor;Descrição;Montante;Saldo',
        '15-09-2026;15-09-2026;DD MEO SERVIÇOS;-35,90;1.204,10',
        '10-09-2026;10-09-2026;TRF UBER BV;+412,30;1.240,00',
        '05-09-2026;05-09-2026;COMPRA NETFLIX.COM;-12,99;827,70',
        '02-09-2026;02-09-2026;COMPRA CONTINENTE GUARDA;-54,12;840,69',
        '15-08-2026;15-08-2026;DD MEO SERVIÇOS;-35,90;881,82',
        '05-08-2026;05-08-2026;COMPRA NETFLIX.COM;-12,99;894,81',
        '20-07-2026;20-07-2026;SEGURANCA SOCIAL;-179,76;737,96',
        '15-07-2026;15-07-2026;DD MEO SERVIÇOS;-35,90;917,72',
      ].join('\r\n')), nomeFicheiro: 'extrato_santander.csv');

  List<MovimentoBanco> movimentosExemplo() {
    final e = extratoExemplo();
    final rec = encontrarRecorrentes(e.movimentos).map((r) => r.chave).toSet();
    var i = 0;
    return [
      for (final m in e.movimentos)
        MovimentoBanco(
          id: 'm${i++}',
          userId: 'u1',
          data: m.data,
          descricao: m.descricao,
          valor: m.valor,
          saldo: m.saldo,
          banco: 'santander',
          categoria: categorizar(m).categoria,
          fornecedor: categorizar(m).fornecedor,
          recorrente: rec.contains(normalizarDescricao(m.descricao)),
          chave: m.chave,
        ),
    ];
  }

  const operadores = [
    OperadorCancelar(chave: 'meo', nome: 'MEO', categoria: 'telemovel', comoCancelar: 'Na área de cliente MEO pedes o cancelamento por escrito; também podes ligar 16200.', url: 'https://my.meo.pt/perfil/mensagens/abrir-pedido', telefone: '16200'),
    OperadorCancelar(chave: 'netflix', nome: 'Netflix', categoria: 'assinatura', comoCancelar: 'Entra em netflix.com → Conta → Cancelar subscrição.', url: 'https://www.netflix.com/cancelplan'),
    OperadorCancelar(chave: 'generico', nome: 'Outro serviço', categoria: 'outro', comoCancelar: 'Procura na fatura a área de cliente e pede o cancelamento por escrito.'),
  ];

  testWidgets('importar extrato — o que a app leu antes de guardar', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vida_importar_extrato',
      tela: () => embrulhaStores(
        tela: ImportarExtratoScreen(exemplo: extratoExemplo(), nomeExemplo: 'extrato_santander.csv'),
        perfil: perfilTeste(),
      ),
    );
    expect(find.text('Movimentos lidos'), findsOneWidget);
    expect(find.text('8'), findsWidgets); // 8 movimentos lidos
    expect(find.text('Santander'), findsOneWidget);
    expect(find.textContaining('coisas que se repetem'), findsWidgets); // MEO + Netflix
    // A última foto da suíte é PT-BR («se repete»): procura-se pela raiz.
    expect(find.textContaining('repete'), findsWidgets);
  });

  testWidgets('coisas que se repetem — total, como cancelar, avisar-me', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'vida_recorrentes',
      tela: () => embrulhaStores(
        tela: RecorrentesScreen(hoje: hoje),
        perfil: perfilTeste(),
        movimentosBanco: movimentosExemplo(),
        operadores: operadores,
      ),
    );
    // MEO 35,90 + Netflix 12,99 = 48,89 €/mês
    expect(find.textContaining('48,89 €'), findsOneWidget);
    expect(find.text('MEO'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Como cancelar'), findsNWidgets(2));
    // abrir o «como cancelar» da MEO
    await tester.tap(find.text('Como cancelar').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('16200'), findsWidgets);
  });

  testWidgets('coisas que se repetem — sem extrato importado', (tester) async {
    await fotografaTela(
      tester,
      nome: 'vida_recorrentes_vazio',
      tamanho: tamanhos[1],
      tela: () => embrulhaStores(tela: RecorrentesScreen(hoje: hoje), perfil: perfilTeste()),
    );
    expect(find.text('Importar o extrato do banco'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}
