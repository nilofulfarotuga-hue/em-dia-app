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
import 'cartao_heroi.dart';
import 'cartoes_painel.dart';
import 'comprovativo.dart';

/// Tela 1 — Painel "Estás em dia?" (a tela de todos os dias).
///
/// Saudação + etiqueta do plano · semáforo grande · cartão-herói "Próximo
/// prazo" (MEI Fácil) · "Este mês pagas" · "Guardar para o IRS" · Vigia do
/// IVA compacta · frase humana. Só o semáforo pode ser laranja.
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
                SemaforoGrande(
                  estado: estado.semaforo,
                  titulo: estado.titulo(l),
                  subtitulo: estado.subtitulo(l),
                ),
                const SizedBox(height: 12),
                CartaoHeroi(
                  item: estado.heroi,
                  hoje: hoje,
                  aoJaPaguei: estado.heroi == null ? null : () => _jaPaguei(estado.heroi!),
                  aoComoPagar: estado.heroi == null ? null : () => mostrarComoPagar(context, estado.heroi!),
                ),
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
  final List<ObrigacaoItem> pagamentosDoMes;
  final DateTime hoje;

  const _EstadoPainel({
    required this.semaforo,
    required this.passadas,
    required this.aVencer,
    required this.heroi,
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
    final heroi = passadas.isNotEmpty ? passadas.first : obrig.proxima(hoje);
    final doMes = obrig.doMes(hoje).where((o) => o.ehPagamento).toList();
    return _EstadoPainel(
      semaforo: semaforo,
      passadas: passadas,
      aVencer: aVencer,
      heroi: heroi,
      pagamentosDoMes: doMes,
      hoje: hoje,
    );
  }

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

  String? subtitulo(AppLocalizations l) {
    if (semaforo == Semaforo.verde) return l.painelSemaforoVerdeSub;
    final o = heroi;
    if (o == null) return null;
    final nome = nomeHumano(l, o);
    return o.valorEstimado == null ? nome : '$nome · ${moeda(o.valorEstimado!)}';
  }

  String fraseHumana(AppLocalizations l) => switch (semaforo) {
        Semaforo.verde => l.fraseHumanaVerde,
        Semaforo.amarelo => l.fraseHumanaAmarelo,
        Semaforo.vermelho => l.fraseHumanaVermelho,
      };
}
