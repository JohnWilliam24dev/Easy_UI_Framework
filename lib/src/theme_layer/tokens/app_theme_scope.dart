import 'package:flutter/widgets.dart';

import '../../kernel/kernel.dart';
import 'app_theme.dart';
import 'theme_tokens.dart';

/// Disponibiliza os [ThemeTokens] ativos para a subárvore, já escolhendo
/// entre claro e escuro conforme [AppTheme.mode].
///
/// Não há tema padrão: como as cores são sempre explícitas, consultar tokens
/// sem um [AppThemeScope] acima lança [FlutterError].
class AppThemeScope extends StatelessWidget {
  const AppThemeScope({super.key, required this.theme, required this.child});

  final AppTheme theme;
  final Widget child;

  /// Tokens ativos neste ponto da árvore.
  static ThemeTokens tokensOf(BuildContext context) {
    return _inheritedOf(context).tokens;
  }

  /// Brilho efetivo (já considerando o modo do tema) neste ponto da árvore.
  static Brightness brightnessOf(BuildContext context) {
    return _inheritedOf(context).brightness;
  }

  static _AppThemeInherited _inheritedOf(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_AppThemeInherited>();
    if (inherited == null) {
      throw FlutterError(
        'Nenhum AppThemeScope encontrado acima deste widget.\n'
        'Envolva o app em AppThemeScope(theme: AppTheme(...), child: ...) '
        'para definir os tokens de cor.',
      );
    }
    return inherited;
  }

  @override
  Widget build(BuildContext context) {
    // Só assina o MediaQuery quando o tema realmente segue a plataforma.
    final platform = theme.mode == AppThemeMode.system
        ? platformBrightnessOf(context)
        : Brightness.light;
    final brightness = theme.resolveBrightness(platform);
    return _AppThemeInherited(
      tokens: theme.tokensFor(brightness),
      brightness: brightness,
      child: child,
    );
  }
}

class _AppThemeInherited extends InheritedWidget {
  const _AppThemeInherited({
    required this.tokens,
    required this.brightness,
    required super.child,
  });

  final ThemeTokens tokens;
  final Brightness brightness;

  @override
  bool updateShouldNotify(_AppThemeInherited oldWidget) {
    return tokens != oldWidget.tokens || brightness != oldWidget.brightness;
  }
}
