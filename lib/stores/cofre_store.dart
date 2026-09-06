import 'package:flutter/foundation.dart';

import '../models/cofre_movimento.dart';
import '../regras/regras.dart';
import '../services/arranque.dart';
import 'resumo_store.dart' show ResumoAno;

/// O cofre do imposto: o que a pessoa aponta que já pôs de lado, e a conta do
/// que devia lá ter.
///
/// Padrão Model → Store → Screen. O ecrã não fala com o Supabase, fala com
/// isto.
///
/// **Este ecrã não mexe em dinheiro nenhum.** Não há banco, não há
/// transferência, não há nada automático — só linhas num caderno. Está escrito
/// no ecrã porque tem de estar, e fica escrito aqui porque quem vier a seguir
/// tem de resistir à tentação de ligar isto a uma conta a sério.
class CofreStore extends ChangeNotifier {
  List<CofreMovimento> _movimentos = [];
  double _entrouParaIrs = 0;
  int? _ano;
  bool _aCarregar = false;
  String? _erro;
  String? _userCarregado;

  /// Do mais recente para o mais antigo — é assim que se lê um caderno.
  List<CofreMovimento> get movimentos => _movimentos;
  bool get aCarregar => _aCarregar;
  String? get erro => _erro;

  /// Já houve uma leitura boa (mesmo que não tenha trazido nada).
  bool get temDados => _userCarregado != null;

  /// O ano a que a conta do "devia ter" diz respeito.
  int get ano => _ano ?? hojeLisboa().year;

  /// O que entrou este ano e conta para o IRS. Vem do servidor
  /// (`resumo_do_ano` → `entrou_para_irs`), não da soma das entradas no
  /// telemóvel: quem mexer na hora do aparelho não muda as contas.
  double get entrouParaIrs => _entrouParaIrs;

  /// Quanto está no cofre: a soma de tudo o que foi apontado.
  ///
  /// **Porque não se pede este número ao servidor.** O `resumo_do_mes` também
  /// o devolve (`no_cofre`) e é isso que o `ResumoStore` usa no cartão do
  /// resumo, onde a lista não é carregada. Aqui a lista JÁ está toda carregada,
  /// e a RLS só deixa ver as linhas do próprio: a soma destas linhas é
  /// exactamente a mesma conta que o servidor faz. Dois números com a mesma
  /// origem no mesmo ecrã só servem para se contradizerem quando um chega
  /// atrasado — e a pessoa acreditaria no errado.
  double get saldo => centimos(_movimentos.fold<double>(0, (s, m) => s + m.valor));

  CofreStore();

  /// Para testes e fotos (golden): tudo posto à mão, sem servidor.
  /// Ordena como o [carregar] faria, para o teste não depender da ordem por
  /// que alguém escreveu a lista.
  CofreStore.paraTeste(
    List<CofreMovimento> movimentos, {
    double entrouParaIrs = 0,
    int? ano,
    bool aCarregar = false,
    String? erro,
  }) : _movimentos = List.of(movimentos)..sort(_maisRecentePrimeiro) {
    _entrouParaIrs = entrouParaIrs;
    _ano = ano;
    _aCarregar = aCarregar;
    _erro = erro;
    // Os três estados que o ecrã tem de saber desenhar têm de caber todos aqui,
    // senão a fábrica de fotos nunca os apanha e ninguém dá por eles estarem
    // partidos: a carregar pela primeira vez (`aCarregar: true`), falhou antes
    // de ter fosse o que fosse (lista vazia + `erro`), ou já leu alguma coisa.
    _userCarregado = (aCarregar || (movimentos.isEmpty && erro != null))
        ? null
        : (movimentos.isEmpty ? 'teste' : movimentos.first.userId);
  }

  static int _maisRecentePrimeiro(CofreMovimento a, CofreMovimento b) =>
      b.data.compareTo(a.data);

