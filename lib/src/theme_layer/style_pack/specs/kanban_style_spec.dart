import 'package:flutter/widgets.dart' show immutable;

@immutable
class KanbanStyleSpec {
  const KanbanStyleSpec({
    this.columnWidth = 320,
    this.radius = 12,
    this.gap = 16,
    this.cardGap = 8,
    this.dragDelay = const Duration(milliseconds: 200),
    this.columnBackgroundOpacity = 0.06,
    this.dragTilt = 0,
  });
  final double columnWidth, radius, gap, cardGap, columnBackgroundOpacity;

  /// Inclinação (radianos) do card enquanto é arrastado, como no Trello.
  /// 0 = sem inclinação. Algo como 0.035 (~2°) dá o efeito sutil.
  final double dragTilt;
  final Duration dragDelay;
  @override
  bool operator ==(Object other) =>
      other is KanbanStyleSpec &&
      other.columnWidth == columnWidth &&
      other.radius == radius &&
      other.gap == gap &&
      other.cardGap == cardGap &&
      other.dragDelay == dragDelay &&
      other.columnBackgroundOpacity == columnBackgroundOpacity &&
      other.dragTilt == dragTilt;
  @override
  int get hashCode =>
      Object.hash(
        columnWidth,
        radius,
        gap,
        cardGap,
        dragDelay,
        columnBackgroundOpacity,
        dragTilt,
      );
}
