import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../exemplo/exemplo_screen.dart';
import '../../exemplo/stores_exemplo.dart';
import '../../l10n/app_localizations.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import '../cofre/cofre_screen.dart';
import '../fala/fala_screen.dart';
import '../guias/guias_screen.dart';
import '../ia/ia_screen.dart';
import '../plano/plano_screen.dart';
import '../prova/prova_rendimento_screen.dart';
import '../radar/radar_screen.dart';
import '../reforma/reforma_screen.dart';
import '../suporte/suporte_screen.dart';
import '../vale_a_pena/vale_a_pena_screen.dart';
import 'definicoes_screen.dart';

/// Mais — a grelha 2×N de acessos rápidos (estrutura do MaisMei).
///
/// A ordem não é por ordem alfabética nem por data: é pelo que a pessoa usa
/// mais. Primeiro as duas que se usam ANTES de trabalhar — "vale a pena esta
/// corrida?" e "fala comigo" —, depois as do dinheiro (cofre, prova de
/// rendimento, fim da fidelização), e só no fim as de consulta e as contas da
/// casa. Sair e apagar a conta vivem nas Definições.
class MaisScreen extends StatelessWidget {
  const MaisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    // Abre o ecrã do plano a partir de dentro de outro ecrã (o cadeado).
    void abrirPlano(BuildContext ctx) => Navigator.of(ctx)
        .push(MaterialPageRoute<void>(builder: (_) => const PlanoScreen()));

    final acessos = <_Acesso>[
      _Acesso('vale_a_pena', Icons.calculate_rounded, l.vpTitulo, l.maisSubValeAPena, (_) => const ValeAPenaScreen()),
      _Acesso('fala', Icons.mic_rounded, l.falaTitulo, l.maisSubFala,
          (ctx) => FalaScreen(aoAbrirPlano: () => abrirPlano(ctx))),
      _Acesso('cofre', Icons.savings_outlined, l.cofreTitulo, l.maisSubCofre, (_) => const CofreScreen()),
      _Acesso('prova', Icons.description_rounded, l.provaTitulo, l.maisSubProva, (_) => const ProvaRendimentoScreen()),
      _Acesso('radar', Icons.link_off_rounded, l.radarAtalho, l.maisSubRadar, (_) => const RadarScreen()),
      _Acesso('reforma', Icons.savings_rounded, l.maisReforma, l.maisSubReforma, (_) => const ReformaScreen()),
      _Acesso('guias', Icons.menu_book_rounded, l.maisGuias, l.maisSubGuias, (_) => const GuiasScreen()),
      _Acesso(
        'ia',
        Icons.chat_bubble_rounded,
        l.maisPergunta,
        l.maisSubPergunta,
        // O assistente pede o plano quando bate no limite do grátis.
        (ctx) => IaScreen(aoAbrirPlano: () => abrirPlano(ctx)),
      ),
      _Acesso('ajuda', Icons.support_agent_rounded, l.maisAjuda, l.maisSubAjuda, (_) => const SuporteScreen()),
      _Acesso('plano', Icons.workspace_premium_rounded, l.maisPlano, l.maisSubPlano, (_) => const PlanoScreen()),
      _Acesso('definicoes', Icons.settings_rounded, l.maisDefinicoes, l.maisSubDefinicoes, (_) => const DefinicoesScreen()),
      // «Ver um exemplo» (B2f) — escondido quando já se está dentro do exemplo.
      if (context.read<SessaoStore>() is! SessaoExemplo)
        _Acesso('exemplo', Icons.visibility_rounded, l.maisExemplo, l.maisSubExemplo, (_) => const ExemploScreen()),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.navMais)),
      body: ListView(
        padding: paddingEcra,
        children: [
          Row(
            children: [
              Expanded(child: Text(l.maisSubtitulo, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary))),
              BotaoOuvir(etiqueta: 'mais-lista', texto: '${l.maisSubtitulo} ${acessos.map((a) => '${a.titulo}: ${a.sub}').join(' ')}', soIcone: true),
              BotaoPalavras(termos: PalavrasDoEcra.mais),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 176,
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

  /// Uma linha, em palavras simples, a dizer para que serve (B4: o juiz de
  /// simplicidade chumbou «Prova de rendimento», «Fim da fidelização» e
  /// «Reforma e direitos» sozinhos — nomes abstratos sem o benefício).
  final String sub;
  final Widget Function(BuildContext) abrir;
  const _Acesso(this.chave, this.icone, this.titulo, this.sub, this.abrir);
}

/// Um tile da grelha: círculo verde-claro com o ícone + título (até 2 linhas)
/// + uma linha simples a dizer para que serve (até 2 linhas). Nunca estoura: a
/// altura é fixa e os textos cortam com reticências.
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
          Text(acesso.titulo, style: t.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Flexible(
            child: Text(acesso.sub, style: t.bodySmall!.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
