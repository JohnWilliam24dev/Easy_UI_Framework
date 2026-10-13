import 'package:easy_ui/src/theme_layer/tokens/tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sincroniza modo e adaptador booleano', () {
    final controller = AppThemeController();
    expect(controller.mode, AppThemeMode.system);
    controller.darkMode.value = true;
    expect(controller.mode, AppThemeMode.dark);
    controller.mode = AppThemeMode.light;
    expect(controller.darkMode.value, isFalse);
    controller.useSystem();
    expect(controller.mode, AppThemeMode.system);
    controller.dispose();
  });
}
