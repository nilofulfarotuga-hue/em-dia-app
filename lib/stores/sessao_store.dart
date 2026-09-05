import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/arranque.dart';

/// Sessão: quem está a usar a app. Login por e-mail com código de 6 números
/// (Supabase OTP) ou Google. Sem palavra-passe (decisão D4 em docs/DECISOES.md).
class SessaoStore extends ChangeNotifier {
  StreamSubscription<AuthState>? _sub;
  User? _user;
  bool _pronto = false;
  String? _erro;
  bool _aTrabalhar = false;
  String? _emailPendente;

  SessaoStore() {
    _user = sb.auth.currentUser;
    _pronto = true;
    _sub = sb.auth.onAuthStateChange.listen((estado) {
      _user = estado.session?.user;
      notifyListeners();
    });
  }

  User? get user => _user;
  String? get userId => _user?.id;
  bool get autenticado => _user != null;
  bool get pronto => _pronto;
  String? get erro => _erro;
  bool get aTrabalhar => _aTrabalhar;
  String? get emailPendente => _emailPendente;
  bool get googleDisponivel => googleWebClientId.isNotEmpty;

  void _comecar() {
    _aTrabalhar = true;
    _erro = null;
    notifyListeners();
  }

  void _acabar([String? erro]) {
    _aTrabalhar = false;
    _erro = erro;
    notifyListeners();
  }

  /// Passo 1: manda o código de 6 números para o e-mail.
  Future<bool> enviarCodigo(String email) async {
    _comecar();
    try {
      await sb.auth.signInWithOtp(
        email: email.trim().toLowerCase(),
        shouldCreateUser: true,
      );
      _emailPendente = email.trim().toLowerCase();
      _acabar();
      return true;
    } on AuthException catch (e) {
      _acabar(e.message);
      return false;
    } catch (e) {
      _acabar(e.toString());
      return false;
    }
  }

  /// Passo 2: confirma o código.
  Future<bool> confirmarCodigo(String codigo) async {
    final email = _emailPendente;
    if (email == null) {
      _acabar('Primeiro pede o código.');
      return false;
    }
    _comecar();
    try {
      final res = await sb.auth.verifyOTP(
        email: email,
        token: codigo.trim(),
        type: OtpType.email,
      );
      _user = res.user;
      _acabar();
      return _user != null;
    } on AuthException catch (e) {
      _acabar(e.message);
      return false;
    } catch (e) {
      _acabar(e.toString());
      return false;
    }
  }

  /// Google: idToken do Google → sessão Supabase.
  Future<bool> entrarComGoogle() async {
    if (!googleDisponivel) {
      _acabar('Login Google ainda não está configurado.');
      return false;
    }
    _comecar();
    try {
      final gs = GoogleSignIn.instance;
      await gs.initialize(serverClientId: googleWebClientId);
      final conta = await gs.authenticate();
      final idToken = conta.authentication.idToken;
      if (idToken == null) {
        _acabar('O Google não devolveu o token.');
        return false;
      }
      final res = await sb.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      _user = res.user;
      _acabar();
      return _user != null;
    } on AuthException catch (e) {
      _acabar(e.message);
      return false;
    } catch (e) {
      _acabar(e.toString());
      return false;
    }
  }

  Future<void> sair() async {
    await sb.auth.signOut();
    _user = null;
    _emailPendente = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
