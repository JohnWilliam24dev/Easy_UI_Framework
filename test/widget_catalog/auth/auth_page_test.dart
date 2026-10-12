import 'package:easy_ui/src/widget_catalog/auth/auth_page.dart';
import 'package:easy_ui/src/widget_catalog/display/card.dart' as easy;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  testWidgets('monta título, subtítulo, formulário, marca e rodapé',
      (tester) async {
    await pumpEasy(
      tester,
      const AuthPage(
        title: 'Entrar',
        subtitle: 'Acesse sua conta',
        form: Text('formulario'),
        brand: Text('marca'),
        footer: Text('rodape'),
      ),
    );

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(find.text('formulario'), findsOneWidget);
    expect(find.text('marca'), findsOneWidget);
    expect(find.text('rodape'), findsOneWidget);
  });

  testWidgets('sem opcionais mostra só título e formulário', (tester) async {
    await pumpEasy(
      tester,
      const AuthPage(title: 'Recuperar', form: Text('formulario')),
    );

    expect(find.text('Recuperar'), findsOneWidget);
    expect(find.text('formulario'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('limita a largura do cartão em telas largas', (tester) async {
    await pumpEasy(
      tester,
      const AuthPage(title: 'Entrar', form: Text('formulario')),
    );

    expect(tester.getSize(find.byType(easy.Card)).width, lessThanOrEqualTo(460));
  });

  testWidgets('onBack mostra a seta e é chamado ao tocar', (tester) async {
    var voltou = 0;
    await pumpEasy(
      tester,
      AuthPage(
        title: 'Entrar',
        form: const Text('formulario'),
        onBack: () => voltou++,
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back));

    expect(voltou, 1);
  });

  testWidgets('cabe em tela estreita sem estourar', (tester) async {
    await pumpEasy(
      tester,
      const AuthPage(
        title: 'Entrar',
        subtitle: 'Acesse sua conta',
        form: Text('formulario'),
        footer: Text('rodape'),
      ),
      size: const Size(360, 640),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('formulario'), findsOneWidget);
  });
}
