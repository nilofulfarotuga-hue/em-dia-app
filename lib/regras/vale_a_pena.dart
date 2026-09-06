/// "Vale a pena esta corrida?" — a conta pura, sem Flutter.
///
/// A pergunta que o motorista ou o estafeta faz ao telemóvel em três segundos:
/// *depois de tudo pago, ainda me sobra alguma coisa?*
///
/// A conta, por esta ordem, com cada parcela à vista:
///
///       quanto a plataforma me paga
///     − combustível/energia dos km   (km × consumo aos 100 × preço do litro ou do kWh)
///     − desgaste do carro            (pneus, revisões, óleo — por km)
///     − Segurança Social             (`ss_taxa` sobre `ss_base_servicos`)
///     − IRS                          (retido na hora, ou pelo escalão do ano)
///     = o que fica mesmo para mim    (e quanto é isso por hora)
///
/// Todos os números legais vêm de [RegrasLegais] — nunca de constantes aqui.
/// A ÚNICA exceção é o desgaste por km, que a pessoa escreve: essa regra não
/// existe na tabela `regras_legais` (procurada a 2026-09-06 e não está lá) e
/// inventar um número legal é pior do que pedir. Por isso entra como
/// [desgastePorKm] e vai sempre marcado como estimativa no ecrã.
library;

import 'carro.dart';
import 'formatos.dart';
import 'irs.dart';
import 'recibo.dart';
import 'regras_legais.dart';
import 'seguranca_social.dart';

/// Onde é que a corrida deixa a pessoa.
enum NivelSobra {
  /// Sobra bem — cartão verde.
  bem,

  /// Sobra, mas pouco — cartão cinzento.
  pouco,

  /// Fica a perder dinheiro — cartão vermelho.
  perde,
}

/// A partir de que fatia é que "sobra bem".
///
/// Isto NÃO é um número legal, e é por isso que vive aqui e não em
/// `regras_legais`: é uma opinião da app sobre quando uma corrida vale a pena.
/// Trinta por cento do que a plataforma paga é o que costuma sobrar depois do
/// combustível, do desgaste e do Estado; abaixo disso a corrida devolve menos
/// de um terço do que rende, e a pessoa merece ver isso a cinzento.
///
/// Se um dia se quiser afinar isto sem publicar app nova, faz-se uma chave
/// `vale_a_pena_sobra_boa_pct` na tabela e lê-se de lá, como tudo o resto.
const double fracaoSobraBoa = 0.30;

/// O resultado da conta, parcela a parcela (o ecrã mostra-as todas).
class ContaDaCorrida {
  /// O que a plataforma paga por esta corrida.
  final double pagam;
  final double km;
  final int? minutos;

  /// Combustível ou energia gastos nestes km.
  final double combustivel;

  /// Pneus, revisões e óleo destes km. Estimativa escrita pela pessoa.
  final double desgaste;

  final double segurancaSocial;
  final double irs;

  /// A soma das duas parcelas do Estado (é só para o texto falado).
  final double estado;

  /// O que fica mesmo para a pessoa.
  final double sobra;

  /// [sobra] por hora, quando a pessoa disse quantos minutos demora.
  final double? porHora;

  /// Quanto custa cada quilómetro (combustível + desgaste).
  final double custoPorKm;

  /// Fatia do que a plataforma paga que fica para a pessoa (0 a 1).
  final double fracaoQueSobra;

  final NivelSobra nivel;

  /// `true` quando o IRS já é tirado na hora (retenção). `false` = estimativa.
  final bool irsRetidoNaHora;

  /// `true` quando não se sabe o que a pessoa fatura no ano e se contou o IRS
  /// do escalão mais baixo. O ecrã tem de dizer que é o mínimo.
  final bool irsNoMinimo;

  /// `true` quando o rendimento do ano ainda fica abaixo do mínimo de
  /// existência: não há IRS a pagar.
  final bool semIrsAPagar;

  /// `true` quando a pessoa ainda está nos 12 meses de isenção da Segurança
  /// Social do 1.º ano.
  final bool isentoSs;

  const ContaDaCorrida({
    required this.pagam,
    required this.km,
    required this.minutos,
    required this.combustivel,
    required this.desgaste,
    required this.segurancaSocial,
    required this.irs,
    required this.estado,
    required this.sobra,
    required this.porHora,
    required this.custoPorKm,
    required this.fracaoQueSobra,
    required this.nivel,
    required this.irsRetidoNaHora,
    required this.irsNoMinimo,
    required this.semIrsAPagar,
    required this.isentoSs,
  });
}

