import 'package:flutter/material.dart';

import '../../theme_layer/theme_layer.dart';

/// Monta o `InputDecoration` de um campo a partir dos tokens e do
/// `InputStyleSpec` do pack ativo. Toda cor vem dos tokens.
InputDecoration buildInputDecoration({
  required ThemeTokens tokens,
  required StylePack pack,
  String? hint,
  String? errorText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  final spec = pack.inputText;
  final kind = spec.kind;
  final hasBox = kind != InputStyleKind.underline;
  final radius = BorderRadius.circular(spec.radius);

  InputBorder border(BorderSide side) {
    return hasBox
        ? OutlineInputBorder(borderRadius: radius, borderSide: side)
        : UnderlineInputBorder(borderSide: side);
  }

  final restSide = kind == InputStyleKind.filled
      ? BorderSide.none
      : BorderSide(color: tokens.borderColor);
  final focusedSide = BorderSide(color: tokens.primaryColor, width: 2);
  final errorSide = BorderSide(color: tokens.errorColor);
  final focusedErrorSide = BorderSide(color: tokens.errorColor, width: 2);

  final filled =
      kind == InputStyleKind.filled || spec.elevation != ElevationLevel.none;
  final fillColor = kind == InputStyleKind.filled
      ? Color.alphaBlend(
          tokens.textColor.withValues(alpha: 0.06),
          tokens.surfaceColor,
        )
      : tokens.surfaceColor;

  final verticalPadding = pack.space(tokens, 1.5);

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: tokens.mutedTextColor,
      fontFamily: tokens.fontFamily,
    ),
    errorText: errorText,
    errorStyle: TextStyle(
      color: tokens.errorColor,
      fontFamily: tokens.fontFamily,
    ),
    filled: filled,
    fillColor: filled ? fillColor : null,
    contentPadding: hasBox
        ? EdgeInsets.symmetric(
            horizontal: pack.space(tokens, 2),
            vertical: verticalPadding,
          )
        : EdgeInsets.symmetric(vertical: verticalPadding),
    border: border(restSide),
    enabledBorder: border(restSide),
    disabledBorder: border(restSide),
    focusedBorder: border(focusedSide),
    errorBorder: border(errorSide),
    focusedErrorBorder: border(focusedErrorSide),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
  );
}
