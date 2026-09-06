import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'services/fala.dart';
import 'services/push.dart';
import 'l10n/app_localizations.dart';
import 'screens/guia_inicio/guia_inicio_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/shell/shell_screen.dart';
import 'stores/dados_store.dart';
import 'stores/perfil_store.dart';
import 'stores/regras_store.dart';
import 'stores/sessao_store.dart';
import 'widgets/widgets.dart';

/// A app inteira: providers (padrão Model → Store → Screen do Bora), tema,
/// idiomas (PT-PT por omissão; PT-BR se o perfil ou o telemóvel pedirem) e o
/// navegador de raiz.
class EmDiaApp extends StatelessWidget {
  const EmDiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessaoStore()),
        // A voz é uma só em toda a app: começar a ler num sítio cala o outro.
        ChangeNotifierProvider<Fala>.value(value: Fala.instancia),
        ChangeNotifierProvider(create: (_) => RegrasStore()..carregar()),
        ChangeNotifierProvider(create: (_) => PlanoStore()),
        ChangeNotifierProvider(create: (_) => PerfilStore()),
        ChangeNotifierProvider(create: (_) => ObrigacoesStore()),
        ChangeNotifierProvider(create: (_) => RendimentosStore()),
        ChangeNotifierProvider(create: (_) => CarrosStore()),
      ],
      child: Consumer<PerfilStore>(
        builder: (context, perfilStore, _) {
          final variante = perfilStore.perfil?.variantePt;
          final locale = variante == 'br' ? const Locale('pt', 'BR') : (variante == 'pt' ? const Locale('pt') : null);
          return MaterialApp(
            title: 'Em Dia',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.claro,
            locale: locale,
            supportedLocales: const [Locale('pt'), Locale('pt', 'BR')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (device, supported) {
              if (locale != null) return locale;
              if (device?.languageCode == 'pt' && device?.countryCode == 'BR') {
                return const Locale('pt', 'BR');
              }
              return const Locale('pt');
            },
            home: const RaizNavegador(),
          );
        },
      ),
    );
  }
}

/// Navegador de raiz (padrão `_RootNavigator` do Bora): não é um Navigator,
/// é um widget que observa a sessão e o perfil e devolve o ecrã certo.
/// Login → Onboarding (se não concluído) → Shell (as 5 abas).
class RaizNavegador extends StatefulWidget {
  const RaizNavegador({super.key});

  @override
  State<RaizNavegador> createState() => _RaizNavegadorState();
}

class _RaizNavegadorState extends State<RaizNavegador> {
  String? _userCarregado;

  Future<void> _carregarTudo(BuildContext context, String userId) async {
    if (_userCarregado == userId) return;
    _userCarregado = userId;
    final perfil = context.read<PerfilStore>();
    final plano = context.read<PlanoStore>();
    final obrig = context.read<ObrigacoesStore>();
    final rend = context.read<RendimentosStore>();
    final carros = context.read<CarrosStore>();
    await perfil.carregar(userId);
    // Avisos push: regista o token deste aparelho (sem Firebase configurado, não faz nada).
    unawaited(PushService.registar(userId));
    await Future.wait([
      plano.carregar(userId),
      obrig.carregar(userId),
      rend.carregar(userId),
      carros.carregar(userId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessaoStore>();
    final perfilStore = context.watch<PerfilStore>();

    if (!sessao.pronto) return const _Splash();
    if (!sessao.autenticado) {
      _userCarregado = null;
      return const LoginScreen();
    }
    final userId = sessao.userId!;
    if (_userCarregado != userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _carregarTudo(context, userId));
    }
    final perfil = perfilStore.perfil;
    if (perfil == null) {
      // Sem perfil há dois casos, e são muito diferentes: ou ainda está a
      // carregar, ou falhou. Antes mostravam o mesmo — um splash a rodar para
      // sempre. Foi assim que o Bora ficou preso, e não se repete aqui.
      if (perfilStore.aCarregar || perfilStore.erro == null) return const _Splash();
      return ContaNaoAbriu(
        aoTentar: () => perfilStore.carregar(userId),
        aoSair: sessao.sair,
      );
    }
    if (!perfil.onboardingConcluido) return const OnboardingScreen();
    // Guia de primeira utilização: três ecrãs, uma só vez. A marca fica no
    // servidor (`viu_guia_inicio`), para quem trocar de telemóvel não repetir.
    if (!perfil.viuGuiaInicio) return const GuiaInicioScreen();
    return const ShellScreen();
  }
}

/// Entrou, mas a conta não abriu. Diz o que se passa e dá dois caminhos —
/// nunca uma roda a girar sem fim.
class ContaNaoAbriu extends StatelessWidget {
  final Future<void> Function() aoTentar;
  final Future<void> Function() aoSair;
  const ContaNaoAbriu({super.key, required this.aoTentar, required this.aoSair});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: paddingEcra,
              shrinkWrap: true,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 56, color: AppTheme.aVencer),
                const SizedBox(height: 16),
                Text(l.arranqueFalhouTitulo, textAlign: TextAlign.center, style: t.headlineSmall),
                const SizedBox(height: 10),
                Text(l.arranqueFalhouLinha,
                    textAlign: TextAlign.center,
                    style: t.bodyMedium!.copyWith(color: AppTheme.textSecondary)),
                const SizedBox(height: 24),
                BotaoGrande(texto: l.tentarOutraVez, aoTocar: aoTentar),
                const SizedBox(height: 10),
                BotaoGrande(texto: l.sair, secundario: true, aoTocar: aoSair),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 72, color: AppTheme.emDia),
            SizedBox(height: 16),
            Text('Em Dia',
                style: TextStyle(fontFamily: AppTheme.fonte, fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            SizedBox(height: 24),
            SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
          ],
        ),
      ),
    );
  }
}
