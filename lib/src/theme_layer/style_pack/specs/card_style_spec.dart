import 'package:flutter/widgets.dart' show immutable;

import 'elevation_level.dart';

/// Aparência dos cards (`Card`).
@immutable
class CardStyleSpec {
  const CardStyleSpec({
    this.radius = 12,
    this.elevation = ElevationLevel.subtle,
    this.paddingSteps = 2,
  });

  /// Card plano e justo: sem sombra, cantos discretos.
  const CardStyleSpec.flat()
      : radius = 4,
        elevation = ElevationLevel.none,
        paddingSteps = 1.5;

  final double radius;
  final ElevationLevel elevation;

  /// Padding interno, em múltiplos da unidade base de espaçamento
  /// (`baseSpacing` do tema, vezes o `spacingScale` do pack).
  final double paddingSteps;

  @override
  bool operator ==(Object other) {
    return other is CardStyleSpec &&
        other.radius == radius &&
        other.elevation == elevation &&
        other.paddingSteps == paddingSteps;
  }

  @override
  int get hashCode => Object.hash(radius, elevation, paddingSteps);
}
