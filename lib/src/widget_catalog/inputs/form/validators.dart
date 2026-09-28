/// Valores atuais de um formulário, por `name` de campo.
typedef FormValues = Map<String, String>;

/// Regra de validação: recebe o valor do campo e os valores de todos os
/// campos do formulário; devolve a mensagem de erro, ou `null` se é válido.
typedef Validator = String? Function(String value, FormValues all);

/// Roda os [validators] em ordem e devolve a primeira mensagem de erro.
String? runValidators(
  List<Validator> validators,
  String value,
  FormValues all,
) {
  for (final validator in validators) {
    final message = validator(value, all);
    if (message != null) return message;
  }
  return null;
}

// Convenção: todos os validadores, exceto [isRequired], consideram um valor
// vazio como válido. Assim um campo opcional com `isEmail()` só reclama se o
// usuário digitar algo inválido; para exigir preenchimento, use `isRequired()`.

/// Exige um valor não vazio (espaços não contam).
Validator isRequired({String message = 'Campo obrigatório'}) {
  return (value, _) => value.trim().isEmpty ? message : null;
}

/// Exige pelo menos [min] caracteres.
Validator minLength(int min, {String? message}) {
  return (value, _) {
    if (value.isEmpty) return null;
    return value.length >= min
        ? null
        : (message ?? 'Use pelo menos $min caracteres');
  };
}

/// Aceita no máximo [max] caracteres.
Validator maxLength(int max, {String? message}) {
  return (value, _) {
    if (value.isEmpty) return null;
    return value.length <= max
        ? null
        : (message ?? 'Use no máximo $max caracteres');
  };
}

/// Exige entre [min] e [max] caracteres (como o `@Length` do NestJS).
Validator lengthBetween(int min, int max, {String? message}) {
  assert(min <= max, 'min deve ser <= max.');
  return (value, _) {
    if (value.isEmpty) return null;
    final ok = value.length >= min && value.length <= max;
    return ok ? null : (message ?? 'Use entre $min e $max caracteres');
  };
}

final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Exige um e-mail em formato válido.
Validator isEmail({String message = 'E-mail inválido'}) {
  return (value, _) {
    if (value.isEmpty) return null;
    return _emailPattern.hasMatch(value) ? null : message;
  };
}

/// Regras de senha. Por padrão exige apenas [min] caracteres; ative os
/// requisitos que quiser. Sem [message], a mensagem lista o que falta.
Validator isPassword({
  int min = 8,
  bool requireUppercase = false,
  bool requireLowercase = false,
  bool requireDigit = false,
  bool requireSymbol = false,
  String? message,
}) {
  final requisitos = <String>[
    '$min ou mais caracteres',
    if (requireUppercase) 'letra maiúscula',
    if (requireLowercase) 'letra minúscula',
    if (requireDigit) 'número',
    if (requireSymbol) 'símbolo',
  ];
  final padrao = 'A senha precisa ter ${requisitos.join(', ')}';

  final upper = RegExp(r'\p{Lu}', unicode: true);
  final lower = RegExp(r'\p{Ll}', unicode: true);
  final digit = RegExp(r'\d');
  final symbol = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);

  return (value, _) {
    if (value.isEmpty) return null;
    final ok = value.length >= min &&
        (!requireUppercase || upper.hasMatch(value)) &&
        (!requireLowercase || lower.hasMatch(value)) &&
        (!requireDigit || digit.hasMatch(value)) &&
        (!requireSymbol || symbol.hasMatch(value));
    return ok ? null : (message ?? padrao);
  };
}

/// Exige que o valor case com [pattern].
Validator matches(RegExp pattern, {String message = 'Formato inválido'}) {
  return (value, _) {
    if (value.isEmpty) return null;
    return pattern.hasMatch(value) ? null : message;
  };
}

/// Exige que o valor seja igual ao do campo [field] do mesmo `FormGroup`
/// (ex: confirmação de senha). Se o campo não existir, o validador falha,
/// para que um nome digitado errado apareça logo em vez de passar calado.
Validator sameAs(String field, {String message = 'Os valores não conferem'}) {
  return (value, all) {
    if (value.isEmpty) return null;
    return value == all[field] ? null : message;
  };
}
