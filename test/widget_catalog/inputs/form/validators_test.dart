import 'package:easy_ui/src/widget_catalog/inputs/form/validators.dart';
import 'package:flutter_test/flutter_test.dart' hide matches;

const FormValues _nada = <String, String>{};

void main() {
  group('isRequired', () {
    test('rejeita vazio e só espaços', () {
      expect(isRequired()('', _nada), 'Campo obrigatório');
      expect(isRequired()('   ', _nada), 'Campo obrigatório');
    });

    test('aceita qualquer valor preenchido', () {
      expect(isRequired()('a', _nada), isNull);
    });

    test('aceita mensagem própria', () {
      expect(isRequired(message: 'Informe o nome')('', _nada), 'Informe o nome');
    });
  });

  group('minLength / maxLength / lengthBetween', () {
    test('minLength exige o mínimo e mostra a mensagem padrão', () {
      expect(minLength(4)('abc', _nada), 'Use pelo menos 4 caracteres');
      expect(minLength(4)('abcd', _nada), isNull);
    });

    test('maxLength limita o tamanho', () {
      expect(maxLength(3)('abcd', _nada), 'Use no máximo 3 caracteres');
      expect(maxLength(3)('abc', _nada), isNull);
    });

    test('lengthBetween aceita apenas a faixa', () {
      final v = lengthBetween(2, 4);
      expect(v('a', _nada), 'Use entre 2 e 4 caracteres');
      expect(v('ab', _nada), isNull);
      expect(v('abcd', _nada), isNull);
      expect(v('abcde', _nada), 'Use entre 2 e 4 caracteres');
    });

    test('valor vazio é considerado válido (use isRequired)', () {
      expect(minLength(4)('', _nada), isNull);
      expect(maxLength(3)('', _nada), isNull);
      expect(lengthBetween(2, 4)('', _nada), isNull);
    });

    test('mensagem própria', () {
      expect(minLength(4, message: 'Curto demais')('a', _nada), 'Curto demais');
    });
  });

  group('isEmail', () {
    test('aceita e-mails comuns', () {
      expect(isEmail()('maria@exemplo.com', _nada), isNull);
      expect(isEmail()('maria.silva+ateliê@ex.com.br', _nada), isNull);
    });

    test('rejeita formatos inválidos', () {
      for (final invalido in ['maria', 'maria@', '@exemplo.com', 'a@b', 'a b@c.com']) {
        expect(isEmail()(invalido, _nada), 'E-mail inválido', reason: invalido);
      }
    });

    test('vazio é válido', () {
      expect(isEmail()('', _nada), isNull);
    });
  });

  group('isPassword', () {
    test('por padrão exige só o tamanho mínimo', () {
      expect(isPassword()('1234567', _nada),
          'A senha precisa ter 8 ou mais caracteres');
      expect(isPassword()('12345678', _nada), isNull);
    });

    test('requisitos opcionais', () {
      final v = isPassword(
        min: 6,
        requireUppercase: true,
        requireLowercase: true,
        requireDigit: true,
        requireSymbol: true,
      );
      expect(v('abcdef', _nada), isNotNull);
      expect(v('Abcdef', _nada), isNotNull);
      expect(v('Abcde1', _nada), isNotNull);
      expect(v('Abcd1!', _nada), isNull);
    });

    test('a mensagem padrão lista os requisitos ativos', () {
      final mensagem = isPassword(requireDigit: true)('abcdefgh', _nada);
      expect(mensagem, 'A senha precisa ter 8 ou mais caracteres, número');
    });

    test('reconhece maiúsculas acentuadas', () {
      expect(isPassword(min: 3, requireUppercase: true)('Ábc', _nada), isNull);
    });

    test('mensagem própria e vazio válido', () {
      expect(isPassword(message: 'Senha fraca')('123', _nada), 'Senha fraca');
      expect(isPassword()('', _nada), isNull);
    });
  });

  group('matches', () {
    final cep = RegExp(r'^\d{5}-?\d{3}$');

    test('valida contra a expressão', () {
      expect(matches(cep)('40000-000', _nada), isNull);
      expect(matches(cep)('abc', _nada), 'Formato inválido');
      expect(matches(cep, message: 'CEP inválido')('abc', _nada), 'CEP inválido');
    });

    test('vazio é válido', () {
      expect(matches(cep)('', _nada), isNull);
    });
  });

  group('sameAs', () {
    test('compara com o outro campo', () {
      const all = {'password': 'segredo123'};
      expect(sameAs('password')('segredo123', all), isNull);
      expect(sameAs('password')('outro', all), 'Os valores não conferem');
    });

    test('campo inexistente falha em vez de passar calado', () {
      expect(sameAs('password')('x', _nada), isNotNull);
    });

    test('vazio é válido', () {
      expect(sameAs('password')('', const {'password': 'abc'}), isNull);
    });
  });

  group('runValidators', () {
    test('devolve a primeira mensagem de erro, na ordem', () {
      final mensagem = runValidators(
        [isRequired(), minLength(4), isEmail()],
        'ab',
        _nada,
      );
      expect(mensagem, 'Use pelo menos 4 caracteres');
    });

    test('vazio dispara só o isRequired', () {
      expect(
        runValidators([isRequired(), minLength(4)], '', _nada),
        'Campo obrigatório',
      );
    });

    test('lista vazia ou tudo válido devolve null', () {
      expect(runValidators(const [], 'x', _nada), isNull);
      expect(runValidators([isRequired(), minLength(1)], 'x', _nada), isNull);
    });
  });
}
