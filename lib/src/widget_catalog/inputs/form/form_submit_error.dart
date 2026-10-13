import 'package:flutter/widgets.dart';

import '../../display/label.dart';
import 'form_controller.dart';
import 'form_scope.dart';

/// Mostra, dentro do `FormGroup`, a mensagem da última falha de envio.
/// Usado por `Modal.form`, onde um Toast ficaria atrás da barreira escura.
class FormSubmitError extends StatefulWidget {
  const FormSubmitError({super.key});

  @override
  State<FormSubmitError> createState() => _FormSubmitErrorState();
}

class _FormSubmitErrorState extends State<FormSubmitError> {
  FormController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = FormScope.maybeOf(context)?.controller
      ?..registerErrorSink();
  }

  @override
  void dispose() {
    _controller?.unregisterErrorSink();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final message = controller.submitError;
        if (message == null) return const SizedBox.shrink();
        return Label(type: LabelType.error, text: message);
      },
    );
  }
}