/// A fatia de Segurança Social que cai sobre CADA euro desta corrida.
///
/// Aqui não se chama [calcularSS] de propósito, e vale a pena deixar o recado:
/// aquela função traz o mínimo de 20 €/mês e o teto de 12 × IAS, que são do mês
/// e do trimestre inteiros. Numa corrida de 12 € o mínimo comia a corrida toda
/// e o número saía uma mentira. O que interessa a uma corrida é a fatia que ela
/// acrescenta — a taxa (`ss_taxa`) sobre a parte do rendimento que conta
/// (`ss_base_servicos`), exatamente as duas chaves que a [calcularSS] lê.
///
/// O teste C-VP07 prova que os dois caminhos dão o mesmo, num trimestre já
/// acima do mínimo e abaixo do teto.
double taxaSsPorEuro(RegrasLegais r, {TipoRendimento tipo = TipoRendimento.servicos}) {
  final base = tipo == TipoRendimento.servicos
      ? r.n('ss_base_servicos')
      : r.n('ss_base_vendas');
  return r.n('ss_taxa') / 100 * base / 100;
}

/// A taxa do escalão de IRS onde cai quem fatura [rendimentoAnualEstimado].
///
/// Reaproveita [calcularIrs] para o que ela faz bem — o coeficiente do regime
/// simplificado e o mínimo de existência — e depois procura o escalão.
///
/// Porque não a diferença entre o imposto do ano com e sem a corrida: o mínimo
/// de existência é um degrau. Quem está mesmo em cima dele veria uma corrida de
/// 12 € a "custar" mais de mil euros de IRS, o que é falso — o degrau é do ano
/// inteiro, não da corrida.
double taxaIrsDoEscalao({
  required double rendimentoAnualEstimado,
  required TipoRendimento tipo,
  required int ano,
  required RegrasLegais r,
}) {
  final doAno = calcularIrs(
      rendimentoBrutoAnual: rendimentoAnualEstimado, tipo: tipo, ano: ano, r: r);
  if (doAno.abaixoMinimoExistencia) return 0;
  return _taxaDoEscalao(doAno.rendimentoColetavel, r.escaloesDoAno(ano));
}

double _taxaDoEscalao(double coletavel, List<EscalaoIrs> escaloes) {
  if (escaloes.isEmpty) return 0;
  for (final e in escaloes) {
    if (e.ate == null || coletavel <= e.ate!) return e.taxa;
  }
  return escaloes.last.taxa;
}

