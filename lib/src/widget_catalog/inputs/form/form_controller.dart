import 'package:flutter/widgets.dart';

import 'validators.dart';

/// O que o [FormController] precisa saber de cada campo registrado.
/// Implementado pelo estado do `InputField`.
abstract interface class FormFieldHandle {
  String get name;
  String get value;
  List<Validator> get validation;
  FocusNode get focusNode;

  /// Passa a exibir os erros deste campo (mesmo que o usuário não o tenha
  /// tocado).
  void reveal();
}

/// Estado compartilhado de um `FormGroup` (uso interno do framework).
///
/// Os `InputField`s com `name` se registram aqui ao entrar na árvore e saem
/// ao serem removidos; o `Button` com `onSubmit` consulta e valida.
class FormController extends ChangeNotifier {
  final Map<String, FormFieldHandle> _fields = <String, FormFieldHandle>{};
  bool _disposed = false;

  /// Valores atuais, por `name`.
  FormValues get values {
    return Map<String, String>.unmodifiable(<String, String>{
      for (final field in _fields.values) field.name: field.value,
    });
  }

  /// `true` se todos os campos passam nas suas validações. Não revela erros.
  bool get isValid {
    final all = values;
    return _fields.values.every(
      (field) => runValidators(field.validation, field.value, all) == null,
    );
  }

  /// Revela os erros de todos os campos, foca o primeiro inválido e devolve
  /// se o formulário está válido. Chame em resposta a um evento (nunca
  /// durante o `build`).
  bool validate() {
    final all = values;
    FormFieldHandle? firstInvalid;
    for (final field in _fields.values) {
      field.reveal();
      if (firstInvalid == null &&
          runValidators(field.validation, field.value, all) != null) {
        firstInvalid = field;
      }
    }
    firstInvalid?.focusNode.requestFocus();
    return firstInvalid == null;
  }

  void attach(FormFieldHandle field) {
    if (_fields.containsKey(field.name)) {
      // Um `throw` síncrono aqui aconteceria no meio de
      // `didChangeDependencies`/build do segundo campo, deixando a árvore de
      // widgets pela metade (o primeiro campo já montado, com FocusNode e
      // dependências de InheritedWidget ativas) — o Flutter não lida bem com
      // isso e o teardown do teste quebra com um erro interno não
      // relacionado. `reportError` avisa (aparece via `tester.takeException`)
      // sem interromper o frame atual: o segundo campo simplesmente não
      // participa da validação do formulário.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError(
            'Já existe um InputField com name "${field.name}" neste FormGroup.',
          ),
          library: 'easy_ui',
        ),
      );
      return;
    }
    _fields[field.name] = field;
    _notifyAfterFrame();
  }

  void detach(FormFieldHandle field) {
    if (identical(_fields[field.name], field)) {
      _fields.remove(field.name);
    }
    _notifyAfterFrame();
  }

  /// Um campo mudou de valor (chamado a partir de um evento do usuário).
  void fieldChanged() => notifyListeners();

  // Entrar/sair da árvore acontece durante o build: avisar os ouvintes só
  // depois do frame evita chamar setState no meio da construção.
  void _notifyAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
