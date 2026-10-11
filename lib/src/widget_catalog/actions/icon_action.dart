import 'package:flutter/material.dart' show IconButton, Tooltip;
import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';

/// Ação compacta com ícone e descrição acessível obrigatória.
class IconAction extends StatelessWidget {
  const IconAction({super.key, required this.icon, required this.tooltip, required this.onPressed});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: tokens.iconColor,
        disabledColor: tokens.disabledColor,
      ),
    );
  }
}
