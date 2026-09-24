import 'package:easy_ui/src/widget_catalog/inputs/select.dart';
import 'package:easy_ui/src/widget_catalog/inputs/select_option.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

const _estados = [
  SelectOption('sp', 'São Paulo'),
  SelectOption('rj', 'Rio de Janeiro'),
];

void main() {
  group('single', () {
    testWidgets('mostra as opções e devolve o valor escolhido',
        (tester) async {
      String? selecionado;
      await pumpEasy(
        tester,
        Tela(
          child: Select<String>.single(
            options: _estados,
            onChanged: (v) => selecionado = v,
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rio de Janeiro').last);
      await tester.pumpAndSettle();

      expect(selecionado, 'rj');
    });

    testWidgets('value inicial aparece selecionado', (tester) async {
      await pumpEasy(
        tester,
        Tela(
          child: Select<String>.single(
            options: _estados,
            value: 'sp',
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('São Paulo'), findsOneWidget);
    });
  });

  group('multi', () {
    testWidgets('abre um diálogo e devolve os marcados', (tester) async {
      List<String>? recebido;
      await pumpEasy(
        tester,
        Tela(
          child: Select<String>.multi(
            options: _estados,
            hint: 'Selecione',
            onChanged: (v) => recebido = v,
          ),
        ),
      );

      expect(find.text('Selecione'), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.tap(find.text('São Paulo'));
      await tester.tap(find.text('Rio de Janeiro'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(recebido, ['sp', 'rj']);
    });

    testWidgets('mostra os rótulos já selecionados, unidos por vírgula',
        (tester) async {
      await pumpEasy(
        tester,
        Tela(
          child: Select<String>.multi(
            options: _estados,
            values: const ['sp', 'rj'],
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('São Paulo, Rio de Janeiro'), findsOneWidget);
    });
  });
}
