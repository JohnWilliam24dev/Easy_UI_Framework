import 'package:flutter/widgets.dart' show immutable;

import 'elevation_level.dart';

/// Variantes semânticas de superfície para [Card].
enum CardVariant { elevated, outlined, tinted, glass }

/// Aparência dos cards (`Card`).
@immutable
class CardStyleSpec {
  const CardStyleSpec({
    this.radius = 12,
    this.elevation = ElevationLevel.subtle,
    this.paddingSteps = 2,
    this.variant = CardVariant.elevated,
    this.borderWidth = 1,
    this.blur = 0,
  });

  /// Card plano e justo: sem sombra, cantos discretos.
  const CardStyleSpec.flat()
    : radius = 4,
      elevation = ElevationLevel.none,
      paddingSteps = 1.5,
      variant = CardVariant.outlined,
      borderWidth = 1,
      blur = 0;

  /// Superfície translúcida. As cores vêm de `panelColor` e
  /// `panelBorderColor` dos tokens.
  const CardStyleSpec.glass({this.radius = 16, this.paddingSteps = 2})
    : elevation = ElevationLevel.none,
      variant = CardVariant.glass,
      borderWidth = 1,
      blur = 12;

  final double radius;
  final ElevationLevel elevation;

  /// Padding interno, em múltiplos da unidade base de espaçamento
  /// (`baseSpacing` do tema, vezes o `spacingScale` do pack).
  final double paddingSteps;
  final CardVariant variant;
  final double borderWidth;
  final double blur;

  @override
  bool operator ==(Object other) {
    return other is CardStyleSpec &&
        other.radius == radius &&
        other.elevation == elevation &&
        other.paddingSteps == paddingSteps &&
        other.variant == variant &&
        other.borderWidth == borderWidth &&
        other.blur == blur;
  }

  @override
  int get hashCode =>
      Object.hash(radius, elevation, paddingSteps, variant, borderWidth, blur);
}
