import 'package:easy_ui/src/kernel/unit_system/unit_system.dart';
import 'package:easy_ui/src/widget_catalog/data/kanban.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:easy_ui/src/widget_catalog/navigation/page_dots.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

const _cardHeight = 60.0;

List<KanbanColumnData<String>> _colunas() => const [
  KanbanColumnData(id: 'A', title: 'A fazer', items: ['a1', 'a2', 'a3']),
  KanbanColumnData(id: 'B', title: 'Em andamento', items: ['b1']),
];

Widget _board({
  List<KanbanColumnData<String>>? columns,
  ValueChanged<KanbanMove<String>>? onMove,
  ValueChanged<String>? onItemTap,
  ValueChanged<KanbanColumnMove>? onColumnMove,
}) {
  return Tela(
    padding: 0.px,
    child: KanbanBoard<String>(
      columns: columns ?? _colunas(),
      itemId: (item) => item,
      itemBuilder: (_, item) => Text(item),
      onMove: onMove ?? (_) {},
      onItemTap: onItemTap,
      onColumnMove: onColumnMove,
      cardHeight: _cardHeight,
    ),
  );
}

Future<TestGesture> _segurar(WidgetTester tester, String item) async {
  final gesture = await tester.startGesture(tester.getCenter(find.text(item)));
  await tester.pump(const Duration(milliseconds: 300));
  return gesture;
}

Future<void> _soltar(WidgetTester tester, TestGesture gesture) async {
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  group('exibição', () {
    testWidgets('mostra títulos, contagem e cards de cada coluna',
        (tester) async {
      await pumpEasy(tester, _board());

      expect(find.text('A fazer'), findsOneWidget);
      expect(find.text('Em andamento'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      for (final item in ['a1', 'a2', 'a3', 'b1']) {
        expect(find.text(item), findsOneWidget);
      }
    });

    testWidgets('coluna sem itens mostra o texto de vazio', (tester) async {
      await pumpEasy(
        tester,
        _board(
          columns: const [
            KanbanColumnData(id: 'A', title: 'A fazer', items: ['a1']),
            KanbanColumnData(id: 'B', title: 'Feito', items: <String>[]),
          ],
        ),
      );

      expect(find.text('Nenhum item aqui'), findsOneWidget);
    });

    testWidgets('toque em um card chama onItemTap', (tester) async {
      String? tocado;
      await pumpEasy(tester, _board(onItemTap: (item) => tocado = item));

      await tester.tap(find.text('a2'));
      await tester.pump();

      expect(tocado, 'a2');
    });

    testWidgets('em tela estreita usa páginas com indicador', (tester) async {
      await pumpEasy(tester, _board(), size: const Size(400, 800));

      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(PageDots), findsOneWidget);
      expect(find.text('A fazer'), findsOneWidget);
    });

    testWidgets('em tela larga não usa páginas', (tester) async {
      await pumpEasy(tester, _board());

      expect(find.byType(PageView), findsNothing);
      expect(find.byType(PageDots), findsNothing);
    });
  });

  group('mover cards', () {
    testWidgets('arrastar para o topo de outra coluna informa o destino',
        (tester) async {
      KanbanMove<String>? movimento;
      await pumpEasy(tester, _board(onMove: (move) => movimento = move));

      final destino = tester.getCenter(find.text('b1'));
      final gesture = await _segurar(tester, 'a1');
      await gesture.moveTo(destino);
      await tester.pump(const Duration(milliseconds: 50));
      await _soltar(tester, gesture);

      expect(movimento, isNotNull);
      expect(movimento!.itemId, 'a1');
      expect(movimento!.item, 'a1');
      expect(movimento!.fromColumnId, 'A');
      expect(movimento!.toColumnId, 'B');
      expect(movimento!.toIndex, 0);
    });

    testWidgets('soltar abaixo do último card da outra coluna vai para o fim',
        (tester) async {
      KanbanMove<String>? movimento;
      await pumpEasy(tester, _board(onMove: (move) => movimento = move));

      final base = tester.getCenter(find.text('b1'));
      final gesture = await _segurar(tester, 'a1');
      await gesture.moveTo(base + const Offset(0, 300));
      await tester.pump(const Duration(milliseconds: 50));
      await _soltar(tester, gesture);

      expect(movimento!.toColumnId, 'B');
      expect(movimento!.toIndex, 1);
    });

    testWidgets('reordenar na mesma coluna ignora o card arrastado no índice',
        (tester) async {
      KanbanMove<String>? movimento;
      await pumpEasy(
        tester,
        _board(
          columns: const [
            KanbanColumnData(id: 'A', title: 'A fazer', items: ['a1', 'a2', 'a3']),
          ],
          onMove: (move) => movimento = move,
        ),
      );

      final base = tester.getCenter(find.text('a2'));
      final gesture = await _segurar(tester, 'a1');
      await gesture.moveTo(Offset(base.dx, 500));
      await tester.pump(const Duration(milliseconds: 50));
      await _soltar(tester, gesture);

      expect(movimento!.fromColumnId, 'A');
      expect(movimento!.toColumnId, 'A');
      expect(movimento!.toIndex, 2);
    });

    testWidgets('soltar no mesmo lugar não dispara onMove', (tester) async {
      var chamadas = 0;
      await pumpEasy(tester, _board(onMove: (_) => chamadas++));

      final gesture = await _segurar(tester, 'a1');
      await _soltar(tester, gesture);

      expect(chamadas, 0);
    });
  });

  group('mover colunas', () {
    testWidgets('arrastar pelo ícone informa a nova posição', (tester) async {
      KanbanColumnMove? movimento;
      await pumpEasy(
        tester,
        _board(onColumnMove: (move) => movimento = move),
      );

      final inicio = tester.getCenter(find.byIcon(Icons.drag_indicator).first);
      final gesture = await tester.startGesture(inicio);
      await gesture.moveBy(const Offset(24, 0));
      await tester.pump();
      await gesture.moveTo(inicio + const Offset(340, 0));
      await tester.pump();
      await _soltar(tester, gesture);

      expect(movimento, isNotNull);
      expect(movimento!.columnId, 'A');
      expect(movimento!.fromIndex, 0);
      expect(movimento!.toIndex, 1);
    });

    testWidgets('sem onColumnMove não mostra o ícone de arrastar',
        (tester) async {
      await pumpEasy(tester, _board());

      expect(find.byIcon(Icons.drag_indicator), findsNothing);
    });
  });
}
