import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// O rascunho do onboarding — o que a pessoa já respondeu antes de carregar em
/// «Entrar na app».
///
/// A 17 de setembro de 2026 a Claude.ai fez o teste no Chrome: respondeu a 4
/// das 5 perguntas, escreveu a matrícula, recarregou a página e voltou à
/// pergunta 1. Nada era guardado antes do fim. Agora cada resposta fica em
/// dois sítios ao sair da pergunta: aqui (no aparelho, `shared_preferences`,
/// que na web é o `localStorage`) e no servidor (`profiles.onboarding_rascunho`,
/// pelo `PerfilStore`). Ao reabrir, ganha a cópia mais recente das duas.
///
/// Só rascunho: quando o onboarding acaba, apaga-se (`limpar`) e o perfil a
/// sério é o que manda.
class RascunhoOnboarding {
  static String _chave(String userId) => 'onboarding_rascunho_$userId';

  /// Guarda o rascunho com carimbo `guardado_em` (UTC ISO) para se comparar com o servidor.
  static Future<Map<String, dynamic>> guardar(String userId, Map<String, dynamic> dados) async {
    final m = Map<String, dynamic>.from(dados)..['guardado_em'] = DateTime.now().toUtc().toIso8601String();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chave(userId), jsonEncode(m));
    } catch (e) {
      debugPrint('rascunho onboarding: não guardou localmente ($e)');
    }
    return m;
  }

  static Future<Map<String, dynamic>?> ler(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_chave(userId));
      if (s == null || s.isEmpty) return null;
      final v = jsonDecode(s);
      return v is Map ? Map<String, dynamic>.from(v) : null;
    } catch (e) {
      debugPrint('rascunho onboarding: não leu localmente ($e)');
      return null;
    }
  }

  static Future<void> limpar(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chave(userId));
    } catch (_) {}
  }

  /// Dos dois rascunhos (aparelho e servidor), o mais recente pelo `guardado_em`.
  static Map<String, dynamic>? maisRecente(Map<String, dynamic>? local, Map<String, dynamic>? servidor) {
    if (local == null) return servidor;
    if (servidor == null) return local;
    final a = DateTime.tryParse('${local['guardado_em'] ?? ''}');
    final b = DateTime.tryParse('${servidor['guardado_em'] ?? ''}');
    if (a == null) return servidor;
    if (b == null) return local;
    return a.isAfter(b) ? local : servidor;
  }
}
