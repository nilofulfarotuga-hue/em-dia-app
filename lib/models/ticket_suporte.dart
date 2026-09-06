/// Um pedido de ajuda do utilizador (tabela `tickets_suporte`).
class TicketSuporte {
  final String id;

  /// duvida · bug · reembolso · guia_novo · outro
  final String tipo;
  final String assunto;
  final String? descricao;

  /// aberto · em_curso · fechado
  final String estado;
  final bool escalarHumano;
  final String? respostaIa;
  final DateTime criadoEm;

  const TicketSuporte({
    required this.id,
    required this.tipo,
    required this.assunto,
    this.descricao,
    required this.estado,
    this.escalarHumano = false,
    this.respostaIa,
    required this.criadoEm,
  });

  /// Os 8 primeiros caracteres do id — o "n.º do pedido" que se mostra.
  String get idCurto => id.length >= 8 ? id.substring(0, 8) : id;

  factory TicketSuporte.fromMap(Map<String, dynamic> m) => TicketSuporte(
        id: m['id'] as String,
        tipo: (m['tipo'] as String?) ?? 'outro',
        assunto: (m['assunto'] as String?) ?? '',
        descricao: m['descricao'] as String?,
        estado: (m['estado'] as String?) ?? 'aberto',
        escalarHumano: m['escalar_humano'] == true,
        respostaIa: m['resposta_ia'] as String?,
        criadoEm: DateTime.tryParse((m['criado_em'] as String?) ?? '')?.toLocal() ?? DateTime.now(),
      );
}
