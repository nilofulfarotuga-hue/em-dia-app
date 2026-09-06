import 'package:flutter/foundation.dart';

import '../models/fatura_recebida.dart';
import '../services/arranque.dart';

/// A caixa de correio das faturas: o endereço da pessoa e o que lá chegou.
///
/// O endereço nasce no servidor (`minha_caixa_de_faturas`) e é o servidor que
/// diz se a caixa está [ligada] — enquanto não houver domínio, está desligada
/// e a app diz isso em vez de mostrar um endereço que não recebe nada.
class CaixaStore extends ChangeNotifier {
  String? _endereco;
  bool _ligada = false;
  List<FaturaRecebida> _faturas = [];
  bool _aCarregar = false;
  String? _erro;
  bool _jaCarregou = false;

  String? get endereco => _endereco;
  bool get ligada => _ligada;
  List<FaturaRecebida> get faturas => _faturas;
  bool get aCarregar => _aCarregar;
  String? get erro => _erro;

  /// Quantas ainda ninguém abriu. É este número que aparece na bolinha.
  int get porVer => _faturas.where((f) => f.porVer).length;

  CaixaStore();

  /// Para testes e fotos (golden): já carregada, sem servidor.
  CaixaStore.paraTeste({
    String? endereco,
    bool ligada = false,
    List<FaturaRecebida> faturas = const [],
    String? erro,
  }) {
    _endereco = endereco;
    _ligada = ligada;
    _faturas = List.of(faturas);
    _erro = erro;
    _jaCarregou = true;
  }

  Future<void> carregarSePreciso() async {
    if (_jaCarregou || _aCarregar) return;
    await carregar();
  }

  Future<void> carregar() async {
    _aCarregar = true;
    _erro = null;
    notifyListeners();
    try {
      // O endereço e a lista vêm ao mesmo tempo: são duas viagens que não
      // dependem uma da outra.
      final resultados = await Future.wait<dynamic>([
        sb.rpc('minha_caixa_de_faturas'),
        // CICATRIZ: `.order('coluna')` sem mais nada devolve DECRESCENTE no
        // cliente do Supabase. Escreve-se sempre `ascending:` à mão.
        sb.from('faturas_recebidas').select().order('recebido_em', ascending: false),
      ]);
      final caixa = resultados[0];
      final linha = caixa is List && caixa.isNotEmpty ? caixa.first as Map<String, dynamic> : null;
      _endereco = linha?['endereco'] as String?;
      _ligada = linha?['ligada'] == true;
      _faturas = (resultados[1] as List)
          .map((m) => FaturaRecebida.daLinha(Map<String, dynamic>.from(m as Map)))
          .toList();
      _jaCarregou = true;
    } catch (e) {
      _erro = e.toString();
      debugPrint('CaixaStore.carregar: $e');
    }
    _aCarregar = false;
    notifyListeners();
  }

  /// Liga esta fatura a uma conta que a pessoa acabou de criar.
  Future<bool> marcarLigada(FaturaRecebida f, String saidaId) =>
      _mudarEstado(f, 'ligada', saidaId: saidaId);

  /// "Já não preciso desta." Não apaga: some da lista do que falta ver, e
  /// continua a poder ver-se no que já foi tratado.
  Future<bool> ignorar(FaturaRecebida f) => _mudarEstado(f, 'ignorada');

  Future<bool> _mudarEstado(FaturaRecebida f, String estado, {String? saidaId}) async {
    try {
      await sb.from('faturas_recebidas').update({
        'estado': estado,
        if (saidaId != null) 'saida_id': saidaId,
      }).eq('id', f.id);
      _faturas = [
        for (final x in _faturas)
          if (x.id == f.id)
            FaturaRecebida(
              id: x.id, remetente: x.remetente, assunto: x.assunto,
              recebidoEm: x.recebidoEm, anexoCaminho: x.anexoCaminho,
              anexoNome: x.anexoNome, anexoBytes: x.anexoBytes,
              estado: estado, saidaId: saidaId ?? x.saidaId, erro: x.erro,
            )
          else
            x,
      ];
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('CaixaStore._mudarEstado: $e');
      return false;
    }
  }

  /// Apaga a linha e o ficheiro. É para sempre — quem chama pergunta antes.
  Future<bool> apagar(FaturaRecebida f) async {
    try {
      if (f.anexoCaminho != null) {
        await sb.storage.from('faturas').remove([f.anexoCaminho!]);
      }
      await sb.from('faturas_recebidas').delete().eq('id', f.id);
      _faturas = _faturas.where((x) => x.id != f.id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('CaixaStore.apagar: $e');
      return false;
    }
  }

  /// Um endereço temporário para abrir o PDF no telemóvel. Vale 5 minutos —
  /// o balde é privado e um link eterno era uma porta aberta.
  Future<String?> enderecoParaAbrir(FaturaRecebida f) async {
    if (f.anexoCaminho == null) return null;
    try {
      return await sb.storage.from('faturas').createSignedUrl(f.anexoCaminho!, 300);
    } catch (e) {
      debugPrint('CaixaStore.enderecoParaAbrir: $e');
      return null;
    }
  }
}
