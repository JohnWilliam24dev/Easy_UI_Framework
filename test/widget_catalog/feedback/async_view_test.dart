import 'dart:async';

import 'package:easy_ui/src/widget_catalog/feedback/async_view.dart';
import 'package:easy_ui/src/widget_catalog/feedback/loader.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  testWidgets('mostra o loader e depois o conteúdo', (tester) async {
    final completer = Completer<String>();
    await pumpEasy(
      tester,
      Tela(
        child: AsyncView<String>(
          load: () => completer.future,
          builder: (_, data) => Text(data),
        ),
      ),
    );
    expect(find.byType(Loader), findsOneWidget);

    completer.complete('pronto');
    await tester.pump();
    await tester.pump();

    expect(find.byType(Loader), findsNothing);
    expect(find.text('pronto'), findsOneWidget);
  });

  testWidgets('erro mostra tentar de novo e recarrega', (tester) async {
    var chamadas = 0;
    await pumpEasy(
      tester,
      Tela(
        child: AsyncView<String>(
          load: () async {
            chamadas++;
            if (chamadas == 1) throw StateError('falhou');
            return 'ok';
          },
          builder: (_, data) => Text(data),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Não foi possível carregar'), findsOneWidget);

    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();
    await tester.pump();

    expect(chamadas, 2);
    expect(find.text('ok'), findsOneWidget);
    expect(find.text('Não foi possível carregar'), findsNothing);
  });

  testWidgets('erro usa o builder customizado quando informado',
      (tester) async {
    await pumpEasy(
      tester,
      Tela(
        child: AsyncView<String>(
          load: () async => throw StateError('falhou'),
          builder: (_, data) => Text(data),
          error: (_, error, reload) => Text('erro: ${error.runtimeType}'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('erro: StateError'), findsOneWidget);
  });

  testWidgets('resultado nulo mostra o estado vazio padrão', (tester) async {
    await pumpEasy(
      tester,
      Tela(
        child: AsyncView<String?>(
          load: () async => null,
          builder: (_, data) => Text(data ?? ''),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Nenhum item encontrado'), findsOneWidget);
  });

  testWidgets('coleção vazia mostra o empty informado', (tester) async {
    await pumpEasy(
      tester,
      Tela(
        child: AsyncView<List<int>>(
          load: () async => <int>[],
          builder: (_, data) => Text('${data.length} itens'),
          empty: const Text('nada por aqui'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('nada por aqui'), findsOneWidget);
    expect(find.text('0 itens'), findsNothing);
  });
}
