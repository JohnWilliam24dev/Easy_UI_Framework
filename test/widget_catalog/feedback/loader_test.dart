import 'package:easy_ui/src/theme_layer/theme_layer.dart';
import 'package:easy_ui/src/widget_catalog/feedback/loader.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  group('inline', () {
    testWidgets('mostra o spinner na cor primária', (tester) async {
      await pumpEasy(tester, const Tela(child: Loader()));
      final spinner =
          tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(spinner.color, testTokens.primaryColor);
    });

    testWidgets('mostra a mensagem quando informada', (tester) async {
      await pumpEasy(
        tester,
        const Tela(child: Loader(message: 'Carregando pedidos...')),
      );
      expect(find.text('Carregando pedidos...'), findsOneWidget);
    });

    testWidgets('sem mensagem, não mostra nenhum texto', (tester) async {
      await pumpEasy(tester, const Tela(child: Loader()));
      expect(find.byType(Text), findsNothing);
    });
  });

  group('overlay', () {
    testWidgets('cobre o Stack e bloqueia toques no conteúdo de baixo',
        (tester) async {
      var toques = 0;
      await pumpEasy(
        tester,
        Tela(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => toques++,
                child: const SizedBox.expand(),
              ),
              const Loader(mode: LoaderMode.overlay),
            ],
          ),
        ),
      );

      await tester.tapAt(const Offset(50, 50));
      expect(toques, 0);
      expect(find.byType(AbsorbPointer), findsOneWidget);
    });

    testWidgets('usa a cor de fundo do tema, semitransparente', (tester) async {
      await pumpEasy(
        tester,
        const Tela(child: Stack(children: [Loader(mode: LoaderMode.overlay)])),
      );
      final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(box.color, testTokens.backgroundColor.withValues(alpha: 0.75));
    });
  });
}
