import 'package:flutter/material.dart';

import '../../theme_layer/theme_layer.dart';
import 'input_decoration_builder.dart';

/// Natureza do dado digitado; define teclado e comportamento.
enum InputType { text, email, password, number, phone, search }

/// Campo de entrada: TextField + InputDecoration, pintado com os tokens e a
/// aparência do `StylePack` ativo (outline, rounded, underline, filled).
///
/// - `password` esconde o texto e ganha o botão de mostrar/ocultar;
/// - `search` ganha o ícone de lupa;
/// - [validator] devolve a mensagem de erro (ou `null` se o valor é válido).
///   O erro só aparece depois que o usuário começa a digitar, para não
///   "acusar" um campo que ainda não foi tocado;
/// - [errorText], se informado, tem prioridade sobre o [validator] (útil para
///   erros vindos do servidor).
///
/// Máscara entra em uma próxima etapa.
///
/// ```dart
/// InputField(hint: 'Username', type: InputType.text)
/// ```
class InputField extends StatefulWidget {
  const InputField({
    super.key,
    this.hint,
    this.type = InputType.text,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
  });

  final String? hint;
  final InputType type;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final String? Function(String value)? validator;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _obscured = true;
  bool _touched = false;
  String _value = '';

  String get _currentValue => widget.controller?.text ?? _value;

  void _handleChanged(String value) {
    setState(() {
      _touched = true;
      _value = value;
    });
    widget.onChanged?.call(value);
  }

  static TextInputType _keyboardFor(InputType type) {
    return switch (type) {
      InputType.text => TextInputType.text,
      InputType.email => TextInputType.emailAddress,
      InputType.password => TextInputType.visiblePassword,
      InputType.number => const TextInputType.numberWithOptions(decimal: true),
      InputType.phone => TextInputType.phone,
      InputType.search => TextInputType.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);
    final type = widget.type;

    final error = widget.errorText ??
        (_touched ? widget.validator?.call(_currentValue) : null);

    final isPassword = type == InputType.password;
    final isFreeText = type == InputType.text || type == InputType.search;

    Widget? prefix;
    Widget? suffix;
    if (type == InputType.search) {
      prefix = Icon(Icons.search, color: tokens.mutedTextColor);
    }
    if (isPassword) {
      suffix = IconButton(
        icon: Icon(
          _obscured ? Icons.visibility : Icons.visibility_off,
          color: tokens.mutedTextColor,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    }

    Widget field = TextField(
      controller: widget.controller,
      onChanged: _handleChanged,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscureText: isPassword && _obscured,
      keyboardType: _keyboardFor(type),
      textInputAction: widget.textInputAction ??
          (type == InputType.search ? TextInputAction.search : null),
      autocorrect: isFreeText,
      enableSuggestions: isFreeText,
      cursorColor: tokens.primaryColor,
      style: TextStyle(
        color: tokens.textColor,
        fontSize: tokens.baseFontSize,
        fontFamily: tokens.fontFamily,
      ),
      decoration: buildInputDecoration(
        tokens: tokens,
        pack: pack,
        hint: widget.hint,
        errorText: error,
        prefixIcon: prefix,
        suffixIcon: suffix,
      ),
    );

    final elevation = pack.inputText.elevation;
    if (elevation != ElevationLevel.none) {
      field = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(pack.inputText.radius),
          boxShadow: [
            BoxShadow(
              color: tokens.textColor.withValues(alpha: 0.12),
              blurRadius: elevation.dp * 2,
              offset: Offset(0, elevation.dp / 2),
            ),
          ],
        ),
        child: field,
      );
    }
    return field;
  }
}
