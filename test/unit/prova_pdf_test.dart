import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/entrada.dart';
import 'package:em_dia/services/prova_rendimento.dart';

/// B2g (2026-09-18): a prova de rendimento sai mesmo como PDF, com a média
/// certa e a letra Inter dentro — não é uma promessa de ecrã.
///
/// Corre-se com `flutter test test/unit/prova_pdf_test.dart`; deixa o ficheiro
/// em `provas/em-dia-tudo-2026-09-17/prova-rendimento-12m.pdf` para se abrir
/// e ver com os olhos.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = '00000000-0000-4000-8000-000000000001';
  final hoje = DateTime(2026, 9, 18);

  // 12 meses fechados (set/2025 → ago/2026), 2 entradas por mês, + o mês em
  // curso, que tem de ficar de fora da conta.
  final entradas = <Entrada>[];
  var i = 0;
  for (var m = 1; m <= 13; m++) {
    final mes = DateTime(2026, 9 - m, 1); // ago/2026, jul/2026, … set/2025
    final base = 1100.0 + (m % 4) * 50; // 1150, 1200, 1250, 1100, …
    entradas.add(Entrada(id: 'e${i++}', userId: uid, data: DateTime(mes.year, mes.month, 10), valor: base * 0.6, tipo: 'plataforma', plataforma: 'uber'));
    entradas.add(Entrada(id: 'e${i++}', userId: uid, data: DateTime(mes.year, mes.month, 24), valor: base * 0.4, tipo: 'recibo_verde'));
  }
  entradas.add(Entrada(id: 'e-mes-corrente', userId: uid, data: DateTime(2026, 9, 5), valor: 999, tipo: 'plataforma', plataforma: 'bolt'));

  test('G01 a conta usa só os 12 meses fechados: o mês em curso fica de fora', () {
    final d = ProvaRendimento.contar(entradas: entradas, meses: 12, hoje: hoje, feitaEm: hoje);
    expect(d.inicio, DateTime(2025, 9, 1));
    expect(d.fim, DateTime(2026, 8, 31));
    expect(d.meses.length, 12);
    // Média = soma dos 12 meses / 12; o 13.º mês (set/2025 já entra; ago/2025 não) e os 999 € de setembro/2026 não contam.
    final soma = d.meses.fold<double>(0, (t, m) => t + m.total);
    expect(d.mediaMensal, closeTo(soma / 12, 0.01));
    expect(d.mediaMensal, lessThan(1400));
    expect(d.meses.every((m) => m.quantas == 2), isTrue);
  });

  test('G02 o PDF sai a sério: cabeçalho %PDF, uma página, letra Inter, ficheiro em provas/', () async {
    final d = ProvaRendimento.contar(entradas: entradas, meses: 12, hoje: hoje, feitaEm: hoje);
    final bytes = await ProvaRendimento.folha(
      dados: d,
      pessoa: const PessoaProva(nome: 'Maria Exemplo', nif: '123456789'),
      textos: const TextosProva(
        titulo: 'Declaração de rendimentos',
        app: 'Em Dia',
        rotuloNome: 'Nome',
        rotuloNif: 'NIF',
        rotuloPeriodo: 'Período',
        periodo: '1 de setembro de 2025 a 31 de agosto de 2026',
        rotuloMedia: 'Rendimento médio por mês',
        ajudaMedia: 'Média dos últimos 12 meses',
        colunaMes: 'Mês',
        colunaValor: 'Valor',
        rotuloTotal: 'Total',
        rotuloOrigem: 'De onde vem',
        origem: 'Recibo verde, App de trabalho (Uber)',
        feitaEm: 'Feita a 18/09/2026',
        honesto: 'Feito pela própria pessoa a partir do que escreveu na app Em Dia. Não é um documento oficial.',
      ),
    );
    // O ficheiro fica em provas/ ANTES de qualquer verificação: se algo falhar,
    // abre-se e vê-se o que saiu.
    final pasta = Directory('provas/em-dia-tudo-2026-09-17');
    if (pasta.existsSync()) {
      File('${pasta.path}/prova-rendimento-12m.pdf').writeAsBytesSync(bytes);
    }
    expect(bytes.length, greaterThan(5000));
    expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
    final cauda = String.fromCharCodes(bytes.sublist(bytes.length - 16)).trim();
    expect(cauda.endsWith('%%EOF'), isTrue);
    final texto = String.fromCharCodes(bytes);
    expect(RegExp(r'/Type\s*/Page[^s]').allMatches(texto).length, 1, reason: 'uma página só');
    expect(ProvaRendimento.saiuComAInter, isTrue, reason: 'a Inter tem de ir dentro do PDF');
    expect(texto.contains('/FontFile2'), isTrue, reason: 'a letra vai embebida (TrueType)');

  });

  test('G03 com só 3 meses escritos a folha não mente: conta os que há e diz quantos', () {
    final poucos = entradas.where((e) => e.data.isAfter(DateTime(2026, 5, 31))).toList();
    final d = ProvaRendimento.contar(entradas: poucos, meses: 12, hoje: hoje, feitaEm: hoje);
    expect(d.mesesComDinheiro, 3);
  });

  test('G04 a letra Inter existe no pacote (o PDF nunca sai sem acentos)', () async {
    final dados = await rootBundle.load('assets/fonts/Inter-VariableFont.ttf');
    expect(dados.lengthInBytes, greaterThan(100000));
  });
}
