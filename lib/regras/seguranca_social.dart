import 'datas.dart';
import 'formatos.dart';
import 'regras_legais.dart';

enum TipoRendimento { servicos, vendas }

/// Contribuição trimestral para a Segurança Social (independentes).
class ContribuicaoSS {
  final double rendimentoTrimestre;
  final double rendimentoMensalRelevante; // rendimento/3 × 70% (ou 20%)
  final double baseIncidencia; // depois do ajuste ±25% e do teto 12×IAS
  final double contribuicaoMensal; // base × 21,4%, mínimo 20 €
  final double contribuicaoTrimestre; // ×3 (os 3 meses seguintes)
  final bool bateuNoMinimo;
  final bool bateuNoMaximo;
  final int ajustePct;

  const ContribuicaoSS({
    required this.rendimentoTrimestre,
    required this.rendimentoMensalRelevante,
    required this.baseIncidencia,
    required this.contribuicaoMensal,
    required this.contribuicaoTrimestre,
    required this.bateuNoMinimo,
    required this.bateuNoMaximo,
    required this.ajustePct,
  });
}

/// 21,4% sobre 70% (serviços) ou 20% (bens) do rendimento médio mensal do
/// trimestre; ajuste até ±25%; mínimo 20 €/mês; base máxima 12 × IAS.
ContribuicaoSS calcularSS({
  required double rendimentoTrimestre,
  required TipoRendimento tipo,
  int ajustePct = 0,
  required RegrasLegais r,
}) {
  final ajusteMax = r.n('ss_ajuste_max').toInt();
  final ajuste = ajustePct.clamp(-ajusteMax, ajusteMax);
  final pctBase = tipo == TipoRendimento.servicos
      ? r.n('ss_base_servicos')
      : r.n('ss_base_vendas');
  final mensal = rendimentoTrimestre / 3 * pctBase / 100;
  var base = mensal * (1 + ajuste / 100);
  final teto = r.n('ss_base_maxima_ias') * r.n('ias');
  final bateuMax = base > teto;
  if (bateuMax) base = teto;
  var contribuicao = base * r.n('ss_taxa') / 100;
  final minimo = r.n('ss_minimo_mensal');
  final bateuMin = contribuicao < minimo;
  if (bateuMin) contribuicao = minimo;
  return ContribuicaoSS(
    rendimentoTrimestre: rendimentoTrimestre,
    rendimentoMensalRelevante: centimos(mensal),
    baseIncidencia: centimos(base),
    contribuicaoMensal: centimos(contribuicao),
    contribuicaoTrimestre: centimos(contribuicao * 3),
    bateuNoMinimo: bateuMin,
    bateuNoMaximo: bateuMax,
    ajustePct: ajuste,
  );
}

/// Estimativa mensal a partir de um rendimento mensal (a "primeira simulação"
/// do onboarding): o trimestre é 3× o mês.
ContribuicaoSS estimarSSMensal({
  required double rendimentoMensal,
  required TipoRendimento tipo,
  int ajustePct = 0,
  required RegrasLegais r,
}) =>
    calcularSS(
        rendimentoTrimestre: rendimentoMensal * 3,
        tipo: tipo,
        ajustePct: ajustePct,
        r: r);

/// Isenção do 1.º ano: primeiro dia do mês em que se começa a pagar.
///
/// A isenção cobre os 12 primeiros meses de atividade contados do mês de
/// abertura. Abriu a 15/03/2026 → paga a partir de março de 2027 (1.ª
/// contribuição a pagar entre 10 e 20 de abril de 2027). Abriu a 31/12/2026 →
/// dezembro de 2027. 29/02/2028 → fevereiro de 2029.
DateTime fimIsencaoSS(DateTime dataAbertura, RegrasLegais r) {
  final inicioMes = DateTime(dataAbertura.year, dataAbertura.month, 1);
  return adicionarMeses(inicioMes, r.n('ss_isencao_meses').toInt());
}

/// Último dia coberto pela isenção (para o texto "estás isento até…").
DateTime ultimoDiaIsencaoSS(DateTime dataAbertura, RegrasLegais r) =>
    fimIsencaoSS(dataAbertura, r).subtract(const Duration(days: 1));

int mesesDeIsencaoRestantes(DateTime dataAbertura, DateTime hoje, RegrasLegais r) {
  final fim = fimIsencaoSS(dataAbertura, r);
  final h = DateTime(hoje.year, hoje.month, 1);
  if (!h.isBefore(fim)) return 0;
  return (fim.year - h.year) * 12 + (fim.month - h.month);
}

/// Primeiro mês (1 = janeiro) em que há declaração trimestral a fazer depois
/// do fim da isenção. As declarações são em jan/abr/jul/out e dizem respeito
/// ao trimestre anterior. POR CONFIRMAR com a Segurança Social: assume-se que
/// a primeira declaração é a do 1.º mês de declaração igual ou posterior ao
/// mês em que se começa a pagar.
DateTime primeiraDeclaracaoTrimestral(DateTime dataAbertura, RegrasLegais r) {
  final fim = fimIsencaoSS(dataAbertura, r);
  final meses = (r.json('ss_declaracao_meses') as List).cast<num>().map((e) => e.toInt()).toList()..sort();
  for (final m in meses) {
    if (m >= fim.month) return DateTime(fim.year, m, 1);
  }
  return DateTime(fim.year + 1, meses.first, 1);
}

/// Prazo (último dia do mês) da declaração trimestral de um dado mês de declaração.
DateTime prazoDeclaracaoTrimestral(int ano, int mesDeclaracao) =>
    DateTime(ano, mesDeclaracao, ultimoDiaDoMes(ano, mesDeclaracao));

/// Prazo de pagamento da contribuição de um mês: dia 20 desse mês.
DateTime prazoPagamentoSS(int ano, int mes, RegrasLegais r) =>
    DateTime(ano, mes, r.n('ss_pagamento_dia_fim').toInt());

/// Estimativa simples de reforma mensal a partir do que se desconta por mês.
/// Fórmula pedagógica (não é a fórmula legal): a pensão cresce ~2% da base por
/// ano de descontos, prorrateada por 40 anos de carreira. Serve para "descontas
/// X — vale ≈ Y" e diz-se sempre que é uma estimativa.
double estimarReformaMensal({
  required double contribuicaoMensal,
  required int anosDeDescontos,
  required RegrasLegais r,
}) {
  final base = contribuicaoMensal / (r.n('ss_taxa') / 100); // base de incidência
  final taxaFormacao = 0.02 * anosDeDescontos; // 2% por ano
  return centimos(base * taxaFormacao.clamp(0, 0.92));
}
