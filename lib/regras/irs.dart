import 'formatos.dart';
import 'regras_legais.dart';
import 'seguranca_social.dart' show TipoRendimento;

/// Provisão de IRS no regime simplificado (estimativa para "quanto guardar").
class ProvisaoIrs {
  final double rendimentoBrutoAnual;
  final double coeficiente; // 0,75 serviços / 0,15 vendas
  final double rendimentoColetavel; // bruto × coeficiente
  final double impostoEstimado; // depois dos escalões e do mínimo de existência
  final double guardarPorMes; // imposto / 12
  final double taxaEfetivaPct;
  final bool abaixoMinimoExistencia;
  final bool justificarDespesas; // acima de ~27.360 € tem de justificar 15%
  final double pagamentoPorContaCada; // 65% × imposto / 3
  final int anoEscaloes;
  final bool escaloesConfirmados;

  const ProvisaoIrs({
    required this.rendimentoBrutoAnual,
    required this.coeficiente,
    required this.rendimentoColetavel,
    required this.impostoEstimado,
    required this.guardarPorMes,
    required this.taxaEfetivaPct,
    required this.abaixoMinimoExistencia,
    required this.justificarDespesas,
    required this.pagamentoPorContaCada,
    required this.anoEscaloes,
    required this.escaloesConfirmados,
  });
}

/// Imposto pelos escalões (método "taxa × coletável − parcela a abater").
double impostoPorEscaloes(double coletavel, List<EscalaoIrs> escaloes) {
  if (coletavel <= 0 || escaloes.isEmpty) return 0;
  for (final e in escaloes) {
    if (e.ate == null || coletavel <= e.ate!) {
      return centimos(coletavel * e.taxa - e.parcelaAbater);
    }
  }
  final ultimo = escaloes.last;
  return centimos(coletavel * ultimo.taxa - ultimo.parcelaAbater);
}

/// Regime simplificado: coletável = bruto × coeficiente; abaixo do mínimo de
/// existência não há imposto; acima, escalões do ano. Estimativa: não entra
/// com deduções pessoais nem com o quociente familiar — é para saber quanto
/// guardar, não para preencher a declaração.
ProvisaoIrs calcularIrs({
  required double rendimentoBrutoAnual,
  required TipoRendimento tipo,
  required int ano,
  required RegrasLegais r,
}) {
  final coef = tipo == TipoRendimento.servicos
      ? r.n('irs_coef_servicos')
      : r.n('irs_coef_vendas');
  final coletavel = centimos(rendimentoBrutoAnual * coef);
  final minimo = r.n('irs_minimo_existencia');
  final escaloes = r.escaloesDoAno(ano);
  final abaixo = coletavel <= minimo;
  final imposto = abaixo ? 0.0 : impostoPorEscaloes(coletavel, escaloes);
  final ppcPct = r.n('irs_pagamentos_conta_pct');
  return ProvisaoIrs(
    rendimentoBrutoAnual: rendimentoBrutoAnual,
    coeficiente: coef,
    rendimentoColetavel: coletavel,
    impostoEstimado: imposto,
    guardarPorMes: centimos(imposto / 12),
    taxaEfetivaPct: rendimentoBrutoAnual > 0
        ? centimos(imposto / rendimentoBrutoAnual * 100)
        : 0,
    abaixoMinimoExistencia: abaixo,
    justificarDespesas:
        rendimentoBrutoAnual > r.n('irs_despesas_justificar_limite'),
    pagamentoPorContaCada: centimos(imposto * ppcPct / 100 / 3),
    anoEscaloes: escaloes.isEmpty ? ano : escaloes.first.ano,
    escaloesConfirmados: escaloes.every((e) => e.confianca != 'por_confirmar'),
  );
}

/// Datas dos pagamentos por conta num ano (20 jul / 20 set / 20 dez).
List<DateTime> datasPagamentosPorConta(int ano, RegrasLegais r) {
  final datas = (r.json('irs_pagamentos_conta_datas') as List).cast<String>();
  return datas.map((s) {
    final p = s.split('-');
    return DateTime(ano, int.parse(p[0]), int.parse(p[1]));
  }).toList();
}

DateTime _dataDoAno(int ano, String mmdd) {
  final p = mmdd.split('-');
  return DateTime(ano, int.parse(p[0]), int.parse(p[1]));
}

DateTime prazoEntregaIrs(int ano, RegrasLegais r) =>
    _dataDoAno(ano, r.txt('irs_entrega_fim'));

DateTime inicioEntregaIrs(int ano, RegrasLegais r) =>
    _dataDoAno(ano, r.txt('irs_entrega_inicio'));

DateTime prazoValidarEfatura(int ano, RegrasLegais r) =>
    _dataDoAno(ano, r.txt('efatura_validar_ate'));
