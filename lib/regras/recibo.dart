import 'formatos.dart';
import 'regras_legais.dart';

/// Retenção na fonte escolhida no recibo.
enum Retencao { padrao, vinteCinco, dispensa }

/// Resultado da calculadora de recibo verde.
class ReciboCalculo {
  final double valorSemIva; // o que está escrito no recibo
  final double iva; // 0 se isento
  final double totalFatura; // valor + IVA
  final double retencao; // o cliente entrega às Finanças por ti
  final double recebesNaConta; // valor + IVA - retenção
  final double ficaTeu; // valor - retenção (o IVA não é teu)
  final double taxaRetencaoPct;
  final double taxaIvaPct;
  final bool isentoIva;
  final String? mencaoIsencao;

  const ReciboCalculo({
    required this.valorSemIva,
    required this.iva,
    required this.totalFatura,
    required this.retencao,
    required this.recebesNaConta,
    required this.ficaTeu,
    required this.taxaRetencaoPct,
    required this.taxaIvaPct,
    required this.isentoIva,
    this.mencaoIsencao,
  });
}

/// Calculadora do recibo: valor → bruto, retenção (23/25/dispensa), IVA
/// (23% ou isento art. 53.º), líquido real.
ReciboCalculo calcularRecibo({
  required double valor,
  required Retencao retencao,
  required bool isentoIva,
  required RegrasLegais r,
}) {
  final taxaRet = switch (retencao) {
    Retencao.padrao => r.n('retencao_padrao'),
    Retencao.vinteCinco => r.n('retencao_opcao'),
    Retencao.dispensa => 0.0,
  };
  final taxaIva = isentoIva ? 0.0 : r.n('iva_taxa_normal');
  final iva = centimos(valor * taxaIva / 100);
  final ret = centimos(valor * taxaRet / 100);
  return ReciboCalculo(
    valorSemIva: centimos(valor),
    iva: iva,
    totalFatura: centimos(valor + iva),
    retencao: ret,
    recebesNaConta: centimos(valor + iva - ret),
    ficaTeu: centimos(valor - ret),
    taxaRetencaoPct: taxaRet,
    taxaIvaPct: taxaIva,
    isentoIva: isentoIva,
    mencaoIsencao: isentoIva ? r.txt('iva_mencao_isencao') : null,
  );
}

/// Pode pedir dispensa de retenção? Só se no ano anterior faturou menos do
/// limite (art. 101.º-B CIRS). O cliente ter contabilidade organizada é
/// condição do lado dele — a app avisa, não decide.
bool podeDispensarRetencao({
  required double faturacaoAnoAnterior,
  required RegrasLegais r,
}) =>
    faturacaoAnoAnterior < r.n('retencao_dispensa_limite');
