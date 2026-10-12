import 'package:easy_ui/src/widget_catalog/data/resource_list.dart';
import 'package:easy_ui/src/widget_catalog/inputs/input_field.dart';
import 'package:easy_ui/src/widget_catalog/inputs/form/validators.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  testWidgets('abre editor de criação e envia valores', (tester) async {
    String? saved;
    await pumpEasy(
      tester,
      Tela(
        child: ResourceList<String>(
          title: 'Pessoas',
          items: const [],
          fields: [Field('Nome', (value) => value)],
          editor: (_) => [
            InputField(name: 'name', validation: [isRequired()]),
          ],
          onSave: (values, _) => saved = values.string('name'),
        ),
      ),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Novo').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(saved, 'Ana');
  });
}
