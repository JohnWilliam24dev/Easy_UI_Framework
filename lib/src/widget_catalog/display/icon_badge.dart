import 'package:flutter/widgets.dart' hide Icon;

import '../../theme_layer/theme_layer.dart';
import 'icon.dart';

/// Ícone decorativo em superfície circular com cores semânticas do tema.
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.size = 40});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: tokens.selectedColor, shape: BoxShape.circle),
        child: Center(child: Icon(icon, size: size * .5, color: (t) => t.accentColor)),
      ),
    );
  }
}
