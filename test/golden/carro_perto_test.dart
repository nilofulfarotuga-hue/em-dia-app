import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/screens/carro/perto_screen.dart';
import 'package:em_dia/stores/perto_store.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// B2e (2026-09-18): «Perto de mim» — combustível mais barato (DGEG) e centros
/// de inspeção (IMT). Os números são os que a base devolveu a 18/09 para a
/// Guarda (postos_perto 40.537,-7.268 gasóleo simples 10 km; centros_perto).
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  const postos = [
    PostoPerto(id: 1, nome: 'PLENERGY Guarda Gare I', marca: 'PLENERGY', localidade: 'Guarda', municipio: 'Guarda', lat: 40.52, lng: -7.27, combustivel: 'Gasóleo simples', preco: 2.035, distanciaKm: 2.7),
    PostoPerto(id: 2, nome: 'PA Arrifana - Guarda', marca: 'PA', localidade: 'Arrifana', municipio: 'Guarda', lat: 40.50, lng: -7.30, combustivel: 'Gasóleo simples', preco: 2.065, distanciaKm: 7.2),
    PostoPerto(id: 3, nome: 'INTERMARCHÉ DA GUARDA', marca: 'INTERMARCHÉ', localidade: 'Guarda', municipio: 'Guarda', lat: 40.54, lng: -7.25, combustivel: 'Gasóleo simples', preco: 2.079, distanciaKm: 1.7),
  ];
  const centros = [
    CentroPerto(codigo: '1', nome: 'CIMA - GUARDA', localidade: 'GUARDA', distrito: 'Guarda', lat: 40.54, lng: -7.26, distanciaKm: 2.0),
    CentroPerto(codigo: '2', nome: 'BETOREL - GUARDA', localidade: 'SÃO MIGUEL DA GUARDA', distrito: 'Guarda', lat: 40.55, lng: -7.28, distanciaKm: 2.5),
    CentroPerto(codigo: '3', nome: 'TORRES & FILHO - TRANCOSO', localidade: 'SANTA MARIA', distrito: 'Guarda', lat: 40.78, lng: -7.35, distanciaKm: 26.6),
  ];

  testWidgets('perto de mim — postos mais baratos e centros, a partir do concelho', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'carro_perto',
      tela: () => embrulhaStores(
        tela: const PertoScreen(),
        perfil: perfilTeste(),
        perto: PertoStore.paraTeste(lat: 40.537, lng: -7.268, origem: OrigemLocal.concelho, concelho: 'Guarda', postos: postos, centros: centros),
      ),
    );
    expect(find.text('2,035 €'), findsOneWidget);
    expect(find.text('PLENERGY Guarda Gare I'), findsOneWidget);
    expect(find.text('CIMA - GUARDA'), findsOneWidget);
    // A fonte (DGEG/IMT) fica no fim da lista, fora do ecrã pequeno: vê-se nas fotos grandes.
  });

  testWidgets('perto de mim — antes de dizer onde está', (tester) async {
    await fotografaTela(
      tester,
      nome: 'carro_perto_vazio',
      tamanho: tamanhos[1],
      tela: () => embrulhaStores(tela: const PertoScreen(), perfil: perfilTeste()),
    );
    expect(find.text('Usar a minha localização'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('perto de mim — sem permissão, diz o que fazer', (tester) async {
    await fotografaTela(
      tester,
      nome: 'carro_perto_sem_permissao',
      tamanho: tamanhos[1],
      tela: () => embrulhaStores(tela: const PertoScreen(), perfil: perfilTeste(), perto: PertoStore.paraTeste(erro: 'sem_permissao')),
    );
    expect(find.textContaining('Sem permissão'), findsOneWidget);
  });
}
