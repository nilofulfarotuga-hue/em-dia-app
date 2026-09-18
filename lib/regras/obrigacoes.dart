import 'carro.dart';
import 'datas.dart';
import 'formatos.dart';
import 'irs.dart';
import 'regras_legais.dart';
import 'seguranca_social.dart';

/// Gerador do calendário de obrigações a partir do perfil (espelho em Dart do
/// que a Edge Function `calcular-obrigacoes` faz no servidor; os dois são
/// testados com os mesmos casos de `docs/casos-teste.md`).

/// O ofício de quem usa a app. Decide os exemplos, os textos e a descrição
/// do serviço no recibo. `obras` e `outro` entraram a 2026-09-06, com a tela
/// de recibos a deixar de ser só de motorista.
enum TipoAtividade { tvde, estafeta, servicos, obras, freelancer, outro, semAtividade, soCarro }

enum RegimeIva { isento53, normal }

/// «Trabalhas como?» — a primeira pergunta do onboarding (B3, 2026-09-18).
/// `independente` = recibos verdes; `contrato` = trabalho por conta de outrem;
/// `ambos` = os dois; `empresa` = tem uma empresa (ENI ou sociedade).
enum TipoTrabalho { independente, contrato, ambos, empresa }

TipoTrabalho tipoTrabalhoDe(String? s) => switch (s) {
      'contrato' => TipoTrabalho.contrato,
      'ambos' => TipoTrabalho.ambos,
      'empresa' => TipoTrabalho.empresa,
      _ => TipoTrabalho.independente,
    };

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

  // B3 — três perfis. `salarioBrutoMensal` só faz sentido com contrato;
  // `empresaTipo` ('eni' | 'sociedade') e `ivaPeriodicidade` ('mensal' |
  // 'trimestral') só com empresa.
  final TipoTrabalho tipoTrabalho;
  final double? salarioBrutoMensal;
  final String? empresaTipo;
  final String? ivaPeriodicidade;

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
    this.tipoTrabalho = TipoTrabalho.independente,
    this.salarioBrutoMensal,
    this.empresaTipo,
    this.ivaPeriodicidade,
  });

  /// Recibos verdes a sério: com atividade aberta (não conta «só carro» nem
  /// «sem atividade», nem quem só tem contrato ou empresa).
  bool get temAtividade =>
      (tipoTrabalho == TipoTrabalho.independente || tipoTrabalho == TipoTrabalho.ambos) &&
      tipoAtividade != TipoAtividade.semAtividade &&
      tipoAtividade != TipoAtividade.soCarro &&
      dataAbertura != null;

  bool get temContrato => tipoTrabalho == TipoTrabalho.contrato || tipoTrabalho == TipoTrabalho.ambos;
  bool get temEmpresa => tipoTrabalho == TipoTrabalho.empresa;
  bool get ehSociedade => temEmpresa && empresaTipo == 'sociedade';

  /// Quem entrega IRS todos os anos: qualquer um destes três.
  bool get entregaIrs => temAtividade || temContrato || temEmpresa;
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

/// Tipos cujo prazo é do Estado (Finanças ou Segurança Social): se o dia legal
/// cai a fim-de-semana ou feriado, cumpre-se no dia útil seguinte (ver
/// [prazoEfetivo]). Os outros (seguro, inspeção, carta, residência) ficam com
/// a data tal como está — a seguradora e o centro de inspeção não esperam.
const Set<String> tiposComPrazoDoEstado = {
  'ss_declaracao', 'ss_pagamento', 'iva_declaracao', 'iva_pagamento', 'irs_entrega',
  'irs_pagamento_conta', 'efatura_validar', 'recibos_comunicar', 'iuc',
  'dmr', 'saft', 'irc_modelo22', 'irc_pagamento_conta', 'ies', 'ss_empresa',
};

/// Lembretes: aparecem na agenda e na lista, mas nunca são «o que fazer
/// agora» no painel nem contam para o semáforo — não é dinheiro a sair nem
/// prazo que se falhe (o subsídio de Natal é para RECEBER; as faturas com
/// NIF são um hábito).
const Set<String> tiposLembrete = {'subsidio_natal', 'faturas_nif'};

class Obrigacao {
  final String tipo;
  final String descricao;

