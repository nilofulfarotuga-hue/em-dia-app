// B3 (2026-09-18): as contas de quem tem contrato — resultados esperados
// calculados À MÃO a partir das fontes em docs/REGRAS-PT-2026.md. Se um
// destes falhar, mudou a regra na tabela ou o código está errado; nunca se
// «ajusta» o esperado para bater certo.
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/regras/regras.dart';

void main() {
  final r = RegrasLegais.padrao2026();

  group('Recibo de vencimento', () {
    test('H01 1.200 € brutos: SS 11 % = 132,00; IRS retido 96,50 → líquido 971,50', () {
      final rv = lerReciboVencimento(bruto: 1200, irsRetido: 96.50, r: r);
      expect(rv.ssTrabalhador, 132.00);
      expect(rv.pctSs, 11);
      expect(rv.liquido, 971.50);
      expect(rv.descontos, 228.50);
    });
    test('H02 salário mínimo 920 €: SS 101,20; sem retenção → líquido 818,80', () {
      final rv = lerReciboVencimento(bruto: r.n('smn'), irsRetido: 0, r: r);
      expect(rv.bruto, 920);
      expect(rv.ssTrabalhador, 101.20);
      expect(rv.liquido, 818.80);
    });
  });

  group('IRS anual de quem tem contrato', () {
    // 1.200 € × 14 = 16.800 brutos. Dedução específica = max(8,54 × 537,13 = 4.587,09; SS 11 % = 1.848) = 4.587,09.
    // Coletável 12.212,91 → 2.º escalão (8.342–12.587): × 15,7 % − 266,94 = 1.917,43 − 266,94 = 1.650,49.
    test('H03 1.200 €/mês com 96,50 € retidos: imposto 1.650,49; retido 1.351,00 → acerto a pagar 299,49', () {
      final e = estimarIrsContrato(brutoMensal: 1200, irsRetidoMensal: 96.50, ano: 2026, r: r);
      expect(e.brutoAnual, 16800);
      expect(e.deducaoEspecifica, 4587.09);
      expect(e.coletavel, 12212.91);
      expect(e.imposto, 1650.49);
      expect(e.retidoAnual, 1351.00);
      expect(e.diferenca, -299.49);
      expect(e.reembolso, isFalse);
      expect(e.escaloesConfirmados, isTrue);
    });
    test('H04 com 150 € retidos por mês fica reembolso de 449,51', () {
      final e = estimarIrsContrato(brutoMensal: 1200, irsRetidoMensal: 150, ano: 2026, r: r);
      expect(e.retidoAnual, 2100);
      expect(e.diferenca, 449.51);
      expect(e.reembolso, isTrue);
    });
    test('H05 abaixo do mínimo de existência não há imposto: 800 € × 14 = 11.200 ≤ 12.880', () {
      final e = estimarIrsContrato(brutoMensal: 800, irsRetidoMensal: 0, ano: 2026, r: r);
      expect(e.imposto, 0);
      expect(e.diferenca, 0);
    });
    test('H06 salário alto: as contribuições (11 %) passam a ser a dedução específica', () {
      // 3.500 × 14 = 49.000; SS = 5.390 > 4.587,09 → dedução 5.390.
      final e = estimarIrsContrato(brutoMensal: 3500, irsRetidoMensal: 800, ano: 2026, r: r);
      expect(e.deducaoEspecifica, 5390);
      expect(e.coletavel, 43610);
      // 7.º escalão (43.090–46.566): 43.610 × 43,1 % − 7.743,23 = 18.795,91 − 7.743,23 = 11.052,68
      expect(e.imposto, 11052.68);
    });
  });

  group('IRS Jovem (CIRS art. 12.º-B)', () {
    test('H07 26 anos, 1.º ano de rendimentos: 100 % isento até 55 × IAS = 29.542,15 €', () {
      final j = irsJovem(idadeEm31Dez: 26, anoDeRendimentos: 1, r: r);
      expect(j.elegivel, isTrue);
      expect(j.pctIsencao, 100);
      expect(j.limiteEur, 29542.15);
    });
    test('H08 os escalões por ano: 2.º–4.º 75 %, 5.º–7.º 50 %, 8.º–10.º 25 %', () {
      expect(irsJovem(idadeEm31Dez: 30, anoDeRendimentos: 2, r: r).pctIsencao, 75);
      expect(irsJovem(idadeEm31Dez: 30, anoDeRendimentos: 4, r: r).pctIsencao, 75);
      expect(irsJovem(idadeEm31Dez: 30, anoDeRendimentos: 5, r: r).pctIsencao, 50);
      expect(irsJovem(idadeEm31Dez: 30, anoDeRendimentos: 7, r: r).pctIsencao, 50);
      expect(irsJovem(idadeEm31Dez: 30, anoDeRendimentos: 8, r: r).pctIsencao, 25);
      expect(irsJovem(idadeEm31Dez: 30, anoDeRendimentos: 10, r: r).pctIsencao, 25);
    });
    test('H09 36 anos já não conta; 11.º ano de rendimentos também não', () {
      expect(irsJovem(idadeEm31Dez: 36, anoDeRendimentos: 3, r: r).elegivel, isFalse);
      expect(irsJovem(idadeEm31Dez: 36, anoDeRendimentos: 3, r: r).motivo, 'idade');
      expect(irsJovem(idadeEm31Dez: 35, anoDeRendimentos: 11, r: r).elegivel, isFalse);
      expect(irsJovem(idadeEm31Dez: 35, anoDeRendimentos: 11, r: r).motivo, 'anos');
      expect(irsJovem(idadeEm31Dez: 35, anoDeRendimentos: 10, r: r).elegivel, isTrue);
    });
  });

  group('Subsídio de desemprego (Guia Prático ISS 2026)', () {
    test('H10 400 dias de descontos em 24 meses: tem direito; 1.200 € → 65 % = 780,00 €/mês; pedir até 90 dias', () {
      final d = estimarDesemprego(diasDeDescontosEm24Meses: 400, salarioBrutoMensal: 1200, dataDesemprego: DateTime(2026, 9, 18), r: r);
      expect(d.temDireito, isTrue);
      expect(d.valorMensalEstimado, 780.00);
      expect(d.pedirAte, DateTime(2026, 12, 17));
      expect(d.prazoGarantiaDias, 360);
    });
    test('H11 com 300 dias faltam 60; salário mínimo bate no mínimo de 617,70 €; 4.000 € bate no teto de 1.342,83 €', () {
      final d = estimarDesemprego(diasDeDescontosEm24Meses: 300, salarioBrutoMensal: 920, dataDesemprego: DateTime(2026, 9, 18), r: r);
      expect(d.temDireito, isFalse);
      expect(d.diasQueFaltam, 60);
      expect(d.valorMensalEstimado, 617.70);
      final alto = estimarDesemprego(diasDeDescontosEm24Meses: 400, salarioBrutoMensal: 4000, dataDesemprego: DateTime(2026, 9, 18), r: r);
      expect(alto.valorMensalEstimado, 1342.83);
    });
  });

  group('Horas extra (CT art. 268.º e 271.º)', () {
    test('H12 1.200 €, 40 h: hora = 6,92; 1.ª hora extra 8,65; seguintes 9,52; fim de semana 10,38', () {
      // (1.200 × 12) ÷ (52 × 40) = 14.400 ÷ 2.080 = 6,923 → 6,92
      final h = valorHoraExtra(brutoMensal: 1200, r: r);
      expect(h.base, 6.92);
      expect(h.primeiraHora, 8.65); // +25 %
      expect(h.horaSeguinte, 9.52); // +37,5 %
      expect(h.descansoOuFeriado, 10.38); // +50 %
    });
    test('H13 depois das 100 horas no ano: +50 %, +75 %, +100 %', () {
      final h = valorHoraExtra(brutoMensal: 1200, maisDe100hNoAno: true, r: r);
      expect(h.primeiraHora, 10.38);
      expect(h.horaSeguinte, 12.11);
      expect(h.descansoOuFeriado, 13.84);
    });
  });
}
