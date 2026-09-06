import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/guia.dart';
import 'package:em_dia/screens/guias/guia_screen.dart';
import 'package:em_dia/screens/guias/guias_screen.dart';
import 'package:em_dia/stores/guias_store.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// Tela 6 — Guias: a lista (11 títulos), um guia com corpo real (passos,
/// negrito, fonte verificada) e um guia ainda "em breve".
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  const corpoPt = '''
# Antes de começar
Precisas do teu **NISS** (o número da Segurança Social) e da senha da Segurança Social Direta.

1. Entra em app.seg-social.pt com o NISS e a senha.
2. Vai a **Conta-corrente** e depois a Pagamentos.
3. Gera a referência Multibanco e paga na app do banco.

- Paga entre o dia 10 e o dia 20 do mês.
- Guarda o comprovativo: junta-o na app em "Já paguei".
''';

  const corpoBr = '''
# Antes de começar
Você precisa do seu **NISS** (o número da Segurança Social) e da senha da Segurança Social Direta.

1. Entre em app.seg-social.pt com o NISS e a senha.
2. Vá em **Conta-corrente** e depois em Pagamentos.
3. Gere a referência Multibanco e pague no app do banco.

- Pague entre o dia 10 e o dia 20 do mês.
- Guarde o comprovante: anexe no app em "Já paguei".
''';

  final comCorpo = Guia(
    slug: 'seguranca-social-direta',
    titulo: 'Segurança Social Direta passo a passo',
    categoria: 'ss',
    ordem: 50,
    corpoPt: corpoPt,
    corpoBr: corpoBr,
    fonteUrl: 'https://app.seg-social.pt/',
    verificadoEm: DateTime(2026, 9, 5),
  );

  List<Guia> itens() => [
        comCorpo,
        ...GuiasStore.guiasLocais().where((g) => g.slug != comCorpo.slug),
      ];

  testWidgets('guias: lista dos 11 títulos, 3 tamanhos, PT e BR', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'guias',
      tela: () => comStores(GuiasScreen(store: GuiasStore.paraTeste(itens())), perfil: perfilTeste()),
    );
    expect(find.byKey(const Key('guia_abrir-atividade')), findsOneWidget);
    expect(find.byKey(const Key('guia_seguranca-social-direta')), findsOneWidget);
    expect(find.byType(GuiaScreen), findsNothing);
  });

  testWidgets('guias: detalhe com passos, negrito e fonte verificada', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'guias_detalhe',
      tela: () => comStores(GuiaScreen(guia: comCorpo), perfil: perfilTeste()),
    );
    expect(find.byKey(const Key('guia_ouvir')), findsOneWidget);
    expect(find.byKey(const Key('guia_fonte')), findsOneWidget);
    expect(find.textContaining('app.seg-social.pt'), findsAtLeastNWidgets(1));
    expect(find.text('1'), findsOneWidget); // o círculo do passo 1
  });

  testWidgets('guias: guia ainda em breve (sem corpo, fonte por confirmar)', (tester) async {
    final emBreve = GuiasStore.guiasLocais().first;
    await fotografaSuite(
      tester,
      nome: 'guias_breve',
      tela: () => comStores(GuiaScreen(guia: emBreve), perfil: perfilTeste()),
    );
    expect(find.byKey(const Key('guia_fonte')), findsNothing);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  test('textoParaVoz tira as marcas e junta as frases', () {
    final voz = textoParaVoz(corpoPt);
    expect(voz, isNot(contains('**')));
    expect(voz, isNot(contains('#')));
    expect(voz, contains('Antes de começar'));
    expect(voz, contains('Entra em app.seg-social.pt'));
  });
}
