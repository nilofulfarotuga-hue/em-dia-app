import 'package:flutter/material.dart';

/// Calendário — ESQUELETO. Substituído pelo ecrã real no bloco 2.
class CalendarioScreen extends StatelessWidget {
  const CalendarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendário')),
      body: const Center(child: Text('Calendário — em construção')),
    );
  }
}
