import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/obrigacao.dart';
import 'package:em_dia/stores/dados_store.dart';

/// Defeito do prazo ao fim de semana na conta do mês (missão
/// fechar-tudo-2026-11-11, bloco 7).
///
/// Regra: um prazo do Estado que cai a sábado, domingo ou feriado cumpre-se no
/// dia útil seguinte. Fonte oficial (lida a 2026-11-11): AT, «Resumo anual —
/// Obrigações de pagamento em 2026», nota a): «Nos meses que terminam em fim
/// de semana ou feriado, a obrigação pode ser cumprida até ao dia útil
/// seguinte.» A mesma tabela põe o IUC de outubro a 2 de novembro.
/// https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Pag_2026.aspx
///
/// O caso real: IUC com dia legal sábado 31/10/2026 (domingo 1/11 é feriado),
/// prazo efetivo segunda 02/11/2026. A 02/11 é o último dia para pagar, mas o
/// «Este mês pagas…» do calendário contava pelo dia legal (outubro) e o IUC
/// sumia de novembro.
void main() {
  ObrigacaoItem iucDeOutubro() => ObrigacaoItem(
        id: 'iuc-out',
        userId: 'u1',
        tipo: 'iuc',
        descricao: 'IUC do carro',
        dataLimite: DateTime(2026, 10, 31),
        prazoEfetivo: DateTime(2026, 11, 2),
        avisoEm: DateTime(2026, 10, 30),
        valorEstimado: 58,
      );

  test('M01 o IUC de sábado 31/10 que passa para segunda 02/11 conta no mês de novembro', () {
    final s = ObrigacoesStore.paraTeste([iucDeOutubro()]);
    expect(s.doMes(DateTime(2026, 11, 2)).map((o) => o.id), ['iuc-out']);
  });

  test('M02 e já não conta em outubro: em outubro ainda se tem até 02/11', () {
    final s = ObrigacoesStore.paraTeste([iucDeOutubro()]);
    expect(s.doMes(DateTime(2026, 10, 20)), isEmpty);
  });

  test('M03 prazo que não mudou fica no mês do dia legal', () {
    final s = ObrigacoesStore.paraTeste([
      ObrigacaoItem(
        id: 'ss-nov',
        userId: 'u1',
        tipo: 'ss_pagamento',
        descricao: 'Segurança Social',
        dataLimite: DateTime(2026, 11, 20),
        avisoEm: DateTime(2026, 11, 20),
      ),
    ]);
    expect(s.doMes(DateTime(2026, 11, 2)).map((o) => o.id), ['ss-nov']);
  });
}
