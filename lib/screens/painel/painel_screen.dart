import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/obrigacao.dart';
import '../../models/perfil.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../widgets/widgets.dart';
import '../calendario/detalhe_obrigacao.dart';
import '../recibos/recibos_screen.dart';
import 'cartao_acao.dart';
import 'cartao_heroi.dart';
import 'cartoes_painel.dart';
import 'comprovativo.dart';

/// Tela 1 — Painel "Estás em dia?" (a tela de todos os dias).
///
/// Saudação + etiqueta do plano · **cartão de ação** (o que fazer agora) ·
/// semáforo grande · cartão-herói "Próximo prazo" (MEI Fácil) · "Este mês
/// pagas" · "Guardar para o IRS" · Vigia do IVA compacta · frase humana.
/// Só o semáforo pode ser laranja cheio.
class PainelScreen extends StatefulWidget {
  /// Dia de referência (testes/fotos). Na app é sempre `hojeLisboa()`.
  final DateTime? hoje;
  const PainelScreen({super.key, this.hoje});

  @override
  State<PainelScreen> createState() => _PainelScreenState();
}

class _PainelScreenState extends State<PainelScreen> {
  @override
  void initState() {
    super.initState();
    ligarPhotoPickerAndroid();
  }

  Future<void> _recarregar() async {
    final perfilStore = context.read<PerfilStore>();
    final userId = perfilStore.perfil?.userId;
    if (userId == null) return;
    final plano = context.read<PlanoStore>();
    final obrig = context.read<ObrigacoesStore>();
    final rend = context.read<RendimentosStore>();
    await Future.wait([
      perfilStore.carregar(userId),
      plano.carregar(userId),
      obrig.carregar(userId),
      rend.carregar(userId),
    ]);
  }

  Future<void> _jaPaguei(ObrigacaoItem o) async {
    final l = AppLocalizations.of(context);
    final obrig = context.read<ObrigacoesStore>();
    final mensageiro = ScaffoldMessenger.of(context);
    final ok = await obrig.marcarPaga(o);
    if (!mounted) return;
    if (!ok) {
      mensageiro.showSnackBar(SnackBar(content: Text(l.painelPagoErro)));
      return;
    }
    mensageiro.showSnackBar(SnackBar(content: Text(l.painelPagoOk)));
    await perguntarComprovativo(context, obrigacao: o);
  }

  /// O botão do cartão de ação: abre o detalhe da obrigação, que é onde
  /// estão todas as coisas que se podem fazer com ela (como pagar, já
  /// paguei, juntar comprovativo).
  Future<void> _abrirDetalhe(ObrigacaoItem o, DateTime hoje) =>
      mostrarDetalheObrigacao(context, obrigacao: o, hoje: hoje);

