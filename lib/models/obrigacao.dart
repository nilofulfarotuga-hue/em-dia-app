import '../regras/regras.dart';

/// Uma obrigação do calendário (tabela `obrigacoes`).
class ObrigacaoItem {
  final String id;
  final String userId;
  final String? carroId;
  final String tipo;
  final String descricao;
  final DateTime dataLimite;
  final DateTime avisoEm;
  final double? valorEstimado;
  final String estado; // pendente | pago | passado
  final String? comprovativoUrl;
  final String? origemRegra;
  final String? comoPagar;
  final DateTime? pagoEm;

  const ObrigacaoItem({
    required this.id,
    required this.userId,
    this.carroId,
    required this.tipo,
    required this.descricao,
    required this.dataLimite,
    required this.avisoEm,
    this.valorEstimado,
    this.estado = 'pendente',
    this.comprovativoUrl,
    this.origemRegra,
    this.comoPagar,
    this.pagoEm,
  });

  bool get pago => estado == 'pago';
  bool get pendente => estado == 'pendente';

  /// Passou o prazo e não foi marcado como pago.
  bool passou(DateTime hoje) => !pago && dataLimite.isBefore(soDia(hoje));

  int diasParaPrazo(DateTime hoje) => diasAte(dataLimite, hoje);

  /// Nome curto e humano do tipo.
  String get nomeCurto => switch (tipo) {
        'ss_declaracao' => 'Declaração Segurança Social',
        'ss_pagamento' => 'Segurança Social',
        'iva_declaracao' => 'Declaração de IVA',
        'iva_pagamento' => 'IVA',
        'irs_entrega' => 'Entrega do IRS',
        'irs_pagamento_conta' => 'Pagamento por conta (IRS)',
        'efatura_validar' => 'Validar e-fatura',
        'recibos_comunicar' => 'Comunicar faturas',
        'iuc' => 'IUC do carro',
        'ipo' => 'Inspeção do carro',
        'seguro' => 'Seguro do carro',
        'carta' => 'Carta de condução',
        'revisao' => 'Revisão do carro',
        'residencia' => 'Autorização de residência',
        'troca_carta' => 'Troca da carta',
        'tvde_certificado' => 'Certificado TVDE',
        'tvde_licenca' => 'Licença TVDE do carro',
        'multa' => 'Multa',
        'portagem' => 'Portagem',
        'fim_isencao_ss' => 'Fim da isenção',
        _ => 'Obrigação',
      };

  /// É "dinheiro a sair" (para o cartão "Este mês pagas")?
  bool get ehPagamento => const {
        'ss_pagamento', 'iva_pagamento', 'irs_pagamento_conta', 'iuc', 'ipo', 'seguro', 'multa', 'portagem',
      }.contains(tipo);

  factory ObrigacaoItem.fromMap(Map<String, dynamic> m) => ObrigacaoItem(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        carroId: m['carro_id'] as String?,
        tipo: m['tipo'] as String,
        descricao: m['descricao'] as String,
        dataLimite: DateTime.parse(m['data_limite'] as String),
        avisoEm: DateTime.parse(m['aviso_em'] as String),
        valorEstimado: m['valor_estimado'] == null ? null : double.tryParse(m['valor_estimado'].toString()),
        estado: (m['estado'] as String?) ?? 'pendente',
        comprovativoUrl: m['comprovativo_url'] as String?,
        origemRegra: m['origem_regra'] as String?,
        comoPagar: m['como_pagar'] as String?,
        pagoEm: m['pago_em'] == null ? null : DateTime.tryParse(m['pago_em'].toString())?.toLocal(),
      );

  /// Constrói a partir de uma obrigação gerada localmente (pré-visualização do onboarding).
  factory ObrigacaoItem.deGerada(Obrigacao o, String userId) => ObrigacaoItem(
        id: '',
        userId: userId,
        carroId: o.carroId,
        tipo: o.tipo,
        descricao: o.descricao,
        dataLimite: o.dataLimite,
        avisoEm: o.avisoEm,
        valorEstimado: o.valorEstimado,
        origemRegra: o.origemRegra,
        comoPagar: o.comoPagar,
      );
}
