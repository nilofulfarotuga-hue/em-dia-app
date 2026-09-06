import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'fala.dart';

/// Em que pé está o ouvido da app.
///
/// Os nomes são o que a pessoa vê no ecrã, não o que o Android devolve: quem
/// ler isto daqui a um ano tem de perceber o estado sem abrir o plugin.
enum EstadoOuvir {
  /// Calado, à espera que a pessoa carregue no botão.
  parou,

  /// A abrir o microfone. O Android leva um instante a responder e sem este
  /// estado o botão parecia avariado nesse intervalo.
  aPreparar,

  /// A ouvir mesmo. As palavras vão caindo em [Ouvir.texto].
  aOuvir,

  /// A pessoa disse "não" ao microfone (ou nunca chegou a ser perguntada).
  semPermissao,

  /// O telemóvel não tem reconhecimento de voz instalado. Não é culpa de
  /// ninguém: há aparelhos que vêm sem ele.
  semServico,
}

/// O ouvido da app: pega no `speech_to_text` e devolve texto em português.
///
/// Existe para o "Fala comigo". Muita gente a quem esta app serve escreve mal
/// e lê pior — imigrantes recém-chegados, quem passou a vida a trabalhar com as
/// mãos, gente de 60 anos. Escrever uma pergunta num telemóvel é uma parede;
/// falar não é. Esta classe é a porta pelo lado de lá.
///
/// Usa-se assim:
/// ```dart
/// final ouvir = Ouvir()..aoTerminar = (frase) => store.perguntar(frase);
/// await ouvir.comecar(variante: 'pt');   // a voz da app cala-se sozinha
/// // …a pessoa fala, o texto vai aparecendo em ouvir.texto…
/// await ouvir.parar();                   // aoTerminar recebe a frase inteira
/// ```
class Ouvir extends ChangeNotifier {
  /// O motor pode ser injetado nos testes. Na app nasce à primeira escuta —
  /// criar um `SpeechToText` custa e ninguém abre esta tela sem falar.
  SpeechToText? _motor;

  /// Modo foto: não toca no plugin nenhum. É o que deixa os golden tests
  /// fotografarem esta tela numa máquina sem microfone.
  final bool _soParaFotos;

  EstadoOuvir _estado = EstadoOuvir.parou;
  String _texto = '';
  String? _localeUsado;
  bool _localeAproximado = false;
  double _volume = 0;

  /// Trava de entrega única: o motor grita "acabei" por mais do que um caminho
  /// (resultado final, mudança de estado, erro) e a pergunta não pode sair
  /// duas vezes.
  bool _entregue = true;

  /// A última escuta fechou sem uma única palavra. Não é avaria nenhuma — é
  /// o telemóvel longe da boca, ou o barulho da rua — mas a tela tem de o
  /// dizer, senão parece que o botão não faz nada.
  bool _semPalavras = false;

  Timer? _rede;

  /// Chamado uma vez por escuta, com a frase inteira, quando o motor fecha.
  /// É aqui que a tela manda a pergunta à IaStore.
  void Function(String frase)? aoTerminar;

  // O analisador pede `this._motor`, mas em Dart um parametro com nome nao
  // pode comecar por underscore — a sugestao dele nao compila. Fica assim.
  Ouvir({SpeechToText? motor})
      // ignore: prefer_initializing_formals
      : _motor = motor,
        _soParaFotos = false;

  /// Para fotos e testes: um ouvido de mentira, parado no estado que se pedir.
  ///
  /// Os campos põem-se no corpo e não na lista de inicialização de propósito:
  /// já têm valor na declaração, e misturar as duas coisas é discussão que não
  /// vale a pena ter com o compilador.
  Ouvir.paraTeste({
    EstadoOuvir estado = EstadoOuvir.parou,
    String texto = '',
    String? localeUsado,
    bool localeAproximado = false,
    bool naoOuviuNada = false,
    double volume = 0,
  }) : _soParaFotos = true {
    _estado = estado;
    _texto = texto;
    _localeUsado = localeUsado;
    _localeAproximado = localeAproximado;
    _semPalavras = naoOuviuNada;
    _volume = volume;
  }

  EstadoOuvir get estado => _estado;

  /// O que já se ouviu nesta escuta (vai crescendo enquanto a pessoa fala).
  String get texto => _texto;

  bool get aOuvir => _estado == EstadoOuvir.aOuvir;
  bool get aPreparar => _estado == EstadoOuvir.aPreparar;

  /// A ouvir ou a abrir o microfone — para a tela, é o mesmo botão aceso.
  bool get ocupado => aOuvir || aPreparar;

  /// Nem microfone nem motor de voz: só resta escrever.
  bool get impedido =>
      _estado == EstadoOuvir.semPermissao || _estado == EstadoOuvir.semServico;

  /// A escuta anterior acabou em silêncio (ver [_semPalavras]).
  bool get naoOuviuNada => _semPalavras;

