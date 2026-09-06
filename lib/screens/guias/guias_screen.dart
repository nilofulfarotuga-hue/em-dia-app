import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/guia.dart';
import '../../stores/guias_store.dart';
import '../../widgets/widgets.dart';
import 'guia_screen.dart';

/// Tela 6 — Guias de 1 minuto: a lista (tabela `guias`; sem rede, os 11
/// títulos locais). Toca num guia para o ler ou ouvir.
class GuiasScreen extends StatefulWidget {
  /// Store já carregada (testes e fotos). Sem ela, o ecrã cria a sua e carrega.
  final GuiasStore? store;
  const GuiasScreen({super.key, this.store});

  @override
  State<GuiasScreen> createState() => _GuiasScreenState();
}

class _GuiasScreenState extends State<GuiasScreen> {
  late final GuiasStore _store = widget.store ?? GuiasStore();

  @override
  void initState() {
    super.initState();
    if (widget.store == null) _store.carregar();
  }

  @override
  void dispose() {
    if (widget.store == null) _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GuiasStore>.value(
      value: _store,
      child: Consumer<GuiasStore>(builder: (context, s, _) => _Lista(store: s)),
    );
  }
}

class _Lista extends StatelessWidget {
  final GuiasStore store;
  const _Lista({required this.store});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final aCarregar = store.aCarregar && store.itens.isEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(l.guiasTitulo)),
      body: ListView(
        padding: paddingEcra,
        children: [
          Text(l.guiasSubtitulo, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          if (store.erro != null) ...[
            Aviso(l.erroRede, tom: Semaforo.vermelho),
            const SizedBox(height: 12),
          ],
          if (aCarregar)
            for (var i = 0; i < 5; i++) const _Esqueleto()
          else if (store.itens.isEmpty)
            Vazio(icone: Icons.menu_book_rounded, texto: l.guiasVazio)
          else
            for (final g in store.itens) _LinhaGuia(guia: g),
        ],
      ),
    );
  }
}

/// Ícone por categoria do guia.
IconData iconeDaCategoria(String? categoria) => switch (categoria) {
      'inicio' => Icons.play_circle_rounded,
      'iva' => Icons.percent_rounded,
      'recibos' => Icons.receipt_long_rounded,
      'ss' => Icons.health_and_safety_rounded,
      'irs' => Icons.account_balance_rounded,
      'tvde' => Icons.local_taxi_rounded,
      'estafeta' => Icons.delivery_dining_rounded,
      'imigrante' => Icons.public_rounded,
      'carro' => Icons.directions_car_rounded,
      _ => Icons.menu_book_rounded,
    };

class _LinhaGuia extends StatelessWidget {
  final Guia guia;
  const _LinhaGuia({required this.guia});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Cartao(
        key: Key('guia_${guia.slug}'),
        padding: const EdgeInsets.all(14),
        aoTocar: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GuiaScreen(guia: guia))),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: Icon(iconeDaCategoria(guia.categoria), color: AppColors.primaryDark, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(guia.titulo, style: t.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.headphones_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(l.guiasUmMinuto, style: t.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }
}

/// Skeleton cinzento de uma linha (estado "a carregar").
class _Esqueleto extends StatelessWidget {
  const _Esqueleto();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 76,
        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: AppTheme.cantos),
      ),
    );
  }
}
