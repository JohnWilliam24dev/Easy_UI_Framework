import 'package:easy_ui/easy_ui.dart';
import 'package:easy_ui_example/theme/example_theme.dart';
import 'package:easy_ui_example/theme/style_packs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta [home] dentro de um EasyApp com o tema e o pack do exemplo.
Widget easyHome(Widget home, {StylePack? pack}) {
  return EasyApp(
    theme: exampleTheme,
    stylePack: pack ?? clientePack,
    home: home,
  );
}

Future<void> preencherLogin(
  WidgetTester tester, {
  required String username,
  required String password,
}) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), username);
  await tester.enterText(campos.at(1), password);
  await tester.pump();
}

/// `true` se o botão de login está habilitado.
bool loginHabilitado(WidgetTester tester) {
  final botao = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
  return botao.onPressed != null;
}
