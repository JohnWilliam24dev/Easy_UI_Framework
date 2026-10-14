import 'package:easy_ui/src/kernel/unit_system/unit_system.dart';
import 'package:easy_ui/src/theme_layer/theme_layer.dart';
import 'package:easy_ui/src/widget_catalog/data/kanban.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

const _colunas = [
  KanbanColumnData<String>(id: 'A', title: 'A fazer', items: ['a1', 'a2']),
  KanbanColumnData<String>(id: 'B', title: 'Feito', items: <String>[]),
];

Widget _board({
  Widget Function(BuildContext, KanbanColumnData<String>, int, Widget?)?
  header,
  ValueChanged<KanbanColumnMove>? onColumnMove,
}) {
  return Tela(
    padding: 0.px,
    child: KanbanBoard<String>(
      columns: _colunas,
      itemId: (item) => item,
      itemBuilder: (_, item) => Text(item),
      onMove: (_) {},
      onColumnMove: onColumnMove,
      columnHeaderBuilder: header,
      cardHeight: 60,
    ),
  );
}

/// Há algum Transform com rotação (seno do ângulo fora de zero) na árvore?
Finder _rotacionado() => find.byWidgetPredicate(
  (w) => w is Transform && w.transform.storage[1].abs() > 0.01,
);

Future<TestGesture> _arrastar(WidgetTester tester, String item) async {
  final gesture = await tester.startGesture(tester.getCenter(find.text(item)));
  await tester.pump(const Duration(milliseconds: 300));
  await gesture.moveBy(const Offset(0, 40));
  await tester.pump();
  return gesture;
}

void main() {
  testWidgets('por padrão o card arrastado não inclina', (tester) async {
    await pumpEasy(tester, _board());

    final gesture = await _arrastar(tester, 'a1');
    expect(_rotacionado(), findsNothing);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('dragTilt inclina o card enquanto ele é arrastado', (
    tester,
  ) async {
    await pumpEasy(
      tester,
      _board(),
      pack: StylePack.define(
        name: 'tilt',
        kanban: const KanbanStyleSpec(dragTilt: 0.035),
      ),
    );

    final gesture = await _arrastar(tester, 'a1');
    expect(_rotacionado(), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_rotacionado(), findsNothing);
  });

  testWidgets('columnHeaderBuilder substitui o cabeçalho e recebe a alça', (
    tester,
  ) async {
    Widget? alca;
    await pumpEasy(
      tester,
      _board(
        onColumnMove: (_) {},
        header: (context, column, index, handle) {
          alca ??= handle;
          return Text('H${column.title}#$index');
        },
      ),
    );

    expect(find.text('HA fazer#0'), findsOneWidget);
    expect(find.text('HFeito#1'), findsOneWidget);
    expect(find.text('A fazer'), findsNothing);
    expect(alca, isNotNull);
  });

  testWidgets('sem onColumnMove a alça chega nula ao cabeçalho', (
    tester,
  ) async {
    Widget? alca = const SizedBox();
    await pumpEasy(
      tester,
      _board(
        header: (context, column, index, handle) {
          alca = handle;
          return Text(column.title);
        },
      ),
    );

    expect(alca, isNull);
  });
}
