// Convida um amigo (2026-09-24, missão em-dia-crescimento-organico).
//
// Duas pontas: (1) o amigo abre app.emdia.boraguarda.com/?c=CODIGO — o código é
// apanhado do endereço antes de a app arrancar e guardado nas preferências;
// (2) depois de entrar e de o perfil existir, o código é entregue ao servidor
// (RPC convite_aplicar), que liga o amigo ao convidador. O prémio (30 dias para
// os dois) é dado pelo servidor quando o amigo usa a app; nada disto escreve
// datas do lado do cliente.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'arranque.dart';

const String _chavePendente = 'emdia.convite_pendente';
const String _chaveAplicado = 'emdia.convite_aplicado';

class Convites {
  Convites._();

  /// Lê `?c=CODIGO` do endereço (só faz sentido na web) e guarda-o para depois.
  static Future<void> capturarDoEndereco() async {
    if (!kIsWeb) return;
    try {
      final c = Uri.base.queryParameters['c'];
      if (c == null || c.trim().isEmpty) return;
      final cod = c.trim().toUpperCase();
      if (!RegExp(r'^[A-Z0-9]{4,12}$').hasMatch(cod)) return;
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_chaveAplicado) == cod) return;
      await prefs.setString(_chavePendente, cod);
    } catch (e) {
      debugPrint('convites: nao apanhei o codigo do endereco: $e');
    }
  }

  /// Chamado quando o perfil já existe: entrega o código pendente ao servidor.
  /// Devolve o motivo do servidor (ligado, proprio, ja_convidado, …) ou null se não havia nada.
  static Future<String?> aplicarPendente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cod = prefs.getString(_chavePendente);
      if (cod == null || cod.isEmpty) return null;
      final r = await sb.rpc('convite_aplicar', params: {'p_codigo': cod});
      final m = r is Map ? Map<String, dynamic>.from(r) : <String, dynamic>{};
      final motivo = (m['motivo'] ?? '').toString();
      // Só se tenta uma vez por código: ligado ou recusado, sai da fila.
      await prefs.remove(_chavePendente);
      await prefs.setString(_chaveAplicado, cod);
      debugPrint('convites: codigo $cod -> $motivo');
      return motivo;
    } catch (e) {
      debugPrint('convites: aplicar falhou: $e');
      return null;
    }
  }

  /// O meu código, o meu link e os números para o ecrã «Convida e ganha».
  static Future<Map<String, dynamic>> meu() async {
    final r = await sb.rpc('convite_meu');
    return r is Map ? Map<String, dynamic>.from(r) : <String, dynamic>{};
  }
}
