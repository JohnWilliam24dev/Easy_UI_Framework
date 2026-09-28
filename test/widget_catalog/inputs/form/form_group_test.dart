import 'dart:async';

import 'package:easy_ui/src/widget_catalog/actions/button.dart';
import 'package:easy_ui/src/widget_catalog/inputs/form/form_group.dart';
import 'package:easy_ui/src/widget_catalog/inputs/form/validators.dart';
import 'package:easy_ui/src/widget_catalog/inputs/input_field.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_easy.dart';

Widget _loginForm({
  FutureOr<void> Function(FormValues values)? onSubmit,
  bool disableWhenInvalid = false,
  VoidCallback? onCancel,
}) {
  return Tela(
    child: FormGroup(
      children: [
        InputField(
          name: 'username',
          hint: 'Username',
          validation: [isRequired(), minLength(4)],
        ),
        InputField(
          name: 'password',
          hint: 'Password',
          type: InputType.password,
          validation: [isRequired(), isPassword(min: 8)],
        ),
        Button(
          text: 'Entrar',
          onSubmit: onSubmit ?? (_) {},
          disableWhenInvalid: disableWhenInvalid,
        ),
        if (onCancel != null)
          Button(
            text: 'Cancelar',
            variant: ButtonVariant.outline,
            onPressed: onCancel,
          ),
      ],
    ),
  );
}

Future<void> _preencher(
  WidgetTester tester, {
  required String username,
  required String password,
}) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), username);
  await tester.enterText(campos.at(1), password);
  await tester.pump();
}

Finder get _botaoEntrar => find.widgetWithText(ElevatedButton, 'Entrar');

void main() {
  group('envio', () {
    testWidgets('formulário válido chama onSubmit com os valores',
        (tester) async {
      FormValues? recebidos;
      await pumpEasy(tester, _loginForm(onSubmit: (v) => recebidos = v));
      await _preencher(tester, username: 'maria', password: 'senha1234');

      await tester.tap(_botaoEntrar);
      await tester.pump();

      expect(recebidos, {'username': 'maria', 'password': 'senha1234'});
    });

    testWidgets('formulário inválido não chama onSubmit e revela os erros',
        (tester) async {
      var chamadas = 0;
      await pumpEasy(tester, _loginForm(onSubmit: (_) => chamadas++));

      // Antes de tentar enviar, nenhum erro aparece.
      expect(find.text('Campo obrigatório'), findsNothing);

      await tester.tap(_botaoEntrar);
      await tester.pump();

      expect(chamadas, 0);
      expect(find.text('Campo obrigatório'), findsNWidgets(2));
    });

    testWidgets('foca o primeiro campo inválido', (tester) async {
      await pumpEasy(tester, _loginForm());
      // username válido, password curto demais -> foca o password.
      await _preencher(tester, username: 'maria', password: '123');

      await tester.tap(_botaoEntrar);
      await tester.pump();

      final password = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(password.focusNode!.hasFocus, isTrue);
      expect(
        find.text('A senha precisa ter 8 ou mais caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('onPressed comum não valida nada', (tester) async {
      var cancelou = false;
      await pumpEasy(
        tester,
        _loginForm(onCancel: () => cancelou = true),
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar'));
      await tester.pump();

      expect(cancelou, isTrue);
      expect(find.text('Campo obrigatório'), findsNothing);
    });
  });

  group('erros durante a digitação', () {
    testWidgets('aparecem só depois de digitar naquele campo', (tester) async {
      await pumpEasy(tester, _loginForm());
      await tester.enterText(find.byType(TextField).at(0), 'abc');
      await tester.pump();

      expect(find.text('Use pelo menos 4 caracteres'), findsOneWidget);
      // O outro campo continua sem erro.
      expect(find.text('Campo obrigatório'), findsNothing);
    });
  });

  group('onSubmit assíncrono', () {
    testWidgets('mostra loading até o Future terminar', (tester) async {
      final completer = Completer<void>();
      await pumpEasy(
        tester,
        _loginForm(onSubmit: (_) => completer.future),
      );
      await _preencher(tester, username: 'maria', password: 'senha1234');

      await tester.tap(_botaoEntrar);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete();
      await tester.pump();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('ignora cliques enquanto está enviando', (tester) async {
      final completer = Completer<void>();
      var chamadas = 0;
      await pumpEasy(
        tester,
        _loginForm(onSubmit: (_) {
          chamadas++;
          return completer.future;
        }),
      );
      await _preencher(tester, username: 'maria', password: 'senha1234');

      await tester.tap(_botaoEntrar);
      await tester.pump();
      await tester.tap(_botaoEntrar);
      await tester.pump();

      expect(chamadas, 1);
      completer.complete();
      await tester.pump();
    });
  });

  group('disableWhenInvalid', () {
    bool botaoHabilitado(WidgetTester tester) {
      return tester.widget<ElevatedButton>(_botaoEntrar).onPressed != null;
    }

    testWidgets('desabilita até o formulário ficar válido', (tester) async {
      await pumpEasy(tester, _loginForm(disableWhenInvalid: true));
      await tester.pump(); // notificação pós-frame do registro dos campos
      expect(botaoHabilitado(tester), isFalse);

      await _preencher(tester, username: 'maria', password: 'senha1234');
      expect(botaoHabilitado(tester), isTrue);

      await tester.enterText(find.byType(TextField).at(1), '123');
      await tester.pump();
      expect(botaoHabilitado(tester), isFalse);
    });
  });

  group('regras entre campos', () {
    Widget confirmacao() {
      return Tela(
        child: FormGroup(
          children: [
            InputField(
              name: 'password',
              type: InputType.password,
              validation: [isRequired()],
            ),
            InputField(
              name: 'confirma',
              type: InputType.password,
              validation: [sameAs('password', message: 'Não confere')],
            ),
          ],
        ),
      );
    }

    testWidgets('sameAs reage quando o outro campo muda', (tester) async {
      await pumpEasy(tester, confirmacao());

      await tester.enterText(find.byType(TextField).at(0), 'abc12345');
      await tester.enterText(find.byType(TextField).at(1), 'zzz');
      await tester.pump();
      expect(find.text('Não confere'), findsOneWidget);

      // Ajusta o primeiro campo para igualar: o erro do segundo some.
      await tester.enterText(find.byType(TextField).at(0), 'zzz');
      await tester.pump();
      expect(find.text('Não confere'), findsNothing);
    });
  });

  group('uso incorreto', () {
    testWidgets('Button com onSubmit fora de um FormGroup lança FlutterError',
        (tester) async {
      await pumpEasy(
        tester,
        Tela(child: Button(text: 'Entrar', onSubmit: (_) {})),
      );
      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('campo com validation sem name dentro do FormGroup falha',
        (tester) async {
      await pumpEasy(
        tester,
        Tela(
          child: FormGroup(
            children: [InputField(validation: [isRequired()])],
          ),
        ),
      );
      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('names duplicados no mesmo FormGroup falham', (tester) async {
      await pumpEasy(
        tester,
        Tela(
          child: FormGroup(
            children: const [
              InputField(name: 'a'),
              InputField(name: 'a'),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isA<FlutterError>());
    });
  });
}
