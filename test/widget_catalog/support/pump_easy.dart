import 'package:easy_ui/src/theme_layer/theme_layer.dart';
import 'package:easy_ui/src/widget_catalog/app/easy_app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const testTokens = ThemeTokens(
  primaryColor: Color(0xFF2196F3),
  secondaryColor: Color(0xFF00BFA5),
  backgroundColor: Color(0xFFFFFFFF),
  textColor: Color(0xFF212121),
);

const testDarkTokens = ThemeTokens(
  primaryColor: Color(0xFF90CAF9),
  secondaryColor: Color(0xFF64FFDA),
  backgroundColor: Color(0xFF121212),
  textColor: Color(0xFFFFFFFF),
);

const testTheme = AppTheme(
  light: testTokens,
  dark: testDarkTokens,
  mode: AppThemeMode.light,
);

/// Monta [home] dentro de um EasyApp, com viewport fixa (800x600 por padrão,
/// pixel ratio 1) para que vw/vh sejam determinísticos.
Future<void> pumpEasy(
  WidgetTester tester,
  Widget home, {
  StylePack pack = StylePack.standard,
  AppTheme theme = testTheme,
  Size size = const Size(800, 600),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(EasyApp(theme: theme, stylePack: pack, home: home));
}
