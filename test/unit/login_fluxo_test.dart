import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:em_dia/config/app_theme.dart';
import 'package:em_dia/l10n/app_localizations.dart';
import 'package:em_dia/screens/login/login_screen.dart';
import 'package:em_dia/stores/sessao_store.dart';

/// O fluxo de entrar, testado à unha.
///
/// Cicatriz de 2026-09-06: o servidor mandava um código de 8 números e o campo
/// da app só deixava escrever 6. Ninguém entrava, e quem voltava atrás batia no
/// limite de 1 minuto sem perceber porquê — o ecrã ficava preso. Estes testes
/// existem para isso não voltar a passar sem alguém dar por ela.
void main() {
  Future<SessaoFalsa> abre(WidgetTester tester, {Locale locale = const Locale('pt')}) async {
    final s = SessaoFalsa();
    await tester.pumpWidget(
      ChangeNotifierProvider<SessaoStore>.value(
        value: s,
        child: MaterialApp(
          theme: AppTheme.claro,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return s;
  }

  testWidgets('L01 e-mail certo leva às casinhas do código', (tester) async {
    final s = await abre(tester);
    await tester.enterText(find.byType(TextField), '  Teste@Exemplo.PT ');
    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();

    expect(s.emailEnviado, 'teste@exemplo.pt', reason: 'tira espaços e põe em minúsculas');
    expect(find.text('teste@exemplo.pt'), findsOneWidget);
    expect(find.text('Confirmar'), findsOneWidget);
  });

  testWidgets('L02 um código de 6 números confirma sozinho', (tester) async {
    final s = await abre(tester);
    await s.enviarCodigo('teste@exemplo.pt');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '510570');
    await tester.pump(const Duration(milliseconds: 600));

    expect(s.codigosRecebidos, ['510570']);
  });

  testWidgets('L03 CICATRIZ: um código de 8 números também entra', (tester) async {
    final s = await abre(tester);
    await s.enviarCodigo('teste@exemplo.pt');
    await tester.pumpAndSettle();

    // Escreve os 8 seguidos, como quem cola do e-mail.
    await tester.enterText(find.byType(TextField), '12521272');
    await tester.pump(const Duration(milliseconds: 600));

    expect(s.codigosRecebidos.last, '12521272',
        reason: 'o campo tem de aceitar mais do que 6 números');
    expect(SessaoStore.tamanhoMaximo >= 8, isTrue);
  });

  testWidgets('L04 voltar ao e-mail nunca deixa o ecrã preso', (tester) async {
    final s = await abre(tester);
    await s.enviarCodigo('teste@exemplo.pt');
    s.poeErro(ErroLogin.codigoErrado);
    await tester.pumpAndSettle();
    expect(find.textContaining('Esse código não bate certo'), findsOneWidget);

    await tester.tap(find.text('Escrevi o e-mail errado'));
    await tester.pumpAndSettle();

    expect(find.text('Enviar código'), findsOneWidget, reason: 'voltou ao passo do e-mail');
    expect(find.textContaining('Esse código não bate certo'), findsNothing,
        reason: 'o vermelho antigo não fica agarrado ao ecrã');
  });

  testWidgets('L05 cada erro tem a sua frase', (tester) async {
    final s = await abre(tester);
    final frases = {
      ErroLogin.emailInvalido: 'Esse e-mail não parece certo',
      ErroLogin.muitosPedidos: 'Pediste códigos a mais',
      ErroLogin.codigoExpirado: 'já passou da validade',
      ErroLogin.codigoCurto: 'Faltam números',
      ErroLogin.rede: 'Sem ligação',
    };
    for (final entrada in frases.entries) {
      s.poeErro(entrada.key);
      await tester.pumpAndSettle();
      expect(find.textContaining(entrada.value), findsOneWidget,
          reason: 'o erro ${entrada.key.name} tem de dizer a sua causa');
    }
  });

  testWidgets('L06 enquanto o minuto não passa, diz quanto falta', (tester) async {
    final s = await abre(tester);
    await s.enviarCodigo('teste@exemplo.pt');
    s.poeContagem(42);
    await tester.pumpAndSettle();

    expect(find.textContaining('42'), findsOneWidget);
    expect(find.text('Não chegou? Enviar outro código'), findsNothing);

    s.poeContagem(0);
    await tester.pumpAndSettle();
    expect(find.text('Não chegou? Enviar outro código'), findsOneWidget);
  });

  testWidgets('L07 em PT-BR as frases mudam de variante', (tester) async {
    final s = await abre(tester, locale: const Locale('pt', 'BR'));
    s.poeErro(ErroLogin.muitosPedidos);
    await tester.pumpAndSettle();
    expect(find.textContaining('Você pediu códigos demais'), findsOneWidget);
  });

  test('L10 e-mails que nao recebem correio nem saem do telemovel', () async {
    // Cicatriz de 2026-09-06: sete de quinze envios do Em Dia falharam, todos
    // para `test@gmail.com` e `newuser@gmail.com`, escritos a experimentar o
    // registo. Cada devolucao gasta a reputacao do dominio que manda os codigos
    // de entrada a toda a gente, e o `test@gmail.com` acabou na lista negra da
    // Resend. Estes nunca mais saem daqui.
    const naoRecebem = [
      'test@gmail.com',
      'newuser@gmail.com',
      'teste@hotmail.com',
      'demo@outlook.com',
      'noreply@gmail.com',
      'alguem@example.com',
      'e2e_admin@boraapp.test',
      'x@qualquercoisa.invalid',
      'y@servidor.local',
    ];
    for (final mau in naoRecebem) {
      expect(SessaoStore.enderecoDeMentira(mau), isTrue, reason: '"$mau" nao recebe correio');
      final s = SessaoStore.semServidor();
      expect(await s.enviarCodigo(mau), isFalse);
      expect(s.erro, ErroLogin.emailDeMentira);
    }
  });

  test('L11 e as pessoas a serio passam, incluindo a forma certa de testar', () {
    // `nome+etiqueta@gmail.com` chega mesmo a caixa de quem a escreveu: e ESTA
    // a maneira de fazer testes sem partir nada.
    const recebem = [
      'danilo@gmail.com',
      'boraappbora+ocr@gmail.com',
      'test.silva@umaempresa.pt',
      'maria@sapo.pt',
      'joao@boraguarda.com',
      'testador@empresa.com',
    ];
    for (final bom in recebem) {
      expect(SessaoStore.enderecoDeMentira(bom), isFalse, reason: '"$bom" e um endereco a serio');
    }
  });

  testWidgets('L12 o e-mail do revisor da Google troca o código por palavra-passe', (tester) async {
    // O revisor da Play não tem caixa de e-mail; sem entrar, a Google rejeita
    // a app. Só ESTE e-mail vê um campo de palavra-passe e um botão "Entrar".
    final s = await abre(tester);
    s.revisor = 'revisor@emdia.pt';
    await tester.enterText(find.byType(TextField), ' Revisor@EmDia.pt ');
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget, reason: 'o botão passa a "Entrar"');
    expect(find.text('Enviar código'), findsNothing);
    expect(find.byType(TextField), findsNWidgets(2), reason: 'e-mail + palavra-passe');

    await tester.enterText(find.byType(TextField).at(1), 'segredo');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(s.entradaComPalavraPasse, ['revisor@emdia.pt', 'segredo']);
    expect(s.emailEnviado, isNull, reason: 'o revisor nunca pede código');
  });

  testWidgets('L13 quem não é o revisor nunca vê a palavra-passe', (tester) async {
    final s = await abre(tester);
    s.revisor = 'revisor@emdia.pt';
    await tester.enterText(find.byType(TextField), 'outro@emdia.pt');
    await tester.pumpAndSettle();

    expect(find.text('Enviar código'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('L14 o anti-robô e a palavra-passe errada têm frase própria', (tester) async {
    final s = await abre(tester);
    s.poeErro(ErroLogin.antiRobo);
    await tester.pumpAndSettle();
    expect(find.textContaining('não és um robô'), findsOneWidget);

    // O mesmo ErroLogin.codigoErrado tem duas caras: no ecrã do revisor
    // (sem código pendente) é a palavra-passe que está errada.
    s.revisor = 'revisor@emdia.pt';
    await tester.enterText(find.byType(TextField), 'revisor@emdia.pt');
    s.poeErro(ErroLogin.codigoErrado);
    await tester.pumpAndSettle();
    expect(find.text('Palavra-passe errada.'), findsOneWidget);
  });

  test('L15 ehRevisor ignora maiúsculas e espaços; sem e-mail na build nunca é', () {
    final semRevisor = SessaoStore.semServidor();
    expect(semRevisor.ehRevisor('revisor@emdia.pt'), isFalse,
        reason: 'os testes correm sem EMAIL_REVISOR');
    final s = SessaoFalsa()..revisor = 'Revisor@EmDia.pt';
    expect(s.ehRevisor('  revisor@emdia.pt '), isTrue);
    expect(s.ehRevisor('outro@emdia.pt'), isFalse);
  });

  test('L08 o tamanho do código da app cobre o do servidor', () {
    // O servidor manda 6 (mailer_otp_length). A margem existe para o dia em
    // que alguém lá mexer sem avisar.
    expect(SessaoStore.tamanhoCodigo, 6);
    expect(SessaoStore.tamanhoMinimo, lessThan(SessaoStore.tamanhoCodigo));
    expect(SessaoStore.tamanhoMaximo, greaterThan(SessaoStore.tamanhoCodigo));
  });

  test('L09 e-mails torcidos não chegam a sair do telemóvel', () async {
    final s = SessaoStore.semServidor();
    for (final mau in ['', 'sem-arroba', 'a@b', 'a@@b.pt', 'espaço @b.pt']) {
      expect(await s.enviarCodigo(mau), isFalse, reason: '"$mau" devia ser recusado');
      expect(s.erro, ErroLogin.emailInvalido);
    }
  });
}

/// Sessão de mentira: guarda o que lhe pedem, não fala com servidor nenhum.
class SessaoFalsa extends SessaoStore {
  SessaoFalsa() : super.semServidor();

  String? emailEnviado;
  final List<String> codigosRecebidos = [];
  int reenvios = 0;
  ErroLogin _erro = ErroLogin.nenhum;
  int _contagem = 0;

  @override
  String? get emailPendente => emailEnviado;
  @override
  ErroLogin get erro => _erro;
  @override
  bool get temErro => _erro != ErroLogin.nenhum;
  @override
  bool get aTrabalhar => false;
  @override
  int get reenviarEm => _contagem;
  @override
  bool get podeReenviar => _contagem == 0;
  @override
  bool get googleDisponivel => false;

  /// O e-mail do revisor da Google, fingido (na build vem do EMAIL_REVISOR).
  String revisor = '';
  @override
  String get emailDoRevisor => revisor;

  /// [e-mail, palavra-passe] da última entrada por palavra-passe.
  List<String>? entradaComPalavraPasse;

  @override
  Future<bool> enviarCodigo(String email, {String? captchaToken}) async {
    emailEnviado = email.trim().toLowerCase();
    _erro = ErroLogin.nenhum;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> reenviarCodigo({String? captchaToken}) async {
    reenvios++;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> entrarComPalavraPasse(
    String email,
    String palavraPasse, {
    String? captchaToken,
  }) async {
    entradaComPalavraPasse = [email.trim().toLowerCase(), palavraPasse];
    _erro = ErroLogin.nenhum;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> confirmarCodigo(String codigo) async {
    codigosRecebidos.add(codigo);
    notifyListeners();
    return true;
  }

  @override
  void trocarEmail() {
    emailEnviado = null;
    _erro = ErroLogin.nenhum;
    notifyListeners();
  }

  @override
  void limparErro() {
    if (_erro == ErroLogin.nenhum) return;
    _erro = ErroLogin.nenhum;
    notifyListeners();
  }

  void poeErro(ErroLogin e) {
    _erro = e;
    notifyListeners();
  }

  void poeContagem(int segundos) {
    _contagem = segundos;
    notifyListeners();
  }
}
