import 'package:flutter/widgets.dart' show immutable;

@immutable
class KanbanStyleSpec {
  const KanbanStyleSpec({
    this.columnWidth = 320,
    this.radius = 12,
    this.gap = 16,
    this.columnBackgroundOpacity = 0.06,
  });
  final double columnWidth, radius, gap, columnBackgroundOpacity;
  @override
  bool operator ==(Object other) =>
      other is KanbanStyleSpec &&
      other.columnWidth == columnWidth &&
      other.radius == radius &&
      other.gap == gap &&
      other.columnBackgroundOpacity == columnBackgroundOpacity;
  @override
  int get hashCode =>
      Object.hash(columnWidth, radius, gap, columnBackgroundOpacity);
}
