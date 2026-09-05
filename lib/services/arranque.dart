import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Arranque comum à app e ao painel admin: Supabase (chaves por
/// --dart-define, NUNCA no código) e o resto que precisa de estar pronto
/// antes do `runApp`.
///
/// Uso: `flutter run --dart-define-from-file=.dart_defines`
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const String googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
const int versionCodeCi = int.fromEnvironment('EMDIA_VERSION_CODE', defaultValue: 0);

bool _arrancou = false;

Future<void> arrancar() async {
  if (_arrancou) return;
  WidgetsFlutterBinding.ensureInitialized();
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    // Sem chaves a app não pode falar com o servidor. Falha alto e cedo —
    // a lição do Bora foi ficar presa no splash em silêncio.
    debugPrint('ERRO: SUPABASE_URL/SUPABASE_ANON_KEY em falta. '
        'Corre com --dart-define-from-file=.dart_defines');
  }
  await Supabase.initialize(
    url: supabaseUrl.isEmpty ? 'https://invalido.supabase.co' : supabaseUrl,
    anonKey: supabaseAnonKey.isEmpty ? 'sem-chave' : supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  _arrancou = true;
}

SupabaseClient get sb => Supabase.instance.client;

bool get temChaves => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
