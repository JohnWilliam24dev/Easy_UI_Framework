import 'package:easy_ui/src/theme_layer/theme_layer.dart';
import 'package:easy_ui/src/widget_catalog/actions/button.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

Widget _tela(Widget child) {
  return Tela(child: Align(alignment: Alignment.topLeft, child: child));
}

OutlinedBorder _shapeOf(ButtonStyle style) {
  return style.shape!.resolve(<WidgetState>{})!;
}

void main() {
  group('variantes', () {
    testWidgets('solid usa ElevatedButton com a cor primária', (tester) async {
      await pumpEasy(tester, _tela(Button(text: 'Login', onPressed: () {})));
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style!;

      expect(find.text('Login'), findsOneWidget);
      expect(style.backgroundColor!.resolve(<WidgetState>{}),
          testTokens.primaryColor);
      expect(style.foregroundColor!.resolve(<WidgetState>{}),
          testTokens.onPrimaryColor);
    });

    testWidgets('outline usa OutlinedButton', (tester) async {
      await pumpEasy(
        tester,
        _tela(
          Button(text: 'x', variant: ButtonVariant.outline, onPressed: () {}),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('ghost usa TextButton', (tester) async {
      await pumpEasy(
        tester,
        _tela(
          Button(text: 'x', variant: ButtonVariant.ghost, onPressed: () {}),
        ),
      );
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('pill arredonda por completo, mesmo com pack quadrado',
        (tester) async {
      await pumpEasy(
        tester,
        _tela(
          Button(text: 'x', variant: ButtonVariant.pill, onPressed: () {}),
        ),
        pack: const StylePack(name: 'compacto', button: ButtonStyleSpec.compact()),
      );
      final style =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).style!;
      final shape = _shapeOf(style) as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(ButtonStyleSpec.pillRadius));
    });
  });

  group('pele do StylePack', () {
    testWidgets('raio e altura mínima vêm do ButtonStyleSpec', (tester) async {
      await pumpEasy(
        tester,
        _tela(Button(text: 'x', onPressed: () {})),
        pack: const StylePack(name: 'compacto', button: ButtonStyleSpec.compact()),
      );
      final style =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).style!;
      final shape = _shapeOf(style) as RoundedRectangleBorder;

      expect(shape.borderRadius, BorderRadius.circular(4));
      expect(style.minimumSize!.resolve(<WidgetState>{}), const Size(0, 32));
    });

    testWidgets('padding horizontal é escalado pelo spacingScale',
        (tester) async {
      await pumpEasy(
        tester,
        _tela(Button(text: 'x', onPressed: () {})),
        pack: const StylePack(name: 'arejado', spacingScale: 1.5),
      );
      final style =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).style!;
      final padding = style.padding!.resolve(<WidgetState>{})! as EdgeInsets;
      expect(padding.left, closeTo(20 * 1.5, 1e-9));
    });
  });

  group('estados', () {
    testWidgets('onPressed é chamado no toque', (tester) async {
      var toques = 0;
      await pumpEasy(
        tester,
        _tela(Button(text: 'Entrar', onPressed: () => toques++)),
      );
      await tester.tap(find.text('Entrar'));
      expect(toques, 1);
    });

    testWidgets('sem onPressed fica desabilitado', (tester) async {
      await pumpEasy(tester, _tela(const Button(text: 'Entrar')));
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('loading mostra indicador e ignora toques', (tester) async {
      var toques = 0;
      await pumpEasy(
        tester,
        _tela(Button(text: 'Entrar', loading: true, onPressed: () => toques++)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      expect(toques, 0);
    });

    testWidgets('expanded ocupa a largura disponível', (tester) async {
      await pumpEasy(
        tester,
        _tela(Button(text: 'Entrar', expanded: true, onPressed: () {})),
      );
      // 800 de viewport - 2 * 16 de padding da Tela.
      expect(tester.getSize(find.byType(ElevatedButton)).width, 768);
    });
  });
}
