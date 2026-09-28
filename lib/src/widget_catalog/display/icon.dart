import 'package:flutter/widgets.dart' as flutter;
import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';

/// Ícone padronizado pelo tema: usa `IconData` do Material (o mesmo conjunto
/// já usado internamente por `InputField` e `Toggle`) mas resolve tamanho e
/// cor a partir dos tokens, sem depender de `Theme.of` do Material.
///
/// ```dart
/// Icon(Icons.search)
/// Icon(Icons.error, color: (tokens) => tokens.errorColor)
/// ```
class Icon extends StatelessWidget {
  const Icon(this.data, {super.key, this.size, this.color});

  final flutter.IconData data;

  /// Tamanho em pixels lógicos. Padrão: `baseFontSize * 1.5` do tema.
  final double? size;

  /// Cor do ícone. Padrão: cor de texto do tema.
  final Color Function(ThemeTokens tokens)? color;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    return flutter.Icon(
      data,
      size: size ?? tokens.baseFontSize * 1.5,
      color: color?.call(tokens) ?? tokens.textColor,
    );
  }
}
