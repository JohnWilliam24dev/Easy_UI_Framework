import 'package:easy_ui/src/kernel/layout_engine/layout.dart';
import 'package:easy_ui/src/kernel/unit_system/unit_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta [child] dentro de uma área de 500x400 com restrições soltas e uma
/// viewport simulada de 400x800 (usada por vw/vh).
Widget harness(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(400, 800)),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 500,
          height: 400,
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('width em vw e height em px usam a viewport', (tester) async {
    await tester.pumpWidget(
      harness(LayoutEngine(width: 50.vw, height: 100.px, children: const [])),
    );
    expect(tester.getSize(find.byType(LayoutEngine)), const Size(200, 100));
  });

  testWidgets('width e height em pct usam o espaço do pai', (tester) async {
    await tester.pumpWidget(
      harness(LayoutEngine(width: 50.pct, height: 50.pct, children: const [])),
    );
    expect(tester.getSize(find.byType(LayoutEngine)), const Size(250, 200));
  });

  testWidgets('fr divide o espaço restante do eixo principal', (tester) async {
    const a = Key('a');
    const b = Key('b');
    const c = Key('c');

    await tester.pumpWidget(
      harness(
        LayoutEngine(
          width: 100.px,
          height: 300.px,
          children: [
            LayoutItem(size: 100.px, child: const SizedBox(key: a, width: 10)),
            LayoutItem(size: 1.fr, child: const SizedBox(key: b, width: 10)),
            LayoutItem(size: 2.fr, child: const SizedBox(key: c, width: 10)),
          ],
        ),
      ),
    );

    // Sobram 200px (300 - 100) divididos em 1fr e 2fr.
    expect(tester.getSize(find.byKey(a)).height, closeTo(100, 0.01));
    expect(tester.getSize(find.byKey(b)).height, closeTo(200 / 3, 0.01));
    expect(tester.getSize(find.byKey(c)).height, closeTo(400 / 3, 0.01));
  });

  testWidgets('gap separa os filhos no eixo principal', (tester) async {
    const a = Key('a');
    const b = Key('b');

    await tester.pumpWidget(
      harness(
        LayoutEngine(
          gap: 20.px,
          children: const [
            SizedBox(key: a, width: 10, height: 10),
            SizedBox(key: b, width: 10, height: 10),
          ],
        ),
      ),
    );

    final distance = tester.getTopLeft(find.byKey(b)).dy -
        tester.getTopLeft(find.byKey(a)).dy;
    expect(distance, closeTo(30, 0.01)); // 10 (altura de A) + 20 (gap)
  });

  testWidgets('direction horizontal posiciona lado a lado', (tester) async {
    const a = Key('a');
    const b = Key('b');

    await tester.pumpWidget(
      harness(
        LayoutEngine(
          direction: LayoutDirection.horizontal,
          gap: 5.px,
          children: const [
            SizedBox(key: a, width: 30, height: 10),
            SizedBox(key: b, width: 30, height: 10),
          ],
        ),
      ),
    );

    final distance = tester.getTopLeft(find.byKey(b)).dx -
        tester.getTopLeft(find.byKey(a)).dx;
    expect(distance, closeTo(35, 0.01)); // 30 (largura de A) + 5 (gap)
  });

  testWidgets('align center centra o conteúdo nos dois eixos', (tester) async {
    const a = Key('a');

    await tester.pumpWidget(
      harness(
        LayoutEngine(
          width: 200.px,
          height: 100.px,
          align: Alignment.center,
          children: const [SizedBox(key: a, width: 40, height: 20)],
        ),
      ),
    );

    final topLeft = tester.getTopLeft(find.byKey(a));
    expect(topLeft.dx, closeTo((200 - 40) / 2, 0.01));
    expect(topLeft.dy, closeTo((100 - 20) / 2, 0.01));
  });

  testWidgets('layered sobrepõe os filhos', (tester) async {
    const a = Key('a');
    const b = Key('b');

    await tester.pumpWidget(
      harness(
        LayoutEngine(
          direction: LayoutDirection.layered,
          width: 100.px,
          height: 100.px,
          children: const [
            SizedBox(key: a, width: 50, height: 50),
            SizedBox(key: b, width: 20, height: 20),
          ],
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(a)),
      tester.getTopLeft(find.byKey(b)),
    );
  });

  testWidgets('pct em eixo ilimitado lança erro claro', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: SingleChildScrollView(
            child: LayoutEngine(height: 50.pct, children: const []),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isA<StateError>());
  });
}
