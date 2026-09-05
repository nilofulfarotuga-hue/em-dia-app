import 'carro.dart';
import 'datas.dart';
import 'formatos.dart';
import 'irs.dart';
import 'regras_legais.dart';
import 'seguranca_social.dart';

/// Gerador do calendário de obrigações a partir do perfil (espelho em Dart do
/// que a Edge Function `calcular-obrigacoes` faz no servidor; os dois são
/// testados com os mesmos casos de `docs/casos-teste.md`).

enum TipoAtividade { tvde, estafeta, servicos, freelancer, semAtividade, soCarro }

enum RegimeIva { isento53, normal }

class PerfilObrigacoes {
  final TipoAtividade tipoAtividade;
  final DateTime? dataAbertura;
  final RegimeIva regimeIva;
  final TipoRendimento tipoRendimento;
  final double? rendimentoMensalEstimado;
  final int ajusteSsPct;
  final bool usaSoftwareFaturacao;
  final bool imigrante;
  final DateTime? residenciaRenovaEm;
  final DateTime? tvdeCertificadoValidade;

  const PerfilObrigacoes({
    required this.tipoAtividade,
    this.dataAbertura,
    this.regimeIva = RegimeIva.isento53,
    this.tipoRendimento = TipoRendimento.servicos,
    this.rendimentoMensalEstimado,
    this.ajusteSsPct = 0,
    this.usaSoftwareFaturacao = false,
    this.imigrante = false,
    this.residenciaRenovaEm,
    this.tvdeCertificadoValidade,
  });

  bool get temAtividade =>
      tipoAtividade != TipoAtividade.semAtividade &&
      tipoAtividade != TipoAtividade.soCarro &&
      dataAbertura != null;
}

class CarroObrigacoes {
  final String id;
  final String matricula;
  final DateTime dataMatricula; // se só se sabe mês/ano: último dia do mês
  final DateTime? seguroRenovaEm;
  final DateTime? ultimaIpo;
  final DateTime? cartaValidade;
  final bool usoTvde;
  final Combustivel combustivel;
  final int? cilindradaCc;
  final int? co2;

  const CarroObrigacoes({
    required this.id,
    required this.matricula,
    required this.dataMatricula,
    this.seguroRenovaEm,
    this.ultimaIpo,
    this.cartaValidade,
    this.usoTvde = false,
    this.combustivel = Combustivel.gasolina,
    this.cilindradaCc,
    this.co2,
  });
}

class Obrigacao {
  final String tipo;
  final String descricao;
  final DateTime dataLimite;
  final DateTime avisoEm;
  final double? valorEstimado;
  final String origemRegra;
  final String comoPagar;
  final String chaveUnica;
  final String? carroId;

  const Obrigacao({
    required this.tipo,
    required this.descricao,
    required this.dataLimite,
    required this.avisoEm,
    this.valorEstimado,
    required this.origemRegra,
    required this.comoPagar,
    required this.chaveUnica,
    this.carroId,
  });

  Map<String, dynamic> toMap(String userId) => {
        'user_id': userId,
        'carro_id': carroId,
        'tipo': tipo,
        'descricao': descricao,
        'data_limite': dataPtIso(dataLimite),
        'aviso_em': dataPtIso(avisoEm),
        'valor_estimado': valorEstimado,
        'origem_regra': origemRegra,
        'como_pagar': comoPagar,
        'chave_unica': chaveUnica,
      };
}

