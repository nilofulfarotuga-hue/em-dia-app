import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../stores/regras_store.dart';
import '../stores/sessao_store.dart';
import 'admin_shell.dart';

/// Painel admin (PT-BR). Só entra quem é admin (claim ou tabela `admins`).
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessaoStore()),
        ChangeNotifierProvider(create: (_) => RegrasStore()..carregar()),
      ],
      child: MaterialApp(
        title: 'Em Dia — Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt'), Locale('pt', 'BR')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AdminShell(),
      ),
    );
  }
}
