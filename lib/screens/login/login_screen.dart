import 'dart:async';

import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/arranque.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';

/// Entrar: e-mail → código que chega ao e-mail (sem palavra-passe) ou Google.
///
/// Feito à maneira das apps que fazem isto bem (Revolut, Wise, Uber):
/// casinhas para os números, envia sozinho quando o código enche, aceita
/// colar, conta o minuto até poder pedir outro, e há sempre um caminho para
/// trás. Nunca fica preso: cada erro tem a sua frase e um botão a seguir.
///
/// Duas coisas que quase ninguém vê:
/// - o anti-robô (Turnstile) corre escondido antes de cada pedido de código;
///   só quando falha é que nasce o desafio visível, por cima do botão;
/// - o e-mail do revisor da Google Play (`EMAIL_REVISOR`) troca o código por
///   um campo de palavra-passe — o revisor não tem caixa de e-mail.
class LoginScreen extends StatefulWidget {
  final bool modoAdmin;
  const LoginScreen({super.key, this.modoAdmin = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _palavraPasse = TextEditingController();
  final _codigo = TextEditingController();
  final _focoCodigo = FocusNode();
  Timer? _espera;

  /// O token do desafio visível, quando o invisível falhou. Vale uma vez.
  String? _tokenDesafio;

  /// Cada token gasto faz o desafio nascer de novo (chave nova no widget),
  /// senão ficava a mostrar um visto verde com um token já morto.
  int _desafioGeracao = 0;

  /// A caixa visível do Turnstile rebentou (`onError`). Provado a 6 de
  /// setembro de 2026 num browser que a Cloudflare recusa: a caixa não aparece
  /// e o botão ficava cinzento para sempre. Com isto o botão volta a ligar-se,
  /// o toque pede um token novo e a caixa renasce (geração nova).
  bool _desafioFalhou = false;

  @override
  void dispose() {
    _espera?.cancel();
    _email.dispose();
    _palavraPasse.dispose();
    _codigo.dispose();
    _focoCodigo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sessao = context.watch<SessaoStore>();
    final t = Theme.of(context).textTheme;
    final noCodigo = sessao.emailPendente != null;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: paddingEcra,
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.emDia),
                const SizedBox(height: 12),
                Text(widget.modoAdmin ? 'Em Dia — Admin' : l.appNome,
                    textAlign: TextAlign.center, style: t.headlineLarge),
                const SizedBox(height: 32),
                if (!noCodigo)
                  ..._passoEmail(l, sessao, t)
                else
                  ..._passoCodigo(l, sessao, t),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- passo 1

  List<Widget> _passoEmail(AppLocalizations l, SessaoStore s, TextTheme t) {
    final revisor = s.ehRevisor(_email.text);
    final bloqueado = s.aTrabalhar || _faltaDesafio(s);
    return [
      Text(l.loginTitulo, style: t.headlineSmall),
      const SizedBox(height: 6),
      Text(revisor ? l.loginAjudaPalavraPasse : l.loginAjuda,
          style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
      const SizedBox(height: 20),
      TextField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        textInputAction: revisor ? TextInputAction.next : TextInputAction.go,
        autocorrect: false,
        autofillHints: const [AutofillHints.email],
        decoration: InputDecoration(
          labelText: l.loginEmail,
          prefixIcon: const Icon(Icons.mail_outline_rounded),
        ),
        // O setState é para o ecrã trocar de cara mal se escreva o e-mail
        // do revisor (código → palavra-passe).
        onChanged: (_) {
          s.limparErro();
          setState(() {});
        },
        onSubmitted: (_) {
          if (!revisor) _enviar(s);
        },
      ),
      if (revisor) ...[
        const SizedBox(height: 12),
        TextField(
          controller: _palavraPasse,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.go,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            labelText: l.loginPalavraPasse,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
          ),
          onChanged: (_) => s.limparErro(),
          onSubmitted: (_) => _entrarComPalavraPasse(s),
        ),
      ],
      ..._desafio(s),
      ..._vermelho(l, s),
      const SizedBox(height: 16),
      BotaoGrande(
        texto: revisor ? l.loginEntrar : l.loginEnviarCodigo,
        aTrabalhar: s.aTrabalhar,
        aoTocar: bloqueado
            ? null
            : () => revisor ? _entrarComPalavraPasse(s) : _enviar(s),
      ),
      if (s.googleDisponivel && !widget.modoAdmin) ...[
        const SizedBox(height: 20),
        Row(children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(l.loginOu, style: t.bodySmall),
          ),
          const Expanded(child: Divider()),
        ]),
        const SizedBox(height: 20),
        BotaoGrande(
          texto: l.loginGoogle,
          secundario: true,
          icone: Icons.g_mobiledata_rounded,
          aoTocar: s.aTrabalhar ? null : s.entrarComGoogle,
        ),
      ],
    ];
  }

  // ---------------------------------------------------------------- passo 2

  List<Widget> _passoCodigo(AppLocalizations l, SessaoStore s, TextTheme t) => [
        Text(l.loginCodigoTitulo, style: t.headlineSmall),
        const SizedBox(height: 6),
        Text(s.emailPendente ?? '',
            style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
        // A saída fica aqui em cima, ao pé do e-mail. Em baixo, num telemóvel
        // pequeno, ficava fora do ecrã e quem escrevesse mal o e-mail não
        // tinha por onde voltar.
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 4),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _trocarEmail(s),
            child: Text(l.loginTrocarEmail),
          ),
        ),
        const SizedBox(height: 12),
        _CasasDoCodigo(
          controlador: _codigo,
          foco: _focoCodigo,
          rotulo: l.loginCodigo,
          aoMudar: (texto) => _mudouCodigo(s, texto),
        ),
        ..._desafio(s),
        ..._vermelho(l, s),
        const SizedBox(height: 16),
        BotaoGrande(
          texto: l.loginConfirmar,
          aTrabalhar: s.aTrabalhar,
          aoTocar: _numeros.length < SessaoStore.tamanhoMinimo || s.aTrabalhar
              ? null
              : () => _confirmar(s),
        ),
        const SizedBox(height: 12),
        Center(
          child: s.podeReenviar
              ? TextButton(
                  onPressed: _faltaDesafio(s) ? null : () => _reenviar(s),
                  child: Text(l.loginReenviar),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l.loginReenviarEm(s.reenviarEm),
                    style: t.bodySmall!.copyWith(color: AppColors.textSecondary),
                  ),
                ),
        ),
        Text(l.loginOndeEsta,
            textAlign: TextAlign.center,
            style: t.bodySmall!.copyWith(color: AppColors.textSecondary)),
      ];

  // -------------------------------------------------------------- anti-robô

  /// O desafio visível do Turnstile. Só nasce quando o modo invisível falhou
  /// (ou o servidor recusou o token) E há chave na build; nos testes, nas
  /// fotos e nas builds sem chave nunca aparece. Cada token vale uma vez:
  /// depois de gasto, o widget renasce com chave nova para pedir outro.
  List<Widget> _desafio(SessaoStore s) {
    if (!s.antiRoboLigado || !s.precisaDesafio) return const [];
    return [
      const SizedBox(height: 16),
      CloudflareTurnstile(
        key: ValueKey('desafio-$_desafioGeracao'),
        siteKey: turnstileSiteKey,
        baseUrl: turnstileBaseUrl,
        options: TurnstileOptions(
          size: TurnstileSize.flexible,
          theme: TurnstileTheme.light,
        ),
        onTokenReceived: (String token) {
          if (!mounted) return;
          setState(() => _tokenDesafio = token);
        },
        onTokenExpired: () {
          if (mounted) setState(() => _tokenDesafio = null);
        },
        onError: (TurnstileException _) {
          if (!mounted) return;
          setState(() {
            _tokenDesafio = null;
            _desafioFalhou = true;
          });
        },
      ),
    ];
  }

  /// `true` enquanto o desafio visível está no ecrã e ainda ninguém o
  /// resolveu: o botão espera pelo token.
  bool _faltaDesafio(SessaoStore s) =>
      s.antiRoboLigado &&
      s.precisaDesafio &&
      _tokenDesafio == null &&
      !_desafioFalhou;

  /// Tira o token do ecrã e faz o desafio nascer de novo. Chama-se ANTES de
  /// cada pedido, porque o token só serve uma vez.
  String? _gastarDesafio() {
    final token = _tokenDesafio;
    if (token != null || _desafioFalhou) {
      // Token gasto, ou caixa rebentada: a próxima caixa nasce de novo.
      setState(() {
        _tokenDesafio = null;
        _desafioFalhou = false;
        _desafioGeracao++;
      });
    }
    return token;
  }

  // ------------------------------------------------------------------ ações

  String get _numeros => _codigo.text.replaceAll(RegExp(r'\D'), '');

  /// O aviso vermelho vive colado ao campo a que diz respeito. Se ficasse no
  /// fundo do ecrã, a lista não o desenhava e a pessoa não via a explicação.
  List<Widget> _vermelho(AppLocalizations l, SessaoStore s) => s.temErro
      ? [const SizedBox(height: 12), Aviso(_frase(l, s), tom: Semaforo.vermelho)]
      : const [];

  Future<void> _enviar(SessaoStore s) async {
    FocusScope.of(context).unfocus();
    final ok = await s.enviarCodigo(_email.text, captchaToken: _gastarDesafio());
    if (ok && mounted) {
      _codigo.clear();
      setState(() {});
      _focoCodigo.requestFocus();
    }
  }

  Future<void> _reenviar(SessaoStore s) async {
    _codigo.clear();
    setState(() {});
    await s.reenviarCodigo(captchaToken: _gastarDesafio());
    if (mounted) _focoCodigo.requestFocus();
  }

  Future<void> _entrarComPalavraPasse(SessaoStore s) async {
    FocusScope.of(context).unfocus();
    await s.entrarComPalavraPasse(
      _email.text,
      _palavraPasse.text,
      captchaToken: _gastarDesafio(),
    );
  }

  void _trocarEmail(SessaoStore s) {
    _espera?.cancel();
    _codigo.clear();
    s.trocarEmail();
    setState(() {});
  }

  /// Enquanto escreve: limpa o vermelho e, quando o código enche, confirma
  /// sozinho. Espera 400 ms para o caso de o código ser mais comprido do que
  /// o costume (foi o que aconteceu com os 8 números).
  void _mudouCodigo(SessaoStore s, String texto) {
    setState(() {});
    s.limparErro();
    _espera?.cancel();
    final n = texto.replaceAll(RegExp(r'\D'), '').length;
    if (n == SessaoStore.tamanhoMaximo) {
      _confirmar(s);
    } else if (n >= SessaoStore.tamanhoCodigo) {
      _espera = Timer(const Duration(milliseconds: 400), () {
        if (mounted && !s.aTrabalhar) _confirmar(s);
      });
    }
  }

  Future<void> _confirmar(SessaoStore s) async {
    _espera?.cancel();
    FocusScope.of(context).unfocus();
    await s.confirmarCodigo(_codigo.text);
  }

  /// A frase de cada erro. `codigoErrado` tem duas caras: no passo do código
  /// é o código; no ecrã do revisor (sem código pendente) é a palavra-passe.
  String _frase(AppLocalizations l, SessaoStore s) => switch (s.erro) {
        ErroLogin.emailInvalido => l.loginEmailInvalido,
        ErroLogin.emailDeMentira => l.loginEmailDeMentira,
        ErroLogin.registoFechado => l.loginErro,
        ErroLogin.rede => l.erroRede,
        ErroLogin.muitosPedidos => l.loginMuitosPedidos,
        ErroLogin.codigoCurto => l.loginCodigoCurto,
        ErroLogin.codigoErrado => s.emailPendente == null && s.ehRevisor(_email.text)
            ? l.loginPalavraPasseErrada
            : l.loginCodigoErrado,
        ErroLogin.codigoExpirado => l.loginCodigoExpirado,
        ErroLogin.antiRobo => l.loginAntiRobo,
        ErroLogin.generico => l.loginErro,
        ErroLogin.nenhum => '',
      };
}

