import 'package:flutter/material.dart' show InkWell, Material, MaterialType;
import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';
import 'label.dart';

/// Linha semântica para menu, lista de ações e seleção.
class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final Widget? leading, trailing;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);
    final spec = pack.listItem;
    final content = Padding(
      padding: EdgeInsets.all(pack.space(tokens, spec.paddingSteps)),
      child: Row(
        children: [
          if (leading != null) ...[leading!, SizedBox(width: pack.space(tokens))],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Label(text: title),
                if (subtitle != null) Label(type: LabelType.caption, text: subtitle!),
              ],
            ),
          ),
          if (trailing != null) ...[SizedBox(width: pack.space(tokens)), trailing!],
        ],
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(spec.radius),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? tokens.selectedColor : null,
              borderRadius: BorderRadius.circular(spec.radius),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
