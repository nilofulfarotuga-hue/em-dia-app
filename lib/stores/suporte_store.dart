import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ticket_suporte.dart';
import '../services/arranque.dart';

/// O que a Edge Function `suporte-auto` devolve (200).
class RespostaSuporte {
  final String ticketId;
  final String resposta;
  final bool escalado;
  final String estado;
  const RespostaSuporte({required this.ticketId, required this.resposta, this.escalado = false, this.estado = 'aberto'});

  String get idCurto => ticketId.length >= 8 ? ticketId.substring(0, 8) : ticketId;
}

/// Pedidos de ajuda (Tela 8). Cria tickets pela Edge Function `suporte-auto`
/// ({tipo, assunto, descricao, logs}) e lê os do utilizador em `tickets_suporte`.
///
/// Contrato provado (docs/provas/edge/suporte-auto.md):
///   200 → {ticket_id, resposta, escalado, estado, email}
///   400 → {erro, mensagem}
class SuporteStore extends ChangeNotifier {
  List<TicketSuporte> _tickets = [];
  bool _aCarregar = false;
  bool _aEnviar = false;
  String? _erro;
  bool _carregado = false;

  SuporteStore();

  /// Para testes e fotos (golden): tickets já carregados, sem servidor.
  SuporteStore.paraTeste(List<TicketSuporte> tickets, {bool aCarregar = false, String? erro})
      : _tickets = List.of(tickets)..sort((a, b) => b.criadoEm.compareTo(a.criadoEm)) {
    _aCarregar = aCarregar;
    _erro = erro;
    _carregado = true;
  }

  List<TicketSuporte> get tickets => List.unmodifiable(_tickets);
  bool get aCarregar => _aCarregar;
  bool get aEnviar => _aEnviar;
  String? get erro => _erro;
  bool get carregado => _carregado;

  Future<void> carregar(String userId) async {
    if (!temChaves) return;
    _aCarregar = true;
    notifyListeners();
    try {
      final rows = await sb
          .from('tickets_suporte')
          .select('id,tipo,assunto,descricao,estado,escalar_humano,resposta_ia,criado_em')
          .eq('user_id', userId)
          .order('criado_em', ascending: false)
          .limit(30);
      _tickets = (rows as List).map((m) => TicketSuporte.fromMap(Map<String, dynamic>.from(m as Map))).toList();
      _carregado = true;
      _erro = null;
    } catch (e) {
      _erro = e.toString();
    } finally {
      _aCarregar = false;
      notifyListeners();
    }
  }

  /// Cria um ticket. Devolve null em falha (e deixa a razão em [erro]).
  Future<RespostaSuporte?> enviar({
    required String tipo,
    required String assunto,
    String? descricao,
    String? logs,
    String? userId,
  }) async {
    final a = assunto.trim();
    if (a.isEmpty || _aEnviar) return null;
    _aEnviar = true;
    _erro = null;
    notifyListeners();
    try {
      final res = await sb.functions.invoke('suporte-auto', body: {
        'tipo': tipo,
        'assunto': a,
        if (descricao != null && descricao.trim().isNotEmpty) 'descricao': descricao.trim(),
        if (logs != null && logs.isNotEmpty) 'logs': logs,
      });
      final d = _comoMapa(res.data);
      final id = (d['ticket_id'] as String?) ?? '';
      if (id.isEmpty) throw StateError('sem_ticket_id');
      final r = RespostaSuporte(
        ticketId: id,
        resposta: ((d['resposta'] as String?) ?? '').trim(),
        escalado: d['escalado'] == true,
        estado: (d['estado'] as String?) ?? 'aberto',
      );
      _aEnviar = false;
      notifyListeners();
      if (userId != null) await carregar(userId);
      return r;
    } on FunctionException catch (e) {
      final d = _comoMapa(e.details);
      _erro = (d['mensagem'] as String?) ?? e.toString();
    } catch (e) {
      _erro = e.toString();
    }
    _aEnviar = false;
    notifyListeners();
    return null;
  }

  static Map<String, dynamic> _comoMapa(dynamic d) {
    if (d is Map) return Map<String, dynamic>.from(d);
    if (d is String && d.trim().startsWith('{')) {
      try {
        final j = jsonDecode(d);
        if (j is Map) return Map<String, dynamic>.from(j);
      } catch (_) {}
    }
    return const {};
  }
}
