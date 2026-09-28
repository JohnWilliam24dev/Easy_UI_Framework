import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';

/// Papel semântico da cor de um [Badge].
enum BadgeColor { success, warning, error, info, neutral }

/// Marcador pequeno de status/tag: um fundo colorido com texto, na cor
/// correspondente do tema.
///
/// ```dart
/// Badge(text: 'Pago', color: BadgeColor.success)
/// ```
class Badge extends StatelessWidget {
  const Badge({super.key, required this.text, this.color = BadgeColor.neutral});

  final String text;
  final BadgeColor color;

  Color _backgroundOf(ThemeTokens tokens) {
    return switch (color) {
      BadgeColor.success => tokens.successColor,
      BadgeColor.warning => tokens.warningColor,
      BadgeColor.error => tokens.errorColor,
      BadgeColor.info => tokens.infoColor,
      BadgeColor.neutral => tokens.borderColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final background = _backgroundOf(tokens);
    final foreground = estimateContrastBrightness(background) == Brightness.dark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            color: foreground,
            fontSize: tokens.baseFontSize * 0.8,
            fontWeight: FontWeight.w600,
            fontFamily: tokens.fontFamily,
          ),
        ),
      ),
    );
  }
}

/// Estimativa de brilho sem depender do Material (evita puxar
/// `package:flutter/material.dart` só por causa disso).
Brightness estimateContrastBrightness(Color color) {
  // Fórmula de luminância relativa (mesma usada pelo Material).
  final r = _linear(color.r);
  final g = _linear(color.g);
  final b = _linear(color.b);
  final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  return luminance <= 0.179 ? Brightness.dark : Brightness.light;
}

double _linear(double channel) {
  return channel <= 0.03928
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}
