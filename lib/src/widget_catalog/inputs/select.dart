import 'package:flutter/material.dart';

import '../../theme_layer/theme_layer.dart';
import 'form/form_controller.dart';
import 'form/form_scope.dart';
import 'form/validators.dart';
import 'input_decoration_builder.dart';
import 'select_option.dart';

/// Campo de seleção: DropdownButton (seleção única) ou um diálogo com
/// caixas de marcação (seleção múltipla), com a mesma decoração visual do
/// `InputField`.
///
/// ```dart
/// Select<String>.single(
///   options: [SelectOption('sp', 'São Paulo'), SelectOption('rj', 'Rio de Janeiro')],
///   value: estado,
///   onChanged: (v) => setState(() => estado = v),
/// )
///
/// Select<String>.multi(
///   options: [SelectOption('tela', 'Tela'), SelectOption('escultura', 'Escultura')],
///   values: tecnicas,
///   onChanged: (v) => setState(() => tecnicas = v),
/// )
/// ```
class Select<T> extends StatefulWidget {
  /// Seleção única: [value] é o selecionado (ou `null`) e [onChanged]
  /// recebe o novo valor.
  const Select.single({
    super.key,
    required this.options,
    this.value,
    required ValueChanged<T?> onChanged,
    this.hint,
    this.label,
    this.name,
    this.validation = const <Validator>[],
    this.enabled = true,
  }) : _isMulti = false,
       _onSingleChanged = onChanged,
       values = const [],
       _onMultiChanged = null;

  /// Seleção múltipla: [values] são os selecionados e [onChanged] recebe a
  /// nova lista.
  const Select.multi({
    super.key,
    required this.options,
    this.values = const [],
    required ValueChanged<List<T>> onChanged,
    this.hint,
    this.label,
    this.name,
    this.validation = const <Validator>[],
    this.enabled = true,
  }) : _isMulti = true,
       _onMultiChanged = onChanged,
       value = null,
       _onSingleChanged = null;

  final List<SelectOption<T>> options;
  final T? value;
  final List<T> values;
  final String? hint;
  final String? label;

  /// Nome do campo dentro de um [FormGroup].
  final String? name;
  final List<Validator> validation;
  final bool enabled;

  final bool _isMulti;
  final ValueChanged<T?>? _onSingleChanged;
  final ValueChanged<List<T>>? _onMultiChanged;

  @override
  State<Select<T>> createState() => _SelectState<T>();
}

