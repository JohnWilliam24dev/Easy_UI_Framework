import 'dart:async';

import 'package:flutter/material.dart' hide Card;

import '../../kernel/kernel.dart';
import '../../theme_layer/theme_layer.dart';
import '../display/card.dart';
import '../display/label.dart';
import '../navigation/page_dots.dart';

class KanbanColumnData<T> {
  const KanbanColumnData({
    required this.id,
    required this.title,
    required this.items,
  });
  final String id;
  final String title;
  final List<T> items;
}

class KanbanMove<T> {
  const KanbanMove({
    required this.item,
    required this.itemId,
    required this.fromColumnId,
    required this.toColumnId,
    required this.toIndex,
  });
  final T item;
  final String itemId, fromColumnId, toColumnId;

  /// Índice na coluna destino sem considerar o item que está sendo movido.
  final int toIndex;
}

class KanbanColumnMove {
  const KanbanColumnMove({
    required this.columnId,
    required this.fromIndex,
    required this.toIndex,
  });
  final String columnId;
  final int fromIndex, toIndex;
}

/// Kanban controlado com reordenação de cards/colunas, posição de queda e
/// paginação no celular. O estado da lista pertence ao aplicativo.
class KanbanBoard<T> extends StatefulWidget {
  const KanbanBoard({
    super.key,
    required this.columns,
    required this.itemId,
    required this.itemBuilder,
    required this.onMove,
    this.onItemTap,
    this.onColumnMove,
    this.columnActionsBuilder,
    this.columnHeaderBuilder,
    this.cardHeight = 112,
    this.emptyLabel = 'Nenhum item aqui',
  });
  final List<KanbanColumnData<T>> columns;
  final String Function(T item) itemId;
  final Widget Function(BuildContext, T) itemBuilder;
  final ValueChanged<KanbanMove<T>> onMove;
  final ValueChanged<T>? onItemTap;
  final ValueChanged<KanbanColumnMove>? onColumnMove;
  final Widget Function(BuildContext, KanbanColumnData<T>, int)?
  columnActionsBuilder;

  /// Substitui o cabeçalho padrão da coluna (título, contagem, ações e alça).
  /// Recebe a alça de arrastar colunas (`null` no celular ou sem
  /// [onColumnMove]); quem monta o cabeçalho decide onde ela aparece.
  final Widget Function(BuildContext, KanbanColumnData<T>, int, Widget?)?
  columnHeaderBuilder;
  final double cardHeight;
  final String emptyLabel;
  @override
  State<KanbanBoard<T>> createState() => _KanbanBoardState<T>();
}

class _KanbanBoardState<T> extends State<KanbanBoard<T>> {
  final _edge = const EdgeAutoScroller(activationDistance: 64, maxStep: 16);
  final _horizontal = ScrollController();
  final _pages = PageController(viewportFraction: .9);
  final _boardKey = GlobalKey();
  final _columns = <String, GlobalKey>{};
  final _lists = <String, GlobalKey>{};
  final _listScrollers = <String, ScrollController>{};
  Timer? _ticker;
  String? _dragId, _fromColumn, _hoverColumn, _dragColumn;
  int _fromIndex = 0, _hoverIndex = 0, _columnFrom = 0, _columnHover = 0;
  Offset? _pointer;
  bool _mobile = false;

