import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:easy_ui/src/widget_catalog/motion/reveal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

List<double> _opacities(WidgetTester tester) {
  return tester
      .widgetList<AnimatedOpacity>(
        find.descendant(
          of: find.byType(Reveal),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .map((widget) => widget.opacity)
      .toList();
}

void main() {
  testWidgets('começa transparente e aparece depois do delay', (tester) async {
    await pumpEasy(
      tester,
      const Tela(
        child: Reveal(delay: Duration(milliseconds: 100), child: Text('oi')),
      ),
    );
    expect(_opacities(tester), [0]);

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    expect(_opacities(tester), [1]);

    await tester.pumpAndSettle();
  });

  testWidgets('stagger escalona a entrada pelo intervalo do pack',
      (tester) async {
    await pumpEasy(
      tester,
      Tela(
        child: Reveal.stagger(
          children: const [Text('a'), Text('b'), Text('c')],
        ),
      ),
    );
    expect(_opacities(tester), [0, 0, 0]);

    await tester.pump(const Duration(milliseconds: 60));
    expect(_opacities(tester), [1, 1, 0]);

    await tester.pump(const Duration(milliseconds: 60));
    expect(_opacities(tester), [1, 1, 1]);

    await tester.pumpAndSettle();
  });

  testWidgets('step informado vence o intervalo do pack', (tester) async {
    await pumpEasy(
      tester,
      Tela(
        child: Reveal.stagger(
          step: const Duration(milliseconds: 500),
          children: const [Text('a'), Text('b')],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(_opacities(tester), [1, 0]);

    await tester.pump(const Duration(milliseconds: 500));
    expect(_opacities(tester), [1, 1]);

    await tester.pumpAndSettle();
  });
}
