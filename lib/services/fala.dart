import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// A voz da app: lê em voz alta o que está escrito, na variante de quem lê.
///
/// Existe porque muita gente que usa o Em Dia não gosta de ler — motoristas ao
/// volante, quem tem pouca escolaridade, quem está a aprender português. Cada
/// explicação da app tem um botão para ouvir, e é esta classe que fala.
///
/// Uma voz de cada vez: se começar a falar noutro sítio, o anterior cala-se.
class Fala extends ChangeNotifier {
  static final Fala instancia = Fala._();
  Fala._();

  FlutterTts? _tts;
  String? _aFalarAgora;

  /// A etiqueta do texto que está a ser lido (ou `null` se está calado).
  String? get aFalarAgora => _aFalarAgora;
  bool estaAFalar(String etiqueta) => _aFalarAgora == etiqueta;

  /// Lê [texto] em voz alta. [etiqueta] serve para o botão saber se é ele que
  /// está a falar. [variante] é `pt` ou `br`.
  ///
  /// Devolve `false` se o telemóvel não tem voz instalada — quem chama mostra
  /// o aviso. Nunca deita a app abaixo por causa disto.
  Future<bool> ler(String etiqueta, String texto, {String variante = 'pt'}) async {
    try {
      if (_aFalarAgora == etiqueta) {
        await parar();
        return true;
      }
      await parar();
      final tts = _tts ??= FlutterTts();
      await tts.setLanguage(variante == 'br' ? 'pt-BR' : 'pt-PT');
      tts.setCompletionHandler(_calou);
      tts.setCancelHandler(_calou);
      tts.setErrorHandler((_) => _calou());
      _aFalarAgora = etiqueta;
      notifyListeners();
      await tts.speak(paraVoz(texto));
      return true;
    } catch (e) {
      debugPrint('Fala: não deu para ler — $e');
      _calou();
      return false;
    }
  }

  Future<void> parar() async {
    try {
      await _tts?.stop();
    } catch (_) {
      // se nem parar dá, o estado limpa-se na mesma
    }
    _calou();
  }

  void _calou() {
    if (_aFalarAgora == null) return;
    _aFalarAgora = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts?.stop();
    super.dispose();
  }

  /// Tira as marcas de escrita (`#`, `-`, `1.`, `**`, links) para a voz ler só
  /// as palavras, e troca abreviaturas que a voz diria mal.
  static String paraVoz(String texto) {
    var t = texto
        .split('\n')
        .map((linha) => linha
            .replaceFirst(RegExp(r'^\s*#{1,6}\s+'), '')
            .replaceFirst(RegExp(r'^\s*[-*•]\s+'), '')
            .replaceFirst(RegExp(r'^\s*\d+[.)]\s+'), '')
            .replaceAll('**', ''))
        .where((linha) => linha.trim().isNotEmpty)
        .join('. ')
        .replaceAll('..', '.');
    // A voz diz "e-u-r-o-s" se lhe deixarmos o símbolo colado ao número.
    t = t.replaceAllMapped(RegExp(r'(\d)\s*€'), (m) => '${m[1]} euros');
    t = t.replaceAll('€', ' euros');
    t = t.replaceAll('%', ' por cento');
    t = t.replaceAll('IVA', 'I. V. A.');
    t = t.replaceAll('IRS', 'I. R. S.');
    t = t.replaceAll('IUC', 'I. U. C.');
    t = t.replaceAll('IPO', 'I. P. O.');
    t = t.replaceAll('NIF', 'N. I. F.');
    t = t.replaceAll('TVDE', 'T. V. D. E.');
    return t;
  }
}
