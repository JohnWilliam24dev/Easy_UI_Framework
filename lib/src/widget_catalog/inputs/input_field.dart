import 'package:flutter/material.dart';

import '../../theme_layer/theme_layer.dart';
import 'form/form_controller.dart';
import 'form/form_scope.dart';
import 'form/validators.dart';
import 'input_decoration_builder.dart';

/// Natureza do dado digitado; define teclado e comportamento.
enum InputType { text, email, password, number, phone, search }

/// Campo de entrada: TextField + InputDecoration, pintado com os tokens e a
/// aparência do `StylePack` ativo (outline, rounded, underline, filled).
///
/// - `password` esconde o texto e ganha o botão de mostrar/ocultar;
/// - `search` ganha o ícone de lupa;
/// - [validation] é a lista de regras (`isRequired()`, `minLength(4)`,
///   `isEmail()`...), avaliadas em ordem; a primeira que falhar mostra a
///   mensagem. O erro só aparece depois que o usuário digita ou tenta enviar
///   o formulário;
/// - [name] identifica o campo dentro de um `FormGroup` (obrigatório se o
///   campo tiver [validation] ou se você quiser o valor em `onSubmit`);
/// - [errorText], se informado, tem prioridade sobre a validação (útil para
///   erros vindos do servidor).
///
/// Máscara entra em uma próxima etapa.
///
/// ```dart
/// InputField(name: 'username', hint: 'Username', validation: [isRequired(), minLength(4)])
/// ```
class InputField extends StatefulWidget {
  const InputField({
    super.key,
    this.name,
    this.hint,
    this.type = InputType.text,
    this.validation = const <Validator>[],
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
  });

  final String? name;
  final String? hint;
  final InputType type;
  final List<Validator> validation;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> implements FormFieldHandle {
  bool _obscured = true;
  bool _touched = false;
  bool _revealed = false;

  TextEditingController? _ownController;
  final FocusNode _focusNode = FocusNode();

  FormController? _form;
  String? _registeredName;

  TextEditingController get _controller {
    return widget.controller ?? (_ownController ??= TextEditingController());
  }

  // ---- FormFieldHandle ----------------------------------------------------

  @override
  String get name => _registeredName!;

  @override
  String get value => _controller.text;

  @override
  List<Validator> get validation => widget.validation;

  @override
  FocusNode get focusNode => _focusNode;

  @override
  void reveal() {
    if (mounted) setState(() => _revealed = true);
  }

  // ---- ligação com o FormGroup ---------------------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncForm();
  }

  @override
  void didUpdateWidget(InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name) {
      _detachFromForm();
      _syncForm();
    }
  }

  void _syncForm() {
    final controller = FormScope.maybeOf(context)?.controller;
    if (identical(controller, _form)) return;

    _detachFromForm();
    _form = controller;
    if (controller == null) return;

    assert(
      widget.name != null || widget.validation.isEmpty,
      'Dentro de um FormGroup, todo InputField com validation precisa de name.',
    );
    if (widget.name != null) {
      _registeredName = widget.name;
      controller.attach(this);
      controller.addListener(_onFormChanged);
    }
  }

  void _detachFromForm() {
    final form = _form;
    if (form == null) return;
    if (_registeredName != null) {
      form.removeListener(_onFormChanged);
      form.detach(this);
      _registeredName = null;
    }
    _form = null;
  }

  // Outro campo mudou (ou entrou/saiu): revalida, pois regras como `sameAs`
  // dependem dos demais valores.
  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  void _handleChanged(String value) {
    setState(() => _touched = true);
    widget.onChanged?.call(value);
    _form?.fieldChanged();
  }

  @override
  void dispose() {
    _detachFromForm();
    _focusNode.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  // ---- construção -----------------------------------------------------------

  String? _currentError() {
    if (widget.validation.isEmpty) return null;
    final all = _form?.values ?? const <String, String>{};
    return runValidators(widget.validation, _controller.text, all);
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
        ((_touched || _revealed) ? _currentError() : null);

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
      controller: _controller,
      focusNode: _focusNode,
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
