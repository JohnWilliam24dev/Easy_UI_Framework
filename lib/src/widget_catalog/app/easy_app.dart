import 'package:flutter/material.dart';

import '../../theme_layer/theme_layer.dart';
import 'material_bridge.dart';

/// Ponto de entrada do app: monta o `MaterialApp` (detalhe interno) já com
/// os tokens do [AppTheme] e o [StylePack] ativo.
///
/// ```dart
/// runApp(EasyApp(
///   theme: AppTheme(light: ..., dark: ...),
///   stylePack: StylePack.byName('cliente_convidativo'),
///   home: LoginPage(),
/// ));
/// ```
///
/// Todas as rotas ficam dentro do `AppThemeScope` e do `StylePackScope`;
/// para usar outro pack numa parte do app, envolva a subárvore em um novo
/// `StylePackScope`.
class EasyApp extends StatelessWidget {
  const EasyApp({
    super.key,
    required this.theme,
    required this.home,
    this.stylePack = StylePack.standard,
    this.title = '',
    this.debugShowCheckedModeBanner = false,
  });

  final AppTheme theme;
  final Widget home;
  final StylePack stylePack;
  final String title;
  final bool debugShowCheckedModeBanner;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      theme: materialThemeFor(theme.light, Brightness.light),
      darkTheme: materialThemeFor(theme.dark, Brightness.dark),
      themeMode: materialThemeModeFor(theme.mode),
      // Dentro do builder já existe MediaQuery, necessário para o modo system.
      builder: (context, child) {
        return AppThemeScope(
          theme: theme,
          child: StylePackScope(
            pack: stylePack,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: home,
    );
  }
}
