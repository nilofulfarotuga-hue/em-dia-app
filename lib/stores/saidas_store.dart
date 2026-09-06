import 'package:flutter/foundation.dart';

import '../models/saida.dart';
import '../regras/regras.dart';
import '../services/arranque.dart';

/// As contas a pagar: as saídas (a conta que existe todos os meses) e os
/// pagamentos (a conta deste mês).
///
/// Quem gera as contas do mês é o servidor (`gerar_pagamentos_do_mes`) —
/// aqui só se pede, se lê, e se marca como pago.
class SaidasStore extends ChangeNotifier {
  List<Saida> _saidas = [];
  List<SaidaPagamento> _pagamentos = [];
  bool _aCarregar = false;
  String? _erro;

  /// Todas as saídas, incluindo as desativadas — um pagamento antigo precisa
  /// do nome da conta mesmo depois de ela ter sido cancelada.
  List<Saida> get todas => _saidas;

  /// As que continuam a existir (são estas que aparecem na lista).
  List<Saida> get ativas => _saidas.where((s) => s.ativa).toList();

  List<SaidaPagamento> get pagamentos => _pagamentos;
  bool get aCarregar => _aCarregar;
  String? get erro => _erro;

  SaidasStore();

  /// Para testes e fotos (golden): já carregado, sem servidor. Ordena como o
  /// [carregar] faria — e é de propósito que ordena aqui: quem escrever um
  /// teste com a lista às avessas tem de ver o mesmo que a app mostra.
  SaidasStore.paraTeste(
    List<Saida> saidas, [
    List<SaidaPagamento> pagamentos = const [],
    String? erro,
  ])  : _saidas = List.of(saidas)..sort(_porNome),
        _pagamentos = List.of(pagamentos)..sort(_porDataLimite) {
    _erro = erro;
  }

