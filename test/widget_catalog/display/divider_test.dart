import 'package:easy_ui/src/kernel/kernel.dart';
import 'package:easy_ui/src/widget_catalog/display/divider.dart' as easy;
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  testWidgets('horizontal fica fino e largo, na cor de borda', (tester) async {
    await pumpEasy(tester, const Tela(child: easy.Divider()));
    final size = tester.getSize(find.byType(easy.Divider));
    expect(size.height, 1);
    expect(size.width, greaterThan(100));

    final box = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(easy.Divider),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(box.color, testTokens.borderColor);
  });

  testWidgets('vertical fica fino e alto', (tester) async {
    await pumpEasy(
      tester,
      const Tela(
        child: SizedBox(
          height: 100,
          child: easy.Divider(direction: LayoutDirection.vertical),
        ),
      ),
    );
    final size = tester.getSize(find.byType(easy.Divider));
    expect(size.width, 1);
  });

  testWidgets('thickness e inset são respeitados', (tester) async {
    await pumpEasy(
      tester,
      const Tela(child: easy.Divider(thickness: 4, inset: 20)),
    );
    expect(tester.getSize(find.byType(easy.Divider)).height, 4);
    final padding = tester.widget<Padding>(
      find.descendant(
        of: find.byType(easy.Divider),
        matching: find.byType(Padding),
      ),
    );
    expect(padding.padding, const EdgeInsets.symmetric(horizontal: 20));
  });
}
