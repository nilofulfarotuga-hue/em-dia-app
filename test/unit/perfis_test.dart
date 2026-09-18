// B3 (2026-09-18): os três perfis — recibos verdes, contrato, empresa — e o
// que cada um vê no calendário. Datas conferidas com a agenda fiscal da AT
// de 2026 e com o Código do Trabalho (docs/REGRAS-PT-2026.md).
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:em_dia/models/obrigacao.dart';
import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/screens/calendario/tipos_obrigacao.dart';

void main() {
  final r = RegrasLegais.padrao2026();
  final hoje = DateTime(2026, 9, 18);

  List<Obrigacao> gerar(PerfilObrigacoes p) => gerarObrigacoes(perfil: p, hoje: hoje, r: r);
  Set<String> tipos(List<Obrigacao> o) => o.map((x) => x.tipo).toSet();
  List<Obrigacao> dos(List<Obrigacao> o, String tipo) => o.where((x) => x.tipo == tipo).toList();

  group('Contrato', () {
    final p = const PerfilObrigacoes(
      tipoAtividade: TipoAtividade.semAtividade,
      tipoTrabalho: TipoTrabalho.contrato,
      salarioBrutoMensal: 1200,
    );
    test('P01 vê IRS, e-fatura, subsídio de Natal e o lembrete das faturas; NÃO vê SS nem IVA de independente', () {
      final o = gerar(p);
      expect(tipos(o), containsAll(['irs_entrega', 'efatura_validar', 'subsidio_natal', 'faturas_nif']));
      expect(tipos(o).intersection({'ss_declaracao', 'ss_pagamento', 'iva_declaracao', 'iva_pagamento', 'irs_pagamento_conta', 'fim_isencao_ss'}), isEmpty);
    });
    test('P02 o subsídio de Natal é a 15 de dezembro, vale um salário e é lembrete (não é o herói)', () {
      final n = dos(gerar(p), 'subsidio_natal');
      expect(n.length, 1);
      expect(n.first.dataLimite, DateTime(2026, 12, 15));
      expect(n.first.valorEstimado, 1200);
      expect(tiposLembrete.contains('subsidio_natal'), isTrue);
    });
    test('P03 «pede fatura com NIF» todos os meses, no último dia, 12 vezes em 12 meses', () {
      final f = dos(gerar(p), 'faturas_nif');
      expect(f.length, 12);
      expect(f.first.dataLimite, DateTime(2026, 9, 30));
      expect(f.every((x) => x.valorEstimado == null), isTrue);
    });
    test('P04 a entrega do IRS diz «anexo A»', () {
      final i = dos(gerar(p), 'irs_entrega').first;
      expect(i.descricao, contains('anexo A'));
      expect(i.dataLimite, DateTime(2027, 6, 30));
    });
  });

  group('Os dois (recibos verdes + contrato)', () {
    final p = PerfilObrigacoes(
      tipoAtividade: TipoAtividade.tvde,
      tipoTrabalho: TipoTrabalho.ambos,
      dataAbertura: DateTime(2024, 3, 1),
      rendimentoMensalEstimado: 800,
      salarioBrutoMensal: 1000,
    );
    test('P05 tem a Segurança Social de independente E o subsídio de Natal; IRS com anexos A e B', () {
      final o = gerar(p);
      expect(tipos(o), containsAll(['ss_declaracao', 'ss_pagamento', 'subsidio_natal', 'faturas_nif', 'irs_entrega']));
      expect(dos(o, 'irs_entrega').first.descricao, contains('anexos A e B'));
    });
  });

  group('Empresa — ENI, IVA trimestral', () {
    final p = const PerfilObrigacoes(
      tipoAtividade: TipoAtividade.semAtividade,
      tipoTrabalho: TipoTrabalho.empresa,
      empresaTipo: 'eni',
      ivaPeriodicidade: 'trimestral',
    );
    test('P06 vê IVA trimestral, SAF-T, DMR e SS da empresa todos os meses; sem IRC nem IES (é ENI)', () {
      final o = gerar(p);
      expect(tipos(o), containsAll(['iva_declaracao', 'iva_pagamento', 'saft', 'dmr', 'ss_empresa', 'irs_entrega']));
      expect(tipos(o).intersection({'irc_modelo22', 'ies', 'irc_pagamento_conta'}), isEmpty);
      expect(dos(o, 'saft').length, 12);
      expect(dos(o, 'dmr').length, 12);
      expect(dos(o, 'ss_empresa').length, 12);
      expect(dos(o, 'iva_declaracao').length, 4);
    });
    test('P07 SAF-T a 5, DMR a 10, SS até 25 — e ao fim-de-semana passam ao dia útil seguinte', () {
      final o = gerar(p);
      final saftOut = dos(o, 'saft').firstWhere((x) => x.dataLimite.month == 10);
      expect(saftOut.dataLimite, DateTime(2026, 10, 5)); // segunda-feira, mas é feriado (5 de outubro)
      expect(saftOut.prazoEfetivo, DateTime(2026, 10, 6)); // a agenda da AT 2026 põe «6» em outubro — bate certo
      final dmrOut = dos(o, 'dmr').firstWhere((x) => x.dataLimite.month == 10);
      expect(dmrOut.dataLimite, DateTime(2026, 10, 10)); // sábado → segunda 12 (a AT põe 12 na agenda de 2026)
      expect(dmrOut.prazoEfetivo, DateTime(2026, 10, 12));
      final ssOut = dos(o, 'ss_empresa').firstWhere((x) => x.dataLimite.month == 10);
      expect(ssOut.dataLimite, DateTime(2026, 10, 25)); // domingo → segunda 26
      expect(ssOut.prazoEfetivo, DateTime(2026, 10, 26));
    });
    test('P08 IVA do 3.º trimestre: declaração a 20 de novembro e pagamento a 25', () {
      final o = gerar(p);
      expect(dos(o, 'iva_declaracao').map((x) => x.dataLimite), contains(DateTime(2026, 11, 20)));
      expect(dos(o, 'iva_pagamento').map((x) => x.dataLimite), contains(DateTime(2026, 11, 25)));
    });
  });

  group('Empresa — sociedade, IVA mensal', () {
    final p = const PerfilObrigacoes(
      tipoAtividade: TipoAtividade.semAtividade,
      tipoTrabalho: TipoTrabalho.empresa,
      empresaTipo: 'sociedade',
      ivaPeriodicidade: 'mensal',
    );
    test('P09 IVA mensal: a declaração de setembro é a 20 de novembro (2.º mês seguinte) e paga-se a 25', () {
      final o = gerar(p);
      final set = dos(o, 'iva_declaracao').firstWhere((x) => x.descricao.contains('setembro de 2026'));
      expect(set.dataLimite, DateTime(2026, 11, 20));
      final pag = dos(o, 'iva_pagamento').firstWhere((x) => x.descricao.contains('setembro de 2026'));
      expect(pag.dataLimite, DateTime(2026, 11, 25));
      expect(dos(o, 'iva_declaracao').length, 12);
    });
    test('P10 Modelo 22 a 31 de maio, IES a 15 de julho, pagamentos por conta a 31 jul / 30 set / 15 dez', () {
      final o = gerar(p);
      expect(dos(o, 'irc_modelo22').single.dataLimite, DateTime(2027, 5, 31));
      expect(dos(o, 'ies').single.dataLimite, DateTime(2027, 7, 15));
      expect(dos(o, 'irc_pagamento_conta').map((x) => x.dataLimite).toList(), [DateTime(2026, 9, 30), DateTime(2026, 12, 15), DateTime(2027, 7, 31)]);
    });
    test('P11 o IRS pessoal continua a existir para quem tem sociedade', () {
      expect(dos(gerar(p), 'irs_entrega').first.descricao, contains('IRS pessoal'));
    });
  });

  group('Todos os tipos gerados têm nome, ícone, grupo e caminho na app', () {
    test('P13 nenhum tipo novo cai no «Obrigação» genérico nem fica sem página certa', () {
      final perfis = [
        const PerfilObrigacoes(tipoAtividade: TipoAtividade.semAtividade, tipoTrabalho: TipoTrabalho.contrato, salarioBrutoMensal: 1000),
        const PerfilObrigacoes(tipoAtividade: TipoAtividade.semAtividade, tipoTrabalho: TipoTrabalho.empresa, empresaTipo: 'sociedade', ivaPeriodicidade: 'mensal'),
        PerfilObrigacoes(tipoAtividade: TipoAtividade.tvde, dataAbertura: DateTime(2025, 6, 1), rendimentoMensalEstimado: 1200, regimeIva: RegimeIva.normal),
      ];
      for (final p in perfis) {
        for (final o in gerar(p)) {
          final item = ObrigacaoItem.deGerada(o, 'u');
          expect(item.nomeCurto, isNot('Obrigação'), reason: 'tipo sem nome curto: ${o.tipo}');
          expect(iconeDoTipo(o.tipo), isNot(Icons.event_note_rounded), reason: 'tipo sem ícone: ${o.tipo}');
          if (o.tipo != 'subsidio_natal') { // o Natal é «outros» de propósito: não é SS, fiscal nem carro
            expect(grupoDoTipo(o.tipo), isNot(GrupoObrigacao.outros), reason: 'tipo fora dos grupos: ${o.tipo}');
          }
        }
      }
    });
  });

  group('Recibos verdes (o que já existia não mudou)', () {
    final p = PerfilObrigacoes(tipoAtividade: TipoAtividade.tvde, dataAbertura: DateTime(2025, 6, 1), rendimentoMensalEstimado: 1200);
    test('P12 sem contrato nem empresa: nada de subsídio de Natal, faturas_nif, DMR ou SAF-T', () {
      final o = gerar(p);
      expect(tipos(o).intersection({'subsidio_natal', 'faturas_nif', 'dmr', 'saft', 'ss_empresa', 'irc_modelo22', 'ies'}), isEmpty);
      expect(tipos(o), containsAll(['ss_declaracao', 'ss_pagamento', 'irs_entrega', 'efatura_validar']));
    });
  });
}
