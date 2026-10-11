import 'dart:typed_data';

import 'package:easy_ui/src/widget_catalog/actions/button.dart';
import 'package:easy_ui/src/widget_catalog/inputs/form/form_group.dart';
import 'package:easy_ui/src/widget_catalog/inputs/form/validators.dart';
import 'package:easy_ui/src/widget_catalog/inputs/image_field.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  testWidgets('ImageField valida, seleciona e envia bytes', (tester) async {
    FormValues? submitted;
    final bytes = Uint8List.fromList([1, 2, 3]);
    await pumpEasy(
      tester,
      Tela(
        child: FormGroup(
          onSubmit: (values) => submitted = values,
          children: [
            ImageField(
              name: 'photo',
              onPick: () async => bytes,
              validation: [isRequiredValue()],
            ),
            const Button(text: 'Salvar'),
          ],
        ),
      ),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pump();
    expect(find.text('Campo obrigatório'), findsOneWidget);
    await tester.tap(find.byType(ImageField));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pump();
    expect(submitted?.get<Uint8List>('photo'), bytes);
  });
}
