import 'package:flutter/widgets.dart' hide Icon;

import '../display/icon.dart';
import '../display/label.dart';

/// Estado padrão para coleções e buscas sem resultado.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon,
    this.title = 'Nenhum item encontrado',
    this.description,
    this.action,
  });

  final IconData? icon;
  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon!, size: 36),
        if (icon != null) const SizedBox(height: 12),
        Label(
          type: LabelType.heading,
          text: title,
          textAlign: TextAlign.center,
        ),
        if (description != null) ...[
          const SizedBox(height: 6),
          Label(
            type: LabelType.caption,
            text: description!,
            textAlign: TextAlign.center,
          ),
        ],
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}
