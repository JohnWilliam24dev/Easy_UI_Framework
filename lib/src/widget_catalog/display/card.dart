import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';

/// Superfície elevada: Container + BoxShadow + BorderRadius + Padding,
/// pintada com os tokens e a aparência do `CardStyleSpec` do pack ativo.
///
/// - [elevation]: sobrescreve a elevação do pack para este card específico;
/// - [onTap]: torna o card tocável (sem efeito visual de toque adicional,
///   além do que a plataforma já oferecer via semântica).
///
/// ```dart
/// Card(child: Div(children: [Label(text: 'Pedido #123'), ...]))
/// ```
class Card extends StatelessWidget {
  const Card({super.key, required this.child, this.elevation, this.onTap});

  final Widget child;
  final ElevationLevel? elevation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);
    final spec = pack.card;
    final level = elevation ?? spec.elevation;

    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surfaceColor,
        borderRadius: BorderRadius.circular(spec.radius),
        boxShadow: level == ElevationLevel.none
            ? null
            : [
                BoxShadow(
                  color: tokens.textColor.withValues(alpha: 0.12),
                  blurRadius: level.dp * 2,
                  offset: Offset(0, level.dp / 2),
                ),
              ],
      ),
      child: Padding(
        padding: EdgeInsets.all(pack.space(tokens, spec.paddingSteps)),
        child: child,
      ),
    );

    final tap = onTap;
    if (tap != null) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(spec.radius),
        child: GestureDetector(onTap: tap, behavior: HitTestBehavior.opaque, child: card),
      );
    }
    return card;
  }
}
