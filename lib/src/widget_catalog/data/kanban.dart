import 'package:flutter/material.dart' hide Card;

import '../display/card.dart';
import '../display/label.dart';

class KanbanColumnData<T> {
  const KanbanColumnData({
    required this.id,
    required this.title,
    required this.items,
  });
  final String id, title;
  final List<T> items;
}

class KanbanMove<T> {
  const KanbanMove({
    required this.item,
    required this.fromColumnId,
    required this.toColumnId,
  });
  final T item;
  final String fromColumnId, toColumnId;
}

/// Quadro de arrastar e soltar controlado: o app atualiza [columns] após
/// receber [onMove], o que facilita persistência e atualizações otimistas.
class KanbanBoard<T> extends StatelessWidget {
  const KanbanBoard({
    super.key,
    required this.columns,
    required this.itemBuilder,
    required this.onMove,
    this.onItemTap,
  });
  final List<KanbanColumnData<T>> columns;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final ValueChanged<KanbanMove<T>> onMove;
  final ValueChanged<T>? onItemTap;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final column in columns)
            SizedBox(
              width: 300,
              child: _Column<T>(
                column: column,
                itemBuilder: itemBuilder,
                onMove: onMove,
                onItemTap: onItemTap,
              ),
            ),
        ],
      ),
    ),
  );
}

class _Column<T> extends StatelessWidget {
  const _Column({
    required this.column,
    required this.itemBuilder,
    required this.onMove,
    this.onItemTap,
  });
  final KanbanColumnData<T> column;
  final Widget Function(BuildContext, T) itemBuilder;
  final ValueChanged<KanbanMove<T>> onMove;
  final ValueChanged<T>? onItemTap;
  @override
  Widget build(BuildContext context) => DragTarget<_Drag<T>>(
    onWillAcceptWithDetails: (_) => true,
    onAcceptWithDetails: (details) => onMove(
      KanbanMove(
        item: details.data.item,
        fromColumnId: details.data.columnId,
        toColumnId: column.id,
      ),
    ),
    builder: (context, _, _) => Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Label(type: LabelType.heading, text: column.title),
          const SizedBox(height: 12),
          for (final item in column.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LongPressDraggable<_Drag<T>>(
                data: _Drag(item, column.id),
                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: 280,
                    child: itemBuilder(context, item),
                  ),
                ),
                child: GestureDetector(
                  onTap: onItemTap == null ? null : () => onItemTap!(item),
                  child: itemBuilder(context, item),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _Drag<T> {
  const _Drag(this.item, this.columnId);
  final T item;
  final String columnId;
}
