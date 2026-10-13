import 'package:flutter/material.dart' show Checkbox, Radio, Switch;
import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';
import 'form/form_controller.dart';
import 'form/form_scope.dart';
import 'form/validators.dart';

/// Comportamento visual do [Toggle].
enum ToggleType { checkbox, switch_, radio }

/// Unificação de Checkbox, Switch e Radio num único widget, controlada por
/// [type]. As cores vêm sempre dos tokens.
///
/// - `checkbox` e `switch_`: [value] é o estado atual (`bool`) e
///   [onChanged] recebe o novo estado;
/// - `radio`: [value] é o valor **desta** opção, [groupValue] é o valor
///   selecionado no grupo, e [onChanged] é chamado com [value] quando esta
///   opção é escolhida. Várias opções com o mesmo tipo `T` e o mesmo
///   [groupValue] formam um grupo.
///
/// ```dart
/// Toggle(type: ToggleType.switch_, value: ativo, onChanged: (v) => ...)
/// Toggle(type: ToggleType.checkbox, value: aceito, onChanged: (v) => ...)
/// Toggle<String>(type: ToggleType.radio, value: 'pix',
///     groupValue: metodo, onChanged: (v) => ...)
/// ```
class Toggle<T> extends StatefulWidget {
  const Toggle({
    super.key,
    this.type = ToggleType.checkbox,
    required this.value,
    this.groupValue,
    required this.onChanged,
    this.enabled = true,
    this.label,
    this.description,
    this.name,
    this.validation = const <Validator>[],
  }) : assert(
         type == ToggleType.radio || value is bool,
         'checkbox e switch_ exigem value do tipo bool.',
       );

  final ToggleType type;
  final T value;

  /// Só usado quando [type] é `radio`.
  final T? groupValue;

  final ValueChanged<T>? onChanged;
  final bool enabled;
  final String? label;
  final String? description;

  /// Nome do campo dentro de um [FormGroup]. Disponível para checkbox e
  /// switch; para uma escolha exclusiva, use [Select.single].
  final String? name;
  final List<Validator> validation;

  @override
  State<Toggle<T>> createState() => _ToggleState<T>();
}

class _ToggleState<T> extends State<Toggle<T>>
    implements FormFieldHandle<Object?> {
  late T _currentValue = widget.value;
  final FocusNode _focusNode = FocusNode();
  FormController? _form;
  String? _registeredName;
  bool _touched = false;
  bool _revealed = false;

  @override
  String get name => _registeredName!;

  @override
  Object? get value => _currentValue;

  @override
  List<Validator> get validation => widget.validation;

  @override
  FocusNode get focusNode => _focusNode;

  @override
  void reset(Object? value) {
    if (value is T) {
      _currentValue = value;
    } else {
      _currentValue = widget.value;
    }
    if (mounted) {
      setState(() {
        _touched = false;
        _revealed = false;
      });
    }
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
  void didUpdateWidget(Toggle<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name) {
      _detachFromForm();
      _syncForm();
    }
    if (_form == null ||
        widget.name == null ||
        !_form!.hasInitialValueFor(widget.name!)) {
      _currentValue = widget.value;
    }
  }

  void _syncForm() {
    final controller = FormScope.maybeOf(context)?.controller;
    if (identical(controller, _form)) return;
    _detachFromForm();
    _form = controller;
    if (controller == null) return;
    if (widget.type == ToggleType.radio && widget.name != null) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError(
            'Toggle radio não pode usar name; use Select.single para uma escolha exclusiva no FormGroup.',
          ),
          library: 'easy_ui',
        ),
      );
      return;
    }
    if (widget.name == null && widget.validation.isNotEmpty) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError(
            'Dentro de um FormGroup, todo Toggle com validation precisa de name.',
          ),
          library: 'easy_ui',
        ),
      );
    }
    if (widget.name != null) {
      _registeredName = widget.name;
      final initial = controller.initialValueFor(widget.name!);
      if (controller.hasInitialValueFor(widget.name!) && initial is T) {
        _currentValue = initial;
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

  void _handleChanged(T next) {
    setState(() {
      _currentValue = next;
      _touched = true;
    });
    widget.onChanged?.call(next);
    _form?.fieldChanged();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final handler = widget.enabled ? _handleChanged : null;
    final error = (_touched || _revealed)
        ? runValidators(
            widget.validation,
            _currentValue,
            _form?.values ?? const FormValues(<String, Object?>{}),
          )
        : null;

    final control = switch (widget.type) {
      ToggleType.checkbox => Checkbox(
        value: _currentValue as bool,
        onChanged: handler == null ? null : (v) => handler(v as T),
        activeColor: tokens.primaryColor,
        checkColor: tokens.onPrimaryColor,
      ),
      ToggleType.switch_ => Switch(
        value: _currentValue as bool,
        onChanged: handler == null ? null : (v) => handler(v as T),
        activeThumbColor: tokens.onPrimaryColor,
        activeTrackColor: tokens.primaryColor,
      ),
      // `groupValue`/`onChanged` diretos no Radio foram descontinuados a
      // favor de um `RadioGroup` ancestral em versões recentes do Flutter,
      // mas o pubspec deste pacote ainda suporta SDKs anteriores a isso.
      // ignore: deprecated_member_use
      ToggleType.radio => Radio<T>(
        value: widget.value,
        // ignore: deprecated_member_use
        groupValue: widget.groupValue,
        // ignore: deprecated_member_use
        onChanged: handler == null
            ? null
            : (v) {
                if (v != null) handler(v);
              },
        activeColor: tokens.primaryColor,
      ),
    };
    Widget result = widget.label == null
        ? control
        : Row(
            children: [
              Focus(focusNode: _focusNode, child: control),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label!,
                      style: TextStyle(
                        color: widget.enabled
                            ? tokens.textColor
                            : tokens.disabledColor,
                        fontFamily: tokens.fontFamily,
                      ),
                    ),
                    if (widget.description != null)
                      Text(
                        widget.description!,
                        style: TextStyle(
                          color: tokens.mutedTextColor,
                          fontSize: tokens.baseFontSize * .85,
                          fontFamily: tokens.fontFamily,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
    if (widget.label == null) {
      result = Focus(focusNode: _focusNode, child: result);
    }
    if (error != null) {
      result = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          result,
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: Text(
              error,
              style: TextStyle(
                color: tokens.errorColor,
                fontSize: tokens.baseFontSize * .75,
                fontFamily: tokens.fontFamily,
              ),
            ),
          ),
        ],
      );
    }
    return result;
  }

  @override
  void dispose() {
    _detachFromForm();
    _focusNode.dispose();
    super.dispose();
  }
}
