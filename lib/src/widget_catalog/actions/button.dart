import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme_layer/theme_layer.dart';
import '../inputs/form/form_controller.dart';
import '../inputs/form/form_scope.dart';
import '../inputs/form/validators.dart' show FormValues;
import '../feedback/toast.dart';
import '../feedback/user_facing_exception.dart';

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

  /// Ação destrutiva, usando `errorColor` do tema.
  danger,

  /// Ação textual com semântica de link.
  link,
}

enum ButtonSize { compact, standard, large }

/// Botão de ação: Elevated/Outlined/TextButton + estado de carregamento,
/// pintado com os tokens e a "pele" do `ButtonStyleSpec` do pack ativo.
///
/// - [onPressed]: ação comum. Sem [onPressed] nem [onSubmit] o botão fica
///   desabilitado;
/// - [onSubmit]: botão de envio de formulário. Precisa estar dentro de um
///   `FormGroup`; ao clicar, valida todos os campos, mostra os erros e foca o
///   primeiro inválido. Só se tudo estiver válido chama [onSubmit] com os
///   valores. Se [onSubmit] devolver um `Future`, o botão mostra o `loading`
///   até ele terminar;
/// - [disableWhenInvalid]: com [onSubmit], deixa o botão desabilitado
///   enquanto o formulário estiver inválido (por padrão ele fica clicável e
///   mostra os erros ao clicar);
/// - [loading] troca o texto por um indicador (mantendo o tamanho) e ignora
///   toques;
/// - [expanded] ocupa toda a largura disponível.
///
/// ```dart
/// Button(text: 'Entrar', onSubmit: (values) => entrar(values['email']!))
/// Button(text: 'Cancelar', variant: ButtonVariant.outline, onPressed: voltar)
/// ```
class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.text,
    this.variant = ButtonVariant.solid,
    this.onPressed,
    this.onSubmit,
    this.disableWhenInvalid = false,
    this.loading = false,
    this.expanded = false,
    this.icon,
    this.size = ButtonSize.standard,
    this.color,
  }) : assert(
         onPressed == null || onSubmit == null,
         'Use onPressed ou onSubmit, não os dois.',
       ),
       assert(
         !disableWhenInvalid || onSubmit != null,
         'disableWhenInvalid só faz sentido junto de onSubmit.',
       );

  final String text;
  final ButtonVariant variant;
  final VoidCallback? onPressed;
  final FutureOr<void> Function(FormValues values)? onSubmit;
  final bool disableWhenInvalid;
  final bool loading;
  final bool expanded;
  final IconData? icon;
  final ButtonSize size;

  /// Cor da ação, escolhida a partir dos tokens (nunca uma cor fixa). Nas
  /// variantes preenchidas é o fundo e o conteúdo usa
  /// `ThemeTokens.onBackgroundColor`; em `outline` e `ghost` é a cor do
  /// contorno e do texto.
  final Color Function(ThemeTokens tokens)? color;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _submitting = false;

  static void _ignore() {}

  Future<void> _submit(
    FormController form,
    FutureOr<void> Function(FormValues values) onSubmit,
  ) async {
    if (_submitting) return;
    form.showSubmitError(null);
    if (!form.validate()) return;

    try {
      final Object? result = onSubmit(form.values);
      if (result is Future) {
        setState(() => _submitting = true);
        await result;
      }
    } catch (error, stack) {
      final String message;
      if (error is UserFacingException) {
        message = error.message;
      } else {
        message = 'Não foi possível concluir a ação. Tente novamente.';
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'easy_ui',
            context: ErrorDescription('ao executar o onSubmit do Button'),
          ),
        );
      }
      if (mounted) {
        if (form.hasErrorSink) {
          form.showSubmitError(message);
        } else {
          Toast.error(context, text: message);
        }
      }
    } finally {
      if (mounted && _submitting) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = FormScope.maybeOf(context)?.controller;
    final submit = widget.onSubmit ?? form?.onSubmit;
    if (submit == null) return _buildButton(context, widget.onPressed);
    if (form == null) {
      throw FlutterError(
        'Button com onSubmit precisa estar dentro de um FormGroup.\n'
        'Envolva os campos e o botão em FormGroup(children: [...]), ou use '
        'onPressed para um botão comum.',
      );
    }

    if (!widget.disableWhenInvalid) {
      return _buildButton(context, () => _submit(form, submit));
    }
    return ListenableBuilder(
      listenable: form,
      builder: (context, _) {
        return _buildButton(
          context,
          form.isValid ? () => _submit(form, submit) : null,
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, VoidCallback? onTap) {
    final text = widget.text;
    final variant = widget.variant;
    final loading = widget.loading || _submitting;
    final expanded = widget.expanded;
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);
    final spec = pack.button;

    final filled =
        variant == ButtonVariant.solid ||
        variant == ButtonVariant.pill ||
        variant == ButtonVariant.danger;
    final danger = variant == ButtonVariant.danger;
    final customBackground = widget.color?.call(tokens);
    final mainColor = customBackground ?? (danger ? tokens.errorColor : tokens.primaryColor);
    final foreground = filled
        ? (customBackground == null ? tokens.onPrimaryColor : tokens.onBackgroundColor)
        : mainColor;
    final radius = variant == ButtonVariant.pill
        ? ButtonStyleSpec.pillRadius
        : spec.radius;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    final padding = EdgeInsets.symmetric(
      horizontal: spec.horizontalPadding * pack.spacingScale,
    );
    final multiplier = switch (widget.size) {
      ButtonSize.compact => 0.82,
      ButtonSize.standard => 1.0,
      ButtonSize.large => 1.18,
    };
    final minimumSize = Size(0, spec.minHeight * multiplier);
    final textStyle = TextStyle(
      fontSize: tokens.baseFontSize,
      fontWeight: spec.fontWeight,
      fontFamily: tokens.fontFamily,
    );

    Widget content = Text(text);
    if (widget.icon != null && !loading) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: spec.iconSize, color: foreground),
          SizedBox(width: spec.iconGap),
          Text(text),
        ],
      );
    }
    if (loading) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0, child: Text(text)),
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          ),
        ],
      );
    }

    final VoidCallback? handler = loading ? _ignore : onTap;

    final Widget button = switch (variant) {
      ButtonVariant.solid ||
      ButtonVariant.pill ||
      ButtonVariant.danger => ElevatedButton(
        onPressed: handler,
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
          foregroundColor: foreground,
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
          foregroundColor: mainColor,
          disabledForegroundColor: tokens.mutedTextColor,
          side: BorderSide(color: mainColor),
          shape: shape,
          minimumSize: minimumSize,
          padding: padding,
          textStyle: textStyle,
        ),
        child: content,
      ),
      ButtonVariant.ghost || ButtonVariant.link => TextButton(
        onPressed: handler,
        style: TextButton.styleFrom(
          foregroundColor: mainColor,
          disabledForegroundColor: tokens.mutedTextColor,
          shape: shape,
          minimumSize: minimumSize,
          padding: padding,
          textStyle: textStyle,
        ),
        child: variant == ButtonVariant.link
            ? DefaultTextStyle.merge(
                style: const TextStyle(decoration: TextDecoration.underline),
                child: content,
              )
            : content,
      ),
    };

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
