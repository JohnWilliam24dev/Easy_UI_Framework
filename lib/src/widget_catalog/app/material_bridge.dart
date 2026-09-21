import 'package:flutter/material.dart';

import '../../theme_layer/theme_layer.dart';

/// Constrói o `ThemeData` do Material a partir dos tokens explícitos.
///
/// O catálogo pinta cada widget com os tokens; este tema existe só para que
/// qualquer parte do Material que ainda apareça (ex: diálogos, seleção de
/// texto) use a paleta do app e não a padrão do Material.
ThemeData materialThemeFor(ThemeTokens tokens, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    fontFamily: tokens.fontFamily,
    scaffoldBackgroundColor: tokens.backgroundColor,
    canvasColor: tokens.surfaceColor,
    dividerColor: tokens.borderColor,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: tokens.primaryColor,
      onPrimary: tokens.onPrimaryColor,
      secondary: tokens.secondaryColor,
      onSecondary: _contrastOn(tokens.secondaryColor),
      error: tokens.errorColor,
      onError: _contrastOn(tokens.errorColor),
      surface: tokens.surfaceColor,
      onSurface: tokens.textColor,
    ),
  );
}

Color _contrastOn(Color color) {
  return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF000000);
}

/// Traduz o modo do `AppTheme` para o `ThemeMode` do Material.
ThemeMode materialThemeModeFor(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };
}
