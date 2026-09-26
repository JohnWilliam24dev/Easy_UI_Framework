import 'package:easy_ui/src/widget_catalog/actions/button.dart';
import 'package:easy_ui/src/widget_catalog/feedback/modal.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  group('confirm', () {
    testWidgets('confirmar devolve true e fecha o diálogo', (tester) async {
      bool? resultado;
      await pumpEasy(
        tester,
        Tela(
          child: Builder(
            builder: (context) => Button(
              text: 'Abrir',
              onPressed: () async {
                resultado = await Modal.confirm(
                  context,
                  title: 'Excluir pedido?',
                  message: 'Esta ação não pode ser desfeita.',
                  confirmText: 'Excluir',
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Excluir pedido?'), findsOneWidget);
      expect(find.text('Esta ação não pode ser desfeita.'), findsOneWidget);

      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      expect(resultado, isTrue);
      expect(find.text('Excluir pedido?'), findsNothing);
    });

    testWidgets('cancelar devolve false', (tester) async {
      bool? resultado;
      await pumpEasy(
        tester,
        Tela(
          child: Builder(
            builder: (context) => Button(
              text: 'Abrir',
              onPressed: () async {
                resultado = await Modal.confirm(context, title: 'Título');
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(resultado, isFalse);
    });
  });

  group('alert', () {
    testWidgets('mostra a mensagem e fecha ao tocar no botão', (tester) async {
      await pumpEasy(
        tester,
        Tela(
          child: Builder(
            builder: (context) => Button(
              text: 'Abrir',
              onPressed: () => Modal.alert(
                context,
                title: 'Pedido salvo',
                okText: 'Entendi',
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Pedido salvo'), findsOneWidget);

      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();
      expect(find.text('Pedido salvo'), findsNothing);
    });
  });

  group('custom', () {
    testWidgets('devolve o valor passado para Navigator.pop', (tester) async {
      String? recebido;
      await pumpEasy(
        tester,
        Tela(
          child: Builder(
            builder: (context) => Button(
              text: 'Abrir',
              onPressed: () async {
                recebido = await Modal.custom<String>(
                  context,
                  builder: (dialogContext) => Button(
                    text: 'Escolher',
                    onPressed: () => Navigator.of(dialogContext).pop('opcao-a'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Escolher'));
      await tester.pumpAndSettle();

      expect(recebido, 'opcao-a');
    });
  });
}
