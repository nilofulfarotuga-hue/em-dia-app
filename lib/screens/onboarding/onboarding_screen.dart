import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/carro.dart';
import '../../models/obrigacao.dart';
import '../../regras/regras.dart';
import '../../services/rascunho_onboarding.dart';
import '../../services/uso.dart';
import '../../stores/dados_store.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import '../recibos/recibos_widgets.dart';

/// Os passos do onboarding (a ordem é a do ecrã).
/// B3 (2026-09-18): a primeira pergunta passou a ser «Trabalhas como?». O
/// caminho depois disso depende da resposta: recibos verdes vê atividade,
/// abertura, IVA e rendimento; contrato vê salário e ano de nascimento (IRS
/// Jovem); empresa vê ENI/sociedade, IVA mensal/trimestral e contabilista.
enum PassoOnboarding { boasVindas, trabalho, atividade, abertura, iva, empresa, ivaPeriodo, salario, nascimento, carro, rendimento, contabilista, fim }

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
  final TipoTrabalho? tipoTrabalho;
  final double? salarioMensal;
  final int? anoNascimento;
  final String? empresaTipo;
  final String? ivaPeriodo;
  final String contabilistaEmail;

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
    this.tipoTrabalho,
    this.salarioMensal,
    this.anoNascimento,
    this.empresaTipo,
    this.ivaPeriodo,
    this.contabilistaEmail = '',
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

  // B3
  TipoTrabalho? _tipoTrabalho;
  final _salario = TextEditingController();
  double? _salarioMensal;
  int? _anoNascimento;
  String? _empresaTipo; // eni | sociedade
  String? _ivaPeriodo; // mensal | trimestral
  final _contabilista = TextEditingController();

  bool _aTrabalhar = false;
  String? _erro;

  /// Guardar o rascunho um bocadinho depois de a pessoa parar de escrever
  /// (matrícula, rendimento) — sem isto, cada letra era um pedido ao servidor.
  Timer? _guardarDepois;

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
    // B3: nas fotos o tipo de trabalho vem no exemplo; sem exemplo é o
    // rascunho que manda; e quando o passo inicial salta a pergunta
    // «Trabalhas como?» fica «recibos verdes», o caminho antigo.
    _tipoTrabalho = e.tipoTrabalho ?? (widget.passoInicial > PassoOnboarding.trabalho.index ? TipoTrabalho.independente : null);
    _salarioMensal = e.salarioMensal;
    if (e.salarioMensal != null) _salario.text = moeda(e.salarioMensal!, comSimbolo: false, casas: 0);
    _anoNascimento = e.anoNascimento;
    _empresaTipo = e.empresaTipo;
    _ivaPeriodo = e.ivaPeriodo;
    _contabilista.text = e.contabilistaEmail;
    final i = widget.passoInicial.clamp(0, PassoOnboarding.values.length - 1);
    _passo = PassoOnboarding.values[i];
    // Retomar onde ficou: primeiro o rascunho que o servidor já trouxe com o
    // perfil (síncrono, sem esperar), depois o do aparelho se for mais novo.
    if (widget.exemplo == null && widget.passoInicial == 0) {
      final servidor = context.read<PerfilStore>().perfil?.onboardingRascunho;
      if (servidor != null) _aplicarRascunho(servidor);
      unawaited(_retomarDoAparelho(servidor));
    }
  }

  @override
  void dispose() {
    _guardarDepois?.cancel();
    _matricula.dispose();
    _rendimento.dispose();
    _salario.dispose();
    _contabilista.dispose();
    super.dispose();
  }

  // ---------------- rascunho (guardar ao sair de cada pergunta) ----------------

  String? get _userId => context.read<SessaoStore>().userId ?? context.read<PerfilStore>().perfil?.userId;

  Map<String, dynamic> _rascunho() => {
        'passo': _passo.name,
        'tipo': _tipo?.name,
        'mesAbertura': _mesAbertura,
        'anoAbertura': _anoAbertura,
        'faturouMais15k': _faturouMais15k,
        'temCarro': _temCarro,
        'matricula': _matricula.text,
        'mesMatricula': _mesMatricula,
        'anoMatricula': _anoMatricula,
        'mesSeguro': _mesSeguro,
        'mesUltimaIpo': _mesUltimaIpo,
        'anoUltimaIpo': _anoUltimaIpo,
        'categoriaCarro': _categoriaCarro,
        'rendimentoMensal': _rendimentoMensal,
        'tipoTrabalho': _tipoTrabalho?.name,
        'salarioMensal': _salarioMensal,
        'anoNascimento': _anoNascimento,
        'empresaTipo': _empresaTipo,
        'ivaPeriodo': _ivaPeriodo,
        'contabilistaEmail': _contabilista.text,
      };

  void _aplicarRascunho(Map<String, dynamic> m) {
    int? inteiro(dynamic v) => v == null ? null : int.tryParse(v.toString());
    bool? logico(dynamic v) => v is bool ? v : null;
    final tipo = m['tipo']?.toString();
    _tipo = tipo == null ? null : TipoAtividade.values.where((t) => t.name == tipo).firstOrNull;
    _mesAbertura = inteiro(m['mesAbertura']);
    _anoAbertura = inteiro(m['anoAbertura']);
    _faturouMais15k = logico(m['faturouMais15k']);
    _temCarro = logico(m['temCarro']);
    _matricula.text = (m['matricula'] ?? '').toString();
    _mesMatricula = inteiro(m['mesMatricula']);
    _anoMatricula = inteiro(m['anoMatricula']);
    _mesSeguro = inteiro(m['mesSeguro']);
    _mesUltimaIpo = inteiro(m['mesUltimaIpo']);
    _anoUltimaIpo = inteiro(m['anoUltimaIpo']);
    _categoriaCarro = (m['categoriaCarro'] ?? 'proprio').toString();
    _rendimentoMensal = m['rendimentoMensal'] == null ? null : double.tryParse(m['rendimentoMensal'].toString());
    _rendimento.text = _rendimentoMensal == null ? '' : moeda(_rendimentoMensal!, comSimbolo: false, casas: 0);
    final tt = m['tipoTrabalho']?.toString();
    _tipoTrabalho = tt == null ? null : TipoTrabalho.values.where((x) => x.name == tt).firstOrNull;
    _salarioMensal = m['salarioMensal'] == null ? null : double.tryParse(m['salarioMensal'].toString());
    _salario.text = _salarioMensal == null ? '' : moeda(_salarioMensal!, comSimbolo: false, casas: 0);
    _anoNascimento = inteiro(m['anoNascimento']);
    _empresaTipo = m['empresaTipo']?.toString();
    _ivaPeriodo = m['ivaPeriodo']?.toString();
    _contabilista.text = (m['contabilistaEmail'] ?? '').toString();
    final passo = m['passo']?.toString();
    final p = PassoOnboarding.values.where((x) => x.name == passo).firstOrNull;
    // Nunca se retoma no "fim" nem em passo que este perfil não vê.
    if (p != null && p != PassoOnboarding.fim && _visiveis.contains(p)) _passo = p;
  }

  Future<void> _retomarDoAparelho(Map<String, dynamic>? servidor) async {
    final uid = _userId;
    if (uid == null) return;
    final local = await RascunhoOnboarding.ler(uid);
    final melhor = RascunhoOnboarding.maisRecente(local, servidor);
    if (!mounted || melhor == null || identical(melhor, servidor)) return;
    setState(() => _aplicarRascunho(melhor));
  }

  Future<void> _guardarRascunho() async {
    final uid = _userId;
    if (uid == null) return;
    final m = await RascunhoOnboarding.guardar(uid, _rascunho());
    if (!mounted) return;
    unawaited(context.read<PerfilStore>().guardarRascunhoOnboarding(m));
  }

  /// Para os campos de texto: guarda 800 ms depois da última tecla.
  void _guardarRascunhoDepois() {
    _guardarDepois?.cancel();
    _guardarDepois = Timer(const Duration(milliseconds: 800), _guardarRascunho);
  }

  // ---------------- navegação ----------------

  /// Os passos que este utilizador vê (depende do que faz).
  List<PassoOnboarding> get _visiveis {
    final t = _tipo;
    final tt = _tipoTrabalho;
    final recibos = tt == null || tt == TipoTrabalho.independente || tt == TipoTrabalho.ambos;
    final contrato = tt == TipoTrabalho.contrato || tt == TipoTrabalho.ambos;
    final empresa = tt == TipoTrabalho.empresa;
    return PassoOnboarding.values.where((p) {
      switch (p) {
        case PassoOnboarding.atividade:
        case PassoOnboarding.rendimento:
          if (!recibos) return false;
        case PassoOnboarding.abertura:
        case PassoOnboarding.iva:
          if (!recibos) return false;
        case PassoOnboarding.salario:
        case PassoOnboarding.nascimento:
          return contrato;
        case PassoOnboarding.empresa:
        case PassoOnboarding.ivaPeriodo:
        case PassoOnboarding.contabilista:
          return empresa;
        default:
          break;
      }
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
    unawaited(_guardarRascunho());
  }

  void _voltar() {
    final v = _visiveis;
    final i = v.indexOf(_passo);
    if (i <= 0) return;
    setState(() {
      _passo = v[i - 1];
      _erro = null;
    });
    unawaited(_guardarRascunho());
  }

  bool get _podeAvancar => switch (_passo) {
        PassoOnboarding.boasVindas => true,
        PassoOnboarding.trabalho => _tipoTrabalho != null,
        PassoOnboarding.salario => (_salarioMensal ?? 0) > 0,
        PassoOnboarding.nascimento => true, // pode saltar
        PassoOnboarding.empresa => _empresaTipo != null,
        PassoOnboarding.ivaPeriodo => _ivaPeriodo != null,
        PassoOnboarding.contabilista => _contabilista.text.trim().isEmpty || _emailValido(_contabilista.text),
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

  bool get _recibosVerdes =>
      _tipoTrabalho == null || _tipoTrabalho == TipoTrabalho.independente || _tipoTrabalho == TipoTrabalho.ambos;

  bool get _temAtividade =>
      _recibosVerdes && _tipo != null && _tipo != TipoAtividade.soCarro && _tipo != TipoAtividade.semAtividade;

  static bool _emailValido(String s) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(s.trim());

  PerfilObrigacoes get _perfilObrigacoes => PerfilObrigacoes(
        tipoAtividade: _tipo ?? TipoAtividade.semAtividade,
        dataAbertura: _temAtividade ? _dataAbertura : null,
        regimeIva: _regimeIva,
        rendimentoMensalEstimado: _rendimentoMensal,
        tipoTrabalho: _tipoTrabalho ?? TipoTrabalho.independente,
        salarioBrutoMensal: _salarioMensal,
        empresaTipo: _empresaTipo,
        ivaPeriodicidade: _ivaPeriodo,
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
    final emailContabilista = _contabilista.text.trim();
    final base = perfil.copyWith(
      tipoAtividade: _tipo ?? TipoAtividade.semAtividade,
      dataAbertura: _temAtividade ? _dataAbertura : null,
      limparDataAbertura: !_temAtividade,
      regimeIva: _regimeIva,
      faturouMais15kAnoAnterior: _faturouMais15k ?? false,
      rendimentoMensalEstimado: _rendimentoMensal,
      tipoTrabalho: _tipoTrabalho ?? TipoTrabalho.independente,
      salarioBrutoMensal: _salarioMensal,
      dataNascimento: _anoNascimento == null ? null : DateTime(_anoNascimento!, 1, 1),
      empresaTipo: _empresaTipo,
      ivaPeriodicidade: _ivaPeriodo,
      contabilistaEmail: emailContabilista.isEmpty ? null : emailContabilista,
      limparContabilista: emailContabilista.isEmpty,
      pastaContabilistaAtiva: emailContabilista.isNotEmpty,
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
    unawaited(Uso.registar(EventoUso.concluiuOnboarding, perfil: perfilStore.perfil));
    if (!okCalendario) {
      mensageiro.showSnackBar(SnackBar(content: Text(l.onbCalendarioErro)));
    }
    // O rascunho já não serve para nada: o perfil a sério é o que manda.
    unawaited(RascunhoOnboarding.limpar(userId));
    unawaited(perfilStore.guardarRascunhoOnboarding(null));
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
                  // A chave muda com o passo: cada pergunta nasce com a lista no
                  // topo. Sem isto, quem escolhia a última opção de uma pergunta
                  // via a seguinte já rolada para baixo, sem título (18/09/2026).
                  child: ListView(
                    key: ValueKey(_passo),
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
      PassoOnboarding.nascimento when _anoNascimento == null => l.onbSaltar,
      PassoOnboarding.contabilista when _contabilista.text.trim().isEmpty => l.onbSaltar,
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
        PassoOnboarding.trabalho => _trabalho(l, t),
        PassoOnboarding.salario => _salarioPasso(l, t, r),
        PassoOnboarding.nascimento => _nascimento(l, t, r),
        PassoOnboarding.empresa => _empresa(l, t),
        PassoOnboarding.ivaPeriodo => _ivaPeriodoPasso(l, t),
        PassoOnboarding.contabilista => _contabilistaPasso(l, t),
        PassoOnboarding.atividade => _atividade(l, t),
        PassoOnboarding.abertura => _abertura(l, t, r),
        PassoOnboarding.iva => _iva(l, t, r),
        PassoOnboarding.carro => _carro(l, t, r),
        PassoOnboarding.rendimento => _rendimentoPasso(l, t, r),
        PassoOnboarding.fim => _fim(l, t, r),
      };

  /// O título de cada pergunta, com o botão «Ouvir» (B4: em todos os ecrãs)
  /// e a frase «Podes mudar depois» quando a ajuda não a diz já.
  Widget _titulo(TextTheme t, String texto, {String? ajuda, List<String> termos = const []}) {
    final l = AppLocalizations.of(context);
    final ajudaFinal = ajuda == null
        ? l.onbPodesMudarDepois
        : (ajuda.contains('mudar') || ajuda.contains('saltar') || ajuda.contains('pular') ? ajuda : '$ajuda ${l.onbPodesMudarDepois}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(texto, style: t.headlineLarge)),
            BotaoOuvir(etiqueta: 'onb-${_passo.name}', texto: '$texto $ajudaFinal', soIcone: true),
            if (termos.isNotEmpty) BotaoPalavras(termos: termos),
          ],
        ),
        const SizedBox(height: 8),
        Text(ajudaFinal, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 20),
      ],
    );
  }

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

  // ---- 1. trabalhas como? (B3) ----
  List<Widget> _trabalho(AppLocalizations l, TextTheme t) {
    final opcoes = <(TipoTrabalho, String, String, IconData)>[
      (TipoTrabalho.independente, l.onbTrabalhoIndependente, l.onbTrabalhoIndependenteAjuda, Icons.receipt_long_rounded),
      (TipoTrabalho.contrato, l.onbTrabalhoContrato, l.onbTrabalhoContratoAjuda, Icons.badge_rounded),
      (TipoTrabalho.ambos, l.onbTrabalhoAmbos, l.onbTrabalhoAmbosAjuda, Icons.call_split_rounded),
      (TipoTrabalho.empresa, l.onbTrabalhoEmpresa, l.onbTrabalhoEmpresaAjuda, Icons.storefront_rounded),
    ];
    return [
      _titulo(t, l.onbTrabalhasComo, ajuda: l.onbPodesMudarDepois, termos: const ['recibos_verdes', 'eni', 'lda']),
      for (final (tipo, texto, ajuda, icone) in opcoes) ...[
        BotaoEscolha(
          texto: texto,
          ajuda: ajuda,
          icone: icone,
          selecionado: _tipoTrabalho == tipo,
          aoTocar: () {
            setState(() {
              _tipoTrabalho = tipo;
              // Contrato e empresa não têm ofício de recibos verdes.
              if (tipo == TipoTrabalho.contrato || tipo == TipoTrabalho.empresa) _tipo = null;
            });
            _avancar();
          },
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  // ---- contrato: quanto ganhas (bruto) ----
  List<Widget> _salarioPasso(AppLocalizations l, TextTheme t, RegrasLegais r) {
    final v = _salarioMensal;
    final linhas = <String>[];
    if (v != null && v > 0) {
      final rv = lerReciboVencimento(bruto: v, irsRetido: 0, r: r);
      linhas.add(l.onbSalarioSs(moeda(rv.ssTrabalhador), moeda(rv.pctSs, comSimbolo: false, casas: 0)));
      linhas.add(l.onbSalario14(moeda(v * 14, casas: 0)));
    }
    return [
      _titulo(t, l.onbSalarioTitulo, ajuda: l.onbSalarioAjuda),
      TextField(
        controller: _salario,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: t.headlineMedium,
        decoration: InputDecoration(
          hintText: '0',
          suffixText: '${l.euros} ${l.onbPorMes}',
          suffixStyle: t.titleMedium!.copyWith(color: AppColors.textSecondary),
        ),
        onChanged: (s) {
          setState(() => _salarioMensal = lerNumero(s));
          _guardarRascunhoDepois();
        },
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          for (final (k, valor) in [r.n('smn').round(), 1100, 1500, 2000].indexed) ...[
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
                  _salarioMensal = valor.toDouble();
                  _salario.text = '$valor';
                }),
              ),
            ),
          ],
        ],
      ),
      if (linhas.isNotEmpty) ...[
        const SizedBox(height: 20),
        _deducao(t, linhas),
      ],
    ];
  }

  // ---- contrato: ano de nascimento (IRS Jovem) ----
  List<Widget> _nascimento(AppLocalizations l, TextTheme t, RegrasLegais r) {
    final anos = [for (var a = _hoje.year - 16; a >= _hoje.year - 80; a--) a];
    final linhas = <String>[];
    if (_anoNascimento != null) {
      final j = irsJovem(idadeEm31Dez: _hoje.year - _anoNascimento!, anoDeRendimentos: 1, r: r);
      linhas.add(j.elegivel ? l.onbIrsJovemSim : l.onbIrsJovemNao);
    }
    return [
      _titulo(t, l.onbNascimentoTitulo, ajuda: l.onbNascimentoAjuda),
      DropdownButtonFormField<int>(
        initialValue: _anoNascimento,
        decoration: InputDecoration(labelText: l.onbAno),
        items: [for (final a in anos) DropdownMenuItem(value: a, child: Text('$a'))],
        onChanged: (v) {
          setState(() => _anoNascimento = v);
          unawaited(_guardarRascunho());
        },
      ),
      if (linhas.isNotEmpty) ...[
        const SizedBox(height: 20),
        _deducao(t, linhas),
      ],
    ];
  }

  // ---- empresa: ENI ou sociedade ----
  List<Widget> _empresa(AppLocalizations l, TextTheme t) => [
        _titulo(t, l.onbEmpresaTitulo, ajuda: l.onbEmpresaAjuda, termos: PalavrasDoEcra.onboardingEmpresa),
        BotaoEscolha(
          texto: l.onbEmpresaEni,
          ajuda: l.onbEmpresaEniAjuda,
          icone: Icons.person_rounded,
          selecionado: _empresaTipo == 'eni',
          aoTocar: () {
            setState(() => _empresaTipo = 'eni');
            _avancar();
          },
        ),
        const SizedBox(height: 12),
        BotaoEscolha(
          texto: l.onbEmpresaSociedade,
          ajuda: l.onbEmpresaSociedadeAjuda,
          icone: Icons.apartment_rounded,
          selecionado: _empresaTipo == 'sociedade',
          aoTocar: () {
            setState(() => _empresaTipo = 'sociedade');
            _avancar();
          },
        ),
      ];

  // ---- empresa: IVA mensal ou trimestral ----
  List<Widget> _ivaPeriodoPasso(AppLocalizations l, TextTheme t) => [
        _titulo(t, l.onbIvaPeriodoTitulo, ajuda: l.onbIvaPeriodoAjuda, termos: PalavrasDoEcra.onboardingIvaPeriodo),
        BotaoEscolha(
          texto: l.onbIvaTrimestral,
          icone: Icons.calendar_view_month_rounded,
          selecionado: _ivaPeriodo == 'trimestral',
          aoTocar: () {
            setState(() => _ivaPeriodo = 'trimestral');
            _avancar();
          },
        ),
        const SizedBox(height: 12),
        BotaoEscolha(
          texto: l.onbIvaMensal,
          icone: Icons.calendar_today_rounded,
          selecionado: _ivaPeriodo == 'mensal',
          aoTocar: () {
            setState(() => _ivaPeriodo = 'mensal');
            _avancar();
          },
        ),
      ];

  // ---- empresa: contabilista (pasta mensal) ----
  List<Widget> _contabilistaPasso(AppLocalizations l, TextTheme t) => [
        _titulo(t, l.onbContabilistaTitulo, ajuda: l.onbContabilistaAjuda, termos: const ['contabilidade']),
        TextField(
          controller: _contabilista,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(labelText: l.onbContabilistaEmail, prefixIcon: const Icon(Icons.mail_outline_rounded)),
          onChanged: (_) {
            setState(() {});
            _guardarRascunhoDepois();
          },
        ),
        const SizedBox(height: 12),
        NotaInfo(l.onbContabilistaNota),
      ];

  // ---- 1. o que fazes ----
  List<Widget> _atividade(AppLocalizations l, TextTheme t) {
    // A app deixou de ser só de motorista: cada ofício tem os seus textos nos
    // recibos. "Serviços" usa a etiqueta nova (sem falar de obras) porque as
    // obras passaram a ser uma opção à parte.
    final opcoes = <(TipoAtividade, String, IconData)>[
      (TipoAtividade.tvde, l.onbTvde, Icons.local_taxi_rounded),
      (TipoAtividade.estafeta, l.onbEstafeta, Icons.delivery_dining_rounded),
      (TipoAtividade.servicos, l.oficioServicos, Icons.handyman_rounded),
      (TipoAtividade.obras, l.oficioObras, Icons.construction_rounded),
      (TipoAtividade.freelancer, l.onbFreelancer, Icons.laptop_mac_rounded),
      (TipoAtividade.outro, l.oficioOutro, Icons.more_horiz_rounded),
      (TipoAtividade.semAtividade, l.onbSemAtividade, Icons.hourglass_empty_rounded),
      (TipoAtividade.soCarro, l.onbSoCarro, Icons.directions_car_rounded),
    ];
    return [
      _titulo(t, l.onbOQueFazes, termos: PalavrasDoEcra.onboardingAtividade),
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
      _titulo(t, l.onbQuandoAbriste, ajuda: l.onbQuandoAbristeAjuda, termos: PalavrasDoEcra.onboardingAbertura),
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
        _titulo(t, l.onbFaturouMais15k, ajuda: l.onbFaturouMais15kAjuda, termos: PalavrasDoEcra.onboardingIva),
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
      _titulo(t, l.onbTensCarro, termos: const ['iuc', 'tvde']),
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
          onChanged: (_) {
            setState(() {});
            _guardarRascunhoDepois();
          },
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
      _titulo(t, l.onbQuantoGanhas, ajuda: l.onbQuantoGanhasAjuda, termos: const ['ss', 'irs', 'imposto']),
      TextField(
        controller: _rendimento,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: t.headlineMedium,
        decoration: InputDecoration(
          hintText: '0',
          suffixText: '${l.euros} ${l.onbPorMes}',
          suffixStyle: t.titleMedium!.copyWith(color: AppColors.textSecondary),
        ),
        onChanged: (s) {
          setState(() => _rendimentoMensal = lerNumero(s));
          _guardarRascunhoDepois();
        },
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
