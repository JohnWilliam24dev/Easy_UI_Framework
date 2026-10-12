import 'package:easy_ui/src/widget_catalog/actions/button.dart';
import 'package:easy_ui/src/widget_catalog/feedback/optimistic.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  testWidgets('mantém a alteração quando persist funciona', (tester) async {
    var valor = 0;
    bool? resultado;
    await pumpEasy(
      tester,
      Tela(
        child: Builder(
          builder: (context) => Button(
            text: 'Ir',
            onPressed: () async {
              resultado = await optimistic(
                context,
                apply: () => valor = 1,
                persist: () async {},
                rollback: () => valor = 0,
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ir'));
    await tester.pump();

    expect(resultado, isTrue);
    expect(valor, 1);
  });

  testWidgets('reverte, avisa e reporta quando persist falha', (tester) async {
    var valor = 0;
    bool? resultado;
    await pumpEasy(
      tester,
      Tela(
        child: Builder(
          builder: (context) => Button(
            text: 'Ir',
            onPressed: () async {
              resultado = await optimistic(
                context,
                apply: () => valor = 1,
                persist: () async => throw StateError('falhou'),
                rollback: () => valor = 0,
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isA<StateError>());
    expect(resultado, isFalse);
    expect(valor, 0);
    expect(find.text('Não foi possível salvar a alteração.'), findsOneWidget);
  });
}
