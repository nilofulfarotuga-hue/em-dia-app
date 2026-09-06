import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../services/arranque.dart';
import '../../stores/perfil_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';

/// Definições: como falo contigo (PT/BR), sair, apagar a conta, versão.
class DefinicoesScreen extends StatefulWidget {
  const DefinicoesScreen({super.key});

  @override
  State<DefinicoesScreen> createState() => _DefinicoesScreenState();
}

class _DefinicoesScreenState extends State<DefinicoesScreen> {
  String? _versao;
  bool _aGuardar = false;
  bool _erro = false;

  @override
  void initState() {
    super.initState();
    _lerVersao();
  }

  Future<void> _lerVersao() async {
    try {
      final i = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _versao = '${i.version} (${i.buildNumber})');
    } catch (_) {
      // Sem plugin (testes, web sem manifesto): fica sem versão, sem crash.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final perfilStore = context.watch<PerfilStore>();
    final perfil = perfilStore.perfil;
    final variante = perfil?.variantePt ?? 'pt';

    return Scaffold(
      appBar: AppBar(title: Text(l.defsTitulo)),
      body: ListView(
        padding: paddingEcra,
        children: [
          TituloSeccao(l.defsIdioma),
          Text(l.defsIdiomaAjuda, style: t.bodySmall),
          const SizedBox(height: 10),
          if (perfil == null) ...[
            Aviso(l.defsSemPerfil, icone: Icons.person_off_rounded),
            const SizedBox(height: 10),
          ],
          BotaoEscolha(
            key: const Key('defs_pt'),
            texto: l.defsPt,
            ajuda: l.defsPtAjuda,
            icone: Icons.record_voice_over_rounded,
            selecionado: variante == 'pt',
            aoTocar: () => _mudarVariante('pt'),
          ),
          const SizedBox(height: 10),
          BotaoEscolha(
            key: const Key('defs_br'),
            texto: l.defsBr,
            ajuda: l.defsBrAjuda,
            icone: Icons.record_voice_over_outlined,
            selecionado: variante == 'br',
            aoTocar: () => _mudarVariante('br'),
          ),
          if (_erro) ...[
            const SizedBox(height: 10),
            Aviso(l.erroRede, tom: Semaforo.vermelho),
          ],
          const SizedBox(height: 20),
          TituloSeccao(l.defsConta),
          Cartao(
            child: Row(
              children: [
                const Icon(Icons.person_rounded, color: AppColors.primaryDark, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(perfil?.email ?? '—', style: t.titleMedium, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(l.defsSairAjuda, style: t.bodySmall),
          const SizedBox(height: 8),
          BotaoGrande(
            key: const Key('defs_sair'),
            texto: l.sair,
            secundario: true,
            icone: Icons.logout_rounded,
            aTrabalhar: _aGuardar,
            aoTocar: _sair,
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              key: const Key('defs_apagar'),
              onPressed: _aGuardar ? null : _apagarConta,
              style: TextButton.styleFrom(foregroundColor: AppColors.danger, minimumSize: const Size(48, 48)),
              child: Text(l.defsApagarConta),
            ),
          ),
          if (_versao != null) ...[
            const SizedBox(height: 8),
            Center(child: Text(l.defsVersao(_versao!), style: t.bodySmall)),
          ],
        ],
      ),
    );
  }

  Future<void> _mudarVariante(String nova) async {
    final perfilStore = context.read<PerfilStore>();
    final perfil = perfilStore.perfil;
    if (perfil == null || perfil.variantePt == nova || _aGuardar) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _aGuardar = true;
      _erro = false;
    });
    final ok = await perfilStore.guardar(perfil.copyWith(variantePt: nova));
    if (!mounted) return;
    setState(() {
      _aGuardar = false;
      _erro = !ok;
    });
    if (ok) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.defsGuardado)));
  }

  Future<void> _sair() async {
    final sessao = context.read<SessaoStore>();
    final nav = Navigator.of(context);
    await sessao.sair();
    // O RaizNavegador troca o `home` para o login; o que estava por cima
    // (este ecrã) tem de sair do caminho.
    nav.popUntil((r) => r.isFirst);
  }

  Future<void> _apagarConta() async {
    final l = AppLocalizations.of(context);
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.defsApagarTitulo),
        content: Text(l.defsApagarTexto),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.cancelar)),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l.defsApagarConfirmar),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    final sessao = context.read<SessaoStore>();
    final mensageiro = ScaffoldMessenger.of(context);
    setState(() => _aGuardar = true);
    try {
      await sb.from('tickets_suporte').insert({
        'user_id': sessao.userId,
        'tipo': 'outro',
        'assunto': 'apagar conta',
        'descricao': 'Pedido feito na app (Definições → Apagar a minha conta). Apagar a conta e os dados em até 30 dias.',
      });
      mensageiro.showSnackBar(SnackBar(content: Text(l.defsApagarPedido)));
      if (mounted) await _sair();
    } catch (_) {
      if (mounted) setState(() => _aGuardar = false);
      mensageiro.showSnackBar(SnackBar(content: Text(l.erroRede)));
    }
  }
}
