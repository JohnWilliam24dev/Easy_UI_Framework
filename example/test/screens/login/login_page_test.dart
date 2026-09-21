import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ui_example/screens/login/login_page.dart';

import '../../support/helpers.dart';

void main() {
  testWidgets('monta só com a API do catálogo, sem erros iniciais',
      (tester) async {
    await tester.pumpWidget(easyHome(LoginPage(onLogin: (_) {})));

    expect(find.byType(FormGroup), findsOneWidget);
    expect(find.byType(Label), findsOneWidget);
    expect(find.byType(InputField), findsNWidgets(2));
    expect(find.byType(Button), findsOneWidget);
    expect(find.text('Campo obrigatório'), findsNothing);
  });

  testWidgets('enviar vazio revela os erros e não faz login', (tester) async {
    String? recebido;
    await tester.pumpWidget(easyHome(LoginPage(onLogin: (u) => recebido = u)));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Campo obrigatório'), findsNWidgets(2));
    expect(recebido, isNull);
  });

  testWidgets('mostra a mensagem de cada regra e não faz login',
      (tester) async {
    String? recebido;
    await tester.pumpWidget(easyHome(LoginPage(onLogin: (u) => recebido = u)));
    await preencherLogin(tester, username: 'abc', password: '1234567');

    expect(find.text('Use pelo menos 4 caracteres'), findsOneWidget);
    expect(
      find.text('A senha precisa ter 8 ou mais caracteres'),
      findsOneWidget,
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(recebido, isNull);
  });

  testWidgets('dados válidos entregam o username', (tester) async {
    String? recebido;
    await tester.pumpWidget(easyHome(LoginPage(onLogin: (u) => recebido = u)));
    await preencherLogin(tester, username: 'maria', password: 'senha1234');

    expect(find.text('Campo obrigatório'), findsNothing);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(recebido, 'maria');
  });
}