  /// Quando não há nada a pagar, a única coisa útil que sobra é dizer quanto
  /// se ganhou este mês — é desse número que saem as contas todas.
  void _abrirRecibos() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecibosScreen(hoje: widget.hoje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final obrig = context.watch<ObrigacoesStore>();
    final rend = context.watch<RendimentosStore>();
    final perfil = context.watch<PerfilStore>().perfil;
    final plano = context.watch<PlanoStore>();
    final regras = context.watch<RegrasStore>().regras;
    final hoje = widget.hoje ?? hojeLisboa();

    final aCarregarPrimeira = obrig.aCarregar && obrig.itens.isEmpty;
    final erroSemDados = !obrig.aCarregar && obrig.erro != null && obrig.itens.isEmpty;
    final estado = _EstadoPainel.calcular(obrig, hoje);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _recarregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: paddingEcra,
            children: [
              _Cabecalho(perfil: perfil, plano: plano),
              const SizedBox(height: 16),
              if (aCarregarPrimeira)
                const SkeletonPainel()
              else if (erroSemDados) ...[
                Aviso(l.erroRede, tom: Semaforo.vermelho, icone: Icons.wifi_off_rounded),
                const SizedBox(height: 12),
                BotaoGrande(texto: l.painelTentarOutraVez, secundario: true, aoTocar: _recarregar),
              ] else ...[
                if (obrig.erro != null) ...[
                  Aviso(l.erroRede, tom: Semaforo.vermelho, icone: Icons.wifi_off_rounded),
                  const SizedBox(height: 12),
                ],
                // Em cima de tudo: UMA ação clara. O resto do painel explica
                // o estado; este cartão diz o que fazer a seguir.
                CartaoAcao(
                  item: estado.heroi,
                  hoje: hoje,
                  aoAgir: estado.heroi == null ? null : () => _abrirDetalhe(estado.heroi!, hoje),
                  // O "já paguei" vem com a ação: era o único botão que o
                  // cartão de baixo tinha e este não, e é o que se carrega
                  // mais vezes.
                  aoJaPaguei: estado.heroi == null ? null : () => _jaPaguei(estado.heroi!),
                  aoRegistarRendimento:
                      estado.heroi == null && _temAtividade(perfil) && rend.doMes(hoje.year, hoje.month) == null
                          ? _abrirRecibos
                          : null,
                ),
                const SizedBox(height: 12),
                SemaforoGrande(
                  estado: estado.semaforo,
                  titulo: estado.titulo(l),
                  subtitulo: estado.subtitulo(l),
                ),
                // O cartão do próximo prazo só aparece quando NÃO é a mesma
                // coisa que o cartão de ação lá em cima. Com um prazo passado,
                // o de cima mostra a dívida antiga e este mostra o que vem a
                // seguir — são duas coisas diferentes e valem as duas. Quando
                // coincidem, repetir o mesmo nome, o mesmo valor e a mesma data
                // três vezes no mesmo ecrã só cansa a vista.
                if (estado.proximoDepoisDaAcao != null) ...[
                  const SizedBox(height: 12),
                  CartaoHeroi(
                    item: estado.proximoDepoisDaAcao,
                    hoje: hoje,
                    aoJaPaguei: () => _jaPaguei(estado.proximoDepoisDaAcao!),
                    aoComoPagar: () => mostrarComoPagar(context, estado.proximoDepoisDaAcao!),
                  ),
                ],
                const SizedBox(height: 12),
                CartaoEsteMes(itens: estado.pagamentosDoMes, hoje: hoje),
                const SizedBox(height: 12),
                CartaoIrs(
                  provisao: _provisaoIrs(perfil, rend, regras, hoje),
                  minimoExistencia: regras.n('irs_minimo_existencia'),
                ),
                if (_temAtividade(perfil)) ...[
                  const SizedBox(height: 12),
                  CartaoVigiaIva(vigia: vigiaIva(acumuladoAno: rend.totalDoAno(hoje.year), r: regras)),
                ],
                const SizedBox(height: 20),
                Text(
                  estado.fraseHumana(l),
                  textAlign: TextAlign.center,
                  style: t.bodyMedium!.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _temAtividade(Perfil? p) =>
      p != null && p.tipoAtividade != TipoAtividade.semAtividade && p.tipoAtividade != TipoAtividade.soCarro;

  /// Rendimento = média dos últimos meses registados; se não há registos,
  /// a estimativa do onboarding. Sem nada → null (o cartão pede o número).
  ProvisaoIrs? _provisaoIrs(Perfil? p, RendimentosStore rend, RegrasLegais r, DateTime hoje) {
    final mensal = rend.mediaMensal() ?? p?.rendimentoMensalEstimado;
    if (mensal == null || mensal <= 0) return null;
    return calcularIrs(
      rendimentoBrutoAnual: centimos(mensal * 12),
      tipo: p?.tipoRendimento ?? TipoRendimento.servicos,
      ano: hoje.year,
      r: r,
    );
  }
}

/// Saudação humana + etiqueta do plano (trial / grátis / Pro / Família).
class _Cabecalho extends StatelessWidget {
  final Perfil? perfil;
  final PlanoStore plano;
  const _Cabecalho({required this.perfil, required this.plano});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final nome = perfil?.nome?.trim() ?? '';
    final primeiro = nome.isEmpty ? '' : nome.split(RegExp(r'\s+')).first;

    final emTrial = plano.carregado ? plano.emTrial : (perfil?.emTrial ?? false);
    final planoNome = plano.carregado ? plano.planoEfetivo : (perfil?.plano ?? 'free');
    final Widget etiqueta;
    if (emTrial && perfil != null) {
      final d = perfil!.trialAte;
      final ddmm = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
      etiqueta = Etiqueta(l.painelEtiquetaTrial(ddmm),
          cor: AppColors.emDiaClaro, corTexto: AppColors.primaryDark, icone: Icons.card_giftcard_rounded);
    } else if (planoNome == 'pro') {
      etiqueta = Etiqueta(l.painelEtiquetaPro,
          cor: AppColors.cadeadoClaro, corTexto: AppColors.cadeado, icone: Icons.workspace_premium_rounded);
    } else if (planoNome == 'familia') {
      etiqueta = Etiqueta(l.painelEtiquetaFamilia,
          cor: AppColors.cadeadoClaro, corTexto: AppColors.cadeado, icone: Icons.groups_rounded);
    } else {
      etiqueta = Etiqueta(l.painelEtiquetaFree, cor: AppColors.surface2, corTexto: AppColors.textSecondary);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(primeiro.isEmpty ? l.painelOlaSemNome : l.painelOla(primeiro),
                  style: t.headlineLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(l.painelPergunta, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(padding: const EdgeInsets.only(top: 6), child: etiqueta),
      ],
    );
  }
}

/// O que o painel deduz das obrigações (calculado uma vez por build).
class _EstadoPainel {
  final Semaforo semaforo;
  final List<ObrigacaoItem> passadas;
  final List<ObrigacaoItem> aVencer;
  final ObrigacaoItem? heroi;

  /// A próxima a vencer, seja ela qual for. Guardada à parte do herói porque
  /// com um prazo passado as duas são coisas diferentes: o herói é a dívida
  /// antiga, esta é a que vem a seguir.
  final ObrigacaoItem? proxima;
  final List<ObrigacaoItem> pagamentosDoMes;
  final DateTime hoje;

  const _EstadoPainel({
    required this.semaforo,
    required this.passadas,
    required this.aVencer,
    required this.heroi,
    required this.proxima,
    required this.pagamentosDoMes,
    required this.hoje,
  });

  factory _EstadoPainel.calcular(ObrigacoesStore obrig, DateTime hoje) {
    final passadas = obrig.passadas(hoje);
    final aVencer = obrig.aVencer(hoje);
    final semaforo = passadas.isNotEmpty
        ? Semaforo.vermelho
        : aVencer.isNotEmpty
            ? Semaforo.amarelo
            : Semaforo.verde;
    // O herói é o mais urgente: uma passada, senão a próxima a vencer.
    final proxima = obrig.proxima(hoje);
    final heroi = passadas.isNotEmpty ? passadas.first : proxima;
    final doMes = obrig.doMes(hoje).where((o) => o.ehPagamento).toList();
    return _EstadoPainel(
      semaforo: semaforo,
      passadas: passadas,
      aVencer: aVencer,
      heroi: heroi,
      proxima: proxima,
      pagamentosDoMes: doMes,
      hoje: hoje,
    );
  }

  /// O prazo A SEGUIR ao que está no cartão de ação.
  ///
  /// O cartão de ação já mostra o mais urgente, com o valor grande e o botão.
  /// Repetir a mesma obrigação logo por baixo, com o mesmo nome, o mesmo valor
  /// e a mesma data, não acrescentava nada — só empurrava o resto do painel
  /// para fora do ecrã. Este cartão passa a responder a outra pergunta:
  /// **e depois desta, o que vem?**
  ///
  /// `null` quando não há mais nada — e aí não se desenha cartão nenhum, em vez
  /// de um cartão vazio a dizer que está vazio.
  ObrigacaoItem? get proximoDepoisDaAcao {
    final id = heroi?.id;
    for (final o in _pendentesPorData) {
      if (o.id != id) return o;
    }
    return null;
  }

  List<ObrigacaoItem> get _pendentesPorData =>
      [...passadas, ...aVencer, if (proxima != null) proxima!]
          .fold<Map<String, ObrigacaoItem>>({}, (m, o) => m..putIfAbsent(o.id, () => o))
          .values
          .toList()
        ..sort((a, b) => a.dataLimite.compareTo(b.dataLimite));

  int get _diasMinimos => aVencer.map((o) => o.diasParaPrazo(hoje)).fold(999, (m, d) => d < m ? d : m);

  String titulo(AppLocalizations l) {
    switch (semaforo) {
      case Semaforo.vermelho:
        final n = passadas.length;
        return n == 1 ? l.semaforoVermelhoUma : l.semaforoVermelhoVarias(n);
      case Semaforo.amarelo:
        final n = aVencer.length;
        final dias = _diasMinimos;
        if (dias <= 0) return n == 1 ? l.painelSemaforoAmareloHojeUma : l.painelSemaforoAmareloHojeVarias(n);
        if (dias == 1) return n == 1 ? l.painelSemaforoAmareloAmanhaUma : l.painelSemaforoAmareloAmanhaVarias(n);
        return n == 1 ? l.semaforoAmareloUma(dias) : l.semaforoAmareloVarias(n, dias);
      case Semaforo.verde:
        return l.semaforoVerde;
    }
  }

  /// O nome e o valor da coisa mais urgente passaram para o cartão de ação,
  /// que está agora em cima. Repeti-los aqui era dizer a mesma coisa duas
  /// vezes no mesmo ecrã, por isso o semáforo fica só com o título — e com a
  /// frase de descanso quando está tudo verde.
  String? subtitulo(AppLocalizations l) =>
      semaforo == Semaforo.verde ? l.painelSemaforoVerdeSub : null;

  String fraseHumana(AppLocalizations l) => switch (semaforo) {
        Semaforo.verde => l.fraseHumanaVerde,
        Semaforo.amarelo => l.fraseHumanaAmarelo,
        Semaforo.vermelho => l.fraseHumanaVermelho,
      };
}
