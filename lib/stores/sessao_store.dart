import 'dart:async';

import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/arranque.dart';
import '../services/push.dart';

/// O que correu mal a entrar. Cada causa tem uma frase própria na app — dizer
/// sempre "não consegui entrar" escondia o problema a sério (o servidor
/// mandava um código de 8 números e o campo da app só aceitava 6, 2026-09-06).
enum ErroLogin {
  nenhum,
  emailInvalido,
  emailDeMentira,
  /// O servidor só deixa entrar quem foi convidado (até ao lançamento).
  registoFechado,
  rede,
  muitosPedidos,
  codigoCurto,
  codigoErrado,
  codigoExpirado,
  /// O anti-robô (Turnstile) não deu token, ou o servidor recusou-o
  /// (`captcha_failed`). O ecrã mostra o desafio visível a seguir.
  antiRobo,
  generico,
}

/// Sessão: quem está a usar a app. Login por e-mail com código de 6 números
/// (Supabase OTP) ou Google. Sem palavra-passe (decisão D4 em docs/DECISOES.md).
///
/// Duas coisas escondidas por baixo:
/// - Com [turnstileSiteKey] na build, cada pedido de código passa primeiro
///   pelo anti-robô da Cloudflare (a 6 de setembro de 2026 o Googlebot
///   submeteu o formulário de entrada com e-mails inventados e tentou códigos).
/// - Só o e-mail do revisor da Google Play ([emailRevisor]) entra com
///   palavra-passe — o revisor não tem caixa de e-mail para receber o código.
///
/// O código tem de ter o mesmo tamanho aqui e no servidor
/// (`mailer_otp_length`). Se um dia mudar lá, muda [tamanhoCodigo] aqui.
class SessaoStore extends ChangeNotifier {
  /// Quantos números o código costuma ter (`mailer_otp_length` no Supabase).
  /// Serve para desenhar as casinhas e para enviar sozinho quando enche.
  static const int tamanhoCodigo = 6;

  /// Mas a app aceita de [tamanhoMinimo] a [tamanhoMaximo] números. Isto não é
  /// enfeite: a 6 de setembro de 2026 o servidor mandava 8 e o campo só deixava
  /// escrever 6 — ninguém conseguia entrar e o ecrã ficava preso. Com uma
  /// margem, se o tamanho lá mudar outra vez, a app continua a funcionar.
  static const int tamanhoMinimo = 4;
  static const int tamanhoMaximo = 8;

  /// O servidor só deixa pedir outro código passado 1 minuto. A app conta o
  /// tempo para não levar um 429 na cara de quem carrega duas vezes.
  static const int segundosEntrePedidos = 60;

  /// Quanto tempo se espera pelo Turnstile invisível. O pacote só avisa
  /// (`onTimeout`) e nunca fecha o Future quando o script não carrega — sem
  /// isto o botão ficava a rodar para sempre. Lido no código do pacote
  /// (cloudflare_turnstile 3.8.1, `_TurnstileInvisible.getToken`).
  static const Duration esperaAntiRobo = Duration(seconds: 20);

