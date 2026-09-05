import 'package:flutter/material.dart';

/// Carro — ESQUELETO. Substituído pelo ecrã real no bloco 2.
class CarroScreen extends StatelessWidget {
  const CarroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carro')),
      body: const Center(child: Text('Carro — em construção')),
    );
  }
}
