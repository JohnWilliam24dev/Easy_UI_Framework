import 'package:flutter/widgets.dart' show immutable;

@immutable
class ModalStyleSpec {
  const ModalStyleSpec({
    this.radius = 16,
    this.maxWidth = 560,
    this.sheetRadius = 20,
  });
  final double radius, maxWidth, sheetRadius;
  @override
  bool operator ==(Object other) =>
      other is ModalStyleSpec &&
      other.radius == radius &&
      other.maxWidth == maxWidth &&
      other.sheetRadius == sheetRadius;
  @override
  int get hashCode => Object.hash(radius, maxWidth, sheetRadius);
}
