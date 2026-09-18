/// O cofre automático (B2d): por cada rendimento que entra, a fatia que se
/// põe de lado para o Estado — Segurança Social + IRS estimado.
///
/// É contabilidade dentro da app, nunca dinheiro: escreve-se uma linha no
/// cofre (`cofre_movimentos`, motivo `guardar`, nota `auto`, ligada à entrada).
/// A pessoa vê «já tens X guardado dos Y que vais precisar em [mês]» e pode
/// desligar isto no cofre (`profiles.cofre_automatico`).
///
/// As contas:
///  · Segurança Social: 21,4 % sobre 70 % do rendimento (serviços) ou 20 %
///    (vendas) — as regras `ss_taxa`, `ss_base_servicos`, `ss_base_vendas`
///    (CRC art. 162.º/168.º; fonte na tabela). Só depois da isenção do 1.º ano.
///  · IRS: a taxa efetiva estimada sobre o rendimento anual (regime
///    simplificado, `calcularIrs`), que é a melhor aproximação sem a
///    declaração feita. Abaixo do mínimo de existência é 0.
library;

import 'datas.dart';
import 'formatos.dart';
import 'irs.dart';
import 'regras_legais.dart';
import 'seguranca_social.dart';

class FatiaCofre {
  final double segurancaSocial;
  final double irs;
  final double total;
  final double pctSs;
  final double pctIrs;
  final bool ssIsenta;

  const FatiaCofre({
    required this.segurancaSocial,
    required this.irs,
    required this.total,
    required this.pctSs,
    required this.pctIrs,
    required this.ssIsenta,
  });

  double get pctTotal => pctSs + pctIrs;
}

/// A fatia de um rendimento [valor] recebido em [data].
///
/// [rendimentoAnualEstimado] é o que a pessoa disse ganhar (× 12) ou o que já
/// entrou este ano — serve para escolher o escalão de IRS. Sem estimativa, o
/// IRS fica a 0 (não se inventa) e só se guarda a Segurança Social.
FatiaCofre fatiaParaOCofre({
  required double valor,
  required DateTime data,
  required TipoRendimento tipo,
  double? rendimentoAnualEstimado,
  DateTime? dataAbertura,
  required RegrasLegais regras,
}) {
  if (valor <= 0) {
    return const FatiaCofre(segurancaSocial: 0, irs: 0, total: 0, pctSs: 0, pctIrs: 0, ssIsenta: false);
  }
  // Segurança Social: só quando já se paga (a isenção do 1.º ano conta por mês).
  final isenta = dataAbertura != null && soDia(data).isBefore(fimIsencaoSS(dataAbertura, regras));
  final base = tipo == TipoRendimento.servicos ? regras.n('ss_base_servicos') : regras.n('ss_base_vendas');
  final pctSs = isenta ? 0.0 : base / 100 * regras.n('ss_taxa') / 100;
  // IRS: taxa efetiva pelo rendimento anual estimado.
  var pctIrs = 0.0;
  if (rendimentoAnualEstimado != null && rendimentoAnualEstimado > 0) {
    final irs = calcularIrs(rendimentoBrutoAnual: rendimentoAnualEstimado, tipo: tipo, ano: data.year, r: regras);
    pctIrs = irs.taxaEfetivaPct / 100;
  }
  final ss = centimos(valor * pctSs);
  final imposto = centimos(valor * pctIrs);
  return FatiaCofre(
    segurancaSocial: ss,
    irs: imposto,
    total: centimos(ss + imposto),
    pctSs: pctSs,
    pctIrs: pctIrs,
    ssIsenta: isenta,
  );
}
