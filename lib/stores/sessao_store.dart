import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/arranque.dart';
import '../services/push.dart';

/// O que correu mal a entrar. Cada causa tem uma frase própria na app — dizer
/// sempre "não consegui entrar" escondia o problema a sério (o servidor
/// mandava um código de 8 números e o campo da app só aceitava 6, 2026-09-06).
enum ErroLogin {
  nenhum,
  emailInvalido,
  rede,
  muitosPedidos,
  codigoCurto,
  codigoErrado,
  codigoExpirado,
  generico,
}

/// Sessão: quem está a usar a app. Login por e-mail com código de 6 números
/// (Supabase OTP) ou Google. Sem palavra-passe (decisão D4 em docs/DECISOES.md).
///
/// O código tem de ter o mesmo tamanho aqui e no servidor
/// (`mailer_otp_length`). Se um dia mudar lá, muda [tamanhoCodigo] aqui.
class SessaoStore extends ChangeNotifier {
  /// Quantos números o código costuma ter (`mailer_otp_length` no Supabase).
  /// Serve para desenhar as casinhas e para enviar sozinho quando enche.
  static const int tamanhoCodigo = 6;

  /// Mas a app aceita de [tamanhoMinimo] a [tamanhoMaximo] números. Isto não é
  /// enfeite: a 6 de setembro de 2026 o servidor mandava 8 e o campo só deixava
  /// escrever 6 — ninguém conseguia entrar e o ecrã ficava preso. Com uma
  /// margem, se o tamanho lá mudar outra vez, a app continua a funcionar.
  static const int tamanhoMinimo = 4;
  static const int tamanhoMaximo = 8;

  /// O servidor só deixa pedir outro código passado 1 minuto. A app conta o
  /// tempo para não levar um 429 na cara de quem carrega duas vezes.
  static const int segundosEntrePedidos = 60;

