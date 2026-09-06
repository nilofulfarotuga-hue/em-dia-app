import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mensagem_ia.dart';
import '../../stores/ia_store.dart';
import '../../stores/regras_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';

const String _urlSubscricoesPlay = 'https://play.google.com/store/account/subscriptions';

/// Tela 7 — "Pergunta ao Em Dia": chat simples com o assistente.
///
/// Balões (utilizador à direita, verde-claro; Em Dia à esquerda, branco),
/// 4 perguntas prontas, campo de texto em baixo e o rodapé fixo
/// "Informação geral, não substitui contabilista.". Trata o 402 (limite do
/// plano grátis → cadeado) e o 503 (assistente a descansar → aviso humano).
class IaScreen extends StatefulWidget {
  /// 'chat' (aba do assistente) ou 'suporte' (vindo da Ajuda).
  final String modo;

  /// Para testes e fotos: store já com conversa. Na app é criada aqui.
  final IaStore? store;

  /// O que fazer quando se toca no cadeado do plano. Por omissão abre uma
  /// folha com o plano Pro e o link para as subscrições da Google Play.
  final VoidCallback? aoAbrirPlano;

  const IaScreen({super.key, this.modo = 'chat', this.store, this.aoAbrirPlano});

  @override
  State<IaScreen> createState() => _IaScreenState();
}

class _IaScreenState extends State<IaScreen> {
  late final IaStore _store;
  late final bool _minha;
  final _texto = TextEditingController();
  final _scroll = ScrollController();
  final _foco = FocusNode();
  int _mensagensVistas = 0;

