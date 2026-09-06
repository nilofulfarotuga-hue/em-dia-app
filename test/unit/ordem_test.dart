import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guarda contra uma armadilha do cliente do Supabase.
///
/// Em postgrest-dart, `order(coluna)` tem `ascending = false` por omissão.
/// Quem escreve `.order('data_limite')` a pensar "por ordem" recebe a lista ao
/// contrário. A 6 de setembro de 2026 isso pôs o painel a dizer
/// «próximo prazo: em 348 dias, 20 de agosto de 2027» quando o próximo prazo
/// era o dia 20 desse mesmo mês.
///
/// A regra da casa passou a ser: escreve-se sempre `ascending:` à mão, mesmo
/// quando é `true`. Este teste falha se alguém se esquecer.
void main() {
  test('O01 nenhuma chamada .order() esconde a direção', () {
    final raiz = Directory('lib');
    final faltas = <String>[];
    for (final f in raiz.listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final linhas = f.readAsLinesSync();
      for (var i = 0; i < linhas.length; i++) {
        final linha = linhas[i];
        if (linha.trimLeft().startsWith('//')) continue;
        if (!linha.contains('.order(')) continue;
        // A direção pode vir na mesma linha ou logo a seguir (chamadas partidas).
        final janela = linhas.skip(i).take(3).join(' ');
        if (!janela.contains('ascending')) {
          faltas.add('${f.path}:${i + 1}  ${linha.trim()}');
        }
      }
    }
    expect(faltas, isEmpty,
        reason: 'escreve `ascending: true` (ou false) à mão — o cliente do '
            'Supabase ordena ao contrário por omissão:\n${faltas.join('\n')}');
  });
}
