import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/fala.dart';
import '../stores/perfil_store.dart';

/// O botão de ouvir, para pôr ao lado de qualquer explicação da app.
///
/// Regra da casa: toda a explicação escrita tem um destes. Muita gente que usa
/// o Em Dia prefere ouvir a ler.
///
/// Usa-se assim:
/// ```dart
/// BotaoOuvir(etiqueta: 'painel-acao', texto: 'Este mês pagas 269,64 €…')
/// ```
/// A [etiqueta] tem de ser diferente em cada sítio: é por ela que o botão sabe
/// se é ele que está a falar, quando há vários no mesmo ecrã.
class BotaoOuvir extends StatelessWidget {
  final String etiqueta;
  final String texto;

  /// `true` mostra só o altifalante, sem a palavra "Ouvir" — para cantos
  /// apertados, como o canto de um cartão.
  final bool soIcone;

  const BotaoOuvir({
    super.key,
    required this.etiqueta,
    required this.texto,
    this.soIcone = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fala = context.watch<Fala>();
    final aFalar = fala.estaAFalar(etiqueta);
    final vazio = texto.trim().isEmpty;
    final rotulo = aFalar ? l.guiasParar : l.guiasOuvir;

    Future<void> tocar() async {
      final mensageiro = ScaffoldMessenger.of(context);
      final erro = l.guiasOuvirErro;
      final variante = context.read<PerfilStore>().perfil?.variantePt ??
          (Localizations.localeOf(context).countryCode == 'BR' ? 'br' : 'pt');
      final ok = await fala.ler(etiqueta, texto, variante: variante);
      if (!ok) mensageiro.showSnackBar(SnackBar(content: Text(erro)));
    }

    if (soIcone) {
      return IconButton(
        key: Key('ouvir_$etiqueta'),
        onPressed: vazio ? null : tocar,
        tooltip: rotulo,
        color: AppColors.textSecondary,
        icon: Icon(aFalar ? Icons.stop_circle_rounded : Icons.volume_up_rounded),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        key: Key('ouvir_$etiqueta'),
        onPressed: vazio ? null : tocar,
        icon: Icon(aFalar ? Icons.stop_rounded : Icons.volume_up_rounded, size: 20),
        label: Text(rotulo),
      ),
    );
  }
}
