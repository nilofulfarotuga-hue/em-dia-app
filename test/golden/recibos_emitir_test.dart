import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/screens/recibos/emitir_recibo_screen.dart';
import 'package:em_dia/screens/recibos/recibos_emitir_card.dart';
import 'package:em_dia/screens/recibos/recibos_screen.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// B2b (2026-09-18): passar a fatura-recibo certificada de dentro da app
/// (InvoiceXpress), atrás do interruptor `faturacao_certificada`.
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  test('NIF: o dígito de controlo apanha os enganos', () {
    expect(nifValido('123456789'), isTrue); // 1·9+2·8+3·7+4·6+5·5+6·4+7·3+8·2 = 156 → 156 % 11 = 2 → 9 ✓
    expect(nifValido('123456780'), isFalse);
    expect(nifValido('12345678'), isFalse);
    expect(nifValido('abcdefghi'), isFalse);
    expect(nifValido('501442600'), isTrue); // 5·9+0+1·7+4·6+4·5+2·4+6·3+0 = 122 → 122 % 11 = 1 → 0 ✓
  });

  testWidgets('passar fatura-recibo — o formulário já escrito, isento (art. 53.º)', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'recibos_passar_fatura',
      tela: () => comStores(
        const EmitirReciboScreen(nomeInicial: 'Uber B.V.', descricaoInicial: 'Serviço de transporte (TVDE)', valorInicial: '620'),
        perfil: perfilTeste(),
      ),
    );
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.byType(Switch), findsOneWidget);
    expect(find.textContaining('53'), findsOneWidget);
  });

  testWidgets('recibos — sem o interruptor ligado o cartão NÃO aparece', (tester) async {
    await fotografaTela(
      tester,
      nome: 'recibos_sem_fatura',
      tamanho: tamanhos[1],
      tela: () => comStores(RecibosScreen(hoje: DateTime(2026, 9, 18)), perfil: perfilTeste()),
    );
    expect(find.byKey(const Key('passar_fatura_card')), findsNothing);
  });

  testWidgets('o cartão «Passar a fatura-recibo daqui» sozinho', (tester) async {
    await fotografaTela(
      tester,
      nome: 'recibos_cartao_fatura',
      tamanho: tamanhos[1],
      tela: () => comStores(
        Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: CartaoPassarFatura(aoTocar: () {}))),
      ),
    );
    expect(find.byKey(const Key('passar_fatura_card')), findsOneWidget);
  });
}
