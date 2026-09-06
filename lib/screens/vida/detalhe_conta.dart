import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/saida.dart';
import '../../regras/regras.dart';
import '../../services/fala.dart';
import '../../stores/perfil_store.dart';
import '../../stores/saidas_store.dart';
import '../../widgets/widgets.dart';
import 'saidas_screen.dart' show iconeCategoria, rotuloCategoria, rotuloMeio;

/// O esquema do MB WAY no telemóvel. Se a app não estiver instalada isto não
/// abre nada — e é por isso que há sempre a frase do multibanco por baixo.
const String _esquemaMbway = 'mbway://';

/// Abre o detalhe de uma conta a pagar. Os stores vão por `.value` porque a
/// folha vive no Navigator de raiz, fora da árvore que os tem.
Future<void> mostrarDetalheConta(
  BuildContext context, {
  required SaidaPagamento pagamento,
  required Saida? saida,
  required DateTime hoje,
}) {
  final saidas = context.read<SaidasStore>();
  // O botão de ouvir precisa da voz e do perfil (é o perfil que diz se lê em
  // português de Portugal ou do Brasil).
  final perfil = context.read<PerfilStore>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider<SaidasStore>.value(value: saidas),
        ChangeNotifierProvider<PerfilStore>.value(value: perfil),
        ChangeNotifierProvider<Fala>.value(value: Fala.instancia),
      ],
      child: DetalheConta(inicial: pagamento, saida: saida, hoje: hoje),
    ),
  );
}

/// Detalhe de uma conta do mês: quanto é, até quando, **como se paga** (a
/// caixa da referência com copiar e ouvir, ou "não tens de fazer nada" no
/// débito direto) e o botão **Já paguei**.
class DetalheConta extends StatefulWidget {
  final SaidaPagamento inicial;
  final Saida? saida;
  final DateTime hoje;
  const DetalheConta({
    super.key,
    required this.inicial,
    required this.saida,
    required this.hoje,
  });

  @override
  State<DetalheConta> createState() => _DetalheContaState();
}

class _DetalheContaState extends State<DetalheConta> {
  final _valor = TextEditingController();
  bool _aTrabalhar = false;

  /// Só fica true depois de o MB WAY não abrir. Antes disso não se diz à
  /// pessoa que ela não tem a app — pode muito bem tê-la.
  bool _mbwayNaoAbriu = false;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _abrirMbway() async {
    var abriu = false;
    try {
      abriu = await launchUrl(Uri.parse(_esquemaMbway), mode: LaunchMode.externalApplication);
    } catch (_) {
      abriu = false;
    }
    if (!abriu && mounted) setState(() => _mbwayNaoAbriu = true);
  }

  Future<void> _marcarPago(SaidaPagamento p) async {
    final l = AppLocalizations.of(context);
    final msg = ScaffoldMessenger.of(context);
    // Conta de valor variável: o que a pessoa escreveu agora é o valor deste
    // mês. Sem isto o "falta pagar" ficava eternamente a zero para esta conta.
    final escrito = valorEscrito(_valor.text);
    setState(() => _aTrabalhar = true);
    final ok = await context.read<SaidasStore>().marcarPago(
          p,
          valor: p.valor == null ? escrito : null,
        );
    if (!mounted) return;
    setState(() => _aTrabalhar = false);
    if (!ok) msg.showSnackBar(SnackBar(content: Text(l.saidasErroMarcar)));
  }

