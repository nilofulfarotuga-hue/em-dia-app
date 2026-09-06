import 'package:flutter/foundation.dart';

import '../models/fidelizacao.dart';
import '../services/arranque.dart';

/// O radar da fidelização: os contratos presos que estão a acabar.
///
/// Quem faz as contas é o servidor (`radar_fidelizacao`): recebe o dono e uma
/// janela de dias, e devolve os contratos que acabam dentro dessa janela mais
/// os que acabaram há menos de 30 dias. A janela por omissão não é um número
/// deste código — vem de `regras_legais.aviso_fidelizacao_dias`. Por isso o
/// `dias` vai a nulo: é a maneira de dizer ao servidor "usa o que está na
/// tabela".
///
/// O cadeado do plano (`feature_flags.radar_fidelizacao`, fechado no grátis)
/// é do `PlanoStore` e vive no ecrã. Aqui não se tranca nada: uma store que
/// decidisse sozinha o que pode mostrar acabava a discordar do servidor.
class RadarStore extends ChangeNotifier {
  List<Fidelizacao> _contratos = [];
  bool _aCarregar = false;
  String? _erro;
  bool _jaCarregou = false;

  /// Sempre pela data, do que acaba primeiro para o que acaba por último.
  List<Fidelizacao> get contratos => _contratos;
  bool get aCarregar => _aCarregar;
  String? get erro => _erro;
  bool get jaCarregou => _jaCarregou;

  /// Já se foi ao servidor e não há nada para mostrar (é o estado vazio, que
  /// é diferente de "ainda não perguntei").
  bool get vazio => _jaCarregou && _contratos.isEmpty;

  RadarStore();

  /// Para testes e fotos (golden): já carregado, sem servidor. Ordena como o
  /// [carregar] faria — quem escrever um teste com a lista às avessas tem de
  /// ver o mesmo que a app mostra.
  RadarStore.paraTeste({
    List<Fidelizacao> contratos = const [],
    bool aCarregar = false,
    String? erro,
  }) {
    _contratos = List.of(contratos)..sort(_porData);
    _aCarregar = aCarregar;
    _erro = erro;
    _jaCarregou = true;
  }

  static int _porData(Fidelizacao a, Fidelizacao b) {
    final d = a.fimFidelizacao.compareTo(b.fimFidelizacao);
    // Dois contratos que acabam no mesmo dia ficam por nome, para a lista não
    // dançar entre duas aberturas do ecrã.
    return d != 0 ? d : a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
  }

  /// Vai ao servidor só à primeira vez. O ecrã chama isto sempre que abre; é
  /// o "puxar para atualizar" que força uma leitura nova.
  Future<void> carregarSePreciso(String userId) async {
    if (_jaCarregou || _aCarregar) return;
    await carregar(userId);
  }

  /// [dias] a nulo (o normal) manda o servidor usar a janela da tabela das
  /// regras. Só se escreve um número aqui para experimentar outra janela.
  Future<void> carregar(String userId, {int? dias}) async {
    _aCarregar = true;
    _erro = null;
    notifyListeners();
    try {
      final linhas = await sb.rpc('radar_fidelizacao', params: {
        'uid': userId,
        'dias': dias,
      });
      _contratos = (linhas as List)
          .map((m) => Fidelizacao.daLinha(Map<String, dynamic>.from(m as Map)))
          .toList()
        // A função já devolve por ordem de data, mas ordena-se na mesma: uma
        // ordem que só existe do lado de lá parte-se em silêncio no dia em que
        // alguém mexer no SQL, e ninguém dá por isso até o ecrã mentir.
        ..sort(_porData);
      _jaCarregou = true;
    } catch (e) {
      _erro = e.toString();
      debugPrint('RadarStore.carregar: $e');
    }
    _aCarregar = false;
    notifyListeners();
  }

  /// A linha que merece a única cor forte do ecrã.
  ///
  /// É a primeira que ainda **não** acabou — a que tem prazo, e portanto a que
  /// obriga a pegar no telefone antes de a empresa renovar sozinha. Quando já
  /// não há nenhuma no futuro, é a que acabou mais perto de hoje (a última da
  /// lista, que está por data): dessa ainda dá para negociar, das velhas nem
  /// por isso.
  int get indiceDestaque {
    if (_contratos.isEmpty) return -1;
    for (var i = 0; i < _contratos.length; i++) {
      if (!_contratos[i].jaAcabou) return i;
    }
    return _contratos.length - 1;
  }

  Fidelizacao? get destaque {
    final i = indiceDestaque;
    return i < 0 ? null : _contratos[i];
  }

  /// Quantos já acabaram. Serve para o ecrã (e para os testes) saberem que a
  /// lista não é só futuro.
  int get quantosJaAcabaram => _contratos.where((c) => c.jaAcabou).length;
}
