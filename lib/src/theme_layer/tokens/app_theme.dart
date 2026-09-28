import 'package:flutter/widgets.dart' show Brightness, immutable;

import 'theme_tokens.dart';

/// Como o app escolhe entre o tema claro e o escuro.
enum AppThemeMode {
  /// Sempre claro.
  light,

  /// Sempre escuro.
  dark,

  /// Segue a preferência da plataforma.
  system,
}

/// Os dois conjuntos de tokens do app e a regra para escolher entre eles.
///
/// ```dart
/// AppTheme(
///   light: ThemeTokens(primaryColor: ..., ...),
///   dark: ThemeTokens(primaryColor: ..., ...),
/// )
/// ```
@immutable
class AppTheme {
  const AppTheme({
    required this.light,
    required this.dark,
    this.mode = AppThemeMode.system,
  });

  final ThemeTokens light;
  final ThemeTokens dark;
  final AppThemeMode mode;

  /// Tokens correspondentes a um brilho.
  ThemeTokens tokensFor(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  /// Brilho efetivo, dado o brilho preferido pela plataforma.
  Brightness resolveBrightness(Brightness platform) {
    return switch (mode) {
      AppThemeMode.light => Brightness.light,
      AppThemeMode.dark => Brightness.dark,
      AppThemeMode.system => platform,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is AppTheme &&
        other.light == light &&
        other.dark == dark &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(light, dark, mode);
}