  // CICATRIZ da casa: no cliente do Supabase, `.order('coluna')` sozinho
  // devolve por ordem DECRESCENTE. Aqui até é decrescente que se quer, mas
  // escreve-se `ascending: false` à mão na mesma — ninguém a ler isto tem de
  // adivinhar qual era o valor por omissão.
  Future<void> carregar(String userId, {int? ano}) async {
    _ano = ano ?? _ano ?? hojeLisboa().year;
    _aCarregar = true;
    notifyListeners();
    try {
      // Os dois pedidos ao mesmo tempo: o ecrã abre de uma vez, não em duas.
      final r = await Future.wait<dynamic>([
        sb
            .from('cofre_movimentos')
            .select()
            .eq('user_id', userId)
            .order('data', ascending: false)
            .order('criado_em', ascending: false),
        sb.rpc('resumo_do_ano', params: {'uid': userId, 'ano': _ano}),
      ]);
      _movimentos = (r[0] as List)
          .map((m) => CofreMovimento.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList();
      // O modelo do ano é o do ResumoStore de propósito: a leitura deste jsonb
      // já estava escrita e testada — repeti-la aqui era arranjar maneira de
      // as duas versões passarem a discordar.
      _entrouParaIrs = ResumoAno.fromMap(Map<String, dynamic>.from(r[1] as Map)).entrouParaIrs;
      _userCarregado = userId;
      _erro = null;
    } catch (e) {
      _erro = e.toString();
    } finally {
      _aCarregar = false;
      notifyListeners();
    }
  }

  /// Carrega só à primeira vez que o ecrã aparece (ou quando muda de conta).
  /// O [ano] vem do ecrã (que sabe qual é o "hoje" das fotos e dos testes) e
  /// não do relógio desta store — senão uma foto tirada com uma data fixa ia
  /// buscar o ano de verdade e o número mudava de dia para dia.
  Future<void> carregarSePreciso(String userId, {int? ano}) async {
    if (_userCarregado == userId || _aCarregar) return;
    await carregar(userId, ano: ano);
  }

  /// Aponta um movimento novo. Devolve `false` se o servidor recusar — e nesse
  /// caso nada fica na lista, para o número de cima não mentir.
  Future<bool> apontar(CofreMovimento m) async {
    try {
      // `insert` e não `upsert`: cada anotação é uma linha nova. O `toMap`
      // já não manda `id` nenhum quando ele vem vazio — é o servidor que o dá.
      await sb.from('cofre_movimentos').insert(m.toMap());
      await carregar(m.userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Apaga uma linha do caderno. Tira-a já da lista e só depois fala com o
  /// servidor: quem carregou no caixote vê-a desaparecer no momento. Se o
  /// servidor recusar, a linha volta e o ecrã mostra o erro.
  Future<bool> apagar(CofreMovimento m) async {
    final antes = List.of(_movimentos);
    _movimentos = _movimentos.where((x) => x.id != m.id).toList();
    notifyListeners();
    try {
      await sb.from('cofre_movimentos').delete().eq('id', m.id);
      _erro = null;
      return true;
    } catch (e) {
      _movimentos = antes;
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// A conta do "quanto devia lá estar", com as regras que o ecrã lhe der.
  ///
  /// A store não guarda as [RegrasLegais] de propósito: elas vivem no
  /// `RegrasStore` e mudam quando o servidor as actualiza. Assim esta conta é
  /// sempre feita com os números que estão no ecrã naquele momento.
  ContaDoCofre conta({
    required RegrasLegais regras,
    TipoRendimento tipo = TipoRendimento.servicos,
    DateTime? dataAbertura,
    int ajusteSsPct = 0,
  }) =>
      calcularDeviaTerNoCofre(
        rendimentoDoAnoParaIrs: _entrouParaIrs,
        tipo: tipo,
        ano: ano,
        regras: regras,
        dataAbertura: dataAbertura,
        ajusteSsPct: ajusteSsPct,
      );
}

/// Como está o cofre em relação ao que devia ter.
enum EstadoCofre {
  /// Tem o que precisa (ou mais).
  chega,

  /// Falta pouco.
  faltaPouco,

  /// Falta a sério.
  faltaMuito,
}

/// A conta do que devia estar no cofre.
class ContaDoCofre {
  /// O que entrou no ano e conta para o IRS (a base de tudo o resto).
  final double rendimento;

  /// Segurança Social do ano inteiro.
  final double segurancaSocial;

  /// IRS estimado do ano.
  final double irs;

  /// A parte do Estado: os dois somados. É este o número do "devias ter".
  final double total;

  /// Quantos meses do ano é que contam para a Segurança Social (12 quando não
  /// há isenção de 1.º ano pelo meio).
  final int mesesDeSs;

  /// A contribuição bateu no mínimo mensal (quem ganha pouco paga o mínimo na
  /// mesma). O ecrã diz isto por palavras para o número não parecer um erro.
  final bool ssNoMinimo;

  /// Os escalões de IRS deste ano ainda estão `por_confirmar` na tabela. Não
  /// se cala: diz-se que a conta é aproximada.
  final bool irsAproximado;

  const ContaDoCofre({
    required this.rendimento,
    required this.segurancaSocial,
    required this.irs,
    required this.total,
    required this.mesesDeSs,
    required this.ssNoMinimo,
    required this.irsAproximado,
  });

  /// Ainda não há um único euro escrito este ano: sem isto, o ecrã anunciava
  /// um "devias ter" que só vinha do mínimo da Segurança Social e assustava
  /// quem ainda não escreveu nada.
  bool get semRendimento => rendimento <= 0;

  /// Está isento da Segurança Social em parte do ano (ou no ano todo).
  bool get temIsencaoSs => mesesDeSs < 12;

  /// O que sobra (positivo) ou o que falta (negativo) face ao [saldo].
  double diferenca(double saldo) => centimos(saldo - total);

  /// Quanto falta, sempre positivo. Zero quando já chega.
  double falta(double saldo) {
    final d = diferenca(saldo);
    return d >= 0 ? 0 : -d;
  }

  /// A cor do ecrã.
  ///
  /// A RÉGUA DOS 10% NÃO É UM NÚMERO LEGAL — é uma escolha de desenho, e por
  /// isso pode viver aqui (a regra da casa proíbe constantes para números da
  /// lei, e este não vem de lei nenhuma). Serve para não pintar de vermelho
  /// quem só está a um bocadinho do que precisa: vermelho a toda a hora deixa
  /// de querer dizer alguma coisa. Se um dia se quiser afinar por utilizador,
  /// passa a ser uma chave de `regras_legais`.
  EstadoCofre estado(double saldo) {
    if (total <= 0) return EstadoCofre.chega;
    final emFalta = falta(saldo);
    if (emFalta <= 0) return EstadoCofre.chega;
    return emFalta <= total * 0.10 ? EstadoCofre.faltaPouco : EstadoCofre.faltaMuito;
  }
}

/// Quanto devia estar no cofre: a parte do Estado sobre o que entrou no ano.
///
/// **Não refaz conta nenhuma:** chama o que já está escrito e testado em
/// `lib/regras/seguranca_social.dart` e `lib/regras/irs.dart`. Todos os
/// números (taxa, base, coeficientes, escalões, mínimo) saem da tabela
/// `regras_legais` por dentro dessas funções.
///
/// **Segurança Social:** a função da casa trabalha por trimestre, porque é
/// assim que a lei conta. Dá-se-lhe um quarto do ano e usa-se a contribuição
/// MENSAL que ela devolve — assim o mínimo de 20 €/mês e o tecto de 12×IAS
/// ficam aplicados onde devem, e não a um número anual inventado.
///
/// **Isenção do 1.º ano:** quem abriu atividade há menos de 12 meses não paga
/// Segurança Social, e dizer-lhe que devia ter mil euros de lado para ela era
/// uma mentira que a fazia guardar dinheiro a mais. Contam-se só os meses do
/// ano já fora da isenção.
///
/// **O que esta conta NÃO sabe:** em que meses é que o dinheiro entrou. Espalha
/// o ano por igual. Para um cofre — que serve para não ser apanhado de surpresa
/// — chega; para preencher a declaração, não serve, e o ecrã diz isso.
ContaDoCofre calcularDeviaTerNoCofre({
  required double rendimentoDoAnoParaIrs,
  required TipoRendimento tipo,
  required int ano,
  required RegrasLegais regras,
  DateTime? dataAbertura,
  int ajusteSsPct = 0,
}) {
  if (rendimentoDoAnoParaIrs <= 0) {
    return const ContaDoCofre(
      rendimento: 0,
      segurancaSocial: 0,
      irs: 0,
      total: 0,
      mesesDeSs: 12,
      ssNoMinimo: false,
      irsAproximado: false,
    );
  }

  final meses = mesesComSegurancaSocial(ano: ano, dataAbertura: dataAbertura, regras: regras);
  final ss = calcularSS(
    rendimentoTrimestre: rendimentoDoAnoParaIrs / 4,
    tipo: tipo,
    ajustePct: ajusteSsPct,
    r: regras,
  );
  final ssDoAno = centimos(ss.contribuicaoMensal * meses);

  final irs = calcularIrs(
    rendimentoBrutoAnual: rendimentoDoAnoParaIrs,
    tipo: tipo,
    ano: ano,
    r: regras,
  );

  return ContaDoCofre(
    rendimento: rendimentoDoAnoParaIrs,
    segurancaSocial: ssDoAno,
    irs: irs.impostoEstimado,
    total: centimos(ssDoAno + irs.impostoEstimado),
    mesesDeSs: meses,
    ssNoMinimo: meses > 0 && ss.bateuNoMinimo,
    irsAproximado: !irs.escaloesConfirmados,
  );
}

/// Quantos meses de um ano é que já estão fora da isenção do 1.º ano.
///
/// Sem data de abertura não há isenção conhecida: contam os 12 meses. É o lado
/// seguro — mais vale ter dinheiro de lado a mais do que a menos.
int mesesComSegurancaSocial({
  required int ano,
  required DateTime? dataAbertura,
  required RegrasLegais regras,
}) {
  if (dataAbertura == null) return 12;
  final comecaAPagar = fimIsencaoSS(dataAbertura, regras);
  if (comecaAPagar.year > ano) return 0;
  if (comecaAPagar.year < ano) return 12;
  // Começa a pagar num mês deste ano: contam esse mês e os que vêm a seguir.
  return 12 - (comecaAPagar.month - 1);
}
