import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import 'recibos_widgets.dart';

const String _urlPortal = 'https://www.portaldasfinancas.gov.pt';

/// "Como emitir o recibo": passos numerados no Portal das Finanças, textos
/// prontos a copiar e botão que abre o portal. As capturas reais ficam para
/// o bloco 6 — por agora um lugar marcado "captura em breve".
class ComoEmitirScreen extends StatelessWidget {
  final bool isentoIva;
  final String descricaoSugerida;
  final String mencaoIsencao;

  /// Quem é o cliente do recibo, no ofício dele (plataforma, dono da casa,
  /// empresa…). Opcional: sem ofício conhecido o passo fica como estava.
  final String? exemploCliente;
  const ComoEmitirScreen({
    super.key,
    required this.isentoIva,
    required this.descricaoSugerida,
    required this.mencaoIsencao,
    this.exemploCliente,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final passos = <_Passo>[
      _Passo(l.emitirPasso1),
      _Passo(l.emitirPasso2, captura: true),
      _Passo(l.emitirPasso3),
      _Passo(l.emitirPasso4, nota: exemploCliente),
      _Passo(l.emitirPasso5, copiar: descricaoSugerida),
      _Passo(l.emitirPasso6),
      if (isentoIva) _Passo(l.emitirPasso7Isento, copiar: mencaoIsencao, captura: true) else _Passo(l.emitirPasso7Normal),
      _Passo(l.emitirPasso8),
    ];
    // O passo a passo inteiro numa só voz: quem está a fazer o recibo no
    // computador ouve os passos sem tirar os olhos do Portal das Finanças.
    final falado = [
      l.emitirTitulo,
      l.emitirSubtitulo,
      for (final passo in passos)
        passo.nota == null ? passo.texto : '${passo.texto} ${passo.nota}',
    ].join(' ');

    return Scaffold(
      appBar: AppBar(title: Text(l.emitirTitulo)),
      body: ListView(
        padding: paddingEcra,
        children: [
          Text(l.emitirSubtitulo, style: t.bodyLarge),
          BotaoOuvir(etiqueta: 'recibos-como-emitir', texto: falado),
          const SizedBox(height: 16),
          for (var i = 0; i < passos.length; i++) ...[
            _CartaoPasso(numero: i + 1, passo: passos[i]),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          BotaoGrande(texto: l.emitirAbrirPortal, icone: Icons.open_in_new_rounded, aoTocar: () => _abrirPortal(context)),
        ],
      ),
    );
  }

  Future<void> _abrirPortal(BuildContext context) async {
    final l = AppLocalizations.of(context);
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(_urlPortal), mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.emitirNaoAbriu)));
    }
  }
}

class _Passo {
  final String texto;
  final String? copiar;
  final bool captura;

  /// Frase extra que muda com o ofício (ex.: quem é o cliente).
  final String? nota;
  const _Passo(this.texto, {this.copiar, this.captura = false, this.nota});
}

class _CartaoPasso extends StatelessWidget {
  final int numero;
  final _Passo passo;
  const _CartaoPasso({required this.numero, required this.passo});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Cartao(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Text('$numero', style: t.titleSmall!.copyWith(color: AppColors.primaryDeep)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(passo.texto, style: t.bodyMedium),
                ),
                if (passo.nota != null) ...[
                  const SizedBox(height: 10),
                  NotaInfo(passo.nota!),
                ],
                if (passo.copiar != null) ...[
                  const SizedBox(height: 10),
                  CaixaCopiar(texto: passo.copiar!),
                ],
                if (passo.captura) ...[
                  const SizedBox(height: 10),
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: AppTheme.cantosPequenos,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_outlined, size: 32, color: AppColors.textSubtle),
                        const SizedBox(height: 6),
                        Text(l.emitirCapturaBreve, style: t.bodySmall),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
