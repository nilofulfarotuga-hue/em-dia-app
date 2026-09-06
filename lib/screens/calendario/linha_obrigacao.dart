import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/obrigacao.dart';
import '../../regras/regras.dart';
import 'tipos_obrigacao.dart';

/// Linha de obrigação (Rocket Money / Drivvo): barra lateral de 4 px na cor
/// do estado, círculo com o ícone do tipo, nome curto, descrição,
/// "faltam N dias / é hoje / passou há N dias", valor à direita e check
/// verde quando está paga.
class LinhaObrigacao extends StatelessWidget {
  final ObrigacaoItem obrigacao;
  final DateTime hoje;
  final VoidCallback aoTocar;
  const LinhaObrigacao({super.key, required this.obrigacao, required this.hoje, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final o = obrigacao;
    final cor = corDaObrigacao(o, hoje);
    final valor = o.valorEstimado;

    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppTheme.cantos, boxShadow: AppTheme.sombraCartao),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppTheme.cantos,
          onTap: aoTocar,
          child: ClipRRect(
            borderRadius: AppTheme.cantos,
            child: Stack(
              children: [
                Positioned(left: 0, top: 0, bottom: 0, width: 4, child: ColoredBox(color: cor)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: o.pago ? AppColors.emDiaClaro : AppColors.surface2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(o.pago ? Icons.check_rounded : iconeDoTipo(o.tipo),
                            size: 22, color: o.pago ? AppColors.primaryDark : AppColors.textPrimary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.nomeCurto, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(o.descricao, style: t.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(textoPrazo(l, o, hoje),
                                style: TextStyle(
                                    fontFamily: AppTheme.fonte, fontSize: 13, fontWeight: FontWeight.w700, color: cor)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(valor == null ? '—' : moeda(valor),
                              style: t.titleMedium!.copyWith(color: o.pago ? AppColors.textSecondary : AppColors.textPrimary)),
                          if (o.pago) ...[
                            const SizedBox(height: 4),
                            const Icon(Icons.check_circle_rounded, color: AppColors.emDia, size: 20),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
