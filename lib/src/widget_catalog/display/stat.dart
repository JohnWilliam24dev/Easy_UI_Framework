import 'package:flutter/widgets.dart' hide Icon;

import '../../theme_layer/theme_layer.dart';
import 'icon.dart';
import 'label.dart';

/// Métrica resumida para dashboards. A aparência do contêiner fica por conta
/// de `Card` ou `StatGrid`; este widget só expressa a informação.
class Stat extends StatelessWidget {
  const Stat({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.delta,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon!, size: 24, color: (t) => t.accentColor),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Label(type: LabelType.fieldLabel, text: label),
              Label(type: LabelType.heading, text: value),
              if (delta != null)
                Text(
                  delta!,
                  style: TextStyle(
                    color: tokens.accentColor,
                    fontSize: tokens.baseFontSize * .85,
                    fontFamily: tokens.fontFamily,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
