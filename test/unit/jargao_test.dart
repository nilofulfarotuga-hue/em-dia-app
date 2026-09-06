import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regra 1 do `CLAUDE.md`: na app, jargão só com explicação entre parênteses.
///
/// Isto passou despercebido até 2026-09-06: o **NIF** aparecia em oito textos e
/// não era explicado em lado nenhum — e a app é para quem chega de fora, onde
/// "NIF" não quer dizer nada. O juiz de visão apanhou-o, mas o juiz custa
/// dinheiro, é lento e às vezes engana-se. Isto é de graça, instantâneo e não
/// tem opinião: se uma sigla aparece nos textos, tem de estar explicada em pelo
/// menos um sítio, nas DUAS variantes.
void main() {
  /// Sigla → maneiras aceites de a explicar (além de `SIGLA (…)` logo a seguir).
  const siglas = <String, List<String>>{
    'IVA': ['valor acrescentado', 'imposto sobre o valor', 'imposto que'],
    'IRS': ['imposto sobre o rendimento', 'imposto do rendimento', 'imposto que pagas sobre',
            'imposto sobre o que'],
    'IUC': ['imposto do carro', 'imposto único', 'imposto unico'],
    'IPO': ['inspeção', 'inspecao', 'vistoria'],
    'NIF': ['contribuinte'],
    'NISS': ['segurança social', 'seguranca social'],
    'CAE': ['código de atividade', 'codigo de atividade', 'atividade económica'],
    'TVDE': ['uber', 'bolt', 'plataforma'],
    'IAS': ['indexante', 'valor de referência', 'valor de referencia'],
  };

  Map<String, String> textosDe(String caminho) {
    final bruto = jsonDecode(File(caminho).readAsStringSync()) as Map<String, dynamic>;
    return {
      for (final e in bruto.entries)
        if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
    };
  }

  /// Aparece a sigla como palavra inteira? (evita apanhar "IVA" dentro de "ativa")
  bool usa(String texto, String sigla) =>
      RegExp('(?<![A-Za-zÀ-ÿ])$sigla(?![A-Za-zÀ-ÿ])').hasMatch(texto);

  bool explica(String texto, String sigla, List<String> pistas) {
    if (RegExp('$sigla\\s*\\([^)]{4,}\\)', caseSensitive: false).hasMatch(texto)) return true;
    final minusculo = texto.toLowerCase();
    return pistas.any(minusculo.contains);
  }

  for (final ficheiro in const ['lib/l10n/app_pt.arb', 'lib/l10n/app_pt_BR.arb']) {
    test('J01 $ficheiro — nenhuma sigla usada fica por explicar', () {
      final textos = textosDe(ficheiro);
      expect(textos.length, greaterThan(500), reason: 'o ficheiro juntado parece vazio');

      final porExplicar = <String>[];
      siglas.forEach((sigla, pistas) {
        final usadaEm = textos.entries.where((e) => usa(e.value, sigla)).toList();
        if (usadaEm.isEmpty) return; // não aparece nos textos: nada a exigir
        final explicadaEm = usadaEm.where((e) => explica(e.value, sigla, pistas)).toList();
        if (explicadaEm.isEmpty) {
          porExplicar.add('$sigla — usada em ${usadaEm.length} texto(s) '
              '(${usadaEm.take(3).map((e) => e.key).join(', ')}) e nunca explicada');
        }
      });

      expect(porExplicar, isEmpty,
          reason: 'A app é para quem não percebe destas coisas. Explica a sigla à '
              'primeira vez, entre parênteses:\n${porExplicar.join('\n')}');
    });
  }

  test('J02 o NIF ficou mesmo explicado (a cicatriz de 2026-09-06)', () {
    for (final ficheiro in const ['lib/l10n/app_pt.arb', 'lib/l10n/app_pt_BR.arb']) {
      final textos = textosDe(ficheiro);
      final comExplicacao = textos.entries
          .where((e) => usa(e.value, 'NIF') && e.value.toLowerCase().contains('contribuinte'))
          .map((e) => e.key)
          .toList();
      expect(comExplicacao, isNotEmpty, reason: '$ficheiro: o NIF voltou a ficar por explicar');
    }
  });
}
