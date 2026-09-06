import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/app.dart';
import 'package:em_dia/widgets/widgets.dart';

import 'fabrica_de_fotos.dart';

/// O ecrã que aparece quando a pessoa entrou mas a conta não abriu.
///
/// Existe por causa da cicatriz do Bora: quando o perfil não carregava, a app
/// ficava num splash a rodar para sempre e não havia por onde sair. Aqui há
/// sempre dois botões — tentar outra vez e sair.
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  testWidgets('conta-nao-abriu: 3 tamanhos, PT e BR', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'conta-nao-abriu',
      tela: () => ContaNaoAbriu(aoTentar: () async {}, aoSair: () async {}),
    );
    // "Sair" escreve-se igual em PT e BR; o botão de tentar muda de variante,
    // por isso conta-se pelo tipo. Nunca pode ficar só a roda a girar.
    expect(find.text('Sair'), findsOneWidget);
    expect(find.byType(BotaoGrande), findsNWidgets(2));
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
  });
}
