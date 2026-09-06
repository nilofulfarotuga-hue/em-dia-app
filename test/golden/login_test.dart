import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/screens/login/login_screen.dart';
import 'package:em_dia/stores/sessao_store.dart';
import 'package:provider/provider.dart';

import 'fabrica_de_fotos.dart';

/// Login por código de e-mail — a primeira tela que qualquer pessoa vê.
void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  testWidgets('login: 3 tamanhos, com e sem teclado, PT e BR', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'login',
      comTeclado: true,
      tela: () => ChangeNotifierProvider<SessaoStore>(
        create: (_) => SessaoStoreFalso(),
        child: const LoginScreen(),
      ),
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}

/// Sessão sem Supabase (as fotos não falam com o servidor).
class SessaoStoreFalso extends SessaoStore {
  SessaoStoreFalso() : super.semServidor();
}
