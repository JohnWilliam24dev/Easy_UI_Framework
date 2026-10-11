import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';

/// Cria uma versão translúcida de [base] com opacidade explícita.
Color tint(Color base, double alpha) => base.withValues(alpha: alpha);

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
    // ignore: prefer_initializing_formals
    Color? surfaceColor,
    // ignore: prefer_initializing_formals
    Color? mutedTextColor,
    // ignore: prefer_initializing_formals
    Color? onPrimaryColor,
    // ignore: prefer_initializing_formals
    Color? borderColor,
    Color? headingColor,
    Color? inputColor,
    Color? disabledColor,
    Color? iconColor,
    Color? selectedColor,
    Color? accentColor,
    Color? negativeColor,
    Color? panelColor,
    Color? panelBorderColor,
    List<Color>? chartColors,
    this.backgroundGradient,
    Color? onBackgroundColor,
    this.successColor = const Color(0xFF2E7D32),
    this.warningColor = const Color(0xFFED6C02),
    this.errorColor = const Color(0xFFD32F2F),
    this.infoColor = const Color(0xFF0288D1),
    this.fontFamily,
    this.baseFontSize = 14,
    this.baseSpacing = 8,
  }) : assert(baseFontSize > 0, 'baseFontSize deve ser > 0.'),
       assert(baseSpacing >= 0, 'baseSpacing deve ser >= 0.'),
       _surfaceColor = surfaceColor,
       _mutedTextColor = mutedTextColor,
       _onPrimaryColor = onPrimaryColor,
       _borderColor = borderColor,
       _headingColor = headingColor,
       _inputColor = inputColor,
       _disabledColor = disabledColor,
       _iconColor = iconColor,
       _selectedColor = selectedColor,
       _accentColor = accentColor,
       _negativeColor = negativeColor,
       _panelColor = panelColor,
       _panelBorderColor = panelBorderColor,
       _chartColors = chartColors,
       _onBackgroundColor = onBackgroundColor;

  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;

  final Color? _surfaceColor;
  final Color? _mutedTextColor;
  final Color? _onPrimaryColor;
  final Color? _borderColor;
  final Color? _headingColor, _inputColor, _disabledColor, _iconColor;
  final Color? _selectedColor, _accentColor, _negativeColor;
  final Color? _panelColor, _panelBorderColor, _onBackgroundColor;
  final List<Color>? _chartColors;
  final Gradient? backgroundGradient;

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
  Color get headingColor => _headingColor ?? textColor;
  Color get inputColor => _inputColor ?? surfaceColor;
  Color get disabledColor => _disabledColor ?? mutedTextColor;
  Color get iconColor => _iconColor ?? textColor;
  Color get selectedColor => _selectedColor ?? tint(primaryColor, 0.12);
  Color get accentColor => _accentColor ?? primaryColor;
  Color get negativeColor => _negativeColor ?? errorColor;
  Color get panelColor => _panelColor ?? surfaceColor;
  Color get panelBorderColor => _panelBorderColor ?? borderColor;
  Color get onBackgroundColor => _onBackgroundColor ?? textColor;
  List<Color> get chartColors =>
      _chartColors ??
      <Color>[primaryColor, secondaryColor, infoColor, warningColor];

  ThemeTokens copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? textColor,
    // ignore: prefer_initializing_formals
    Color? surfaceColor,
    // ignore: prefer_initializing_formals
    Color? mutedTextColor,
    // ignore: prefer_initializing_formals
    Color? onPrimaryColor,
    // ignore: prefer_initializing_formals
    Color? borderColor,
    Color? headingColor,
    Color? inputColor,
    Color? disabledColor,
    Color? iconColor,
    Color? selectedColor,
    Color? accentColor,
    Color? negativeColor,
    Color? panelColor,
    Color? panelBorderColor,
    List<Color>? chartColors,
    Gradient? backgroundGradient,
    Color? onBackgroundColor,
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
      headingColor: headingColor ?? _headingColor,
      inputColor: inputColor ?? _inputColor,
      disabledColor: disabledColor ?? _disabledColor,
      iconColor: iconColor ?? _iconColor,
      selectedColor: selectedColor ?? _selectedColor,
      accentColor: accentColor ?? _accentColor,
      negativeColor: negativeColor ?? _negativeColor,
      panelColor: panelColor ?? _panelColor,
      panelBorderColor: panelBorderColor ?? _panelBorderColor,
      chartColors: chartColors ?? _chartColors,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      onBackgroundColor: onBackgroundColor ?? _onBackgroundColor,
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
        other._headingColor == _headingColor &&
        other._inputColor == _inputColor &&
        other._disabledColor == _disabledColor &&
        other._iconColor == _iconColor &&
        other._selectedColor == _selectedColor &&
        other._accentColor == _accentColor &&
        other._negativeColor == _negativeColor &&
        other._panelColor == _panelColor &&
        other._panelBorderColor == _panelBorderColor &&
        other._onBackgroundColor == _onBackgroundColor &&
        other.backgroundGradient == backgroundGradient &&
        listEquals(other._chartColors, _chartColors) &&
        other.successColor == successColor &&
        other.warningColor == warningColor &&
        other.errorColor == errorColor &&
        other.infoColor == infoColor &&
        other.fontFamily == fontFamily &&
        other.baseFontSize == baseFontSize &&
        other.baseSpacing == baseSpacing;
  }

  @override
  int get hashCode => Object.hashAll([
    primaryColor,
    secondaryColor,
    backgroundColor,
    textColor,
    _surfaceColor,
    _mutedTextColor,
    _onPrimaryColor,
    _borderColor,
    _headingColor,
    _inputColor,
    _disabledColor,
    _iconColor,
    _selectedColor,
    _accentColor,
    _negativeColor,
    _panelColor,
    _panelBorderColor,
    Object.hashAll(_chartColors ?? const <Color>[]),
    backgroundGradient,
    _onBackgroundColor,
    successColor,
    warningColor,
    errorColor,
    infoColor,
    fontFamily,
    baseFontSize,
    baseSpacing,
  ]);
}