/// As casinhas do código. Por baixo há um campo de texto normal (invisível)
/// para o teclado, o colar e o preenchimento automático funcionarem como
/// sempre; por cima desenham-se as casas. Se o código vier maior do que o
/// costume, nascem casas a mais em vez de o resto se perder.
class _CasasDoCodigo extends StatelessWidget {
  final TextEditingController controlador;
  final FocusNode foco;
  final String rotulo;
  final ValueChanged<String> aoMudar;

  const _CasasDoCodigo({
    required this.controlador,
    required this.foco,
    required this.rotulo,
    required this.aoMudar,
  });

  @override
  Widget build(BuildContext context) {
    final texto = controlador.text.replaceAll(RegExp(r'\D'), '');
    final quantas = texto.length > SessaoStore.tamanhoCodigo
        ? texto.length
        : SessaoStore.tamanhoCodigo;
    return Semantics(
      label: rotulo,
      textField: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              for (var i = 0; i < quantas; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _casa(context, i < texto.length ? texto[i] : '', foco.hasFocus && i == texto.length)),
              ],
            ],
          ),
          // O campo a sério: transparente, por cima, a ocupar tudo.
          SizedBox(
            height: 64,
            child: TextField(
              controller: controlador,
              focusNode: foco,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(SessaoStore.tamanhoMaximo),
              ],
              showCursor: false,
              cursorColor: Colors.transparent,
              style: const TextStyle(color: Colors.transparent, fontSize: 1, height: 0.1),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: aoMudar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _casa(BuildContext context, String numero, bool aEsperar) {
    final t = Theme.of(context).textTheme;
    return Container(
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppTheme.cantosPequenos,
        border: Border.all(
          color: numero.isNotEmpty
              ? AppColors.emDia
              : (aEsperar ? AppColors.emDia : AppColors.divider),
          width: numero.isNotEmpty || aEsperar ? 2 : 1,
        ),
      ),
      child: Text(numero, style: t.headlineSmall),
    );
  }
}
