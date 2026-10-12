import 'package:easy_ui/src/widget_catalog/inputs/select_option.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:easy_ui/src/widget_catalog/navigation/menu.dart';
import 'package:easy_ui/src/widget_catalog/navigation/page_dots.dart';
import 'package:easy_ui/src/widget_catalog/navigation/tabs.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  group('Menu', () {
    testWidgets('abre as opções e devolve o valor escolhido', (tester) async {
      String? escolhido;
      await pumpEasy(
        tester,
        Tela(
          child: Align(
            alignment: Alignment.topLeft,
            child: Menu<String>(
              items: const [
                SelectOption('editar', 'Editar'),
                SelectOption('excluir', 'Excluir'),
              ],
              onSelected: (value) => escolhido = value,
              child: const Text('Ações'),
            ),
          ),
        ),
      );
      expect(find.text('Editar'), findsNothing);

      await tester.tap(find.text('Ações'));
      await tester.pumpAndSettle();
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);

      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      expect(escolhido, 'excluir');
      expect(find.text('Editar'), findsNothing);
    });
  });

  group('Tabs', () {
    testWidgets('mostra a primeira aba e troca ao tocar em outra',
        (tester) async {
      await pumpEasy(
        tester,
        const Tela(
          child: Tabs(
            items: [
              TabItem(label: 'Geral', child: Text('conteudo geral')),
              TabItem(label: 'Pedidos', child: Text('conteudo pedidos')),
            ],
          ),
        ),
      );
      expect(find.text('Geral'), findsOneWidget);
      expect(find.text('Pedidos'), findsOneWidget);
      expect(find.text('conteudo geral'), findsOneWidget);

      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();

      expect(find.text('conteudo pedidos'), findsOneWidget);
    });
  });

  group('PageDots', () {
    List<double?> larguras(WidgetTester tester) {
      return tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .map((container) => container.constraints?.maxWidth)
          .toList();
    }

    testWidgets('destaca o ponto da página atual', (tester) async {
      final controller = PageController();
      addTearDown(controller.dispose);
      await pumpEasy(
        tester,
        Tela(
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: PageView(
                  controller: controller,
                  children: const [Text('1'), Text('2'), Text('3')],
                ),
              ),
              PageDots(controller: controller, count: 3),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(larguras(tester), [18, 7, 7]);

      controller.jumpToPage(2);
      await tester.pumpAndSettle();

      expect(larguras(tester), [7, 7, 18]);
    });

    testWidgets('sem PageView anexado usa a página inicial', (tester) async {
      final controller = PageController(initialPage: 1);
      addTearDown(controller.dispose);
      await pumpEasy(
        tester,
        Tela(child: PageDots(controller: controller, count: 3)),
      );

      expect(larguras(tester), [7, 18, 7]);
    });
  });
}
