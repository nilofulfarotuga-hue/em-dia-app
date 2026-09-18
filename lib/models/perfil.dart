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
  final bool viuGuiaInicio;
  final bool imigrante;
  final DateTime? residenciaRenovaEm;
  final bool banido;
  final DateTime criadoEm;

  /// O que a pessoa já respondeu no onboarding antes de o acabar (coluna
  /// `onboarding_rascunho`, JSON com `passo` e as respostas). Lê-se aqui;
  /// escreve-se só pelo `PerfilStore.guardarRascunhoOnboarding` — nunca pelo
  /// `toUpdate`, para um guardar do perfil não apagar o rascunho.
  final Map<String, dynamic>? onboardingRascunho;

  /// O cofre guarda sozinho a fatia do imposto de cada rendimento (B2d).
  /// Ligado por omissão; a pessoa desliga no cofre.
  final bool cofreAutomatico;

  // B3 — «Trabalhas como?» e o que cada resposta traz consigo.
  final TipoTrabalho tipoTrabalho;
  final double? salarioBrutoMensal; // contrato
  final DateTime? dataNascimento; // IRS Jovem
  final String? empresaTipo; // 'eni' | 'sociedade'
  final String? ivaPeriodicidade; // 'mensal' | 'trimestral'
  final String? contabilistaEmail;
  final bool pastaContabilistaAtiva;

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
    this.viuGuiaInicio = false,
    this.imigrante = false,
    this.residenciaRenovaEm,
    this.banido = false,
    required this.criadoEm,
    this.onboardingRascunho,
    this.cofreAutomatico = true,
    this.tipoTrabalho = TipoTrabalho.independente,
    this.salarioBrutoMensal,
    this.dataNascimento,
    this.empresaTipo,
    this.ivaPeriodicidade,
    this.contabilistaEmail,
    this.pastaContabilistaAtiva = false,
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
        tipoTrabalho: tipoTrabalho,
        salarioBrutoMensal: salarioBrutoMensal,
        empresaTipo: empresaTipo,
        ivaPeriodicidade: ivaPeriodicidade,
      );

  bool get temContrato => tipoTrabalho == TipoTrabalho.contrato || tipoTrabalho == TipoTrabalho.ambos;
  bool get temEmpresa => tipoTrabalho == TipoTrabalho.empresa;
  bool get temRecibosVerdes => tipoTrabalho == TipoTrabalho.independente || tipoTrabalho == TipoTrabalho.ambos;

  /// Idade a 31 de dezembro de [ano] (para o IRS Jovem); null sem data de nascimento.
  int? idadeEm31Dez(int ano) {
    final n = dataNascimento;
    if (n == null) return null;
    return ano - n.year;
  }

  static TipoAtividade _tipo(String? s) => switch (s) {
        'tvde' => TipoAtividade.tvde,
        'estafeta' => TipoAtividade.estafeta,
        'servicos' => TipoAtividade.servicos,
        'obras' => TipoAtividade.obras,
        'outro' => TipoAtividade.outro,
        'freelancer' => TipoAtividade.freelancer,
        'so_carro' => TipoAtividade.soCarro,
        _ => TipoAtividade.semAtividade,
      };

  static String tipoParaDb(TipoAtividade t) => switch (t) {
        TipoAtividade.tvde => 'tvde',
        TipoAtividade.estafeta => 'estafeta',
        TipoAtividade.servicos => 'servicos',
        TipoAtividade.obras => 'obras',
        TipoAtividade.outro => 'outro',
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
        viuGuiaInicio: (m['viu_guia_inicio'] as bool?) ?? false,
        imigrante: (m['imigrante'] as bool?) ?? false,
        residenciaRenovaEm: _data(m['residencia_renova_em']),
        banido: (m['banido'] as bool?) ?? false,
        criadoEm: DateTime.parse(m['criado_em'] as String).toLocal(),
        onboardingRascunho: m['onboarding_rascunho'] is Map ? Map<String, dynamic>.from(m['onboarding_rascunho'] as Map) : null,
        cofreAutomatico: (m['cofre_automatico'] as bool?) ?? true,
        tipoTrabalho: tipoTrabalhoDe(m['tipo_trabalho'] as String?),
        salarioBrutoMensal: _num(m['salario_bruto_mensal']),
        dataNascimento: _data(m['data_nascimento']),
        empresaTipo: m['empresa_tipo'] as String?,
        ivaPeriodicidade: m['iva_periodicidade'] as String?,
        contabilistaEmail: m['contabilista_email'] as String?,
        pastaContabilistaAtiva: (m['pasta_contabilista_ativa'] as bool?) ?? false,
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
        'viu_guia_inicio': viuGuiaInicio,
        'imigrante': imigrante,
        'residencia_renova_em': residenciaRenovaEm == null ? null : dataPtIso(residenciaRenovaEm!),
        'cofre_automatico': cofreAutomatico,
        'tipo_trabalho': tipoTrabalho.name,
        'salario_bruto_mensal': salarioBrutoMensal,
        'data_nascimento': dataNascimento == null ? null : dataPtIso(dataNascimento!),
        'empresa_tipo': empresaTipo,
        'iva_periodicidade': ivaPeriodicidade,
        'contabilista_email': contabilistaEmail,
        'pasta_contabilista_ativa': pastaContabilistaAtiva,
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
    bool? viuGuiaInicio,
    bool? imigrante,
    DateTime? residenciaRenovaEm,
    Map<String, dynamic>? onboardingRascunho,
    bool limparRascunho = false,
    bool? cofreAutomatico,
    TipoTrabalho? tipoTrabalho,
    double? salarioBrutoMensal,
    DateTime? dataNascimento,
    String? empresaTipo,
    String? ivaPeriodicidade,
    String? contabilistaEmail,
    bool limparContabilista = false,
    bool? pastaContabilistaAtiva,
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
        viuGuiaInicio: viuGuiaInicio ?? this.viuGuiaInicio,
        imigrante: imigrante ?? this.imigrante,
        residenciaRenovaEm: residenciaRenovaEm ?? this.residenciaRenovaEm,
        banido: banido,
        criadoEm: criadoEm,
        onboardingRascunho: limparRascunho ? null : (onboardingRascunho ?? this.onboardingRascunho),
        cofreAutomatico: cofreAutomatico ?? this.cofreAutomatico,
        tipoTrabalho: tipoTrabalho ?? this.tipoTrabalho,
        salarioBrutoMensal: salarioBrutoMensal ?? this.salarioBrutoMensal,
        dataNascimento: dataNascimento ?? this.dataNascimento,
        empresaTipo: empresaTipo ?? this.empresaTipo,
        ivaPeriodicidade: ivaPeriodicidade ?? this.ivaPeriodicidade,
        contabilistaEmail: limparContabilista ? null : (contabilistaEmail ?? this.contabilistaEmail),
        pastaContabilistaAtiva: pastaContabilistaAtiva ?? this.pastaContabilistaAtiva,
      );
}

DateTime? _data(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
double? _num(dynamic v) => v == null ? null : double.tryParse(v.toString());