  /// A língua que o motor está mesmo a usar (`pt_PT`, `pt_BR`, …) ou `null`
  /// quando ficou a do telemóvel.
  String? get localeUsado => _localeUsado;

  /// `true` quando não havia a língua pedida e se usou o que havia. A tela
  /// diz isto à pessoa — senão ela acha que fala mal, e o problema é do
  /// aparelho.
  bool get localeAproximado => _localeAproximado;

  /// Força da voz, de 0 a 1. Serve só para o anel do botão pulsar ao ritmo de
  /// quem fala: é essa a prova visível de que o microfone está mesmo aberto.
  double get volume => _volume;

  /// Abre o microfone e começa a ouvir. [variante] é `pt` ou `br`.
  Future<void> comecar({String variante = 'pt'}) async {
    if (_soParaFotos || ocupado) return;

    // A app não se pode ouvir a si própria. Se a voz estivesse a ler a resposta
    // anterior, o microfone apanhava-a e a pessoa acabava a "perguntar" o que a
    // app tinha acabado de dizer.
    await Fala.instancia.parar();

    _texto = '';
    _entregue = false;
    _semPalavras = false;
    _volume = 0;
    _mudarPara(EstadoOuvir.aPreparar);

    final motor = _motor ??= SpeechToText();
    try {
      final pronto = await motor.initialize(
        onStatus: _aoEstadoDoMotor,
        onError: _aoErro,
      );
      if (!pronto) {
        // `initialize` devolve falso por duas razões muito diferentes e a
        // pessoa merece saber qual: ou recusou o microfone, ou o aparelho não
        // tem motor de voz. `hasPermission` só pergunta ao sistema, não abre
        // caixa nenhuma, por isso é seguro chamar aqui.
        final temMicrofone = await motor.hasPermission;
        _mudarPara(
            temMicrofone ? EstadoOuvir.semServico : EstadoOuvir.semPermissao);
        _entregue = true;
        return;
      }

      final locale = await _escolherLocale(motor, variante);
      await motor.listen(
        onResult: _aoResultado,
        onSoundLevelChange: _aoVolume,
        listenOptions: SpeechListenOptions(
          localeId: locale,
          // Sem resultados parciais não havia palavras a aparecer no ecrã — e
          // é isso que mostra a quem fala que a app o está a acompanhar.
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
          // Quatro segundos de silêncio fecham a escuta. Menos do que isso
          // corta quem pensa a meio da frase.
          pauseFor: const Duration(seconds: 4),
          listenFor: const Duration(seconds: 60),
        ),
      );
      if (_estado == EstadoOuvir.aPreparar) _mudarPara(EstadoOuvir.aOuvir);
    } catch (e) {
      // Aqui caem o `SpeechToTextNotInitializedException` e o
      // `ListenFailedException`. Nenhum deles é culpa de quem está a falar.
      debugPrint('Ouvir: não deu para abrir o microfone — $e');
      _entregue = true;
      _mudarPara(EstadoOuvir.semServico);
    }
  }

  /// Fecha o microfone e entrega a frase.
  ///
  /// A entrega não acontece já: o resultado final chega DEPOIS do `stop`, e
  /// entregar aqui dava frases cortadas a meio.
  Future<void> parar() async {
    if (_soParaFotos) {
      _terminar();
      return;
    }
    try {
      await _motor?.stop();
    } catch (e) {
      debugPrint('Ouvir: falhou a fechar o microfone — $e');
    }
    // Rede de segurança: se o motor não disser "acabei" em 3 segundos, entrega
    // o que já se ouviu. Sem isto, um telemóvel que se cala deixa a pessoa a
    // olhar para um botão a pulsar, sem nada acontecer e sem saber porquê.
    _rede?.cancel();
    _rede = Timer(const Duration(seconds: 3), _terminar);
  }

  /// Fecha o microfone e deita fora o que se ouviu (sair da tela, por exemplo).
  Future<void> cancelar() async {
    _entregue = true;
    _semPalavras = false;
    _rede?.cancel();
    _rede = null;
    _texto = '';
    if (!_soParaFotos) {
      try {
        await _motor?.cancel();
      } catch (e) {
        debugPrint('Ouvir: falhou a cancelar — $e');
      }
    }
    _volume = 0;
    if (ocupado) _estado = EstadoOuvir.parou;
    notifyListeners();
  }

  /// Apaga os recados que a tela está a dar ("sem microfone", "sem serviço",
  /// "não te ouvi") para a pessoa poder tentar outra vez com o ecrã limpo.
  void limparRecados() {
    if (!impedido && !_semPalavras) return;
    _semPalavras = false;
    if (impedido) _estado = EstadoOuvir.parou;
    notifyListeners();
  }

  void _aoResultado(SpeechRecognitionResult r) {
    _texto = r.recognizedWords;
    if (_estado == EstadoOuvir.aPreparar) _estado = EstadoOuvir.aOuvir;
    notifyListeners();
    if (r.finalResult) _terminar();
  }

