import 'datas.dart';
import 'formatos.dart';
import 'regras_legais.dart';

/// Datas do carro: IUC (mês da matrícula), IPO (4/6/8 e depois anual),
/// seguro (aviso 45 dias), carta (15/5/2 anos), multas (15 dias úteis).

/// Prazo do IUC num dado ano: último dia do mês da matrícula.
DateTime prazoIuc({required int mesMatricula, required int ano}) =>
    DateTime(ano, mesMatricula, ultimoDiaDoMes(ano, mesMatricula));

/// Próximo prazo do IUC a partir de hoje (este ano se ainda não passou; senão o
/// do ano que vem).
DateTime proximoIuc({required int mesMatricula, required DateTime hoje}) {
  final esteAno = prazoIuc(mesMatricula: mesMatricula, ano: hoje.year);
  return esteAno.isBefore(soDia(hoje))
      ? prazoIuc(mesMatricula: mesMatricula, ano: hoje.year + 1)
      : esteAno;
}

/// Calendário completo de inspeções de um ligeiro a partir da matrícula:
/// aos 4, 6 e 8 anos, depois todos os anos. TVDE: anual desde o 1.º ano
/// (POR CONFIRMAR no IMT). Devolve as datas até [ate].
List<DateTime> calendarioIpo({
  required DateTime matricula,
  required DateTime ate,
  bool tvde = false,
  required RegrasLegais r,
}) {
  final datas = <DateTime>[];
  if (tvde) {
    var d = adicionarAnos(matricula, 1);
    while (!d.isAfter(ate)) {
      datas.add(d);
      d = adicionarAnos(d, 1);
    }
    return datas;
  }
  final marcos = (r.json('ipo_ligeiros_anos') as List).cast<num>().map((e) => e.toInt()).toList()..sort();
  for (final anos in marcos) {
    final d = adicionarAnos(matricula, anos);
    if (!d.isAfter(ate)) datas.add(d);
  }
  var anos = marcos.last + 1;
  var d = adicionarAnos(matricula, anos);
  while (!d.isAfter(ate)) {
    datas.add(d);
    anos++;
    d = adicionarAnos(matricula, anos);
  }
  return datas;
}

/// Próxima inspeção. Se houver data da última, é a primeira do calendário
/// depois dessa; senão, a primeira igual ou posterior a hoje.
DateTime? proximaIpo({
  required DateTime matricula,
  DateTime? ultimaIpo,
  required DateTime hoje,
  bool tvde = false,
  required RegrasLegais r,
}) {
  final cal = calendarioIpo(
      matricula: matricula, ate: adicionarAnos(hoje, 3), tvde: tvde, r: r);
  if (ultimaIpo != null) {
    for (final d in cal) {
      if (d.isAfter(soDia(ultimaIpo))) return d;
    }
    return null;
  }
  for (final d in cal) {
    if (!d.isBefore(soDia(hoje))) return d;
  }
  return null;
}

/// Dias de aviso antes da inspeção (30 e 7).
List<int> avisosIpo(RegrasLegais r) =>
    (r.json('ipo_avisos_dias') as List).cast<num>().map((e) => e.toInt()).toList();

/// Data em que se avisa do seguro: 45 dias antes de renovar.
DateTime avisoSeguro(DateTime renovaEm, RegrasLegais r) =>
    renovaEm.subtract(Duration(days: r.n('seguro_aviso_dias').toInt()));

/// Validade da carta (anos) pela idade: 15 até aos 60, 5 até aos 70, depois 2.
int anosValidadeCarta(int idade, RegrasLegais r) {
  final m = r.json('carta_validade') as Map;
  if (idade < 60) return (m['ate_60'] as num).toInt();
  if (idade < 70) return (m['60_a_70'] as num).toInt();
  return (m['mais_70'] as num).toInt();
}

/// Prazo de pagamento voluntário de uma multa/portagem: 15 dias úteis.
DateTime prazoMulta(DateTime notificacao, RegrasLegais r) => somarDiasUteis(
    notificacao,
    r.n('multa_pagamento_voluntario_dias_uteis').toInt(),
    r.feriados);

enum Combustivel { gasolina, gasoleo, eletrico, hibrido, gpl, outro }

