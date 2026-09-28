import 'package:easy_ui/src/kernel/layout_engine/layout.dart';
import 'package:easy_ui/src/kernel/unit_system/unit_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Área de 500x400 com restrições soltas para o filho.
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
  const a = Key('a');

  // Filho de 100x50 numa área de 500x400.
  const esperado = <LayoutPosition, Offset>{
    LayoutPosition.center: Offset(200, 175),
    LayoutPosition.top: Offset(200, 0),
    LayoutPosition.bottom: Offset(200, 350),
    LayoutPosition.left: Offset(0, 175),
    LayoutPosition.right: Offset(400, 175),
    LayoutPosition.topLeft: Offset(0, 0),
    LayoutPosition.topRight: Offset(400, 0),
    LayoutPosition.bottomLeft: Offset(0, 350),
    LayoutPosition.bottomRight: Offset(400, 350),
  };

  for (final entry in esperado.entries) {
    testWidgets('position ${entry.key.name} posiciona o motor no pai',
        (tester) async {
      await tester.pumpWidget(
        harness(
          LayoutEngine(
            position: entry.key,
            children: const [SizedBox(key: a, width: 100, height: 50)],
          ),
        ),
      );
      expect(tester.getTopLeft(find.byKey(a)), entry.value);
    });
  }

  testWidgets('position funciona junto de width e height declarados',
      (tester) async {
    await tester.pumpWidget(
      harness(
        LayoutEngine(
          position: LayoutPosition.bottomRight,
          width: 100.px,
          height: 50.px,
          children: const [SizedBox(key: a, width: 40, height: 20)],
        ),
      ),
    );
    // O motor (100x50) vai para o canto; o filho fica no topo-esquerda dele.
    expect(tester.getTopLeft(find.byKey(a)), const Offset(400, 350));
  });

  testWidgets('position em horizontal também ajusta ao conteúdo',
      (tester) async {
    await tester.pumpWidget(
      harness(
        LayoutEngine(
          direction: LayoutDirection.horizontal,
          position: LayoutPosition.right,
          children: const [SizedBox(key: a, width: 100, height: 50)],
        ),
      ),
    );
    expect(tester.getTopLeft(find.byKey(a)), const Offset(400, 175));
  });

  test('cada LayoutPosition tem um Alignment correspondente', () {
    expect(LayoutPosition.center.alignment, Alignment.center);
    expect(LayoutPosition.right.alignment, Alignment.centerRight);
    expect(LayoutPosition.bottomLeft.alignment, Alignment.bottomLeft);
  });
}
