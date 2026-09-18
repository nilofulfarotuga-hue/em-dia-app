import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/fala.dart';
import '../stores/perfil_store.dart';
import 'botao_ouvir.dart';
import 'widgets.dart' show BotaoGrande;

/// «O que é isto?» — o botão que explica as palavras difíceis de um ecrã
/// (B4, 2026-09-18).
///
/// O juiz de simplicidade (Gemini, pergunta «uma pessoa que nunca usou uma app
/// destas percebe o que fazer aqui?») apontou 30 ecrãs «quase» e o motivo era
/// quase sempre o mesmo: IRS, Segurança Social, IVA, TVDE, IUC, NIF… sem
/// explicação. Não cabe uma explicação entre parênteses ao lado de cada
/// palavra em cada ecrã; cabe um botão no canto que abre a lista das palavras
/// desse ecrã, em linguagem de criança de 5 anos, com botão «Ouvir».
///
/// Usa-se assim, nas `actions` da AppBar ou ao lado de um título:
/// ```dart
/// BotaoPalavras(termos: ['irs', 'ss', 'iva'])
/// ```
/// As chaves são as do [glossario]. Uma chave que não exista é ignorada — o
/// botão nunca rebenta por causa de uma palavra a mais.
class BotaoPalavras extends StatelessWidget {
  final List<String> termos;

  /// `true` mostra também a palavra «O que é isto?» ao lado do ícone.
  final bool comTexto;

  const BotaoPalavras({super.key, required this.termos, this.comTexto = false});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final existem = termos.where((t) => glossario(l).containsKey(t)).toList();
    if (existem.isEmpty) return const SizedBox.shrink();
    void abrir() => mostrarPalavrasDificeis(context, existem);
    if (comTexto) {
      return TextButton.icon(
        key: Key('palavras_${existem.first}'),
        onPressed: abrir,
        icon: const Icon(Icons.help_outline_rounded, size: 20),
        label: Text(l.glossBotao),
        style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark, padding: const EdgeInsets.symmetric(horizontal: 8)),
      );
    }
    return IconButton(
      key: Key('palavras_${existem.first}'),
      onPressed: abrir,
      tooltip: l.glossBotao,
      color: AppColors.textSecondary,
      icon: const Icon(Icons.help_outline_rounded),
    );
  }
}

/// Abre a folha «Palavras difíceis» com os [termos] pedidos (chaves do
/// [glossario]).
Future<void> mostrarPalavrasDificeis(BuildContext context, List<String> termos) {
  // A folha vive no Navigator de raiz, fora da árvore que tem os stores: o
  // botão Ouvir precisa da voz e do perfil (a variante PT/BR), por isso vão
  // por `.value` — como em `mostrarDetalheObrigacao`.
  PerfilStore? perfil;
  try {
    perfil = context.read<PerfilStore>();
  } on ProviderNotFoundException {
    perfil = null;
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.raio))),
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider<Fala>.value(value: Fala.instancia),
        if (perfil != null) ChangeNotifierProvider<PerfilStore>.value(value: perfil),
      ],
      child: FolhaPalavrasDificeis(termos: termos),
    ),
  );
}

