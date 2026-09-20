import 'package:flutter/widgets.dart';

/// Paleta crua e valores base do tema, definidos explicitamente pelo
/// desenvolvedor. O framework não infere nada do Material Design.
///
/// Obrigatórias: [primaryColor], [secondaryColor], [backgroundColor] e
/// [textColor]. As demais têm um padrão documentado:
///
/// - [surfaceColor]: padrão = [backgroundColor];
/// - [mutedTextColor]: padrão = [textColor] com 60% de opacidade;
/// - [onPrimaryColor]: padrão = branco (informe outro se [primaryColor]
///   for uma cor clara);
/// - [borderColor]: padrão = [textColor] com 20% de opacidade;
/// - cores de status: verde, âmbar, vermelho e azul fixos do framework.
@immutable
class ThemeTokens {
  const ThemeTokens({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    Color? surfaceColor,
    Color? mutedTextColor,
    Color? onPrimaryColor,
    Color? borderColor,
    this.successColor = const Color(0xFF2E7D32),
    this.warningColor = const Color(0xFFED6C02),
    this.errorColor = const Color(0xFFD32F2F),
    this.infoColor = const Color(0xFF0288D1),
    this.fontFamily,
    this.baseFontSize = 14,
    this.baseSpacing = 8,
  })  : assert(baseFontSize > 0, 'baseFontSize deve ser > 0.'),
        assert(baseSpacing >= 0, 'baseSpacing deve ser >= 0.'),
        _surfaceColor = surfaceColor,
        _mutedTextColor = mutedTextColor,
        _onPrimaryColor = onPrimaryColor,
        _borderColor = borderColor;

  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;

  final Color? _surfaceColor;
  final Color? _mutedTextColor;
  final Color? _onPrimaryColor;
  final Color? _borderColor;

  final Color successColor;
  final Color warningColor;
  final Color errorColor;
  final Color infoColor;

  /// Família de fonte padrão. `null` usa a fonte padrão da plataforma.
  final String? fontFamily;

  /// Tamanho de fonte base (corpo de texto), em pixels lógicos.
  final double baseFontSize;

  /// Unidade base de espaçamento, em pixels lógicos. O `spacingScale` do
  /// `StylePack` multiplica este valor.
  final double baseSpacing;

  /// Cor de superfícies (cards, modais).
  Color get surfaceColor => _surfaceColor ?? backgroundColor;

  /// Cor de texto secundário (legendas, dicas).
  Color get mutedTextColor =>
      _mutedTextColor ?? textColor.withValues(alpha: 0.6);

  /// Cor de conteúdo (texto/ícone) sobre [primaryColor].
  Color get onPrimaryColor => _onPrimaryColor ?? const Color(0xFFFFFFFF);

  /// Cor de bordas e divisores.
  Color get borderColor => _borderColor ?? textColor.withValues(alpha: 0.2);

  ThemeTokens copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? textColor,
    Color? surfaceColor,
    Color? mutedTextColor,
    Color? onPrimaryColor,
    Color? borderColor,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? infoColor,
    String? fontFamily,
    double? baseFontSize,
    double? baseSpacing,
  }) {
    return ThemeTokens(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      surfaceColor: surfaceColor ?? _surfaceColor,
      mutedTextColor: mutedTextColor ?? _mutedTextColor,
      onPrimaryColor: onPrimaryColor ?? _onPrimaryColor,
      borderColor: borderColor ?? _borderColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
      infoColor: infoColor ?? this.infoColor,
      fontFamily: fontFamily ?? this.fontFamily,
      baseFontSize: baseFontSize ?? this.baseFontSize,
      baseSpacing: baseSpacing ?? this.baseSpacing,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ThemeTokens &&
        other.primaryColor == primaryColor &&
        other.secondaryColor == secondaryColor &&
        other.backgroundColor == backgroundColor &&
        other.textColor == textColor &&
        other._surfaceColor == _surfaceColor &&
        other._mutedTextColor == _mutedTextColor &&
        other._onPrimaryColor == _onPrimaryColor &&
        other._borderColor == _borderColor &&
        other.successColor == successColor &&
        other.warningColor == warningColor &&
        other.errorColor == errorColor &&
        other.infoColor == infoColor &&
        other.fontFamily == fontFamily &&
        other.baseFontSize == baseFontSize &&
        other.baseSpacing == baseSpacing;
  }

  @override
  int get hashCode => Object.hash(
        primaryColor,
        secondaryColor,
        backgroundColor,
        textColor,
        _surfaceColor,
        _mutedTextColor,
        _onPrimaryColor,
        _borderColor,
        successColor,
        warningColor,
        errorColor,
        infoColor,
        fontFamily,
        baseFontSize,
        baseSpacing,
      );
}
