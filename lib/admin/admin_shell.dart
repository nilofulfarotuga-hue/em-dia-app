import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../screens/login/login_screen.dart';
import '../services/arranque.dart';
import '../stores/sessao_store.dart';

/// Esqueleto do painel admin (PT-BR): login → verificação de admin → menu
/// lateral com as secções. As secções vivem em lib/admin/secoes/ (bloco 2).
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool? _ehAdmin;
  String? _userVerificado;
  int _seccao = 0;

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
              const Text('Esta conta não é administradora.'),
              const SizedBox(height: 16),
              TextButton(onPressed: sessao.sair, child: const Text('Sair')),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _seccao,
            onDestinationSelected: (i) => setState(() => _seccao = i),
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Icon(Icons.check_circle_rounded, color: AppColors.emDia, size: 36),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_rounded), label: Text('Visão geral')),
              NavigationRailDestination(icon: Icon(Icons.people_rounded), label: Text('Usuários')),
              NavigationRailDestination(icon: Icon(Icons.gavel_rounded), label: Text('Regras legais')),
              NavigationRailDestination(icon: Icon(Icons.support_agent_rounded), label: Text('Tickets')),
              NavigationRailDestination(icon: Icon(Icons.smart_toy_rounded), label: Text('IA')),
              NavigationRailDestination(icon: Icon(Icons.campaign_rounded), label: Text('Avisos')),
              NavigationRailDestination(icon: Icon(Icons.history_rounded), label: Text('Auditoria')),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(onPressed: sessao.sair, icon: const Icon(Icons.logout_rounded), tooltip: 'Sair'),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: AdminSeccao(indice: _seccao)),
        ],
      ),
    );
  }
}

/// Secção ativa. Substituída pelas secções reais em lib/admin/secoes/.
class AdminSeccao extends StatelessWidget {
  final int indice;
  const AdminSeccao({super.key, required this.indice});

  @override
  Widget build(BuildContext context) {
    const nomes = ['Visão geral', 'Usuários', 'Regras legais', 'Tickets', 'IA', 'Avisos', 'Auditoria'];
    return Center(child: Text('${nomes[indice]} — em construção', style: Theme.of(context).textTheme.titleLarge));
  }
}
