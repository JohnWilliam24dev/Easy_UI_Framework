import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' show Icons;
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

  test('barrel exporta FormGroup e os validadores', () {
    const FormValues nada = <String, String>{};
    expect(const FormGroup().children, isEmpty);
    expect(isRequired()('', nada), isNotNull);
    expect(minLength(3)('ab', nada), isNotNull);
    expect(maxLength(3)('abcd', nada), isNotNull);
    expect(lengthBetween(1, 2)('abc', nada), isNotNull);
    expect(isEmail()('x', nada), isNotNull);
    expect(isPassword()('123', nada), isNotNull);
    expect(matches(RegExp(r'^\d+$'))('a', nada), isNotNull);
    expect(sameAs('a')('x', nada), isNotNull);
  });

  test('barrel exporta os widgets da Fase 5', () {
    expect(Avatar.initialsOf('Maria Silva'), 'MS');
    expect(AvatarSize.md.diameter, 40);
    expect(const Badge(text: 'x').color, BadgeColor.neutral);
    expect(const Card(child: SizedBox()).elevation, isNull);
    expect(const Divider().thickness, 1);
    expect(const Icon(Icons.star).size, isNull);
    expect(const Toggle(value: true, onChanged: null).type, ToggleType.checkbox);
    expect(
      Select<String>.single(options: const [], onChanged: (_) {}).options,
      isEmpty,
    );
    expect(const Grid(minCell: 2, maxCell: 4, children: []).cellRatio, 1);
    expect(
      const DataList<int>(source: _semDados, itemBuilder: _semItem).limit,
      50,
    );
  });
}

Future<List<int>> _semDados(int page, int limit) async => const [];
Widget _semItem(BuildContext context, int item) => const SizedBox();