/// A conta toda. Só faz contas: quem decide o que mostrar é o ecrã.
///
/// [precoUnidade] é o preço do litro (ou do kWh) — vem do último abastecimento
/// da pessoa, por [precoDoUltimoAbastecimento], ou é escrito à mão. Não há
/// recolha de preços ligada (decisão D21: os dados oficiais da DGEG proíbem uso
/// comercial), por isso o preço mais verdadeiro que a app tem é o que a pessoa
/// pagou da última vez.
///
/// [retencao] diz o que lhe tiram NA HORA. Com retenção, o IRS desta corrida é
/// essa retenção e mais nada — a retenção é o IRS pago adiantado, contar as
/// duas coisas seria cobrar duas vezes. Sem retenção ([Retencao.dispensa]), o
/// IRS é estimado pelo escalão do ano; e se nem o ano se sabe
/// ([rendimentoAnualEstimado] a `null`), usa-se o escalão mais baixo da tabela
/// e diz-se que é o mínimo.
ContaDaCorrida calcularValeAPena({
  required double pagam,
  required double km,
  int? minutos,
  required double consumoPor100,
  required double precoUnidade,
  required double desgastePorKm,
  Retencao retencao = Retencao.padrao,
  double? rendimentoAnualEstimado,
  TipoRendimento tipo = TipoRendimento.servicos,
  bool isentoSs = false,
  int? ano,
  required RegrasLegais r,
}) {
  final anoConta = ano ?? DateTime.now().year;
  final kmPositivos = km < 0 ? 0.0 : km;

  final combustivel = centimos(kmPositivos / 100 * consumoPor100 * precoUnidade);
  final desgaste = centimos(kmPositivos * desgastePorKm);

  // Quem está nos 12 primeiros meses de atividade não paga Segurança Social —
  // e é justamente quem mais precisa de ver a conta certa.
  final ss = isentoSs ? 0.0 : centimos(pagam * taxaSsPorEuro(r, tipo: tipo));

  final retido = retencao != Retencao.dispensa;
  var irs = 0.0;
  var irsNoMinimo = false;
  var semIrsAPagar = false;
  if (retido) {
    final taxa = retencao == Retencao.vinteCinco
        ? r.n('retencao_opcao')
        : r.n('retencao_padrao');
    irs = centimos(pagam * taxa / 100);
  } else {
    // Só se quer o coeficiente do regime simplificado desta [calcularIrs] —
    // é ele que diz que parte do que se fatura é que conta para o imposto.
    final coeficiente = calcularIrs(
            rendimentoBrutoAnual: rendimentoAnualEstimado ?? 0,
            tipo: tipo,
            ano: anoConta,
            r: r)
        .coeficiente;
    double taxa;
    if (rendimentoAnualEstimado == null) {
      final escaloes = r.escaloesDoAno(anoConta);
      taxa = escaloes.isEmpty ? 0 : escaloes.first.taxa;
      irsNoMinimo = escaloes.isNotEmpty;
    } else {
      taxa = taxaIrsDoEscalao(
          rendimentoAnualEstimado: rendimentoAnualEstimado,
          tipo: tipo,
          ano: anoConta,
          r: r);
      semIrsAPagar = taxa == 0;
    }
    irs = centimos(pagam * coeficiente * taxa);
  }

  final sobra = centimos(pagam - combustivel - desgaste - ss - irs);
  final fracao = pagam > 0 ? sobra / pagam : 0.0;

  return ContaDaCorrida(
    pagam: centimos(pagam),
    km: kmPositivos,
    minutos: minutos,
    combustivel: combustivel,
    desgaste: desgaste,
    segurancaSocial: ss,
    irs: irs,
    estado: centimos(ss + irs),
    sobra: sobra,
    porHora: (minutos == null || minutos <= 0) ? null : centimos(sobra / minutos * 60),
    custoPorKm: kmPositivos > 0 ? centimos((combustivel + desgaste) / kmPositivos) : 0,
    fracaoQueSobra: fracao,
    nivel: sobra <= 0
        ? NivelSobra.perde
        : (fracao < fracaoSobraBoa ? NivelSobra.pouco : NivelSobra.bem),
    irsRetidoNaHora: retido,
    irsNoMinimo: irsNoMinimo,
    semIrsAPagar: semIrsAPagar,
    isentoSs: isentoSs,
  );
}

/// O preço por litro (ou por kWh) do último abastecimento com litros e valor.
class PrecoPorUnidade {
  final double valor;

  /// O dia do abastecimento de onde veio — o ecrã diz-o, para a pessoa saber
  /// que o preço é dela e de quando é.
  final DateTime data;

  const PrecoPorUnidade(this.valor, this.data);
}

/// O preço que a pessoa pagou da última vez: `valor_total ÷ litros`.
///
/// Devolve `null` quando ainda não há nenhum abastecimento com litros — e aí é
/// a pessoa que escreve o preço. A app não vai buscar preços a lado nenhum
/// (decisão D21), por isso este é o único preço verdadeiro que ela tem.
PrecoPorUnidade? precoDoUltimoAbastecimento(List<AbastecimentoLinha> abastecimentos) {
  final uteis = abastecimentos
      .where((a) => (a.litros ?? 0) > 0 && a.valorTotal > 0)
      .toList()
    ..sort((a, b) => a.data.compareTo(b.data));
  if (uteis.isEmpty) return null;
  final ultimo = uteis.last;
  // Três casas, não duas: o litro custa 1,789 € e arredondar a cêntimos
  // punha-o a 1,79 € — em 500 km isso já é dinheiro a sério.
  final porUnidade = (ultimo.valorTotal / ultimo.litros! * 1000).round() / 1000;
  return PrecoPorUnidade(porUnidade, ultimo.data);
}

/// Quanto o carro gasta aos 100 km, pelos abastecimentos que já lá estão.
///
/// É o mesmo cálculo do ecrã do carro ([custoPorKm]): só se conta o consumo
/// entre depósitos cheios com quilómetros escritos. Sem isso devolve `null` e
/// a pessoa escreve o consumo à mão.
double? consumoDosAbastecimentos(List<AbastecimentoLinha> abastecimentos) {
  final c = custoPorKm(abastecimentos);
  if (c == null || c.litrosPor100Km <= 0) return null;
  return c.litrosPor100Km;
}
