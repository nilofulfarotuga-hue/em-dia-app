import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../screens/login/login_screen.dart';
import '../services/arranque.dart';
import '../stores/sessao_store.dart';
import 'admin_dados.dart';
import 'secoes/auditoria.dart';
import 'secoes/avisos.dart';
import 'secoes/ia.dart';
import 'secoes/regras_legais.dart';
import 'secoes/tickets.dart';
import 'secoes/usuarios.dart';
import 'secoes/visao_geral.dart';

/// Esqueleto do painel admin (PT-BR): login → verificação de admin → menu
/// lateral com as secções (lib/admin/secoes/).
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool? _ehAdmin;
  String? _userVerificado;
  int _seccao = 0;
  final _dados = AdminDados();

  Future<void> _verificar(String userId) async {
    if (_userVerificado == userId) return;
    _userVerificado = userId;
    try {
      final r = await sb.rpc('is_admin');
      if (mounted) setState(() => _ehAdmin = r == true);
    } catch (_) {
      if (mounted) setState(() => _ehAdmin = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sessao = context.watch<SessaoStore>();
    if (!sessao.autenticado) {
      _userVerificado = null;
      _ehAdmin = null;
      return const LoginScreen(modoAdmin: true);
    }
    if (_userVerificado != sessao.userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _verificar(sessao.userId!));
    }
    if (_ehAdmin == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_ehAdmin == false) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 56, color: AppColors.passou),
              const SizedBox(height: 12),
              Text(l.admNaoAdmin),
              const SizedBox(height: 16),
              TextButton(onPressed: sessao.sair, child: Text(l.sair)),
            ],
          ),
        ),
      );
    }
    return AdminMoldura(
      dados: _dados,
      seccao: _seccao,
      aoEscolher: (i) => setState(() => _seccao = i),
      aoSair: sessao.sair,
    );
  }
}

/// A moldura do painel: NavigationRail com as 7 secções + a secção ativa.
/// Separada do shell para ser fotografável sem sessão (golden).
class AdminMoldura extends StatelessWidget {
  final AdminDados dados;
  final int seccao;
  final ValueChanged<int> aoEscolher;
  final VoidCallback? aoSair;
  const AdminMoldura({super.key, required this.dados, required this.seccao, required this.aoEscolher, this.aoSair});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: seccao,
            onDestinationSelected: aoEscolher,
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primaryLight,
            selectedIconTheme: const IconThemeData(color: AppColors.primaryDark),
            selectedLabelTextStyle: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.primaryDark),
            unselectedLabelTextStyle: Theme.of(context).textTheme.labelSmall,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Icon(Icons.check_circle_rounded, color: AppColors.emDia, size: 36),
            ),
            destinations: [
              NavigationRailDestination(icon: const Icon(Icons.dashboard_rounded), label: Text(l.admNavVisaoGeral)),
              NavigationRailDestination(icon: const Icon(Icons.people_rounded), label: Text(l.admNavUsuarios)),
              NavigationRailDestination(icon: const Icon(Icons.gavel_rounded), label: Text(l.admNavRegras)),
              NavigationRailDestination(icon: const Icon(Icons.support_agent_rounded), label: Text(l.admNavTickets)),
              NavigationRailDestination(icon: const Icon(Icons.smart_toy_rounded), label: Text(l.admNavIa)),
              NavigationRailDestination(icon: const Icon(Icons.campaign_rounded), label: Text(l.admNavAvisos)),
              NavigationRailDestination(icon: const Icon(Icons.history_rounded), label: Text(l.admNavAuditoria)),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(onPressed: aoSair, icon: const Icon(Icons.logout_rounded), tooltip: l.sair),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: AdminSeccao(indice: seccao, dados: dados)),
        ],
      ),
    );
  }
}

/// A secção ativa.
class AdminSeccao extends StatelessWidget {
  final int indice;
  final AdminDados dados;
  const AdminSeccao({super.key, required this.indice, required this.dados});

  @override
  Widget build(BuildContext context) {
    return switch (indice) {
      0 => VisaoGeralSeccao(dados: dados),
      1 => UsuariosSeccao(dados: dados),
      2 => RegrasLegaisSeccao(dados: dados),
      3 => TicketsSeccao(dados: dados),
      4 => IaSeccao(dados: dados),
      5 => AvisosSeccao(dados: dados),
      _ => AuditoriaSeccao(dados: dados),
    };
  }
}
