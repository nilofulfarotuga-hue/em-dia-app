/// Uma entrada de dinheiro (tabela `entradas`).
///
/// É o dinheiro que ENTRA: o recibo verde, o pagamento da app, o salário, as
/// notas que alguém deu à mão. Fica tudo na mesma tabela de propósito — quem
/// anda a recibos verdes ganha de sítios diferentes no mesmo mês e não pode
/// ter de escolher em que gaveta arruma cada um.
///
/// Puro: sem Flutter, sem Supabase. Só dados e as duas conversões.
class Entrada {
  final String id;
  final String userId;

  /// O dia em que o dinheiro entrou (só a data, sem horas).
  final DateTime data;
  final double valor;

  /// recibo_verde | plataforma | salario | dinheiro_mao | arrendamento |
  /// subsidio | pensao | outro
  final String tipo;

  /// Só quando [tipo] é `plataforma`: uber | bolt | glovo | uber_eats | outro.
  final String? plataforma;

  final String? descricao;

  /// dia | semana | mes — de quanto tempo é este dinheiro. Quem trabalha nas
  /// apps recebe a semana toda de uma vez; sem isto, a app leria uma semana
  /// como se fosse um dia e diria uma mentira sobre quanto se ganha por dia.
  final String periodo;

  /// Quilómetros feitos para ganhar isto (opcional). É daqui que sai, mais à
  /// frente, o "vale a pena esta corrida".
  final int? km;

  final double? horas;

  /// Se este dinheiro entra nas contas com as Finanças.
  final bool contaParaIrs;

  final String? fotoUrl;
  final String? leituraOcrId;

  const Entrada({
    required this.id,
    required this.userId,
    required this.data,
    required this.valor,
    this.tipo = 'outro',
    this.plataforma,
    this.descricao,
    this.periodo = 'dia',
    this.km,
    this.horas,
    this.contaParaIrs = true,
    this.fotoUrl,
    this.leituraOcrId,
  });

  /// A plataforma só faz sentido quando o dinheiro veio de uma app. Guardar
  /// "bolt" num salário sujava a tabela e enganava as contas mais à frente.
  String? get plataformaValida => tipo == 'plataforma' ? plataforma : null;

  factory Entrada.fromMap(Map<String, dynamic> m) => Entrada(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        data: DateTime.parse(m['data'] as String),
        valor: double.tryParse(m['valor'].toString()) ?? 0,
        tipo: (m['tipo'] as String?) ?? 'outro',
        plataforma: m['plataforma'] as String?,
        descricao: m['descricao'] as String?,
        periodo: (m['periodo'] as String?) ?? 'dia',
        km: (m['km'] as num?)?.toInt(),
        horas: (m['horas'] as num?)?.toDouble(),
        contaParaIrs: m['conta_para_irs'] != false,
        fotoUrl: m['foto_url'] as String?,
        leituraOcrId: m['leitura_ocr_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        // Sem id, o servidor gera um novo. Com id, é o mesmo registo a ser
        // corrigido — é isto que faz o `upsert` servir para os dois casos.
        if (id.isNotEmpty) 'id': id,
        'user_id': userId,
        'data': _iso(data),
        'valor': valor,
        'tipo': tipo,
        'plataforma': plataformaValida,
        'descricao': descricao,
        'periodo': periodo,
        'km': km,
        'horas': horas,
        'conta_para_irs': contaParaIrs,
        'foto_url': fotoUrl,
        'leitura_ocr_id': leituraOcrId,
      };

  Entrada copiarCom({
    DateTime? data,
    double? valor,
    String? tipo,
    String? plataforma,
    String? descricao,
    String? periodo,
    int? km,
    bool? contaParaIrs,
  }) =>
      Entrada(
        id: id,
        userId: userId,
        data: data ?? this.data,
        valor: valor ?? this.valor,
        tipo: tipo ?? this.tipo,
        plataforma: plataforma ?? this.plataforma,
        descricao: descricao ?? this.descricao,
        periodo: periodo ?? this.periodo,
        km: km ?? this.km,
        horas: horas,
        contaParaIrs: contaParaIrs ?? this.contaParaIrs,
        fotoUrl: fotoUrl,
        leituraOcrId: leituraOcrId,
      );

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// Os oito sítios de onde o dinheiro pode vir. A ordem é a dos botões do
/// formulário: primeiro o que é mais comum em quem anda a recibos verdes.
const List<String> tiposEntrada = [
  'recibo_verde',
  'plataforma',
  'salario',
  'dinheiro_mao',
  'arrendamento',
  'subsidio',
  'pensao',
  'outro',
];

/// As apps de trabalho. Mesmos valores da coluna `entradas.plataforma`.
const List<String> plataformasEntrada = ['uber', 'bolt', 'glovo', 'uber_eats', 'outro'];

/// De quanto tempo é o dinheiro que se está a escrever.
const List<String> periodosEntrada = ['dia', 'semana', 'mes'];
