import 'package:easy_ui/src/widget_catalog/data/data_list.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

DataSource<int> _fakeSource(int total, {Duration delay = Duration.zero}) {
  return (page, limit) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final start = page * limit;
    if (start >= total) return const [];
    final end = (start + limit).clamp(0, total);
    return List.generate(end - start, (i) => start + i);
  };
}

Widget _lista(DataSource<int> source, {int limit = 50, WidgetBuilder? emptyBuilder}) {
  return Tela(
    child: SizedBox(
      height: 400,
      child: DataList<int>(
        source: source,
        limit: limit,
        emptyBuilder: emptyBuilder,
        itemBuilder: (context, item) => SizedBox(
          key: ValueKey(item),
          height: 60,
          child: Text('Item $item'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('mostra loader enquanto a primeira página carrega',
      (tester) async {
    await pumpEasy(
      tester,
      _lista(_fakeSource(5, delay: const Duration(milliseconds: 50))),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('carrega a primeira página com o limite pedido', (tester) async {
    await pumpEasy(tester, _lista(_fakeSource(100), limit: 10));
    await tester.pumpAndSettle();
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 9'), findsOneWidget);
    expect(find.text('Item 10'), findsNothing);
  });

  testWidgets('rolar perto do fim busca a próxima página', (tester) async {
    await pumpEasy(tester, _lista(_fakeSource(100), limit: 10));
    await tester.pumpAndSettle();
    expect(find.text('Item 10'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();

    expect(find.text('Item 10'), findsOneWidget);
  });

  testWidgets('para quando a página vem incompleta (fim dos dados)',
      (tester) async {
    await pumpEasy(tester, _lista(_fakeSource(15), limit: 10));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(find.text('Item 14'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Mais uma tentativa de rolar não deve pedir página 3.
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('lista vazia usa o emptyBuilder', (tester) async {
    await pumpEasy(
      tester,
      _lista(
        _fakeSource(0),
        emptyBuilder: (_) => const Text('Nada por aqui'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nada por aqui'), findsOneWidget);
  });

  testWidgets('lista vazia sem emptyBuilder usa o texto padrão',
      (tester) async {
    await pumpEasy(tester, _lista(_fakeSource(0)));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum item encontrado'), findsOneWidget);
  });

  testWidgets('erro na primeira página mostra estado de erro com retry',
      (tester) async {
    var tentativas = 0;
    Future<List<int>> falhaUmaVez(int page, int limit) async {
      tentativas++;
      if (tentativas == 1) throw Exception('falhou');
      return List.generate(limit, (i) => i);
    }

    await pumpEasy(tester, _lista(falhaUmaVez, limit: 5));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível carregar'), findsOneWidget);
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível carregar'), findsNothing);
    expect(find.text('Item 0'), findsOneWidget);
  });
}
