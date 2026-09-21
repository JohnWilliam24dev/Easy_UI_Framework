import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';

/// Papel tipográfico do texto.
enum LabelType { title, subtitle, body, caption, error }

/// Monta o `TextStyle` de um [LabelType] a partir dos tokens e da escala
/// tipográfica do pack ativo.
TextStyle labelStyleFor({
  required ThemeTokens tokens,
  required LabelStyleSpec spec,
  required LabelType type,
}) {
  final (scale, weight, color) = switch (type) {
    LabelType.title => (spec.titleScale, spec.titleWeight, tokens.textColor),
    LabelType.subtitle => (
        spec.subtitleScale,
        spec.subtitleWeight,
        tokens.textColor,
      ),
    LabelType.body => (spec.bodyScale, FontWeight.w400, tokens.textColor),
    LabelType.caption => (
        spec.captionScale,
        FontWeight.w400,
        tokens.mutedTextColor,
      ),
    LabelType.error => (spec.bodyScale, FontWeight.w500, tokens.errorColor),
  };

  return TextStyle(
    color: color,
    fontSize: tokens.baseFontSize * scale,
    fontWeight: weight,
    fontFamily: tokens.fontFamily,
  );
}

/// Texto do app: Text + TextStyle do tema, escolhido por [type].
///
/// ```dart
/// Label(type: LabelType.title, text: 'Login')
/// ```
class Label extends StatelessWidget {
  const Label({
    super.key,
    required this.text,
    this.type = LabelType.body,
    this.textAlign,
    this.maxLines,
  });

  final String text;
  final LabelType type;
  final TextAlign? textAlign;

  /// Limita o número de linhas (o excesso vira reticências).
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final style = labelStyleFor(
      tokens: AppThemeScope.tokensOf(context),
      spec: StylePackScope.of(context).label,
      type: type,
    );
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
