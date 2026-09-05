import 'package:flutter/foundation.dart';

import '../regras/regras.dart';
import '../services/arranque.dart';

/// As regras legais vindas do servidor (tabela `regras_legais` + escalões +
/// feriados). Arranca com o espelho do seed e troca pela versão do servidor
/// assim que a tiver — assim a calculadora funciona sem rede.
class RegrasStore extends ChangeNotifier {
  RegrasLegais _regras = RegrasLegais.padrao2026();
  bool _doServidor = false;
  DateTime? _atualizadoEm;

  RegrasLegais get regras => _regras;
  bool get doServidor => _doServidor;
  DateTime? get atualizadoEm => _atualizadoEm;

  Future<void> carregar() async {
    if (!temChaves) return;
    try {
      final rs = await sb.from('regras_legais').select();
      final es = await sb.from('irs_escaloes').select();
      final fs = await sb.from('feriados').select('data');
      final regras = (rs as List).map((m) => RegraLegal.fromMap(Map<String, dynamic>.from(m as Map))).toList();
      final escaloes = (es as List).map((m) => EscalaoIrs.fromMap(Map<String, dynamic>.from(m as Map))).toList();
      final feriados = (fs as List).map((m) => DateTime.parse((m as Map)['data'] as String)).toList();
      if (regras.isNotEmpty) {
        _regras = RegrasLegais(regras: regras, escaloes: escaloes, feriados: feriados);
        _doServidor = true;
        _atualizadoEm = DateTime.now();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('regras_legais: a usar o espelho local ($e)');
    }
  }
}

/// Cadeados por plano (tabela `feature_flags`) + plano efetivo do utilizador.
class PlanoStore extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _flags = {};
  String _planoEfetivo = 'free';
  bool _carregado = false;

  String get planoEfetivo => _planoEfetivo;
  bool get carregado => _carregado;
  bool get emTrial => _planoEfetivo == 'trial';
  bool get ehPago => _planoEfetivo == 'pro' || _planoEfetivo == 'familia';

  Future<void> carregar(String? userId) async {
    if (!temChaves) return;
    try {
      final fs = await sb.from('feature_flags').select();
      _flags
        ..clear()
        ..addEntries((fs as List).map((m) {
          final mm = Map<String, dynamic>.from(m as Map);
          return MapEntry(mm['chave'] as String, mm);
        }));
      if (userId != null) {
        final p = await sb.rpc('plano_efetivo', params: {'uid': userId});
        _planoEfetivo = (p as String?) ?? 'free';
      }
      _carregado = true;
      notifyListeners();
    } catch (e) {
      debugPrint('feature_flags: $e');
    }
  }

  /// A funcionalidade está aberta neste plano? (trial = tudo aberto)
  bool permitida(String chave) {
    if (_planoEfetivo == 'trial') return true;
    final f = _flags[chave];
    if (f == null) return true; // flag desconhecida: não se tranca por engano
    return switch (_planoEfetivo) {
      'familia' => (f['familia'] as bool?) ?? false,
      'pro' => (f['pro'] as bool?) ?? false,
      _ => (f['free'] as bool?) ?? false,
    };
  }

  /// Limite numérico (null = sem limite).
  int? limite(String chave) {
    if (_planoEfetivo == 'trial') return null;
    final f = _flags[chave];
    if (f == null) return null;
    final v = switch (_planoEfetivo) {
      'familia' => f['limite_familia'],
      'pro' => f['limite_pro'],
      _ => f['limite_free'],
    };
    return (v as num?)?.toInt();
  }
}
