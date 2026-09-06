import 'package:flutter/foundation.dart';

import '../regras/regras.dart';
import '../services/arranque.dart';

/// O resumo do mês e do ano ("Como está o meu mês").
///
/// As contas são feitas no servidor (`resumo_do_mes` e `resumo_do_ano`) e não
/// aqui — mesma razão de sempre: quem mexer na hora do telemóvel não muda as
/// contas, e o mês fecha na hora de Lisboa.
///
/// Os dois modelos vivem neste ficheiro (e não em `lib/models/`) porque só
/// existem para dar forma ao que estas duas funções devolvem: não são coisas
/// que se guardem nem se escrevam, são só a leitura de um jsonb.
///
/// O orquestrador liga isto como os outros:
/// `ChangeNotifierProvider(create: (_) => ResumoStore())`.

/// Lê um número que pode vir como número ou como texto (o jsonb do Postgres
/// devolve `numeric` como número, mas o cliente já mudou de ideias antes).
double _n(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

/// O mês: entrou, saiu, o que ainda falta pagar, e como o mês acaba.
class ResumoMes {
  /// Primeiro dia do mês a que estas contas dizem respeito.
  final DateTime mes;
  final double entrou;
  final double saiu;
  final double faltaPagarContas;
  final double faltaPagarEstado;

  /// O número que interessa: entrou − saiu − o que ainda falta pagar.
  /// Pode ser negativo, e é isso que a app tem de dizer a tempo.
  final double comoAcabaOMes;

  /// Tudo o que está posto de lado para o imposto (soma de sempre, não do mês).
  final double noCofre;

  const ResumoMes({
    required this.mes,
    required this.entrou,
    required this.saiu,
    required this.faltaPagarContas,
    required this.faltaPagarEstado,
    required this.comoAcabaOMes,
    required this.noCofre,
  });

  factory ResumoMes.fromMap(Map<String, dynamic> m) => ResumoMes(
        mes: DateTime.tryParse('${m['mes']}') ?? soDia(hojeLisboa()),
        entrou: _n(m['entrou']),
        saiu: _n(m['saiu']),
        faltaPagarContas: _n(m['falta_pagar_contas']),
        faltaPagarEstado: _n(m['falta_pagar_estado']),
        comoAcabaOMes: _n(m['como_acaba_o_mes']),
        noCofre: _n(m['no_cofre']),
      );

  /// Contas + Estado: o que ainda tem de sair da carteira este mês.
  double get faltaPagarTudo => faltaPagarContas + faltaPagarEstado;

  /// Não há um único número escrito neste mês.
  bool get semNada =>
      entrou == 0 && saiu == 0 && faltaPagarContas == 0 && faltaPagarEstado == 0 && noCofre == 0;
}

/// O ano, para o IRS: quanto entrou, quanto disso conta, de onde veio e quando.
class ResumoAno {
  final int ano;
  final double entrouTotal;
  final double entrouParaIrs;

  /// tipo de entrada (`recibo_verde`, `plataforma`, …) → total do ano.
  final Map<String, double> porTipo;

  /// Doze meses, de janeiro a dezembro. Mês sem nada fica a zero — a lista tem
  /// SEMPRE 12 casas para o gráfico não ter de adivinhar buracos.
  final List<double> porMes;

  final double saiuTotal;

  const ResumoAno({
    required this.ano,
    required this.entrouTotal,
    required this.entrouParaIrs,
    required this.porTipo,
    required this.porMes,
    required this.saiuTotal,
  });

  factory ResumoAno.fromMap(Map<String, dynamic> m) {
    final tipos = <String, double>{};
    final t = m['por_tipo'];
    if (t is Map) {
      t.forEach((k, v) => tipos['$k'] = _n(v));
    }
    // `por_mes` vem com as chaves "2026-01", "2026-03"… só dos meses que têm
    // alguma coisa. Espalha-se pelas 12 casas; o que falta fica a zero.
    final meses = List<double>.filled(12, 0);
    final pm = m['por_mes'];
    if (pm is Map) {
      pm.forEach((k, v) {
        final partes = '$k'.split('-');
        if (partes.length < 2) return;
        final mm = int.tryParse(partes[1]);
        if (mm != null && mm >= 1 && mm <= 12) meses[mm - 1] = _n(v);
      });
    }
    return ResumoAno(
      ano: (m['ano'] is num) ? (m['ano'] as num).toInt() : int.tryParse('${m['ano']}') ?? hojeLisboa().year,
      entrouTotal: _n(m['entrou_total']),
      entrouParaIrs: _n(m['entrou_para_irs']),
      porTipo: tipos,
      porMes: meses,
      saiuTotal: _n(m['saiu_total']),
    );
  }

  /// Do maior para o mais pequeno: é assim que se lê "de onde veio o dinheiro".
  List<MapEntry<String, double>> get tiposPorTamanho {
    final l = porTipo.entries.where((e) => e.value != 0).toList();
    l.sort((a, b) => b.value.compareTo(a.value));
    return l;
  }

  /// O maior mês do ano (serve de topo ao gráfico).
  double get maiorMes => porMes.fold<double>(0, (m, v) => v > m ? v : m);

  bool get semNada => entrouTotal == 0 && saiuTotal == 0 && maiorMes == 0;
}

/// Estado do ecrã "Como está o meu mês".
class ResumoStore extends ChangeNotifier {
  ResumoMes? _mes;
  ResumoAno? _ano;
  int? _anoEscolhido;
  bool _aCarregar = false;
  bool _aCarregarAno = false;
  String? _erro;

  ResumoMes? get mes => _mes;
  ResumoAno? get ano => _ano;
  bool get aCarregar => _aCarregar;

  /// Só o cartão do ano está a carregar (trocou-se de ano). O mês fica quieto.
  bool get aCarregarAno => _aCarregarAno;
  String? get erro => _erro;

  /// O ano que está a ser mostrado. Antes da primeira leitura é o ano de hoje.
  int get anoEscolhido => _anoEscolhido ?? hojeLisboa().year;

  /// Já houve uma leitura boa (mesmo que vazia).
  bool get temDados => _mes != null || _ano != null;

  /// Não há nada escrito em lado nenhum: o ecrã convida a escrever a primeira
  /// coisa em vez de mostrar zeros por todo o lado.
  bool get semNada => temDados && (_mes?.semNada ?? true) && (_ano?.semNada ?? true);

  ResumoStore();

  /// Para testes e fotos (golden): dados já postos, sem servidor.
  ResumoStore.paraTeste({
    ResumoMes? mes,
    ResumoAno? ano,
    bool aCarregar = false,
    String? erro,
    int? anoEscolhido,
  }) {
    // Atribui-se no corpo e não na lista de inicialização de propósito: o
    // analisador pedia `this._mes`, e em Dart um parâmetro com nome não pode
    // começar por underscore — a sugestão dele não compila.
    _mes = mes;
    _ano = ano;
    _aCarregar = aCarregar;
    _erro = erro;
    _anoEscolhido = anoEscolhido ?? ano?.ano;
  }

  /// Vai buscar o mês e o ano ao servidor, os dois ao mesmo tempo.
  ///
  /// Se falhar, guarda o erro MAS não deita fora o que já estava no ecrã: mais
  /// vale um número de há um minuto do que um ecrã em branco.
  Future<void> carregar(String userId, {int? ano}) async {
    _anoEscolhido = ano ?? _anoEscolhido ?? hojeLisboa().year;
    _aCarregar = true;
    _erro = null;
    notifyListeners();
    try {
      // Os dois pedidos ao mesmo tempo: o ecrã abre de uma vez, não em duas.
      final r = await Future.wait<dynamic>([
        sb.rpc('resumo_do_mes', params: {'uid': userId}),
        sb.rpc('resumo_do_ano', params: {'uid': userId, 'ano': _anoEscolhido}),
      ]);
      _mes = ResumoMes.fromMap(Map<String, dynamic>.from(r[0] as Map));
      _ano = ResumoAno.fromMap(Map<String, dynamic>.from(r[1] as Map));
      _erro = null;
    } catch (e) {
      _erro = e.toString();
    } finally {
      _aCarregar = false;
      notifyListeners();
    }
  }

  /// Trocar de ano só volta a pedir o ano — o mês é sempre o mês de hoje.
  Future<void> escolherAno(String userId, int ano) async {
    if (ano == _anoEscolhido && _ano != null) return;
    _anoEscolhido = ano;
    _aCarregarAno = true;
    _erro = null;
    notifyListeners();
    try {
      final r = await sb.rpc('resumo_do_ano', params: {'uid': userId, 'ano': ano});
      _ano = ResumoAno.fromMap(Map<String, dynamic>.from(r as Map));
      _erro = null;
    } catch (e) {
      _erro = e.toString();
    } finally {
      _aCarregarAno = false;
      notifyListeners();
    }
  }
}
