import 'package:easy_ui/src/theme_layer/theme_layer.dart';
import 'package:easy_ui/src/widget_catalog/display/card.dart' as easy;
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

BoxDecoration _decorationOf(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: find.byType(easy.Card), matching: find.byType(DecoratedBox)).first,
  );
  return box.decoration as BoxDecoration;
}

void main() {
  testWidgets('usa a cor de superfície e o raio do pack', (tester) async {
    await pumpEasy(
      tester,
      const Tela(child: easy.Card(child: SizedBox())),
    );
    final decoration = _decorationOf(tester);
    expect(decoration.color, testTokens.surfaceColor);
    expect(decoration.borderRadius, BorderRadius.circular(12));
    expect(decoration.boxShadow, isNotNull); // elevation padrão: subtle
  });

  testWidgets('elevation none não desenha sombra', (tester) async {
    await pumpEasy(
      tester,
      const Tela(
        child: easy.Card(elevation: ElevationLevel.none, child: SizedBox()),
      ),
    );
    expect(_decorationOf(tester).boxShadow, isNull);
  });

  testWidgets('padding interno vem de paddingSteps x baseSpacing x scale',
      (tester) async {
    await pumpEasy(
      tester,
      const Tela(
        padding: null,
        child: easy.Card(
          child: SizedBox(key: Key('conteudo'), width: 10, height: 10),
        ),
      ),
    );
    final padding = tester.widget<Padding>(
      find.descendant(of: find.byType(easy.Card), matching: find.byType(Padding)),
    );
    expect((padding.padding as EdgeInsets).left, closeTo(8 * 2, 1e-9));
  });

  testWidgets('onTap torna o card tocável', (tester) async {
    var toques = 0;
    await pumpEasy(
      tester,
      Tela(child: easy.Card(onTap: () => toques++, child: const SizedBox())),
    );
    await tester.tap(find.byType(easy.Card));
    expect(toques, 1);
  });

  testWidgets('sem onTap não reage a GestureDetector', (tester) async {
    await pumpEasy(tester, const Tela(child: easy.Card(child: SizedBox())));
    expect(find.byType(GestureDetector), findsNothing);
  });
}