  @override
  void initState() {
    super.initState();
    _minha = widget.store == null;
    _store = widget.store ?? IaStore(modo: widget.modo);
    _mensagensVistas = _store.mensagens.length;
    _store.addListener(_aoMudar);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = context.read<SessaoStore>().userId;
      if (_minha && userId != null) _store.carregarHistorico(userId);
      _irParaOFim(animado: false);
    });
  }

  @override
  void dispose() {
    _store.removeListener(_aoMudar);
    if (_minha) _store.dispose();
    _texto.dispose();
    _scroll.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _aoMudar() {
    final devolvida = _store.tomarPerguntaDevolvida();
    if (devolvida != null && _texto.text.trim().isEmpty) _texto.text = devolvida;
    final n = _store.mensagens.length;
    if (n != _mensagensVistas || _store.aPensar) {
      _mensagensVistas = n;
      WidgetsBinding.instance.addPostFrameCallback((_) => _irParaOFim());
    }
  }

  void _irParaOFim({bool animado = true}) {
    if (!_scroll.hasClients) return;
    final fim = _scroll.position.maxScrollExtent;
    if (animado) {
      _scroll.animateTo(fim, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _scroll.jumpTo(fim);
    }
  }

  Future<void> _enviar([String? pronta]) async {
    final p = (pronta ?? _texto.text).trim();
    if (p.isEmpty) return;
    _texto.clear();
    await _store.perguntar(p);
  }

  void _abrirPlano() {
    if (widget.aoAbrirPlano != null) {
      widget.aoAbrirPlano!();
      return;
    }
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.raio))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_rounded, color: AppColors.cadeado, size: 26),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l.planoCadeado, style: Theme.of(ctx).textTheme.titleLarge)),
                ],
              ),
              const SizedBox(height: 10),
              Text(l.planoCadeadoLinha, style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Cartao(
                cor: AppColors.cadeadoClaro,
                child: Row(
                  children: [
                    Text(l.planoPro,
                        style: const TextStyle(
                            fontFamily: AppTheme.fonte, fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.cadeado)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.planoProPreco, style: Theme.of(ctx).textTheme.bodyMedium)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BotaoGrande(
                texto: l.planoGerir,
                icone: Icons.open_in_new_rounded,
                cor: AppColors.cadeado,
                aoTocar: () {
                  Navigator.of(ctx).pop();
                  launchUrl(Uri.parse(_urlSubscricoesPlay), mode: LaunchMode.externalApplication);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plano = context.watch<PlanoStore>();
    final suporte = widget.modo == 'suporte';
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final limitePlano = plano.limite('ia_perguntas') ?? _store.limiteValor;
        final usadas = _store.usadas;
        final mostraContador = limitePlano != null && usadas != null;
        final mensagens = _store.mensagens;
        final vazio = mensagens.isEmpty && !_store.aPensar;
        final chips = [l.iaChip1, l.iaChip2, l.iaChip3, l.iaChip4];
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text(suporte ? l.iaSuporteTitulo : l.iaTitulo)),
          body: SafeArea(
            child: Column(
              children: [
                if (mostraContador)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
                    child: Row(
                      children: [
                        const Icon(Icons.forum_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(l.iaContador(usadas, limitePlano),
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: vazio
                      ? ListView(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          children: [
                            Vazio(icone: Icons.chat_bubble_outline_rounded, texto: l.iaVazio),
                            if (!_store.limite)
                              _Chips(perguntas: chips, ativo: !_store.aPensar, aoEscolher: (p) => _enviar(p), empilhado: true),
                          ],
                        )
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          itemCount: mensagens.length + (_store.aPensar ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i >= mensagens.length) return const _BalaoAPensar();
                            return _Balao(mensagem: mensagens[i], indice: i);
                          },
                        ),
                ),
                if (_store.aDescansar)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Aviso(l.iaDescansar, tom: Semaforo.amarelo, icone: Icons.bedtime_outlined),
                  )
                else if (_store.erro != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Aviso(l.erroRede, tom: Semaforo.vermelho, icone: Icons.wifi_off_rounded),
                  ),
                if (_store.limite) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: _CartaoLimite(
                      texto: l.iaLimiteFree(limitePlano ?? usadas ?? 0, usadas ?? limitePlano ?? 0),
                      acao: l.iaVerPlano,
                      aoTocar: _abrirPlano,
                    ),
                  ),
                  Cadeado(
                    trancado: true,
                    linha: l.iaLimiteCta,
                    aoTocar: _abrirPlano,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: _Entrada(controlador: _texto, foco: _foco, dica: l.iaEscreve, ativo: false, aoEnviar: () {}),
                    ),
                  ),
                ] else ...[
                  if (!vazio) _Chips(perguntas: chips, ativo: !_store.aPensar, aoEscolher: (p) => _enviar(p)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: _Entrada(
                      controlador: _texto,
                      foco: _foco,
                      dica: l.iaEscreve,
                      ativo: !_store.aPensar,
                      aoEnviar: _enviar,
                    ),
                  ),
                ],
                _Rodape(texto: l.iaRodape),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Texto do Em Dia com parágrafos e "Próximo passo:" em negrito.
/// Também usado pela Tela 8 (resposta do ticket).
class TextoIa extends StatelessWidget {
  final String texto;
  final Color cor;
  const TextoIa(this.texto, {super.key, this.cor = AppColors.textPrimary});

  static final RegExp _proximoPasso = RegExp(r'^(pr[oó]ximo passo)\s*:', caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontFamily: AppTheme.fonte, fontSize: 15, height: 1.45, color: cor);
    final negrito = base.copyWith(fontWeight: FontWeight.w700);
    final paragrafos = texto.split('\n').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    final spans = <InlineSpan>[];
    for (var i = 0; i < paragrafos.length; i++) {
      final p = paragrafos[i];
      final m = _proximoPasso.firstMatch(p);
      if (m != null) {
        spans.add(TextSpan(text: p.substring(0, m.end), style: negrito));
        spans.add(TextSpan(text: p.substring(m.end)));
      } else {
        spans.add(TextSpan(text: p));
      }
      if (i < paragrafos.length - 1) spans.add(const TextSpan(text: '\n\n'));
    }
    return Text.rich(TextSpan(style: base, children: spans));
  }
}

class _Balao extends StatelessWidget {
  final MensagemIa mensagem;

  /// Lugar da mensagem na conversa — só serve para dar uma etiqueta diferente
  /// a cada botão de ouvir (a voz precisa de saber qual deles está a falar).
  final int indice;
  const _Balao({required this.mensagem, required this.indice});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final meu = mensagem.doUtilizador;
    final largura = MediaQuery.sizeOf(context).width * 0.82;
    final raio = Radius.circular(AppTheme.raio);
    return Align(
      alignment: meu ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: largura),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: meu ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: raio,
              topRight: raio,
              bottomLeft: meu ? raio : const Radius.circular(4),
              bottomRight: meu ? const Radius.circular(4) : raio,
            ),
            boxShadow: meu ? null : AppTheme.sombraCartao,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextoIa(mensagem.texto),
              if (mensagem.foraDasRegras) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_stories_outlined, size: 16, color: AppColors.info),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(l.iaGuiaNovo,
                          style: const TextStyle(
                              fontFamily: AppTheme.fonte, fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.info)),
                    ),
                  ],
                ),
              ],
              // Cada resposta do Em Dia é uma explicação — logo tem o botão de
              // ouvir. Nas perguntas do próprio utilizador não faz sentido.
              if (!meu) BotaoOuvir(etiqueta: 'ia-resposta-$indice', texto: mensagem.texto, soIcone: true),
            ],
          ),
        ),
      ),
    );
  }
}

