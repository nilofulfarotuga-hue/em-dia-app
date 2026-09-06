import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'arranque.dart';

/// Avisos por notificação (Firebase Cloud Messaging).
///
/// O servidor (`avisos-cron`) manda 1 aviso por obrigação por dia às 09:00 de
/// Lisboa para os tokens em `push_tokens`. Aqui só se: liga o Firebase (se a
/// build tiver google-services.json), pede a permissão POST_NOTIFICATIONS e
/// guarda o token do aparelho. Sem Firebase configurado nada rebenta — a app
/// funciona sem push e o cron regista `sem_token`.
class PushService {
  PushService._();

  static bool _ligado = false;
  static String? _token;

  static bool get ligado => _ligado;
  static String? get token => _token;

  /// Chamar depois do login. Idempotente.
  static Future<void> registar(String userId) async {
    if (kIsWeb) return; // web: sem push nesta fase (D10)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _ligado = true;
    } catch (e) {
      // Sem google-services.json (build sem Firebase): fica desligado, sem erro.
      debugPrint('push: Firebase não configurado ($e)');
      _ligado = false;
      return;
    }
    try {
      final fm = FirebaseMessaging.instance;
      final perm = await fm.requestPermission(alert: true, badge: true, sound: true);
      if (perm.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('push: permissão negada');
        return;
      }
      final t = await fm.getToken();
      if (t != null) await _guardar(userId, t);
      fm.onTokenRefresh.listen((novo) => _guardar(userId, novo));
    } catch (e) {
      debugPrint('push: $e');
    }
  }

  static Future<void> _guardar(String userId, String t) async {
    _token = t;
    if (!temChaves) return;
    try {
      await sb.from('push_tokens').upsert({
        'token': t,
        'user_id': userId,
        'plataforma': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        'atualizado_em': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('push_tokens: $e');
    }
  }

  /// Ao sair: apaga o token deste aparelho (não avisar quem já não está ligado).
  static Future<void> esquecer() async {
    final t = _token;
    if (t == null || !temChaves) return;
    try {
      await sb.from('push_tokens').delete().eq('token', t);
    } catch (_) {}
    _token = null;
  }
}
