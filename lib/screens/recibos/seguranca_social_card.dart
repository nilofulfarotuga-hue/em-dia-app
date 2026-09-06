import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/perfil.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../stores/perfil_store.dart';
import '../../widgets/widgets.dart';
import 'recibos_widgets.dart';

/// Segurança Social: isenção do 1.º ano (contagem regressiva) ou a
/// declaração trimestral + quanto pagas por mês, com o ajuste ±25%.
class SegurancaSocialCard extends StatelessWidget {
  final RegrasLegais regras;
  final Perfil perfil;
  final RendimentosStore rendimentos;
  final DateTime hoje;
  const SegurancaSocialCard({
    super.key,
    required this.regras,
    required this.perfil,
    required this.rendimentos,
    required this.hoje,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final r = regras;
    final abertura = perfil.dataAbertura;

    final Widget corpo;
    if (abertura == null) {
      corpo = NotaInfo(l.ssSemDataAbertura);
    } else if (mesesDeIsencaoRestantes(abertura, hoje, r) > 0) {
      final meses = mesesDeIsencaoRestantes(abertura, hoje, r);
      final ultimo = ultimoDiaIsencaoSS(abertura, r);
      final mensal = _rendimentoMensalEstimado();
      corpo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CaixaDestaque(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.ssIsencaoFaltam(meses), style: t.headlineSmall!.copyWith(color: AppColors.primaryDeep)),
                const SizedBox(height: 4),
                Text(l.ssIsencaoAte(dataExtensoPt(ultimo)), style: t.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(l.ssIsencaoExplica, style: t.bodySmall),
          if (mensal != null && mensal > 0) ...[
            const SizedBox(height: 12),
            Text(
              l.ssAvisoAntes(
                r.n('ss_aviso_fim_isencao_dias').toInt(),
                moeda(estimarSSMensal(rendimentoMensal: mensal, tipo: perfil.tipoRendimento, ajustePct: perfil.ajusteSsPct, r: r)
                    .contribuicaoMensal),
              ),
              style: t.bodyMedium,
            ),
          ],
        ],
      );
    } else {
      final decl = _proximaDeclaracao(abertura);
      final (contrib, base, estimativa) = _contribuicao(l);
      corpo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.ssDeclararEm(nomeMes(decl.month)), style: t.titleMedium),
          const SizedBox(height: 10),
          CaixaDestaque(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.ssPagaPorMes(moeda(contrib.contribuicaoMensal)),
                    style: t.headlineSmall!.copyWith(color: AppColors.primaryDeep)),
                if (estimativa) ...[
                  const SizedBox(height: 6),
                  Etiqueta(l.etiquetaEstimativa, cor: AppColors.surface2, corTexto: AppColors.textSecondary),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(base, style: t.bodySmall),
          if (contrib.bateuNoMinimo) ...[
            const SizedBox(height: 4),
            Text(l.ssMinimo(moeda(r.n('ss_minimo_mensal'))), style: t.bodySmall),
          ],
          if (perfil.ajusteSsPct != 0) ...[
            const SizedBox(height: 4),
            Text(l.ssAjusteAtual(_rotuloAjuste(l, perfil.ajusteSsPct)), style: t.bodySmall),
          ],
          const SizedBox(height: 14),
          BotaoGrande(
            texto: l.ssAjustar,
            secundario: true,
            icone: Icons.tune_rounded,
            aoTocar: () => _abrirAjuste(context),
          ),
          const SizedBox(height: 6),
          Text(l.ssAjustarAjuda, style: t.bodySmall),
        ],
      );
    }

    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabecalhoCartao(icone: Icons.health_and_safety_rounded, titulo: l.ssTitulo),
          const SizedBox(height: 12),
          corpo,
        ],
      ),
    );
  }

  double? _rendimentoMensalEstimado() => perfil.rendimentoMensalEstimado ?? rendimentos.mediaMensal();

  /// Próximo mês de declaração (jan/abr/jul/out) — nunca antes da primeira
  /// declaração depois da isenção.
  DateTime _proximaDeclaracao(DateTime abertura) {
    final meses = (regras.json('ss_declaracao_meses') as List).cast<num>().map((e) => e.toInt()).toList()..sort();
    DateTime proxima = DateTime(hoje.year + 1, meses.first, 1);
    for (final m in meses) {
      if (m >= hoje.month) {
        proxima = DateTime(hoje.year, m, 1);
        break;
      }
    }
    final primeira = primeiraDeclaracaoTrimestral(abertura, regras);
    return primeira.isAfter(proxima) ? primeira : proxima;
  }

  /// Contribuição a mostrar: pelo trimestre anterior se houver registos;
  /// senão pela estimativa mensal (perfil ou média); senão o mínimo.
  (ContribuicaoSS, String, bool) _contribuicao(AppLocalizations l) {
    final trimestreAtual = ((hoje.month - 1) ~/ 3) + 1;
    final anoAnterior = trimestreAtual == 1 ? hoje.year - 1 : hoje.year;
    final trimestreAnterior = trimestreAtual == 1 ? 4 : trimestreAtual - 1;
    final total = rendimentos.totalTrimestre(anoAnterior, trimestreAnterior);
    if (total > 0) {
      final inicio = (trimestreAnterior - 1) * 3 + 1;
      final c = calcularSS(rendimentoTrimestre: total, tipo: perfil.tipoRendimento, ajustePct: perfil.ajusteSsPct, r: regras);
      return (c, l.ssBaseTrimestre(nomeMes(inicio), nomeMes(inicio + 2), moeda(total)), false);
    }
    final mensal = _rendimentoMensalEstimado();
    if (mensal != null && mensal > 0) {
      final c = estimarSSMensal(rendimentoMensal: mensal, tipo: perfil.tipoRendimento, ajustePct: perfil.ajusteSsPct, r: regras);
      return (c, l.ssBaseEstimativa(moeda(mensal)), true);
    }
    final c = calcularSS(rendimentoTrimestre: 0, tipo: perfil.tipoRendimento, ajustePct: perfil.ajusteSsPct, r: regras);
    return (c, l.ssSemDados, true);
  }

  static String _rotuloAjuste(AppLocalizations l, int pct) {
    if (pct == 0) return l.ssAjusteNormal;
    return pct < 0 ? l.ssAjusteMenos(-pct) : l.ssAjusteMais(pct);
  }

  Future<void> _abrirAjuste(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final perfilStore = context.read<PerfilStore>();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AjusteSS(
        regras: regras,
        perfil: perfil,
        rendimentoTrimestre: _baseTrimestreParaAjuste(),
        guardar: (pct) => perfilStore.guardar(perfil.copyWith(ajusteSsPct: pct)),
      ),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.ssAjusteGuardado)));
    }
  }

  double _baseTrimestreParaAjuste() {
    final trimestreAtual = ((hoje.month - 1) ~/ 3) + 1;
    final anoAnterior = trimestreAtual == 1 ? hoje.year - 1 : hoje.year;
    final trimestreAnterior = trimestreAtual == 1 ? 4 : trimestreAtual - 1;
    final total = rendimentos.totalTrimestre(anoAnterior, trimestreAnterior);
    if (total > 0) return total;
    return (_rendimentoMensalEstimado() ?? 0) * 3;
  }
}

