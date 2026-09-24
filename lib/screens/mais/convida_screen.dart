// Ecrã «Convida e ganha» (2026-09-24): o link próprio de cada pessoa, o texto
// pronto para o WhatsApp, Instagram/Facebook (folha de partilha do sistema) e
// copiar, e o contador «já convidaste X». As regras (30 dias para os dois quando
// o amigo usa a app; 1 prémio por pessoa; máximo 12 meses) estão escritas no
// ecrã em palavras simples — e são o servidor que as aplica.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../services/convites.dart';
import '../../widgets/widgets.dart';

class ConvidaScreen extends StatefulWidget {
  /// Para testes e fotos: dados prontos, sem servidor.
  final Map<String, dynamic>? dadosProntos;
  const ConvidaScreen({super.key, this.dadosProntos});

  @override
  State<ConvidaScreen> createState() => _ConvidaScreenState();
}

class _ConvidaScreenState extends State<ConvidaScreen> {
  Map<String, dynamic>? _d;
  String? _erro;

  @override
  void initState() {
    super.initState();
    if (widget.dadosProntos != null) {
      _d = widget.dadosProntos;
    } else {
      _ler();
    }
  }

  Future<void> _ler() async {
    try {
      final d = await Convites.meu();
      if (!mounted) return;
      setState(() {
        _d = d;
        _erro = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.toString());
    }
  }

  String get _link => (_d?['link'] ?? '').toString();

  String _texto(AppLocalizations l) => l.convTextoPartilha(_link);

  Future<void> _whatsapp(AppLocalizations l) async {
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(_texto(l))}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await _partilhar(l);
    }
  }

  Future<void> _partilhar(AppLocalizations l) async {
    await Share.share(_texto(l), subject: l.convAssunto);
  }

  Future<void> _copiar(AppLocalizations l) async {
    await Clipboard.setData(ClipboardData(text: _link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.convCopiado)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = _d;
    return Scaffold(
      appBar: AppBar(title: Text(l.convTitulo)),
      body: _erro != null
          ? Padding(padding: const EdgeInsets.all(16), child: Aviso(l.convErro, tom: Semaforo.vermelho))
          : d == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(l.convLead, style: t.titleLarge!.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(l.convComoFunciona, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    Cartao(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.convOTeuLink, style: t.labelLarge),
                          const SizedBox(height: 6),
                          SelectableText(_link, key: const Key('conv_link'), style: t.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(l.convCodigo((d['codigo'] ?? '').toString()), style: t.bodySmall!.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    BotaoGrande(key: const Key('conv_whatsapp'), texto: l.convWhatsapp, icone: Icons.chat_rounded, aoTocar: () => _whatsapp(l)),
                    const SizedBox(height: 10),
                    BotaoGrande(key: const Key('conv_partilhar'), texto: l.convInstaFace, icone: Icons.ios_share_rounded, secundario: true, aoTocar: () => _partilhar(l)),
                    const SizedBox(height: 10),
                    BotaoGrande(key: const Key('conv_copiar'), texto: l.convCopiar, icone: Icons.copy_rounded, secundario: true, aoTocar: () => _copiar(l)),
                    const SizedBox(height: 20),
                    Cartao(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.convJaConvidaste(_n(d['convidados'])), key: const Key('conv_contador'), style: t.titleMedium!.copyWith(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(l.convGanhos(_n(d['premiados']), _n(d['meses_ganhos']), _n(d['maximo'])), style: t.bodyMedium),
                              ],
                            ),
                          ),
                          const Icon(Icons.card_giftcard_rounded, color: AppColors.primary, size: 36),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Aviso(l.convRegras, tom: Semaforo.verde),
                  ],
                ),
    );
  }

  static int _n(dynamic v) => v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
}
