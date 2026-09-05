import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../calendario/calendario_screen.dart';
import '../carro/carro_screen.dart';
import '../mais/mais_screen.dart';
import '../painel/painel_screen.dart';
import '../recibos/recibos_screen.dart';

/// As 5 abas: Painel · Recibos · Calendário · Carro · Mais.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ecras = const [PainelScreen(), RecibosScreen(), CalendarioScreen(), CarroScreen(), MaisScreen()];
    return Scaffold(
      body: IndexedStack(index: _aba, children: ecras),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.traffic_outlined), selectedIcon: const Icon(Icons.traffic_rounded), label: l.navPainel),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long_rounded), label: l.navRecibos),
          NavigationDestination(icon: const Icon(Icons.calendar_month_outlined), selectedIcon: const Icon(Icons.calendar_month_rounded), label: l.navCalendario),
          NavigationDestination(icon: const Icon(Icons.directions_car_outlined), selectedIcon: const Icon(Icons.directions_car_rounded), label: l.navCarro),
          NavigationDestination(icon: const Icon(Icons.more_horiz_rounded), selectedIcon: const Icon(Icons.more_horiz_rounded), label: l.navMais),
        ],
      ),
    );
  }
}
