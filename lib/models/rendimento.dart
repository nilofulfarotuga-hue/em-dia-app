/// Um rendimento mensal registado (tabela `rendimentos`).
class Rendimento {
  final String id;
  final String userId;
  final DateTime mes; // 1.º dia do mês
  final double valorBruto;
  final String tipo; // servicos | vendas
  final String origem; // manual | foto
  final String? plataforma;
  final String? comprovativoUrl;
  final String? nota;

  const Rendimento({
    required this.id,
    required this.userId,
    required this.mes,
    required this.valorBruto,
    this.tipo = 'servicos',
    this.origem = 'manual',
    this.plataforma,
    this.comprovativoUrl,
    this.nota,
  });

  factory Rendimento.fromMap(Map<String, dynamic> m) => Rendimento(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        mes: DateTime.parse(m['mes'] as String),
        valorBruto: double.tryParse(m['valor_bruto'].toString()) ?? 0,
        tipo: (m['tipo'] as String?) ?? 'servicos',
        origem: (m['origem'] as String?) ?? 'manual',
        plataforma: m['plataforma'] as String?,
        comprovativoUrl: m['comprovativo_url'] as String?,
        nota: m['nota'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id.isNotEmpty) 'id': id,
        'user_id': userId,
        'mes': '${mes.year}-${mes.month.toString().padLeft(2, '0')}-01',
        'valor_bruto': valorBruto,
        'tipo': tipo,
        'origem': origem,
        'plataforma': plataforma,
        'comprovativo_url': comprovativoUrl,
        'nota': nota,
      };
}
