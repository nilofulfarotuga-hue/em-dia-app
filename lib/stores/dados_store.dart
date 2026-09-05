import 'package:flutter/foundation.dart';

import '../models/carro.dart';
import '../models/obrigacao.dart';
import '../models/rendimento.dart';
import '../regras/regras.dart';
import '../services/arranque.dart';

/// Obrigações do utilizador (o calendário). O servidor gera-as
/// (`calcular-obrigacoes`); aqui só se lêem, marcam como pagas e juntam
/// comprovativos.
class ObrigacoesStore extends ChangeNotifier {
  List<ObrigacaoItem> _itens = [];
  bool _aCarregar = false;
  String? _erro;

  List<ObrigacaoItem> get itens => _itens;
  bool get aCarregar => _aCarregar;
  String? get erro => _erro;

  Future<void> carregar(String userId) async {
    _aCarregar = true;
    notifyListeners();
    try {
      final rows = await sb
          .from('obrigacoes')
          .select()
          .eq('user_id', userId)
          .order('data_limite');
      _itens = (rows as List).map((m) => ObrigacaoItem.fromMap(Map<String, dynamic>.from(m as Map))).toList();
      _erro = null;
    } catch (e) {
      _erro = e.toString();
    } finally {
      _aCarregar = false;
      notifyListeners();
    }
  }

  /// Pede ao servidor para (re)gerar o calendário a partir do perfil.
  Future<bool> recalcular(String userId) async {
    try {
      await sb.functions.invoke('calcular-obrigacoes');
      await carregar(userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> marcarPaga(ObrigacaoItem o, {String? comprovativoUrl}) async {
    try {
      await sb.from('obrigacoes').update({
        'estado': 'pago',
        'pago_em': DateTime.now().toUtc().toIso8601String(),
        if (comprovativoUrl != null) 'comprovativo_url': comprovativoUrl,
      }).eq('id', o.id);
      await carregar(o.userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> desmarcarPaga(ObrigacaoItem o) async {
    try {
      await sb.from('obrigacoes').update({'estado': 'pendente', 'pago_em': null}).eq('id', o.id);
      await carregar(o.userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ---- leituras para o painel ----
  List<ObrigacaoItem> pendentes(DateTime hoje) => _itens.where((o) => o.pendente).toList();
  List<ObrigacaoItem> passadas(DateTime hoje) => _itens.where((o) => o.passou(hoje)).toList();
  List<ObrigacaoItem> aVencer(DateTime hoje, {int dias = 5}) => _itens
      .where((o) => o.pendente && !o.passou(hoje) && o.diasParaPrazo(hoje) <= dias)
      .toList();
  List<ObrigacaoItem> doMes(DateTime hoje) => _itens
      .where((o) => o.dataLimite.year == hoje.year && o.dataLimite.month == hoje.month)
      .toList();
  ObrigacaoItem? proxima(DateTime hoje) {
    final p = _itens.where((o) => o.pendente && !o.passou(hoje)).toList();
    return p.isEmpty ? null : p.first;
  }
}

/// Rendimentos mensais (para a vigia do IVA, a SS e o IRS).
class RendimentosStore extends ChangeNotifier {
  List<Rendimento> _itens = [];
  String? _erro;

  List<Rendimento> get itens => _itens;
  String? get erro => _erro;

  Future<void> carregar(String userId) async {
    try {
      final rows = await sb.from('rendimentos').select().eq('user_id', userId).order('mes', ascending: false);
      _itens = (rows as List).map((m) => Rendimento.fromMap(Map<String, dynamic>.from(m as Map))).toList();
      _erro = null;
    } catch (e) {
      _erro = e.toString();
    }
    notifyListeners();
  }

  Future<bool> guardar(Rendimento r) async {
    try {
      await sb.from('rendimentos').upsert(r.toMap());
      await carregar(r.userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> apagar(Rendimento r) async {
    try {
      await sb.from('rendimentos').delete().eq('id', r.id);
      await carregar(r.userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  double totalDoAno(int ano) =>
      _itens.where((r) => r.mes.year == ano).fold(0.0, (s, r) => s + r.valorBruto);

  double totalTrimestre(int ano, int trimestre) => _itens
      .where((r) => r.mes.year == ano && ((r.mes.month - 1) ~/ 3) + 1 == trimestre)
      .fold(0.0, (s, r) => s + r.valorBruto);

  double? doMes(int ano, int mes) {
    final l = _itens.where((r) => r.mes.year == ano && r.mes.month == mes);
    return l.isEmpty ? null : l.fold<double>(0.0, (s, r) => s + r.valorBruto);
  }

  /// Média mensal dos últimos [meses] meses com registo (para "quanto guardar").
  double? mediaMensal({int meses = 3}) {
    final l = _itens.take(meses).toList();
    if (l.isEmpty) return null;
    return l.fold(0.0, (s, r) => s + r.valorBruto) / l.length;
  }
}

/// Carros, abastecimentos e despesas.
class CarrosStore extends ChangeNotifier {
  List<Carro> _carros = [];
  final Map<String, List<Abastecimento>> _abastecimentos = {};
  final Map<String, List<DespesaCarro>> _despesas = {};
  String? _erro;

  List<Carro> get carros => _carros;
  String? get erro => _erro;
  List<Abastecimento> abastecimentosDe(String carroId) => _abastecimentos[carroId] ?? const [];
  List<DespesaCarro> despesasDe(String carroId) => _despesas[carroId] ?? const [];

  Future<void> carregar(String userId) async {
    try {
      final rows = await sb.from('carros').select().eq('user_id', userId).eq('ativo', true).order('criado_em');
      _carros = (rows as List).map((m) => Carro.fromMap(Map<String, dynamic>.from(m as Map))).toList();
      final ab = await sb.from('abastecimentos').select().eq('user_id', userId).order('data');
      _abastecimentos.clear();
      for (final m in ab as List) {
        final a = Abastecimento.fromMap(Map<String, dynamic>.from(m as Map));
        _abastecimentos.putIfAbsent(a.carroId, () => []).add(a);
      }
      final de = await sb.from('despesas_carro').select().eq('user_id', userId).order('data', ascending: false);
      _despesas.clear();
      for (final m in de as List) {
        final d = DespesaCarro.fromMap(Map<String, dynamic>.from(m as Map));
        _despesas.putIfAbsent(d.carroId, () => []).add(d);
      }
      _erro = null;
    } catch (e) {
      _erro = e.toString();
    }
    notifyListeners();
  }

  Future<Carro?> guardarCarro(Carro c) async {
    try {
      final m = await sb.from('carros').upsert(c.toMap()).select().single();
      await carregar(c.userId);
      return Carro.fromMap(Map<String, dynamic>.from(m));
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> apagarCarro(Carro c) async {
    try {
      await sb.from('carros').update({'ativo': false}).eq('id', c.id);
      await carregar(c.userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> guardarAbastecimento(String userId, Map<String, dynamic> dados) async {
    try {
      await sb.from('abastecimentos').insert({...dados, 'user_id': userId});
      await carregar(userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> guardarDespesa(String userId, Map<String, dynamic> dados) async {
    try {
      await sb.from('despesas_carro').insert({...dados, 'user_id': userId});
      await carregar(userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  CustoKm? custoKm(String carroId) => custoPorKm(abastecimentosDe(carroId).map((a) => a.linha).toList());
}
