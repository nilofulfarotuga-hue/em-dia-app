import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import '../guias/guias_screen.dart';
import '../ia/ia_screen.dart';
import '../plano/plano_screen.dart';
import '../reforma/reforma_screen.dart';
import '../suporte/suporte_screen.dart';
import 'definicoes_screen.dart';

/// Mais — a grelha 2×N de acessos rápidos (estrutura do MaisMei): Reforma e
/// direitos · Guias · Pergunta ao Em Dia · Ajuda · O teu plano · Definições.
/// Sair e apagar a conta vivem nas Definições.
class MaisScreen extends StatelessWidget {
  const MaisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final acessos = <_Acesso>[
      _Acesso('reforma', Icons.savings_rounded, l.maisReforma, (_) => const ReformaScreen()),
      _Acesso('guias', Icons.menu_book_rounded, l.maisGuias, (_) => const GuiasScreen()),
      _Acesso(
        'ia',
        Icons.chat_bubble_rounded,
        l.maisPergunta,
        // O assistente pede o plano quando bate no limite do grátis.
        (ctx) => IaScreen(
          aoAbrirPlano: () =>
              Navigator.of(ctx).push(MaterialPageRoute<void>(builder: (_) => const PlanoScreen())),
        ),
      ),
      _Acesso('ajuda', Icons.support_agent_rounded, l.maisAjuda, (_) => const SuporteScreen()),
      _Acesso('plano', Icons.workspace_premium_rounded, l.maisPlano, (_) => const PlanoScreen()),
      _Acesso('definicoes', Icons.settings_rounded, l.maisDefinicoes, (_) => const DefinicoesScreen()),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.navMais)),
      body: ListView(
        padding: paddingEcra,
        children: [
          Text(l.maisSubtitulo, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 150,
            ),
            itemCount: acessos.length,
            itemBuilder: (_, i) => _Tile(acesso: acessos[i]),
          ),
        ],
      ),
    );
  }
}

class _Acesso {
  final String chave;
  final IconData icone;
  final String titulo;
  final Widget Function(BuildContext) abrir;
  const _Acesso(this.chave, this.icone, this.titulo, this.abrir);
}

/// Um tile da grelha: círculo verde-claro com o ícone + título (até 3 linhas,
/// nunca estoura: a altura é fixa e o texto é flexível).
class _Tile extends StatelessWidget {
  final _Acesso acesso;
  const _Tile({required this.acesso});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Cartao(
      key: Key('mais_${acesso.chave}'),
      aoTocar: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => acesso.abrir(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Icon(acesso.icone, color: AppColors.primaryDark, size: 26),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(acesso.titulo, style: t.titleMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
