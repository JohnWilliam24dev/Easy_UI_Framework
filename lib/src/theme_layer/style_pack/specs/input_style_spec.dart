import 'package:flutter/widgets.dart' show immutable;

import 'elevation_level.dart';

/// Estrutura visual de um campo de entrada.
enum InputStyleKind {
  /// Borda em volta do campo.
  outline,

  /// Apenas uma linha embaixo.
  underline,

  /// Fundo preenchido, sem borda.
  filled,
}

/// Aparência dos campos de texto (`InputField`). Não conhece cores: elas
/// vêm dos `ThemeTokens` na hora de montar o widget.
@immutable
class InputStyleSpec {
  /// Campo com borda.
  const InputStyleSpec.outline({
    this.radius = 8,
    this.elevation = ElevationLevel.none,
  }) : kind = InputStyleKind.outline;

  /// Campo com borda bem arredondada (padrão de raio maior).
  const InputStyleSpec.rounded({
    this.radius = 16,
    this.elevation = ElevationLevel.none,
  }) : kind = InputStyleKind.outline;

  /// Campo só com linha embaixo (visual denso, operacional).
  const InputStyleSpec.underline()
      : kind = InputStyleKind.underline,
        radius = 0,
        elevation = ElevationLevel.none;

  /// Campo com fundo preenchido.
  const InputStyleSpec.filled({
    this.radius = 8,
    this.elevation = ElevationLevel.none,
  }) : kind = InputStyleKind.filled;

  final InputStyleKind kind;
  final double radius;
  final ElevationLevel elevation;

  @override
  bool operator ==(Object other) {
    return other is InputStyleSpec &&
        other.kind == kind &&
        other.radius == radius &&
        other.elevation == elevation;
  }

  @override
  int get hashCode => Object.hash(kind, radius, elevation);
}
