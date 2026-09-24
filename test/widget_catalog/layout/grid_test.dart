import 'package:easy_ui/src/kernel/kernel.dart';
import 'package:easy_ui/src/widget_catalog/layout/grid.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  testWidgets('colunas variam por interpolação, sem saltar de vez',
      (tester) async {
    Future<int> colunasEm(double largura) async {
      await pumpEasy(
        tester,
        Tela(
          padding: 0.px,
          child: Grid(
            minCell: 2,
            maxCell: 6,
            children: List.generate(12, (i) => Container(key: ValueKey(i))),
          ),
        ),
        size: Size(largura, 800),
      );
      final delegate = tester
          .widget<GridView>(find.byType(GridView))
          .gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      return delegate.crossAxisCount;
    }

    final estreita = await colunasEm(360);
    final media = await colunasEm(900);
    final larga = await colunasEm(1440);

    expect(estreita, 2);
    expect(larga, 6);
    expect(media, greaterThan(estreita));
    expect(media, lessThan(larga));
  });

  testWidgets('cellRatio vira o childAspectRatio', (tester) async {
    await pumpEasy(
      tester,
      Tela(
        child: Grid(
          minCell: 2,
          maxCell: 2,
          cellRatio: 1.5,
          children: List.generate(4, (i) => Container(key: ValueKey(i))),
        ),
      ),
    );
    final delegate = tester
        .widget<GridView>(find.byType(GridView))
        .gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.childAspectRatio, 1.5);
  });

  testWidgets('por padrão não rola sozinho (shrinkWrap)', (tester) async {
    await pumpEasy(
      tester,
      Tela(
        child: Grid(
          minCell: 2,
          maxCell: 2,
          children: List.generate(4, (i) => Container(key: ValueKey(i))),
        ),
      ),
    );
    final grid = tester.widget<GridView>(find.byType(GridView));
    expect(grid.shrinkWrap, isTrue);
    expect(grid.physics, isA<NeverScrollableScrollPhysics>());
  });

  testWidgets('scrollable: true rola por conta própria', (tester) async {
    await pumpEasy(
      tester,
      Tela(
        child: Grid(
          minCell: 2,
          maxCell: 2,
          scrollable: true,
          children: List.generate(4, (i) => Container(key: ValueKey(i))),
        ),
      ),
    );
    final grid = tester.widget<GridView>(find.byType(GridView));
    expect(grid.shrinkWrap, isFalse);
  });
}
