import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../../services/compras.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';

const String _urlAssinaturasPlay = 'https://play.google.com/store/account/subscriptions';

/// Espelho do seed de `feature_flags` para quando o servidor ainda não
/// respondeu (o valor real vem sempre de [PlanoStore.limite]).
const int _limAvisosPadrao = 3;
const int _limCarrosPadrao = 1;
const int _limPerguntasPadrao = 5;
const int _membrosFamiliaPadrao = 5;

/// Tela 9 — O teu plano: o estado atual (trial / grátis / Pro / Família),
/// as duas ofertas com preços de `regras_legais`, e a compra pela Google Play
/// (isolada em [Compras]). Na web mostra só a mensagem `planoWeb`.
class PlanoScreen extends StatefulWidget {
  final DateTime? hoje;

  /// Loja injetada (testes e fotos). Sem ela: em Android cria a real; noutros
  /// sítios (web, desktop) não há loja e mostra-se a mensagem da web.
  final Compras? compras;
  const PlanoScreen({super.key, this.hoje, this.compras});

  @override
  State<PlanoScreen> createState() => _PlanoScreenState();
}

class _PlanoScreenState extends State<PlanoScreen> {
  Compras? _compras;
  bool _minha = false;
  bool _anual = false;

  @override
  void initState() {
    super.initState();
    if (widget.compras != null) {
      _compras = widget.compras;
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _compras = Compras();
      _minha = true;
      _compras!.iniciar();
    }
    _compras?.addListener(_aoMudarCompra);
  }

  @override
  void dispose() {
    _compras?.removeListener(_aoMudarCompra);
    if (_minha) _compras?.dispose();
    super.dispose();
  }

