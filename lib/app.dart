import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/login/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/shell/shell_screen.dart';
import 'stores/dados_store.dart';
import 'stores/perfil_store.dart';
import 'stores/regras_store.dart';
import 'stores/sessao_store.dart';

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
    if (perfil == null) return const _Splash();
    if (!perfil.onboardingConcluido) return const OnboardingScreen();
    return const ShellScreen();
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
