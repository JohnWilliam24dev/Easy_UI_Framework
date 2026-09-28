import 'package:easy_ui/src/kernel/kernel.dart';
import 'package:easy_ui/src/theme_layer/theme_layer.dart';
import 'package:easy_ui/src/widget_catalog/layout/div.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  const a = Key('a');
  const b = Key('b');

  double dy(WidgetTester tester) {
    return tester.getTopLeft(find.byKey(b)).dy -
        tester.getTopLeft(find.byKey(a)).dy;
  }

  group('Div', () {
    testWidgets('gap padrão vem do tema (2 x baseSpacing x spacingScale)',
        (tester) async {
      await pumpEasy(
        tester,
        Tela(
          padding: 0.px,
          child: Div(
            children: const [
              SizedBox(key: a, width: 10, height: 10),
              SizedBox(key: b, width: 10, height: 10),
            ],
          ),
        ),
      );
      expect(dy(tester), closeTo(26, 0.01)); // 10 + 2 * 8 * 1
    });

    testWidgets('spacingScale do pack ativo altera o gap padrão',
        (tester) async {
      await pumpEasy(
        tester,
        Tela(
          padding: 0.px,
          child: Div(
            children: const [
              SizedBox(key: a, width: 10, height: 10),
              SizedBox(key: b, width: 10, height: 10),
            ],
          ),
        ),
        pack: const StylePack(name: 'denso', spacingScale: 0.5),
      );
      expect(dy(tester), closeTo(18, 0.01)); // 10 + 2 * 8 * 0.5
    });

    testWidgets('gap explícito vence o do tema', (tester) async {
      await pumpEasy(
        tester,
        Tela(
          padding: 0.px,
          child: Div(
            gap: 0.px,
            children: const [
              SizedBox(key: a, width: 10, height: 10),
              SizedBox(key: b, width: 10, height: 10),
            ],
          ),
        ),
      );
      expect(dy(tester), closeTo(10, 0.01));
    });

    testWidgets('position center + width posiciona o Div no meio do pai',
        (tester) async {
      await pumpEasy(
        tester,
        Tela(
          padding: 0.px,
          child: Div(
            position: LayoutPosition.center,
            width: 100.px,
            children: const [SizedBox(key: a, width: 100, height: 10)],
          ),
        ),
      );
      final topLeft = tester.getTopLeft(find.byKey(a));
      expect(topLeft.dx, closeTo((800 - 100) / 2, 0.01));
      expect(topLeft.dy, closeTo((600 - 10) / 2, 0.01));
    });

    testWidgets('width em vw usa a viewport', (tester) async {
      await pumpEasy(
        tester,
        Tela(
          padding: 0.px,
          child: Div(
            width: 50.vw,
            children: const [SizedBox(key: a, height: 10)],
          ),
        ),
      );
      // 50vw de 800 = 400: o filho sem largura própria ocupa no máximo isso.
      expect(tester.getSize(find.byKey(a)).width, lessThanOrEqualTo(400));
    });

    testWidgets('direction horizontal coloca lado a lado', (tester) async {
      await pumpEasy(
        tester,
        Tela(
          padding: 0.px,
          child: Div(
            direction: LayoutDirection.horizontal,
            gap: 4.px,
            children: const [
              SizedBox(key: a, width: 20, height: 10),
              SizedBox(key: b, width: 20, height: 10),
            ],
          ),
        ),
      );
      final dx =
          tester.getTopLeft(find.byKey(b)).dx - tester.getTopLeft(find.byKey(a)).dx;
      expect(dx, closeTo(24, 0.01));
    });
  });

  group('Tela', () {
    testWidgets('usa o fundo do tema', (tester) async {
      await pumpEasy(tester, const Tela(child: SizedBox()));
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, testTokens.backgroundColor);
    });

    testWidgets('padding padrão vem do tema', (tester) async {
      await pumpEasy(
        tester,
        const Tela(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(key: a, width: 10, height: 10),
          ),
        ),
      );
      expect(tester.getTopLeft(find.byKey(a)), const Offset(16, 16));
    });

    testWidgets('padding explícito vence o do tema', (tester) async {
      await pumpEasy(
        tester,
        Tela(
          padding: 24.px,
          child: const Align(
            alignment: Alignment.topLeft,
            child: SizedBox(key: a, width: 10, height: 10),
          ),
        ),
      );
      expect(tester.getTopLeft(find.byKey(a)), const Offset(24, 24));
    });

    testWidgets('scrollable envolve o conteúdo em rolagem', (tester) async {
      await pumpEasy(tester, const Tela(child: SizedBox()));
      expect(find.byType(SingleChildScrollView), findsNothing);

      await pumpEasy(tester, const Tela(scrollable: true, child: SizedBox()));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