  @override
  void dispose() {
    _ticker?.cancel();
    _horizontal.dispose();
    _pages.dispose();
    for (final controller in _listScrollers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  GlobalKey _key(Map<String, GlobalKey> map, String id) =>
      map.putIfAbsent(id, GlobalKey.new);
  ScrollController _scroller(String id) =>
      _listScrollers.putIfAbsent(id, ScrollController.new);
  Rect? _rect(GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    return box is RenderBox && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
  }

  void _start(T item, String columnId) {
    setState(() {
      _dragId = widget.itemId(item);
      _fromColumn = _hoverColumn = columnId;
      _fromIndex = _hoverIndex = widget.columns
          .firstWhere((column) => column.id == columnId)
          .items
          .indexWhere((value) => widget.itemId(value) == _dragId);
    });
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  void _update(Offset pointer) {
    _pointer = pointer;
    _updateHover();
  }

  void _end() {
    final id = _dragId;
    final from = _fromColumn;
    final target = _hoverColumn;
    final index = _hoverIndex;
    _ticker?.cancel();
    _ticker = null;
    _pointer = null;
    setState(() {
      _dragId = null;
      _fromColumn = null;
      _hoverColumn = null;
    });
    if (id == null ||
        from == null ||
        target == null ||
        (from == target && index == _fromIndex))
      return;
    final item = widget.columns
        .firstWhere((column) => column.id == from)
        .items
        .firstWhere((value) => widget.itemId(value) == id);
    widget.onMove(
      KanbanMove(
        item: item,
        itemId: id,
        fromColumnId: from,
        toColumnId: target,
        toIndex: index,
      ),
    );
  }

  void _updateHover() {
    final pointer = _pointer;
    if (pointer == null || _dragId == null) return;
    for (final column in widget.columns) {
      final rect = _rect(_key(_columns, column.id));
      if (rect == null || !rect.contains(pointer)) continue;
      final listRect = _rect(_key(_lists, column.id));
      final offset = _scroller(column.id).hasClients
          ? _scroller(column.id).offset
          : 0;
      final visible = column.items
          .where((item) => widget.itemId(item) != _dragId)
          .length;
      final cardGap = StylePackScope.of(context).kanban.cardGap;
      final raw = listRect == null
          ? visible
          : ((pointer.dy - listRect.top + offset) / (widget.cardHeight + cardGap))
                .floor();
      final index = raw.clamp(0, visible);
      if (_hoverColumn != column.id || _hoverIndex != index)
        setState(() {
          _hoverColumn = column.id;
          _hoverIndex = index;
        });
      return;
    }
  }

  void _tick() {
    final pointer = _pointer;
    if (pointer == null) return;
    if (_dragId != null) {
      final column = _hoverColumn;
      if (column != null) {
        final rect = _rect(_key(_lists, column));
        if (rect != null)
          _edge.scrollBy(_scroller(column), _edge.deltaFor(pointer, rect));
      }
      if (!_mobile) {
        final rect = _rect(_boardKey);
        if (rect != null && _horizontal.hasClients) {
          final left = pointer.dx - rect.left;
          final right = rect.right - pointer.dx;
          final delta = left < 72
              ? -16 * (1 - left / 72)
              : right < 72
              ? 16 * (1 - right / 72)
              : 0;
          if (delta != 0) {
            final position = _horizontal.position;
            _horizontal.jumpTo(
              (_horizontal.offset + delta).clamp(
                position.minScrollExtent,
                position.maxScrollExtent,
              ),
            );
          }
        }
      }
      _updateHover();
    }
  }

  void _startColumn(String id) {
    setState(() {
      _dragColumn = id;
      _columnFrom = _columnHover = widget.columns.indexWhere(
        (column) => column.id == id,
      );
    });
  }

  void _updateColumn(Offset position, double width) {
    final board = _rect(_boardKey);
    if (board == null || _dragColumn == null) return;
    final index =
        ((position.dx -
                    board.left +
                    (_horizontal.hasClients ? _horizontal.offset : 0)) /
                width)
            .floor()
            .clamp(0, widget.columns.length - 1);
    if (index != _columnHover) setState(() => _columnHover = index);
  }

  void _endColumn() {
    final id = _dragColumn;
    setState(() => _dragColumn = null);
    if (id != null && _columnFrom != _columnHover)
      widget.onColumnMove?.call(
        KanbanColumnMove(
          columnId: id,
          fromIndex: _columnFrom,
          toIndex: _columnHover,
        ),
      );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      _mobile = width < Breakpoints.standard.tabletMin;
      final height = constraints.hasBoundedHeight
          ? constraints.maxHeight
          : 480.0;
      return SizedBox(
        key: _boardKey,
        height: height,
        child: _mobile ? _mobileBoard(width) : _desktopBoard(height),
      );
    },
  );
  Widget _desktopBoard(double height) {
    final spec = StylePackScope.of(context).kanban;
    return SingleChildScrollView(
      controller: _horizontal,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            for (var index = 0; index < widget.columns.length; index++) ...[
              if (index > 0) SizedBox(width: spec.gap),
              if (_dragColumn != null && _columnHover == index)
                _columnPlaceholder(spec),
              _column(widget.columns[index], spec.columnWidth, false),
              if (_dragColumn != null &&
                  index == widget.columns.length - 1 &&
                  _columnHover == widget.columns.length - 1)
                _columnPlaceholder(spec),
            ],
          ],
        ),
      ),
    );
  }

  Widget _mobileBoard(double width) => Column(
    children: [
      Expanded(
        child: PageView(
          controller: _pages,
          children: [
            for (final column in widget.columns)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: _column(column, width * .9 - 24, true),
              ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      PageDots(controller: _pages, count: widget.columns.length),
    ],
  );
  Widget _columnPlaceholder(KanbanStyleSpec spec) => SizedBox(
    width: spec.columnWidth,
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppThemeScope.tokensOf(context).primaryColor),
        borderRadius: BorderRadius.circular(spec.radius),
      ),
    ),
  );
  Widget _tilt(double angle, Widget child) =>
      angle == 0 ? child : Transform.rotate(angle: angle, child: child);
  Widget _columnHandle(
    KanbanColumnData<T> column,
    double width,
    KanbanStyleSpec spec,
  ) =>
      Draggable<String>(
                        data: column.id,
                        onDragStarted: () => _startColumn(column.id),
                        onDragUpdate: (details) => _updateColumn(
                          details.globalPosition,
                          width + spec.gap,
                        ),
                        onDragEnd: (_) => _endColumn(),
                        feedback: SizedBox(
                          width: width,
                          child: Card(
                            child: Label(
                              type: LabelType.heading,
                              text: column.title,
                            ),
                          ),
                        ),
                        child: const Icon(Icons.drag_indicator),
                      );
  Widget _column(KanbanColumnData<T> column, double width, bool mobile) {
    final spec = StylePackScope.of(context).kanban;
    final tokens = AppThemeScope.tokensOf(context);
    final index = widget.columns.indexOf(column);
    final handle = !mobile && widget.onColumnMove != null
        ? _columnHandle(column, width, spec)
        : null;
    return Offstage(
      offstage: _dragColumn == column.id,
      child: SizedBox(
        width: width,
        child: Card(
          child: DecoratedBox(
            key: _key(_columns, column.id),
            decoration: BoxDecoration(
              color: tokens.primaryColor.withValues(
                alpha: spec.columnBackgroundOpacity,
              ),
              borderRadius: BorderRadius.circular(spec.radius),
            ),
            child: Column(
              children: [
                widget.columnHeaderBuilder?.call(
                      context,
                      column,
                      index,
                      handle,
                    ) ??
                    Row(
                  children: [
                    Expanded(
                      child: Label(
                        type: LabelType.heading,
                        text: column.title,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Label(
                      type: LabelType.caption,
                      text: '${column.items.length}',
                    ),
                    if (widget.columnActionsBuilder != null)
                      widget.columnActionsBuilder!(
                        context,
                        column,
                        widget.columns.indexOf(column),
                      ),
                    if (handle != null) handle,
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: _key(_lists, column.id),
                    controller: _scroller(column.id),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _cards(column, width - 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _cards(KanbanColumnData<T> column, double width) {
    final widgets = <Widget>[];
    final theme = AppThemeScope.themeOf(context);
    final pack = StylePackScope.of(context);
    var visible = 0;
    for (final item in column.items) {
      final id = widget.itemId(item);
      if (id != _dragId) {
        if (_hoverColumn == column.id && _hoverIndex == visible)
          widgets.add(_placeholder());
        visible++;
      }
      widgets.add(
        LongPressDraggable<String>(
          data: id,
          delay: pack.kanban.dragDelay,
          onDragStarted: () => _start(item, column.id),
          onDragUpdate: (details) => _update(details.globalPosition),
          onDragEnd: (_) => _end(),
          childWhenDragging: const SizedBox.shrink(),
          feedback: Material(
            color: const Color(0x00000000),
            child: AppThemeScope(
              theme: theme,
              child: StylePackScope(
                pack: pack,
                child: _tilt(
                  pack.kanban.dragTilt,
                  SizedBox(
                    width: width,
                    height: widget.cardHeight,
                    child: widget.itemBuilder(context, item),
                  ),
                ),
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: pack.kanban.cardGap),
            child: SizedBox(
              height: widget.cardHeight,
              child: GestureDetector(
                onTap: widget.onItemTap == null
                    ? null
                    : () => widget.onItemTap!(item),
                child: widget.itemBuilder(context, item),
              ),
            ),
          ),
        ),
      );
    }
    if (_hoverColumn == column.id && _hoverIndex == visible)
      widgets.add(_placeholder());
    if (widgets.isEmpty)
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(24),
          child: Label(
            type: LabelType.caption,
            text: widget.emptyLabel,
            textAlign: TextAlign.center,
          ),
        ),
      );
    return widgets;
  }

  Widget _placeholder() => Padding(
    padding: EdgeInsets.only(bottom: StylePackScope.of(context).kanban.cardGap),
    child: SizedBox(
      height: widget.cardHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppThemeScope.tokensOf(context).primaryColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