  /// O dia legal (o que a lei ou o Estado escrevem: «até dia 20»).
  final DateTime dataLimite;

  /// Até quando se pode mesmo cumprir: igual a [dataLimite], ou o dia útil
  /// seguinte quando o dia legal cai a sábado, domingo ou feriado e o prazo é
  /// do Estado. É por ESTE que se conta «passou» e «faltam N dias».
  final DateTime prazoEfetivo;
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
    required this.prazoEfetivo,
    required this.avisoEm,
    this.valorEstimado,
    required this.origemRegra,
    required this.comoPagar,
    required this.chaveUnica,
    this.carroId,
  });

  /// O dia legal caiu a fim-de-semana/feriado e passou para o dia útil seguinte.
  bool get prazoMudou => prazoEfetivo != dataLimite;

  Map<String, dynamic> toMap(String userId) => {
        'user_id': userId,
        'carro_id': carroId,
        'tipo': tipo,
        'descricao': descricao,
        'data_limite': dataPtIso(dataLimite),
        'prazo_efetivo': dataPtIso(prazoEfetivo),
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
        prazoEfetivo: tiposComPrazoDoEstado.contains(tipo) ? prazoEfetivo(prazo, feriados) : soDia(prazo),
        avisoEm: avisoEm(prazo, feriados),
        valorEstimado: valor,
        origemRegra: regra,
        comoPagar: comoPagar,
        chaveUnica: '$tipo|${dataPtIso(prazo)}${carroId != null ? '|$carroId' : ''}$sufixo',
        carroId: carroId,
      );

  bool dentro(DateTime d) => !d.isBefore(desde) && !d.isAfter(fim);

  // ---------------- IVA (helpers partilhados pelo independente e pela empresa) ----------------
  // Trimestral: T1 (jan–mar) → maio; T2 → SETEMBRO; T3 → novembro; T4 → fevereiro.
  // O T2 não é agosto: o CIVA, art. 41.º n.º 10 (redação do DL 49/2025), manda
  // entregar a declaração do 2.º trimestre «até 20 de setembro», e a AT põe o
  // pagamento a 25 de setembro (quadro de pagamentos 2026). Regra
  // `iva_trimestre2_mes` na tabela.
  void ivaTrimestral() {
    final diaDecl = r.n('iva_declaracao_trimestral_dia').toInt();
    final diaPag = r.n('iva_pagamento_dia').toInt();
    final mesT2 = r.n('iva_trimestre2_mes').toInt();
    for (var ano = desde.year - 1; ano <= fim.year; ano++) {
      for (final t in [1, 2, 3, 4]) {
        final mesDecl = t == 2 ? mesT2 : t * 3 + 2; // 5, 9, 11, 14→2 do ano seguinte
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

  // Mensal (empresas acima do limiar): a declaração do mês M entrega-se até ao
  // dia 20 do 2.º mês seguinte e paga-se até ao dia 25 (CIVA art. 41.º n.º 1 a)
  // e 27.º; quadro da AT 2026: «regime mensal» dia 20 de todos os meses).
  void ivaMensal() {
    final diaDecl = r.n('iva_mensal_declaracao_dia').toInt();
    final diaPag = r.n('iva_pagamento_dia').toInt();
    var mesRef = adicionarMeses(DateTime(desde.year, desde.month, 1), -3);
    while (!mesRef.isAfter(fim)) {
      final alvo = adicionarMeses(mesRef, 2);
      final decl = DateTime(alvo.year, alvo.month, diaDecl);
      final pag = DateTime(alvo.year, alvo.month, diaPag);
      if (dentro(decl)) {
        out.add(o(
          tipo: 'iva_declaracao',
          descricao: 'Declaração de IVA de ${nomeMes(mesRef.month)} de ${mesRef.year} (regime mensal).',
          prazo: decl,
          regra: 'iva_mensal_declaracao_dia',
          comoPagar: 'Portal das Finanças → IVA → Entregar declaração periódica (normalmente é o contabilista que entrega).',
        ));
      }
      if (dentro(pag)) {
        out.add(o(
          tipo: 'iva_pagamento',
          descricao: 'Pagar o IVA de ${nomeMes(mesRef.month)} de ${mesRef.year}.',
          prazo: pag,
          regra: 'iva_pagamento_dia',
          comoPagar: 'Depois da declaração, o Portal das Finanças dá a referência. Paga na app do banco.',
        ));
      }
      mesRef = adicionarMeses(mesRef, 1);
    }
  }

  // Todos os meses, no dia [dia], com a descrição pelo mês anterior.
  void mensal({
    required String tipo,
    required int dia,
    required String regra,
    required String Function(DateTime mesAnterior) descricao,
    required String comoPagar,
    double? valor,
  }) {
    var c = DateTime(desde.year, desde.month, 1);
    while (!c.isAfter(fim)) {
      final prazo = DateTime(c.year, c.month, dia);
      if (dentro(prazo)) {
        out.add(o(tipo: tipo, descricao: descricao(adicionarMeses(c, -1)), prazo: prazo, regra: regra, comoPagar: comoPagar, valor: valor));
      }
      c = adicionarMeses(c, 1);
    }
  }

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
    final avisoFim = somarDias(fimIsencao, -avisoDias);
    if (dentro(fimIsencao)) {
      out.add(Obrigacao(
        tipo: 'fim_isencao_ss',
        descricao:
            'Acaba a isenção de Segurança Social. A partir de ${nomeMes(fimIsencao.month)} pagas cerca de ${estim == null ? '—' : moeda(estim.contribuicaoMensal)}/mês.',
        dataLimite: fimIsencao,
        prazoEfetivo: fimIsencao,
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
            comoPagar: 'Segurança Social Direta → Conta-corrente → Pagamentos → gera a referência Multibanco e paga na app do banco. Entre o dia 10 e o dia 20; se o dia 20 for sábado, domingo ou feriado, tens até ao dia útil seguinte.',
          ));
        }
      }
      cursor = adicionarMeses(cursor, 1);
    }

    // ---------------- IVA (regime normal, trimestral) ----------------
    if (perfil.regimeIva == RegimeIva.normal) ivaTrimestral();

    // ---------------- IRS: pagamentos por conta (só faz sentido com estimativa de imposto) ----------------
    for (var ano = desde.year; ano <= fim.year; ano++) {
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

  // ---------------- IRS anual: entrega e e-fatura (recibos verdes, contrato e empresa) ----------------
  if (perfil.entregaIrs) {
    for (var ano = desde.year; ano <= fim.year; ano++) {
      final entrega = prazoEntregaIrs(ano, r);
      if (dentro(entrega)) {
        final anexo = perfil.temAtividade && perfil.temContrato
            ? 'anexos A e B'
            : perfil.temContrato
                ? 'anexo A'
                : perfil.ehSociedade
                    ? 'o teu IRS pessoal'
                    : 'anexo B';
        out.add(o(
          tipo: 'irs_entrega',
          descricao: 'Entregar a declaração de IRS do ano ${ano - 1} ($anexo).',
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
    }
  }

  // ---------------- Contrato (trabalho por conta de outrem) ----------------
  if (perfil.temContrato) {
    // Subsídio de Natal: a entidade patronal paga até 15 de dezembro (CT art. 263.º).
    final mmdd = r.txt('subsidio_natal_ate').split('-');
    for (var ano = desde.year; ano <= fim.year; ano++) {
      final d = DateTime(ano, int.parse(mmdd[0]), int.parse(mmdd[1]));
      if (dentro(d)) {
        out.add(o(
          tipo: 'subsidio_natal',
          descricao: 'Recebes o subsídio de Natal (um mês de salário) até 15 de dezembro.',
          prazo: d,
          valor: perfil.salarioBrutoMensal,
          regra: 'subsidio_natal_ate',
          comoPagar: 'Não pagas nada — é para RECEBER. Se não vier até dia 15, fala com a entidade patronal; se não resolver, com a ACT (act.gov.pt).',
        ));
      }
    }
    // Pede fatura com NIF: no último dia de cada mês, um lembrete (deduções do IRS).
    var c = DateTime(desde.year, desde.month, 1);
    while (!c.isAfter(fim)) {
      final prazo = DateTime(c.year, c.month, ultimoDiaDoMes(c.year, c.month));
      if (dentro(prazo)) {
        out.add(o(
          tipo: 'faturas_nif',
          descricao: 'Pediste fatura com NIF este mês? Saúde, escola, casa, oficina, restaurantes: vale desconto no IRS.',
          prazo: prazo,
          regra: 'deducoes_irs',
          comoPagar: 'Nada a pagar. É só um hábito: sempre que pagares, diz o teu NIF. Em fevereiro vês tudo em faturas.portaldasfinancas.gov.pt.',
        ));
      }
      c = adicionarMeses(c, 1);
    }
  }

  // ---------------- Empresa (ENI ou sociedade) — só CALENDÁRIO, com fonte ----------------
  if (perfil.temEmpresa) {
    // IVA: mensal ou trimestral, conforme o enquadramento.
    if (perfil.ivaPeriodicidade == 'mensal') {
      ivaMensal();
    } else {
      ivaTrimestral();
    }
    // Faturas comunicadas às Finanças (SAF-T) até ao dia 5 do mês seguinte.
    mensal(
      tipo: 'saft',
      dia: r.n('saft_dia').toInt(),
      regra: 'saft_dia',
      descricao: (m) => 'Comunicar às Finanças as faturas de ${nomeMes(m.month)} (ficheiro SAF-T).',
      comoPagar: 'O programa de faturação envia o SAF-T; confirma no Portal das Finanças → e-fatura → Comunicação. Normalmente o contabilista trata.',
    );
    // Salários: DMR até ao dia 10 e Segurança Social até ao dia 25 do mês seguinte.
    mensal(
      tipo: 'dmr',
      dia: r.n('dmr_dia').toInt(),
      regra: 'dmr_dia',
      descricao: (m) => 'Declaração Mensal de Remunerações (salários de ${nomeMes(m.month)}) às Finanças e à Segurança Social.',
      comoPagar: 'Portal das Finanças → DMR (e a DRI na Segurança Social Direta). Se tens contabilista, é ele que entrega.',
    );
    mensal(
      tipo: 'ss_empresa',
      dia: r.n('ss_empregador_pagamento_dia_fim').toInt(),
      regra: 'ss_empregador_pagamento_dia_fim',
      descricao: (m) => 'Pagar à Segurança Social as contribuições dos salários de ${nomeMes(m.month)} (trabalhadores e gerência).',
      comoPagar: 'Segurança Social Direta → Conta-corrente → Pagamentos. Entre o dia 1 e o dia 25 do mês seguinte.',
    );
    // Só as sociedades têm IRC (Modelo 22, pagamentos por conta) e IES.
    if (perfil.ehSociedade) {
      final m22 = r.txt('irc_modelo22_data').split('-');
      final ies = r.txt('ies_data').split('-');
      for (var ano = desde.year; ano <= fim.year; ano++) {
        final d22 = DateTime(ano, int.parse(m22[0]), int.parse(m22[1]));
        if (dentro(d22)) {
          out.add(o(
            tipo: 'irc_modelo22',
            descricao: 'Modelo 22 (IRC) da empresa, do ano ${ano - 1}, e pagar o imposto que faltar.',
            prazo: d22,
            regra: 'irc_modelo22_data',
            comoPagar: 'É o contabilista que entrega (Portal das Finanças → IRC → Modelo 22). Confirma com ele em abril.',
          ));
        }
        final dIes = DateTime(ano, int.parse(ies[0]), int.parse(ies[1]));
        if (dentro(dIes)) {
          out.add(o(
            tipo: 'ies',
            descricao: 'IES (Informação Empresarial Simplificada) do ano ${ano - 1}.',
            prazo: dIes,
            regra: 'ies_data',
            comoPagar: 'É o contabilista que entrega no Portal das Finanças. Tem custo de registo (taxa da conservatória) — confirma com ele.',
          ));
        }
        for (final mmddPc in (r.json('irc_pagamentos_conta_datas') as List).cast<String>()) {
          final pc = mmddPc.split('-');
          final dPc = DateTime(ano, int.parse(pc[0]), int.parse(pc[1]));
          if (dentro(dPc)) {
            out.add(o(
              tipo: 'irc_pagamento_conta',
              descricao: 'Pagamento por conta de IRC (${nomeMes(dPc.month)}).',
              prazo: dPc,
              regra: 'irc_pagamentos_conta_datas',
              comoPagar: 'Só se a empresa teve IRC a pagar no ano anterior. O contabilista diz-te o valor; paga-se no Portal das Finanças.',
            ));
          }
        }
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