  void _aoMudarCompra() {
    if (!mounted) return;
    final c = _compras!;
    if (c.estado == EstadoCompra.feita) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.planoCompraOk)));
      final userId = context.read<SessaoStore>().userId;
      context.read<PlanoStore>().carregar(userId);
      c.limparEstado();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final regras = context.watch<RegrasStore>().regras;
    final plano = context.watch<PlanoStore>();
    final perfil = context.watch<PerfilStore>().perfil;
    final hoje = widget.hoje ?? hojeLisboa();
    final efetivo = plano.planoEfetivo;
    final c = _compras;
    final semLoja = c == null;
    final lojaIndisponivel = c != null && c.iniciado && !c.disponivel;

    final proMes = regras.n('preco_pro_mensal');
    final proAno = regras.n('preco_pro_anual');
    final famMes = regras.n('preco_familia_mensal');
    final famAno = regras.n('preco_familia_anual');

    return Scaffold(
      appBar: AppBar(title: Text(l.planoTitulo)),
      body: ListView(
        padding: paddingEcra,
        children: [
          Text(l.planoSubtitulo, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _EstadoAtual(plano: plano, trialAte: perfil?.trialAte, hoje: hoje),
          if (efetivo != 'familia') ...[
            const SizedBox(height: 16),
            if (semLoja)
              Aviso(l.planoWeb, icone: Icons.phone_android_rounded)
            else if (lojaIndisponivel)
              Aviso(l.planoLojaIndisponivel, tom: Semaforo.vermelho),
            if (semLoja || lojaIndisponivel) const SizedBox(height: 12),
            TituloSeccao(l.planoEscolhe),
            Row(
              children: [
                Expanded(
                  child: _Pilula(
                    key: const Key('plano_mes'),
                    texto: l.planoPorMes,
                    selecionada: !_anual,
                    aoTocar: () => setState(() => _anual = false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Pilula(
                    key: const Key('plano_ano'),
                    texto: l.planoPorAno,
                    selecionada: _anual,
                    aoTocar: () => setState(() => _anual = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (efetivo != 'pro') ...[
              _Oferta(
                chave: 'pro',
                nome: l.planoPro,
                precoMes: proMes,
                precoAno: proAno,
                anual: _anual,
                destaque: true,
                linhas: [
                  l.planoAbreAvisos,
                  l.planoAbreIa,
                  l.planoAbreFoto,
                  l.planoAbreComprovativos,
                  l.planoAbreCarros,
                  l.planoAbreExportar,
                  l.planoAbreReforma,
                ],
                botao: l.planoAtivarPro,
                aTrabalhar: c?.aTrabalhar ?? false,
                aoTocar: semLoja ? null : () => _comprar(_anual ? 'pro_anual' : 'pro_mensal'),
              ),
              const SizedBox(height: 12),
            ],
            _Oferta(
              chave: 'familia',
              nome: l.planoFamilia,
              precoMes: famMes,
              precoAno: famAno,
              anual: _anual,
              destaque: false,
              linhas: [l.planoFamiliaAbre(plano.limite('membros') ?? _membrosFamiliaPadrao)],
              botao: l.planoAtivarFamilia,
              aTrabalhar: c?.aTrabalhar ?? false,
              aoTocar: semLoja ? null : () => _comprar(_anual ? 'familia_anual' : 'familia_mensal'),
            ),
            if (c != null) ..._mensagemCompra(l, c),
          ],
          const SizedBox(height: 16),
          BotaoGrande(
            key: const Key('plano_gerir'),
            texto: l.planoGerir,
            secundario: true,
            icone: Icons.open_in_new_rounded,
            aoTocar: () => _abrir(_urlAssinaturasPlay),
          ),
          const SizedBox(height: 6),
          Text(l.planoCancelarQuando, style: t.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  List<Widget> _mensagemCompra(AppLocalizations l, Compras c) => switch (c.estado) {
        EstadoCompra.aComprar || EstadoCompra.aValidar => [
            const SizedBox(height: 12),
            Aviso(l.planoATrabalhar, tom: Semaforo.verde, icone: Icons.hourglass_top_rounded),
          ],
        EstadoCompra.erro => [const SizedBox(height: 12), Aviso(l.planoCompraErro, tom: Semaforo.vermelho)],
        EstadoCompra.cancelada => [
            const SizedBox(height: 12),
            Aviso(l.planoCompraCancelada, tom: Semaforo.verde, icone: Icons.info_outline_rounded),
          ],
        _ => const [],
      };

  Future<void> _comprar(String produtoId) async {
    final c = _compras;
    if (c == null || c.aTrabalhar) return;
    await c.comprar(produtoId);
  }

  Future<void> _abrir(String url) async {
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

/// O cartão do estado atual: trial (dias que faltam), grátis (os limites),
/// Pro ou Família (tudo aberto).
class _EstadoAtual extends StatelessWidget {
  final PlanoStore plano;
  final DateTime? trialAte;
  final DateTime hoje;
  const _EstadoAtual({required this.plano, required this.trialAte, required this.hoje});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final efetivo = plano.planoEfetivo;
    final Widget corpo;
    switch (efetivo) {
      case 'trial':
        final ate = trialAte ?? hoje;
        final dias = (soDia(ate).difference(soDia(hoje)).inDays + 1).clamp(0, 999);
        corpo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.faltamDias(dias), style: t.headlineLarge!.copyWith(color: AppColors.primaryDeep)),
            const SizedBox(height: 4),
            Text(l.planoTrial(dataExtensoPt(ate)), style: t.titleMedium),
            const SizedBox(height: 6),
            Text(l.planoTrialDepois, style: t.bodySmall),
          ],
        );
      case 'pro':
        corpo = _Linha(icone: Icons.verified_rounded, texto: l.planoTensPro, estilo: t.titleMedium);
      case 'familia':
        corpo = _Linha(
          icone: Icons.verified_rounded,
          texto: l.planoTensFamilia(plano.limite('membros') ?? _membrosFamiliaPadrao),
          estilo: t.titleMedium,
        );
      default:
        corpo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.planoFree, style: t.headlineSmall),
            const SizedBox(height: 8),
            _Linha(icone: Icons.notifications_rounded, texto: l.planoLimAvisos(plano.limite('avisos_push') ?? _limAvisosPadrao)),
            _Linha(icone: Icons.directions_car_rounded, texto: l.planoLimCarros(plano.limite('carros') ?? _limCarrosPadrao)),
            _Linha(icone: Icons.chat_bubble_rounded, texto: l.planoLimPerguntas(plano.limite('ia_perguntas') ?? _limPerguntasPadrao)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.lock_rounded, size: 18, color: AppColors.cadeado),
                const SizedBox(width: 6),
                Expanded(child: Text(l.planoLimResto, style: t.bodySmall)),
              ],
            ),
          ],
        );
    }
    return Cartao(
      key: Key('plano_estado_$efetivo'),
      cor: AppColors.primaryWash,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.planoEstadoTitulo.toUpperCase(),
              style: t.labelSmall!.copyWith(letterSpacing: 0.8, color: AppColors.primaryDeep)),
          const SizedBox(height: 6),
          corpo,
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final IconData icone;
  final String texto;
  final TextStyle? estilo;
  const _Linha({required this.icone, required this.texto, this.estilo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: AppColors.primaryDark),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: estilo ?? Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// Um cartão de oferta: nome, preço grande (mês ou ano), o que abre, botão.
class _Oferta extends StatelessWidget {
  final String chave;
  final String nome;
  final double precoMes;
  final double precoAno;
  final bool anual;
  final bool destaque;
  final List<String> linhas;
  final String botao;
  final bool aTrabalhar;
  final VoidCallback? aoTocar;
  const _Oferta({
    required this.chave,
    required this.nome,
    required this.precoMes,
    required this.precoAno,
    required this.anual,
    required this.destaque,
    required this.linhas,
    required this.botao,
    required this.aTrabalhar,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final poupanca = centimos(precoMes * 12 - precoAno);
    return Cartao(
      key: Key('plano_oferta_$chave'),
      bordo: destaque ? AppColors.primary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(nome, style: t.titleLarge)),
              if (anual && poupanca > 0)
                Etiqueta(l.planoPoupas(moeda(poupanca)), cor: AppColors.primaryLight, corTexto: AppColors.primaryDeep),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            anual ? l.planoPrecoAno(moeda(precoAno)) : l.planoPrecoMes(moeda(precoMes)),
            style: t.headlineMedium!.copyWith(color: AppColors.primaryDeep),
          ),
          const SizedBox(height: 10),
          for (final linha in linhas)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(linha, style: t.bodyMedium)),
                ],
              ),
            ),
          const SizedBox(height: 14),
          BotaoGrande(
            key: Key('plano_ativar_$chave'),
            texto: botao,
            secundario: !destaque,
            aTrabalhar: aTrabalhar,
            aoTocar: aoTocar,
          ),
        ],
      ),
    );
  }
}

/// Pílula de escolha (mês / ano) com alvo de 48 px; o texto quebra em vez de cortar.
class _Pilula extends StatelessWidget {
  final String texto;
  final bool selecionada;
  final VoidCallback aoTocar;
  const _Pilula({super.key, required this.texto, required this.selecionada, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionada ? AppColors.primaryLight : AppColors.surface2,
      borderRadius: AppTheme.cantosPequenos,
      child: InkWell(
        borderRadius: AppTheme.cantosPequenos,
        onTap: aoTocar,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selecionada) ...[
                const Icon(Icons.check_rounded, size: 20, color: AppColors.primaryDeep),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  texto,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fonte,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: selecionada ? AppColors.primaryDeep : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
