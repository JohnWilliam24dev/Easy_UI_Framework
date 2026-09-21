/// Regras de validação do login. Devolvem a mensagem de erro, ou `null`
/// quando o valor é válido.
String? validarUsername(String valor) {
  return valor.trim().length > 3 ? null : 'Use mais de 3 caracteres';
}

String? validarSenha(String valor) {
  return valor.length >= 8 ? null : 'A senha precisa de 8 caracteres ou mais';
}
