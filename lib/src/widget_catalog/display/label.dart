import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';

/// Papel tipográfico do texto.
enum LabelType {
  title,
  subtitle,
  body,
  caption,
  error,
  overline,
  heading,
  fieldLabel,
}

/// Monta o `TextStyle` de um [LabelType] a partir dos tokens e da escala
/// tipográfica do pack ativo.
TextStyle labelStyleFor({
  required ThemeTokens tokens,
  required LabelStyleSpec spec,
  required LabelType type,
}) {
  final (scale, weight, color, letterSpacing) = switch (type) {
    LabelType.title => (
      spec.titleScale,
      spec.titleWeight,
      tokens.headingColor,
      0.0,
    ),
    LabelType.subtitle => (
      spec.subtitleScale,
      spec.subtitleWeight,
      tokens.headingColor,
      0.0,
    ),
    LabelType.body => (spec.bodyScale, FontWeight.w400, tokens.textColor, 0.0),
    LabelType.caption => (
      spec.captionScale,
      FontWeight.w400,
      tokens.mutedTextColor,
      0.0,
    ),
    LabelType.error => (
      spec.bodyScale,
      FontWeight.w500,
      tokens.errorColor,
      0.0,
    ),
    LabelType.overline => (
      spec.overlineScale,
      FontWeight.w600,
      tokens.mutedTextColor,
      spec.overlineLetterSpacing,
    ),
    LabelType.heading => (
      spec.headingScale,
      spec.titleWeight,
      tokens.headingColor,
      0.0,
    ),
    LabelType.fieldLabel => (
      spec.fieldLabelScale,
      FontWeight.w600,
      tokens.mutedTextColor,
      0.0,
    ),
  };

  return TextStyle(
    color: color,
    fontSize: tokens.baseFontSize * scale,
    fontWeight: weight,
    fontFamily: tokens.fontFamily,
    height: spec.lineHeight,
    letterSpacing: letterSpacing,
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
    this.color,
    this.lineHeight,
  });

  final String text;
  final LabelType type;
  final TextAlign? textAlign;

  /// Limita o número de linhas (o excesso vira reticências).
  final int? maxLines;
  final Color Function(ThemeTokens tokens)? color;
  final double? lineHeight;

  @override
  Widget build(BuildContext context) {
    final style = labelStyleFor(
      tokens: AppThemeScope.tokensOf(context),
      spec: StylePackScope.of(context).label,
      type: type,
    );
    return Text(
      text,
      style: style.copyWith(
        color: color?.call(AppThemeScope.tokensOf(context)),
        height: lineHeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
