import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/obrigacao.dart';
import 'package:em_dia/stores/dados_store.dart';

/// O painel não pode depender da ordem por que os itens chegam do servidor.
///
/// Cicatriz de 2026-09-06: `.order('data_limite')` no cliente do Supabase
/// devolve por ordem DECRESCENTE, e o painel — que lia o PRIMEIRO da lista —
/// anunciou «próximo prazo: em 348 dias, 20 de agosto de 2027» quando o
/// próximo era o dia 20 desse mesmo mês. O `ordem_test.dart` guarda a chamada
/// `.order`; este guarda a leitura, que é a outra metade: mesmo que a lista
/// venha ao contrário, o painel tem de dizer a mesma coisa.
void main() {
  final hoje = DateTime(2026, 9, 6);

  ObrigacaoItem item(String id, DateTime data, {String estado = 'pendente'}) => ObrigacaoItem(
        id: id,
        userId: 'u1',
        tipo: 'ss_pagamento',
        descricao: 'Segurança Social de $id',
        dataLimite: data,
        avisoEm: data.subtract(const Duration(days: 2)),
        estado: estado,
      );

  // De propósito fora de ordem, e com uma passada e duas futuras.
  final itens = [
    item('longe', DateTime(2027, 8, 20)),
    item('perto', DateTime(2026, 9, 20)),
    item('passada-antiga', DateTime(2026, 7, 20)),
    item('meio', DateTime(2026, 10, 20)),
    item('passada-recente', DateTime(2026, 8, 20)),
  ];

  test('P01 a próxima é a mais perto, venha a lista na ordem que vier', () {
    for (final lista in [itens, itens.reversed.toList()]) {
      final s = ObrigacoesStore.comoVeioDoServidor(lista);
      expect(s.proxima(hoje)?.id, 'perto',
          reason: 'o painel apanhou o item errado com a lista nesta ordem');
    }
  });

  test('P02 a primeira passada é a mais ANTIGA — é a mais urgente', () {
    for (final lista in [itens, itens.reversed.toList()]) {
      final s = ObrigacoesStore.comoVeioDoServidor(lista);
      expect(s.passadas(hoje).first.id, 'passada-antiga');
      expect(s.passadas(hoje).map((o) => o.id).toList(),
          ['passada-antiga', 'passada-recente']);
    }
  });

  test('P03 as que estão a vencer vêm da mais perto para a mais longe', () {
    final s = ObrigacoesStore.comoVeioDoServidor(itens.reversed.toList());
    final aVencer = s.aVencer(DateTime(2026, 9, 18)); // faltam 2 dias para o dia 20
    expect(aVencer.map((o) => o.id).toList(), ['perto']);
  });

  test('P04 os pendentes saem por data, mesmo ao contrário', () {
    final s = ObrigacoesStore.comoVeioDoServidor(itens.reversed.toList());
    final datas = s.pendentes(hoje).map((o) => o.dataLimite).toList();
    final ordenadas = List.of(datas)..sort();
    expect(datas, ordenadas);
  });

  test('P05 sem nada por vencer, a próxima é nula (e não rebenta)', () {
    final s = ObrigacoesStore.comoVeioDoServidor([
      item('paga', DateTime(2026, 9, 20), estado: 'pago'),
      item('velha', DateTime(2026, 7, 20)),
    ]);
    expect(s.proxima(hoje), isNull);
  });
}
