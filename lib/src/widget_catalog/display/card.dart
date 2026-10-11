import 'dart:ui';

import 'package:flutter/material.dart' show InkWell, Material, MaterialType;
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
  const Card({
    super.key,
    required this.child,
    this.elevation,
    this.variant,
    this.paddingSteps,
    this.onTap,
  });

  final Widget child;
  final ElevationLevel? elevation;
  final CardVariant? variant;
  final double? paddingSteps;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);
    final spec = pack.card;
    final level = elevation ?? spec.elevation;
    final activeVariant = variant ?? spec.variant;
    final isGlass = activeVariant == CardVariant.glass;
    final background = switch (activeVariant) {
      CardVariant.tinted => tokens.selectedColor,
      CardVariant.glass => tokens.panelColor.withValues(alpha: 0.72),
      _ => tokens.surfaceColor,
    };

    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(spec.radius),
        border: activeVariant == CardVariant.outlined || isGlass
            ? Border.all(
                color: tokens.panelBorderColor,
                width: spec.borderWidth,
              )
            : null,
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
        padding: EdgeInsets.all(
          pack.space(tokens, paddingSteps ?? spec.paddingSteps),
        ),
        child: child,
      ),
    );

    if (isGlass && spec.blur > 0) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(spec.radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: spec.blur, sigmaY: spec.blur),
          child: card,
        ),
      );
    }
    final tap = onTap;
    if (tap != null) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(spec.radius),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(onTap: tap, child: card),
        ),
      );
    }
    return card;
  }
}
