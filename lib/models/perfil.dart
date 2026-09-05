import '../regras/regras.dart';

/// O perfil do utilizador (tabela `profiles`). `trialAte` e `plano` são do
/// servidor: a app lê, nunca escreve (o trigger ignora se tentar).
class Perfil {
  final String userId;
  final String? nome;
  final String? email;
  final String? telefone;
  final TipoAtividade tipoAtividade;
  final DateTime? dataAbertura;
  final RegimeIva regimeIva;
  final bool faturouMais15kAnoAnterior;
  final String retencaoOpcao; // padrao | 25 | dispensa
  final TipoRendimento tipoRendimento;
  final double? rendimentoMensalEstimado;
  final int ajusteSsPct;
  final String variantePt; // pt | br
  final String plano; // free | pro | familia (servidor)
  final DateTime trialAte; // servidor
  final bool onboardingConcluido;
  final bool imigrante;
  final DateTime? residenciaRenovaEm;
  final bool banido;
  final DateTime criadoEm;

  const Perfil({
    required this.userId,
    this.nome,
    this.email,
    this.telefone,
    this.tipoAtividade = TipoAtividade.semAtividade,
    this.dataAbertura,
    this.regimeIva = RegimeIva.isento53,
    this.faturouMais15kAnoAnterior = false,
    this.retencaoOpcao = 'padrao',
    this.tipoRendimento = TipoRendimento.servicos,
    this.rendimentoMensalEstimado,
    this.ajusteSsPct = 0,
    this.variantePt = 'pt',
    this.plano = 'free',
    required this.trialAte,
    this.onboardingConcluido = false,
    this.imigrante = false,
    this.residenciaRenovaEm,
    this.banido = false,
    required this.criadoEm,
  });

  bool get emTrial => trialAte.isAfter(DateTime.now());
  int get diasDeTrialRestantes =>
      emTrial ? trialAte.difference(DateTime.now()).inDays + 1 : 0;

  PerfilObrigacoes get paraObrigacoes => PerfilObrigacoes(
        tipoAtividade: tipoAtividade,
        dataAbertura: dataAbertura,
        regimeIva: regimeIva,
        tipoRendimento: tipoRendimento,
        rendimentoMensalEstimado: rendimentoMensalEstimado,
        ajusteSsPct: ajusteSsPct,
        imigrante: imigrante,
        residenciaRenovaEm: residenciaRenovaEm,
      );

  static TipoAtividade _tipo(String? s) => switch (s) {
        'tvde' => TipoAtividade.tvde,
        'estafeta' => TipoAtividade.estafeta,
        'servicos' => TipoAtividade.servicos,
        'freelancer' => TipoAtividade.freelancer,
        'so_carro' => TipoAtividade.soCarro,
        _ => TipoAtividade.semAtividade,
      };

  static String tipoParaDb(TipoAtividade t) => switch (t) {
        TipoAtividade.tvde => 'tvde',
        TipoAtividade.estafeta => 'estafeta',
        TipoAtividade.servicos => 'servicos',
        TipoAtividade.freelancer => 'freelancer',
        TipoAtividade.soCarro => 'so_carro',
        TipoAtividade.semAtividade => 'sem_atividade',
      };

