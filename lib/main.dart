// Em Dia — a app (PT-PT). Painel admin: lib/main_admin.dart.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'config/app_colors.dart';
import 'config/app_theme.dart';
import 'services/arranque.dart';

Future<void> main() async {
  // NUNCA MAIS UM ECRÃ CINZENTO.
  //
  // A 6 de setembro de 2026 um utilizador novo, logo a seguir ao onboarding,
  // ficou a olhar para um ecrã cinzento sem uma palavra: um erro de build no
  // guia de 3 ecrãs, e o Flutter, em release, pinta cinzento e cala-se. O
  // erro do guia está corrigido, mas a regra fica: quando alguma coisa rebenta,
  // a pessoa vê uma frase em português e um botão para voltar ao início —
  // nunca cinzento.
  ErrorWidget.builder = (FlutterErrorDetails detalhes) => _EcraDeErro(detalhes: detalhes);

  // Os erros ficam no registo do browser/adb com o texto completo; em release
  // continuam a ser apanhados aqui em vez de matarem a app em silêncio.
  FlutterError.onError = (detalhes) {
    FlutterError.presentError(detalhes);
    debugPrint('Em Dia: erro de Flutter — ${detalhes.exceptionAsString()}');
  };

  await runZonedGuarded(() async {
    await arrancar();
    runApp(const EmDiaApp());
  }, (erro, pilha) {
    debugPrint('Em Dia: erro fora do Flutter — $erro\n$pilha');
  });
}

/// O que aparece no lugar de um widget que rebentou.
///
/// Não tem traduções: se o erro for na própria árvore das traduções, um
/// `AppLocalizations.of` aqui rebentava outra vez. Português de Portugal fixo,
/// simples, com o botão a fazer a única coisa que ajuda — recomeçar a app.
class _EcraDeErro extends StatelessWidget {
  final FlutterErrorDetails detalhes;
  const _EcraDeErro({required this.detalhes});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.build_circle_outlined, size: 56, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              const Text(
                'Isto não devia ter acontecido.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: AppTheme.fonte, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Uma parte da app não abriu. Os teus dados estão guardados. Toca no botão para recomeçar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: AppTheme.fonte, fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => runApp(const EmDiaApp()),
                child: const Text('Recomeçar', style: TextStyle(fontFamily: AppTheme.fonte, fontSize: 16)),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                Text(detalhes.exceptionAsString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: AppTheme.fonte, fontSize: 12, color: AppColors.passou)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
