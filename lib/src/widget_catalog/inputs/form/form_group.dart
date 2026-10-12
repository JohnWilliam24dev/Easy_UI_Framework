import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../kernel/kernel.dart';
import '../../layout/div.dart';
import 'form_controller.dart';
import 'form_scope.dart';
import 'validators.dart' show FormValues;

/// Agrupa campos para validação conjunta: um `Div` que também é um
/// formulário.
///
/// Os `InputField`s com `name` dentro dele se registram sozinhos, e um
/// `Button` com `onSubmit` valida todos de uma vez. A tela não precisa de
/// estado, controllers nem `onChanged`.
///
/// ```dart
/// FormGroup(
///   position: LayoutPosition.center,
///   width: 50.vw,
///   children: [
///     InputField(name: 'email', validation: [isRequired(), isEmail()]),
///     Button(text: 'Entrar', onSubmit: (values) => entrar(values['email']!)),
///   ],
/// )
/// ```
///
/// As props de layout são as mesmas do `Div`.
class FormGroup extends StatefulWidget {
  const FormGroup({
    super.key,
    this.children = const <Widget>[],
    this.direction = LayoutDirection.vertical,
    this.position,
    this.align = Alignment.topLeft,
    this.gap,
    this.runGap,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.maxHeight,
    this.padding,
    this.fill = false,
    this.scrollable = false,
    this.stackBelow,
    this.initialValues = const <String, Object?>{},
    this.onSubmit,
  }) : assert(gap is! Fr, 'gap não pode ser Fr.'),
       assert(width is! Fr, 'width não pode ser Fr.'),
       assert(height is! Fr, 'height não pode ser Fr.');

  final List<Widget> children;
  final LayoutDirectionValue direction;
  final LayoutPosition? position;
  final Alignment align;
  final Dimension? gap;
  final Dimension? runGap;
  final Dimension? width;
  final Dimension? height;
  final Dimension? minWidth;
  final Dimension? maxWidth;
  final Dimension? maxHeight;
  final Dimension? padding;
  final bool fill;
  final bool scrollable;
  final double? stackBelow;
  final Map<String, Object?> initialValues;
  final FutureOr<void> Function(FormValues values)? onSubmit;

  @override
  State<FormGroup> createState() => _FormGroupState();
}

class _FormGroupState extends State<FormGroup> {
  late final FormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FormController(initialValues: widget.initialValues);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.onSubmit = widget.onSubmit;
    final layout = LayoutProps(
      direction: widget.direction,
      position: widget.position,
      align: widget.align,
      gap: widget.gap,
      runGap: widget.runGap,
      width: widget.width,
      height: widget.height,
      minWidth: widget.minWidth,
      maxWidth: widget.maxWidth,
      maxHeight: widget.maxHeight,
      padding: widget.padding,
      fill: widget.fill,
      scrollable: widget.scrollable,
      stackBelow: widget.stackBelow,
    );
    return FormScope(
      controller: _controller,
      child: Div(
        direction: layout.direction,
        position: layout.position,
        align: layout.align,
        gap: layout.gap,
        runGap: layout.runGap,
        width: layout.width,
        height: layout.height,
        minWidth: layout.minWidth,
        maxWidth: layout.maxWidth,
        maxHeight: layout.maxHeight,
        padding: layout.padding,
        fill: layout.fill,
        scrollable: layout.scrollable,
        stackBelow: layout.stackBelow,
        children: widget.children,
      ),
    );
  }
}
