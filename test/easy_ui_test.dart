import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('barrel exporta as unidades declarativas', () {
    expect(50.vw, const Vw(50));
    expect(100.vh, const Vh(100));
    expect(30.pct, const Percent(30));
    expect(200.px, const Px(200));
    expect(1.fr, const Fr(1));
  });

  test('barrel exporta tema e StylePack', () {
    const tokens = ThemeTokens(
      primaryColor: Color(0xFF2196F3),
      secondaryColor: Color(0xFF00BFA5),
      backgroundColor: Color(0xFFFFFFFF),
      textColor: Color(0xDD000000),
    );
    const tema = AppTheme(light: tokens, dark: tokens);
    expect(tema.mode, AppThemeMode.system);

    final pack = StylePack.define(
      name: 'barrel_teste',
      inputText: const InputStyleSpec.rounded(
        radius: 16,
        elevation: ElevationLevel.subtle,
      ),
      button: const ButtonStyleSpec.pill(),
      spacingScale: 1.2,
    );
    expect(StylePack.byName('barrel_teste'), pack);
  });

  test('barrel exporta o catálogo e o vocabulário de layout', () {
    expect(const Label(text: 'x').type, LabelType.body);
    expect(const Button(text: 'x').variant, ButtonVariant.solid);
    expect(const InputField().type, InputType.text);
    expect(LayoutPosition.center, isNotNull);
    expect(LayoutDirection.vertical, isNotNull);
  });
}
