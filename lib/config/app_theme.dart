import 'package:flutter/material.dart';

/// Tema do Em Dia.
///
/// Design system (ordem da missão 2026-09-05): verde `#16A34A` = em dia,
/// laranja `#F97316` = a vencer, vermelho `#DC2626` = passou, fundo claro,
/// cantos 16, fonte Inter.
///
/// LIÇÃO DO BORA (botões com `fontFamily: null`): TODOS os estilos de texto
/// levam `fontFamily: 'Inter'` explícito. Nunca deixar um TextStyle sem
/// família, senão o Android troca para Roboto só nesse sítio.
class AppTheme {
  AppTheme._();

  static const String fonte = 'Inter';

  // Semáforo
  static const Color emDia = Color(0xFF16A34A); // verde — está tudo em dia
  static const Color aVencer = Color(0xFFF97316); // laranja — a vencer
  static const Color passou = Color(0xFFDC2626); // vermelho — prazo passado

  // Verde (marca)
  static const Color primary = emDia;
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryDeep = Color(0xFF065F46);
  static const Color primaryLight = Color(0xFFDCFCE7);
  static const Color primaryWash = Color(0xFFF0FDF4);

  // Laranja
  static const Color accent = aVencer;
  static const Color accentDark = Color(0xFFEA580C);
  static const Color accentLight = Color(0xFFFFEDD5);

  // Vermelho
  static const Color danger = passou;
  static const Color dangerLight = Color(0xFFFEE2E2);

  // Fundo e superfícies (claro)
  static const Color background = Color(0xFFF6F7F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF1F3EF);
  static const Color divider = Color(0xFFE5E7EB);

  // Texto
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textSubtle = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Colors.white;

  // Cantos
  static const double raio = 16;
  static const BorderRadius cantos = BorderRadius.all(Radius.circular(raio));
  static const BorderRadius cantosPequenos =
      BorderRadius.all(Radius.circular(12));

  // Sombras (slate-900 com alfa baixo)
  static const List<BoxShadow> sombraCartao = [
    BoxShadow(color: Color(0x140F172A), offset: Offset(0, 2), blurRadius: 8),
  ];
  static const List<BoxShadow> sombraGrande = [
    BoxShadow(color: Color(0x1F0F172A), offset: Offset(0, 8), blurRadius: 24),
  ];

  static TextStyle _t({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = textPrimary,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: fonte,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static ThemeData get claro {
    final textTheme = TextTheme(
      displayLarge: _t(size: 40, weight: FontWeight.w800, height: 1.1),
      displayMedium: _t(size: 32, weight: FontWeight.w800, height: 1.15),
      headlineLarge: _t(size: 28, weight: FontWeight.w800, height: 1.2),
      headlineMedium: _t(size: 24, weight: FontWeight.w700, height: 1.2),
      headlineSmall: _t(size: 20, weight: FontWeight.w700, height: 1.25),
      titleLarge: _t(size: 18, weight: FontWeight.w700, height: 1.3),
      titleMedium: _t(size: 16, weight: FontWeight.w600, height: 1.3),
      titleSmall: _t(size: 14, weight: FontWeight.w600, height: 1.3),
      bodyLarge: _t(size: 17, height: 1.45),
      bodyMedium: _t(size: 15, height: 1.45),
      bodySmall: _t(size: 13, color: textSecondary, height: 1.4),
      labelLarge: _t(size: 16, weight: FontWeight.w600, letterSpacing: 0.2),
      labelMedium: _t(size: 14, weight: FontWeight.w600),
      labelSmall: _t(size: 12, weight: FontWeight.w600, color: textSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fonte,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: accent,
        onSecondary: Colors.white,
        error: danger,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        primaryContainer: primaryLight,
        onPrimaryContainer: primaryDeep,
        secondaryContainer: accentLight,
        onSecondaryContainer: accentDark,
        errorContainer: dangerLight,
        onErrorContainer: danger,
        outline: divider,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _t(size: 20, weight: FontWeight.w700),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: cantos),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textOnPrimary,
          disabledBackgroundColor: divider,
          disabledForegroundColor: textSubtle,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: cantos),
          textStyle: _t(size: 17, weight: FontWeight.w700, color: textOnPrimary),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textOnPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(borderRadius: cantos),
          textStyle: _t(size: 17, weight: FontWeight.w700, color: textOnPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: primary, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: cantos),
          textStyle: _t(size: 17, weight: FontWeight.w700, color: primaryDark),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          textStyle: _t(size: 16, weight: FontWeight.w600, color: primaryDark),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: const OutlineInputBorder(
          borderRadius: cantosPequenos,
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: cantosPequenos,
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: cantosPequenos,
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: cantosPequenos,
          borderSide: BorderSide(color: danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: cantosPequenos,
          borderSide: BorderSide(color: danger, width: 2),
        ),
        labelStyle: _t(size: 15, color: textSecondary),
        hintStyle: _t(size: 16, color: textSubtle),
        helperStyle: _t(size: 13, color: textSecondary),
        errorStyle: _t(size: 13, color: danger),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface2,
        selectedColor: primaryLight,
        labelStyle: _t(size: 14, weight: FontWeight.w600),
        shape: const RoundedRectangleBorder(borderRadius: cantosPequenos),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primaryLight,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => _t(
            size: 12,
            weight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? primaryDark
                : textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primaryDark
                : textSecondary,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textPrimary,
        contentTextStyle: _t(size: 15, color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: cantosPequenos),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: cantos),
        titleTextStyle: _t(size: 20, weight: FontWeight.w700),
        contentTextStyle: _t(size: 15, height: 1.45),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        space: 1,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: _t(size: 16, weight: FontWeight.w600),
        subtitleTextStyle: _t(size: 14, color: textSecondary, height: 1.35),
        shape: const RoundedRectangleBorder(borderRadius: cantos),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : null,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: divider,
      ),
    );
  }
}
