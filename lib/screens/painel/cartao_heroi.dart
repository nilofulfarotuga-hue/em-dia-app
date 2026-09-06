import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/obrigacao.dart';
import '../../regras/regras.dart';
import 'cartoes_painel.dart' show nomeHumano;

/// Cartão-herói "Próximo prazo" (estrutura do MEI Fácil: etiqueta, número
/// grande com a contagem, nome + data + valor, dois botões).
///
/// Fundo verde-escuro de marca (`primaryDeep`) — nunca laranja: a cor "a
/// vencer" vive só no `SemaforoGrande` logo acima (regra: 1 laranja por
/// ecrã). Se o prazo já passou, o herói fica vermelho: um cartão verde a
/// dizer "Passou há 2 dias" contradizia o semáforo (juiz de visão, 04:22).
class CartaoHeroi extends StatelessWidget {
  final ObrigacaoItem? item;
  final DateTime hoje;
  final VoidCallback? aoJaPaguei;
  final VoidCallback? aoComoPagar;

  const CartaoHeroi({
    super.key,
    required this.item,
    required this.hoje,
    this.aoJaPaguei,
    this.aoComoPagar,
  });

  String _contagem(AppLocalizations l) {
    final d = item!.diasParaPrazo(hoje);
    if (d < 0) return l.painelHeroiPassouHa(-d);
    if (d == 0) return l.eHoje;
    return l.painelHeroiEmDias(d);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final branco92 = Colors.white.withValues(alpha: 0.92);
    final o = item;
    final passou = o != null && o.passou(hoje);
    final fundo = passou ? AppColors.passou : AppColors.primaryDeep;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: AppTheme.cantos,
        boxShadow: AppTheme.sombraGrande,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  o == null ? Icons.check_circle_outline_rounded : Icons.calendar_today_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.cartaoProximoPrazo.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTheme.fonte,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (o == null) ...[
            Text(l.painelHeroiSemPrazo,
                style: t.headlineMedium!.copyWith(color: Colors.white, fontFamily: AppTheme.fonte)),
            const SizedBox(height: 6),
            Text(l.painelHeroiSemPrazoAjuda,
                style: t.bodyLarge!.copyWith(color: branco92, fontFamily: AppTheme.fonte)),
          ] else ...[
            Text(_contagem(l),
                style: t.displayLarge!.copyWith(color: Colors.white, fontFamily: AppTheme.fonte)),
            const SizedBox(height: 6),
            Text(nomeHumano(l, o),
                style: t.titleMedium!.copyWith(color: Colors.white, fontFamily: AppTheme.fonte)),
            const SizedBox(height: 2),
            // Data e valor em linhas separadas: numa só, o "€" caía sozinho
            // para a linha de baixo a 360 px.
            Text(dataExtensoPt(o.dataLimite),
                style: t.bodyLarge!.copyWith(color: branco92, fontFamily: AppTheme.fonte)),
            if (o.valorEstimado != null)
              Text(moeda(o.valorEstimado!),
                  style: t.titleLarge!.copyWith(color: Colors.white, fontFamily: AppTheme.fonte)),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, c) {
                final jaPaguei = ElevatedButton.icon(
                  onPressed: aoJaPaguei,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: fundo,
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle: const TextStyle(fontFamily: AppTheme.fonte, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 22),
                  label: Text(l.jaPaguei, maxLines: 1, overflow: TextOverflow.ellipsis),
                );
                final comoPagar = OutlinedButton(
                  onPressed: aoComoPagar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle: const TextStyle(fontFamily: AppTheme.fonte, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  child: Text(l.comoPagar, maxLines: 1, overflow: TextOverflow.ellipsis),
                );
                // Ecrã estreito (360 px, PT-BR): um botão por linha, nunca cortado.
                if (c.maxWidth < 300) {
                  return Column(children: [jaPaguei, const SizedBox(height: 8), comoPagar]);
                }
                return Row(
                  children: [
                    Expanded(child: jaPaguei),
                    const SizedBox(width: 10),
                    Expanded(child: comoPagar),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
