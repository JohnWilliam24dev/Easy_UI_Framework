import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';
import '../display/label.dart';

/// Bloco de página com cabeçalho semântico e conteúdo livre.
class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(type: LabelType.heading, text: title),
                  if (subtitle != null) ...[
                    SizedBox(height: pack.space(tokens, .5)),
                    Label(type: LabelType.caption, text: subtitle!),
                  ],
                ],
              ),
            ),
            if (action != null) ...[SizedBox(width: pack.space(tokens)), action!],
          ],
        ),
        SizedBox(height: pack.space(tokens, 2)),
        child,
      ],
    );
  }
}
