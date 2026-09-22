import 'package:easy_ui/src/widget_catalog/display/badge.dart' as easy;
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

DecoratedBox _decoratedBadge(WidgetTester tester) {
  return tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(easy.Badge),
      matching: find.byType(DecoratedBox),
    ),
  );
}

void main() {
  test('estimateContrastBrightness escolhe o contraste certo', () {
    expect(easy.estimateContrastBrightness(const Color(0xFFFFFFFF)), Brightness.light);
    expect(easy.estimateContrastBrightness(const Color(0xFF000000)), Brightness.dark);
  });

  testWidgets('cores de status vêm dos tokens', (tester) async {
    await pumpEasy(
      tester,
      const Tela(
        child: easy.Badge(text: 'Pago', color: easy.BadgeColor.success),
      ),
    );
    final box = _decoratedBadge(tester);
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, testTokens.successColor);
    expect(find.text('Pago'), findsOneWidget);
  });

  testWidgets('formato de pílula', (tester) async {
    await pumpEasy(tester, const Tela(child: easy.Badge(text: 'x')));
    final decoration = _decoratedBadge(tester).decoration as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(999));
  });

  testWidgets('padrão é neutro', (tester) async {
    await pumpEasy(tester, const Tela(child: easy.Badge(text: 'x')));
    final decoration = _decoratedBadge(tester).decoration as BoxDecoration;
    expect(decoration.color, testTokens.borderColor);
  });
}
