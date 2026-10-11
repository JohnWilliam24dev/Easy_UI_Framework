import 'package:flutter/widgets.dart' show immutable;

@immutable
class ListItemStyleSpec {
  const ListItemStyleSpec({
    this.radius = 10,
    this.paddingSteps = 1.5,
    this.selectedOpacity = 0.12,
  });
  final double radius, paddingSteps, selectedOpacity;
  @override
  bool operator ==(Object other) =>
      other is ListItemStyleSpec &&
      other.radius == radius &&
      other.paddingSteps == paddingSteps &&
      other.selectedOpacity == selectedOpacity;
  @override
  int get hashCode => Object.hash(radius, paddingSteps, selectedOpacity);
}
