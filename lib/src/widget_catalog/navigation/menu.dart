import 'package:flutter/material.dart' show PopupMenuButton, PopupMenuItem;
import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';
import '../inputs/select_option.dart';

/// Menu contextual controlado pela seleção, sem `PopupMenuButton` nas telas.
class Menu<T> extends StatelessWidget {
  const Menu({
    super.key,
    required this.items,
    required this.onSelected,
    required this.child,
  });
  final List<SelectOption<T>> items;
  final ValueChanged<T> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    return PopupMenuButton<T>(
      onSelected: onSelected,
      color: tokens.surfaceColor,
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem(value: item.value, child: Text(item.label, style: TextStyle(color: tokens.textColor))),
      ],
      child: child,
    );
  }
}
