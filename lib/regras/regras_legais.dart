/// A tabela de regras legais, em memória.
///
/// A ÚNICA fonte de números legais da app. Vem da tabela `regras_legais` do
/// Supabase; [RegrasLegais.padrao2026] é o espelho do seed
/// (`supabase/migrations/20260905_0003_seed.sql`) para testes e para a app
/// arrancar sem rede. Se um valor mudar, muda-se na tabela — nunca aqui.
class RegraLegal {
  final String chave;
  final num? valorNum;
  final String? valorTxt;
  final dynamic valorJson;
  final String? unidade;
  final int ano;
  final String descricao;
  final String? fonteUrl;
  final String confianca; // oficial | aproximado | por_confirmar
  final DateTime? verificadoEm;

  const RegraLegal({
    required this.chave,
    this.valorNum,
    this.valorTxt,
    this.valorJson,
    this.unidade,
    this.ano = 2026,
    required this.descricao,
    this.fonteUrl,
    this.confianca = 'oficial',
    this.verificadoEm,
  });

  bool get confirmada => confianca != 'por_confirmar';

  factory RegraLegal.fromMap(Map<String, dynamic> m) => RegraLegal(
        chave: m['chave'] as String,
        valorNum: m['valor_num'] == null
            ? null
            : num.tryParse(m['valor_num'].toString()),
        valorTxt: m['valor_txt'] as String?,
        valorJson: m['valor_json'],
        unidade: m['unidade'] as String?,
        ano: (m['ano'] as num?)?.toInt() ?? 2026,
        descricao: (m['descricao'] as String?) ?? '',
        fonteUrl: m['fonte_url'] as String?,
        confianca: (m['confianca'] as String?) ?? 'oficial',
        verificadoEm: m['verificado_em'] == null
            ? null
            : DateTime.tryParse(m['verificado_em'].toString()),
      );
}

class EscalaoIrs {
  final int ano;
  final int ordem;
  final double? ate; // null = sem limite
  final double taxa; // 0.125 = 12,5%
  final double parcelaAbater;
  final String confianca;

  const EscalaoIrs({
    required this.ano,
    required this.ordem,
    required this.ate,
    required this.taxa,
    required this.parcelaAbater,
    this.confianca = 'oficial',
  });

  factory EscalaoIrs.fromMap(Map<String, dynamic> m) => EscalaoIrs(
        ano: (m['ano'] as num).toInt(),
        ordem: (m['ordem'] as num).toInt(),
        ate: m['ate'] == null ? null : double.parse(m['ate'].toString()),
        taxa: double.parse(m['taxa'].toString()),
        parcelaAbater: double.parse(m['parcela_abater'].toString()),
        confianca: (m['confianca'] as String?) ?? 'oficial',
      );
}

class RegrasLegais {
  final Map<String, RegraLegal> _regras;
  final List<EscalaoIrs> escaloes;
  final Set<DateTime> feriados; // datas (só ano-mês-dia)

  RegrasLegais({
    required Iterable<RegraLegal> regras,
    required this.escaloes,
    required Iterable<DateTime> feriados,
  })  : _regras = {for (final r in regras) r.chave: r},
        feriados = {
          for (final f in feriados) DateTime(f.year, f.month, f.day),
        };

  RegraLegal? regra(String chave) => _regras[chave];
  bool tem(String chave) => _regras.containsKey(chave);

  /// Número da regra. Lança se não existir — um número legal em falta é um
  /// erro de dados, nunca se inventa um valor por omissão.
  double n(String chave) {
    final r = _regras[chave];
    if (r == null || r.valorNum == null) {
      throw StateError('Regra legal em falta ou sem número: $chave');
    }
    return r.valorNum!.toDouble();
  }

  String txt(String chave) {
    final r = _regras[chave];
    if (r == null || r.valorTxt == null) {
      throw StateError('Regra legal em falta ou sem texto: $chave');
    }
    return r.valorTxt!;
  }

  dynamic json(String chave) {
    final r = _regras[chave];
    if (r == null || r.valorJson == null) {
      throw StateError('Regra legal em falta ou sem JSON: $chave');
    }
    return r.valorJson;
  }

  List<EscalaoIrs> escaloesDoAno(int ano) {
    final doAno = escaloes.where((e) => e.ano == ano).toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
    if (doAno.isNotEmpty) return doAno;
    // Sem tabela para o ano pedido: usa o ano mais recente que exista.
    final anos = escaloes.map((e) => e.ano).toSet().toList()..sort();
    if (anos.isEmpty) return const [];
    return escaloesDoAno(anos.last);
  }