String dataPtIso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Gera todas as obrigações entre [desde] e [ate] (por omissão: 12 meses).
List<Obrigacao> gerarObrigacoes({
  required PerfilObrigacoes perfil,
  List<CarroObrigacoes> carros = const [],
  required DateTime hoje,
  DateTime? ate,
  required RegrasLegais r,
}) {
  final desde = soDia(hoje);
  final fim = ate ?? adicionarMeses(desde, 12);
  final out = <Obrigacao>[];
  final feriados = r.feriados;

  Obrigacao o({
    required String tipo,
    required String descricao,
    required DateTime prazo,
    double? valor,
    required String regra,
    required String comoPagar,
    String? carroId,
    String sufixo = '',
  }) =>
      Obrigacao(
        tipo: tipo,
        descricao: descricao,
        dataLimite: soDia(prazo),
        avisoEm: avisoEm(prazo, feriados),
        valorEstimado: valor,
        origemRegra: regra,
        comoPagar: comoPagar,
        chaveUnica: '$tipo|${dataPtIso(prazo)}${carroId != null ? '|$carroId' : ''}$sufixo',
        carroId: carroId,
      );

  bool dentro(DateTime d) => !d.isBefore(desde) && !d.isAfter(fim);

  // ---------------- Segurança Social ----------------
  if (perfil.temAtividade) {
    final abertura = perfil.dataAbertura!;
    final fimIsencao = fimIsencaoSS(abertura, r);
    final avisoDias = r.n('ss_aviso_fim_isencao_dias').toInt();
    final estim = perfil.rendimentoMensalEstimado == null
        ? null
        : estimarSSMensal(
            rendimentoMensal: perfil.rendimentoMensalEstimado!,
            tipo: perfil.tipoRendimento,
            ajustePct: perfil.ajusteSsPct,
            r: r);

    // Fim da isenção (aviso 30 dias antes com o valor que vai passar a pagar)
    // O aviso sai 30 dias antes (véspera útil), com o valor que vai passar a pagar.
    final avisoFim = fimIsencao.subtract(Duration(days: avisoDias));
    if (dentro(fimIsencao)) {
      out.add(Obrigacao(
        tipo: 'fim_isencao_ss',
        descricao:
            'Acaba a isenção de Segurança Social. A partir de ${nomeMes(fimIsencao.month)} pagas cerca de ${estim == null ? '—' : moeda(estim.contribuicaoMensal)}/mês.',
        dataLimite: fimIsencao,
        avisoEm: avisoEm(avisoFim.isBefore(desde) ? fimIsencao : avisoFim, feriados),
        valorEstimado: estim?.contribuicaoMensal,
        origemRegra: 'ss_isencao_meses',
        comoPagar: 'Nada a pagar neste dia — é só para saberes. O primeiro pagamento é entre o dia 10 e 20 do mês seguinte, na Segurança Social Direta.',
        chaveUnica: 'fim_isencao_ss|${dataPtIso(fimIsencao)}',
      ));
    }

    // Declarações trimestrais (último dia de jan/abr/jul/out) e pagamentos (dia 20)
    final mesesDecl = (r.json('ss_declaracao_meses') as List).cast<num>().map((e) => e.toInt()).toList()..sort();
    final primeiraDecl = primeiraDeclaracaoTrimestral(abertura, r);
    var cursor = DateTime(desde.year, desde.month, 1);
    while (!cursor.isAfter(fim)) {
      // declaração
      if (mesesDecl.contains(cursor.month) && !cursor.isBefore(primeiraDecl)) {
        final prazo = prazoDeclaracaoTrimestral(cursor.year, cursor.month);
        if (dentro(prazo)) {
          out.add(o(
            tipo: 'ss_declaracao',
            descricao: 'Declaração trimestral à Segurança Social: o que ganhaste nos últimos 3 meses.',
            prazo: prazo,
            regra: 'ss_declaracao_meses',
            comoPagar: 'Segurança Social Direta → Emprego → Trabalhadores Independentes → Regime de rendimentos → Declaração trimestral. Não se paga nada aqui: só se declara.',
          ));
        }
      }
      // pagamento mensal (a partir do mês em que acaba a isenção)
      if (!cursor.isBefore(fimIsencao)) {
        final prazo = prazoPagamentoSS(cursor.year, cursor.month, r);
        if (dentro(prazo)) {
          out.add(o(
            tipo: 'ss_pagamento',
            descricao: 'Contribuição de ${nomeMes(cursor.month)} para a Segurança Social.',
            prazo: prazo,
            valor: estim?.contribuicaoMensal,
            regra: 'ss_pagamento_dia_fim',
            comoPagar: 'Segurança Social Direta → Conta-corrente → Pagamentos → gera a referência Multibanco e paga na app do banco. Entre o dia 10 e o dia 20.',
          ));
        }
      }
      cursor = adicionarMeses(cursor, 1);
    }

    // ---------------- IVA (regime normal, trimestral) ----------------
    if (perfil.regimeIva == RegimeIva.normal) {
      final diaDecl = r.n('iva_declaracao_trimestral_dia').toInt();
      final diaPag = r.n('iva_pagamento_dia').toInt();
      // trimestres: T1 (jan–mar) → maio; T2 → agosto; T3 → novembro; T4 → fevereiro
      for (var ano = desde.year - 1; ano <= fim.year; ano++) {
        for (final t in [1, 2, 3, 4]) {
          final mesDecl = t * 3 + 2; // 5, 8, 11, 14→2 do ano seguinte
          final anoDecl = mesDecl > 12 ? ano + 1 : ano;
          final m = mesDecl > 12 ? mesDecl - 12 : mesDecl;
          final decl = DateTime(anoDecl, m, diaDecl);
          final pag = DateTime(anoDecl, m, diaPag);
          if (dentro(decl)) {
            out.add(o(
              tipo: 'iva_declaracao',
              descricao: 'Declaração de IVA do $t.º trimestre de $ano.',
              prazo: decl,
              regra: 'iva_declaracao_trimestral_dia',
              comoPagar: 'Portal das Finanças → IVA → Entregar declaração periódica (ou o contabilista faz).',
            ));
          }
          if (dentro(pag)) {
            out.add(o(
              tipo: 'iva_pagamento',
              descricao: 'Pagar o IVA do $t.º trimestre de $ano.',
              prazo: pag,
              regra: 'iva_pagamento_dia',
              comoPagar: 'Depois de entregar a declaração, o Portal das Finanças dá a referência de pagamento. Paga na app do banco.',
            ));
          }
        }
      }
    }

    // ---------------- IRS ----------------
    for (var ano = desde.year; ano <= fim.year; ano++) {
      final entrega = prazoEntregaIrs(ano, r);
      if (dentro(entrega)) {
        out.add(o(
          tipo: 'irs_entrega',
          descricao: 'Entregar a declaração de IRS do ano ${ano - 1} (anexo B).',
          prazo: entrega,
          regra: 'irs_entrega_fim',
          comoPagar: 'Portal das Finanças → IRS → Entregar declaração. Começa a 1 de abril. Se tiveres dúvidas, um contabilista faz por pouco dinheiro.',
        ));
      }
      final efatura = prazoValidarEfatura(ano, r);
      if (dentro(efatura)) {
        out.add(o(
          tipo: 'efatura_validar',
          descricao: 'Validar as faturas no e-fatura (as despesas com NIF de ${ano - 1}).',
          prazo: efatura,
          regra: 'efatura_validar_ate',
          comoPagar: 'faturas.portaldasfinancas.gov.pt → Faturas → Consumidor → valida as que estão pendentes.',
        ));
      }
      // pagamentos por conta (só faz sentido com estimativa de imposto)
      if (perfil.rendimentoMensalEstimado != null) {
        final prov = calcularIrs(
            rendimentoBrutoAnual: perfil.rendimentoMensalEstimado! * 12,
            tipo: perfil.tipoRendimento,
            ano: ano,
            r: r);
        if (prov.pagamentoPorContaCada > 0) {
          for (final d in datasPagamentosPorConta(ano, r)) {
            if (dentro(d)) {
              out.add(o(
                tipo: 'irs_pagamento_conta',
                descricao: 'Pagamento por conta de IRS (${nomeMes(d.month)}).',
                prazo: d,
                valor: prov.pagamentoPorContaCada,
                regra: 'irs_pagamentos_conta_pct',
                comoPagar: 'Portal das Finanças → Situação fiscal → Pagamentos → referência Multibanco. Só se aplica se tiveste IRS a pagar no ano anterior.',
              ));
            }
          }
        }
      }
    }

    // ---------------- Comunicar recibos (só com software de faturação) ----------------
    if (perfil.usaSoftwareFaturacao) {
      var c = DateTime(desde.year, desde.month, 1);
      while (!c.isAfter(fim)) {
        final prazo = DateTime(c.year, c.month, r.n('recibos_comunicar_dia').toInt());
        if (dentro(prazo)) {
          out.add(o(
            tipo: 'recibos_comunicar',
            descricao: 'Comunicar às Finanças as faturas de ${nomeMes(adicionarMeses(c, -1).month)}.',
            prazo: prazo,
            regra: 'recibos_comunicar_dia',
            comoPagar: 'O teu programa de faturação envia o ficheiro SAF-T. Se passas recibos no Portal das Finanças, isto não se aplica a ti.',
          ));
        }
        c = adicionarMeses(c, 1);
      }
    }
  }

  // ---------------- TVDE ----------------
  if (perfil.tipoAtividade == TipoAtividade.tvde && perfil.tvdeCertificadoValidade != null) {
    final v = perfil.tvdeCertificadoValidade!;
    if (dentro(v)) {
      out.add(o(
        tipo: 'tvde_certificado',
        descricao: 'Renovar o certificado de motorista TVDE (vale 5 anos).',
        prazo: v,
        regra: 'tvde_certificado_validade_anos',
        comoPagar: 'IMT online → Motorista TVDE → renovação. Trata com 2 meses de antecedência.',
      ));
    }
  }

  // ---------------- Imigrante ----------------
  if (perfil.imigrante && perfil.residenciaRenovaEm != null && dentro(perfil.residenciaRenovaEm!)) {
    out.add(o(
      tipo: 'residencia',
      descricao: 'Renovar a autorização de residência.',
      prazo: perfil.residenciaRenovaEm!,
      regra: 'troca_carta_estrangeira_prazo_anos',
      comoPagar: 'Portal da AIMA → renovação automática ou marcação. Começa 90 dias antes.',
    ));
  }

  // ---------------- Carro ----------------
  for (final c in carros) {
    // IUC — todos os anos no mês da matrícula
    for (var ano = desde.year; ano <= fim.year; ano++) {
      final prazo = prazoIuc(mesMatricula: c.dataMatricula.month, ano: ano);
      if (dentro(prazo)) {
        final est = estimarIuc(
            matricula: c.dataMatricula,
            combustivel: c.combustivel,
            cilindradaCc: c.cilindradaCc,
            co2: c.co2,
            r: r);
        out.add(o(
          tipo: 'iuc',
          descricao: 'IUC (imposto do carro) do ${c.matricula}.',
          prazo: prazo,
          valor: est?.valor,
          regra: 'iuc_regra',
          comoPagar: 'Portal das Finanças → IUC → Pagar → escolhe a matrícula → referência Multibanco. Até ao fim do mês da matrícula.',
          carroId: c.id,
        ));
      }
    }
    // IPO
    final ipo = proximaIpo(
        matricula: c.dataMatricula, ultimaIpo: c.ultimaIpo, hoje: desde, tvde: c.usoTvde, r: r);
    if (ipo != null && dentro(ipo)) {
      out.add(o(
        tipo: 'ipo',
        descricao: 'Inspeção periódica do ${c.matricula}.',
        prazo: ipo,
        regra: c.usoTvde ? 'ipo_tvde' : 'ipo_ligeiros_anos',
        comoPagar: 'Marca num centro de inspeção perto de ti (a app mostra os mais próximos). Leva o DUA e o seguro. Custa cerca de 30–40 €.',
        carroId: c.id,
      ));
    }
    // Seguro
    if (c.seguroRenovaEm != null) {
      var s = c.seguroRenovaEm!;
      while (s.isBefore(desde)) {
        s = adicionarAnos(s, 1);
      }
      if (dentro(s)) {
        out.add(o(
          tipo: 'seguro',
          descricao: 'Renova o seguro do ${c.matricula}. 45 dias antes é a altura de comparar preços.',
          prazo: s,
          regra: 'seguro_aviso_dias',
          comoPagar: 'Pede 2 ou 3 simulações antes de renovar. Se mudares de seguradora, avisa a antiga por escrito 30 dias antes.',
          carroId: c.id,
        ));
      }
    }
    // Carta
    if (c.cartaValidade != null && dentro(c.cartaValidade!)) {
      out.add(o(
        tipo: 'carta',
        descricao: 'Renovar a carta de condução.',
        prazo: c.cartaValidade!,
        regra: 'carta_validade',
        comoPagar: 'IMT online ou Espaço Cidadão. Precisas de atestado médico (o médico de família passa).',
        carroId: c.id,
      ));
    }
  }

  out.sort((a, b) => a.dataLimite.compareTo(b.dataLimite));
  return out;
}
