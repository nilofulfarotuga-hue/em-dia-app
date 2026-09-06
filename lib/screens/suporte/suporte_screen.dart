import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/ticket_suporte.dart';
import '../../regras/regras.dart';
import '../../services/fala.dart';
import '../../stores/dados_store.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../stores/sessao_store.dart';
import '../../stores/suporte_store.dart';
import '../../widgets/widgets.dart';
import '../ia/ia_screen.dart';

const String _urlSubscricoesPlay = 'https://play.google.com/store/account/subscriptions';
const String _emailSuporte = 'suporte@emdia.pt';

/// Tela 8 — Ajuda. Três portas grandes ("Tenho uma dúvida" → IA em modo
/// suporte · "Algo não funciona" → formulário com logs automáticos ·
/// "Reembolso ou cancelar" → Google Play) + "Os meus pedidos".
class SuporteScreen extends StatefulWidget {
  /// Para testes e fotos: store já com tickets. Na app é criada aqui.
  final SuporteStore? store;
  const SuporteScreen({super.key, this.store});

  @override
  State<SuporteScreen> createState() => _SuporteScreenState();
}

class _SuporteScreenState extends State<SuporteScreen> {
  late final SuporteStore _store;
  late final bool _minha;

  @override
  void initState() {
    super.initState();
    _minha = widget.store == null;
    _store = widget.store ?? SuporteStore();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = context.read<SessaoStore>().userId;
      if (_minha && userId != null) _store.carregar(userId);
    });
  }

  @override
  void dispose() {
    if (_minha) _store.dispose();
    super.dispose();
  }

  Future<void> _abrir(Widget tela) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => tela));
    if (!mounted) return;
    final userId = context.read<SessaoStore>().userId;
    if (_minha && userId != null) _store.carregar(userId);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final tickets = _store.tickets;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text(l.suporteTitulo)),
          body: ListView(
            padding: paddingEcra,
            children: [
              Text(l.suporteIntro, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              BotaoEscolha(
                texto: l.suporteDuvida,
                ajuda: l.suporteDuvidaAjuda,
                icone: Icons.chat_bubble_outline_rounded,
                aoTocar: () => _abrir(const IaScreen(modo: 'suporte')),
              ),
              const SizedBox(height: 10),
              BotaoEscolha(
                texto: l.suporteBug,
                ajuda: l.suporteBugAjuda,
                icone: Icons.build_outlined,
                aoTocar: () => _abrir(SuporteBugScreen(store: _store)),
              ),
              const SizedBox(height: 10),
              BotaoEscolha(
                texto: l.suporteReembolso,
                ajuda: l.suporteReembolsoAjuda,
                icone: Icons.credit_card_off_outlined,
                aoTocar: () => _abrir(SuporteReembolsoScreen(store: _store)),
              ),
              const SizedBox(height: 24),
              TituloSeccao(l.suporteMeusPedidos),
              const SizedBox(height: 8),
              if (_store.aCarregar && tickets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5))),
                )
              else if (tickets.isEmpty)
                Vazio(icone: Icons.inbox_outlined, texto: l.suporteSemPedidos)
              else
                for (final t in tickets) ...[
                  _LinhaTicket(ticket: t),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mail_outline_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(l.suporteEmailRodape(_emailSuporte),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Nome humano do tipo e do estado de um ticket.
String _tipoTexto(AppLocalizations l, String tipo) => switch (tipo) {
      'duvida' => l.suporteTipoDuvida,
      'bug' => l.suporteTipoBug,
      'reembolso' => l.suporteTipoReembolso,
      'guia_novo' => l.suporteTipoGuia,
      _ => l.suporteTipoOutro,
    };

String _estadoTexto(AppLocalizations l, String estado) => switch (estado) {
      'fechado' => l.suporteEstadoFechado,
      'em_curso' => l.suporteEstadoEmCurso,
      _ => l.suporteEstadoAberto,
    };

Color _estadoCor(String estado) => switch (estado) {
      'fechado' => AppColors.emDia,
      'em_curso' => AppColors.info,
      _ => AppColors.textSecondary,
    };

IconData _tipoIcone(String tipo) => switch (tipo) {
      'duvida' => Icons.chat_bubble_outline_rounded,
      'bug' => Icons.build_outlined,
      'reembolso' => Icons.credit_card_off_outlined,
      'guia_novo' => Icons.auto_stories_outlined,
      _ => Icons.help_outline_rounded,
    };

class _LinhaTicket extends StatelessWidget {
  final TicketSuporte ticket;
  const _LinhaTicket({required this.ticket});

  void _detalhe(BuildContext context) {
    final l = AppLocalizations.of(context);
    // A folha abre no Navigator de raiz, acima das stores: o botão de ouvir
    // só encontra a voz e o perfil se eles forem com ela.
    final perfilStore = context.read<PerfilStore>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.raio))),
      builder: (ctx) => MultiProvider(
        providers: [
          ChangeNotifierProvider<PerfilStore>.value(value: perfilStore),
          ChangeNotifierProvider<Fala>.value(value: Fala.instancia),
        ],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Etiqueta(_estadoTexto(l, ticket.estado), cor: _estadoCor(ticket.estado)),
                    const SizedBox(width: 8),
                    Etiqueta(l.suporteTicket(ticket.idCurto), cor: AppColors.surface2, corTexto: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 12),
                Text(ticket.assunto, style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('${_tipoTexto(l, ticket.tipo)} · ${dataPt(ticket.criadoEm)}',
                    style: Theme.of(ctx).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary)),
                if ((ticket.respostaIa ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l.suporteRespostaTitulo,
                      style: const TextStyle(
                          fontFamily: AppTheme.fonte, fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Flexible(child: SingleChildScrollView(child: TextoIa(ticket.respostaIa!))),
                  // A resposta do Em Dia é uma explicação: dá para a ouvir.
                  BotaoOuvir(etiqueta: 'suporte-ticket-resposta', texto: ticket.respostaIa!),
                ],
                if (ticket.escalarHumano) ...[
                  const SizedBox(height: 12),
                  Aviso(l.suporteEscalado, tom: Semaforo.verde, icone: Icons.person_outline_rounded),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Cartao(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      aoTocar: () => _detalhe(context),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.surface2, shape: BoxShape.circle),
            child: Icon(_tipoIcone(ticket.tipo), size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.assunto,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: AppTheme.fonte, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text('${_tipoTexto(l, ticket.tipo)} · ${dataPt(ticket.criadoEm)}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Etiqueta(_estadoTexto(l, ticket.estado), cor: _estadoCor(ticket.estado)),
        ],
      ),
    );
  }
}

/// "Algo não funciona" — assunto + descrição; a app junta os logs sozinha.
class SuporteBugScreen extends StatefulWidget {
  final SuporteStore store;
  const SuporteBugScreen({super.key, required this.store});

  @override
  State<SuporteBugScreen> createState() => _SuporteBugScreenState();
}

class _SuporteBugScreenState extends State<SuporteBugScreen> {
  final _assunto = TextEditingController();
  final _descricao = TextEditingController();
  RespostaSuporte? _resposta;
  String? _erro;
  bool _aEnviar = false;

  @override
  void dispose() {
    _assunto.dispose();
    _descricao.dispose();
    super.dispose();
  }

  /// Versão da app, plataforma, utilizador, plano e os últimos erros dos
  /// stores. Nada de palavras-passe nem tokens.
  Future<String> _recolherLogs() async {
    final sessao = context.read<SessaoStore>();
    final plano = context.read<PlanoStore>();
    final erros = <String, String>{};
    void junta(String nome, String? e) {
      if (e != null && e.trim().isNotEmpty) erros[nome] = e.length > 300 ? e.substring(0, 300) : e;
    }

    junta('sessao', sessao.temErro ? '${sessao.erro.name}: ${sessao.erroTecnico}' : null);
    junta('perfil', context.read<PerfilStore>().erro);
    junta('obrigacoes', context.read<ObrigacoesStore>().erro);
    junta('rendimentos', context.read<RendimentosStore>().erro);
    junta('carros', context.read<CarrosStore>().erro);

    var versao = 'desconhecida';
    try {
      final info = await PackageInfo.fromPlatform();
      versao = '${info.version}+${info.buildNumber}';
    } catch (_) {}

    return jsonEncode({
      'versao': versao,
      'plataforma': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'modo': kReleaseMode ? 'release' : 'debug',
      'user_id': sessao.userId,
      'plano': plano.planoEfetivo,
      'erros': erros,
      'quando': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> _enviar() async {
    final l = AppLocalizations.of(context);
    if (_assunto.text.trim().isEmpty) {
      setState(() => _erro = l.suporteAssuntoEmFalta);
      return;
    }
    setState(() {
      _aEnviar = true;
      _erro = null;
    });
    final userId = context.read<SessaoStore>().userId;
    final logs = await _recolherLogs();
    final r = await widget.store.enviar(
      tipo: 'bug',
      assunto: _assunto.text,
      descricao: _descricao.text,
      logs: logs,
      userId: userId,
    );
    if (!mounted) return;
    setState(() {
      _aEnviar = false;
      _resposta = r;
      if (r == null) _erro = l.suporteErro;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = _resposta;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l.suporteBug)),
      body: r != null
          ? _Enviado(resposta: r)
          : ListView(
              padding: paddingEcra,
              children: [
                TextField(
                  controller: _assunto,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l.suporteAssunto, hintText: l.suporteAssuntoDica),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _descricao,
                  minLines: 4,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l.suporteDescreve,
                    hintText: l.suporteDescricaoDica,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                Aviso(l.suporteLogsNota, tom: Semaforo.verde, icone: Icons.shield_outlined),
                BotaoOuvir(etiqueta: 'suporte-o-que-vai-junto', texto: l.suporteLogsNota),
                if (_erro != null) ...[
                  const SizedBox(height: 10),
                  Aviso(_erro!, tom: Semaforo.vermelho, icone: Icons.error_outline_rounded),
                ],
                const SizedBox(height: 20),
                BotaoGrande(texto: l.suporteEnviar, icone: Icons.send_rounded, aTrabalhar: _aEnviar, aoTocar: _enviar),
              ],
            ),
    );
  }
}

/// Confirmação depois de criar o ticket: "Recebi." + n.º + resposta.
class _Enviado extends StatelessWidget {
  final RespostaSuporte resposta;
  const _Enviado({required this.resposta});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: paddingEcra,
      children: [
        const SizedBox(height: 8),
        const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.emDia),
        const SizedBox(height: 12),
        Text(l.suporteEnviado, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Center(
          child: Etiqueta(l.suporteTicket(resposta.idCurto), cor: AppColors.surface2, corTexto: AppColors.textSecondary),
        ),
        if (resposta.resposta.isNotEmpty) ...[
          const SizedBox(height: 16),
          Cartao(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.suporteRespostaTitulo,
                    style: const TextStyle(
                        fontFamily: AppTheme.fonte, fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextoIa(resposta.resposta),
                BotaoOuvir(etiqueta: 'suporte-resposta', texto: resposta.resposta),
              ],
            ),
          ),
        ],
        if (resposta.escalado) ...[
          const SizedBox(height: 12),
          Aviso(l.suporteEscalado, tom: Semaforo.verde, icone: Icons.person_outline_rounded),
        ],
        const SizedBox(height: 20),
        BotaoGrande(texto: l.suporteFechar, aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}

/// "Reembolso ou cancelar" — explica em 3 linhas que se faz na Google Play e
/// abre as subscrições; regista um ticket 'reembolso' para ficar o rasto.
class SuporteReembolsoScreen extends StatefulWidget {
  final SuporteStore store;
  const SuporteReembolsoScreen({super.key, required this.store});

  @override
  State<SuporteReembolsoScreen> createState() => _SuporteReembolsoScreenState();
}

class _SuporteReembolsoScreenState extends State<SuporteReembolsoScreen> {
  RespostaSuporte? _registo;
  bool _aRegistar = false;

  Future<void> _abrirSubscricoes() async {
    final l = AppLocalizations.of(context);
    final userId = context.read<SessaoStore>().userId;
    unawaited(launchUrl(Uri.parse(_urlSubscricoesPlay), mode: LaunchMode.externalApplication));
    if (_registo != null || _aRegistar || userId == null) return;
    setState(() => _aRegistar = true);
    final r = await widget.store.enviar(
      tipo: 'reembolso',
      assunto: l.suporteReembolso,
      descricao: l.suporteReembolsoDescricao,
      userId: userId,
    );
    if (!mounted) return;
    setState(() {
      _aRegistar = false;
      _registo = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final linhas = [l.suporteReembolsoLinha1, l.suporteReembolsoLinha2, l.suporteReembolsoLinha3];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l.suporteReembolso)),
      body: ListView(
        padding: paddingEcra,
        children: [
          const SizedBox(height: 4),
          const Icon(Icons.storefront_outlined, size: 56, color: AppColors.primary),
          const SizedBox(height: 16),
          Cartao(
            child: Column(
              children: [
                for (var i = 0; i < linhas.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                fontFamily: AppTheme.fonte,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(linhas[i], style: Theme.of(context).textTheme.bodyLarge)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // As três linhas são UMA explicação: um só botão para as ouvir.
          BotaoOuvir(etiqueta: 'suporte-reembolso', texto: linhas.join('. ')),
          const SizedBox(height: 12),
          BotaoGrande(
            texto: l.suporteAbrirSubscricoes,
            icone: Icons.open_in_new_rounded,
            aTrabalhar: _aRegistar,
            aoTocar: _abrirSubscricoes,
          ),
          if (_registo != null) ...[
            const SizedBox(height: 12),
            Aviso(l.suporteRegistado(_registo!.idCurto), tom: Semaforo.verde, icone: Icons.check_circle_outline_rounded),
          ],
          const SizedBox(height: 10),
          BotaoGrande(texto: l.suporteFechar, secundario: true, aoTocar: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}
