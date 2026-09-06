import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/carro.dart';
import '../../models/obrigacao.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';

/// Os passos do onboarding (a ordem é a do ecrã).
enum PassoOnboarding { boasVindas, atividade, abertura, iva, carro, rendimento, fim }

/// O que o onboarding recolhe. Também serve para pré-encher o ecrã nas fotos
/// (golden) sem servidor.
class DadosOnboarding {
  final TipoAtividade? tipoAtividade;
  final int? mesAbertura;
  final int? anoAbertura;
  final bool? faturouMais15k;
  final bool? temCarro;
  final String matricula;
  final int? mesMatricula;
  final int? anoMatricula;
  final int? mesSeguro;
  final int? mesUltimaIpo;
  final int? anoUltimaIpo;
  final String categoriaCarro; // proprio | alugado_frota
  final double? rendimentoMensal;

  const DadosOnboarding({
    this.tipoAtividade,
    this.mesAbertura,
    this.anoAbertura,
    this.faturouMais15k,
    this.temCarro,
    this.matricula = '',
    this.mesMatricula,
    this.anoMatricula,
    this.mesSeguro,
    this.mesUltimaIpo,
    this.anoUltimaIpo,
    this.categoriaCarro = 'proprio',
    this.rendimentoMensal,
  });
}

/// Tela 0 — Onboarding de 2 minutos: uma pergunta por ecrã, botões grandes,
/// barra de progresso fina no topo, botão Voltar. No fim gera a
/// pré-visualização das obrigações do mês e guarda o perfil.
class OnboardingScreen extends StatefulWidget {
  /// Passo em que arranca (para as fotos). 0 = boas-vindas.
  final int passoInicial;

  /// Dados de exemplo para pré-encher (para as fotos).
  final DadosOnboarding? exemplo;

  /// "Hoje" fixo (para as fotos serem sempre iguais). Por omissão: Lisboa.
  final DateTime? hoje;

  const OnboardingScreen({super.key, this.passoInicial = 0, this.exemplo, this.hoje});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PassoOnboarding _passo;
  late DateTime _hoje;

  TipoAtividade? _tipo;
  int? _mesAbertura;
  int? _anoAbertura;
  bool? _faturouMais15k;
  bool? _temCarro;
  final _matricula = TextEditingController();
  int? _mesMatricula;
  int? _anoMatricula;
  int? _mesSeguro;
  int? _mesUltimaIpo;
  int? _anoUltimaIpo;
  String _categoriaCarro = 'proprio';
  final _rendimento = TextEditingController();
  double? _rendimentoMensal;

