import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';

/// O cartão «Passar a fatura-recibo daqui» (B2b). Vive num ficheiro à parte
/// para a foto do golden o apanhar sozinho, sem ligar o interruptor.
class CartaoPassarFatura extends StatelessWidget {
  final VoidCallback aoTocar;
  const CartaoPassarFatura({super.key, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Cartao(
      key: const Key('passar_fatura_card'),
      aoTocar: aoTocar,
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: AppColors.primaryDark, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.faturaCartaoTitulo, style: t.titleMedium),
                const SizedBox(height: 2),
                Text(l.faturaCartaoSub, style: t.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle),
        ],
      ),
    );
  }
}
