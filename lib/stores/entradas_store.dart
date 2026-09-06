import 'package:flutter/foundation.dart';

import '../models/entrada.dart';
import '../services/arranque.dart';

/// O dinheiro que entra (tabela `entradas`).
///
/// Padrão Model → Store → Screen: o ecrã não fala com o Supabase, fala com
/// isto. A lista chega ordenada do mais recente para o mais antigo, que é a
/// ordem por que a pessoa quer ver ("o que ganhei ontem" está sempre no topo).
class EntradasStore extends ChangeNotifier {
  List<Entrada> _itens = [];
  bool _aCarregar = false;
  String? _erro;
  String? _userCarregado;

  List<Entrada> get itens => _itens;
  bool get aCarregar => _aCarregar;
  String? get erro => _erro;

  EntradasStore();

  /// Para testes e fotos (golden): itens já carregados, sem servidor.
  /// Ordena como o servidor faria, para o teste não depender da ordem em que
  /// alguém escreveu a lista à mão.
  EntradasStore.paraTeste(List<Entrada> itens, {String? erro})
      : _itens = List.of(itens)..sort((a, b) => b.data.compareTo(a.data)) {
    _erro = erro;
    _userCarregado = itens.isEmpty ? null : itens.first.userId;
  }

  // CICATRIZ herdada do resto da app: `.order('coluna')` sozinho devolve por
  // ordem DECRESCENTE no postgrest-dart. Aqui até queremos decrescente, mas
  // escreve-se `ascending: false` à mão na mesma — ninguém a ler isto tem de
  // adivinhar qual era o padrão.
  Future<void> carregar(String userId) async {
    _aCarregar = true;
    notifyListeners();
    try {
      final rows = await sb
          .from('entradas')
          .select()
          .eq('user_id', userId)
          .order('data', ascending: false)
          .order('criado_em', ascending: false);
      _itens = (rows as List).map((m) => Entrada.fromMap(Map<String, dynamic>.from(m as Map))).toList();
      _userCarregado = userId;
      _erro = null;
    } catch (e) {
      _erro = e.toString();
    } finally {
      _aCarregar = false;
      notifyListeners();
    }
  }

  /// Carrega só à primeira vez que o ecrã aparece (ou quando muda de conta).
  /// O arranque da app não puxa esta tabela; quem a precisa é este ecrã.
  Future<void> carregarSePreciso(String userId) async {
    if (_userCarregado == userId || _aCarregar) return;
    await carregar(userId);
  }

  Future<bool> guardar(Entrada e) async {
    try {
      await sb.from('entradas').upsert(e.toMap());
      await carregar(e.userId);
      return true;
    } catch (erro) {
      _erro = erro.toString();
      notifyListeners();
      return false;
    }
  }

  /// Apaga já da lista e só depois fala com o servidor: quem deslizou a linha
  /// vê-a desaparecer no momento. Se o servidor recusar, a lista volta ao que
  /// estava (o `carregar` traz a verdade) e o ecrã mostra o erro.
  Future<bool> apagar(Entrada e) async {
    final antes = List.of(_itens);
    _itens = _itens.where((x) => x.id != e.id).toList();
    notifyListeners();
    try {
      await sb.from('entradas').delete().eq('id', e.id);
      _erro = null;
      return true;
    } catch (erro) {
      _itens = antes;
      _erro = erro.toString();
      notifyListeners();
      return false;
    }
  }

  // ---- leituras para o ecrã ----

  /// As entradas de um mês, da mais recente para a mais antiga.
  List<Entrada> doMes(int ano, int mes) =>
      _itens.where((e) => e.data.year == ano && e.data.month == mes).toList()
        ..sort((a, b) => b.data.compareTo(a.data));

  double totalDoMes(int ano, int mes) =>
      doMes(ano, mes).fold(0.0, (s, e) => s + e.valor);

  double totalDoAno(int ano) =>
      _itens.where((e) => e.data.year == ano).fold(0.0, (s, e) => s + e.valor);

  /// Só o que conta para as Finanças — é este o número do IRS, não o total.
  double totalDoAnoParaIrs(int ano) => _itens
      .where((e) => e.data.year == ano && e.contaParaIrs)
      .fold(0.0, (s, e) => s + e.valor);

  /// Quilómetros escritos num mês (o que alimenta o "vale a pena esta corrida").
  int kmDoMes(int ano, int mes) =>
      doMes(ano, mes).fold(0, (s, e) => s + (e.km ?? 0));
}
