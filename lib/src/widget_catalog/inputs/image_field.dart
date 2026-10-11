import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../theme_layer/theme_layer.dart';
import '../display/picture.dart';
import 'form/form_controller.dart';
import 'form/form_scope.dart';
import 'form/validators.dart';
import 'input_decoration_builder.dart';

/// Escolhe uma imagem e devolve seus bytes. O aplicativo decide qual plugin
/// ou origem usar, mantendo o EasyUI independente de plataformas.
typedef ImagePickerCallback = Future<Uint8List?> Function();

/// Campo de imagem com seleção, prévia e integração com [FormGroup].
class ImageField extends StatefulWidget {
  const ImageField({
    super.key,
    this.name,
    this.label,
    this.hint = 'Toque para selecionar uma imagem',
    this.changeLabel = 'Toque para trocar a imagem',
    this.initialValue,
    this.onPick,
    this.onChanged,
    this.validation = const <Validator>[],
    this.enabled = true,
  });

  final String? name;
  final String? label;
  final String hint;
  final String changeLabel;
  final Uint8List? initialValue;
  final ImagePickerCallback? onPick;
  final ValueChanged<Uint8List?>? onChanged;
  final List<Validator> validation;
  final bool enabled;

  @override
  State<ImageField> createState() => _ImageFieldState();
}

class _ImageFieldState extends State<ImageField>
    implements FormFieldHandle<Object?> {
  Uint8List? _value;
  final FocusNode _focusNode = FocusNode();
  FormController? _form;
  String? _registeredName;
  bool _touched = false;
  bool _revealed = false;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  String get name => _registeredName!;
  @override
  Object? get value => _value;
  @override
  List<Validator> get validation => widget.validation;
  @override
  FocusNode get focusNode => _focusNode;

  @override
  void reset(Object? value) {
    setState(() {
      _value = value is Uint8List ? value : widget.initialValue;
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
            'Dentro de um FormGroup, todo ImageField com validation precisa de name.',
          ),
          library: 'easy_ui',
        ),
      );
    }
    if (widget.name != null) {
      _registeredName = widget.name;
      final initial = controller.initialValueFor(widget.name!);
      if (controller.hasInitialValueFor(widget.name!) && initial is Uint8List) {
        _value = initial;
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

  Future<void> _pick() async {
    final picker = widget.onPick;
    if (!widget.enabled || picker == null || _picking) return;
    setState(() => _picking = true);
    try {
      final image = await picker();
      if (!mounted || image == null) return;
      setState(() {
        _value = image;
        _touched = true;
      });
      widget.onChanged?.call(image);
      _form?.fieldChanged();
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);
    final error = (_touched || _revealed)
        ? runValidators(
            widget.validation,
            _value,
            _form?.values ?? const FormValues(<String, Object?>{}),
          )
        : null;
    final decoration = buildInputDecoration(
      tokens: tokens,
      pack: pack,
      label: widget.label,
      errorText: error,
    );
    return Focus(
      focusNode: _focusNode,
      child: InkWell(
        onTap: widget.onPick == null ? null : _pick,
        child: InputDecorator(
          decoration: decoration,
          child: SizedBox(
            height: 144,
            child: _picking
                ? const Center(child: CircularProgressIndicator())
                : _value == null
                ? Center(
                    child: Text(
                      widget.hint,
                      style: TextStyle(
                        color: tokens.mutedTextColor,
                        fontFamily: tokens.fontFamily,
                      ),
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Picture(bytes: _value, radius: pack.inputText.radius),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ColoredBox(
                          color: tokens.surfaceColor.withValues(alpha: .88),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              widget.changeLabel,
                              style: TextStyle(
                                color: tokens.textColor,
                                fontFamily: tokens.fontFamily,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _detachFromForm();
    _focusNode.dispose();
    super.dispose();
  }
}
