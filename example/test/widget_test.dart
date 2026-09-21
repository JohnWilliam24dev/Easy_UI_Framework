import 'package:easy_ui/easy_ui.dart';
import 'package:easy_ui_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> preencher(
  WidgetTester tester, {
  required String username,
  required String password,
}) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), username);
  await tester.enterText(campos.at(1), password);
  await tester.pump();
}

bool botaoHabilitado(WidgetTester tester) {
  final botao = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
  return botao.onPressed != null;
}

void main() {
  group('validação do login', () {
    test('regras puras', () {
      expect(validarUsername('abc'), isNotNull);
      expect(validarUsername('   a  '), isNotNull);
      expect(validarUsername('abcd'), isNull);
      expect(validarSenha('1234567'), isNotNull);
      expect(validarSenha('12345678'), isNull);
    });

    testWidgets('monta só com a API do catálogo e começa bloqueado',
        (tester) async {
      await tester.pumpWidget(const ExampleApp());

      expect(find.byType(Label), findsOneWidget);
      expect(find.byType(InputField), findsNWidgets(2));
      expect(find.byType(Button), findsOneWidget);
      expect(botaoHabilitado(tester), isFalse);
      // Nenhum erro aparece antes do usuário digitar.
      expect(find.text('Use mais de 3 caracteres'), findsNothing);
    });

    testWidgets('mostra os erros e mantém o botão bloqueado', (tester) async {
      await tester.pumpWidget(const ExampleApp());
      await preencher(tester, username: 'abc', password: '1234567');

      expect(find.text('Use mais de 3 caracteres'), findsOneWidget);
      expect(find.text('A senha precisa de 8 caracteres ou mais'), findsOneWidget);
      expect(botaoHabilitado(tester), isFalse);
    });

    testWidgets('com dados válidos libera o botão e abre a próxima tela',
        (tester) async {
      await tester.pumpWidget(const ExampleApp());
      await preencher(tester, username: 'maria', password: 'senha1234');

      expect(find.text('Use mais de 3 caracteres'), findsNothing);
      expect(botaoHabilitado(tester), isTrue);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Olá, maria'), findsOneWidget);
    });
  });

  group('próxima tela', () {
    testWidgets('mostra os dois painéis com packs diferentes', (tester) async {
      await tester.pumpWidget(
        const ExampleApp(),
      );
      await preencher(tester, username: 'maria', password: 'senha1234');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Área do cliente'), findsOneWidget);
      expect(find.text('Área operacional (ERP)'), findsOneWidget);
      expect(find.byType(InputField), findsNWidgets(2));
    });

    testWidgets('Sair volta para o login', (tester) async {
      await tester.pumpWidget(const ExampleApp());
      await preencher(tester, username: 'maria', password: 'senha1234');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(botaoHabilitado(tester), isFalse);
    });
  });
}
