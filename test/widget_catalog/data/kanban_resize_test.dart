import 'package:easy_ui/src/kernel/unit_system/unit_system.dart';
import 'package:easy_ui/src/widget_catalog/data/kanban.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

Widget _board() {
  return Tela(
    padding: 0.px,
    child: KanbanBoard<String>(
      columns: const [
        KanbanColumnData(id: 'A', title: 'A fazer', items: ['a1', 'a2']),
        KanbanColumnData(id: 'B', title: 'Feito', items: ['b1']),
        KanbanColumnData(id: 'C', title: 'Pronto', items: <String>[]),
      ],
      itemId: (item) => item,
      itemBuilder: (_, item) => Text(item),
      onMove: (_) {},
      onColumnMove: (_) {},
      cardHeight: 60,
    ),
  );
}

void main() {
  testWidgets('alternar entre largura de desktop e de celular não dá erro', (
    tester,
  ) async {
    await pumpEasy(tester, _board(), size: const Size(900, 700));
    expect(find.text('b1'), findsOneWidget);

    // Atravessa o breakpoint várias vezes: o quadro troca de layout dentro do
    // mesmo State, sem reaproveitar GlobalKey entre os dois.
    for (final largura in [400.0, 900.0, 500.0, 1000.0, 450.0, 900.0]) {
      tester.view.physicalSize = Size(largura, 700);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'largura $largura');
      expect(find.text('a1'), findsOneWidget, reason: 'largura $largura');
    }
    expect(find.text('b1'), findsOneWidget);
  });

  testWidgets('arrastar o fundo com o mouse rola o quadro na horizontal', (
    tester,
  ) async {
    // 3 colunas de 320 + folgas passam dos 800 de largura da tela.
    await pumpEasy(tester, _board(), size: const Size(800, 700));
    final horizontal = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axis == Axis.horizontal,
    );
    double posicao() => tester.state<ScrollableState>(horizontal).position.pixels;
    expect(posicao(), 0);

    // Começa numa área vazia (abaixo dos cards da primeira coluna).
    final gesture = await tester.startGesture(
      const Offset(150, 550),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveBy(const Offset(-120, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-120, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(posicao(), greaterThan(0));
  });
}