/// Balão do Em Dia "a pensar": 3 pontos que pulsam.
class _BalaoAPensar extends StatefulWidget {
  const _BalaoAPensar();

  @override
  State<_BalaoAPensar> createState() => _BalaoAPensarState();
}

class _BalaoAPensarState extends State<_BalaoAPensar> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: l.iaAPensar,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.raio),
              topRight: Radius.circular(AppTheme.raio),
              bottomRight: Radius.circular(AppTheme.raio),
              bottomLeft: Radius.circular(4),
            ),
            boxShadow: AppTheme.sombraCartao,
          ),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final fase = ((_anim.value - i / 3) % 1.0);
                final forca = 0.3 + 0.7 * (1 - (fase * 2 - 1).abs());
                return Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: forca),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// As 4 perguntas prontas. [empilhado] = uma por linha (estado vazio);
/// senão, fila horizontal que desliza, com desvanecimento à direita.
class _Chips extends StatelessWidget {
  final List<String> perguntas;
  final bool ativo;
  final ValueChanged<String> aoEscolher;
  final bool empilhado;
  const _Chips({required this.perguntas, required this.ativo, required this.aoEscolher, this.empilhado = false});

  Widget _chip(String p) => Material(
        color: AppColors.surface,
        shape: StadiumBorder(side: BorderSide(color: (ativo ? AppColors.primary : AppColors.divider).withValues(alpha: 0.6))),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: ativo ? () => aoEscolher(p) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Text(
              p,
              maxLines: empilhado ? 2 : 1,
              style: TextStyle(
                fontFamily: AppTheme.fonte,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ativo ? AppColors.primaryDark : AppColors.textSubtle,
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (empilhado) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final p in perguntas) ...[
            Padding(padding: const EdgeInsets.only(bottom: 8), child: _chip(p)),
          ],
        ],
      );
    }
    return SizedBox(
      height: 44,
      child: ShaderMask(
        shaderCallback: (r) => const LinearGradient(
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0, 0.88, 1],
        ).createShader(r),
        blendMode: BlendMode.dstIn,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 4, 40, 4),
          itemCount: perguntas.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) => _chip(perguntas[i]),
        ),
      ),
    );
  }
}

class _Entrada extends StatelessWidget {
  final TextEditingController controlador;
  final FocusNode foco;
  final String dica;
  final bool ativo;
  final VoidCallback aoEnviar;
  const _Entrada({
    required this.controlador,
    required this.foco,
    required this.dica,
    required this.ativo,
    required this.aoEnviar,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controlador,
            focusNode: foco,
            enabled: ativo,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => aoEnviar(),
            decoration: InputDecoration(
              hintText: dica,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide(color: AppColors.divider)),
              enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide(color: AppColors.divider)),
              focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: l.suporteEnviar,
          child: Material(
            color: ativo ? AppColors.primary : AppColors.divider,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: ativo ? aoEnviar : null,
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartaoLimite extends StatelessWidget {
  final String texto;
  final String acao;
  final VoidCallback aoTocar;
  const _CartaoLimite({required this.texto, required this.acao, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return Cartao(
      cor: AppColors.cadeadoClaro,
      bordo: AppColors.cadeado.withValues(alpha: 0.35),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_rounded, color: AppColors.cadeado, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(texto,
                    style: const TextStyle(
                        fontFamily: AppTheme.fonte, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: aoTocar,
              style: TextButton.styleFrom(foregroundColor: AppColors.cadeado),
              icon: const Icon(Icons.workspace_premium_rounded, size: 18),
              label: Text(acao, style: const TextStyle(fontFamily: AppTheme.fonte, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Rodape extends StatelessWidget {
  final String texto;
  const _Rodape({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: AppTheme.fonte, fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}
