import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/screens/login/login_screen.dart';
import 'package:em_dia/stores/sessao_store.dart';
import 'package:provider/provider.dart';

import 'fabrica_de_fotos.dart';

/// Login por código de e-mail — a primeira tela que qualquer pessoa vê.
/// São dois passos, e os dois são fotografados: pedir o código e escrevê-lo.
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

  testWidgets('login-codigo: as casinhas do código em 3 tamanhos, PT e BR', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'login-codigo',
      comTeclado: true,
      tela: () => ChangeNotifierProvider<SessaoStore>(
        create: (_) => SessaoStoreNoCodigo(),
        child: const LoginScreen(),
      ),
    );
    // A saída ("Escrevi o e-mail errado") tem de estar sempre no ecrã, senão
    // quem escreve o e-mail errado fica preso — foi o que aconteceu a
    // 2026-09-06.
    expect(find.text('Escrevi o e-mail errado'), findsOneWidget);
  });
}

/// Sessão sem Supabase (as fotos não falam com o servidor).
class SessaoStoreFalso extends SessaoStore {
  SessaoStoreFalso() : super.semServidor();
}

/// Já pediu o código: mostra o passo das casinhas, com o minuto a contar.
class SessaoStoreNoCodigo extends SessaoStore {
  SessaoStoreNoCodigo() : super.semServidor();

  @override
  String? get emailPendente => 'joao.silva@gmail.com';
  @override
  int get reenviarEm => 42;
  @override
  bool get podeReenviar => false;
}
