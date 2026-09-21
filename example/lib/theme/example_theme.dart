import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' show Color;

/// Paleta do app de exemplo, definida explicitamente (claro e escuro).
const AppTheme exampleTheme = AppTheme(
  light: ThemeTokens(
    primaryColor: Color(0xFF2196F3),
    secondaryColor: Color(0xFF00BFA5),
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xDD000000),
  ),
  dark: ThemeTokens(
    primaryColor: Color(0xFF90CAF9),
    secondaryColor: Color(0xFF64FFDA),
    backgroundColor: Color(0xFF121212),
    textColor: Color(0xFFFFFFFF),
    onPrimaryColor: Color(0xFF000000),
  ),
);
