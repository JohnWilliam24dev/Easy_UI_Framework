import 'package:flutter/widgets.dart';

import 'form_controller.dart';

/// Entrega o [FormController] do `FormGroup` mais próximo.
///
/// Quem consulta não se inscreve automaticamente nas mudanças; quem precisa
/// reagir (ex: `Button(disableWhenInvalid: true)`) escuta o controller.
class FormScope extends InheritedWidget {
  const FormScope({super.key, required this.controller, required super.child});

  final FormController controller;

  static FormScope? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<FormScope>();
  }

  @override
  bool updateShouldNotify(FormScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
