import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'arranque.dart';

/// Estado de uma compra na Google Play, do ponto de vista do ecrã.
enum EstadoCompra { parado, aComprar, aValidar, feita, erro, cancelada, lojaIndisponivel }

/// Compras na Google Play (assinaturas Pro / Família), isoladas do ecrã.
///
/// Fluxo: [iniciar] pergunta à loja se está disponível, pede os 4 produtos e
/// fica a ouvir o `purchaseStream`; [comprar] abre a folha de pagamento da
/// Play; quando a compra chega, o recibo vai ao servidor
/// (`validar-compra-play`) e só depois se completa a compra na loja. O
/// servidor é quem manda: sem validação não há plano.
class Compras extends ChangeNotifier {
  static const Set<String> produtos = {'pro_mensal', 'pro_anual', 'familia_mensal', 'familia_anual'};

  final InAppPurchase? _iap;
  final Map<String, String> _precosTeste;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  final Map<String, ProductDetails> _detalhes = {};
  bool _disponivel = false;
  bool _iniciado = false;
  EstadoCompra _estado = EstadoCompra.parado;
  String? _erro;
  String? _produtoFeito;

  /// A loja real (só faz sentido em Android).
  Compras() : _iap = InAppPurchase.instance, _precosTeste = const {};

  /// Para testes e fotos: nunca fala com a loja nem com o servidor.
  Compras.paraTeste({bool disponivel = true, Map<String, String> precos = const {}})
      : _iap = null,
        _precosTeste = precos {
    _disponivel = disponivel;
    _iniciado = true;
  }

  bool get disponivel => _disponivel;
  bool get iniciado => _iniciado;
  EstadoCompra get estado => _estado;
  String? get erro => _erro;
  String? get produtoFeito => _produtoFeito;
  bool get aTrabalhar => _estado == EstadoCompra.aComprar || _estado == EstadoCompra.aValidar;

  /// Preço tal como a loja o mostra (já na moeda do utilizador), se o tivermos.
  String? precoLoja(String produtoId) => _detalhes[produtoId]?.price ?? _precosTeste[produtoId];

  Future<void> iniciar() async {
    final iap = _iap;
    if (iap == null) return;
    try {
      _disponivel = await iap.isAvailable();
      if (!_disponivel) {
        _estado = EstadoCompra.lojaIndisponivel;
      } else {
        _sub ??= iap.purchaseStream.listen(_aoMudar, onError: (Object e) {
          _estado = EstadoCompra.erro;
          _erro = e.toString();
          notifyListeners();
        });
        final r = await iap.queryProductDetails(produtos);
        for (final pd in r.productDetails) {
          _detalhes[pd.id] = pd;
        }
        if (r.notFoundIDs.isNotEmpty) debugPrint('compras: produtos em falta na Play: ${r.notFoundIDs}');
      }
    } catch (e) {
      _disponivel = false;
      _estado = EstadoCompra.lojaIndisponivel;
      _erro = e.toString();
    } finally {
      _iniciado = true;
      notifyListeners();
    }
  }

  /// Abre a folha de pagamento da Play. Devolve false se não deu para abrir.
  Future<bool> comprar(String produtoId) async {
    final iap = _iap;
    _erro = null;
    if (iap == null || !_disponivel) {
      _estado = EstadoCompra.lojaIndisponivel;
      notifyListeners();
      return false;
    }
    final pd = _detalhes[produtoId];
    if (pd == null) {
      _estado = EstadoCompra.erro;
      _erro = 'produto $produtoId não encontrado na Play';
      notifyListeners();
      return false;
    }
    _estado = EstadoCompra.aComprar;
    notifyListeners();
    try {
      // Assinaturas compram-se como "não consumível" no plugin.
      return await iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: pd));
    } catch (e) {
      _estado = EstadoCompra.erro;
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _aoMudar(List<PurchaseDetails> lista) async {
    for (final p in lista) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _estado = EstadoCompra.aComprar;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _estado = EstadoCompra.aValidar;
          notifyListeners();
          await _validar(p);
        case PurchaseStatus.error:
          _estado = EstadoCompra.erro;
          _erro = p.error?.message;
        case PurchaseStatus.canceled:
          _estado = EstadoCompra.cancelada;
      }
      if (p.pendingCompletePurchase) {
        try {
          await _iap?.completePurchase(p);
        } catch (e) {
          debugPrint('compras: completePurchase falhou ($e)');
        }
      }
    }
    notifyListeners();
  }

  Future<void> _validar(PurchaseDetails p) async {
    try {
      await sb.functions.invoke('validar-compra-play', body: {
        'produto_id': p.productID,
        'token_compra': p.verificationData.serverVerificationData,
      });
      _estado = EstadoCompra.feita;
      _produtoFeito = p.productID;
    } catch (e) {
      _estado = EstadoCompra.erro;
      _erro = e.toString();
    }
  }

  /// Limpa a mensagem de estado (depois de o ecrã a mostrar).
  void limparEstado() {
    if (_estado == EstadoCompra.lojaIndisponivel) return;
    _estado = EstadoCompra.parado;
    _erro = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
