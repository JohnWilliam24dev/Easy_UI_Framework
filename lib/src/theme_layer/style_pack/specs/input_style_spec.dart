import 'package:flutter/widgets.dart' show Color, immutable;

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

/// Posição padrão do rótulo de um campo.
enum InputLabelPosition { above, floating, none }

/// Aparência dos campos de texto (`InputField`). Não conhece cores: elas
/// vêm dos `ThemeTokens` na hora de montar o widget.
@immutable
class InputStyleSpec {
  /// Campo com borda.
  const InputStyleSpec.outline({
    this.radius = 8,
    this.elevation = ElevationLevel.none,
    this.labelPosition = InputLabelPosition.floating,
    this.borderColor,
  }) : kind = InputStyleKind.outline;

  /// Campo com borda bem arredondada (padrão de raio maior).
  const InputStyleSpec.rounded({
    this.radius = 16,
    this.elevation = ElevationLevel.none,
    this.labelPosition = InputLabelPosition.floating,
    this.borderColor,
  }) : kind = InputStyleKind.outline;

  /// Campo só com linha embaixo (visual denso, operacional).
  const InputStyleSpec.underline()
    : kind = InputStyleKind.underline,
      radius = 0,
      elevation = ElevationLevel.none,
      labelPosition = InputLabelPosition.above,
      borderColor = null;

  /// Campo com fundo preenchido.
  const InputStyleSpec.filled({
    this.radius = 8,
    this.elevation = ElevationLevel.none,
    this.labelPosition = InputLabelPosition.floating,
  }) : kind = InputStyleKind.filled,
       borderColor = null;

  final InputStyleKind kind;
  final double radius;
  final ElevationLevel elevation;
  final InputLabelPosition labelPosition;

  /// Cor da borda em repouso. `null` usa `ThemeTokens.borderColor`. Serve
  /// quando o token de borda do tema não contrasta com a superfície do campo
  /// (ex.: borda translúcida pensada para fundo colorido).
  final Color? borderColor;

  @override
  bool operator ==(Object other) {
    return other is InputStyleSpec &&
        other.kind == kind &&
        other.radius == radius &&
        other.elevation == elevation &&
        other.labelPosition == labelPosition &&
        other.borderColor == borderColor;
  }

  @override
  int get hashCode => Object.hash(kind, radius, elevation, labelPosition, borderColor);
}