/// Seletor −25% … +25% em passos de 5, com o novo valor à vista.
class _AjusteSS extends StatefulWidget {
  final RegrasLegais regras;
  final Perfil perfil;
  final double rendimentoTrimestre;
  final Future<bool> Function(int pct) guardar;
  const _AjusteSS({required this.regras, required this.perfil, required this.rendimentoTrimestre, required this.guardar});

  @override
  State<_AjusteSS> createState() => _AjusteSSState();
}

class _AjusteSSState extends State<_AjusteSS> {
  late int _pct = widget.perfil.ajusteSsPct;
  bool _aGuardar = false;
  bool _erro = false;

  int get _max => widget.regras.n('ss_ajuste_max').toInt();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = calcularSS(
        rendimentoTrimestre: widget.rendimentoTrimestre, tipo: widget.perfil.tipoRendimento, ajustePct: _pct, r: widget.regras);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.ssAjustarTitulo, style: t.headlineSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              _BotaoPasso(icone: Icons.remove_rounded, ativo: _pct > -_max, aoTocar: () => setState(() => _pct -= 5)),
              Expanded(
                child: Text(
                  SegurancaSocialCard._rotuloAjuste(l, _pct),
                  textAlign: TextAlign.center,
                  style: t.headlineSmall!.copyWith(color: AppColors.primaryDeep),
                ),
              ),
              _BotaoPasso(icone: Icons.add_rounded, ativo: _pct < _max, aoTocar: () => setState(() => _pct += 5)),
            ],
          ),
          const SizedBox(height: 16),
          CaixaDestaque(
            child: Text(l.ssNovoValor(moeda(c.contribuicaoMensal)), style: t.titleMedium!.copyWith(color: AppColors.primaryDeep)),
          ),
          const SizedBox(height: 8),
          Text(l.ssAjustarAjuda, style: t.bodySmall),
          if (_erro) ...[
            const SizedBox(height: 12),
            Aviso(l.erroRede, tom: Semaforo.vermelho),
          ],
          const SizedBox(height: 16),
          BotaoGrande(texto: l.guardar, aTrabalhar: _aGuardar, aoTocar: _guardar),
        ],
      ),
    );
  }

  Future<void> _guardar() async {
    setState(() {
      _aGuardar = true;
      _erro = false;
    });
    final ok = await widget.guardar(_pct);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _aGuardar = false;
        _erro = true;
      });
    }
  }
}

class _BotaoPasso extends StatelessWidget {
  final IconData icone;
  final bool ativo;
  final VoidCallback aoTocar;
  const _BotaoPasso({required this.icone, required this.ativo, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: OutlinedButton(
        onPressed: ativo ? aoTocar : null,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(56, 56)),
        child: Icon(icone, size: 28),
      ),
    );
  }
}