  factory Perfil.fromMap(Map<String, dynamic> m) => Perfil(
        userId: m['user_id'] as String,
        nome: m['nome'] as String?,
        email: m['email'] as String?,
        telefone: m['telefone'] as String?,
        tipoAtividade: _tipo(m['tipo_atividade'] as String?),
        dataAbertura: _data(m['data_abertura']),
        regimeIva: m['regime_iva'] == 'normal' ? RegimeIva.normal : RegimeIva.isento53,
        faturouMais15kAnoAnterior: (m['faturou_mais_15k_ano_anterior'] as bool?) ?? false,
        retencaoOpcao: (m['retencao_opcao'] as String?) ?? 'padrao',
        tipoRendimento: m['tipo_rendimento'] == 'vendas' ? TipoRendimento.vendas : TipoRendimento.servicos,
        rendimentoMensalEstimado: _num(m['rendimento_mensal_estimado']),
        ajusteSsPct: (m['ajuste_ss_pct'] as num?)?.toInt() ?? 0,
        variantePt: (m['variante_pt'] as String?) ?? 'pt',
        plano: (m['plano'] as String?) ?? 'free',
        trialAte: DateTime.parse(m['trial_ate'] as String).toLocal(),
        onboardingConcluido: (m['onboarding_concluido'] as bool?) ?? false,
        imigrante: (m['imigrante'] as bool?) ?? false,
        residenciaRenovaEm: _data(m['residencia_renova_em']),
        banido: (m['banido'] as bool?) ?? false,
        criadoEm: DateTime.parse(m['criado_em'] as String).toLocal(),
      );

  /// Só os campos que o utilizador pode escrever.
  Map<String, dynamic> toUpdate() => {
        'nome': nome,
        'telefone': telefone,
        'tipo_atividade': tipoParaDb(tipoAtividade),
        'data_abertura': dataAbertura == null ? null : dataPtIso(dataAbertura!),
        'regime_iva': regimeIva == RegimeIva.normal ? 'normal' : 'isento_53',
        'faturou_mais_15k_ano_anterior': faturouMais15kAnoAnterior,
        'retencao_opcao': retencaoOpcao,
        'tipo_rendimento': tipoRendimento == TipoRendimento.vendas ? 'vendas' : 'servicos',
        'rendimento_mensal_estimado': rendimentoMensalEstimado,
        'ajuste_ss_pct': ajusteSsPct,
        'variante_pt': variantePt,
        'onboarding_concluido': onboardingConcluido,
        'imigrante': imigrante,
        'residencia_renova_em': residenciaRenovaEm == null ? null : dataPtIso(residenciaRenovaEm!),
      };

  Perfil copyWith({
    String? nome,
    String? telefone,
    TipoAtividade? tipoAtividade,
    DateTime? dataAbertura,
    bool limparDataAbertura = false,
    RegimeIva? regimeIva,
    bool? faturouMais15kAnoAnterior,
    String? retencaoOpcao,
    TipoRendimento? tipoRendimento,
    double? rendimentoMensalEstimado,
    int? ajusteSsPct,
    String? variantePt,
    bool? onboardingConcluido,
    bool? imigrante,
    DateTime? residenciaRenovaEm,
  }) =>
      Perfil(
        userId: userId,
        nome: nome ?? this.nome,
        email: email,
        telefone: telefone ?? this.telefone,
        tipoAtividade: tipoAtividade ?? this.tipoAtividade,
        dataAbertura: limparDataAbertura ? null : (dataAbertura ?? this.dataAbertura),
        regimeIva: regimeIva ?? this.regimeIva,
        faturouMais15kAnoAnterior: faturouMais15kAnoAnterior ?? this.faturouMais15kAnoAnterior,
        retencaoOpcao: retencaoOpcao ?? this.retencaoOpcao,
        tipoRendimento: tipoRendimento ?? this.tipoRendimento,
        rendimentoMensalEstimado: rendimentoMensalEstimado ?? this.rendimentoMensalEstimado,
        ajusteSsPct: ajusteSsPct ?? this.ajusteSsPct,
        variantePt: variantePt ?? this.variantePt,
        plano: plano,
        trialAte: trialAte,
        onboardingConcluido: onboardingConcluido ?? this.onboardingConcluido,
        imigrante: imigrante ?? this.imigrante,
        residenciaRenovaEm: residenciaRenovaEm ?? this.residenciaRenovaEm,
        banido: banido,
        criadoEm: criadoEm,
      );
}

DateTime? _data(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
double? _num(dynamic v) => v == null ? null : double.tryParse(v.toString());