  /// Espelho do seed 0003 (2026). Testes e arranque offline.
  factory RegrasLegais.padrao2026() {
    RegraLegal r(String chave, num valor, String desc,
            {String unidade = 'eur', String confianca = 'oficial'}) =>
        RegraLegal(
            chave: chave,
            valorNum: valor,
            unidade: unidade,
            descricao: desc,
            confianca: confianca);
    RegraLegal t(String chave, String valor, String desc,
            {String confianca = 'oficial'}) =>
        RegraLegal(
            chave: chave, valorTxt: valor, descricao: desc, confianca: confianca);
    RegraLegal j(String chave, dynamic valor, String desc,
            {String confianca = 'oficial'}) =>
        RegraLegal(
            chave: chave, valorJson: valor, descricao: desc, confianca: confianca);

    final regras = <RegraLegal>[
      r('ias', 537.13, 'IAS 2026'),
      r('iva_taxa_normal', 23, 'Taxa normal de IVA', unidade: 'pct'),
      r('iva_isencao_limite', 15000, 'Isenção art. 53.º'),
      r('iva_isencao_aviso', 12000, 'Aviso amarelo'),
      r('iva_isencao_perda_imediata', 18750, 'Perda imediata (+25%)'),
      r('iva_isencao_comunicacao_dias_uteis', 15, 'Comunicar às Finanças',
          unidade: 'dias_uteis'),
      t('iva_mencao_isencao', 'IVA - regime de isenção [artigo 53.º do CIVA] (M10)',
          'Menção no recibo'),
      r('iva_declaracao_trimestral_dia', 20, 'Declaração IVA', unidade: 'dia_do_mes'),
      r('iva_pagamento_dia', 25, 'Pagamento IVA', unidade: 'dia_do_mes'),
      r('retencao_padrao', 23, 'Retenção padrão', unidade: 'pct'),
      r('retencao_opcao', 25, 'Retenção por opção', unidade: 'pct'),
      r('retencao_dispensa_limite', 15000, 'Dispensa de retenção'),
      r('ss_taxa', 21.4, 'Taxa SS', unidade: 'pct'),
      r('ss_base_servicos', 70, 'Base serviços', unidade: 'pct'),
      r('ss_base_vendas', 20, 'Base vendas', unidade: 'pct'),
      r('ss_ajuste_max', 25, 'Ajuste máximo', unidade: 'pct'),
      r('ss_minimo_mensal', 20, 'Mínimo mensal'),
      r('ss_base_maxima_ias', 12, 'Base máxima ×IAS', unidade: 'multiplo_ias'),
      r('ss_isencao_meses', 12, 'Isenção 1.º ano', unidade: 'meses'),
      j('ss_declaracao_meses', [1, 4, 7, 10], 'Meses da declaração'),
      r('ss_pagamento_dia_inicio', 10, 'Pagamento SS do dia', unidade: 'dia_do_mes'),
      r('ss_pagamento_dia_fim', 20, 'Pagamento SS até ao dia', unidade: 'dia_do_mes'),
      r('ss_aviso_fim_isencao_dias', 30, 'Aviso fim isenção', unidade: 'dias'),
      r('irs_coef_servicos', 0.75, 'Coeficiente serviços', unidade: 'coeficiente'),
      r('irs_coef_vendas', 0.15, 'Coeficiente vendas', unidade: 'coeficiente'),
      r('irs_minimo_existencia', 12880, 'Mínimo de existência'),
      r('irs_pagamentos_conta_pct', 65, 'Pagamentos por conta', unidade: 'pct'),
      j('irs_pagamentos_conta_datas', ['07-20', '09-20', '12-20'], 'Datas PPC'),
      t('irs_entrega_inicio', '04-01', 'Entrega IRS início'),
      t('irs_entrega_fim', '06-30', 'Entrega IRS fim'),
      t('efatura_validar_ate', '02-25', 'Validar e-fatura'),
      r('irs_despesas_justificar_limite', 27360, 'Justificar despesas acima de',
          confianca: 'aproximado'),
      r('irs_despesas_justificar_pct', 15, 'Percentagem a justificar', unidade: 'pct'),
      r('recibos_comunicar_dia', 5, 'Comunicar faturas', unidade: 'dia_do_mes'),
      r('reforma_idade', 66.75, 'Idade da reforma', unidade: 'anos'),
      r('reforma_carreira_minima_anos', 15, 'Carreira mínima', unidade: 'anos'),
      r('baixa_doenca_dia_inicio', 11, 'Baixa a partir do dia', unidade: 'dia'),
      r('baixa_doenca_prazo_garantia_meses', 6, 'Prazo de garantia baixa', unidade: 'meses'),
      r('cessacao_atividade_prazo_garantia_dias', 360, 'Prazo de garantia cessação',
          unidade: 'dias'),
      t('acordo_pt_br_url', 'https://www.seg-social.pt/acordos-internacionais',
          'Acordo de Segurança Social Portugal–Brasil'),
      t('iuc_regra', 'mes_da_matricula', 'IUC no mês da matrícula'),
      j('iuc_tabela', _iucTabela2026, 'Tabela IUC aproximada', confianca: 'aproximado'),
      j('ipo_ligeiros_anos', [4, 6, 8], 'IPO aos 4/6/8 anos'),
      t('ipo_apos_8_anos', 'anual', 'IPO anual depois dos 8'),
      t('ipo_tvde', 'anual', 'IPO TVDE anual', confianca: 'por_confirmar'),
      j('ipo_avisos_dias', [30, 7], 'Avisos IPO'),
      r('seguro_aviso_dias', 45, 'Aviso seguro', unidade: 'dias'),
      // Espelho da migracao 0016. Faltava aqui, e por isso o radar da
      // fidelizacao ficava sem numero nas fotos e sem rede.
      r('aviso_fidelizacao_dias', 30, 'Aviso fim da fidelizacao',
          unidade: 'dias', confianca: 'aproximado'),
      // Aviso das contas de casa, por meio de pagamento (migracao 0016).
      r('aviso_debito_direto_dias', 1, 'Aviso debito direto',
          unidade: 'dias', confianca: 'aproximado'),
      r('aviso_referencia_dias', 3, 'Aviso referencia Multibanco',
          unidade: 'dias', confianca: 'aproximado'),
      j('carta_validade', {'ate_60': 15, '60_a_70': 5, 'mais_70': 2}, 'Validade da carta'),
      r('multa_pagamento_voluntario_dias_uteis', 15, 'Multas: pagamento voluntário',
          unidade: 'dias_uteis'),
      r('troca_carta_estrangeira_prazo_anos', 2, 'Troca de carta estrangeira',
          unidade: 'anos', confianca: 'por_confirmar'),
      r('tvde_certificado_validade_anos', 5, 'Certificado TVDE', unidade: 'anos'),
      r('trial_dias', 30, 'Trial', unidade: 'dias'),
      r('trial_aviso_dia', 25, 'Aviso trial', unidade: 'dia'),
      r('preco_pro_mensal', 3.49, 'Pro mensal'),
      r('preco_pro_anual', 29.90, 'Pro anual'),
      r('preco_familia_mensal', 5.99, 'Família mensal'),
      r('preco_familia_anual', 49.90, 'Família anual'),
      r('ia_custo_alarme_dia_eur', 0.50, 'Alarme custo IA'),
      r('push_hora_lisboa', 9, 'Hora dos avisos', unidade: 'hora'),
    ];

    const escaloes = <EscalaoIrs>[
      EscalaoIrs(ano: 2025, ordem: 1, ate: 8059, taxa: 0.125, parcelaAbater: 0),
      EscalaoIrs(ano: 2025, ordem: 2, ate: 12160, taxa: 0.16, parcelaAbater: 282.07),
      EscalaoIrs(ano: 2025, ordem: 3, ate: 17233, taxa: 0.215, parcelaAbater: 950.87),
      EscalaoIrs(ano: 2025, ordem: 4, ate: 22306, taxa: 0.244, parcelaAbater: 1450.63),
      EscalaoIrs(ano: 2025, ordem: 5, ate: 28400, taxa: 0.314, parcelaAbater: 3012.05),
      EscalaoIrs(ano: 2025, ordem: 6, ate: 41629, taxa: 0.349, parcelaAbater: 4006.05),
      EscalaoIrs(ano: 2025, ordem: 7, ate: 44987, taxa: 0.431, parcelaAbater: 7419.63),
      EscalaoIrs(ano: 2025, ordem: 8, ate: 83696, taxa: 0.446, parcelaAbater: 8094.44),
      EscalaoIrs(ano: 2025, ordem: 9, ate: null, taxa: 0.48, parcelaAbater: 10940.10),
      EscalaoIrs(ano: 2026, ordem: 1, ate: 8342, taxa: 0.125, parcelaAbater: 0, confianca: 'por_confirmar'),
      EscalaoIrs(ano: 2026, ordem: 2, ate: 12588, taxa: 0.157, parcelaAbater: 266.94, confianca: 'por_confirmar'),
      EscalaoIrs(ano: 2026, ordem: 3, ate: 17838, taxa: 0.212, parcelaAbater: 959.28, confianca: 'por_confirmar'),
      EscalaoIrs(ano: 2026, ordem: 4, ate: 23088, taxa: 0.241, parcelaAbater: 1476.58, confianca: 'por_confirmar'),
      EscalaoIrs(ano: 2026, ordem: 5, ate: 29397, taxa: 0.311, parcelaAbater: 3092.74, confianca: 'por_confirmar'),
      EscalaoIrs(ano: 2026, ordem: 6, ate: 43090, taxa: 0.349, parcelaAbater: 4209.83, confianca: 'por_confirmar'),
      EscalaoIrs(ano: 2026, ordem: 7, ate: 46567, taxa: 0.431, parcelaAbater: 7743.21, confianca: 'por_confirmar'),
      EscalaoIrs(ano: 2026, ordem: 8, ate: 86634, taxa: 0.446, parcelaAbater: 8441.72, confianca: 'por_confirmar'),
      EscalaoIrs(ano: 2026, ordem: 9, ate: null, taxa: 0.48, parcelaAbater: 11387.28, confianca: 'por_confirmar'),
    ];

    final feriados = <DateTime>[
      DateTime(2026, 1, 1), DateTime(2026, 4, 3), DateTime(2026, 4, 5), DateTime(2026, 4, 25),
      DateTime(2026, 5, 1), DateTime(2026, 6, 4), DateTime(2026, 6, 10), DateTime(2026, 8, 15),
      DateTime(2026, 10, 5), DateTime(2026, 11, 1), DateTime(2026, 12, 1), DateTime(2026, 12, 8),
      DateTime(2026, 12, 25),
      DateTime(2027, 1, 1), DateTime(2027, 3, 26), DateTime(2027, 3, 28), DateTime(2027, 4, 25),
      DateTime(2027, 5, 1), DateTime(2027, 5, 27), DateTime(2027, 6, 10), DateTime(2027, 8, 15),
      DateTime(2027, 10, 5), DateTime(2027, 11, 1), DateTime(2027, 12, 1), DateTime(2027, 12, 8),
      DateTime(2027, 12, 25),
    ];

    return RegrasLegais(regras: regras, escaloes: escaloes, feriados: feriados);
  }
}