class _SelectState<T> extends State<Select<T>>
    implements FormFieldHandle<Object?> {
  late T? _singleValue = widget.value;
  late List<T> _multiValues = List<T>.of(widget.values);
  final FocusNode _focusNode = FocusNode();
  FormController? _form;
  String? _registeredName;
  bool _touched = false;
  bool _revealed = false;

  String _labelFor(T value) =>
      widget.options.firstWhere((option) => option.value == value).label;

  @override
  String get name => _registeredName!;

  @override
  Object? get value =>
      widget._isMulti ? List<T>.unmodifiable(_multiValues) : _singleValue;

  @override
  List<Validator> get validation => widget.validation;

  @override
  FocusNode get focusNode => _focusNode;

  @override
  void reset(Object? value) {
    setState(() {
      if (widget._isMulti) {
        _multiValues = value is Iterable<T>
            ? List<T>.of(value)
            : List<T>.of(widget.values);
      } else {
        _singleValue = value is T ? value : widget.value;
      }
      _touched = false;
      _revealed = false;
    });
  }

  @override
  void reveal() {
    if (mounted) setState(() => _revealed = true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncForm();
  }

  @override
  void didUpdateWidget(Select<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name) {
      _detachFromForm();
      _syncForm();
    }
    if (!_hasFormInitialValue) {
      _singleValue = widget.value;
      _multiValues = List<T>.of(widget.values);
    }
  }

  bool get _hasFormInitialValue =>
      _form != null &&
      widget.name != null &&
      _form!.hasInitialValueFor(widget.name!);

  void _syncForm() {
    final controller = FormScope.maybeOf(context)?.controller;
    if (identical(controller, _form)) return;
    _detachFromForm();
    _form = controller;
    if (controller == null) return;
    if (widget.name == null && widget.validation.isNotEmpty) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError(
            'Dentro de um FormGroup, todo Select com validation precisa de name.',
          ),
          library: 'easy_ui',
        ),
      );
    }
    if (widget.name != null) {
      _registeredName = widget.name;
      if (controller.hasInitialValueFor(widget.name!)) {
        final initial = controller.initialValueFor(widget.name!);
        if (widget._isMulti && initial is Iterable<T>) {
          _multiValues = List<T>.of(initial);
        } else if (!widget._isMulti && initial is T) {
          _singleValue = initial;
        }
      }
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

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  void _setSingle(T? next) {
    setState(() {
      _singleValue = next;
      _touched = true;
    });
    widget._onSingleChanged?.call(next);
    _form?.fieldChanged();
  }

  void _setMulti(List<T> next) {
    setState(() {
      _multiValues = next;
      _touched = true;
    });
    widget._onMultiChanged?.call(next);
    _form?.fieldChanged();
  }

  Future<void> _openMultiPicker(
    BuildContext context,
    ThemeTokens tokens,
  ) async {
    final selecao = Set<T>.of(_multiValues);
    final resultado = await showDialog<Set<T>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return SimpleDialog(
              backgroundColor: tokens.surfaceColor,
              children: [
                for (final option in widget.options)
                  CheckboxListTile(
                    value: selecao.contains(option.value),
                    title: Text(
                      option.label,
                      style: TextStyle(color: tokens.textColor),
                    ),
                    activeColor: tokens.primaryColor,
                    onChanged: (marcado) {
                      setState(() {
                        if (marcado ?? false) {
                          selecao.add(option.value);
                        } else {
                          selecao.remove(option.value);
                        }
                      });
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(selecao),
                      child: Text(
                        'OK',
                        style: TextStyle(color: tokens.primaryColor),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    if (resultado != null) {
      _setMulti(
        widget.options.map((o) => o.value).where(resultado.contains).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);
    final decoration = buildInputDecoration(
      tokens: tokens,
      pack: pack,
      hint: widget.hint,
      label: widget.label,
      errorText: (_touched || _revealed)
          ? runValidators(
              widget.validation,
              value,
              _form?.values ?? const FormValues(<String, Object?>{}),
            )
          : null,
    );
    final textStyle = TextStyle(
      color: tokens.textColor,
      fontSize: tokens.baseFontSize,
      fontFamily: tokens.fontFamily,
    );

    if (widget._isMulti) {
      final isEmptyState = _multiValues.isEmpty;
      return Focus(
        focusNode: _focusNode,
        child: InkWell(
          onTap: widget.enabled
              ? () => _openMultiPicker(context, tokens)
              : null,
          child: InputDecorator(
            decoration: decoration,
            isEmpty: isEmptyState,
            // Quando vazio, o próprio InputDecorator já desenha o hintText da
            // decoration; não repita o texto aqui, ou ele aparece em dobro.
            child: isEmptyState
                ? const SizedBox.shrink()
                : Text(
                    _multiValues.map(_labelFor).join(', '),
                    style: textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),
      );
    }

    return DropdownButtonFormField<T>(
      // A chave recria apenas o estado interno do FormField quando o valor é
      // alterado pelo FormGroup (por exemplo, em reset), sem usar a API
      // `value`, descontinuada pelo Flutter.
      key: ValueKey<T?>(_singleValue),
      initialValue: _singleValue,
      isExpanded: true,
      decoration: decoration,
      dropdownColor: tokens.surfaceColor,
      style: textStyle,
      iconEnabledColor: tokens.mutedTextColor,
      focusNode: _focusNode,
      onChanged: widget.enabled ? _setSingle : null,
      items: [
        for (final option in widget.options)
          DropdownMenuItem(value: option.value, child: Text(option.label)),
      ],
    );
  }

  @override
  void dispose() {
    _detachFromForm();
    _focusNode.dispose();
    super.dispose();
  }
}
