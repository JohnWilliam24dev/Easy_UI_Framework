import 'package:flutter/widgets.dart' show immutable;

enum NavStyle { docked, floating }

@immutable
class NavStyleSpec {
  const NavStyleSpec({
    this.expandedWidth = 264,
    this.collapsedWidth = 72,
    this.itemRadius = 10,
    this.style = NavStyle.docked,
  });
  final double expandedWidth, collapsedWidth, itemRadius;
  final NavStyle style;
  @override
  bool operator ==(Object other) =>
      other is NavStyleSpec &&
      other.expandedWidth == expandedWidth &&
      other.collapsedWidth == collapsedWidth &&
      other.itemRadius == itemRadius &&
      other.style == style;
  @override
  int get hashCode =>
      Object.hash(expandedWidth, collapsedWidth, itemRadius, style);
}
