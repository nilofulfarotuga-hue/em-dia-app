import '../regras/regras.dart';

/// Um carro do utilizador (tabela `carros`).
class Carro {
  final String id;
  final String userId;
  final String? nome;
  final String matricula;
  final DateTime? dataMatricula;
  final int? mesMatricula;
  final int? anoMatricula;
  final String categoria; // proprio | alugado_frota
  final bool usoTvde;
  final Combustivel combustivel;
  final int? cilindradaCc;
  final int? co2;
  final String? seguradora;
  final DateTime? seguroRenovaEm;
  final DateTime? ultimaIpo;
  final DateTime? proximaIpo;
  final int? kmAtual;
  final DateTime? cartaValidade;
  final DateTime? revisaoProxima;
  final int? revisaoKm;
  final bool ativo;

  const Carro({
    required this.id,
    required this.userId,
    this.nome,
    required this.matricula,
    this.dataMatricula,
    this.mesMatricula,
    this.anoMatricula,
    this.categoria = 'proprio',
    this.usoTvde = false,
    this.combustivel = Combustivel.gasolina,
    this.cilindradaCc,
    this.co2,
    this.seguradora,
    this.seguroRenovaEm,
    this.ultimaIpo,
    this.proximaIpo,
    this.kmAtual,
    this.cartaValidade,
    this.revisaoProxima,
    this.revisaoKm,
    this.ativo = true,
  });

  String get nomeOuMatricula => (nome == null || nome!.isEmpty) ? matricula : nome!;

  /// Data de matrícula efetiva: a data completa, ou o último dia do mês/ano.
  DateTime? get matriculaEfetiva {
    if (dataMatricula != null) return dataMatricula;
    if (mesMatricula != null && anoMatricula != null) {
      return DateTime(anoMatricula!, mesMatricula!, ultimoDiaDoMes(anoMatricula!, mesMatricula!));
    }
    return null;
  }

  CarroObrigacoes? get paraObrigacoes {
    final m = matriculaEfetiva;
    if (m == null) return null;
    return CarroObrigacoes(
      id: id,
      matricula: matricula,
      dataMatricula: m,
      seguroRenovaEm: seguroRenovaEm,
      ultimaIpo: ultimaIpo,
      cartaValidade: cartaValidade,
      usoTvde: usoTvde,
      combustivel: combustivel,
      cilindradaCc: cilindradaCc,
      co2: co2,
    );
  }

  static Combustivel combustivelDe(String? s) => switch (s) {
        'gasoleo' => Combustivel.gasoleo,
        'eletrico' => Combustivel.eletrico,
        'hibrido' => Combustivel.hibrido,
        'gpl' => Combustivel.gpl,
        'outro' => Combustivel.outro,
        _ => Combustivel.gasolina,
      };

  static String combustivelParaDb(Combustivel c) => c.name;

  factory Carro.fromMap(Map<String, dynamic> m) => Carro(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        nome: m['nome'] as String?,
        matricula: m['matricula'] as String,
        dataMatricula: _data(m['data_matricula']),
        mesMatricula: (m['mes_matricula'] as num?)?.toInt(),
        anoMatricula: (m['ano_matricula'] as num?)?.toInt(),
        categoria: (m['categoria'] as String?) ?? 'proprio',
        usoTvde: (m['uso_tvde'] as bool?) ?? false,
        combustivel: combustivelDe(m['combustivel'] as String?),
        cilindradaCc: (m['cilindrada_cc'] as num?)?.toInt(),
        co2: (m['co2_g_km'] as num?)?.toInt(),
        seguradora: m['seguradora'] as String?,
        seguroRenovaEm: _data(m['seguro_renova_em']),
        ultimaIpo: _data(m['ultima_ipo']),
        proximaIpo: _data(m['proxima_ipo']),
        kmAtual: (m['km_atual'] as num?)?.toInt(),
        cartaValidade: _data(m['carta_validade']),
        revisaoProxima: _data(m['revisao_proxima']),
        revisaoKm: (m['revisao_km'] as num?)?.toInt(),
        ativo: (m['ativo'] as bool?) ?? true,
      );

