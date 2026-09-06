import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/mensagem_ia.dart';
import '../services/arranque.dart';

/// Rodapés que o servidor cola ao fim da resposta. A tela já tem o rodapé
/// fixo (`iaRodape`), por isso tira-se daqui para não aparecer duas vezes.
const List<String> _rodapesServidor = [
  'Informação geral, não substitui contabilista.',
  'Informação geral, não substitui contador.',
];

/// Chat com o Em Dia (Tela 7). Fala com a Edge Function `ia-responder`
/// ({pergunta, modo}) e lê o histórico de `conversas_ia`.
///
/// Contrato provado (docs/provas/edge/ia-responder.md):
///   200 → {resposta, variante, fora_das_regras, ...}
///   402 → {limite: true, usadas, limite_valor, mensagem}  (plano grátis esgotado)
///   503 → {erro: 'sem_gemini_api_key', mensagem}          (assistente a descansar)
class IaStore extends ChangeNotifier {
  /// 'chat' (Tela 7) ou 'suporte' (Tela 8 → "Tenho uma dúvida").
  final String modo;

  List<MensagemIa> _mensagens = [];
  bool _aPensar = false;
  bool _limite = false;
  bool _aDescansar = false;
  String? _erro;
  int? _usadas;
  int? _limiteValor;
  bool _historicoCarregado = false;
  String? _perguntaDevolvida;

  IaStore({this.modo = 'chat'});

  /// Para testes e fotos (golden): conversa já feita, sem servidor.
  IaStore.paraTeste(
    List<MensagemIa> mensagens, {
    this.modo = 'chat',
    bool aPensar = false,
    bool limite = false,
    int? usadas,
    int? limiteValor,
    bool aDescansar = false,
    String? erro,
  }) : _mensagens = List.of(mensagens) {
    _aPensar = aPensar;
    _limite = limite;
    _usadas = usadas;
    _limiteValor = limiteValor;
    _aDescansar = aDescansar;
    _erro = erro;
    _historicoCarregado = true;
  }

  List<MensagemIa> get mensagens => List.unmodifiable(_mensagens);
  bool get aPensar => _aPensar;

  /// 402: o plano grátis esgotou as perguntas do mês.
  bool get limite => _limite;

  /// 503: o assistente está sem chave / a descansar.
  bool get aDescansar => _aDescansar;
  String? get erro => _erro;

  /// Perguntas de chat feitas este mês (só o modo 'chat' conta para o limite).
  int? get usadas => _usadas;

  /// Limite do plano, como o servidor o devolveu no 402 (null = desconhecido).
  int? get limiteValor => _limiteValor;
  bool get historicoCarregado => _historicoCarregado;

  /// Pergunta que falhou (402/503/erro) — a tela devolve-a ao campo de texto.
  /// Lê-se uma vez: fica a null depois.
  String? tomarPerguntaDevolvida() {
    final p = _perguntaDevolvida;
    _perguntaDevolvida = null;
    return p;
  }

  /// Últimas 20 conversas deste modo + contagem de perguntas de chat do mês.
  Future<void> carregarHistorico(String userId) async {
    if (_historicoCarregado || !temChaves) return;
    try {
      final rows = await sb
          .from('conversas_ia')
          .select('pergunta,resposta,fora_das_regras,criado_em')
          .eq('user_id', userId)
          .eq('modo', modo)
          .order('criado_em', ascending: false)
          .limit(20);
      final lista = <MensagemIa>[];
      for (final m in (rows as List).reversed) {
        final mm = Map<String, dynamic>.from(m as Map);
        final quando = DateTime.tryParse((mm['criado_em'] as String?) ?? '')?.toLocal();
        final pergunta = ((mm['pergunta'] as String?) ?? '').trim();
        if (pergunta.isEmpty) continue;
        lista.add(MensagemIa.utilizador(pergunta, quando: quando));
        final resposta = ((mm['resposta'] as String?) ?? '').trim();
        if (resposta.isNotEmpty) {
          lista.add(MensagemIa.emDia(limparRodape(resposta), foraDasRegras: mm['fora_das_regras'] == true, quando: quando));
        }
      }
      _mensagens = lista;

      final agora = DateTime.now();
      final inicioMes = DateTime(agora.year, agora.month, 1).toUtc().toIso8601String();
      final doMes = await sb
          .from('conversas_ia')
          .select('id')
          .eq('user_id', userId)
          .eq('modo', 'chat')
          .gte('criado_em', inicioMes);
      _usadas = (doMes as List).length;
      _historicoCarregado = true;
      _erro = null;
    } catch (e) {
      debugPrint('conversas_ia: $e');
    }
    notifyListeners();
  }

  /// Envia a pergunta. O balão do utilizador aparece já; o do Em Dia quando
  /// o servidor responder. Em falha, a pergunta sai da lista e fica em
  /// [tomarPerguntaDevolvida] para voltar ao campo.
  Future<void> perguntar(String pergunta) async {
    final p = pergunta.trim();
    if (p.isEmpty || _aPensar || _limite) return;
    _mensagens.add(MensagemIa.utilizador(p));
    _aPensar = true;
    _erro = null;
    _aDescansar = false;
    notifyListeners();
    try {
      final res = await sb.functions.invoke('ia-responder', body: {'pergunta': p, 'modo': modo});
      final dados = _comoMapa(res.data);
      final texto = ((dados['resposta'] as String?) ?? '').trim();
      if (texto.isEmpty) throw StateError('resposta_vazia');
      _mensagens.add(MensagemIa.emDia(limparRodape(texto), foraDasRegras: dados['fora_das_regras'] == true));
      final usadasServidor = dados['usadas'];
      if (usadasServidor is num) {
        _usadas = usadasServidor.toInt();
      } else if (modo == 'chat' && _usadas != null) {
        _usadas = _usadas! + 1;
      }
      final lim = dados['limite_valor'];
      if (lim is num) _limiteValor = lim.toInt();
    } on FunctionException catch (e) {
      final d = _comoMapa(e.details);
      _devolver(p);
      if (e.status == 402) {
        _limite = true;
        final u = d['usadas'];
        final lv = d['limite_valor'];
        if (u is num) _usadas = u.toInt();
        if (lv is num) _limiteValor = lv.toInt();
      } else if (e.status == 503) {
        _aDescansar = true;
      } else {
        _erro = (d['mensagem'] as String?) ?? e.toString();
      }
    } catch (e) {
      _devolver(p);
      _erro = e.toString();
    } finally {
      _aPensar = false;
      notifyListeners();
    }
  }

  void _devolver(String pergunta) {
    if (_mensagens.isNotEmpty && _mensagens.last.doUtilizador && _mensagens.last.texto == pergunta) {
      _mensagens.removeLast();
    }
    _perguntaDevolvida = pergunta;
  }

  /// Limpa a nota de erro / "a descansar" (depois de a tela a mostrar).
  void limparAviso() {
    if (_erro == null && !_aDescansar) return;
    _erro = null;
    _aDescansar = false;
    notifyListeners();
  }

  /// Tira o rodapé do servidor do fim da resposta (a tela já o mostra fixo).
  static String limparRodape(String texto) {
    var t = texto.trimRight();
    for (final r in _rodapesServidor) {
      if (t.endsWith(r)) t = t.substring(0, t.length - r.length).trimRight();
    }
    return t;
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
