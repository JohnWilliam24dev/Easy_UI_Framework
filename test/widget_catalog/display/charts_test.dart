import 'package:easy_ui/src/widget_catalog/display/charts.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

List<double?> _fatores(WidgetTester tester) {
  return tester
      .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
      .map((box) => box.widthFactor)
      .toList();
}

void main() {
  group('ProgressBar', () {
    testWidgets('preenche a fração informada', (tester) async {
      await pumpEasy(tester, const Tela(child: ProgressBar(value: .4)));
      expect(_fatores(tester), [.4]);
    });

    testWidgets('limita valores fora de 0 a 1', (tester) async {
      await pumpEasy(
        tester,
        const Tela(
          child: Column(
            children: [ProgressBar(value: 1.5), ProgressBar(value: -1)],
          ),
        ),
      );
      expect(_fatores(tester), [1, 0]);
    });
  });

  group('BarChart', () {
    testWidgets('barras são proporcionais ao maior valor', (tester) async {
      await pumpEasy(
        tester,
        const Tela(
          child: BarChart(
            values: [ChartValue('Jan', 10), ChartValue('Fev', 5)],
          ),
        ),
      );
      expect(find.text('Jan'), findsOneWidget);
      expect(find.text('Fev'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(_fatores(tester), [1, .5]);
    });

    testWidgets('todos os valores zerados não dividem por zero',
        (tester) async {
      await pumpEasy(
        tester,
        const Tela(
          child: BarChart(values: [ChartValue('Jan', 0), ChartValue('Fev', 0)]),
        ),
      );
      expect(_fatores(tester), [0, 0]);
    });
  });

  group('Legend, DonutChart e ChartCard', () {
    testWidgets('Legend lista rótulo e valor', (tester) async {
      await pumpEasy(
        tester,
        const Tela(
          child: Legend(values: [ChartValue('Pago', 7), ChartValue('Aberto', 3)]),
        ),
      );
      expect(find.text('Pago: 7'), findsOneWidget);
      expect(find.text('Aberto: 3'), findsOneWidget);
    });

    testWidgets('DonutChart mostra o total e a legenda', (tester) async {
      await pumpEasy(
        tester,
        const Tela(
          child: DonutChart(
            values: [ChartValue('Pago', 7), ChartValue('Aberto', 3)],
          ),
        ),
      );
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Pago: 7'), findsOneWidget);
    });

    testWidgets('ChartCard mostra o título e o conteúdo', (tester) async {
      await pumpEasy(
        tester,
        const Tela(
          child: ChartCard(title: 'Receita', child: Text('conteudo')),
        ),
      );
      expect(find.text('Receita'), findsOneWidget);
      expect(find.text('conteudo'), findsOneWidget);
    });
  });
}
