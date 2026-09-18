import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/obrigacao.dart';
import 'package:em_dia/regras/regras.dart';

/// Defeito 3 da missão em-dia-tudo-2026-09-17: «Segurança Social até domingo,
/// dia 20». Em Portugal um prazo do Estado que cai a sábado, domingo ou
/// feriado cumpre-se no dia útil seguinte.
///
/// Fontes (lidas a 2026-09-18):
///  · AT, «Resumo anual — Obrigações de pagamento em 2026», nota a): «Nos meses
///    que terminam em fim de semana ou feriado, a obrigação pode ser cumprida
///    até ao dia útil seguinte.» (info.portaldasfinancas.gov.pt/…/Quadro_res_Pag_2026.aspx)
///  · Segurança Social, Guia Prático «Pagamento de Contribuições»: «Se o último
///    dia de pagamento coincidir com um sábado, domingo ou feriado, o pagamento
///    poderá ser efetuado no dia útil seguinte.»
///  · Feriados: Código do Trabalho, art. 234.º (DRE, legislação consolidada).
///  · CRC (Lei 110/2009) art. 155.º n.º 2: contribuição dos independentes
///    «entre o dia 10 e o dia 20 do mês seguinte»; art. 151.º-A n.º 3:
///    declaração trimestral «até ao último dia dos meses de abril, julho,
///    outubro e janeiro».
void main() {
  final r = RegrasLegais.padrao2026();
  final f = r.feriados;

  group('Dia útil seguinte', () {
    test('P01 20/09/2026 é domingo → segunda, 21/09/2026', () {
      expect(prazoEfetivo(DateTime(2026, 9, 20), f), DateTime(2026, 9, 21));
    });
    test('P02 dia útil fica igual (21/09/2026, segunda)', () {
      expect(prazoEfetivo(DateTime(2026, 9, 21), f), DateTime(2026, 9, 21));
    });
    test('P03 sábado 19/09/2026 → segunda 21', () {
      expect(prazoEfetivo(DateTime(2026, 9, 19), f), DateTime(2026, 9, 21));
    });
    test('P04 feriado à sexta (25/12/2026) → segunda 28/12', () {
      expect(prazoEfetivo(DateTime(2026, 12, 25), f), DateTime(2026, 12, 28));
    });
    test('P05 feriado à segunda (1/6/2027? não é; 10/6/2027 é quinta) — 10/06/2026 é quarta feriado → quinta 11', () {
      expect(prazoEfetivo(DateTime(2026, 6, 10), f), DateTime(2026, 6, 11));
    });
    test('P06 fim-de-semana seguido de feriado: 1/11/2026 é domingo (feriado) → segunda 2/11', () {
      expect(prazoEfetivo(DateTime(2026, 11, 1), f), DateTime(2026, 11, 2));
    });
    test('P07 o aviso continua na véspera útil do dia legal (sexta 18 para o domingo 20)', () {
      expect(avisoEm(DateTime(2026, 9, 20), f), DateTime(2026, 9, 18));
    });
    test('P08 mudança de hora: 25/10/2026 (domingo, fim da hora de verão) → segunda 26/10 às 00:00, não às 23:00', () {
      // Apanhado a 18/09/2026 pelo teste dos perfis: `add(Duration(days: 1))` num dia de 25 horas caía às 23:00.
      final d = prazoEfetivo(DateTime(2026, 10, 25), f);
      expect(d, DateTime(2026, 10, 26));
      expect(d.hour, 0);
      expect(somarDias(DateTime(2026, 3, 29), 1), DateTime(2026, 3, 30)); // início da hora de verão
      expect(somarDias(DateTime(2026, 10, 26), -1), DateTime(2026, 10, 25));
    });
  });

  group('Feriados 2026 e 2027 pelo Código do Trabalho, art. 234.º', () {
    // Páscoa: 5/4/2026 e 28/3/2027 (algoritmo de Meeus, o mesmo que o calendário civil).
    DateTime pascoa(int ano) {
      final a = ano % 19, b = ano ~/ 100, c = ano % 100, d = b ~/ 4, e = b % 4, g = (8 * b + 13) ~/ 25;
      final h = (19 * a + b - d - g + 15) % 30, i = c ~/ 4, k = c % 4, l = (32 + 2 * e + 2 * i - h - k) % 7;
      final m = (a + 11 * h + 22 * l) ~/ 451, mes = (h + l - 7 * m + 114) ~/ 31, dia = (h + l - 7 * m + 114) % 31 + 1;
      return DateTime(ano, mes, dia);
    }

    Set<DateTime> pelaLei(int ano) {
      final p = pascoa(ano);
      return {
        DateTime(ano, 1, 1), DateTime(p.year, p.month, p.day - 2), p, DateTime(ano, 4, 25), DateTime(ano, 5, 1),
        DateTime(p.year, p.month, p.day + 60), DateTime(ano, 6, 10), DateTime(ano, 8, 15), DateTime(ano, 10, 5),
        DateTime(ano, 11, 1), DateTime(ano, 12, 1), DateTime(ano, 12, 8), DateTime(ano, 12, 25),
      };
    }

    test('F01 Páscoa 2026 = 5 de abril; 2027 = 28 de março', () {
      expect(pascoa(2026), DateTime(2026, 4, 5));
      expect(pascoa(2027), DateTime(2027, 3, 28));
    });
    test('F02 a tabela do espelho tem exatamente os 13 feriados de 2026 e os 13 de 2027', () {
      expect(f.where((d) => d.year == 2026).toSet(), pelaLei(2026));
      expect(f.where((d) => d.year == 2027).toSet(), pelaLei(2027));
    });
  });

  group('Gerador: o dia legal fica, o prazo efetivo anda', () {
    final hoje = DateTime(2026, 9, 6);
    final perfil = PerfilObrigacoes(
      tipoAtividade: TipoAtividade.tvde,
      dataAbertura: DateTime(2024, 1, 1),
      regimeIva: RegimeIva.isento53,
      rendimentoMensalEstimado: 1200,
    );
    final obs = gerarObrigacoes(perfil: perfil, hoje: hoje, r: r);

    test('G01 contribuição de agosto: dia legal 20/09/2026 (domingo), efetivo 21/09, aviso sexta 18/09', () {
      final ss = obs.firstWhere((o) => o.tipo == 'ss_pagamento' && o.dataLimite == DateTime(2026, 9, 20));
      expect(ss.prazoEfetivo, DateTime(2026, 9, 21));
      expect(ss.prazoMudou, isTrue);
      expect(ss.avisoEm, DateTime(2026, 9, 18));
    });
    test('G02 contribuição com dia 20 útil: efetivo = legal (20/10/2026, terça)', () {
      final ss = obs.firstWhere((o) => o.tipo == 'ss_pagamento' && o.dataLimite == DateTime(2026, 10, 20));
      expect(ss.prazoEfetivo, ss.dataLimite);
      expect(ss.prazoMudou, isFalse);
    });
    test('G03 declaração trimestral de janeiro: 31/01/2027 é domingo → 1/2/2027', () {
      final d = obs.firstWhere((o) => o.tipo == 'ss_declaracao' && o.dataLimite == DateTime(2027, 1, 31));
      expect(d.prazoEfetivo, DateTime(2027, 2, 1));
    });
    test('G04 o que NÃO é do Estado não anda: seguro ao domingo fica ao domingo', () {
      final carro = CarroObrigacoes(
        id: 'c1',
        matricula: 'AA-11-BB',
        dataMatricula: DateTime(2021, 2, 28),
        seguroRenovaEm: DateTime(2026, 9, 20),
      );
      final o2 = gerarObrigacoes(perfil: perfil, carros: [carro], hoje: hoje, r: r);
      final seguro = o2.firstWhere((o) => o.tipo == 'seguro');
      expect(seguro.dataLimite, DateTime(2026, 9, 20));
      expect(seguro.prazoEfetivo, DateTime(2026, 9, 20));
    });
    test('G05 na tabela vai `prazo_efetivo` ao lado de `data_limite`', () {
      final ss = obs.firstWhere((o) => o.tipo == 'ss_pagamento' && o.dataLimite == DateTime(2026, 9, 20));
      final m = ss.toMap('u1');
      expect(m['data_limite'], '2026-09-20');
      expect(m['prazo_efetivo'], '2026-09-21');
    });
  });

  group('O item da app conta pelo prazo efetivo', () {
    ObrigacaoItem item({DateTime? efetivo}) => ObrigacaoItem(
          id: 'x',
          userId: 'u1',
          tipo: 'ss_pagamento',
          descricao: 'Contribuição de agosto',
          dataLimite: DateTime(2026, 9, 20),
          prazoEfetivo: efetivo,
          avisoEm: DateTime(2026, 9, 18),
        );
    test('I01 na segunda 21/09 ainda não passou (o dia legal era domingo 20)', () {
      final o = item(efetivo: DateTime(2026, 9, 21));
      expect(o.passou(DateTime(2026, 9, 21)), isFalse);
      expect(o.diasParaPrazo(DateTime(2026, 9, 21)), 0);
      expect(o.passou(DateTime(2026, 9, 22)), isTrue);
    });
    test('I02 linha antiga sem a coluna: efetivo = legal', () {
      final o = item();
      expect(o.prazoEfetivo, DateTime(2026, 9, 20));
      expect(o.prazoMudou, isFalse);
    });
    test('I03 lida da tabela com prazo_efetivo', () {
      final o = ObrigacaoItem.fromMap({
        'id': 'a', 'user_id': 'u1', 'tipo': 'iuc', 'descricao': 'IUC', 'data_limite': '2026-10-31',
        'prazo_efetivo': '2026-11-02', 'aviso_em': '2026-10-30',
      });
      expect(o.prazoEfetivo, DateTime(2026, 11, 2));
      expect(o.prazoMudou, isTrue);
    });
  });
}
