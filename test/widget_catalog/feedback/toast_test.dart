import 'package:easy_ui/src/widget_catalog/feedback/toast.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart' show SnackBar;
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  testWidgets('mostra o texto com a cor do status', (tester) async {
    late final builderContext = tester.element(find.byType(Tela));
    await pumpEasy(tester, const Tela(child: SizedBox()));

    Toast.show(builderContext, text: 'Pedido salvo', type: ToastType.success);
    await tester.pump();

    expect(find.text('Pedido salvo'), findsOneWidget);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, testTokens.successColor);
  });

  testWidgets('cada tipo usa a cor correspondente do tema', (tester) async {
    late final builderContext = tester.element(find.byType(Tela));
    await pumpEasy(tester, const Tela(child: SizedBox()));

    for (final entry in {
      ToastType.error: testTokens.errorColor,
      ToastType.warning: testTokens.warningColor,
      ToastType.info: testTokens.infoColor,
    }.entries) {
      Toast.show(builderContext, text: 'msg', type: entry.key);
      await tester.pump();
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, entry.value, reason: '${entry.key}');
    }
  });

  testWidgets('um novo toast substitui o anterior', (tester) async {
    late final builderContext = tester.element(find.byType(Tela));
    await pumpEasy(tester, const Tela(child: SizedBox()));

    Toast.show(builderContext, text: 'Primeiro');
    await tester.pump();
    Toast.show(builderContext, text: 'Segundo');
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Segundo'), findsOneWidget);
  });

  testWidgets('desaparece sozinho após a duration', (tester) async {
    late final builderContext = tester.element(find.byType(Tela));
    await pumpEasy(tester, const Tela(child: SizedBox()));

    Toast.show(
      builderContext,
      text: 'Some rápido',
      duration: const Duration(milliseconds: 500),
    );
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });
}
