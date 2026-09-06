import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/guia.dart';
import '../../regras/regras.dart';
import '../../stores/perfil_store.dart';
import '../../widgets/widgets.dart';

/// Um guia aberto: título, botão Ouvir/Parar (texto-para-voz do telemóvel),
/// o corpo em parágrafos e passos, e o rodapé com a fonte oficial.
class GuiaScreen extends StatefulWidget {
  final Guia guia;
  const GuiaScreen({super.key, required this.guia});

  @override
  State<GuiaScreen> createState() => _GuiaScreenState();
}

class _GuiaScreenState extends State<GuiaScreen> {
  FlutterTts? _tts;
  bool _aFalar = false;

  @override
  void dispose() {
    _tts?.stop();
    super.dispose();
  }

  String _variante(BuildContext context) {
    final doPerfil = context.watch<PerfilStore>().perfil?.variantePt;
    if (doPerfil != null) return doPerfil;
    return Localizations.localeOf(context).countryCode == 'BR' ? 'br' : 'pt';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final guia = widget.guia;
    final variante = _variante(context);
    final corpo = guia.corpo(variante).trim();

    return Scaffold(
      appBar: AppBar(title: Text(l.guiasTitulo)),
      body: ListView(
        padding: paddingEcra,
        children: [
          Text(guia.titulo, style: t.headlineSmall),
          const SizedBox(height: 12),
          BotaoGrande(
            key: const Key('guia_ouvir'),
            texto: _aFalar ? l.guiasParar : l.guiasOuvir,
            icone: _aFalar ? Icons.stop_rounded : Icons.volume_up_rounded,
            aoTocar: corpo.isEmpty ? null : () => _alternar(corpo, variante),
          ),
          const SizedBox(height: 16),
          if (corpo.isEmpty)
            Cartao(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppColors.textSecondary, size: 26),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l.guiasEmBreve, style: t.bodyMedium)),
                ],
              ),
            )
          else
            Cartao(child: CorpoGuia(texto: corpo)),
          const SizedBox(height: 16),
          _Rodape(guia: guia),
        ],
      ),
    );
  }

  Future<void> _alternar(String corpo, String variante) async {
    final l = AppLocalizations.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      if (_aFalar) {
        await _tts?.stop();
        if (mounted) setState(() => _aFalar = false);
        return;
      }
      final tts = _tts ??= FlutterTts();
      await tts.setLanguage(variante == 'br' ? 'pt-BR' : 'pt-PT');
      tts.setCompletionHandler(() {
        if (mounted) setState(() => _aFalar = false);
      });
      tts.setCancelHandler(() {
        if (mounted) setState(() => _aFalar = false);
      });
      setState(() => _aFalar = true);
      await tts.speak('${widget.guia.titulo}. ${textoParaVoz(corpo)}');
    } catch (_) {
      if (mounted) setState(() => _aFalar = false);
      mensageiro.showSnackBar(SnackBar(content: Text(l.guiasOuvirErro)));
    }
  }
}

/// Tira as marcas (`#`, `-`, `1.`, `**`) para a voz ler só as palavras.
String textoParaVoz(String corpo) => corpo
    .split('\n')
    .map((linha) => linha
        .replaceFirst(RegExp(r'^\s*#{1,6}\s+'), '')
        .replaceFirst(RegExp(r'^\s*[-*•]\s+'), '')
        .replaceFirst(RegExp(r'^\s*\d+[.)]\s+'), '')
        .replaceAll('**', ''))
    .where((linha) => linha.trim().isNotEmpty)
    .join('. ')
    .replaceAll('..', '.');

/// Rodapé: "Fonte oficial: {domínio} · verificado em {data}" (clicável) —
/// ou "por confirmar" quando ainda ninguém verificou.
class _Rodape extends StatelessWidget {
  final Guia guia;
  const _Rodape({required this.guia});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final url = guia.fonteUrl;
    final data = guia.verificadoEm == null ? l.guiasPorConfirmar : dataPt(guia.verificadoEm!);
    if (url == null || url.isEmpty) {
      return Text(l.guiasSemFonte, style: t.bodySmall);
    }
    final dominio = Uri.tryParse(url)?.host ?? url;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('guia_fonte'),
        onTap: () => _abrir(context, url),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.link_rounded, size: 18, color: AppColors.info),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.guiasFonte(dominio.isEmpty ? url : dominio, data),
                  style: t.bodySmall!.copyWith(color: AppColors.info, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
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

/// Corpo do guia sem pacote de markdown: parágrafos, `#` títulos, `-`
/// listas, `1.` passos numerados (círculo verde) e `**negrito**`.
class CorpoGuia extends StatelessWidget {
  final String texto;
  const CorpoGuia({super.key, required this.texto});

  static final RegExp _titulo = RegExp(r'^#{1,6}\s+(.*)$');
  static final RegExp _passo = RegExp(r'^(\d+)[.)]\s+(.*)$');
  static final RegExp _lista = RegExp(r'^[-*•]\s+(.*)$');

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final filhos = <Widget>[];
    for (final bruta in texto.split('\n')) {
      final linha = bruta.trim();
      if (linha.isEmpty) {
        filhos.add(const SizedBox(height: 8));
        continue;
      }
      final mt = _titulo.firstMatch(linha);
      if (mt != null) {
        filhos.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(mt.group(1)!, style: t.titleMedium),
        ));
        continue;
      }
      final mp = _passo.firstMatch(linha);
      if (mp != null) {
        filhos.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Text(mp.group(1)!,
                    style: t.labelMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(child: _rico(mp.group(2)!, t.bodyMedium!)),
            ],
          ),
        ));
        continue;
      }
      final ml = _lista.firstMatch(linha);
      if (ml != null) {
        filhos.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•', style: t.bodyMedium!.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Expanded(child: _rico(ml.group(1)!, t.bodyMedium!)),
            ],
          ),
        ));
        continue;
      }
      filhos.add(Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: _rico(linha, t.bodyMedium!)));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: filhos);
  }

  /// `**negrito**` a meio da frase.
  static Widget _rico(String s, TextStyle base) {
    final partes = s.split('**');
    if (partes.length < 3) return Text(s, style: base);
    return Text.rich(TextSpan(
      style: base,
      children: [
        for (var i = 0; i < partes.length; i++)
          if (partes[i].isNotEmpty)
            TextSpan(text: partes[i], style: i.isOdd ? const TextStyle(fontWeight: FontWeight.w700) : null),
      ],
    ));
  }
}
