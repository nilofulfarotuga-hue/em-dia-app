import 'package:flutter/material.dart';

/// Painel — ESQUELETO. Substituído pelo ecrã real no bloco 2.
class PainelScreen extends StatelessWidget {
  const PainelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel')),
      body: const Center(child: Text('Painel — em construção')),
    );
  }
}