  static final RegExp _emailOk = RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]{2,}$');
  static final RegExp _naoNumero = RegExp(r'\D');

  StreamSubscription<AuthState>? _sub;
  Timer? _relogio;
  User? _user;
  bool _pronto = false;
  ErroLogin _erro = ErroLogin.nenhum;
  String? _erroTecnico;
  bool _aTrabalhar = false;
  String? _emailPendente;
  int _reenviarEm = 0;

  SessaoStore() {
    _user = sb.auth.currentUser;
    _pronto = true;
    _sub = sb.auth.onAuthStateChange.listen((estado) {
      _user = estado.session?.user;
      notifyListeners();
    });
  }

  /// Para testes e fotos: sem Supabase, ninguém autenticado.
  SessaoStore.semServidor() : _pronto = true;

  User? get user => _user;
  String? get userId => _user?.id;
  bool get autenticado => _user != null;
  bool get pronto => _pronto;
  ErroLogin get erro => _erro;
  bool get temErro => _erro != ErroLogin.nenhum;

  /// A mensagem literal do servidor. Não se mostra a ninguém — serve para o
  /// `debugPrint` e para o relatório quando algo corre mal.
  String? get erroTecnico => _erroTecnico;
  bool get aTrabalhar => _aTrabalhar;
  String? get emailPendente => _emailPendente;

  /// Segundos que faltam para poder pedir outro código. 0 = já pode.
  int get reenviarEm => _reenviarEm;
  bool get podeReenviar => _reenviarEm == 0 && !_aTrabalhar;
  bool get googleDisponivel => googleWebClientId.isNotEmpty;

  void _comecar() {
    _aTrabalhar = true;
    _erro = ErroLogin.nenhum;
    _erroTecnico = null;
    notifyListeners();
  }

  void _acabar([ErroLogin erro = ErroLogin.nenhum, String? tecnico]) {
    _aTrabalhar = false;
    _erro = erro;
    _erroTecnico = tecnico;
    if (tecnico != null) debugPrint('SessaoStore: $erro — $tecnico');
    notifyListeners();
  }

  /// Limpa o aviso vermelho (ao voltar atrás ou ao escrever de novo).
  void limparErro() {
    if (_erro == ErroLogin.nenhum) return;
    _erro = ErroLogin.nenhum;
    _erroTecnico = null;
    notifyListeners();
  }

  /// Traduz o que o servidor devolveu para uma das causas que a app sabe
  /// explicar. Os códigos são os de
  /// https://supabase.com/docs/guides/auth/debugging/error-codes
  ErroLogin _classificar(Object e) {
    if (e is AuthRetryableFetchException) return ErroLogin.rede;
    if (e is AuthException) {
      final codigo = e.code ?? '';
      final msg = e.message.toLowerCase();
      if (codigo.contains('rate_limit') || e.statusCode == '429') {
        return ErroLogin.muitosPedidos;
      }
      if (codigo == 'otp_expired' || msg.contains('expired')) {
        return ErroLogin.codigoExpirado;
      }
      if (codigo == 'validation_failed' ||
          codigo == 'email_address_invalid' ||
          msg.contains('invalid email')) {
        return ErroLogin.emailInvalido;
      }
      if (codigo == 'otp_disabled' || codigo == 'invalid_credentials') {
        return ErroLogin.codigoErrado;
      }
      return ErroLogin.generico;
    }
    final texto = e.toString().toLowerCase();
    if (texto.contains('socket') ||
        texto.contains('failed host lookup') ||
        texto.contains('connection') ||
        texto.contains('clientexception')) {
      return ErroLogin.rede;
    }
    return ErroLogin.generico;
  }

  void _contarParaReenviar() {
    _relogio?.cancel();
    _reenviarEm = segundosEntrePedidos;
    _relogio = Timer.periodic(const Duration(seconds: 1), (t) {
      _reenviarEm--;
      if (_reenviarEm <= 0) {
        _reenviarEm = 0;
        t.cancel();
      }
      notifyListeners();
    });
  }

  /// Passo 1: manda o código de 6 números para o e-mail.
  Future<bool> enviarCodigo(String email) async {
    final limpo = email.trim().toLowerCase();
    if (!_emailOk.hasMatch(limpo)) {
      _acabar(ErroLogin.emailInvalido, 'e-mail fora do formato: "$limpo"');
      return false;
    }
    _comecar();
    try {
      await sb.auth.signInWithOtp(email: limpo, shouldCreateUser: true);
      _emailPendente = limpo;
      _acabar();
      _contarParaReenviar();
      return true;
    } catch (e) {
      _acabar(_classificar(e), e.toString());
      return false;
    }
  }

  /// Pede outro código para o mesmo e-mail. Só funciona depois do minuto.
  Future<bool> reenviarCodigo() async {
    final email = _emailPendente;
    if (email == null || !podeReenviar) return false;
    return enviarCodigo(email);
  }

  /// Passo 2: confirma o código. Aceita espaços e traços colados do e-mail.
  Future<bool> confirmarCodigo(String codigo) async {
    final email = _emailPendente;
    if (email == null) {
      _acabar(ErroLogin.generico, 'confirmarCodigo sem e-mail pendente');
      return false;
    }
    final numeros = codigo.replaceAll(_naoNumero, '');
    if (numeros.length < tamanhoMinimo || numeros.length > tamanhoMaximo) {
      _acabar(ErroLogin.codigoCurto, 'código com ${numeros.length} números');
      return false;
    }
    _comecar();
    try {
      final res = await sb.auth.verifyOTP(
        email: email,
        token: numeros,
        type: OtpType.email,
      );
      _user = res.user;
      if (_user == null) {
        _acabar(ErroLogin.codigoErrado, 'verifyOTP devolveu sessão sem user');
        return false;
      }
      _relogio?.cancel();
      _reenviarEm = 0;
      _acabar();
      return true;
    } catch (e) {
      _acabar(_classificar(e), e.toString());
      return false;
    }
  }

  /// Google: idToken do Google → sessão Supabase.
  Future<bool> entrarComGoogle() async {
    if (!googleDisponivel) {
      _acabar(ErroLogin.generico, 'GOOGLE_WEB_CLIENT_ID em falta nesta build');
      return false;
    }
    _comecar();
    try {
      final gs = GoogleSignIn.instance;
      await gs.initialize(serverClientId: googleWebClientId);
      final conta = await gs.authenticate();
      final idToken = conta.authentication.idToken;
      if (idToken == null) {
        _acabar(ErroLogin.generico, 'o Google não devolveu idToken');
        return false;
      }
      final res = await sb.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      _user = res.user;
      _acabar();
      return _user != null;
    } catch (e) {
      _acabar(_classificar(e), e.toString());
      return false;
    }
  }

  /// Volta ao passo do e-mail (escrevi o e-mail errado).
  void trocarEmail() {
    _emailPendente = null;
    _relogio?.cancel();
    _reenviarEm = 0;
    _erro = ErroLogin.nenhum;
    _erroTecnico = null;
    notifyListeners();
  }

  Future<void> sair() async {
    await PushService.esquecer();
    await sb.auth.signOut();
    _user = null;
    _emailPendente = null;
    _relogio?.cancel();
    _reenviarEm = 0;
    _erro = ErroLogin.nenhum;
    _erroTecnico = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _relogio?.cancel();
    super.dispose();
  }
}
