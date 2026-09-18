import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/regras/extrato_banco.dart';

/// O leitor de extratos não conhece bancos de cor: reconhece as colunas pelos
/// nomes e lê datas e números como os bancos portugueses (e o Revolut) os
/// escrevem. Os ficheiros aqui são construídos à mão com os formatos que os
/// bancos usam; os exports reais de cada banco ficam POR CONFIRMAR com
/// ficheiros de verdade (o Danilo tem contas na CGD/Millennium — B8).
void main() {
  group('Números e datas à portuguesa', () {
    test('E01 1.234,56 · -12,50 · 12,50 € · (12,50) · -12.50 · 1,234.56', () {
      expect(lerNumeroExtrato('1.234,56'), 1234.56);
      expect(lerNumeroExtrato('-12,50'), -12.5);
      expect(lerNumeroExtrato('12,50 €'), 12.5);
      expect(lerNumeroExtrato('(12,50)'), -12.5);
      expect(lerNumeroExtrato('-12.50'), -12.5);
      expect(lerNumeroExtrato('1,234.56'), 1234.56);
      expect(lerNumeroExtrato('1.234'), 1234);
      expect(lerNumeroExtrato('0,00'), 0);
      expect(lerNumeroExtrato(''), isNull);
      expect(lerNumeroExtrato('abc'), isNull);
    });
    test('E02 datas dd-mm-aaaa, dd/mm/aaaa, aaaa-mm-dd com hora, dd-mm-aa', () {
      expect(lerDataExtrato('20-09-2026'), DateTime(2026, 9, 20));
      expect(lerDataExtrato('20/09/2026'), DateTime(2026, 9, 20));
      expect(lerDataExtrato('2026-09-20 14:31:00'), DateTime(2026, 9, 20));
      expect(lerDataExtrato('20-09-26'), DateTime(2026, 9, 20));
      expect(lerDataExtrato('31/02/2026'), isNull);
      expect(lerDataExtrato('Descrição'), isNull);
    });
    test('E03 descrição normalizada tira acentos, referências e datas', () {
      expect(normalizarDescricao('COMPRA 1234567 NETFLIX.COM 15/09'), 'compra netflix com');
      expect(normalizarDescricao('Débito Direto MEO - SERVIÇOS DE COMUNICAÇÕES'), 'debito direto meo servicos de comunicacoes');
    });
  });

  group('CSV com uma coluna de valor (Santander/Novobanco/BPI-like)', () {
    final csv = latin1.encode([
      'Extrato de conta',
      'Conta: 0000 0000 00000000000 00',
      '',
      'Data Operação;Data Valor;Descrição;Montante;Saldo',
      '15-09-2026;15-09-2026;DD MEO SERVIÇOS;-35,90;1.204,10',
      '10-09-2026;10-09-2026;TRF UBER BV;+412,30;1.240,00',
      '02-09-2026;02-09-2026;COMPRA CONTINENTE GUARDA;-54,12;827,70',
      '15-08-2026;15-08-2026;DD MEO SERVIÇOS;-35,90;881,82',
      '15-07-2026;15-07-2026;DD MEO SERVIÇOS;-35,90;917,72',
      '20-07-2026;20-07-2026;SEGURANCA SOCIAL;-179,76;737,96',
    ].join('\r\n'));
    test('E04 encontra o cabeçalho depois das linhas de conversa, lê 6 movimentos', () {
      final e = lerExtratoCsv(csv, nomeFicheiro: 'extrato_santander.csv');
      expect(e.formato, 'csv');
      expect(e.banco, 'santander');
      expect(e.movimentos.length, 6);
      expect(e.linhasIgnoradas, isEmpty);
      final meo = e.movimentos.firstWhere((m) => m.descricao.contains('MEO') && m.data.month == 9);
      expect(meo.valor, -35.9);
      expect(meo.saldo, 1204.10);
      expect(meo.entra, isFalse);
      final uber = e.movimentos.firstWhere((m) => m.descricao.contains('UBER'));
      expect(uber.valor, 412.3);
      expect(uber.entra, isTrue);
    });
    test('E05 do mais recente para o mais antigo, com chave estável', () {
      final e = lerExtratoCsv(csv);
      expect(e.movimentos.first.data, DateTime(2026, 9, 15));
      expect(e.movimentos.last.data, DateTime(2026, 7, 15));
      expect(e.movimentos.first.chave, '2026-09-15|-35.90|dd meo servicos');
    });
    test('E06 categoriza e encontra o que se repete: MEO 3 meses = recorrente; Continente 1 vez não', () {
      final e = lerExtratoCsv(csv);
      final rec = encontrarRecorrentes(e.movimentos);
      expect(rec.length, 1);
      expect(rec.first.fornecedor, 'MEO');
      expect(rec.first.categoria, 'telemovel');
      expect(rec.first.valorMedio, 35.9);
      expect(rec.first.vezes, 3);
      expect(rec.first.diaHabitual, 15);
      expect(totalMensalRecorrente(rec), 35.9);
      expect(categorizar(e.movimentos.firstWhere((m) => m.descricao.contains('UBER'))).categoria, 'rendimento');
      expect(categorizar(e.movimentos.firstWhere((m) => m.descricao.contains('SEGURANCA'))).categoria, 'imposto');
      expect(categorizar(e.movimentos.firstWhere((m) => m.descricao.contains('CONTINENTE'))).categoria, 'compras');
    });
  });

  group('CSV com Débito e Crédito separados (CGD/Millennium-like), UTF-8 com BOM', () {
    final csv = utf8.encode('﻿${[
      'Data mov.;Data valor;Descrição;Débito;Crédito;Saldo contabilístico',
      '18/09/2026;18/09/2026;COMPRA NETFLIX.COM;12,99;;500,00',
      '18/08/2026;18/08/2026;COMPRA NETFLIX.COM;12,99;;512,99',
      '05/09/2026;05/09/2026;TRF BOLT OPERATIONS;;350,00;862,99',
      '01/09/2026;01/09/2026;RENDA SETEMBRO;450,00;;512,99',
      'Total;;;;;',
    ].join('\n')}');
    test('E07 débito sai negativo, crédito entra positivo; a linha «Total» é ignorada e contada', () {
      final e = lerExtratoCsv(csv, nomeFicheiro: 'movimentos_caixadirecta.csv');
      expect(e.banco, 'cgd');
      expect(e.movimentos.length, 4);
      expect(e.linhasIgnoradas.length, 1);
      expect(e.movimentos.firstWhere((m) => m.descricao.contains('NETFLIX') && m.data.month == 9).valor, -12.99);
      expect(e.movimentos.firstWhere((m) => m.descricao.contains('BOLT')).valor, 350.0);
      final rec = encontrarRecorrentes(e.movimentos);
      expect(rec.map((r) => r.fornecedor), ['Netflix']);
      expect(rec.first.categoria, 'assinatura');
    });
  });

  group('Revolut (vírgula, datas ISO com hora, ponto decimal)', () {
    final csv = utf8.encode([
      'Type,Product,Started Date,Completed Date,Description,Amount,Fee,Currency,State,Balance',
      'CARD_PAYMENT,Current,2026-09-10 08:02:11,2026-09-11 09:00:00,Spotify,-6.99,0.00,EUR,COMPLETED,120.50',
      'CARD_PAYMENT,Current,2026-08-10 08:02:11,2026-08-11 09:00:00,Spotify,-6.99,0.00,EUR,COMPLETED,127.49',
      'TOPUP,Current,2026-09-01 10:00:00,2026-09-01 10:00:00,"Top-Up by *1234",50.00,0.00,EUR,COMPLETED,127.49',
    ].join('\n'));
    test('E08 lê pela «Completed Date», reconhece o banco e o Spotify repete-se', () {
      final e = lerExtratoCsv(csv, nomeFicheiro: 'account-statement.csv');
      expect(e.banco, 'revolut');
      expect(e.movimentos.length, 3);
      expect(e.movimentos.first.data, DateTime(2026, 9, 11));
      expect(e.movimentos.firstWhere((m) => m.descricao.startsWith('Top-Up')).valor, 50.0);
      final rec = encontrarRecorrentes(e.movimentos);
      expect(rec.single.fornecedor, 'Spotify');
      expect(rec.single.valorMedio, 6.99);
    });
  });

  group('Excel (células já lidas) e erros', () {
    test('E09 folha de Excel com linhas vazias e cabeçalho na 3.ª linha', () {
      final e = lerExtratoDeCelulas([
        ['Millennium bcp', '', '', ''],
        ['', '', '', ''],
        ['Data lançamento', 'Data valor', 'Descrição', 'Valor', 'Saldo'],
        ['12-09-2026', '12-09-2026', 'DD EDP COMERCIAL', '-61,40', '900,00'],
        ['12-08-2026', '12-08-2026', 'DD EDP COMERCIAL', '-58,10', '961,40'],
      ], nomeFicheiro: 'movimentos.xlsx');
      expect(e.formato, 'xlsx');
      expect(e.banco, 'millennium');
      expect(e.movimentos.length, 2);
      final rec = encontrarRecorrentes(e.movimentos);
      expect(rec.single.fornecedor, 'EDP');
      expect(rec.single.categoria, 'luz');
    });
    test('E10 um CSV sem colunas reconhecíveis dá erro claro, não lixo', () {
      expect(() => lerExtratoCsv(utf8.encode('a;b;c\n1;2;3')), throwsA(isA<ExtratoInvalido>()));
      expect(() => lerExtratoCsv(utf8.encode('')), throwsA(isA<ExtratoInvalido>()));
    });
    test('E11 valores que variam mais de 15% não são «a mesma coisa» (compras no supermercado)', () {
      final e = lerExtratoCsv(utf8.encode([
        'Data;Descrição;Valor',
        '01-09-2026;COMPRA PINGO DOCE;-80,00',
        '01-08-2026;COMPRA PINGO DOCE;-30,00',
      ].join('\n')));
      expect(encontrarRecorrentes(e.movimentos), isEmpty);
    });
  });
}
