import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Tokens de cor do Em Dia. Os ecrãs usam ISTO, nunca hex à mão.
class AppColors {
  AppColors._();

  // Semáforo (a linguagem visual de toda a app)
  static const Color emDia = AppTheme.emDia;
  static const Color aVencer = AppTheme.aVencer;
  static const Color passou = AppTheme.passou;
  static const Color emDiaClaro = AppTheme.primaryLight;
  static const Color aVencerClaro = AppTheme.accentLight;
  static const Color passouClaro = AppTheme.dangerLight;

  // Marca
  static const Color primary = AppTheme.primary;
  static const Color primaryDark = AppTheme.primaryDark;
  static const Color primaryDeep = AppTheme.primaryDeep;
  static const Color primaryLight = AppTheme.primaryLight;
  static const Color primaryWash = AppTheme.primaryWash;
  static const Color accent = AppTheme.accent;
  static const Color accentDark = AppTheme.accentDark;
  static const Color danger = AppTheme.danger;

  // Superfícies
  static const Color background = AppTheme.background;
  static const Color surface = AppTheme.surface;
  static const Color surface2 = AppTheme.surface2;
  static const Color divider = AppTheme.divider;

  // Texto
  static const Color textPrimary = AppTheme.textPrimary;
  static const Color textSecondary = AppTheme.textSecondary;
  static const Color textSubtle = AppTheme.textSubtle;
  static const Color textOnPrimary = AppTheme.textOnPrimary;

  // Informação neutra (dicas, links)
  static const Color info = Color(0xFF2563EB);
  static const Color infoClaro = Color(0xFFDBEAFE);

  // Cadeado (funcionalidade Pro)
  static const Color cadeado = Color(0xFF7C3AED);
  static const Color cadeadoClaro = Color(0xFFEDE9FE);

  /// Cor do semáforo por estado de obrigação.
  static Color porEstado(String estado, {int? diasParaPrazo}) {
    if (estado == 'passado') return passou;
    if (estado == 'pago') return emDia;
    if (diasParaPrazo != null && diasParaPrazo <= 5) return aVencer;
    return emDia;
  }
}
