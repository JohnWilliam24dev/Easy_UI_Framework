import 'package:flutter/material.dart';

import '../../kernel/kernel.dart' show platformBrightnessOf;
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
    this.themeController,
    this.stylePack = StylePack.standard,
    this.title = '',
    this.debugShowCheckedModeBanner = false,
    this.routes = const <String, WidgetBuilder>{},
    this.onGenerateRoute,
    this.navigatorKey,
    this.navigatorObservers = const <NavigatorObserver>[],
  });

  final AppTheme theme;
  final AppThemeController? themeController;
  final Widget home;
  final StylePack stylePack;
  final String title;
  final bool debugShowCheckedModeBanner;
  final Map<String, WidgetBuilder> routes;
  final RouteFactory? onGenerateRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;

  @override
  Widget build(BuildContext context) {
    final controller = themeController;
    if (controller == null) return _buildApp(theme);
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: controller,
      builder: (context, mode, _) =>
          _buildApp(theme.copyWith(mode: mode), controller),
    );
  }

  Widget _buildApp(AppTheme activeTheme, [AppThemeController? controller]) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      theme: materialThemeFor(activeTheme.light, Brightness.light),
      darkTheme: materialThemeFor(activeTheme.dark, Brightness.dark),
      themeMode: materialThemeModeFor(activeTheme.mode),
      routes: routes,
      onGenerateRoute: onGenerateRoute,
      navigatorKey: navigatorKey,
      navigatorObservers: navigatorObservers,
      // Dentro do builder já existe MediaQuery, necessário para o modo system.
      builder: (context, child) {
        if (controller != null) {
          final platformBrightness = platformBrightnessOf(context);
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => controller.syncSystemBrightness(platformBrightness),
          );
        }
        return AppThemeScope(
          theme: activeTheme,
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
