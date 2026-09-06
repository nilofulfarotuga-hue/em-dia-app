/// O que sai: as contas a pagar.
///
/// São duas coisas diferentes e é preciso não as confundir:
///  * [Saida] é a conta em si — "a luz de casa", que existe todos os meses;
///  * [SaidaPagamento] é a conta **deste mês** — a linha que se paga e se
///    marca como paga, gerada no servidor por `gerar_pagamentos_do_mes`.
///
/// Quem apagar a luz de casa não pode apagar o que já pagou no mês passado —
/// por isso a saída desativa-se (`ativa = false`) e os pagamentos ficam.
library;

import '../regras/regras.dart';

/// As 19 categorias da tabela `saidas`. A ordem aqui não manda nada:
/// quem manda no ecrã são os grupos de [gruposCategorias].
const List<String> categoriasSaida = [
  'renda', 'luz', 'agua', 'gas',
  'telemovel', 'internet', 'tv',
  'carro', 'combustivel', 'seguro',
  'escola', 'creche', 'saude', 'ginasio',
  'credito', 'imposto', 'assinatura',
  'compras', 'outro',
];

/// As categorias arrumadas por assunto, com o nome do grupo.
///
/// Dezanove botões seguidos são uma parede. Assim a pessoa procura onde a
/// coisa vive na cabeça dela: a luz está em "casa", a creche está na
/// "família". A chave do grupo tem tradução (`saidasGrupo…`).
const Map<String, List<String>> gruposCategorias = {
  'casa': ['renda', 'luz', 'agua', 'gas'],
  'comunicacoes': ['telemovel', 'internet', 'tv'],
  'carro': ['carro', 'combustivel', 'seguro'],
  'familia': ['escola', 'creche', 'saude', 'ginasio'],
  'dinheiro': ['credito', 'imposto', 'assinatura'],
  'diaAdia': ['compras', 'outro'],
};

/// Os 6 meios de pagamento da tabela `saidas`.
const List<String> meiosPagamento = [
  'debito_direto', 'referencia_mb', 'mbway', 'transferencia', 'dinheiro', 'cartao',
];

/// A entidade do Multibanco tem 5 números. Nem 4 nem 6.
bool entidadeValida(String s) => RegExp(r'^\d{5}$').hasMatch(s.trim());

/// A referência do Multibanco tem 9 números.
bool referenciaValida(String s) => RegExp(r'^\d{9}$').hasMatch(s.trim());

