import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/obrigacao.dart';
import 'package:em_dia/stores/dados_store.dart';

/// As regras do painel, escritas em pedra.
///
/// Cicatriz de 2026-09-06: o cartão anunciava «próximo prazo: em 348 dias,
/// 20 de agosto de 2027» enquanto havia coisas a vencer nessa mesma semana, e
/// o semáforo dizia "está tudo em dia". A causa era a lista vir do servidor ao
/// contrário e o código apanhar o primeiro item em vez do mais próximo.
///
/// Regra, tal como o Danilo a escreveu:
///   próximo prazo = obrigação pendente com a data mais próxima, sempre;
///   vermelho se houver prazo passado;
///   laranja se houver algo a menos de 5 dias;
///   verde só se não houver nada.
void main() {
  final hoje = DateTime(2026, 9, 6);

  ObrigacaoItem obr(String id, DateTime data, {String estado = 'pendente', String tipo = 'ss_pagamento'}) =>
      ObrigacaoItem(
        id: id,
        userId: 'u1',
        tipo: tipo,
        descricao: id,
        dataLimite: data,
        avisoEm: data,
        estado: estado,
      );

  // De propósito ao contrário: a mais longe primeiro, como o Supabase devolvia.
  List<ObrigacaoItem> aoContrario() => [
        obr('daqui-a-um-ano', DateTime(2027, 8, 20)),
        obr('daqui-a-um-mes', DateTime(2026, 10, 20)),
        obr('daqui-a-cinco-dias', DateTime(2026, 9, 11)),
        obr('daqui-a-dois-dias', DateTime(2026, 9, 8)),
        obr('daqui-a-um-dia', DateTime(2026, 9, 7)),
      ];

  test('P01 CICATRIZ: o próximo prazo é o mais perto, mesmo com a lista ao contrário', () {
    final s = ObrigacoesStore.comoVeioDoServidor(aoContrario());
    expect(s.proxima(hoje)!.id, 'daqui-a-um-dia');
    expect(s.proxima(hoje)!.diasParaPrazo(hoje), 1);
  });

  test('P02 as listas do painel saem sempre por ordem de data', () {
    final s = ObrigacoesStore.comoVeioDoServidor(aoContrario());
    expect(s.aVencer(hoje).map((o) => o.id).toList(),
        ['daqui-a-um-dia', 'daqui-a-dois-dias', 'daqui-a-cinco-dias']);
    expect(s.pendentes(hoje).first.id, 'daqui-a-um-dia');
    expect(s.doMes(hoje).map((o) => o.id).toList(),
        ['daqui-a-um-dia', 'daqui-a-dois-dias', 'daqui-a-cinco-dias']);
  });

  test('P03 laranja: há coisas a menos de 5 dias, logo NÃO está tudo em dia', () {
    final s = ObrigacoesStore.comoVeioDoServidor(aoContrario());
    expect(s.passadas(hoje), isEmpty);
    expect(s.aVencer(hoje), isNotEmpty, reason: 'com prazos a 1, 2 e 5 dias o semáforo não pode ficar verde');
  });

  test('P04 o dia exato conta: 5 dias entra, 6 dias não', () {
    final s = ObrigacoesStore.comoVeioDoServidor([
      obr('cinco', DateTime(2026, 9, 11)),
      obr('seis', DateTime(2026, 9, 12)),
    ]);
    expect(s.aVencer(hoje).map((o) => o.id).toList(), ['cinco']);
  });

  test('P05 vermelho: um prazo passado, e o primeiro da lista é o mais antigo', () {
    final s = ObrigacoesStore.comoVeioDoServidor([
      obr('passou-ontem', DateTime(2026, 9, 5)),
      obr('passou-ha-um-mes', DateTime(2026, 8, 5)),
      obr('daqui-a-um-dia', DateTime(2026, 9, 7)),
    ]);
    expect(s.passadas(hoje).map((o) => o.id).toList(), ['passou-ha-um-mes', 'passou-ontem']);
  });

  test('P06 o que já foi pago não conta para nada', () {
    final s = ObrigacoesStore.comoVeioDoServidor([
      obr('pago-e-passado', DateTime(2026, 8, 20), estado: 'pago'),
      obr('pago-e-perto', DateTime(2026, 9, 7), estado: 'pago'),
      obr('por-pagar', DateTime(2026, 9, 30)),
    ]);
    expect(s.passadas(hoje), isEmpty);
    expect(s.aVencer(hoje), isEmpty);
    expect(s.proxima(hoje)!.id, 'por-pagar');
  });

  test('P07 verde: sem nada pendente não há próximo prazo', () {
    final s = ObrigacoesStore.comoVeioDoServidor([]);
    expect(s.proxima(hoje), isNull);
    expect(s.passadas(hoje), isEmpty);
    expect(s.aVencer(hoje), isEmpty);
  });

  test('P08 o que vence hoje ainda não passou, mas é urgente', () {
    final s = ObrigacoesStore.comoVeioDoServidor([obr('hoje', DateTime(2026, 9, 6))]);
    expect(s.passadas(hoje), isEmpty, reason: 'hoje ainda dá para pagar');
    expect(s.aVencer(hoje).single.id, 'hoje');
    expect(s.proxima(hoje)!.diasParaPrazo(hoje), 0);
  });
}