  void _aoVolume(double nivel) {
    // O Android manda algo entre -2 e 10; o iOS manda outra escala. Isto não
    // quer ser um medidor certo, só um anel que mexe quando alguém fala.
    final novo = ((nivel + 2) / 12).clamp(0.0, 1.0);
    if ((novo - _volume).abs() < 0.03) return;
    _volume = novo;
    notifyListeners();
  }

  void _aoEstadoDoMotor(String estadoDoMotor) {
    if (estadoDoMotor == SpeechToText.listeningStatus) {
      if (_estado == EstadoOuvir.aPreparar) _mudarPara(EstadoOuvir.aOuvir);
      return;
    }
    // Só o `done` serve para entregar. O `notListening` chega ANTES do
    // resultado final: entregar aí perdia a última parte da frase.
    if (estadoDoMotor == SpeechToText.doneStatus) _terminar();
  }

  void _aoErro(SpeechRecognitionError erro) {
    debugPrint('Ouvir: ${erro.errorMsg} (permanente: ${erro.permanent})');
    if (erro.errorMsg.contains('permission')) {
      _entregue = true;
      _mudarPara(EstadoOuvir.semPermissao);
      return;
    }
    // Silêncio não é avaria: a pessoa carregou e não disse nada, ou o motor
    // não percebeu. Fecha-se sem drama e sem mensagem de erro.
    if (erro.errorMsg == 'error_no_match' ||
        erro.errorMsg == 'error_speech_timeout') {
      _terminar();
      return;
    }
    if (erro.permanent) {
      _entregue = true;
      _mudarPara(EstadoOuvir.semServico);
      return;
    }
    _terminar();
  }

  void _terminar() {
    _rede?.cancel();
    _rede = null;
    final jaTinhaSaido = _entregue;
    _entregue = true;
    _volume = 0;
    // Um `semPermissao` / `semServico` não pode ser apagado por um "acabei"
    // que chegue atrasado: a mensagem tem de ficar no ecrã.
    final frase = _texto.trim();
    // Houve tentativa e não saiu palavra nenhuma: a tela tem de o dizer.
    if (!jaTinhaSaido && frase.isEmpty) _semPalavras = true;
    if (ocupado) _estado = EstadoOuvir.parou;
    notifyListeners();
    if (!jaTinhaSaido && frase.isNotEmpty) aoTerminar?.call(frase);
  }

  /// Escolhe a língua da escuta e diz, pelo caminho, se ficou a certa.
  ///
  /// Ordem: a variante do perfil, depois a outra variante do português, depois
  /// qualquer português, e por fim a língua do telemóvel. Nunca falha — mas as
  /// três últimas marcam [localeAproximado], e a tela avisa.
  Future<String?> _escolherLocale(SpeechToText motor, String variante) async {
    final querida = variante == 'br' ? 'pt_br' : 'pt_pt';
    final prima = variante == 'br' ? 'pt_pt' : 'pt_br';
    try {
      final linguas = await motor.locales();
      String? procurar(String id) {
        for (final lingua in linguas) {
          if (_normalizar(lingua.localeId) == id) return lingua.localeId;
        }
        return null;
      }

      final certa = procurar(querida);
      if (certa != null) {
        _localeUsado = certa;
        _localeAproximado = false;
        return certa;
      }
      final outra = procurar(prima);
      if (outra != null) {
        _localeUsado = outra;
        _localeAproximado = true;
        return outra;
      }
      for (final lingua in linguas) {
        if (_normalizar(lingua.localeId).startsWith('pt')) {
          _localeUsado = lingua.localeId;
          _localeAproximado = true;
          return lingua.localeId;
        }
      }
    } catch (e) {
      debugPrint('Ouvir: não deu para ler as línguas do aparelho — $e');
    }
    // Sem português nenhum instalado: fica a língua do telemóvel. Vai perceber
    // pior, e é por isso que a tela o diz em vez de deixar a pessoa a pensar
    // que a culpa é da maneira como ela fala.
    _localeUsado = null;
    _localeAproximado = true;
    return null;
  }

  void _mudarPara(EstadoOuvir novo) {
    if (_estado == novo) return;
    _estado = novo;
    notifyListeners();
  }

  /// O Android devolve `pt_PT` e o iOS `pt-PT`. Comparar sem isto dá falso
  /// negativo e a app dizia "não tenho português" num telemóvel que tem.
  static String _normalizar(String id) => id.replaceAll('-', '_').toLowerCase();

  @override
  void dispose() {
    _rede?.cancel();
    aoTerminar = null;
    if (!_soParaFotos) {
      try {
        _motor?.cancel();
      } catch (_) {
        // a sair da tela; se nem cancelar dá, não há nada a fazer
      }
    }
    super.dispose();
  }
}
