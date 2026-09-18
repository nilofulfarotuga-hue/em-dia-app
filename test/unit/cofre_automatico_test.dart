import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/regras/regras.dart';

/// B2d: a fatia que o cofre guarda sozinho por cada rendimento.
/// Fontes: `ss_taxa` 21,4 % e `ss_base_servicos` 70 % (CRC art. 162.º/168.º,
/// seg-social.pt, na tabela regras_legais); IRS pelos escalões da tabela.
void main() {
  final r = RegrasLegais.padrao2026();

  test('A01 1.200 € de serviços, sem isenção, sem IRS estimado → só a SS: 70 % × 21,4 % = 179,76 €', () {
    final f = fatiaParaOCofre(valor: 1200, data: DateTime(2026, 9, 10), tipo: TipoRendimento.servicos, dataAbertura: DateTime(2024, 1, 1), regras: r);
    expect(f.segurancaSocial, 179.76);
    expect(f.irs, 0);
    expect(f.total, 179.76);
    expect(f.ssIsenta, isFalse);
  });

  test('A02 no 1.º ano de atividade a SS é 0 (isenção), e o IRS entra pela taxa efetiva do rendimento anual', () {
    final f = fatiaParaOCofre(
      valor: 2000,
      data: DateTime(2026, 9, 10),
      tipo: TipoRendimento.servicos,
      dataAbertura: DateTime(2026, 3, 15),
      rendimentoAnualEstimado: 24000,
      regras: r,
    );
    expect(f.ssIsenta, isTrue);
    expect(f.segurancaSocial, 0);
    final irs = calcularIrs(rendimentoBrutoAnual: 24000, tipo: TipoRendimento.servicos, ano: 2026, r: r);
    expect(f.irs, centimos(2000 * irs.taxaEfetivaPct / 100));
    expect(f.irs, greaterThan(0));
  });

  test('A03 vendas: 20 % de base → 4,28 % do rendimento', () {
    final f = fatiaParaOCofre(valor: 1000, data: DateTime(2026, 9, 10), tipo: TipoRendimento.vendas, dataAbertura: DateTime(2020, 1, 1), regras: r);
    expect(f.segurancaSocial, 42.8);
  });

  test('A04 abaixo do mínimo de existência não se guarda IRS (12.000 €/ano)', () {
    final f = fatiaParaOCofre(valor: 1000, data: DateTime(2026, 9, 10), tipo: TipoRendimento.servicos, rendimentoAnualEstimado: 12000, regras: r);
    expect(f.irs, 0);
    expect(f.pctSs, closeTo(0.1498, 0.0001));
  });

  test('A05 valor zero ou negativo → nada', () {
    expect(fatiaParaOCofre(valor: 0, data: DateTime(2026, 9, 10), tipo: TipoRendimento.servicos, regras: r).total, 0);
  });
}
