/// As contas de quem trabalha por conta de outrem (B3, 2026-09-18): o recibo
/// de vencimento linha a linha, a estimativa do IRS anual (reembolso ou
/// acerto), o IRS Jovem, o subsídio de desemprego e as horas extra.
///
/// Todos os números vêm da tabela `regras_legais` (fontes em
/// docs/REGRAS-PT-2026.md): SS 11 % (SS «Taxas Contributivas»), dedução
/// específica 8,54 × IAS (CIRS art. 25.º), escalões do CIRS art. 68.º,
/// IRS Jovem (art. 12.º-B), subsídio de desemprego (Guia Prático do ISS 2026),
/// trabalho suplementar (CT art. 268.º) e retribuição horária (CT art. 271.º).
library;

import 'formatos.dart';
import 'irs.dart';
import 'regras_legais.dart';

/// O recibo de vencimento explicado: bruto → descontos → líquido.
class ReciboVencimento {
  final double bruto;
  final double ssTrabalhador;
  final double pctSs;
  final double irsRetido;
  final double liquido;
  const ReciboVencimento({
    required this.bruto,
    required this.ssTrabalhador,
    required this.pctSs,
    required this.irsRetido,
    required this.liquido,
  });

  double get descontos => centimos(ssTrabalhador + irsRetido);
  double get pctIrs => bruto <= 0 ? 0 : irsRetido / bruto * 100;
}

ReciboVencimento lerReciboVencimento({required double bruto, required double irsRetido, required RegrasLegais r}) {
  final pct = r.n('ss_trabalhador_taxa');
  final ss = centimos(bruto * pct / 100);
  return ReciboVencimento(
    bruto: centimos(bruto),
    ssTrabalhador: ss,
    pctSs: pct,
    irsRetido: centimos(irsRetido),
    liquido: centimos(bruto - ss - irsRetido),
  );
}

/// O IRS do ano inteiro de quem tem contrato, para saber se o que ficou
/// retido chega (reembolso) ou falta (acerto). Estimativa: sem deduções
/// pessoais (saúde, educação, dependentes) nem quociente familiar — é para
/// a pessoa não ser apanhada de surpresa, não para preencher a declaração.
class EstimativaIrsContrato {
  final double brutoAnual;
  final double deducaoEspecifica;
  final double coletavel;
  final double imposto;
  final double retidoAnual;
  final int anoEscaloes;
  final bool escaloesConfirmados;
  const EstimativaIrsContrato({
    required this.brutoAnual,
    required this.deducaoEspecifica,
    required this.coletavel,
    required this.imposto,
    required this.retidoAnual,
    required this.anoEscaloes,
    required this.escaloesConfirmados,
  });

  /// Positivo = reembolso (retiveram a mais); negativo = acerto a pagar.
  double get diferenca => centimos(retidoAnual - imposto);
  bool get reembolso => diferenca >= 0;
}

EstimativaIrsContrato estimarIrsContrato({
  required double brutoMensal,
  required double irsRetidoMensal,
  int mesesPorAno = 14, // 12 salários + subsídio de férias + subsídio de Natal
  required int ano,
  required RegrasLegais r,
}) {
  final brutoAnual = centimos(brutoMensal * mesesPorAno);
  final ssAnual = centimos(brutoAnual * r.n('ss_trabalhador_taxa') / 100);
  // CIRS art. 25.º n.º 1 a) e n.º 2: 8,54 × IAS, ou as contribuições se forem maiores.
  final minimo = centimos(r.n('irs_deducao_especifica_ias') * r.n('ias'));
  final deducao = ssAnual > minimo ? ssAnual : minimo;
  final coletavel = brutoAnual - deducao < 0 ? 0.0 : centimos(brutoAnual - deducao);
  final escaloes = r.escaloesDoAno(ano);
  final abaixoMinimo = brutoAnual <= r.n('irs_minimo_existencia');
  final imposto = abaixoMinimo ? 0.0 : impostoPorEscaloes(coletavel, escaloes);
  return EstimativaIrsContrato(
    brutoAnual: brutoAnual,
    deducaoEspecifica: deducao,
    coletavel: coletavel,
    imposto: imposto < 0 ? 0 : imposto,
    retidoAnual: centimos(irsRetidoMensal * mesesPorAno),
    anoEscaloes: escaloes.isEmpty ? ano : escaloes.first.ano,
    escaloesConfirmados: escaloes.every((e) => e.confianca != 'por_confirmar'),
  );
}

/// IRS Jovem (CIRS art. 12.º-B): até 35 anos, não dependente, nos 10
/// primeiros anos de rendimentos; isenção por ano de rendimentos com o
/// limite de 55 × IAS. [anoDeRendimentos] é o 1.º, 2.º … 10.º ano em que a
/// pessoa ganha dinheiro (categorias A ou B).
class IrsJovem {
  final bool elegivel;
  final double pctIsencao;
  final double limiteEur;
  final String motivo; // 'ok' | 'idade' | 'anos'
  const IrsJovem({required this.elegivel, required this.pctIsencao, required this.limiteEur, required this.motivo});
}