  Future<void> _mudarEstado(Future<bool> Function() acao) async {
    final l = AppLocalizations.of(context);
    final msg = ScaffoldMessenger.of(context);
    setState(() => _aTrabalhar = true);
    final ok = await acao();
    if (!mounted) return;
    setState(() => _aTrabalhar = false);
    if (!ok) msg.showSnackBar(SnackBar(content: Text(l.saidasErroMarcar)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final store = context.watch<SaidasStore>();
    // Relê do store para o ecrã mudar sozinho depois de marcar como pago.
    final p = store.pagamentos.firstWhere(
      (x) => x.id == widget.inicial.id,
      orElse: () => widget.inicial,
    );
    final saida = store.saidaDe(p) ?? widget.saida;
    final categoria = saida?.categoria ?? 'outro';
    final meio = saida?.meio ?? 'debito_direto';
    final nome = (saida?.nome.isNotEmpty ?? false) ? saida!.nome : rotuloCategoria(l, categoria);
    final fornecedor = saida?.fornecedor?.trim();
    final passou = p.passou(widget.hoje);
    final cor = p.pago ? AppColors.emDia : (passou ? AppColors.passou : AppColors.textSecondary);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: cor.withValues(alpha: 0.14), shape: BoxShape.circle),
                child: Icon(p.pago ? Icons.check_rounded : iconeCategoria(categoria), color: cor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nome, style: t.headlineSmall),
                    const SizedBox(height: 4),
                    Text(_quandoE(l, p), style: t.bodyMedium!.copyWith(color: passou ? AppColors.passou : null)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Cartao(
            cor: AppColors.surface2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                LinhaValor(
                  l.saidasQuantoE,
                  p.valor == null ? l.saidasValorPorSaber : moeda(p.valor!),
                  destaque: true,
                ),
                const Divider(height: 12),
                LinhaValor(l.saidasPagaAte, dataExtensoPt(p.dataLimite)),
                if (fornecedor != null && fornecedor.isNotEmpty) ...[
                  const Divider(height: 12),
                  LinhaValor(l.saidasFornecedorCurto, fornecedor),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(l.saidasComoSePaga, style: t.titleMedium),
          const SizedBox(height: 10),
          ..._comoSePaga(l, saida, meio, p),

          const SizedBox(height: 20),
          if (p.pago) ...[
            Aviso(
              p.pagoEm == null ? l.saidasJaEstaPago : l.saidasPagoEm(dataPt(p.pagoEm!)),
              tom: Semaforo.verde,
              icone: Icons.check_circle_rounded,
            ),
            const SizedBox(height: 10),
            BotaoGrande(
              texto: l.saidasAfinalNaoPaguei,
              secundario: true,
              aTrabalhar: _aTrabalhar,
              aoTocar: () => _mudarEstado(() => context.read<SaidasStore>().desmarcarPago(p)),
            ),
          ] else if (p.saltado) ...[
            Aviso(l.saidasSaltada, tom: Semaforo.verde, icone: Icons.event_busy_rounded),
            const SizedBox(height: 10),
            BotaoGrande(
              texto: l.jaPaguei,
              icone: Icons.check_rounded,
              aTrabalhar: _aTrabalhar,
              aoTocar: () => _marcarPago(p),
            ),
          ] else ...[
            // Conta de valor variável ainda sem valor: pergunta-se quanto foi
            // antes de marcar, senão a soma do mês fica a mentir.
            if (p.valor == null) ...[
              Text(l.saidasEscreveValorAjuda, style: t.bodyMedium),
              const SizedBox(height: 10),
              CampoValor(controlador: _valor, rotulo: l.saidasEscreveValor),
              const SizedBox(height: 14),
            ],
            BotaoGrande(
              key: const Key('conta_ja_paguei'),
              texto: l.jaPaguei,
              icone: Icons.check_rounded,
              aTrabalhar: _aTrabalhar,
              aoTocar: () => _marcarPago(p),
            ),
            const SizedBox(height: 8),
            BotaoGrande(
              texto: l.saidasSaltarMes,
              secundario: true,
              aTrabalhar: _aTrabalhar,
              aoTocar: () => _mudarEstado(() => context.read<SaidasStore>().saltar(p)),
            ),
          ],
        ],
      ),
    );
  }

  /// A frase do prazo, em linguagem de gente: hoje, faltam X dias, ou passou.
  String _quandoE(AppLocalizations l, SaidaPagamento p) {
    if (p.pago) return l.saidasEstadoPago;
    if (p.saltado) return l.saidasEstadoSaltado;
    if (p.passou(widget.hoje)) return l.saidasEstadoPassou;
    final dias = p.diasParaPrazo(widget.hoje);
    if (dias == 0) return l.eHoje;
    return l.faltamDias(dias);
  }

  /// O bloco "como se paga" muda com o meio. É a parte que faz a app valer a
  /// pena: quem paga por referência não tem de procurar os números outra vez,
  /// e quem tem débito direto fica a saber que não tem de fazer nada.
  List<Widget> _comoSePaga(
    AppLocalizations l,
    Saida? saida,
    String meio,
    SaidaPagamento p,
  ) {
    if (meio == 'referencia_mb' && saida != null && saida.temReferenciaMultibanco) {
      return [
        CaixaReferencia(
          entidade: saida.entidade!,
          referencia: saida.referencia!,
          valor: p.valor,
        ),
        const SizedBox(height: 12),
        BotaoGrande(
          key: const Key('conta_abrir_mbway'),
          texto: l.saidasMbwayAbrir,
          icone: Icons.smartphone_rounded,
          secundario: true,
          aoTocar: _abrirMbway,
        ),
        const SizedBox(height: 8),
        Text(l.saidasMbwayComoPagar, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        // A frase do multibanco está sempre cá: telemóvel sem MB WAY também
        // paga, e quem não sabe onde carregar precisa de a ler antes de sair
        // de casa.
        Aviso(
          _mbwayNaoAbriu ? l.saidasMbwaySemApp : l.saidasRefNoMultibanco,
          tom: Semaforo.verde,
          icone: Icons.atm_rounded,
        ),
      ];
    }
    if (meio == 'debito_direto') {
      final texto = l.saidasDebitoNadaFazer(saida?.diaDoMes ?? p.dataLimite.day);
      return [
        Aviso(texto, tom: Semaforo.verde, icone: Icons.autorenew_rounded),
        const SizedBox(height: 6),
        // A etiqueta não é texto visível: é só o nome por que este botão se
        // reconhece quando há vários a falar no mesmo ecrã.
        BotaoOuvir(etiqueta: 'saidas-debito-${p.id}', texto: texto),
      ];
    }
    final texto = switch (meio) {
      'mbway' => l.saidasAjudaMbway,
      'transferencia' => l.saidasAjudaTransferencia,
      'dinheiro' => l.saidasAjudaDinheiro,
      _ => l.saidasAjudaCartao,
    };
    return [
      Aviso(texto, tom: Semaforo.verde, icone: Icons.info_rounded),
      const SizedBox(height: 6),
      Text(rotuloMeio(l, meio), style: Theme.of(context).textTheme.bodySmall),
    ];
  }
}
