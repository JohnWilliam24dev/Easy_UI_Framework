import 'package:easy_ui_example/app.dart';
import 'package:easy_ui_example/screens/home/home_page.dart';
import 'package:easy_ui_example/screens/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/helpers.dart';

void main() {
  testWidgets('login válido leva à home e Sair volta ao login',
      (tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.byType(LoginPage), findsOneWidget);

    await preencherLogin(tester, username: 'maria', password: 'senha1234');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Olá, maria'), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(loginHabilitado(tester), isFalse);
  });

  testWidgets('login inválido não navega', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await preencherLogin(tester, username: 'abc', password: '123');

    expect(loginHabilitado(tester), isFalse);
    await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });
}
