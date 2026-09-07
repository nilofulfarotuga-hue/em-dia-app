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

/// Anti-robô (Cloudflare Turnstile) no pedido do código de entrada. A 6 de
/// setembro de 2026 o Googlebot submeteu o formulário de entrada com e-mails
/// inventados e tentou códigos no /verify. Com esta chave, a app pede um
/// token ao Turnstile antes de cada pedido de código e manda-o ao Supabase
/// (`captcha_token`). Chave VAZIA = sem captcha nenhum: os testes, as fotos e
/// as builds antigas continuam a funcionar, e enquanto a protecção estiver
/// desligada no servidor o token é simplesmente ignorado. A chave do sítio é
/// pública — vai no --dart-define como as outras.
const String turnstileSiteKey = String.fromEnvironment('TURNSTILE_SITE_KEY');

/// O domínio a que o widget do Turnstile está preso (lista de domínios do
/// widget, na Cloudflare). No Android é obrigatório — o WebView escondido
/// finge estar nesta página; na web é ignorado. Desde 2026-09-07 a app vive
/// em app.emdia.boraguarda.com (o app-em-dia.pages.dev só redireciona); este
/// domínio tem de constar na lista do widget, senão o Android fica sem token.
const String turnstileBaseUrl = 'https://app.emdia.boraguarda.com/';

/// O revisor da Google Play não tem caixa de e-mail para receber o código, e
/// sem entrar a Google rejeita a app. Este e-mail (e só este) entra com
/// palavra-passe; a conta é criada no servidor pelo orquestrador. É público —
/// é só um e-mail; a palavra-passe nunca está na app. Vazio = não há revisor.
const String emailRevisor = String.fromEnvironment('EMAIL_REVISOR');

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