  Map<String, dynamic> toMap() => {
        if (id.isNotEmpty) 'id': id,
        'user_id': userId,
        'nome': nome,
        'matricula': matricula,
        'data_matricula': dataMatricula == null ? null : dataPtIso(dataMatricula!),
        'mes_matricula': mesMatricula ?? dataMatricula?.month,
        'ano_matricula': anoMatricula ?? dataMatricula?.year,
        'categoria': categoria,
        'uso_tvde': usoTvde,
        'combustivel': combustivelParaDb(combustivel),
        'cilindrada_cc': cilindradaCc,
        'co2_g_km': co2,
        'seguradora': seguradora,
        'seguro_renova_em': seguroRenovaEm == null ? null : dataPtIso(seguroRenovaEm!),
        'ultima_ipo': ultimaIpo == null ? null : dataPtIso(ultimaIpo!),
        'proxima_ipo': proximaIpo == null ? null : dataPtIso(proximaIpo!),
        'km_atual': kmAtual,
        'carta_validade': cartaValidade == null ? null : dataPtIso(cartaValidade!),
        'revisao_proxima': revisaoProxima == null ? null : dataPtIso(revisaoProxima!),
        'revisao_km': revisaoKm,
        'ativo': ativo,
      };
}

class Abastecimento {
  final String id;
  final String carroId;
  final DateTime data;
  final double? litros;
  final double valorTotal;
  final int? km;
  final bool depositoCheio;
  final String? posto;
  final bool comNif;

  const Abastecimento({
    required this.id,
    required this.carroId,
    required this.data,
    this.litros,
    required this.valorTotal,
    this.km,
    this.depositoCheio = true,
    this.posto,
    this.comNif = false,
  });

  AbastecimentoLinha get linha => AbastecimentoLinha(
      data: data, valorTotal: valorTotal, litros: litros, km: km, depositoCheio: depositoCheio);

  factory Abastecimento.fromMap(Map<String, dynamic> m) => Abastecimento(
        id: m['id'] as String,
        carroId: m['carro_id'] as String,
        data: DateTime.parse(m['data'] as String),
        litros: _num(m['litros']),
        valorTotal: _num(m['valor_total']) ?? 0,
        km: (m['km'] as num?)?.toInt(),
        depositoCheio: (m['deposito_cheio'] as bool?) ?? true,
        posto: m['posto'] as String?,
        comNif: (m['com_nif'] as bool?) ?? false,
      );
}

class DespesaCarro {
  final String id;
  final String carroId;
  final DateTime data;
  final String tipo;
  final double valor;
  final String? descricao;
  final String? comprovativoUrl;
  final bool comNif;
  final DateTime? dataLimite;
  final bool pago;

  const DespesaCarro({
    required this.id,
    required this.carroId,
    required this.data,
    required this.tipo,
    required this.valor,
    this.descricao,
    this.comprovativoUrl,
    this.comNif = false,
    this.dataLimite,
    this.pago = true,
  });

  factory DespesaCarro.fromMap(Map<String, dynamic> m) => DespesaCarro(
        id: m['id'] as String,
        carroId: m['carro_id'] as String,
        data: DateTime.parse(m['data'] as String),
        tipo: m['tipo'] as String,
        valor: _num(m['valor']) ?? 0,
        descricao: m['descricao'] as String?,
        comprovativoUrl: m['comprovativo_url'] as String?,
        comNif: (m['com_nif'] as bool?) ?? false,
        dataLimite: _data(m['data_limite']),
        pago: (m['pago'] as bool?) ?? true,
      );
}

DateTime? _data(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
double? _num(dynamic v) => v == null ? null : double.tryParse(v.toString());
