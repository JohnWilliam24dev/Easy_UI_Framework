import 'package:flutter/widgets.dart';

import '../../kernel/kernel.dart';
import '../../theme_layer/theme_layer.dart';

/// Linha divisória: Divider / VerticalDivider, na cor de borda do tema.
///
/// - [direction] `horizontal` (padrão, para separar itens em coluna) ou
///   `vertical` (para separar itens em linha);
/// - [thickness]: espessura em pixels lógicos (padrão 1);
/// - [inset]: recuo nas duas pontas, na direção da linha.
class Divider extends StatelessWidget {
  const Divider({
    super.key,
    this.direction = LayoutDirection.horizontal,
    this.thickness = 1,
    this.inset = 0,
  }) : assert(
          direction != LayoutDirection.layered,
          'Divider não aceita direction layered.',
        );

  final LayoutDirection direction;
  final double thickness;
  final double inset;

  @override
  Widget build(BuildContext context) {
    final color = AppThemeScope.tokensOf(context).borderColor;
    final horizontal = direction == LayoutDirection.horizontal;

    return horizontal
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: inset),
            child: SizedBox(height: thickness, child: ColoredBox(color: color)),
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: inset),
            child: SizedBox(width: thickness, child: ColoredBox(color: color)),
          );
  }
}
