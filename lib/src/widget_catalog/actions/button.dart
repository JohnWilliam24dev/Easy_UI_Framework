import 'package:flutter/material.dart';

import '../../theme_layer/theme_layer.dart';

/// Variação visual do botão.
enum ButtonVariant {
  /// Preenchido com a cor primária.
  solid,

  /// Só borda e texto na cor primária.
  outline,

  /// Só texto na cor primária, sem borda nem fundo.
  ghost,

  /// Como `solid`, mas sempre com cantos totalmente arredondados,
  /// independente do pack ativo.
  pill,
}

/// Botão de ação: Elevated/Outlined/TextButton + estado de carregamento,
/// pintado com os tokens e a "pele" do `ButtonStyleSpec` do pack ativo.
///
/// - sem [onPressed] o botão fica desabilitado;
/// - [loading] troca o texto por um indicador (mantendo o tamanho) e ignora
///   toques;
/// - [expanded] ocupa toda a largura disponível.
///
/// ```dart
/// Button(text: 'Login', variant: ButtonVariant.solid, onPressed: entrar)
/// ```
class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.text,
    this.variant = ButtonVariant.solid,
    this.onPressed,
    this.loading = false,
    this.expanded = false,
  });

  final String text;
  final ButtonVariant variant;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expanded;

  static void _ignore() {}

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);
    final spec = pack.button;

    final filled =
        variant == ButtonVariant.solid || variant == ButtonVariant.pill;
    final foreground = filled ? tokens.onPrimaryColor : tokens.primaryColor;
    final radius =
        variant == ButtonVariant.pill ? ButtonStyleSpec.pillRadius : spec.radius;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    final padding = EdgeInsets.symmetric(
      horizontal: spec.horizontalPadding * pack.spacingScale,
    );
    final minimumSize = Size(0, spec.minHeight);
    final textStyle = TextStyle(
      fontSize: tokens.baseFontSize,
      fontWeight: spec.fontWeight,
      fontFamily: tokens.fontFamily,
    );

    Widget content = Text(text);
    if (loading) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0, child: Text(text)),
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foreground,
            ),
          ),
        ],
      );
    }

    final VoidCallback? handler = loading ? _ignore : onPressed;

    final Widget button = switch (variant) {
      ButtonVariant.solid || ButtonVariant.pill => ElevatedButton(
          onPressed: handler,
          style: ElevatedButton.styleFrom(
            backgroundColor: tokens.primaryColor,
            foregroundColor: tokens.onPrimaryColor,
            disabledBackgroundColor: tokens.borderColor,
            disabledForegroundColor: tokens.mutedTextColor,
            elevation: 0,
            shape: shape,
            minimumSize: minimumSize,
            padding: padding,
            textStyle: textStyle,
          ),
          child: content,
        ),
      ButtonVariant.outline => OutlinedButton(
          onPressed: handler,
          style: OutlinedButton.styleFrom(
            foregroundColor: tokens.primaryColor,
            disabledForegroundColor: tokens.mutedTextColor,
            side: BorderSide(color: tokens.primaryColor),
            shape: shape,
            minimumSize: minimumSize,
            padding: padding,
            textStyle: textStyle,
          ),
          child: content,
        ),
      ButtonVariant.ghost => TextButton(
          onPressed: handler,
          style: TextButton.styleFrom(
            foregroundColor: tokens.primaryColor,
            disabledForegroundColor: tokens.mutedTextColor,
            shape: shape,
            minimumSize: minimumSize,
            padding: padding,
            textStyle: textStyle,
          ),
          child: content,
        ),
    };

    return expanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
