import 'package:easy_ui/src/theme_layer/theme_layer.dart';
import 'package:easy_ui/src/widget_catalog/inputs/input_field.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

Widget _tela(Widget field) {
  return Tela(
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 300, child: field),
    ),
  );
}

TextField _textField(WidgetTester tester) {
  return tester.widget<TextField>(find.byType(TextField));
}

void main() {
  group('tipos', () {
    testWidgets('text usa teclado de texto e mostra o hint', (tester) async {
      await pumpEasy(
        tester,
        _tela(const InputField(hint: 'Username', type: InputType.text)),
      );
      final field = _textField(tester);
      expect(field.keyboardType, TextInputType.text);
      expect(field.obscureText, isFalse);
      expect(field.decoration?.hintText, 'Username');
    });

    testWidgets('email usa teclado de e-mail e sem autocorreção',
        (tester) async {
      await pumpEasy(tester, _tela(const InputField(type: InputType.email)));
      final field = _textField(tester);
      expect(field.keyboardType, TextInputType.emailAddress);
      expect(field.autocorrect, isFalse);
    });

    testWidgets('phone e number usam os teclados correspondentes',
        (tester) async {
      await pumpEasy(tester, _tela(const InputField(type: InputType.phone)));
      expect(_textField(tester).keyboardType, TextInputType.phone);

      await pumpEasy(tester, _tela(const InputField(type: InputType.number)));
      expect(
        _textField(tester).keyboardType,
        const TextInputType.numberWithOptions(decimal: true),
      );
    });

    testWidgets('search mostra a lupa', (tester) async {
      await pumpEasy(tester, _tela(const InputField(type: InputType.search)));
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(_textField(tester).textInputAction, TextInputAction.search);
    });
  });

  group('password', () {
    testWidgets('começa oculto e o botão alterna a visibilidade',
        (tester) async {
      await pumpEasy(
        tester,
        _tela(const InputField(hint: 'Password', type: InputType.password)),
      );
      expect(_textField(tester).obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      expect(_textField(tester).obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      expect(_textField(tester).obscureText, isTrue);
    });
  });

  group('interação', () {
    testWidgets('onChanged recebe o que foi digitado', (tester) async {
      String? digitado;
      await pumpEasy(
        tester,
        _tela(InputField(onChanged: (v) => digitado = v)),
      );
      await tester.enterText(find.byType(TextField), 'maria');
      expect(digitado, 'maria');
    });

    testWidgets('controller externo é respeitado', (tester) async {
      final controller = TextEditingController(text: 'inicial');
      addTearDown(controller.dispose);
      await pumpEasy(tester, _tela(InputField(controller: controller)));
      expect(find.text('inicial'), findsOneWidget);
    });

    testWidgets('errorText aparece na tela', (tester) async {
      await pumpEasy(
        tester,
        _tela(const InputField(errorText: 'Campo obrigatório')),
      );
      expect(find.text('Campo obrigatório'), findsOneWidget);
    });
  });

  group('aparência vem do StylePack', () {
    testWidgets('padrão é outline com raio 8 e cores dos tokens',
        (tester) async {
      await pumpEasy(tester, _tela(const InputField()));
      final decoration = _textField(tester).decoration!;
      final enabled = decoration.enabledBorder as OutlineInputBorder;
      final focused = decoration.focusedBorder as OutlineInputBorder;

      expect(enabled.borderRadius, BorderRadius.circular(8));
      expect(enabled.borderSide.color, testTokens.borderColor);
      expect(focused.borderSide.color, testTokens.primaryColor);
    });

    testWidgets('rounded aplica o raio do pack', (tester) async {
      await pumpEasy(
        tester,
        _tela(const InputField()),
        pack: const StylePack(
          name: 'cliente',
          inputText: InputStyleSpec.rounded(radius: 16),
        ),
      );
      final enabled =
          _textField(tester).decoration!.enabledBorder as OutlineInputBorder;
      expect(enabled.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('underline usa borda só embaixo', (tester) async {
      await pumpEasy(
        tester,
        _tela(const InputField()),
        pack: const StylePack(
          name: 'erp',
          inputText: InputStyleSpec.underline(),
        ),
      );
      expect(
        _textField(tester).decoration!.enabledBorder,
        isA<UnderlineInputBorder>(),
      );
    });

    testWidgets('filled preenche o fundo e não desenha borda em repouso',
        (tester) async {
      await pumpEasy(
        tester,
        _tela(const InputField()),
        pack: const StylePack(
          name: 'preenchido',
          inputText: InputStyleSpec.filled(),
        ),
      );
      final decoration = _textField(tester).decoration!;
      final enabled = decoration.enabledBorder as OutlineInputBorder;
      expect(decoration.filled, isTrue);
      expect(enabled.borderSide, BorderSide.none);
    });

    testWidgets('elevation adiciona sombra atrás do campo', (tester) async {
      bool temSombra(Widget w) {
        return w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).boxShadow != null;
      }

      await pumpEasy(tester, _tela(const InputField()));
      expect(find.byWidgetPredicate(temSombra), findsNothing);

      await pumpEasy(
        tester,
        _tela(const InputField()),
        pack: const StylePack(
          name: 'elevado',
          inputText: InputStyleSpec.rounded(elevation: ElevationLevel.subtle),
        ),
      );
      expect(find.byWidgetPredicate(temSombra), findsOneWidget);
    });

    testWidgets('spacingScale altera o padding interno', (tester) async {
      await pumpEasy(
        tester,
        _tela(const InputField()),
        pack: const StylePack(name: 'arejado', spacingScale: 2),
      );
      final padding = _textField(tester).decoration!.contentPadding!
          as EdgeInsets;
      expect(padding.horizontal, closeTo(2 * (2 * 8 * 2), 1e-9)); // esq + dir
      expect(padding.vertical, closeTo(2 * (1.5 * 8 * 2), 1e-9)); // topo + base
    });
  });

  group('validator', () {
    String? minimo4(String v) => v.length >= 4 ? null : 'Mínimo de 4';

    testWidgets('só mostra o erro depois que o usuário digita',
        (tester) async {
      await pumpEasy(tester, _tela(InputField(validator: minimo4)));
      expect(find.text('Mínimo de 4'), findsNothing);

      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump();
      expect(find.text('Mínimo de 4'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'abcd');
      await tester.pump();
      expect(find.text('Mínimo de 4'), findsNothing);
    });

    testWidgets('errorText externo tem prioridade sobre o validator',
        (tester) async {
      await pumpEasy(
        tester,
        _tela(InputField(validator: minimo4, errorText: 'Vindo do servidor')),
      );
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump();
      expect(find.text('Vindo do servidor'), findsOneWidget);
      expect(find.text('Mínimo de 4'), findsNothing);
    });

    testWidgets('onChanged continua sendo chamado', (tester) async {
      String? recebido;
      await pumpEasy(
        tester,
        _tela(InputField(validator: minimo4, onChanged: (v) => recebido = v)),
      );
      await tester.enterText(find.byType(TextField), 'abc');
      expect(recebido, 'abc');
    });

    testWidgets('lê o valor do controller quando existe', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpEasy(
        tester,
        _tela(InputField(controller: controller, validator: minimo4)),
      );
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump();
      expect(find.text('Mínimo de 4'), findsOneWidget);
    });
  });
}
