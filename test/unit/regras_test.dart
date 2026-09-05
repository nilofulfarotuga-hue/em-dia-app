// Os casos de teste das regras — resultado esperado calculado À MÃO (ver
// docs/casos-teste.md, gerado a partir deste ficheiro). Se um teste falhar, a
// regra mudou ou o código está errado: nunca se "ajusta" o esperado para bater.
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/regras/regras.dart';

void main() {
  final r = RegrasLegais.padrao2026();
  final hoje = DateTime(2026, 9, 6);

  group('Calculadora de recibo', () {
    test('C01 1000 €, retenção 23%, isento de IVA', () {
      final c = calcularRecibo(valor: 1000, retencao: Retencao.padrao, isentoIva: true, r: r);
      expect(c.iva, 0);
      expect(c.retencao, 230);
      expect(c.recebesNaConta, 770);
      expect(c.ficaTeu, 770);
      expect(c.mencaoIsencao, contains('artigo 53'));
    });
    test('C02 1000 €, retenção 25%, IVA 23%', () {
      final c = calcularRecibo(valor: 1000, retencao: Retencao.vinteCinco, isentoIva: false, r: r);
      expect(c.iva, 230);
      expect(c.totalFatura, 1230);
      expect(c.retencao, 250);
      expect(c.recebesNaConta, 980);
      expect(c.ficaTeu, 750);
      expect(c.mencaoIsencao, isNull);
    });
    test('C03 500 €, dispensa de retenção, isento', () {
      final c = calcularRecibo(valor: 500, retencao: Retencao.dispensa, isentoIva: true, r: r);
      expect(c.retencao, 0);
      expect(c.recebesNaConta, 500);
    });
    test('C04 1234,56 € com cêntimos (IVA e retenção arredondados)', () {
      final c = calcularRecibo(valor: 1234.56, retencao: Retencao.padrao, isentoIva: false, r: r);
      expect(c.iva, 283.95);
      expect(c.retencao, 283.95);
      expect(c.recebesNaConta, 1234.56);
      expect(c.ficaTeu, 950.61);
    });
    test('C05 dispensa só abaixo de 15.000 € no ano anterior', () {
      expect(podeDispensarRetencao(faturacaoAnoAnterior: 14999.99, r: r), isTrue);
      expect(podeDispensarRetencao(faturacaoAnoAnterior: 15000, r: r), isFalse);
    });
  });

  group('Vigia do IVA', () {
    test('C06 8.000 € → ok, falta 7.000', () {
      final v = vigiaIva(acumuladoAno: 8000, r: r);
      expect(v.nivel, NivelIva.ok);
      expect(v.faltaParaLimite, 7000);
      expect(v.fracao, closeTo(0.5333, 0.001));
    });
    test('C07 12.000 € → aviso', () {
      expect(vigiaIva(acumuladoAno: 12000, r: r).nivel, NivelIva.aviso);
    });
    test('C08 15.000 € é aviso; 15.000,01 € é alarme', () {
      expect(vigiaIva(acumuladoAno: 15000, r: r).nivel, NivelIva.aviso);
      expect(vigiaIva(acumuladoAno: 15000.01, r: r).nivel, NivelIva.alarme);
      expect(cobraIvaNoProximoAno(faturacaoEsteAno: 15000.01, r: r), isTrue);
    });
    test('C09 18.750 € é alarme; 18.750,01 € é crítico (perde já)', () {
      expect(vigiaIva(acumuladoAno: 18750, r: r).nivel, NivelIva.alarme);
      expect(vigiaIva(acumuladoAno: 18750.01, r: r).nivel, NivelIva.critico);
    });
  });

  group('Segurança Social', () {
    test('C10 1.000 €/mês serviços → 149,80 €/mês', () {
      final c = calcularSS(rendimentoTrimestre: 3000, tipo: TipoRendimento.servicos, r: r);
      expect(c.rendimentoMensalRelevante, 700);
      expect(c.contribuicaoMensal, 149.80);
      expect(c.contribuicaoTrimestre, 449.40);
      expect(c.bateuNoMinimo, isFalse);
      expect(c.bateuNoMaximo, isFalse);
    });
    test('C11 ajuste −25% → 112,35 €; +25% → 187,25 €', () {
      expect(calcularSS(rendimentoTrimestre: 3000, tipo: TipoRendimento.servicos, ajustePct: -25, r: r).contribuicaoMensal, 112.35);
      expect(calcularSS(rendimentoTrimestre: 3000, tipo: TipoRendimento.servicos, ajustePct: 25, r: r).contribuicaoMensal, 187.25);
    });
    test('C12 ajuste fora do limite é tapado a ±25%', () {
      expect(calcularSS(rendimentoTrimestre: 3000, tipo: TipoRendimento.servicos, ajustePct: -40, r: r).ajustePct, -25);
    });
    test('C13 100 €/mês → mínimo de 20 €', () {
      final c = calcularSS(rendimentoTrimestre: 300, tipo: TipoRendimento.servicos, r: r);
      expect(c.contribuicaoMensal, 20);
      expect(c.contribuicaoTrimestre, 60);
      expect(c.bateuNoMinimo, isTrue);
    });
    test('C14 vendas 1.000 €/mês → base 20% → 42,80 €', () {
      final c = calcularSS(rendimentoTrimestre: 3000, tipo: TipoRendimento.vendas, r: r);
      expect(c.baseIncidencia, 200);
      expect(c.contribuicaoMensal, 42.80);
    });
    test('C15 20.000 €/mês → teto 12×IAS (6.445,56 €) → 1.379,35 €', () {
      final c = calcularSS(rendimentoTrimestre: 60000, tipo: TipoRendimento.servicos, r: r);
      expect(c.baseIncidencia, 6445.56);
      expect(c.contribuicaoMensal, 1379.35);
      expect(c.bateuNoMaximo, isTrue);
    });
    test('C16 isenção: abriu 15/03/2026 → paga desde 01/03/2027; 1.ª declaração abril 2027', () {
      final abertura = DateTime(2026, 3, 15);
      expect(fimIsencaoSS(abertura, r), DateTime(2027, 3, 1));
      expect(ultimoDiaIsencaoSS(abertura, r), DateTime(2027, 2, 28));
      expect(primeiraDeclaracaoTrimestral(abertura, r), DateTime(2027, 4, 1));
      expect(mesesDeIsencaoRestantes(abertura, hoje, r), 6);
    });
    test('C17 isenção: abriu 31/12/2026 → paga desde 01/12/2027; 1.ª declaração janeiro 2028', () {
      final abertura = DateTime(2026, 12, 31);
      expect(fimIsencaoSS(abertura, r), DateTime(2027, 12, 1));
      expect(primeiraDeclaracaoTrimestral(abertura, r), DateTime(2028, 1, 1));
    });
    test('C18 isenção: abriu 29/02/2028 (bissexto) → paga desde 01/02/2029', () {
      final abertura = DateTime(2028, 2, 29);
      expect(fimIsencaoSS(abertura, r), DateTime(2029, 2, 1));
      expect(ultimoDiaIsencaoSS(abertura, r), DateTime(2029, 1, 31));
    });
    test('C19 prazos: declaração até ao último dia do mês; pagamento até dia 20', () {
      expect(prazoDeclaracaoTrimestral(2027, 4), DateTime(2027, 4, 30));
      expect(prazoDeclaracaoTrimestral(2026, 1), DateTime(2026, 1, 31));
      expect(prazoPagamentoSS(2027, 3, r), DateTime(2027, 3, 20));
    });
  });

  group('IRS (regime simplificado)', () {
    test('C20 12.000 € serviços 2025 → abaixo do mínimo de existência → 0', () {
      final p = calcularIrs(rendimentoBrutoAnual: 12000, tipo: TipoRendimento.servicos, ano: 2025, r: r);
      expect(p.rendimentoColetavel, 9000);
      expect(p.abaixoMinimoExistencia, isTrue);
      expect(p.impostoEstimado, 0);
      expect(p.guardarPorMes, 0);
    });
    test('C21 24.000 € serviços 2025 → coletável 18.000 → 2.941,37 €; 245,11 €/mês; PPC 637,30 €', () {
      final p = calcularIrs(rendimentoBrutoAnual: 24000, tipo: TipoRendimento.servicos, ano: 2025, r: r);
      expect(p.rendimentoColetavel, 18000);
      expect(p.impostoEstimado, 2941.37);
      expect(p.guardarPorMes, 245.11);
      expect(p.pagamentoPorContaCada, 637.30);
      expect(p.taxaEfetivaPct, 12.26);
      expect(p.justificarDespesas, isFalse);
      expect(p.escaloesConfirmados, isTrue);
    });
    test('C22 40.000 € serviços 2025 → 6.463,95 €; tem de justificar despesas', () {
      final p = calcularIrs(rendimentoBrutoAnual: 40000, tipo: TipoRendimento.servicos, ano: 2025, r: r);
      expect(p.impostoEstimado, 6463.95);
      expect(p.justificarDespesas, isTrue);
    });
    test('C23 40.000 € vendas 2025 → coletável 6.000 → 0', () {
      final p = calcularIrs(rendimentoBrutoAnual: 40000, tipo: TipoRendimento.vendas, ano: 2025, r: r);
      expect(p.rendimentoColetavel, 6000);
      expect(p.impostoEstimado, 0);
    });
    test('C24 100.000 € serviços 2025 → 25.355,56 €', () {
      final p = calcularIrs(rendimentoBrutoAnual: 100000, tipo: TipoRendimento.servicos, ano: 2025, r: r);
      expect(p.impostoEstimado, 25355.56);
    });
    test('C25 2026: escalões POR CONFIRMAR ficam marcados; 24.000 € → 2.861,42 €', () {
      final p = calcularIrs(rendimentoBrutoAnual: 24000, tipo: TipoRendimento.servicos, ano: 2026, r: r);
      expect(p.escaloesConfirmados, isFalse);
      expect(p.anoEscaloes, 2026);
      expect(p.impostoEstimado, 2861.42);
    });
    test('C26 datas: PPC 20 jul/set/dez; entrega até 30 jun; e-fatura até 25 fev', () {
      expect(datasPagamentosPorConta(2026, r), [DateTime(2026, 7, 20), DateTime(2026, 9, 20), DateTime(2026, 12, 20)]);
      expect(prazoEntregaIrs(2027, r), DateTime(2027, 6, 30));
      expect(inicioEntregaIrs(2027, r), DateTime(2027, 4, 1));
      expect(prazoValidarEfatura(2027, r), DateTime(2027, 2, 25));
    });
  });

  group('Carro', () {
    test('C27 IUC: matrícula de fevereiro → até 28/02 (29 em bissexto)', () {
      expect(prazoIuc(mesMatricula: 2, ano: 2026), DateTime(2026, 2, 28));
      expect(prazoIuc(mesMatricula: 2, ano: 2028), DateTime(2028, 2, 29));
      expect(proximoIuc(mesMatricula: 2, hoje: hoje), DateTime(2027, 2, 28));
      expect(proximoIuc(mesMatricula: 10, hoje: hoje), DateTime(2026, 10, 31));
    });
    test('C28 IPO ligeiro 2021: 4/6/8 anos e depois anual', () {
      final m = DateTime(2021, 2, 15);
      final cal = calendarioIpo(matricula: m, ate: DateTime(2031, 12, 31), r: r);
      expect(cal.take(5).toList(), [
        DateTime(2025, 2, 15), DateTime(2027, 2, 15), DateTime(2029, 2, 15),
        DateTime(2030, 2, 15), DateTime(2031, 2, 15),
      ]);
      expect(proximaIpo(matricula: m, hoje: hoje, r: r), DateTime(2027, 2, 15));
      expect(proximaIpo(matricula: m, ultimaIpo: DateTime(2025, 2, 20), hoje: hoje, r: r), DateTime(2027, 2, 15));
    });
    test('C29 IPO carro de 2015 com inspeção feita em junho de 2026 → junho de 2027', () {
      final m = DateTime(2015, 6, 10);
      expect(proximaIpo(matricula: m, ultimaIpo: DateTime(2026, 6, 12), hoje: hoje, r: r), DateTime(2027, 6, 10));
    });
    test('C30 IPO TVDE: anual (POR CONFIRMAR)', () {
      final m = DateTime(2024, 2, 15);
      expect(proximaIpo(matricula: m, hoje: hoje, tvde: true, r: r), DateTime(2027, 2, 15));
      expect(r.regra('ipo_tvde')!.confirmada, isFalse);
    });
    test('C31 carta: 15 anos até aos 60, 5 até aos 70, depois 2', () {
      expect(anosValidadeCarta(35, r), 15);
      expect(anosValidadeCarta(65, r), 5);
      expect(anosValidadeCarta(72, r), 2);
    });
    test('C32 multa notificada a 10/09/2026 → 15 dias úteis → 01/10/2026', () {
      expect(prazoMulta(DateTime(2026, 9, 10), r), DateTime(2026, 10, 1));
    });
    test('C33 IUC estimado: 1199 cc, 120 g CO2 (WLTP), 2021 → 111,48 €; elétrico → 0', () {
      final e = estimarIuc(matricula: DateTime(2021, 2, 15), combustivel: Combustivel.gasolina, cilindradaCc: 1199, co2: 120, r: r)!;
      expect(e.valor, 111.48);
      expect(e.aproximado, isTrue);
      expect(estimarIuc(matricula: DateTime(2021, 2, 15), combustivel: Combustivel.eletrico, r: r)!.valor, 0);
    });
    test('C34 custo por km: 500 km com 45 € → 0,09 €/km, 5,4 L/100', () {
      final c = custoPorKm([
        AbastecimentoLinha(data: DateTime(2026, 9, 1), valorTotal: 50, litros: 30, km: 10000),
        AbastecimentoLinha(data: DateTime(2026, 9, 10), valorTotal: 45, litros: 27, km: 10500),
      ])!;
      expect(c.kmPercorridos, 500);
      expect(c.custoPorKm, 0.09);
      expect(c.litrosPor100Km, 5.4);
    });
    test('C35 seguro: aviso 45 dias antes', () {
      expect(avisoSeguro(DateTime(2027, 5, 15), r), DateTime(2027, 3, 31));
    });
  });

  group('Datas e formatos', () {
    test('C36 véspera útil: domingo, sábado, feriado', () {
      expect(avisoEm(DateTime(2026, 9, 20), r.feriados), DateTime(2026, 9, 18));
      expect(avisoEm(DateTime(2026, 10, 31), r.feriados), DateTime(2026, 10, 30));
      expect(avisoEm(DateTime(2026, 12, 25), r.feriados), DateTime(2026, 12, 24));
      expect(avisoEm(DateTime(2026, 6, 10), r.feriados), DateTime(2026, 6, 9));
      expect(avisoEm(DateTime(2026, 9, 7), r.feriados), DateTime(2026, 9, 7));
    });
    test('C37 15 dias úteis a partir de 01/12/2026 (feriado + 8/12) → 23/12/2026', () {
      expect(somarDiasUteis(DateTime(2026, 12, 1), 15, r.feriados), DateTime(2026, 12, 23));
    });
    test('C38 somar meses prende o dia ao fim do mês', () {
      expect(adicionarMeses(DateTime(2027, 1, 31), 1), DateTime(2027, 2, 28));
      expect(adicionarMeses(DateTime(2028, 1, 31), 1), DateTime(2028, 2, 29));
      expect(adicionarMeses(DateTime(2026, 11, 15), 2), DateTime(2027, 1, 15));
      expect(adicionarMeses(DateTime(2026, 3, 1), -1), DateTime(2026, 2, 1));
    });
    test('C39 moeda 1.234,56 € e datas dd/mm/aaaa', () {
      expect(moeda(1234.56), '1.234,56 €');
      expect(moeda(1234567.891), '1.234.567,89 €');
      expect(moeda(0.5), '0,50 €');
      expect(moeda(-20), '-20,00 €');
      expect(dataPt(DateTime(2026, 9, 6)), '06/09/2026');
      expect(pct(21.4), '21,4%');
    });
    test('C40 ler números escritos à portuguesa e à inglesa', () {
      expect(lerNumero('1.234,56'), 1234.56);
      expect(lerNumero('1234.56'), 1234.56);
      expect(lerNumero('12,5'), 12.5);
      expect(lerNumero('1 250 €'), 1250);
      expect(lerNumero('abc'), isNull);
    });
    test('C41 hora de Lisboa: verão +1, inverno +0', () {
      expect(paraLisboa(DateTime.utc(2026, 7, 1, 8, 0)).hour, 9);
      expect(paraLisboa(DateTime.utc(2026, 12, 1, 8, 0)).hour, 8);
      expect(hojeLisboa(agoraUtc: DateTime.utc(2026, 7, 1, 23, 30)), DateTime(2026, 7, 2));
    });
  });

  group('Gerador de obrigações', () {
    final perfilTvde = PerfilObrigacoes(
      tipoAtividade: TipoAtividade.tvde,
      dataAbertura: DateTime(2026, 3, 15),
      regimeIva: RegimeIva.isento53,
      rendimentoMensalEstimado: 1500,
    );

    test('C42 TVDE aberto a 15/03/2026, isento: fim da isenção, pagamentos desde março 2027, sem IVA', () {
      final obs = gerarObrigacoes(perfil: perfilTvde, hoje: hoje, r: r);
      final fim = obs.singleWhere((o) => o.tipo == 'fim_isencao_ss');
      expect(fim.dataLimite, DateTime(2027, 3, 1));
      expect(fim.valorEstimado, 224.70);
      expect(fim.avisoEm, DateTime(2027, 1, 29)); // 30 dias antes = 30/01 (sábado) → sexta 29/01
      final pag = obs.where((o) => o.tipo == 'ss_pagamento').toList();
      expect(pag.first.dataLimite, DateTime(2027, 3, 20));
      expect(pag.first.avisoEm, DateTime(2027, 3, 19)); // 20/03/2027 é sábado
      expect(pag.first.valorEstimado, 224.70);
      expect(pag.length, 6); // mar..ago 2027 (setembro já é depois dos 12 meses)
      final decl = obs.where((o) => o.tipo == 'ss_declaracao').toList();
      expect(decl.map((o) => o.dataLimite), [DateTime(2027, 4, 30), DateTime(2027, 7, 31)]);
      expect(obs.where((o) => o.tipo.startsWith('iva_')), isEmpty);
      expect(obs.singleWhere((o) => o.tipo == 'irs_entrega').dataLimite, DateTime(2027, 6, 30));
      expect(obs.singleWhere((o) => o.tipo == 'efatura_validar').dataLimite, DateTime(2027, 2, 25));
      expect(obs.map((o) => o.chaveUnica).toSet().length, obs.length, reason: 'chaves únicas');
      expect(obs, isSorted<Obrigacao>((a, b) => a.dataLimite.compareTo(b.dataLimite)));
    });

    test('C43 regime normal de IVA: declaração dia 20 e pagamento dia 25 do 2.º mês após o trimestre', () {
      final perfil = PerfilObrigacoes(
        tipoAtividade: TipoAtividade.freelancer,
        dataAbertura: DateTime(2024, 1, 10),
        regimeIva: RegimeIva.normal,
        rendimentoMensalEstimado: 3000,
      );
      final obs = gerarObrigacoes(perfil: perfil, hoje: hoje, r: r);
      final decl = obs.where((o) => o.tipo == 'iva_declaracao').map((o) => o.dataLimite).toList();
      expect(decl, [DateTime(2026, 11, 20), DateTime(2027, 2, 20), DateTime(2027, 5, 20), DateTime(2027, 8, 20)]);
      final pag = obs.where((o) => o.tipo == 'iva_pagamento').map((o) => o.dataLimite).toList();
      expect(pag, [DateTime(2026, 11, 25), DateTime(2027, 2, 25), DateTime(2027, 5, 25), DateTime(2027, 8, 25)]);
      // atividade antiga: já paga SS todos os meses e declara em out/jan/abr/jul
      expect(obs.where((o) => o.tipo == 'ss_pagamento').length, 12);
      expect(obs.where((o) => o.tipo == 'ss_declaracao').length, 4);
      expect(obs.where((o) => o.tipo == 'fim_isencao_ss'), isEmpty);
    });

    test('C44 carro de fevereiro de 2021 com seguro em maio: IUC 28/02, IPO 28/02/2027, seguro roda para 2027', () {
      final carro = CarroObrigacoes(
        id: 'c1',
        matricula: 'AA-11-BB',
        dataMatricula: DateTime(2021, 2, 28),
        seguroRenovaEm: DateTime(2026, 5, 15),
        combustivel: Combustivel.gasolina,
        cilindradaCc: 1199,
        co2: 120,
      );
      final obs = gerarObrigacoes(
        perfil: const PerfilObrigacoes(tipoAtividade: TipoAtividade.soCarro),
        carros: [carro],
        hoje: hoje,
        r: r,
      );
      expect(obs.where((o) => o.tipo.startsWith('ss_')), isEmpty);
      final iuc = obs.singleWhere((o) => o.tipo == 'iuc');
      expect(iuc.dataLimite, DateTime(2027, 2, 28));
      expect(iuc.valorEstimado, 111.48);
      expect(iuc.avisoEm, DateTime(2027, 2, 26)); // 28/02/2027 é domingo
      expect(obs.singleWhere((o) => o.tipo == 'ipo').dataLimite, DateTime(2027, 2, 28));
      expect(obs.singleWhere((o) => o.tipo == 'seguro').dataLimite, DateTime(2027, 5, 15));
      expect(iuc.carroId, 'c1');
    });

    test('C45 sem atividade e sem carro → nada', () {
      final obs = gerarObrigacoes(
        perfil: const PerfilObrigacoes(tipoAtividade: TipoAtividade.semAtividade),
        hoje: hoje,
        r: r,
      );
      expect(obs, isEmpty);
    });
  });

  group('Regras legais (a tabela)', () {
    test('C46 número em falta é erro, nunca um valor inventado', () {
      expect(() => r.n('regra_que_nao_existe'), throwsStateError);
      expect(r.regra('ipo_tvde')!.confirmada, isFalse);
      expect(r.regra('ias')!.confirmada, isTrue);
    });
    test('C47 escalões: 2027 não existe → usa o ano mais recente (2026)', () {
      expect(r.escaloesDoAno(2027).first.ano, 2026);
      expect(r.escaloesDoAno(2025).length, 9);
    });
  });
}

Matcher isSorted<T>(int Function(T a, T b) cmp) => predicate<List<T>>((list) {
      for (var i = 1; i < list.length; i++) {
        if (cmp(list[i - 1], list[i]) > 0) return false;
      }
      return true;
    }, 'está ordenado');