  static int _porNome(Saida a, Saida b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
  static int _porDataLimite(SaidaPagamento a, SaidaPagamento b) =>
      a.dataLimite.compareTo(b.dataLimite);

  // CICATRIZ herdada do calendário (2026-09-06): no cliente do Supabase,
  // `.order('coluna')` sem mais nada devolve por ordem DECRESCENTE. Escreve-se
  // sempre `ascending:` à mão, mesmo quando é `true`.
  Future<void> carregar(String userId, {DateTime? hoje}) async {
    _aCarregar = true;
    notifyListeners();
    final dia = soDia(hoje ?? hojeLisboa());
    // Doze meses para trás chega e sobra: a app mostra este mês e o que ficou
    // por pagar atrás. Trazer a vida toda da pessoa a cada abertura de ecrã
    // seria pagar internet por dados que ninguém vai ler.
    final desde = DateTime(dia.year - 1, dia.month, 1);
    try {
      final linhasSaidas = await sb
          .from('saidas')
          .select()
          .eq('user_id', userId)
          .order('nome', ascending: true);
      _saidas = (linhasSaidas as List)
          .map((m) => Saida.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList();

      final linhasPagamentos = await sb
          .from('saidas_pagamentos')
          .select()
          .eq('user_id', userId)
          .gte('mes', dataPtIso(desde))
          .order('data_limite', ascending: true);
      _pagamentos = (linhasPagamentos as List)
          .map((m) => SaidaPagamento.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList();
      _erro = null;
    } catch (e) {
      _erro = e.toString();
    } finally {
      _aCarregar = false;
      notifyListeners();
    }
  }

  /// Pede ao servidor as contas deste mês (a partir das saídas ativas) e
  /// volta a ler. Chama-se depois de guardar uma conta nova, para a linha
  /// deste mês aparecer logo e não só no mês seguinte.
  Future<bool> gerarDoMes(String userId, {DateTime? mes}) async {
    try {
      await sb.rpc('gerar_pagamentos_do_mes', params: {
        'uid': userId,
        if (mes != null) 'mes_ref': dataPtIso(DateTime(mes.year, mes.month, 1)),
      });
      await carregar(userId, hoje: mes);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Grava uma conta (nova ou mudada) e devolve-a como ficou no servidor.
  Future<Saida?> guardar(Saida s) async {
    try {
      final m = await sb.from('saidas').upsert(s.toMap()).select().single();
      await carregar(s.userId);
      return Saida.fromMap(Map<String, dynamic>.from(m));
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Cancelar uma conta não é apagá-la: fica `ativa = false` para não voltar
  /// a gerar contas nos meses seguintes, mas o que já foi pago mantém-se.
  Future<bool> desativar(Saida s) async {
    try {
      await sb.from('saidas').update({'ativa': false}).eq('id', s.id);
      await carregar(s.userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// "Já paguei": estado a pago e a hora do momento.
  Future<bool> marcarPago(SaidaPagamento p, {double? valor}) async {
    try {
      await sb.from('saidas_pagamentos').update({
        'estado': 'pago',
        'pago_em': DateTime.now().toUtc().toIso8601String(),
        if (valor != null) 'valor': valor,
      }).eq('id', p.id);
      await carregar(p.userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Enganou-se a marcar. Volta a pendente.
  Future<bool> desmarcarPago(SaidaPagamento p) async {
    try {
      await sb
          .from('saidas_pagamentos')
          .update({'estado': 'pendente', 'pago_em': null}).eq('id', p.id);
      await carregar(p.userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Este mês não houve (o ginásio que se cancelou, a conta que não chegou).
  /// Não é pago nem é dívida: sai da soma sem ficar por resolver.
  Future<bool> saltar(SaidaPagamento p) async {
    try {
      await sb
          .from('saidas_pagamentos')
          .update({'estado': 'saltado', 'pago_em': null}).eq('id', p.id);
      await carregar(p.userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ---- leituras para o ecrã ----
  //
  // Todas devolvem pela data-limite, da mais perto para a mais longe, seja
  // qual for a ordem por que as linhas chegaram.
  static List<SaidaPagamento> _porData(Iterable<SaidaPagamento> l) =>
      List.of(l)..sort(_porDataLimite);

  /// A conta a que um pagamento pertence. A nulo só se a saída tiver
  /// desaparecido do servidor — o ecrã tem de aguentar isso sem rebentar.
  Saida? saidaDe(SaidaPagamento p) {
    for (final s in _saidas) {
      if (s.id == p.saidaId) return s;
    }
    return null;
  }

  String nomeDe(SaidaPagamento p) => saidaDe(p)?.nome ?? '';

  /// As contas do mês de [hoje], pela data-limite.
  List<SaidaPagamento> doMes(DateTime hoje) => _porData(
        _pagamentos.where((p) => p.mes.year == hoje.year && p.mes.month == hoje.month),
      );

  /// O que ficou para trás e continua por pagar (meses anteriores). Aparece
  /// junto com o mês porque uma conta atrasada não deixa de existir só por
  /// virar a página do calendário.
  List<SaidaPagamento> atrasadasDeAntes(DateTime hoje) => _porData(
        _pagamentos.where((p) =>
            p.pendente &&
            (p.mes.year < hoje.year || (p.mes.year == hoje.year && p.mes.month < hoje.month))),
      );

  /// O número grande do topo: quanto falta pagar este mês.
  ///
  /// Uma conta de valor variável ainda sem valor não entra na soma — inventar
  /// um número aqui era mentir à pessoa sobre o que tem de ter na conta.
  double faltaPagarDoMes(DateTime hoje) => doMes(hoje)
      .where((p) => p.contaParaFalta)
      .fold(0.0, (s, p) => s + (p.valor ?? 0));

  /// Quantas contas do mês ainda não têm valor (para o ecrã poder dizer
  /// "mais as que ainda não sabem o valor" em vez de calar).
  int semValorDoMes(DateTime hoje) =>
      doMes(hoje).where((p) => p.contaParaFalta && p.valor == null).length;

  /// Há alguma conta com o prazo passado? É isto que pinta o topo de vermelho.
  bool temAtrasadas(DateTime hoje) =>
      _pagamentos.any((p) => p.passou(hoje));

  /// Contas que vencem dentro de [dias] e ainda estão por pagar.
  List<SaidaPagamento> aVencer(DateTime hoje, {int dias = 5}) => _porData(
        _pagamentos.where(
          (p) => p.pendente && !p.passou(hoje) && p.diasParaPrazo(hoje) <= dias,
        ),
      );

  /// Contratos presos que acabam dentro de [dias] — é quando ainda dá para
  /// mudar de fornecedor sem multa (o mesmo que o `radar_fidelizacao` faz no
  /// servidor, mas com o que já está carregado).
  List<Saida> fidelizacoesAAcabar(DateTime hoje, {int dias = 30}) {
    final l = ativas.where((s) {
      final d = s.diasParaFidelizacao(hoje);
      return d != null && d >= 0 && d <= dias;
    }).toList();
    l.sort((a, b) => a.fimFidelizacao!.compareTo(b.fimFidelizacao!));
    return l;
  }
}