IrsJovem irsJovem({required int idadeEm31Dez, required int anoDeRendimentos, required RegrasLegais r}) {
  final j = r.json('irs_jovem') as Map;
  final idadeMax = (j['idade_max'] as num).toInt();
  final pcts = (j['pct_por_ano'] as List).cast<num>();
  final limite = centimos((j['limite_ias'] as num) * r.n('ias'));
  if (idadeEm31Dez > idadeMax) {
    return IrsJovem(elegivel: false, pctIsencao: 0, limiteEur: limite, motivo: 'idade');
  }
  if (anoDeRendimentos < 1 || anoDeRendimentos > pcts.length) {
    return IrsJovem(elegivel: false, pctIsencao: 0, limiteEur: limite, motivo: 'anos');
  }
  return IrsJovem(elegivel: true, pctIsencao: pcts[anoDeRendimentos - 1].toDouble(), limiteEur: limite, motivo: 'ok');
}

/// Subsídio de desemprego (Guia Prático do ISS, 2026): 360 dias de descontos
/// nos últimos 24 meses; pedir até 90 dias depois; 65 % da remuneração de
/// referência, entre 1,15 × IAS e 2,5 × IAS.
class Desemprego {
  final bool temDireito;
  final int diasQueFaltam;
  final double valorMensalEstimado;
  final DateTime pedirAte;
  final int prazoGarantiaDias;
  final int janelaMeses;
  const Desemprego({
    required this.temDireito,
    required this.diasQueFaltam,
    required this.valorMensalEstimado,
    required this.pedirAte,
    required this.prazoGarantiaDias,
    required this.janelaMeses,
  });
}

Desemprego estimarDesemprego({
  required int diasDeDescontosEm24Meses,
  required double salarioBrutoMensal,
  required DateTime dataDesemprego,
  required RegrasLegais r,
}) {
  final d = r.json('desemprego') as Map;
  final garantia = (d['prazo_garantia_dias'] as num).toInt();
  final pedir = (d['pedir_ate_dias'] as num).toInt();
  // Remuneração de referência por dia = salários de 12 meses ÷ 360; o subsídio
  // é 65 % dela × 30 dias, dentro dos limites do IAS.
  final rrDia = salarioBrutoMensal * 12 / 360;
  var mensal = rrDia * (d['pct_rr'] as num) / 100 * 30;
  final minimo = (d['min_eur'] as num).toDouble();
  final maximo = (d['max_eur'] as num).toDouble();
  if (mensal < minimo) mensal = minimo;
  if (mensal > maximo) mensal = maximo;
  return Desemprego(
    temDireito: diasDeDescontosEm24Meses >= garantia,
    diasQueFaltam: diasDeDescontosEm24Meses >= garantia ? 0 : garantia - diasDeDescontosEm24Meses,
    valorMensalEstimado: centimos(mensal),
    pedirAte: DateTime(dataDesemprego.year, dataDesemprego.month, dataDesemprego.day + pedir),
    prazoGarantiaDias: garantia,
    janelaMeses: (d['janela_meses'] as num).toInt(),
  );
}

/// Retribuição horária (CT art. 271.º): (salário mensal × 12) ÷ (52 × horas por semana).
double retribuicaoHoraria({required double brutoMensal, int horasSemana = 40}) =>
    centimos(brutoMensal * 12 / (52 * horasSemana));

/// Quanto vale uma hora extra (CT art. 268.º): a primeira hora do dia e as
/// seguintes têm acréscimos diferentes; ao fim de semana/feriado é outro; e a
/// partir das 100 horas no ano os acréscimos sobem.
class HoraExtra {
  final double base;
  final double primeiraHora;
  final double horaSeguinte;
  final double descansoOuFeriado;
  const HoraExtra({required this.base, required this.primeiraHora, required this.horaSeguinte, required this.descansoOuFeriado});
}

HoraExtra valorHoraExtra({required double brutoMensal, int horasSemana = 40, bool maisDe100hNoAno = false, required RegrasLegais r}) {
  final base = retribuicaoHoraria(brutoMensal: brutoMensal, horasSemana: horasSemana);
  final tabela = (r.json('horas_extra_pct') as Map)[maisDe100hNoAno ? 'mais_100h' : 'ate_100h'] as Map;
  double com(num pct) => centimos(base * (1 + pct / 100));
  return HoraExtra(
    base: base,
    primeiraHora: com(tabela['primeira'] as num),
    horaSeguinte: com(tabela['seguintes'] as num),
    descansoOuFeriado: com(tabela['descanso_ou_feriado'] as num),
  );
}
