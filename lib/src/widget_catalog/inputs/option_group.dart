import 'package:flutter/material.dart' show RadioListTile;
import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';
import 'select_option.dart';

/// Grupo de opções mutuamente exclusivas, sem exigir `RadioGroup` ou a
/// repetição de `RadioListTile` em cada tela.
class OptionGroup<T> extends StatelessWidget {
  const OptionGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final List<SelectOption<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in options)
          RadioListTile<T>(
            value: option.value,
            groupValue: value,
            onChanged: enabled
                ? (next) {
                    if (next != null) onChanged(next);
                  }
                : null,
            activeColor: tokens.primaryColor,
            title: Text(
              option.label,
              style: TextStyle(
                color: enabled ? tokens.textColor : tokens.disabledColor,
                fontFamily: tokens.fontFamily,
              ),
            ),
          ),
      ],
    );
  }
}
