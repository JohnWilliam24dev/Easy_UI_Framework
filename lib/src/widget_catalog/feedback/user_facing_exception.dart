/// Falha com mensagem própria para o usuário (ex.: regra de negócio).
///
/// Lançada em `Button(onSubmit:)`, `Modal.form` ou `optimistic`, a [message]
/// é exibida como está e a exceção não é reportada como erro do app. Qualquer
/// outra exceção mostra uma mensagem genérica e vai para
/// `FlutterError.reportError`.
class UserFacingException implements Exception {
  const UserFacingException(this.message);

  final String message;

  @override
  String toString() => 'UserFacingException: $message';
}
