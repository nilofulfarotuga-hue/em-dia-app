import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/entrada.dart';
import '../../regras/regras.dart';
import '../../stores/entradas_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import 'nova_entrada.dart';

/// A aba "Entra": em cima o que já entrou este mês, em baixo o botão que abre
/// a folha de registo.
///
/// Duas partes e nada mais. Quem abre isto ou quer ver quanto ganhou, ou quer
/// escrever o que acabou de ganhar — e o botão está sempre no fundo do ecrã,
/// não é preciso rolar a lista toda para lá chegar.
class EntradasScreen extends StatefulWidget {
  /// Só para fotos/testes: fixa o "hoje". Na app é sempre [hojeLisboa].
  final DateTime? hoje;
  const EntradasScreen({super.key, this.hoje});

  @override
  State<EntradasScreen> createState() => _EntradasScreenState();
}

class _EntradasScreenState extends State<EntradasScreen> {
  DateTime get _hoje => widget.hoje ?? hojeLisboa();

  @override
  void initState() {
    super.initState();
    // O arranque da app não puxa esta tabela — quem a precisa é este ecrã.
    // Depois da primeira pintura, para não mandar notificações a meio de um
    // `build` (foi assim que outros ecrãs ficaram a piscar).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = context.read<SessaoStore>().userId;
      if (userId != null) context.read<EntradasStore>().carregarSePreciso(userId);
    });
  }

  void _snack(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _novaEntrada() async {
    final l = AppLocalizations.of(context);
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) {
      _snack(l.vidaSemSessao);
      return;
    }
    final ok = await mostrarNovaEntrada(context, userId: userId, hoje: _hoje);
    if (ok == true && mounted) _snack(l.vidaGuardado);
  }

  /// Apagar é para sempre: pergunta-se sempre, e a pergunta diz o valor e o
  /// dia para não se apagar a linha errada.
  Future<bool> _confirmarApagar(Entrada e) async {
    final l = AppLocalizations.of(context);
    final sim = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.vidaApagarPergunta(moeda(e.valor), dataPt(e.data))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancelar)),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l.apagar)),
        ],
      ),
    );
    return sim == true;
  }

  Future<void> _apagar(Entrada e) async {
    final l = AppLocalizations.of(context);
    final ok = await context.read<EntradasStore>().apagar(e);
    if (!mounted) return;
    _snack(ok ? l.vidaApagado : l.erroRede);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final store = context.watch<EntradasStore>();
    final h = _hoje;
    final doMes = store.doMes(h.year, h.month);
    final total = store.totalDoMes(h.year, h.month);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: paddingEcra,
            children: [
              // 1. O número grande: quanto entrou este mês.
              Cartao(
                key: const Key('entradas_total_mes'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.vidaEsteMes, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(moeda(total),
                          style: t.displayMedium!.copyWith(color: AppColors.primaryDeep)),
                    ),
                    const SizedBox(height: 6),
                    Text(l.vidaQuantasEntradas(doMes.length), style: t.bodySmall),
                  ],
                ),
              ),
              if (store.erro != null) ...[
                const SizedBox(height: 12),
                Aviso(l.erroRede, tom: Semaforo.vermelho),
              ],
              const SizedBox(height: 8),
              TituloSeccao(l.vidaListaTitulo),

              if (store.itens.isEmpty && store.aCarregar)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text(l.aCarregar, style: t.bodyMedium)),
                )
              else if (store.itens.isEmpty)
                Vazio(
                  key: const Key('entradas_vazio'),
                  icone: Icons.savings_outlined,
                  texto: l.vidaVazio,
                )
              else
                // A lista inteira, não só o mês: quem rola para baixo quer ver
                // o mês passado sem ter de andar a trocar de mês.
                for (final e in store.itens) ...[
                  _LinhaEntrada(
                    entrada: e,
                    aoConfirmarApagar: () => _confirmarApagar(e),
                    aoApagar: () => _apagar(e),
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          ),
        ),

        // 2. O botão grande, sempre à mão.
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: BotaoGrande(
              key: const Key('entradas_novo'),
              texto: l.vidaBotaoNovo,
              icone: Icons.add_rounded,
              aoTocar: _novaEntrada,
            ),
          ),
        ),
      ],
    );
  }
}

/// Uma linha da lista: ícone do sítio de onde veio, o que foi, o dia e o
/// valor. Desliza para a esquerda para apagar; quem não souber deslizar tem o
/// caixote do lixo ao lado — as duas maneiras fazem o mesmo.
class _LinhaEntrada extends StatelessWidget {
  final Entrada entrada;
  final Future<bool> Function() aoConfirmarApagar;
  final VoidCallback aoApagar;
  const _LinhaEntrada({
    required this.entrada,
    required this.aoConfirmarApagar,
    required this.aoApagar,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final e = entrada;

    // Sub-linha: o dia, e depois só o que acrescenta alguma coisa — a app, o
    // período quando não é um dia, os km, o que a pessoa escreveu.
    final pedacos = <String>[
      dataPt(e.data),
      if (e.tipo == 'plataforma' && e.plataforma != null) nomePlataformaEntrada(l, e.plataforma),
      if (e.periodo == 'semana') l.vidaListaSemana,
      if (e.periodo == 'mes') l.vidaListaMes,
      if (e.km != null && e.km! > 0) l.vidaKmCurto(e.km!),
      if (e.descricao != null && e.descricao!.trim().isNotEmpty) e.descricao!.trim(),
    ];

    return Dismissible(
      key: ValueKey('entrada_${e.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => aoConfirmarApagar(),
      onDismissed: (_) => aoApagar(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.passou, borderRadius: AppTheme.cantos),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Cartao(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: AppColors.primaryWash, shape: BoxShape.circle),
              child: Icon(iconeTipoEntrada(e.tipo), size: 22, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rotuloTipoEntrada(l, e.tipo), style: t.titleMedium),
                  const SizedBox(height: 2),
                  Text(pedacos.join(' · '), style: t.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(moeda(e.valor), style: t.titleMedium),
            IconButton(
              onPressed: () async {
                if (await aoConfirmarApagar()) aoApagar();
              },
              tooltip: l.apagar,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSubtle),
            ),
          ],
        ),
      ),
    );
  }
}
