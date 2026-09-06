// Os casos do "Vale a pena esta corrida?" — resultado esperado calculado À MÃO.
// Se um destes falhar, ou a regra mudou na tabela `regras_legais` ou o código
// está errado: nunca se "ajusta" o esperado para bater certo.
//
// Os números da conta são sempre os mesmos, para se ver de onde vem cada euro:
//   corrida de 10 €, 10 km, carro a gastar 6 L aos 100 km, litro a 1,75 €,
//   desgaste a 0,05 €/km.
//     combustível = 10/100 × 6 × 1,75 = 1,05 €
//     desgaste    = 10 × 0,05         = 0,50 €
//     Segurança Social = 10 × 21,4% × 70% = 1,50 € (1,498 arredondado)
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/regras/regras.dart';

void main() {
  final r = RegrasLegais.padrao2026();

  ContaDaCorrida corridaTipo({
    double pagam = 10,
    double km = 10,
    int? minutos,
    double consumo = 6,
    double preco = 1.75,
    double desgaste = 0.05,
    Retencao retencao = Retencao.padrao,
    double? rendimentoAnual,
    bool isentoSs = false,
  }) =>
      calcularValeAPena(
        pagam: pagam,
        km: km,
        minutos: minutos,
        consumoPor100: consumo,
        precoUnidade: preco,
        desgastePorKm: desgaste,
        retencao: retencao,
        rendimentoAnualEstimado: rendimentoAnual,
        isentoSs: isentoSs,
        ano: 2026,
        r: r,
      );

  group('A conta da corrida', () {
    test('VP01 corrida de 10 € com retenção de 23% — sobra 4,65 €', () {
      final c = corridaTipo(minutos: 20);
      expect(c.combustivel, 1.05);
      expect(c.desgaste, 0.50);
      expect(c.segurancaSocial, 1.50);
      expect(c.irs, 2.30); // 23% de 10 €, retidos na hora
      expect(c.estado, 3.80);
      expect(c.sobra, 4.65);
      expect(c.porHora, 13.95); // 4,65 € em 20 minutos
      expect(c.custoPorKm, 0.16); // (1,05 + 0,50) ÷ 10 km
      expect(c.irsRetidoNaHora, isTrue);
      expect(c.nivel, NivelSobra.bem);
    });

    test('VP02 retenção de 25% em vez de 23% — o IRS sobe 20 cêntimos', () {
      final c = corridaTipo(retencao: Retencao.vinteCinco);
      expect(c.irs, 2.50);
      expect(c.sobra, 4.45);
    });

    test('VP03 sem retenção, com o ano conhecido — IRS pelo escalão', () {
      // 18.000 € × 0,75 = 13.500 € de coletável → 3.º escalão de 2026 (21,2%).
      // IRS da corrida = 10 € × 0,75 × 21,2% = 1,59 €.
      final c = corridaTipo(retencao: Retencao.dispensa, rendimentoAnual: 18000);
      expect(c.irs, 1.59);
      expect(c.sobra, 5.36);
      expect(c.irsRetidoNaHora, isFalse);
      expect(c.irsNoMinimo, isFalse);
      expect(c.semIrsAPagar, isFalse);
    });

    test('VP04 sem retenção e sem saber o ano — conta o escalão mais baixo', () {
      // 1.º escalão de 2026 = 12,5%. IRS = 10 € × 0,75 × 12,5% = 0,94 €.
      final c = corridaTipo(retencao: Retencao.dispensa);
      expect(c.irs, 0.94);
      expect(c.irsNoMinimo, isTrue, reason: 'o ecrã tem de dizer que é o mínimo');
      expect(c.sobra, 6.01);
    });

    test('VP05 abaixo do mínimo de existência não há IRS nenhum', () {
      // 12.000 € × 0,75 = 9.000 € de coletável, abaixo dos 12.880 €.
      final c = corridaTipo(retencao: Retencao.dispensa, rendimentoAnual: 12000);
      expect(c.irs, 0);
      expect(c.semIrsAPagar, isTrue);
      expect(c.sobra, 6.95);
    });

    test('VP06 corrida longa e mal paga — fica a perder', () {
      // 5 €, 30 km, carro a gastar 8 L aos 100, litro a 1,90 €.
      // combustível 4,56 € · desgaste 1,50 € · SS 0,75 € · IRS 1,15 €.
      final c = corridaTipo(pagam: 5, km: 30, consumo: 8, preco: 1.90);
      expect(c.combustivel, 4.56);
      expect(c.sobra, -2.96);
      expect(c.nivel, NivelSobra.perde);
    });

    test('VP07 sobra pouco (nem verde nem vermelho)', () {
      // 10 €, 20 km, 7 L aos 100, litro a 1,80 € → sobram 2,68 €, 26,8%.
      final c = corridaTipo(km: 20, consumo: 7, preco: 1.80);
      expect(c.sobra, 2.68);
      expect(c.fracaoQueSobra, lessThan(fracaoSobraBoa));
      expect(c.nivel, NivelSobra.pouco);
    });

    test('VP08 no primeiro ano de atividade não se desconta Segurança Social', () {
      final c = corridaTipo(isentoSs: true);
      expect(c.segurancaSocial, 0);
      expect(c.sobra, 6.15);
    });

    test('VP09 sem minutos não há valor por hora (e não se inventa um)', () {
      expect(corridaTipo().porHora, isNull);
      expect(corridaTipo(minutos: 0).porHora, isNull);
    });

    test('VP10 corrida sem quilómetros: sem combustível e sem desgaste', () {
      final c = corridaTipo(km: 0);
      expect(c.combustivel, 0);
      expect(c.desgaste, 0);
      expect(c.custoPorKm, 0);
      expect(c.sobra, 6.20);
    });

    test('VP11 quilómetros negativos não dão troco: contam como zero', () {
      final c = corridaTipo(km: -10);
      expect(c.km, 0);
      expect(c.combustivel, 0);
    });
  });

  group('As fatias do Estado', () {
    test('VP12 a fatia da Segurança Social é a mesma que a conta trimestral dá', () {
      // A prova de que [taxaSsPorEuro] não é um número à parte: num trimestre
      // já acima do mínimo de 20 €/mês e abaixo do teto de 12 × IAS, a conta
      // oficial da Segurança Social dá exatamente a mesma fatia por euro.
      final trimestral = calcularSS(
          rendimentoTrimestre: 9000, tipo: TipoRendimento.servicos, r: r);
      expect(trimestral.bateuNoMinimo, isFalse);
      expect(trimestral.bateuNoMaximo, isFalse);
      expect(trimestral.contribuicaoMensal / (9000 / 3),
          closeTo(taxaSsPorEuro(r), 0.0000001));
      expect(taxaSsPorEuro(r), closeTo(0.1498, 0.0000001)); // 21,4% de 70%
    });

    test('VP13 o escalão do IRS é o do rendimento do ano, não o da corrida', () {
      expect(
          taxaIrsDoEscalao(
              rendimentoAnualEstimado: 12000, // coletável 9.000 €
              tipo: TipoRendimento.servicos,
              ano: 2026,
              r: r),
          0);
      expect(
          taxaIrsDoEscalao(
              rendimentoAnualEstimado: 18000, // coletável 13.500 €
              tipo: TipoRendimento.servicos,
              ano: 2026,
              r: r),
          0.212);
      expect(
          taxaIrsDoEscalao(
              rendimentoAnualEstimado: 40000, // coletável 30.000 €
              tipo: TipoRendimento.servicos,
              ano: 2026,
              r: r),
          0.349);
    });
  });

  group('O preço do combustível vem do último abastecimento', () {
    final antigo = AbastecimentoLinha(
        data: DateTime(2026, 8, 1), valorTotal: 60, litros: 40, km: 100000);
    final recente = AbastecimentoLinha(
        data: DateTime(2026, 9, 3), valorTotal: 71.56, litros: 40, km: 100500);
    final semLitros =
        AbastecimentoLinha(data: DateTime(2026, 9, 5), valorTotal: 20, km: 100600);

    test('VP14 o preço é o do último, com três casas', () {
      final p = precoDoUltimoAbastecimento([antigo, recente]);
      expect(p, isNotNull);
      // 71,56 € ÷ 40 L = 1,789 €/L. A cêntimos dava 1,79 € — em 500 km isso
      // já é dinheiro a sério, por isso guardam-se três casas.
      expect(p!.valor, 1.789);
      expect(p.data, DateTime(2026, 9, 3));
    });

    test('VP15 um abastecimento sem litros escritos não serve para o preço', () {
      final p = precoDoUltimoAbastecimento([antigo, recente, semLitros]);
      expect(p!.data, DateTime(2026, 9, 3), reason: 'ficou o último que tem litros');
    });

    test('VP16 sem abastecimentos não se inventa preço nenhum', () {
      expect(precoDoUltimoAbastecimento(const []), isNull);
      expect(precoDoUltimoAbastecimento([semLitros]), isNull);
    });

    test('VP17 o consumo sai dos dois depósitos cheios: 40 L em 500 km', () {
      expect(consumoDosAbastecimentos([antigo, recente]), 8.0);
      expect(consumoDosAbastecimentos([antigo]), isNull,
          reason: 'com um só depósito não há distância percorrida para medir');
    });
  });
}