/// O conteúdo da folha: título, uma linha de ajuda, e uma entrada por palavra
/// (nome a negrito, explicação, botão Ouvir).
class FolhaPalavrasDificeis extends StatelessWidget {
  final List<String> termos;
  const FolhaPalavrasDificeis({super.key, required this.termos});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final mapa = glossario(l);
    final entradas = [for (final k in termos) if (mapa[k] != null) (k, mapa[k]!)];
    final alturaMax = MediaQuery.sizeOf(context).height * 0.8;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: alturaMax),
        child: ListView(
          key: const Key('palavras_folha'),
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Row(
              children: [
                const Icon(Icons.help_outline_rounded, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                Expanded(child: Text(l.glossTitulo, style: t.titleLarge)),
                BotaoOuvir(
                  etiqueta: 'palavras-todas',
                  texto: entradas.map((e) => '${e.$2.$1}: ${e.$2.$2}').join(' '),
                  soIcone: true,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l.glossAjuda, style: t.bodySmall!.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            for (final (chave, (nome, texto)) in entradas)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nome, style: t.titleSmall),
                          const SizedBox(height: 2),
                          Text(texto, style: t.bodyMedium),
                        ],
                      ),
                    ),
                    BotaoOuvir(etiqueta: 'palavra-$chave', texto: '$nome: $texto', soIcone: true),
                  ],
                ),
              ),
            // O juiz pediu «um botão evidente para fechar»: a pega em cima já
            // fecha ao puxar, mas quem nunca usou uma app destas não sabe.
            BotaoGrande(
              key: const Key('palavras_fechar'),
              texto: l.glossFechar,
              icone: Icons.close_rounded,
              secundario: true,
              aoTocar: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Todas as palavras difíceis que a app usa, por chave, com o nome e a
/// explicação na língua de quem lê (os textos vivem em
/// `lib/l10n/partes/glossario_*.arb`).
Map<String, (String, String)> glossario(AppLocalizations l) => {
      'irs': (l.glossIrsNome, l.glossIrsTexto),
      'iva': (l.glossIvaNome, l.glossIvaTexto),
      'ss': (l.glossSsNome, l.glossSsTexto),
      'ss_direta': (l.glossSsDiretaNome, l.glossSsDiretaTexto),
      'tvde': (l.glossTvdeNome, l.glossTvdeTexto),
      'iuc': (l.glossIucNome, l.glossIucTexto),
      'nif': (l.glossNifNome, l.glossNifTexto),
      'niss': (l.glossNissNome, l.glossNissTexto),
      'nipc': (l.glossNipcNome, l.glossNipcTexto),
      'cae': (l.glossCaeNome, l.glossCaeTexto),
      'retencao': (l.glossRetencaoNome, l.glossRetencaoTexto),
      'anexo_b': (l.glossAnexoBNome, l.glossAnexoBTexto),
      'anexo_a': (l.glossAnexoANome, l.glossAnexoATexto),
      'art53': (l.glossArt53Nome, l.glossArt53Texto),
      'multibanco': (l.glossMultibancoNome, l.glossMultibancoTexto),
      'conta_corrente': (l.glossContaCorrenteNome, l.glossContaCorrenteTexto),
      'dgeg': (l.glossDgegNome, l.glossDgegTexto),
      'imt': (l.glossImtNome, l.glossImtTexto),
      'iefp': (l.glossIefpNome, l.glossIefpTexto),
      'pro': (l.glossProNome, l.glossProTexto),
      'eni': (l.glossEniNome, l.glossEniTexto),
      'lda': (l.glossLdaNome, l.glossLdaTexto),
      'irc': (l.glossIrcNome, l.glossIrcTexto),
      'trimestre': (l.glossTrimestreNome, l.glossTrimestreTexto),
      'contabilidade': (l.glossContabilidadeNome, l.glossContabilidadeTexto),
      'dmr': (l.glossDmrNome, l.glossDmrTexto),
      'saft': (l.glossSaftNome, l.glossSaftTexto),
      'ies': (l.glossIesNome, l.glossIesTexto),
      'efatura': (l.glossEfaturaNome, l.glossEfaturaTexto),
      'recibos_verdes': (l.glossRecibosVerdesNome, l.glossRecibosVerdesTexto),
      'ias': (l.glossIasNome, l.glossIasTexto),
      'portal_financas': (l.glossPortalFinancasNome, l.glossPortalFinancasTexto),
      'subsidio_natal': (l.glossSubsidioNatalNome, l.glossSubsidioNatalTexto),
      'proporcional': (l.glossProporcionalNome, l.glossProporcionalTexto),
      'fidelizacao': (l.glossFidelizacaoNome, l.glossFidelizacaoTexto),
      'prova_rendimento': (l.glossProvaRendimentoNome, l.glossProvaRendimentoTexto),
      'imposto': (l.glossImpostoNome, l.glossImpostoTexto),
      'cofre': (l.glossCofreNome, l.glossCofreTexto),
      'horas_extra': (l.glossHorasExtraNome, l.glossHorasExtraTexto),
      'reforma': (l.glossReformaNome, l.glossReformaTexto),
      'isencao': (l.glossIsencaoNome, l.glossIsencaoTexto),
    };

/// As palavras de cada ecrã, num sítio só — para os testes conferirem que
/// nenhum ecrã apontado pelo juiz ficou sem o botão.
abstract final class PalavrasDoEcra {
  static const calendario = ['iva', 'irs', 'ss', 'efatura', 'multibanco', 'conta_corrente', 'ss_direta'];
  static const painel = ['ss', 'irs', 'iva', 'imposto'];
  static const cofre = ['cofre', 'imposto', 'ss', 'irs', 'iva', 'contabilidade'];
  static const carro = ['tvde', 'iuc', 'imt', 'dgeg', 'nif', 'irs'];
  static const guias = ['cae', 'iva', 'art53', 'retencao', 'irs', 'anexo_b', 'tvde', 'niss', 'multibanco', 'conta_corrente', 'recibos_verdes', 'isencao'];
  static const fala = ['iva', 'ss', 'irs', 'trimestre', 'pro'];
  static const ia = ['ss', 'iva', 'irs', 'pro'];
  static const recibos = ['recibos_verdes', 'iva', 'retencao', 'nif', 'portal_financas', 'isencao'];
  static const contrato = ['irs', 'ss', 'anexo_a', 'retencao', 'iefp', 'subsidio_natal', 'proporcional', 'horas_extra', 'efatura'];
  static const empresa = ['eni', 'lda', 'nipc', 'irc', 'iva', 'dmr', 'saft', 'ies', 'contabilidade'];
  static const onboardingEmpresa = ['eni', 'lda', 'nipc', 'nif'];
  static const onboardingAbertura = ['portal_financas', 'ss', 'cae'];
  static const onboardingIva = ['iva', 'isencao', 'art53'];
  static const onboardingIvaPeriodo = ['iva', 'trimestre'];
  static const onboardingAtividade = ['tvde', 'recibos_verdes', 'cae'];
  static const mais = ['cofre', 'prova_rendimento', 'fidelizacao', 'reforma', 'pro'];
  static const reforma = ['reforma', 'ss', 'ias'];
  static const prova = ['prova_rendimento', 'irs', 'recibos_verdes'];
  static const radar = ['fidelizacao'];
}
