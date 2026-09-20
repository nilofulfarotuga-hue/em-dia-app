import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/perfil.dart';
import 'package:em_dia/services/uso.dart';

Perfil _perfil({required bool consentiu}) => Perfil(
      userId: '00000000-0000-4000-8000-000000000001',
      trialAte: DateTime(2026, 9, 30),
      criadoEm: DateTime(2026, 8, 31),
      consentiuEstatisticas: consentiu,
    );

void main() {
  test('sem consentimento não toca no cliente e não lança', () async {
    await Uso.registar(EventoUso.abriuApp, perfil: _perfil(consentiu: false), cliente: null);
  });

  test('converte enum para os textos da tabela', () {
    expect(EventoUso.values.map(Uso.tipoDb).toList(), [
      'abriu_app',
      'concluiu_onboarding',
      'viu_plano',
      'iniciou_compra',
      'comprou',
      'cancelou',
    ]);
  });

  test('com consentimento, erro do cliente não propaga', () async {
    await Uso.registar(EventoUso.comprou, perfil: _perfil(consentiu: true), cliente: null);
  });
}
