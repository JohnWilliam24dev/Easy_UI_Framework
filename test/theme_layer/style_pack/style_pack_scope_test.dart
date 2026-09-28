import 'package:easy_ui/src/kernel/kernel.dart';
import 'package:easy_ui/src/theme_layer/theme_layer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget que registra o pack visto neste ponto da árvore.
Widget _probe(ValueChanged<StylePack> onPack) {
  return Builder(
    builder: (context) {
      onPack(StylePackScope.of(context));
      return const SizedBox();
    },
  );
}

void main() {
  late StylePack cliente;
  late StylePack erp;

  setUp(() {
    StylePack.clearRegistry();
    cliente = StylePack.define(
      name: 'cliente_convidativo',
      inputText: const InputStyleSpec.rounded(),
      button: const ButtonStyleSpec.pill(),
      spacingScale: 1.2,
    );
    erp = StylePack.define(
      name: 'erp_operacional',
      inputText: const InputStyleSpec.underline(),
      button: const ButtonStyleSpec.compact(),
      spacingScale: 0.8,
    );
  });

  testWidgets('dois StylePacks coexistem em subárvores diferentes',
      (tester) async {
    StylePack? daArea1;
    StylePack? daArea2;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            StylePackScope(pack: cliente, child: _probe((p) => daArea1 = p)),
            StylePackScope(pack: erp, child: _probe((p) => daArea2 = p)),
          ],
        ),
      ),
    );

    expect(daArea1, cliente);
    expect(daArea2, erp);
    expect(daArea1!.button, isNot(daArea2!.button));
    expect(daArea1!.inputText, isNot(daArea2!.inputText));
  });

  testWidgets('sem escopo, usa o pack standard', (tester) async {
    StylePack? visto;
    await tester.pumpWidget(_probe((p) => visto = p));
    expect(visto, same(StylePack.standard));
    expect(StylePackScope.maybeOf(tester.element(find.byType(SizedBox))), isNull);
  });

  testWidgets('escopo mais próximo vence', (tester) async {
    StylePack? interno;
    StylePack? externo;

    await tester.pumpWidget(
      StylePackScope(
        pack: erp,
        child: Column(
          textDirection: TextDirection.ltr,
          children: [
            _probe((p) => externo = p),
            StylePackScope(pack: cliente, child: _probe((p) => interno = p)),
          ],
        ),
      ),
    );

    expect(externo, erp);
    expect(interno, cliente);
  });

  testWidgets('named usa um pack registrado', (tester) async {
    StylePack? visto;
    await tester.pumpWidget(
      StylePackScope.named('erp_operacional', child: _probe((p) => visto = p)),
    );
    expect(visto, same(erp));
  });

  testWidgets('named com nome desconhecido lança ArgumentError', (tester) async {
    expect(
      () => StylePackScope.named('nao_existe', child: const SizedBox()),
      throwsArgumentError,
    );
  });

  testWidgets('trocar o pack do escopo atualiza os filhos', (tester) async {
    StylePack? visto;
    Widget build(StylePack pack) =>
        StylePackScope(pack: pack, child: _probe((p) => visto = p));

    await tester.pumpWidget(build(cliente));
    expect(visto, cliente);

    await tester.pumpWidget(build(erp));
    expect(visto, erp);
  });

  group('resolvers da Theme Layer implementam o contrato do Kernel', () {
    test('são StyleResolver', () {
      expect(const ThemeTokensResolver(), isA<StyleResolver<ThemeTokens>>());
      expect(const ActiveStylePackResolver(), isA<StyleResolver<StylePack>>());
    });

    testWidgets('ActiveStylePackResolver resolve o pack do escopo',
        (tester) async {
      StylePack? visto;
      await tester.pumpWidget(
        StylePackScope(
          pack: cliente,
          child: Builder(
            builder: (context) {
              visto = const ActiveStylePackResolver().resolve(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(visto, cliente);
    });

    testWidgets('ThemeTokensResolver resolve os tokens do AppThemeScope',
        (tester) async {
      const tokens = ThemeTokens(
        primaryColor: Color(0xFF000001),
        secondaryColor: Color(0xFF000002),
        backgroundColor: Color(0xFF000003),
        textColor: Color(0xFF000004),
      );
      ThemeTokens? visto;

      await tester.pumpWidget(
        AppThemeScope(
          theme: const AppTheme(
            light: tokens,
            dark: tokens,
            mode: AppThemeMode.light,
          ),
          child: Builder(
            builder: (context) {
              visto = const ThemeTokensResolver().resolve(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(visto, tokens);
    });
  });
}
