import 'package:easy_ui/src/theme_layer/style_pack/specs/specs.dart';
import 'package:easy_ui/src/theme_layer/style_pack/style_pack.dart';
import 'package:easy_ui/src/theme_layer/tokens/theme_tokens.dart';
import 'package:flutter/widgets.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(StylePack.clearRegistry);

  test('define cria o pack com o que foi declarado e o registra', () {
    final pack = StylePack.define(
      name: 'cliente_convidativo',
      inputText: const InputStyleSpec.rounded(
        radius: 16,
        elevation: ElevationLevel.subtle,
      ),
      button: const ButtonStyleSpec.pill(),
      spacingScale: 1.2,
    );

    expect(pack.name, 'cliente_convidativo');
    expect(pack.inputText.radius, 16);
    expect(pack.button, const ButtonStyleSpec.pill());
    expect(pack.spacingScale, 1.2);
    expect(StylePack.byName('cliente_convidativo'), same(pack));
  });

  test('campos não declarados usam os padrões', () {
    final pack = StylePack.define(name: 'minimo');
    expect(pack.inputText, const InputStyleSpec.outline());
    expect(pack.button, const ButtonStyleSpec());
    expect(pack.card, const CardStyleSpec());
    expect(pack.label, const LabelStyleSpec());
    expect(pack.spacingScale, 1);
  });

  test('definir o mesmo nome substitui o pack anterior', () {
    StylePack.define(name: 'x', spacingScale: 1);
    final novo = StylePack.define(name: 'x', spacingScale: 2);
    expect(StylePack.byName('x'), same(novo));
    expect(StylePack.byName('x').spacingScale, 2);
  });

  test('byName de nome desconhecido lança ArgumentError listando os packs', () {
    StylePack.define(name: 'conhecido');
    expect(
      () => StylePack.byName('nao_existe'),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.toString(),
          'mensagem',
          contains('conhecido'),
        ),
      ),
    );
  });

  test('o nome standard é reservado, mas byName o resolve', () {
    expect(() => StylePack.define(name: 'standard'), throwsAssertionError);
    expect(StylePack.byName('standard'), same(StylePack.standard));
    expect(StylePack.definedNames, contains('standard'));
  });

  test('spacingScale deve ser positivo', () {
    expect(
      () => StylePack.define(name: 'ruim', spacingScale: 0),
      throwsAssertionError,
    );
  });

  test('space multiplica baseSpacing, passos e spacingScale', () {
    const tokens = ThemeTokens(
      primaryColor: Color(0xFF000001),
      secondaryColor: Color(0xFF000002),
      backgroundColor: Color(0xFF000003),
      textColor: Color(0xFF000004),
    );
    final arejado = StylePack.define(name: 'arejado', spacingScale: 1.5);
    final denso = StylePack.define(name: 'denso', spacingScale: 0.5);

    expect(arejado.space(tokens), 12); // 8 * 1 * 1.5
    expect(arejado.space(tokens, 2), 24); // 8 * 2 * 1.5
    expect(denso.space(tokens, 2), 8); // 8 * 2 * 0.5
  });

  test('igualdade por valor', () {
    expect(const StylePack(name: 'a'), const StylePack(name: 'a'));
    expect(
      const StylePack(name: 'a'),
      isNot(const StylePack(name: 'a', spacingScale: 2)),
    );
  });
}
