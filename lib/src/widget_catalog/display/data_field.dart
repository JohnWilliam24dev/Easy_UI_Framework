import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';
import 'label.dart';

/// Par semântico de rótulo e valor, para resumos e detalhes.
class DataField extends StatelessWidget {
  const DataField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final pack = StylePackScope.of(context);
    final tokens = AppThemeScope.tokensOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Label(type: LabelType.fieldLabel, text: label),
        SizedBox(height: pack.space(tokens, .5)),
        Label(text: value),
      ],
    );
  }
}