/// Só letras e números fazem parte de uma entidade/referência — quem copia de
/// uma fatura traz espaços e pontos pelo caminho.
String soNumeros(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

/// Uma conta que se paga (tabela `saidas`).
class Saida {
  final String id;
  final String userId;
  final String nome;
  final String categoria;

  /// A nulo quando o valor muda todos os meses ([variavel] a true).
  final double? valor;
  final bool variavel;

  /// Dia do mês em que se paga, 1 a 31.
  final int diaDoMes;
  final String meio;

  /// Os números do Multibanco. Só valem juntos — um sem o outro não paga nada.
  final String? entidade;
  final String? referencia;

  final DateTime? fimFidelizacao;
  final String? fornecedor;
  final bool ativa;
  final String? fotoUrl;
  final String? leituraOcrId;
  final String? notas;

  const Saida({
    required this.id,
    required this.userId,
    required this.nome,
    required this.categoria,
    this.valor,
    this.variavel = false,
    this.diaDoMes = 1,
    this.meio = 'debito_direto',
    this.entidade,
    this.referencia,
    this.fimFidelizacao,
    this.fornecedor,
    this.ativa = true,
    this.fotoUrl,
    this.leituraOcrId,
    this.notas,
  });

  /// Só se mostra a referência quando ela paga mesmo alguma coisa: o meio tem
  /// de ser referência e os dois números têm de lá estar.
  bool get temReferenciaMultibanco =>
      meio == 'referencia_mb' &&
      entidade != null &&
      referencia != null &&
      entidadeValida(entidade!) &&
      referenciaValida(referencia!);

  /// Quantos dias faltam até acabar a fidelização. A nulo quando não há
  /// contrato preso. Negativo quando já acabou.
  int? diasParaFidelizacao(DateTime hoje) =>
      fimFidelizacao == null ? null : diasAte(fimFidelizacao!, hoje);

  factory Saida.fromMap(Map<String, dynamic> m) => Saida(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        nome: (m['nome'] as String?) ?? '',
        categoria: (m['categoria'] as String?) ?? 'outro',
        valor: m['valor'] == null ? null : double.tryParse(m['valor'].toString()),
        variavel: m['variavel'] == true,
        diaDoMes: (m['dia_do_mes'] as num?)?.toInt() ?? 1,
        meio: (m['meio'] as String?) ?? 'debito_direto',
        entidade: m['entidade'] as String?,
        referencia: m['referencia'] as String?,
        fimFidelizacao: m['fim_fidelizacao'] == null
            ? null
            : DateTime.tryParse(m['fim_fidelizacao'] as String),
        fornecedor: m['fornecedor'] as String?,
        ativa: m['ativa'] != false,
        fotoUrl: m['foto_url'] as String?,
        leituraOcrId: m['leitura_ocr_id'] as String?,
        notas: m['notas'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id.isNotEmpty) 'id': id,
        'user_id': userId,
        'nome': nome,
        'categoria': categoria,
        // Conta de valor variável fica sem valor: escrever um número aqui era
        // prometer à pessoa uma conta que não é a que vai chegar.
        'valor': variavel ? null : valor,
        'variavel': variavel,
        'dia_do_mes': diaDoMes,
        'meio': meio,
        // Fora da referência Multibanco estes dois números não querem dizer
        // nada — vão a nulo para não ficarem lá a apodrecer.
        'entidade': meio == 'referencia_mb' ? entidade : null,
        'referencia': meio == 'referencia_mb' ? referencia : null,
        'fim_fidelizacao': fimFidelizacao == null ? null : dataPtIso(fimFidelizacao!),
        'fornecedor': fornecedor,
        'ativa': ativa,
        'foto_url': fotoUrl,
        'leitura_ocr_id': leituraOcrId,
        'notas': notas,
      };

  Saida copyWith({
    String? nome,
    String? categoria,
    double? valor,
    bool? variavel,
    int? diaDoMes,
    String? meio,
    String? entidade,
    String? referencia,
    DateTime? fimFidelizacao,
    String? fornecedor,
    bool? ativa,
    String? leituraOcrId,
    String? notas,
  }) =>
      Saida(
        id: id,
        userId: userId,
        nome: nome ?? this.nome,
        categoria: categoria ?? this.categoria,
        valor: valor ?? this.valor,
        variavel: variavel ?? this.variavel,
        diaDoMes: diaDoMes ?? this.diaDoMes,
        meio: meio ?? this.meio,
        entidade: entidade ?? this.entidade,
        referencia: referencia ?? this.referencia,
        fimFidelizacao: fimFidelizacao ?? this.fimFidelizacao,
        fornecedor: fornecedor ?? this.fornecedor,
        ativa: ativa ?? this.ativa,
        fotoUrl: fotoUrl,
        leituraOcrId: leituraOcrId ?? this.leituraOcrId,
        notas: notas ?? this.notas,
      );
}

/// A conta de um mês (tabela `saidas_pagamentos`). É isto que se paga.
class SaidaPagamento {
  final String id;
  final String userId;
  final String saidaId;

  /// 1.º dia do mês a que a conta pertence.
  final DateTime mes;
  final DateTime dataLimite;

  /// A nulo nas contas de valor variável enquanto ninguém escreveu o valor.
  final double? valor;

  /// pendente | pago | saltado
  final String estado;
  final DateTime? pagoEm;
  final String? comprovativoUrl;

  const SaidaPagamento({
    required this.id,
    required this.userId,
    required this.saidaId,
    required this.mes,
    required this.dataLimite,
    this.valor,
    this.estado = 'pendente',
    this.pagoEm,
    this.comprovativoUrl,
  });

  bool get pago => estado == 'pago';
  bool get pendente => estado == 'pendente';
  bool get saltado => estado == 'saltado';

  /// Passou o dia e continua por pagar.
  bool passou(DateTime hoje) => pendente && dataLimite.isBefore(soDia(hoje));

  int diasParaPrazo(DateTime hoje) => diasAte(dataLimite, hoje);

  /// Só conta para o "falta pagar" o que ainda está pendente. Uma conta
  /// saltada (o mês em que não houve ginásio) não entra na soma.
  bool get contaParaFalta => pendente;

  factory SaidaPagamento.fromMap(Map<String, dynamic> m) => SaidaPagamento(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        saidaId: m['saida_id'] as String,
        mes: DateTime.parse(m['mes'] as String),
        dataLimite: DateTime.parse(m['data_limite'] as String),
        valor: m['valor'] == null ? null : double.tryParse(m['valor'].toString()),
        estado: (m['estado'] as String?) ?? 'pendente',
        pagoEm: m['pago_em'] == null ? null : DateTime.tryParse(m['pago_em'] as String),
        comprovativoUrl: m['comprovativo_url'] as String?,
      );
}