class EstimativaIuc {
  final double valor;
  final String explicacao;
  final bool aproximado;
  const EstimativaIuc(this.valor, this.explicacao, {this.aproximado = true});
}

double _valorNaTabela(List tabela, num chave) {
  for (final linha in tabela) {
    final m = linha as Map;
    if (chave <= (m['ate'] as num)) return (m['valor'] as num).toDouble();
  }
  return ((tabela.last as Map)['valor'] as num).toDouble();
}

/// Estimativa do IUC pela tabela simplificada de `regras_legais.iuc_tabela`.
/// Categoria B (matriculados desde julho de 2007): cilindrada + CO2, × coef. do ano.
/// Categoria A (antes): só cilindrada e combustível. Elétricos: 0.
EstimativaIuc? estimarIuc({
  required DateTime matricula,
  required Combustivel combustivel,
  int? cilindradaCc,
  int? co2,
  bool co2Wltp = true,
  required RegrasLegais r,
}) {
  final t = r.json('iuc_tabela') as Map;
  if (combustivel == Combustivel.eletrico) {
    return const EstimativaIuc(0, 'Carro elétrico: isento de IUC.', aproximado: false);
  }
  if (cilindradaCc == null) return null;
  final catB = matricula.isAfter(DateTime(2007, 6, 30));
  if (!catB) {
    final tab = combustivel == Combustivel.gasoleo
        ? t['cat_a_gasoleo'] as List
        : t['cat_a_gasolina'] as List;
    final v = _valorNaTabela(tab, cilindradaCc);
    return EstimativaIuc(centimos(v),
        'Categoria A (antes de julho de 2007): $cilindradaCc cc → ${moeda(v)}. Valor aproximado.');
  }
  final vCil = _valorNaTabela(t['cat_b_cilindrada'] as List, cilindradaCc);
  double vCo2 = 0;
  if (co2 != null) {
    vCo2 = _valorNaTabela(
        (co2Wltp ? t['cat_b_co2_wltp'] : t['cat_b_co2_nedc']) as List, co2);
  }
  double coef = 1.0;
  for (final linha in t['cat_b_coef_ano'] as List) {
    final m = linha as Map;
    if (matricula.year >= (m['ano'] as num)) coef = (m['coef'] as num).toDouble();
  }
  final total = centimos((vCil + vCo2) * coef);
  return EstimativaIuc(
      total,
      'Categoria B: cilindrada ${moeda(vCil)} + CO2 ${moeda(vCo2)} × $coef (ano ${matricula.year}). '
      '${co2 == null ? 'Sem CO2 conhecido — falta a parcela do CO2. ' : ''}Valor aproximado: confirma no Portal das Finanças.');
}

/// Custo por km a partir dos abastecimentos (entre o primeiro e o último
/// depósito cheio com km registados).
class CustoKm {
  final double custoPorKm;
  final double litrosPor100Km;
  final int kmPercorridos;
  final double gasto;
  const CustoKm(this.custoPorKm, this.litrosPor100Km, this.kmPercorridos, this.gasto);
}

class AbastecimentoLinha {
  final DateTime data;
  final double valorTotal;
  final double? litros;
  final int? km;
  final bool depositoCheio;
  const AbastecimentoLinha({
    required this.data,
    required this.valorTotal,
    this.litros,
    this.km,
    this.depositoCheio = true,
  });
}

CustoKm? custoPorKm(List<AbastecimentoLinha> abastecimentos) {
  final comKm = abastecimentos.where((a) => a.km != null && a.depositoCheio).toList()
    ..sort((a, b) => a.data.compareTo(b.data));
  if (comKm.length < 2) return null;
  final primeiro = comKm.first;
  final ultimo = comKm.last;
  final km = ultimo.km! - primeiro.km!;
  if (km <= 0) return null;
  // O primeiro cheio enche o depósito: o combustível gasto nos km é o dos seguintes.
  final seguintes = abastecimentos
      .where((a) => a.data.isAfter(primeiro.data) && !a.data.isAfter(ultimo.data))
      .toList();
  final gasto = seguintes.fold<double>(0, (s, a) => s + a.valorTotal);
  final litros = seguintes.fold<double>(0, (s, a) => s + (a.litros ?? 0));
  return CustoKm(centimos(gasto / km), centimos(litros / km * 100), km, centimos(gasto));
}
