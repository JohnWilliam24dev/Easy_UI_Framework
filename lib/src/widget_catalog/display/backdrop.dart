import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';

/// Fundo decorativo que usa somente os tokens do tema ativo.
class Backdrop extends StatelessWidget {
  const Backdrop.bubbles({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.backgroundColor,
            gradient: tokens.backgroundGradient,
          ),
        ),
        Positioned(
          top: -100,
          right: -60,
          child: _bubble(tokens.primaryColor.withValues(alpha: .16), 260),
        ),
        Positioned(
          bottom: -120,
          left: -80,
          child: _bubble(tokens.secondaryColor.withValues(alpha: .12), 300),
        ),
        child,
      ],
    );
  }

  Widget _bubble(Color color, double size) => SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      );
}
