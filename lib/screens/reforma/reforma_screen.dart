import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/perfil.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../widgets/widgets.dart';
import '../plano/plano_screen.dart';

const int _anosMin = 5;
const int _anosMax = 45;
const int _anosPadrao = 20;

/// Tela 5 — Reforma e direitos: "Descontas X — vale ≈ Y de reforma", a idade
/// da reforma, o que ganhas por pagar, o que perdes se não pagares e o acordo
/// Portugal–Brasil. No plano grátis só a primeira linha está aberta
/// (cadeado `reforma_completa`).
class ReformaScreen extends StatefulWidget {
  final DateTime? hoje;
  const ReformaScreen({super.key, this.hoje});

  @override
  State<ReformaScreen> createState() => _ReformaScreenState();
}

class _ReformaScreenState extends State<ReformaScreen> {
  int _anos = _anosPadrao;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final regras = context.watch<RegrasStore>().regras;
    final perfil = context.watch<PerfilStore>().perfil;
    final rendimentos = context.watch<RendimentosStore>();
    final plano = context.watch<PlanoStore>();
    final hoje = widget.hoje ?? hojeLisboa();

    final (contribuicao, semDados) = _contribuicao(regras, perfil, rendimentos, hoje);
    final reforma = estimarReformaMensal(contribuicaoMensal: contribuicao, anosDeDescontos: _anos, r: regras);
    final trancado = !plano.permitida('reforma_completa');

    // Os textos das duas secções ficam aqui em cima porque são lidos duas
    // vezes: uma pelos olhos, nos cartões, e outra pela voz.
    final baixaTexto = l.reformaBaixaTexto(
      regras.n('baixa_doenca_dia_inicio').toInt(),
      regras.n('baixa_doenca_prazo_garantia_meses').toInt(),
    );
    final cessacaoTexto = l.reformaCessacaoTexto(regras.n('cessacao_atividade_prazo_garantia_dias').toInt());
    final direitosFalado = [
      l.reformaDireitos,
      '${l.reformaBaixaTitulo}. $baixaTexto',
      '${l.reformaParentalidadeTitulo}. ${l.reformaParentalidadeTexto}',
      '${l.reformaCessacaoTitulo}. $cessacaoTexto',
      '${l.reformaFilhosTitulo}. ${l.reformaFilhosTexto}',
    ].join('. ');
    final perdesFalado = [
      l.reformaPerdes,
      l.reformaPerdesBaixa,
      l.reformaPerdesSubsidio,
      l.reformaPerdesTempo,
      l.reformaPerdesDivida,
    ].join('. ');
    final estimativaFalado = [
      l.reformaSubtitulo,
      l.reformaDescontasHoje(moeda(contribuicao)),
      '${l.reformaValeCerca} ${moeda(reforma)} ${l.reformaPorMesDeReforma}',
      l.reformaAnosDescontos(_anos),
      l.reformaEstimativaNota,
      if (semDados) l.reformaSemDados,
    ].join('. ');

