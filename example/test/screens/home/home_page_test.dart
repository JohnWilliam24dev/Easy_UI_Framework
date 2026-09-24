import 'package:easy_ui_example/screens/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/helpers.dart';

void main() {
  testWidgets('mostra a saudação e os dois painéis', (tester) async {
    await tester.pumpWidget(
      easyHome(HomePage(username: 'maria', onLogout: () {}, onOpenOrders: () {})),
    );

    expect(find.text('Olá, maria'), findsOneWidget);
    expect(find.text('Área do cliente'), findsOneWidget);
    expect(find.text('Área operacional (ERP)'), findsOneWidget);
  });

  testWidgets('cada painel usa o seu StylePack', (tester) async {
    await tester.pumpWidget(
      easyHome(HomePage(username: 'maria', onLogout: () {}, onOpenOrders: () {})),
    );

    final campos =
        tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(campos, hasLength(2));
    // Cliente: borda arredondada. ERP: só a linha embaixo.
    expect(campos[0].decoration!.enabledBorder, isA<OutlineInputBorder>());
    expect(campos[1].decoration!.enabledBorder, isA<UnderlineInputBorder>());
  });

  testWidgets('Sair chama onLogout', (tester) async {
    var saiu = false;
    await tester.pumpWidget(
      easyHome(HomePage(username: 'maria', onLogout: () => saiu = true, onOpenOrders: () {})),
    );

    await tester.tap(find.text('Sair'));
    await tester.pump();
    expect(saiu, isTrue);
  });

  testWidgets('Ver pedidos chama onOpenOrders', (tester) async {
    var abriu = false;
    await tester.pumpWidget(
      easyHome(
        HomePage(
          username: 'maria',
          onLogout: () {},
          onOpenOrders: () => abriu = true,
        ),
      ),
    );

    await tester.tap(find.text('Ver pedidos'));
    await tester.pump();
    expect(abriu, isTrue);
  });
}