const Map<String, dynamic> _iucTabela2026 = {
  'cat_b_cilindrada': [
    {'ate': 1250, 'valor': 32.36},
    {'ate': 1750, 'valor': 64.92},
    {'ate': 2500, 'valor': 129.77},
    {'ate': 99999, 'valor': 444.51},
  ],
  'cat_b_co2_nedc': [
    {'ate': 120, 'valor': 64.58},
    {'ate': 180, 'valor': 96.77},
    {'ate': 250, 'valor': 210.17},
    {'ate': 9999, 'valor': 360.09},
  ],
  'cat_b_co2_wltp': [
    {'ate': 140, 'valor': 64.58},
    {'ate': 205, 'valor': 96.77},
    {'ate': 260, 'valor': 210.17},
    {'ate': 9999, 'valor': 360.09},
  ],
  'cat_b_coef_ano': [
    {'ano': 2007, 'coef': 1.0},
    {'ano': 2008, 'coef': 1.05},
    {'ano': 2009, 'coef': 1.1},
    {'ano': 2010, 'coef': 1.15},
  ],
  'cat_a_gasolina': [
    {'ate': 1000, 'valor': 19.20},
    {'ate': 1300, 'valor': 30.60},
    {'ate': 1750, 'valor': 47.20},
    {'ate': 2600, 'valor': 118.90},
    {'ate': 3500, 'valor': 193.20},
    {'ate': 99999, 'valor': 344.10},
  ],
  'cat_a_gasoleo': [
    {'ate': 1500, 'valor': 30.60},
    {'ate': 2000, 'valor': 47.20},
    {'ate': 3000, 'valor': 118.90},
    {'ate': 99999, 'valor': 193.20},
  ],
  'eletrico': 0,
};
