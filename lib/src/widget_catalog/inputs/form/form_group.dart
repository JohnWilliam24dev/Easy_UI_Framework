import 'package:flutter/widgets.dart';

import '../../../kernel/kernel.dart';
import '../../layout/div.dart';
import 'form_controller.dart';
import 'form_scope.dart';

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
    this.width,
    this.height,
  })  : assert(gap is! Fr, 'gap não pode ser Fr.'),
        assert(width is! Fr, 'width não pode ser Fr.'),
        assert(height is! Fr, 'height não pode ser Fr.');

  final List<Widget> children;
  final LayoutDirection direction;
  final LayoutPosition? position;
  final Alignment align;
  final Dimension? gap;
  final Dimension? width;
  final Dimension? height;

  @override
  State<FormGroup> createState() => _FormGroupState();
}

class _FormGroupState extends State<FormGroup> {
  final FormController _controller = FormController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormScope(
      controller: _controller,
      child: Div(
        direction: widget.direction,
        position: widget.position,
        align: widget.align,
        gap: widget.gap,
        width: widget.width,
        height: widget.height,
        children: widget.children,
      ),
    );
  }
}
