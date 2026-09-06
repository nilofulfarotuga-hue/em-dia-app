import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/obrigacao.dart';
import '../../regras/regras.dart';
import '../../services/fala.dart';
import '../../stores/dados_store.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../widgets/widgets.dart';
import '../painel/comprovativo.dart' show juntarComprovativo, ligarPhotoPickerAndroid;
import 'tipos_obrigacao.dart';

/// Abre o detalhe de uma obrigação em bottom sheet. Os stores vão por
/// `.value` porque o sheet vive no Navigator de raiz (fora da árvore que os
/// tem, nas fotos e na app).
Future<void> mostrarDetalheObrigacao(
  BuildContext context, {
  required ObrigacaoItem obrigacao,
  required DateTime hoje,
}) {
  final obrig = context.read<ObrigacoesStore>();
  final plano = context.read<PlanoStore>();
  // O botão de ouvir precisa da voz e do perfil (é o perfil que diz se lê em
  // português de Portugal ou do Brasil) — e nesta folha eles não vêm de cima.
  final perfilStore = context.read<PerfilStore>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider<ObrigacoesStore>.value(value: obrig),
        ChangeNotifierProvider<PlanoStore>.value(value: plano),
        ChangeNotifierProvider<PerfilStore>.value(value: perfilStore),
        ChangeNotifierProvider<Fala>.value(value: Fala.instancia),
      ],
      child: DetalheObrigacao(inicial: obrigacao, hoje: hoje),
    ),
  );
}

/// Detalhe: data limite, "aviso-te a", valor (com "aproximado"), a regra que
/// a gerou, **Como pagar** com botão para o site, **Já paguei** (ou
/// desmarcar) e **Juntar comprovativo** (cadeado se o plano não deixar).
class DetalheObrigacao extends StatefulWidget {
  final ObrigacaoItem inicial;
  final DateTime hoje;
  const DetalheObrigacao({super.key, required this.inicial, required this.hoje});

  @override
  State<DetalheObrigacao> createState() => _DetalheObrigacaoState();
}

class _DetalheObrigacaoState extends State<DetalheObrigacao> {
  bool _aTrabalhar = false;

  @override
  void initState() {
    super.initState();
    ligarPhotoPickerAndroid();
  }

  Future<void> _marcar(ObrigacoesStore store, ObrigacaoItem o, {required bool paga}) async {
    final l = AppLocalizations.of(context);
    final msg = ScaffoldMessenger.of(context);
    setState(() => _aTrabalhar = true);
    final ok = paga ? await store.marcarPaga(o) : await store.desmarcarPaga(o);
    if (!mounted) return;
    setState(() => _aTrabalhar = false);
    msg.showSnackBar(SnackBar(content: Text(ok ? (paga ? l.calMarcadaPaga : l.calDesmarcada) : l.calErroGuardar)));
  }

  Future<void> _abrirSite(Uri url) async {
    final l = AppLocalizations.of(context);
    final msg = ScaffoldMessenger.of(context);
    var ok = false;
    try {
      ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && mounted) msg.showSnackBar(SnackBar(content: Text(l.calErroAbrirSite)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final store = context.watch<ObrigacoesStore>();
    final plano = context.watch<PlanoStore>();
    final o = store.itens.firstWhere((x) => x.id == widget.inicial.id, orElse: () => widget.inicial);
    final cor = corDaObrigacao(o, widget.hoje);
    final site = siteDoTipo(l, o.tipo);
    final regra = nomeDaRegra(l, o.origemRegra);
    final valor = o.valorEstimado;
    final podeComprovativo = plano.permitida('comprovativos_guardar');

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: cor.withValues(alpha: 0.14), shape: BoxShape.circle),
                child: Icon(o.pago ? Icons.check_rounded : iconeDoTipo(o.tipo), color: cor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.nomeCurto, style: t.headlineSmall),
                    const SizedBox(height: 6),
                    _Pilula(textoPrazo(l, o, widget.hoje), cor: cor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(o.descricao, style: t.bodyMedium),
          const SizedBox(height: 16),
          Cartao(
            cor: AppColors.surface2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                _Linha(icone: Icons.event_rounded, rotulo: l.calDataLimite, texto: dataExtensoPt(o.dataLimite)),
                _Linha(icone: Icons.notifications_active_outlined, texto: l.calAvisoEm(dataPt(o.avisoEm))),
                if (valor != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.euro_rounded, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 10),
                        Expanded(child: Text(l.calValorEstimado, style: t.bodySmall)),
                        if (valorEhAproximado(o)) ...[
                          _Pilula(l.calAproximado, cor: AppColors.info, clara: true),
                          const SizedBox(width: 8),
                        ],
                        Text(moeda(valor), style: t.titleLarge!.copyWith(color: AppColors.primaryDark)),
                      ],
                    ),
                  ),
                if (regra != null) _Linha(icone: Icons.info_outline_rounded, rotulo: l.calRegra, texto: regra),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(l.calComoPagar.toUpperCase(),
              style: const TextStyle(
                  fontFamily: AppTheme.fonte,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Cartao(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.payments_outlined, color: AppColors.info, size: 22),
                const SizedBox(width: 10),
                Expanded(child: Text(comoPagarDe(l, o), style: t.bodyMedium)),
              ],
            ),
          ),
          // Uma só voz para o detalhe todo: o que é, e como se paga.
          BotaoOuvir(
            etiqueta: 'calendario-como-pagar',
            texto: '${o.nomeCurto}. ${o.descricao} ${l.calComoPagar}. ${comoPagarDe(l, o)}',
          ),
          if (site != null) ...[
            const SizedBox(height: 10),
            BotaoGrande(
              texto: l.calAbrirSite(site.nome),
              icone: Icons.open_in_new_rounded,
              secundario: true,
              aoTocar: () => _abrirSite(site.url),
            ),
          ],
          const SizedBox(height: 18),
          if (!o.pago)
            BotaoGrande(
              texto: l.calJaPaguei,
              icone: Icons.check_rounded,
              aTrabalhar: _aTrabalhar,
              aoTocar: () => _marcar(store, o, paga: true),
            )
          else ...[
            Aviso(l.calPagoEm(dataPt(o.pagoEm ?? widget.hoje)), tom: Semaforo.verde, icone: Icons.check_circle_rounded),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _aTrabalhar ? null : () => _marcar(store, o, paga: false),
                child: Text(l.calDesmarcar),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Cadeado(
            trancado: !podeComprovativo,
            linha: l.calCadeadoComprovativo,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: podeComprovativo ? 0 : 16),
              child: BotaoGrande(
                texto: l.juntarComprovativo,
                icone: Icons.photo_camera_outlined,
                secundario: true,
                aoTocar: () => juntarComprovativo(context, o),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha "ícone · rótulo pequeno · texto" do cartão de dados.
class _Linha extends StatelessWidget {
  final IconData icone;
  final String? rotulo;
  final String texto;
  const _Linha({required this.icone, this.rotulo, required this.texto});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rotulo != null) Text(rotulo!, style: t.bodySmall),
                Text(texto, style: t.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pílula de estado (13 px, legível) — "faltam 6 dias", "aproximado".
class _Pilula extends StatelessWidget {
  final String texto;
  final Color cor;
  final bool clara;
  const _Pilula(this.texto, {required this.cor, this.clara = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: clara ? cor.withValues(alpha: 0.12) : cor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(texto,
          style: TextStyle(
              fontFamily: AppTheme.fonte,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: clara ? cor : Colors.white)),
    );
  }
}