    return Scaffold(
      appBar: AppBar(title: Text(l.reformaTitulo)),
      body: ListView(
        padding: paddingEcra,
        children: [
          Text(l.reformaSubtitulo, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Cartao(
            key: const Key('reforma_estimativa'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.reformaDescontasHoje(moeda(contribuicao)), style: t.titleMedium),
                const SizedBox(height: 8),
                Text(l.reformaValeCerca, style: t.bodySmall),
                Text(moeda(reforma), style: t.displayMedium!.copyWith(color: AppColors.primaryDeep)),
                Text(l.reformaPorMesDeReforma, style: t.bodyMedium),
                const SizedBox(height: 10),
                Etiqueta(l.reformaEstimativaSimples, cor: AppColors.surface2, corTexto: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(l.reformaAnosDescontos(_anos), style: t.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _BotaoPasso(
                      key: const Key('reforma_menos'),
                      icone: Icons.remove_rounded,
                      ativo: _anos > _anosMin,
                      aoTocar: () => setState(() => _anos = (_anos - 5).clamp(_anosMin, _anosMax)),
                    ),
                    Expanded(
                      child: Text(
                        l.reformaAnosCurto(_anos),
                        textAlign: TextAlign.center,
                        style: t.headlineSmall!.copyWith(color: AppColors.primaryDeep),
                      ),
                    ),
                    _BotaoPasso(
                      key: const Key('reforma_mais'),
                      icone: Icons.add_rounded,
                      ativo: _anos < _anosMax,
                      aoTocar: () => setState(() => _anos = (_anos + 5).clamp(_anosMin, _anosMax)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(l.reformaEstimativaNota, style: t.bodySmall),
                if (semDados) ...[
                  const SizedBox(height: 6),
                  Text(l.reformaSemDados, style: t.bodySmall),
                ],
                BotaoOuvir(etiqueta: 'reforma-estimativa', texto: estimativaFalado),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Cadeado(
            trancado: trancado,
            linha: l.planoCadeadoLinha,
            aoTocar: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PlanoScreen())),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CartaoIdade(regras: regras, hoje: hoje),
                TituloSeccao(
                  l.reformaDireitos,
                  acao: BotaoOuvir(etiqueta: 'reforma-direitos', texto: direitosFalado, soIcone: true),
                ),
                _Direito(
                  icone: Icons.sick_rounded,
                  titulo: l.reformaBaixaTitulo,
                  texto: baixaTexto,
                ),
                _Direito(
                  icone: Icons.child_friendly_rounded,
                  titulo: l.reformaParentalidadeTitulo,
                  texto: l.reformaParentalidadeTexto,
                ),
                _Direito(
                  icone: Icons.work_off_rounded,
                  titulo: l.reformaCessacaoTitulo,
                  texto: cessacaoTexto,
                ),
                _Direito(
                  icone: Icons.family_restroom_rounded,
                  titulo: l.reformaFilhosTitulo,
                  texto: l.reformaFilhosTexto,
                ),
                TituloSeccao(
                  l.reformaPerdes,
                  acao: BotaoOuvir(etiqueta: 'reforma-perdes', texto: perdesFalado, soIcone: true),
                ),
                Cartao(
                  child: Column(
                    children: [
                      _Perda(l.reformaPerdesBaixa),
                      _Perda(l.reformaPerdesSubsidio),
                      _Perda(l.reformaPerdesTempo),
                      _Perda(l.reformaPerdesDivida),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _CartaoAcordo(url: regras.regra('acordo_pt_br_url')?.valorTxt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Contribuição mensal atual: pelo trimestre anterior se houver registos;
  /// senão pela estimativa mensal (perfil ou média); senão o mínimo legal.
  /// (A mesma escolha do cartão da Segurança Social, para os números baterem.)
  static (double, bool) _contribuicao(RegrasLegais r, Perfil? perfil, RendimentosStore rendimentos, DateTime hoje) {
    final tipo = perfil?.tipoRendimento ?? TipoRendimento.servicos;
    final ajuste = perfil?.ajusteSsPct ?? 0;
    final trimestreAtual = ((hoje.month - 1) ~/ 3) + 1;
    final anoAnterior = trimestreAtual == 1 ? hoje.year - 1 : hoje.year;
    final trimestreAnterior = trimestreAtual == 1 ? 4 : trimestreAtual - 1;
    final total = rendimentos.totalTrimestre(anoAnterior, trimestreAnterior);
    if (total > 0) {
      return (calcularSS(rendimentoTrimestre: total, tipo: tipo, ajustePct: ajuste, r: r).contribuicaoMensal, false);
    }
    final mensal = perfil?.rendimentoMensalEstimado ?? rendimentos.mediaMensal();
    if (mensal != null && mensal > 0) {
      return (estimarSSMensal(rendimentoMensal: mensal, tipo: tipo, ajustePct: ajuste, r: r).contribuicaoMensal, false);
    }
    return (calcularSS(rendimentoTrimestre: 0, tipo: tipo, ajustePct: ajuste, r: r).contribuicaoMensal, true);
  }
}

/// Quando te podes reformar: idade (texto da regra, ou calculado do número) e
/// carreira mínima — tudo de `regras_legais`.
class _CartaoIdade extends StatelessWidget {
  final RegrasLegais regras;
  final DateTime hoje;
  const _CartaoIdade({required this.regras, required this.hoje});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final regra = regras.regra('reforma_idade');
    final String idade;
    if (regra?.valorTxt != null) {
      idade = regra!.valorTxt!;
    } else {
      final v = regras.n('reforma_idade');
      final anos = v.floor();
      final meses = ((v - anos) * 12).round();
      idade = meses == 0 ? l.reformaAnosCurto(anos) : l.reformaAnosEMeses(anos, meses);
    }
    final ano = regra?.ano ?? hoje.year;
    final minimo = regras.n('reforma_carreira_minima_anos').toInt();
    return Cartao(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cake_rounded, color: AppColors.primaryDark, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.reformaIdadeTitulo, style: t.titleMedium),
                const SizedBox(height: 4),
                Text(l.reformaIdadeRegra(ano, idade, minimo), style: t.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Um direito de quem paga: ícone em círculo verde-claro, título e explicação.
class _Direito extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String texto;
  const _Direito({required this.icone, required this.titulo, required this.texto});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Cartao(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: Icon(icone, color: AppColors.primaryDark, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: t.titleMedium),
                  const SizedBox(height: 2),
                  Text(texto, style: t.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma linha de "o que perdes": cruz vermelha + frase.
class _Perda extends StatelessWidget {
  final String texto;
  const _Perda(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_rounded, color: AppColors.passou, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// Acordo Portugal–Brasil: explicação simples + botão para o site oficial
/// (a URL vem de `regras_legais.acordo_pt_br_url`; sem URL não há botão).
class _CartaoAcordo extends StatelessWidget {
  final String? url;
  const _CartaoAcordo({required this.url});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.public_rounded, color: AppColors.primaryDark, size: 24),
              const SizedBox(width: 8),
              Expanded(child: Text(l.reformaAcordoTitulo, style: t.titleLarge)),
            ],
          ),
          const SizedBox(height: 8),
          Text(l.reformaAcordoTexto, style: t.bodyMedium),
          BotaoOuvir(
            etiqueta: 'reforma-acordo-brasil',
            texto: '${l.reformaAcordoTitulo}. ${l.reformaAcordoTexto}',
          ),
          if (url != null) ...[
            const SizedBox(height: 12),
            BotaoGrande(
              key: const Key('reforma_acordo_link'),
              texto: l.reformaAcordoBotao,
              secundario: true,
              icone: Icons.open_in_new_rounded,
              aoTocar: () => _abrir(context, url!),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _abrir(BuildContext context, String url) async {
    final l = AppLocalizations.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok) mensageiro.showSnackBar(SnackBar(content: Text(l.erroRede)));
    } catch (_) {
      mensageiro.showSnackBar(SnackBar(content: Text(l.erroRede)));
    }
  }
}

/// Botão −/+ de 56 px (alvo de toque grande).
class _BotaoPasso extends StatelessWidget {
  final IconData icone;
  final bool ativo;
  final VoidCallback aoTocar;
  const _BotaoPasso({super.key, required this.icone, required this.ativo, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: OutlinedButton(
        onPressed: ativo ? aoTocar : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(56, 56),
          shape: const RoundedRectangleBorder(borderRadius: AppTheme.cantosPequenos),
        ),
        child: Icon(icone, size: 28),
      ),
    );
  }
}
