/// Widgets próprios da tela dos Recibos. Compõem os partilhados de
/// `lib/widgets/widgets.dart`; não os substituem.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Copia para a área de transferência e mostra "Copiado".
Future<void> copiarTexto(BuildContext context, String texto) async {
  final l = AppLocalizations.of(context);
  final mensageiro = ScaffoldMessenger.maybeOf(context);
  await Clipboard.setData(ClipboardData(text: texto));
  mensageiro?.showSnackBar(SnackBar(content: Text(l.calcCopiado)));
}

/// Nota azul (informação neutra). Não gasta o laranja do ecrã — o laranja é
/// só "a vencer".
class NotaInfo extends StatelessWidget {
  final String texto;
  final IconData icone;
  const NotaInfo(this.texto, {super.key, this.icone = Icons.info_outline_rounded});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.infoClaro, borderRadius: AppTheme.cantosPequenos),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: AppColors.info, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// Barra de progresso 12 px, cantos 6 (a barra da Vigia do IVA).
class BarraProgresso extends StatelessWidget {
  final double fracao; // 0..1
  final Color cor;
  const BarraProgresso({super.key, required this.fracao, required this.cor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: fracao.clamp(0.0, 1.0),
        minHeight: 12,
        color: cor,
        backgroundColor: AppColors.divider,
      ),
    );
  }
}

/// Caixa com um texto pronto a copiar e o botão "Copiar".
class CaixaCopiar extends StatelessWidget {
  final String texto;
  final String? titulo;
  const CaixaCopiar({super.key, required this.texto, this.titulo});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: AppTheme.cantosPequenos,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo != null) ...[
            Text(titulo!, style: t.bodySmall),
            const SizedBox(height: 4),
          ],
          SelectableText(texto, style: t.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => copiarTexto(context, texto),
              icon: const Icon(Icons.copy_rounded, size: 20),
              label: Text(l.calcCopiar),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de escolha com alvo de toque de 48 px.
class ChipEscolha extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback aoTocar;
  const ChipEscolha({super.key, required this.texto, required this.selecionado, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    // Pílula própria (não ChoiceChip): o texto QUEBRA linha em vez de ser
    // cortado em 360 px e em PT-BR.
    return Material(
      color: selecionado ? AppColors.primaryLight : AppColors.surface2,
      borderRadius: AppTheme.cantosPequenos,
      child: InkWell(
        borderRadius: AppTheme.cantosPequenos,
        onTap: aoTocar,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selecionado) ...[
                const Icon(Icons.check_rounded, size: 20, color: AppColors.primaryDeep),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  texto,
                  style: TextStyle(
                    fontFamily: AppTheme.fonte,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: selecionado ? AppColors.primaryDeep : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cabeçalho de um cartão de secção: ícone + título (18/700).
class CabecalhoCartao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final Widget? direita;
  const CabecalhoCartao({super.key, required this.icone, required this.titulo, this.direita});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, color: AppColors.primaryDark, size: 24),
        const SizedBox(width: 8),
        Expanded(child: Text(titulo, style: Theme.of(context).textTheme.titleLarge)),
        if (direita != null) direita!,
      ],
    );
  }
}

/// Caixa verde-clara com a frase/número principal da secção.
class CaixaDestaque extends StatelessWidget {
  final Widget child;
  const CaixaDestaque({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.primaryWash, borderRadius: AppTheme.cantosPequenos),
      child: child,
    );
  }
}