  bool _aTrabalhar = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _hoje = widget.hoje ?? hojeLisboa();
    final e = widget.exemplo ?? const DadosOnboarding();
    _tipo = e.tipoAtividade;
    _mesAbertura = e.mesAbertura;
    _anoAbertura = e.anoAbertura;
    _faturouMais15k = e.faturouMais15k;
    _temCarro = e.temCarro;
    _matricula.text = e.matricula;
    _mesMatricula = e.mesMatricula;
    _anoMatricula = e.anoMatricula;
    _mesSeguro = e.mesSeguro;
    _mesUltimaIpo = e.mesUltimaIpo;
    _anoUltimaIpo = e.anoUltimaIpo;
    _categoriaCarro = e.categoriaCarro;
    _rendimentoMensal = e.rendimentoMensal;
    if (e.rendimentoMensal != null) _rendimento.text = moeda(e.rendimentoMensal!, comSimbolo: false, casas: 0);
    final i = widget.passoInicial.clamp(0, PassoOnboarding.values.length - 1);
    _passo = PassoOnboarding.values[i];
  }

  @override
  void dispose() {
    _matricula.dispose();
    _rendimento.dispose();
    super.dispose();
  }

  // ---------------- navegação ----------------

  /// Os passos que este utilizador vê (depende do que faz).
  List<PassoOnboarding> get _visiveis {
    final t = _tipo;
    return PassoOnboarding.values.where((p) {
      if (t == TipoAtividade.soCarro &&
          (p == PassoOnboarding.abertura || p == PassoOnboarding.iva || p == PassoOnboarding.rendimento)) {
        return false;
      }
      if (t == TipoAtividade.semAtividade && (p == PassoOnboarding.abertura || p == PassoOnboarding.iva)) {
        return false;
      }
      return true;
    }).toList();
  }

  void _avancar() {
    final v = _visiveis;
    final i = v.indexOf(_passo);
    if (i < 0 || i >= v.length - 1) return;
    setState(() {
      _passo = v[i + 1];
      _erro = null;
    });
  }

  void _voltar() {
    final v = _visiveis;
    final i = v.indexOf(_passo);
    if (i <= 0) return;
    setState(() {
      _passo = v[i - 1];
      _erro = null;
    });
  }

  bool get _podeAvancar => switch (_passo) {
        PassoOnboarding.boasVindas => true,
        PassoOnboarding.atividade => _tipo != null,
        PassoOnboarding.abertura => _dataAbertura != null,
        PassoOnboarding.iva => _faturouMais15k != null,
        PassoOnboarding.carro => _temCarro == false || (_temCarro == true && _carroValido),
        PassoOnboarding.rendimento => (_rendimentoMensal ?? 0) > 0,
        PassoOnboarding.fim => !_aTrabalhar,
      };

  // ---------------- deduções ----------------

  DateTime? get _dataAbertura =>
      (_mesAbertura == null || _anoAbertura == null) ? null : DateTime(_anoAbertura!, _mesAbertura!, 1);

  bool get _carroValido =>
      _matricula.text.trim().isNotEmpty && _mesMatricula != null && _anoMatricula != null;

  DateTime? get _dataMatricula => (_mesMatricula == null || _anoMatricula == null)
      ? null
      : DateTime(_anoMatricula!, _mesMatricula!, ultimoDiaDoMes(_anoMatricula!, _mesMatricula!));

  /// O seguro renova no próximo mês com esse número (dia 1, para o aviso chegar antes).
  DateTime? get _seguroRenovaEm {
    final m = _mesSeguro;
    if (m == null) return null;
    final ano = m > _hoje.month ? _hoje.year : _hoje.year + 1;
    return DateTime(ano, m, 1);
  }

  DateTime? get _ultimaIpo => (_mesUltimaIpo == null || _anoUltimaIpo == null)
      ? null
      : DateTime(_anoUltimaIpo!, _mesUltimaIpo!, ultimoDiaDoMes(_anoUltimaIpo!, _mesUltimaIpo!));

  RegimeIva get _regimeIva => _faturouMais15k == true ? RegimeIva.normal : RegimeIva.isento53;

  bool get _temAtividade =>
      _tipo != null && _tipo != TipoAtividade.soCarro && _tipo != TipoAtividade.semAtividade;

  PerfilObrigacoes get _perfilObrigacoes => PerfilObrigacoes(
        tipoAtividade: _tipo ?? TipoAtividade.semAtividade,
        dataAbertura: _temAtividade ? _dataAbertura : null,
        regimeIva: _regimeIva,
        rendimentoMensalEstimado: _rendimentoMensal,
      );

  CarroObrigacoes? get _carroObrigacoes {
    final dm = _dataMatricula;
    if (_temCarro != true || dm == null) return null;
    return CarroObrigacoes(
      id: 'novo',
      matricula: _matricula.text.trim().toUpperCase(),
      dataMatricula: dm,
      seguroRenovaEm: _seguroRenovaEm,
      ultimaIpo: _ultimaIpo,
      usoTvde: _tipo == TipoAtividade.tvde,
    );
  }

  /// As obrigações do MÊS corrente (pré-visualização local, sem servidor).
  List<ObrigacaoItem> _obrigacoesDoMes(RegrasLegais r, String userId) {
    final c = _carroObrigacoes;
    final todas = gerarObrigacoes(
      perfil: _perfilObrigacoes,
      carros: c == null ? const [] : [c],
      hoje: _hoje,
      r: r,
    );
    return todas
        .where((o) => o.dataLimite.year == _hoje.year && o.dataLimite.month == _hoje.month)
        .map((o) => ObrigacaoItem.deGerada(o, userId))
        .toList()
      ..sort((a, b) => a.dataLimite.compareTo(b.dataLimite));
  }

  // ---------------- concluir ----------------

  Future<void> _concluir() async {
    final l = AppLocalizations.of(context);
    final perfilStore = context.read<PerfilStore>();
    final carrosStore = context.read<CarrosStore>();
    final obrigStore = context.read<ObrigacoesStore>();
    final sessao = context.read<SessaoStore>();
    final mensageiro = ScaffoldMessenger.of(context);

    final perfil = perfilStore.perfil;
    final userId = sessao.userId ?? perfil?.userId;
    if (perfil == null || userId == null) {
      setState(() => _erro = l.erroRede);
      return;
    }
    setState(() {
      _aTrabalhar = true;
      _erro = null;
    });

    // 1. O perfil (ainda sem concluir — a Edge Function lê-o do servidor).
    final base = perfil.copyWith(
      tipoAtividade: _tipo,
      dataAbertura: _temAtividade ? _dataAbertura : null,
      limparDataAbertura: !_temAtividade,
      regimeIva: _regimeIva,
      faturouMais15kAnoAnterior: _faturouMais15k ?? false,
      rendimentoMensalEstimado: _rendimentoMensal,
    );
    final ok1 = await perfilStore.guardar(base);
    if (!ok1) {
      if (mounted) {
        setState(() {
          _aTrabalhar = false;
          _erro = l.erroRede;
        });
      }
      return;
    }

    // 2. O carro (se houver).
    final c = _carroObrigacoes;
    if (c != null) {
      await carrosStore.guardarCarro(Carro(
        id: '',
        userId: userId,
        matricula: c.matricula,
        mesMatricula: _mesMatricula,
        anoMatricula: _anoMatricula,
        categoria: _categoriaCarro,
        usoTvde: c.usoTvde,
        seguroRenovaEm: c.seguroRenovaEm,
        ultimaIpo: c.ultimaIpo,
      ));
    }

    // 3. O calendário (Edge Function). Se falhar, avisa mas conclui na mesma.
    final okCalendario = await obrigStore.recalcular(userId);

    // 4. Concluído — o RaizNavegador troca para a Shell quando isto ficar true.
    final ok4 = await perfilStore.guardar(base.copyWith(onboardingConcluido: true));
    if (!ok4) {
      if (mounted) {
        setState(() {
          _aTrabalhar = false;
          _erro = l.erroRede;
        });
      }
      return;
    }
    if (!okCalendario) {
      mensageiro.showSnackBar(SnackBar(content: Text(l.onbCalendarioErro)));
    }
    if (mounted) setState(() => _aTrabalhar = false);
  }

  // ---------------- ecrã ----------------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final r = context.watch<RegrasStore>().regras;
    final visiveis = _visiveis;
    final i = visiveis.indexOf(_passo).clamp(0, visiveis.length - 1);
    final progresso = visiveis.length <= 1 ? 1.0 : i / (visiveis.length - 1);
    final ehPergunta = _passo != PassoOnboarding.boasVindas && _passo != PassoOnboarding.fim;
    final totalPerguntas = visiveis.length - 2;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: progresso, minHeight: 4),
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  if (_passo != PassoOnboarding.boasVindas)
                    TextButton.icon(
                      onPressed: _aTrabalhar ? null : _voltar,
                      icon: const Icon(Icons.arrow_back_rounded, size: 22),
                      label: Text(l.onbVoltar),
                    ),
                  const Spacer(),
                  if (ehPergunta)
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(l.onbPergunta(i, totalPerguntas), style: t.bodySmall),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: ListView(
                    padding: paddingEcra,
                    children: _conteudo(l, t, r),
                  ),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: _botaoPrincipal(l),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoPrincipal(AppLocalizations l) {
    final texto = switch (_passo) {
      PassoOnboarding.boasVindas => l.onbComecar,
      PassoOnboarding.fim => l.onbEntrarNaApp,
      _ => l.onbContinuar,
    };
    return BotaoGrande(
      texto: texto,
      aTrabalhar: _aTrabalhar,
      icone: _passo == PassoOnboarding.fim ? Icons.check_rounded : null,
      aoTocar: !_podeAvancar ? null : (_passo == PassoOnboarding.fim ? _concluir : _avancar),
    );
  }

  List<Widget> _conteudo(AppLocalizations l, TextTheme t, RegrasLegais r) => switch (_passo) {
        PassoOnboarding.boasVindas => _boasVindas(l, t),
        PassoOnboarding.atividade => _atividade(l, t),
        PassoOnboarding.abertura => _abertura(l, t, r),
        PassoOnboarding.iva => _iva(l, t, r),
        PassoOnboarding.carro => _carro(l, t, r),
        PassoOnboarding.rendimento => _rendimentoPasso(l, t, r),
        PassoOnboarding.fim => _fim(l, t, r),
      };

  Widget _titulo(TextTheme t, String texto, {String? ajuda}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(texto, style: t.headlineLarge),
          if (ajuda != null) ...[
            const SizedBox(height: 8),
            Text(ajuda, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 20),
        ],
      );

  /// Cartão verde com o que o Em Dia já deduziu.
  Widget _deducao(TextTheme t, List<String> linhas) => Cartao(
        cor: AppColors.emDiaClaro,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var k = 0; k < linhas.length; k++) ...[
              if (k > 0) const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.primaryDark, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(linhas[k], style: t.titleMedium!.copyWith(color: AppColors.primaryDeep)),
                  ),
                ],
              ),
            ],
          ],
        ),
      );

  // ---- 0. boas-vindas ----
  List<Widget> _boasVindas(AppLocalizations l, TextTheme t) => [
        const SizedBox(height: 24),
        const Icon(Icons.check_circle_rounded, size: 72, color: AppColors.emDia),
        const SizedBox(height: 16),
        Text(l.appNome, textAlign: TextAlign.center, style: t.headlineLarge),
        const SizedBox(height: 20),
        Text(l.boasVindas, textAlign: TextAlign.center, style: t.bodyLarge),
      ];

  // ---- 1. o que fazes ----
  List<Widget> _atividade(AppLocalizations l, TextTheme t) {
    final opcoes = <(TipoAtividade, String, IconData)>[
      (TipoAtividade.tvde, l.onbTvde, Icons.local_taxi_rounded),
      (TipoAtividade.estafeta, l.onbEstafeta, Icons.delivery_dining_rounded),
      (TipoAtividade.servicos, l.onbServicos, Icons.handyman_rounded),
      (TipoAtividade.freelancer, l.onbFreelancer, Icons.laptop_mac_rounded),
      (TipoAtividade.semAtividade, l.onbSemAtividade, Icons.hourglass_empty_rounded),
      (TipoAtividade.soCarro, l.onbSoCarro, Icons.directions_car_rounded),
    ];
    return [
      _titulo(t, l.onbOQueFazes),
      for (final (tipo, texto, icone) in opcoes) ...[
        BotaoEscolha(
          texto: texto,
          icone: icone,
          selecionado: _tipo == tipo,
          aoTocar: () {
            setState(() => _tipo = tipo);
            _avancar();
          },
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  // ---- 2. quando abriste ----
  List<Widget> _abertura(AppLocalizations l, TextTheme t, RegrasLegais r) {
    final anos = [for (var a = _hoje.year; a >= _hoje.year - 20; a--) a];
    final d = _dataAbertura;
    final linhas = <String>[];
    if (d != null) {
      final fim = fimIsencaoSS(d, r);
      if (!_hoje.isBefore(fim)) {
        linhas.add(l.onbIsencaoJaAcabou(dataPt(ultimoDiaIsencaoSS(d, r))));
      } else {
        linhas.add(l.onbIsentoAte(dataPt(ultimoDiaIsencaoSS(d, r))));
        linhas.add(l.onbDepoisPagas('${nomeMes(fim.month)} ${fim.year}'));
      }
    }
    return [
      _titulo(t, l.onbQuandoAbriste, ajuda: l.onbQuandoAbristeAjuda),
      Row(
        children: [
          Expanded(
            flex: 3,
            child: _Seletor(
              rotulo: l.onbMes,
              valor: _mesAbertura,
              opcoes: [for (var m = 1; m <= 12; m++) m],
              texto: nomeMes,
              aoMudar: (v) => setState(() => _mesAbertura = v),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _Seletor(
              rotulo: l.onbAno,
              valor: _anoAbertura,
              opcoes: anos,
              texto: (a) => '$a',
              aoMudar: (v) => setState(() => _anoAbertura = v),
            ),
          ),
        ],
      ),
      if (linhas.isNotEmpty) ...[
        const SizedBox(height: 20),
        _deducao(t, linhas),
      ],
    ];
  }

  // ---- 3. IVA ----
  List<Widget> _iva(AppLocalizations l, TextTheme t, RegrasLegais r) => [
        _titulo(t, l.onbFaturouMais15k, ajuda: l.onbFaturouMais15kAjuda),
        BotaoEscolha(
          texto: l.onbSim,
          icone: Icons.trending_up_rounded,
          selecionado: _faturouMais15k == true,
          aoTocar: () => setState(() => _faturouMais15k = true),
        ),
        const SizedBox(height: 12),
        BotaoEscolha(
          texto: l.onbNao,
          icone: Icons.trending_flat_rounded,
          selecionado: _faturouMais15k == false,
          aoTocar: () => setState(() => _faturouMais15k = false),
        ),
        if (_faturouMais15k != null) ...[
          const SizedBox(height: 20),
          _deducao(t, [
            _faturouMais15k!
                ? l.onbIvaNormalExplica(pct(r.n('iva_taxa_normal'), casas: 0))
                : l.onbIvaIsentoExplica,
          ]),
        ],
      ];

  // ---- 4. carro ----
  List<Widget> _carro(AppLocalizations l, TextTheme t, RegrasLegais r) {
    final anosMatricula = [for (var a = _hoje.year; a >= _hoje.year - 30; a--) a];
    final anosIpo = [for (var a = _hoje.year; a >= _hoje.year - 4; a--) a];
    final meses = [for (var m = 1; m <= 12; m++) m];
    final linhas = <String>[];
    final dm = _dataMatricula;
    if (dm != null) {
      linhas.add(l.onbIucEm(nomeMes(proximoIuc(mesMatricula: dm.month, hoje: _hoje).month)));
      final ipo = proximaIpo(
        matricula: dm,
        ultimaIpo: _ultimaIpo,
        hoje: _hoje,
        tvde: _tipo == TipoAtividade.tvde,
        r: r,
      );
      if (ipo != null) linhas.add(l.onbProximaIpo(dataPt(ipo)));
    }
    final rotulo = t.titleSmall!.copyWith(color: AppColors.textSecondary);
    return [
      _titulo(t, l.onbTensCarro),
      Row(
        children: [
          Expanded(
            child: _Opcao(
              texto: l.onbSim,
              icone: Icons.directions_car_rounded,
              selecionado: _temCarro == true,
              aoTocar: () => setState(() => _temCarro = true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Opcao(
              texto: l.onbNao,
              icone: Icons.close_rounded,
              selecionado: _temCarro == false,
              aoTocar: () => setState(() => _temCarro = false),
            ),
          ),
        ],
      ),
      if (_temCarro == true) ...[
        const SizedBox(height: 20),
        TextField(
          controller: _matricula,
          textCapitalization: TextCapitalization.characters,
          autocorrect: false,
          inputFormatters: [
            TextInputFormatter.withFunction((antes, depois) => depois.copyWith(text: depois.text.toUpperCase())),
            LengthLimitingTextInputFormatter(10),
          ],
          style: t.titleLarge!.copyWith(letterSpacing: 1.5),
          decoration: InputDecoration(labelText: l.onbMatricula, prefixIcon: const Icon(Icons.pin_rounded)),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 6),
        Text(l.onbMatriculaAjuda, style: t.bodySmall),
        const SizedBox(height: 20),
        Text(l.onbDataMatricula, style: rotulo),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _Seletor(
                rotulo: l.onbMes,
                valor: _mesMatricula,
                opcoes: meses,
                texto: nomeMes,
                aoMudar: (v) => setState(() => _mesMatricula = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _Seletor(
                rotulo: l.onbAno,
                valor: _anoMatricula,
                opcoes: anosMatricula,
                texto: (a) => '$a',
                aoMudar: (v) => setState(() => _anoMatricula = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(l.onbSeguroMes, style: rotulo),
        const SizedBox(height: 8),
        _Seletor(
          rotulo: l.onbMes,
          valor: _mesSeguro,
          opcoes: meses,
          texto: nomeMes,
          aoMudar: (v) => setState(() => _mesSeguro = v),
        ),
        const SizedBox(height: 20),
        Text('${l.onbUltimaIpo} (${l.onbOpcional})', style: rotulo),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _Seletor(
                rotulo: l.onbMes,
                valor: _mesUltimaIpo,
                opcoes: meses,
                texto: nomeMes,
                aoMudar: (v) => setState(() => _mesUltimaIpo = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _Seletor(
                rotulo: l.onbAno,
                valor: _anoUltimaIpo,
                opcoes: anosIpo,
                texto: (a) => '$a',
                aoMudar: (v) => setState(() => _anoUltimaIpo = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(l.onbProprioOuFrota, style: rotulo),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Opcao(
                texto: l.onbProprio,
                selecionado: _categoriaCarro == 'proprio',
                aoTocar: () => setState(() => _categoriaCarro = 'proprio'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Opcao(
                texto: l.onbAlugadoFrota,
                selecionado: _categoriaCarro == 'alugado_frota',
                aoTocar: () => setState(() => _categoriaCarro = 'alugado_frota'),
              ),
            ),
          ],
        ),
        if (linhas.isNotEmpty) ...[
          const SizedBox(height: 20),
          _deducao(t, linhas),
        ],
      ],
    ];
  }

  // ---- 5. quanto ganhas ----
  List<Widget> _rendimentoPasso(AppLocalizations l, TextTheme t, RegrasLegais r) {
    final v = _rendimentoMensal;
    final d = _temAtividade ? _dataAbertura : null;
    final linhas = <String>[];
    if (v != null && v > 0) {
      if (d != null && _hoje.isBefore(fimIsencaoSS(d, r))) {
        linhas.add(l.onbSsIsentoAte(dataPt(ultimoDiaIsencaoSS(d, r))));
      } else {
        final ss = estimarSSMensal(rendimentoMensal: v, tipo: TipoRendimento.servicos, r: r);
        linhas.add(l.onbSsPorMes(moeda(ss.contribuicaoMensal)));
      }
      final irs = calcularIrs(rendimentoBrutoAnual: v * 12, tipo: TipoRendimento.servicos, ano: _hoje.year, r: r);
      linhas.add(irs.guardarPorMes > 0 ? l.onbIrsPorMes(moeda(irs.guardarPorMes)) : l.onbIrsZero);
    }
    return [
      _titulo(t, l.onbQuantoGanhas, ajuda: l.onbQuantoGanhasAjuda),
      TextField(
        controller: _rendimento,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: t.headlineMedium,
        decoration: InputDecoration(
          hintText: '0',
          suffixText: '${l.euros} ${l.onbPorMes}',
          suffixStyle: t.titleMedium!.copyWith(color: AppColors.textSecondary),
        ),
        onChanged: (s) => setState(() => _rendimentoMensal = lerNumero(s)),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          for (final (k, valor) in const [800, 1200, 1800, 2500].indexed) ...[
            if (k > 0) const SizedBox(width: 6),
            Expanded(
              child: ChoiceChip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(moeda(valor, casas: 0), textAlign: TextAlign.center, maxLines: 1),
                ),
                selected: v == valor,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                onSelected: (_) => setState(() {
                  _rendimentoMensal = valor.toDouble();
                  _rendimento.text = '$valor';
                }),
              ),
            ),
          ],
        ],
      ),
      if (linhas.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text(l.onbSimulacaoTitulo, style: t.titleMedium),
        const SizedBox(height: 8),
        _deducao(t, linhas),
        const SizedBox(height: 8),
        Text(l.onbSimulacaoAjuda, style: t.bodySmall),
      ],
    ];
  }

  // ---- 6. fim ----
  List<Widget> _fim(AppLocalizations l, TextTheme t, RegrasLegais r) {
    final userId = context.read<SessaoStore>().userId ?? '';
    final itens = _obrigacoesDoMes(r, userId);
    String dia(DateTime d) =>
        d.month == _hoje.month ? '${d.day}' : '${d.day} de ${nomeMes(d.month)}';
    final String mensagem;
    if (itens.isEmpty) {
      mensagem = l.fimOnboardingNada;
    } else if (itens.length == 1) {
      final o = itens.first;
      mensagem = l.fimOnboardingUma(
        o.nomeCurto,
        o.valorEstimado == null ? l.onbSemValor : moeda(o.valorEstimado!),
        dia(o.dataLimite),
        dia(o.avisoEm),
      );
    } else {
      final lista = itens
          .map((o) => o.valorEstimado == null
              ? l.onbItemListaSemValor(o.nomeCurto, dia(o.dataLimite))
              : l.onbItemLista(o.nomeCurto, moeda(o.valorEstimado!), dia(o.dataLimite)))
          .join(', ');
      mensagem = l.fimOnboardingVarias(itens.length, lista);
    }
    return [
      const SizedBox(height: 8),
      const Icon(Icons.celebration_rounded, size: 64, color: AppColors.emDia),
      const SizedBox(height: 16),
      Text(mensagem, style: t.headlineSmall),
      if (itens.isNotEmpty) ...[
        const SizedBox(height: 20),
        TituloSeccao(l.onbEsteMes),
        for (final o in itens) ...[
          Cartao(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LinhaValor(
              '${o.nomeCurto} · ${l.onbDiaLimite(dia(o.dataLimite))}',
              o.valorEstimado == null ? '—' : moeda(o.valorEstimado!),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
      if (_erro != null) ...[
        const SizedBox(height: 8),
        Aviso(_erro!, tom: Semaforo.vermelho),
      ],
    ];
  }
}

/// Seletor grande (dropdown) de mês ou ano.
class _Seletor extends StatelessWidget {
  final String rotulo;
  final int? valor;
  final List<int> opcoes;
  final String Function(int) texto;
  final ValueChanged<int?> aoMudar;
  const _Seletor({
    required this.rotulo,
    required this.valor,
    required this.opcoes,
    required this.texto,
    required this.aoMudar,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: rotulo,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      isEmpty: valor == null,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: valor,
          isExpanded: true,
          isDense: true,
          style: t.titleMedium,
          icon: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
          items: [
            for (final o in opcoes)
              DropdownMenuItem<int>(value: o, child: Text(texto(o), overflow: TextOverflow.ellipsis)),
          ],
          onChanged: aoMudar,
        ),
      ),
    );
  }
}

/// Opção curta lado a lado (Sim / Não, É meu / Alugado à frota).
class _Opcao extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final bool selecionado;
  final VoidCallback aoTocar;
  const _Opcao({required this.texto, this.icone, required this.selecionado, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cor = selecionado ? AppColors.primaryDark : AppColors.textPrimary;
    return Cartao(
      aoTocar: aoTocar,
      cor: selecionado ? AppColors.primaryLight : AppColors.surface,
      bordo: selecionado ? AppColors.primary : AppColors.divider,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icone != null) ...[Icon(icone, size: 24, color: cor), const SizedBox(width: 8)],
          Flexible(
            child: Text(
              texto,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.titleMedium!.copyWith(color: cor),
            ),
          ),
        ],
      ),
    );
  }
}
