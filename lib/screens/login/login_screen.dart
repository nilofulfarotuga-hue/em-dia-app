import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';

/// Entrar: e-mail → código de 6 números (sem palavra-passe) ou Google.
class LoginScreen extends StatefulWidget {
  final bool modoAdmin;
  const LoginScreen({super.key, this.modoAdmin = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _codigo = TextEditingController();
  bool _codigoEnviado = false;

  @override
  void dispose() {
    _email.dispose();
    _codigo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sessao = context.watch<SessaoStore>();
    final t = Theme.of(context).textTheme;
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
                Text(widget.modoAdmin ? 'Em Dia — Admin' : l.appNome, textAlign: TextAlign.center, style: t.headlineLarge),
                const SizedBox(height: 32),
                if (!_codigoEnviado) ...[
                  Text(l.loginTitulo, style: t.headlineSmall),
                  const SizedBox(height: 6),
                  Text(l.loginAjuda, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(labelText: l.loginEmail, prefixIcon: const Icon(Icons.mail_outline_rounded)),
                    onSubmitted: (_) => _enviar(sessao),
                  ),
                  const SizedBox(height: 16),
                  BotaoGrande(texto: l.loginEnviarCodigo, aTrabalhar: sessao.aTrabalhar, aoTocar: () => _enviar(sessao)),
                  if (sessao.googleDisponivel && !widget.modoAdmin) ...[
                    const SizedBox(height: 20),
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(l.loginOu, style: t.bodySmall)),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 20),
                    BotaoGrande(texto: l.loginGoogle, secundario: true, icone: Icons.g_mobiledata_rounded, aoTocar: sessao.entrarComGoogle),
                  ],
                ] else ...[
                  Text(l.loginCodigoTitulo, style: t.headlineSmall),
                  const SizedBox(height: 6),
                  Text(sessao.emailPendente ?? '', style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _codigo,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    style: t.headlineMedium!.copyWith(letterSpacing: 8),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(labelText: l.loginCodigo, counterText: ''),
                    onSubmitted: (_) => _confirmar(sessao),
                  ),
                  const SizedBox(height: 16),
                  BotaoGrande(texto: l.loginConfirmar, aTrabalhar: sessao.aTrabalhar, aoTocar: () => _confirmar(sessao)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => setState(() => _codigoEnviado = false), child: Text(l.onbVoltar)),
                ],
                if (sessao.erro != null) ...[
                  const SizedBox(height: 16),
                  Aviso(_codigoEnviado ? l.loginCodigoErrado : l.loginErro, tom: Semaforo.vermelho),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _enviar(SessaoStore s) async {
    if (_email.text.trim().isEmpty) return;
    final ok = await s.enviarCodigo(_email.text);
    if (ok && mounted) setState(() => _codigoEnviado = true);
  }

  Future<void> _confirmar(SessaoStore s) async {
    if (_codigo.text.trim().length < 6) return;
    await s.confirmarCodigo(_codigo.text);
  }
}
