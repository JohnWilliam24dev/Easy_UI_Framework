import 'package:easy_ui/src/widget_catalog/actions/button.dart';
import 'package:easy_ui/src/widget_catalog/display/list_item.dart';
import 'package:easy_ui/src/widget_catalog/feedback/modal.dart';
import 'package:easy_ui/src/widget_catalog/feedback/user_facing_exception.dart';
import 'package:easy_ui/src/widget_catalog/inputs/input_field.dart';
import 'package:easy_ui/src/widget_catalog/inputs/form/validators.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  testWidgets('form valida campos antes de enviar', (tester) async {
    var calls = 0;
    await pumpEasy(
      tester,
      Tela(
        child: Builder(
          builder: (context) => Button(
            text: 'Abrir',
            onPressed: () => Modal.form<void>(
              context,
              title: 'Editar',
              fields: (_) => [
                InputField(name: 'name', validation: [isRequired()]),
              ],
              onSubmit: (_) => calls++,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pump();
    expect(calls, 0);
    expect(find.text('Campo obrigatório'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(calls, 1);
  });
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

  group('sheet, adaptive e choice', () {
    Widget abrir(Future<void> Function(BuildContext context) open) => Tela(
      child: Builder(
        builder: (context) =>
            Button(text: 'Abrir', onPressed: () => open(context)),
      ),
    );

    testWidgets('adaptive abre bottom sheet em tela estreita', (tester) async {
      await pumpEasy(
        tester,
        abrir(
          (context) => Modal.adaptive<void>(
            context,
            builder: (_) => const Text('conteudo'),
          ),
        ),
        size: const Size(400, 800),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('conteudo'), findsOneWidget);
    });

    testWidgets('adaptive abre diálogo em tela larga', (tester) async {
      await pumpEasy(
        tester,
        abrir(
          (context) => Modal.adaptive<void>(
            context,
            builder: (_) => const Text('conteudo'),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('sheet sobe acima do teclado', (tester) async {
      await pumpEasy(
        tester,
        abrir(
          (context) => Modal.sheet<void>(
            context,
            builder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child: TextField(),
            ),
          ),
        ),
        size: const Size(400, 800),
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(
        tester.getBottomLeft(find.byType(TextField)).dy,
        lessThanOrEqualTo(500),
      );
    });

    testWidgets('choice marca a opção atual', (tester) async {
      await pumpEasy(
        tester,
        abrir(
          (context) => Modal.choice<String>(
            context,
            title: 'Status',
            selected: 'b',
            choices: const [
              ModalChoice('a', 'Aberto'),
              ModalChoice('b', 'Fechado'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      final items = tester.widgetList<ListItem>(find.byType(ListItem));
      expect(items.map((item) => item.selected), [false, true]);
    });
  });

  group('form: falha e adaptive', () {
    Widget abrir({
      required Object Function() falha,
      bool adaptive = false,
    }) => Tela(
      child: Builder(
        builder: (context) => Button(
          text: 'Abrir',
          onPressed: () => Modal.form<void>(
            context,
            title: 'Editar',
            adaptive: adaptive,
            fields: (_) => [const InputField(name: 'nome')],
            onSubmit: (_) => throw falha(),
          ),
        ),
      ),
    );

    testWidgets('UserFacingException aparece dentro do modal, sem Toast',
        (tester) async {
      await pumpEasy(
        tester,
        abrir(falha: () => const UserFacingException('Coluna com comissões')),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Coluna com comissões'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Editar'), findsOneWidget);
    });

    testWidgets('erro comum mostra texto genérico inline e é reportado',
        (tester) async {
      await pumpEasy(tester, abrir(falha: () => StateError('falhou')));
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isA<StateError>());
      expect(
        find.text('Não foi possível concluir a ação. Tente novamente.'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('o erro some quando o usuário edita um campo', (tester) async {
      await pumpEasy(
        tester,
        abrir(falha: () => const UserFacingException('Coluna com comissões')),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Coluna com comissões'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'novo');
      await tester.pump();

      expect(find.text('Coluna com comissões'), findsNothing);
    });

    testWidgets('adaptive abre bottom sheet em tela estreita', (tester) async {
      await pumpEasy(
        tester,
        abrir(falha: () => StateError('x'), adaptive: true),
        size: const Size(400, 800),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Editar'), findsOneWidget);
    });

    testWidgets('adaptive abre diálogo em tela larga', (tester) async {
      await pumpEasy(
        tester,
        abrir(falha: () => StateError('x'), adaptive: true),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
    });
  });
}
