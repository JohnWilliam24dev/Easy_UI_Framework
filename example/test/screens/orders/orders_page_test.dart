import 'package:easy_ui/easy_ui.dart';
import 'package:easy_ui_example/screens/orders/order.dart';
import 'package:flutter/widgets.dart' show Size;
import 'package:easy_ui_example/screens/orders/order_card.dart';
import 'package:easy_ui_example/screens/orders/order_summary_card.dart';
import 'package:easy_ui_example/screens/orders/orders_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/helpers.dart';

void main() {
  testWidgets('mostra os cards de resumo e a lista de pedidos',
      (tester) async {
    await tester.pumpWidget(easyHome(OrdersPage(onBack: () {})));
    await tester.pumpAndSettle();

    expect(find.byType(OrderSummaryCard), findsNWidgets(3));
    expect(find.byType(OrderCard), findsWidgets);
    expect(find.text('Cliente 1'), findsOneWidget);
  });

  testWidgets('Voltar chama onBack', (tester) async {
    var voltou = false;
    await tester.pumpWidget(easyHome(OrdersPage(onBack: () => voltou = true)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Voltar'));
    await tester.pump();
    expect(voltou, isTrue);
  });

  testWidgets('alternar "Só pendentes" refaz a busca', (tester) async {
    await tester.pumpWidget(easyHome(OrdersPage(onBack: () {})));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Toggle<bool>));
    await tester.pumpAndSettle();

    // Todos os pedidos visíveis devem ser "Pendente" agora.
    expect(find.text('Em produção'), findsNothing);
    expect(find.text('Concluído'), findsNothing);
    expect(find.text('Pendente'), findsWidgets);
  });

  testWidgets(
      'em tela estreita, filtros empilham e nada estoura (regressão da '
      'janela ~430px)', (tester) async {
    tester.view.physicalSize = const Size(430, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(easyHome(OrdersPage(onBack: () {})));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(OrderSummaryCard), findsNWidgets(3));
    expect(find.byType(Select<OrderStatus?>), findsOneWidget);
    expect(find.byType(Toggle<bool>), findsOneWidget);
  });
}