  static final RegExp _emailOk = RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]{2,}$');
  static final RegExp _naoNumero = RegExp(r'\D');

  /// Terminações que NUNCA recebem correio. `.test`, `.invalid`, `.example` e
  /// `.localhost` estão reservadas por norma (RFC 2606 e RFC 6761) e não existem
  /// na internet; `example.com` é o domínio de exemplo oficial.
  static const List<String> _dominiosQueNaoExistem = [
    '.test', '.invalid', '.example', '.localhost', '.local',
    'example.com', 'example.org', 'example.net',
  ];

  /// Caixas de correio inventadas nos fornecedores grandes.
  ///
  /// Isto não é preciosismo: cada envio para uma destas volta para trás, e cada
  /// devolução gasta a reputação do domínio que manda os códigos de entrada a
  /// toda a gente. A 6 de setembro de 2026, sete de quinze envios do Em Dia
  /// falharam — todos para `test@gmail.com` e `newuser@gmail.com`, escritos a
  /// experimentar o registo. O `test@gmail.com` foi devolvido e a Resend
  /// pô-lo na lista negra. Uma pessoa a sério nunca perde nada com esta
  /// travagem; um teste distraído perde o domínio a toda a gente.
  static const List<String> _caixasInventadas = [
    'test', 'teste', 'testes', 'testing', 'newuser', 'novouser', 'utilizador',
    'exemplo', 'example', 'demo', 'asdf', 'aaaa', 'qwerty', 'noreply', 'no-reply',
  ];
  static const List<String> _fornecedoresGrandes = [
    'gmail.com', 'hotmail.com', 'outlook.com', 'outlook.pt', 'live.com',
    'yahoo.com', 'yahoo.com.br', 'icloud.com', 'sapo.pt',
  ];

  /// `true` quando o endereço não vai chegar a lado nenhum.
  static bool enderecoDeMentira(String email) {
    final e = email.trim().toLowerCase();
    for (final fim in _dominiosQueNaoExistem) {
      if (e.endsWith(fim)) return true;
    }
    final partes = e.split('@');
    if (partes.length != 2) return false;
    // `nome+etiqueta@gmail.com` é a forma certa de fazer testes: chega mesmo à
    // caixa de quem a escreveu. Só se olha para o que vem antes do `+`.
    final caixa = partes[0].split('+').first;
    return _fornecedoresGrandes.contains(partes[1]) && _caixasInventadas.contains(caixa);
  }

  StreamSubscription<AuthState>? _sub;
  Timer? _relogio;
  User? _user;
  bool _pronto = false;
  ErroLogin _erro = ErroLogin.nenhum;
  String? _erroTecnico;
  bool _aTrabalhar = false;
  String? _emailPendente;
  int _reenviarEm = 0;
  bool _precisaDesafio = false;

  SessaoStore() {
    _user = sb.auth.currentUser;
    _pronto = true;
    _sub = sb.auth.onAuthStateChange.listen((estado) {
      _user = estado.session?.user;
      notifyListeners();
    });
  }

  /// Para testes e fotos: sem Supabase, ninguém autenticado.
  SessaoStore.semServidor() : _pronto = true;

  User? get user => _user;
  String? get userId => _user?.id;
  bool get autenticado => _user != null;
  bool get pronto => _pronto;
  ErroLogin get erro => _erro;
  bool get temErro => _erro != ErroLogin.nenhum;

  /// A mensagem literal do servidor. Não se mostra a ninguém — serve para o
  /// `debugPrint` e para o relatório quando algo corre mal.
  String? get erroTecnico => _erroTecnico;
  bool get aTrabalhar => _aTrabalhar;
  String? get emailPendente => _emailPendente;

  /// Segundos que faltam para poder pedir outro código. 0 = já pode.
  int get reenviarEm => _reenviarEm;
  bool get podeReenviar => _reenviarEm == 0 && !_aTrabalhar;
  bool get googleDisponivel => googleWebClientId.isNotEmpty;

  /// Há chave do Turnstile nesta build. Sem ela não há captcha nenhum: os
  /// testes, as fotos e as builds antigas continuam a funcionar.
  bool get antiRoboLigado => turnstileSiteKey.isNotEmpty;

  /// O modo invisível falhou (ou o servidor recusou o token): o próximo pedido
  /// tem de passar pelo desafio visível, que o ecrã desenha.
  bool get precisaDesafio => _precisaDesafio;

  /// O e-mail do revisor da Google Play. Getter (e não a constante) para os
  /// testes poderem fingir um.
  String get emailDoRevisor => emailRevisor;

  /// `true` quando este e-mail é o do revisor da Google Play (sem maiúsculas
  /// nem espaços a contar). Sem [emailRevisor] na build, nunca.
  bool ehRevisor(String email) {
    final r = emailDoRevisor.trim().toLowerCase();
    return r.isNotEmpty && email.trim().toLowerCase() == r;
  }

  void _comecar() {
    _aTrabalhar = true;
    _erro = ErroLogin.nenhum;
    _erroTecnico = null;
    notifyListeners();
  }

  void _acabar([ErroLogin erro = ErroLogin.nenhum, String? tecnico]) {
    _aTrabalhar = false;
    _erro = erro;
    _erroTecnico = tecnico;
    if (tecnico != null) debugPrint('SessaoStore: $erro — $tecnico');
    notifyListeners();
  }

  /// Fecha o pedido com o erro classificado. Se o servidor recusou o token
  /// anti-robô, o próximo pedido passa a pedir o desafio visível.
  void _falhou(Object e) {
    final erro = _classificar(e);
    if (erro == ErroLogin.antiRobo) _precisaDesafio = true;
    _acabar(erro, e.toString());
  }

  /// Limpa o aviso vermelho (ao voltar atrás ou ao escrever de novo).
  void limparErro() {
    if (_erro == ErroLogin.nenhum) return;
    _erro = ErroLogin.nenhum;
    _erroTecnico = null;
    notifyListeners();
  }

  /// Traduz o que o servidor devolveu para uma das causas que a app sabe
  /// explicar. Os códigos são os de
  /// https://supabase.com/docs/guides/auth/debugging/error-codes
  ErroLogin _classificar(Object e) {
    if (e is AuthRetryableFetchException) return ErroLogin.rede;
    if (e is AuthException) {
      final codigo = e.code ?? '';
      final msg = e.message.toLowerCase();
      // Protecção anti-robô ligada no servidor e o token não foi, expirou
      // (300 s) ou já tinha sido gasto: 400 "captcha_failed".
      if (codigo == 'captcha_failed') return ErroLogin.antiRobo;
      if (codigo.contains('rate_limit') || e.statusCode == '429') {
        return ErroLogin.muitosPedidos;
      }
      // As duas travas do servidor (migrações 0021 e 0027) chegam aqui como
      // 500 "unexpected_failure" com a razão no texto. Sem isto a pessoa via
      // "Não consegui entrar", que é feio e não diz o que fazer.
      if (msg.contains('registo_fechado')) return ErroLogin.registoFechado;
      if (msg.contains('email_que_nao_recebe')) return ErroLogin.emailDeMentira;
      if (codigo == 'otp_expired' || msg.contains('expired')) {
        return ErroLogin.codigoExpirado;
      }
      if (codigo == 'validation_failed' ||
          codigo == 'email_address_invalid' ||
          msg.contains('invalid email')) {
        return ErroLogin.emailInvalido;
      }
      if (codigo == 'otp_disabled' || codigo == 'invalid_credentials') {
        return ErroLogin.codigoErrado;
      }
      return ErroLogin.generico;
    }
    final texto = e.toString().toLowerCase();
    if (texto.contains('socket') ||
        texto.contains('failed host lookup') ||
        texto.contains('connection') ||
        texto.contains('clientexception')) {
      return ErroLogin.rede;
    }
    return ErroLogin.generico;
  }

  void _contarParaReenviar() {
    _relogio?.cancel();
    _reenviarEm = segundosEntrePedidos;
    _relogio = Timer.periodic(const Duration(seconds: 1), (t) {
      _reenviarEm--;
      if (_reenviarEm <= 0) {
        _reenviarEm = 0;
        t.cancel();
      }
      notifyListeners();
    });
  }

  /// Pede um token NOVO ao Turnstile em modo invisível (sem nada no ecrã).
  /// Devolve `null` quando não conseguiu — o desafio escalou para interactivo,
  /// o script não carregou, a rede falhou — e o ecrã passa ao desafio visível.
  ///
  /// O `baseUrl` é o domínio a que o widget está preso na Cloudflare: no
  /// Android é obrigatório (o WebView finge estar nessa página), na web é
  /// ignorado. O `dispose` no `finally` é exigido pelo pacote: cada instância
  /// abre um WebView escondido.
  Future<String?> _pedirTokenAntiRobo() async {
    final turnstile = CloudflareTurnstile.invisible(
      siteKey: turnstileSiteKey,
      baseUrl: turnstileBaseUrl,
    );
    try {
      final token = await turnstile.getToken().timeout(esperaAntiRobo);
      if (token == null || token.isEmpty) {
        debugPrint('SessaoStore: Turnstile invisível não devolveu token');
        return null;
      }
      return token;
    } on TurnstileException catch (e) {
      debugPrint('SessaoStore: Turnstile ${e.code} — ${e.message}');
      return null;
    } on TimeoutException {
      debugPrint('SessaoStore: Turnstile invisível não respondeu em '
          '${esperaAntiRobo.inSeconds} s');
      return null;
    } catch (e) {
      // No Android o WebView devolve o erro em bruto (WebResourceError).
      debugPrint('SessaoStore: Turnstile falhou — $e');
      return null;
    } finally {
      try {
        await turnstile.dispose();
      } catch (e) {
        debugPrint('SessaoStore: Turnstile dispose — $e');
      }
    }
  }

  /// Passo 1: manda o código de 6 números para o e-mail.
  ///
  /// Com o anti-robô ligado, pede um token NOVO ao Turnstile imediatamente
  /// antes de cada pedido (cada token vale uma vez e morre aos 300 s):
  /// primeiro em modo invisível; se esse falhar, [precisaDesafio] fica `true`,
  /// o ecrã mostra o desafio visível e volta a chamar isto com o
  /// [captchaToken] que a pessoa resolveu.
  Future<bool> enviarCodigo(String email, {String? captchaToken}) async {
    final limpo = email.trim().toLowerCase();
    if (!_emailOk.hasMatch(limpo)) {
      _acabar(ErroLogin.emailInvalido, 'e-mail fora do formato: "$limpo"');
      return false;
    }
    if (enderecoDeMentira(limpo)) {
      _acabar(ErroLogin.emailDeMentira, 'endereço que não recebe correio: "$limpo"');
      return false;
    }
    _comecar();
    var token = captchaToken;
    if (antiRoboLigado && token == null) {
      token = await _pedirTokenAntiRobo();
      if (token == null) {
        _precisaDesafio = true;
        _acabar(ErroLogin.antiRobo, 'o Turnstile invisível não deu token');
        return false;
      }
    }
    try {
      await sb.auth.signInWithOtp(
        email: limpo,
        shouldCreateUser: true,
        captchaToken: token,
      );
      _emailPendente = limpo;
      _precisaDesafio = false;
      _acabar();
      _contarParaReenviar();
      return true;
    } catch (e) {
      _falhou(e);
      return false;
    }
  }

  /// Pede outro código para o mesmo e-mail. Só funciona depois do minuto.
  /// Passa por [enviarCodigo], logo pede token anti-robô novo.
  Future<bool> reenviarCodigo({String? captchaToken}) async {
    final email = _emailPendente;
    if (email == null || !podeReenviar) return false;
    return enviarCodigo(email, captchaToken: captchaToken);
  }

  /// Passo 2: confirma o código. Aceita espaços e traços colados do e-mail.
  Future<bool> confirmarCodigo(String codigo) async {
    final email = _emailPendente;
    if (email == null) {
      _acabar(ErroLogin.generico, 'confirmarCodigo sem e-mail pendente');
      return false;
    }
    final numeros = codigo.replaceAll(_naoNumero, '');
    if (numeros.length < tamanhoMinimo || numeros.length > tamanhoMaximo) {
      _acabar(ErroLogin.codigoCurto, 'código com ${numeros.length} números');
      return false;
    }
    _comecar();
    try {
      final res = await sb.auth.verifyOTP(
        email: email,
        token: numeros,
        type: OtpType.email,
      );
      _user = res.user;
      if (_user == null) {
        _acabar(ErroLogin.codigoErrado, 'verifyOTP devolveu sessão sem user');
        return false;
      }
      _relogio?.cancel();
      _reenviarEm = 0;
      _acabar();
      return true;
    } catch (e) {
      _falhou(e);
      return false;
    }
  }

  /// Só para o revisor da Google Play (ver [emailRevisor]): entra com
  /// palavra-passe, sem código e sem passar pelo Turnstile — o revisor não o
  /// consegue resolver num emulador. A conta é criada no servidor pelo
  /// orquestrador; a app nunca tem a palavra-passe.
  ///
  /// Se o servidor mesmo assim exigir captcha (a protecção do Supabase
  /// também cobre `/token?grant_type=password`), [precisaDesafio] fica
  /// `true`, o ecrã mostra o desafio visível e volta cá com o [captchaToken].
  Future<bool> entrarComPalavraPasse(
    String email,
    String palavraPasse, {
    String? captchaToken,
  }) async {
    final limpo = email.trim().toLowerCase();
    if (!ehRevisor(limpo)) {
      _acabar(ErroLogin.generico, 'entrada por palavra-passe só para o revisor');
      return false;
    }
    if (palavraPasse.isEmpty) {
      _acabar(ErroLogin.codigoErrado, 'palavra-passe vazia');
      return false;
    }
    // O servidor protege também este caminho quando o captcha está ligado
    // (GoTrue verifica o token em /token?grant_type=password). Pede-se o
    // invisível primeiro, como no pedido de código: o revisor é uma pessoa e
    // passa sem ver nada; só se o invisível falhar é que aparece o desafio.
    var token = captchaToken;
    if (antiRoboLigado && token == null) {
      token = await _pedirTokenAntiRobo();
      if (token == null) {
        _precisaDesafio = true;
        _acabar(ErroLogin.antiRobo, 'o Turnstile invisível não deu token (revisor)');
        return false;
      }
    }
    _comecar();
    try {
      final res = await sb.auth.signInWithPassword(
        email: limpo,
        password: palavraPasse,
        captchaToken: token,
      );
      _user = res.user;
      if (_user == null) {
        _acabar(ErroLogin.codigoErrado, 'signInWithPassword devolveu sessão sem user');
        return false;
      }
      _precisaDesafio = false;
      _acabar();
      return true;
    } catch (e) {
      _falhou(e);
      return false;
    }
  }

  /// Google: idToken do Google → sessão Supabase.
  Future<bool> entrarComGoogle() async {
    if (!googleDisponivel) {
      _acabar(ErroLogin.generico, 'GOOGLE_WEB_CLIENT_ID em falta nesta build');
      return false;
    }
    _comecar();
    try {
      final gs = GoogleSignIn.instance;
      await gs.initialize(serverClientId: googleWebClientId);
      final conta = await gs.authenticate();
      final idToken = conta.authentication.idToken;
      if (idToken == null) {
        _acabar(ErroLogin.generico, 'o Google não devolveu idToken');
        return false;
      }
      final res = await sb.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      _user = res.user;
      _acabar();
      return _user != null;
    } catch (e) {
      _falhou(e);
      return false;
    }
  }

  /// Volta ao passo do e-mail (escrevi o e-mail errado).
  void trocarEmail() {
    _emailPendente = null;
    _relogio?.cancel();
    _reenviarEm = 0;
    _erro = ErroLogin.nenhum;
    _erroTecnico = null;
    notifyListeners();
  }

  Future<void> sair() async {
    await PushService.esquecer();
    await sb.auth.signOut();
    _user = null;
    _emailPendente = null;
    _relogio?.cancel();
    _reenviarEm = 0;
    _erro = ErroLogin.nenhum;
    _erroTecnico = null;
    _precisaDesafio = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _relogio?.cancel();
    super.dispose();
  }
}
