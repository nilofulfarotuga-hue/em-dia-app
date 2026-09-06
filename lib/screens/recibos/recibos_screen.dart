import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/perfil.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../widgets/widgets.dart';
import 'calculadora_recibo.dart';
import 'como_emitir_screen.dart';
import 'irs_card.dart';
import 'recibos_widgets.dart';
import 'rendimentos_seccao.dart';
import 'seguranca_social_card.dart';
import 'vigia_iva_card.dart';

/// Tela 2 — Recibos verdes. Secções: calculadora (aberta no topo),
/// rendimentos, Vigia do IVA, Segurança Social, IRS, como emitir o recibo.
/// Todos os números vêm de `lib/regras/` com as regras da [RegrasStore].
class RecibosScreen extends StatelessWidget {
  /// Data de referência (Lisboa). Nas fotos passa-se uma data fixa.
  final DateTime? hoje;
  const RecibosScreen({super.key, this.hoje});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final regras = context.watch<RegrasStore>().regras;
    final perfil = context.watch<PerfilStore>().perfil;
    final rend = context.watch<RendimentosStore>();
    final h = hoje ?? hojeLisboa();
    final semAtividade = perfil == null ||
        perfil.tipoAtividade == TipoAtividade.semAtividade ||
        perfil.tipoAtividade == TipoAtividade.soCarro;
    final isento = perfil?.regimeIva != RegimeIva.normal;

    return Scaffold(
      appBar: AppBar(title: Text(l.recibosTitulo)),
      body: ListView(
        padding: paddingEcra,
        children: [
          CalculadoraRecibo(
            regras: regras,
            perfil: perfil,
            faturacaoAnoAnterior: rend.totalDoAno(h.year - 1),
          ),
          const SizedBox(height: 12),
          RendimentosSeccao(hoje: h),
          const SizedBox(height: 12),
          VigiaIvaCard(regras: regras, acumuladoAno: rend.totalDoAno(h.year), temDados: rend.itens.isNotEmpty),
          const SizedBox(height: 12),
          if (semAtividade)
            Cartao(key: const Key('ss_card'), child: NotaInfo(l.ssSemAtividade))
          else ...[
            KeyedSubtree(
              key: const Key('ss_card'),
              child: SegurancaSocialCard(regras: regras, perfil: perfil, rendimentos: rend, hoje: h),
            ),
            const SizedBox(height: 12),
            KeyedSubtree(
              key: const Key('irs_card'),
              child: IrsCard(regras: regras, perfil: perfil, rendimentos: rend, hoje: h),
            ),
          ],
          const SizedBox(height: 12),
          Cartao(
            key: const Key('emitir_card'),
            aoTocar: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => ComoEmitirScreen(
                isentoIva: isento,
                descricaoSugerida: _descricao(l, perfil),
                mencaoIsencao: regras.txt('iva_mencao_isencao'),
              ),
            )),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: AppColors.primaryDark, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.emitirTitulo, style: t.titleMedium),
                      const SizedBox(height: 2),
                      Text(l.emitirSubtitulo, style: t.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static String _descricao(AppLocalizations l, Perfil? p) => switch (p?.tipoAtividade) {
        TipoAtividade.tvde => l.emitirDescricaoTvde,
        TipoAtividade.estafeta => l.emitirDescricaoEstafeta,
        _ => l.emitirDescricaoServicos,
      };
}
