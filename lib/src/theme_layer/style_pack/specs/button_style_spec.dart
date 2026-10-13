import 'package:flutter/widgets.dart' show FontWeight, immutable;

/// Aparência dos botões (`Button`). A escolha entre solid, outline, ghost
/// etc. é a prop `variant` do widget; aqui fica a "pele" do pack: raio,
/// altura e espaçamento interno.
@immutable
class ButtonStyleSpec {
  const ButtonStyleSpec({
    this.radius = 8,
    this.minHeight = 44,
    this.horizontalPadding = 20,
    this.fontWeight = FontWeight.w600,
    this.iconGap = 8,
    this.iconSize = 18,
  });

  /// Cantos totalmente arredondados (formato de pílula).
  const ButtonStyleSpec.pill()
    : radius = pillRadius,
      minHeight = 48,
      horizontalPadding = 28,
      fontWeight = FontWeight.w600,
      iconGap = 8,
      iconSize = 18;

  /// Botão baixo e justo, para telas densas.
  const ButtonStyleSpec.compact()
    : radius = 4,
      minHeight = 32,
      horizontalPadding = 12,
      fontWeight = FontWeight.w500,
      iconGap = 6,
      iconSize = 16;

  /// Raio grande o bastante para virar pílula em qualquer altura.
  static const double pillRadius = 999;

  final double radius;
  final double minHeight;
  final double horizontalPadding;
  final FontWeight fontWeight;
  final double iconGap;
  final double iconSize;

  @override
  bool operator ==(Object other) {
    return other is ButtonStyleSpec &&
        other.radius == radius &&
        other.minHeight == minHeight &&
        other.horizontalPadding == horizontalPadding &&
        other.fontWeight == fontWeight &&
        other.iconGap == iconGap &&
        other.iconSize == iconSize;
  }

  @override
  int get hashCode => Object.hash(
    radius,
    minHeight,
    horizontalPadding,
    fontWeight,
    iconGap,
    iconSize,
  );
}
