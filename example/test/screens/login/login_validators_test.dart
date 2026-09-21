import 'package:easy_ui_example/screens/login/login_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validarUsername', () {
    test('exige mais de 3 caracteres', () {
      expect(validarUsername('abc'), isNotNull);
      expect(validarUsername('abcd'), isNull);
    });

    test('espaços nas pontas não contam', () {
      expect(validarUsername('   a  '), isNotNull);
      expect(validarUsername('  abcd  '), isNull);
    });
  });

  group('validarSenha', () {
    test('exige 8 caracteres ou mais', () {
      expect(validarSenha('1234567'), isNotNull);
      expect(validarSenha('12345678'), isNull);
      expect(validarSenha('123456789'), isNull);
    });
  });
}
