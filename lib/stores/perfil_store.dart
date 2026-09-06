import 'package:flutter/foundation.dart';

import '../models/perfil.dart';
import '../services/arranque.dart';

/// O perfil do utilizador autenticado.
class PerfilStore extends ChangeNotifier {
  Perfil? _perfil;
  bool _aCarregar = false;
  String? _erro;

  Perfil? get perfil => _perfil;
  bool get aCarregar => _aCarregar;
  String? get erro => _erro;
  bool get temPerfil => _perfil != null;

  Future<void> carregar(String userId) async {
    _aCarregar = true;
    _erro = null;
    notifyListeners();
    try {
      // Com prazo: um pedido pendurado deixava a app num splash a rodar para
      // sempre. Ao fim de 20 s desiste e o ecrã mostra a saída.
      await _carregarComPrazo(userId).timeout(const Duration(seconds: 20));
    } catch (e) {
      _erro = e.toString();
    } finally {
      _aCarregar = false;
      notifyListeners();
    }
  }

  Future<void> _carregarComPrazo(String userId) async {
    final m = await sb.from('profiles').select().eq('user_id', userId).maybeSingle();
    if (m == null) {
      // O trigger cria o perfil no registo; se ainda não existir, cria agora.
      await sb.from('profiles').upsert({'user_id': userId, 'email': sb.auth.currentUser?.email});
      final m2 = await sb.from('profiles').select().eq('user_id', userId).single();
      _perfil = Perfil.fromMap(Map<String, dynamic>.from(m2));
    } else {
      _perfil = Perfil.fromMap(Map<String, dynamic>.from(m));
    }
    // último acesso (para a mensagem de reativação aos 7 dias)
    await sb.from('profiles').update({'ultimo_acesso': DateTime.now().toUtc().toIso8601String()}).eq('user_id', userId);
  }

  Future<bool> guardar(Perfil novo) async {
    try {
      await sb.from('profiles').update(novo.toUpdate()).eq('user_id', novo.userId);
      final m = await sb.from('profiles').select().eq('user_id', novo.userId).single();
      _perfil = Perfil.fromMap(Map<String, dynamic>.from(m));
      _erro = null;
      notifyListeners();
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  void limpar() {
    _perfil = null;
    notifyListeners();
  }
}
