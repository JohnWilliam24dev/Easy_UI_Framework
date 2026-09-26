import 'package:easy_ui/src/widget_catalog/inputs/toggle.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  group('checkbox', () {
    testWidgets('mostra o valor e a cor ativa vem do tema', (tester) async {
      await pumpEasy(
        tester,
        Tela(child: Toggle(type: ToggleType.checkbox, value: true, onChanged: (_) {})),
      );
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
      expect(checkbox.activeColor, testTokens.primaryColor);
    });

    testWidgets('onChanged recebe o novo valor', (tester) async {
      bool? recebido;
      await pumpEasy(
        tester,
        Tela(
          child: Toggle(
            type: ToggleType.checkbox,
            value: false,
            onChanged: (v) => recebido = v,
          ),
        ),
      );
      await tester.tap(find.byType(Checkbox));
      expect(recebido, isTrue);
    });

    testWidgets('enabled: false desabilita', (tester) async {
      await pumpEasy(
        tester,
        Tela(
          child: Toggle(
            type: ToggleType.checkbox,
            value: false,
            enabled: false,
            onChanged: (_) {},
          ),
        ),
      );
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
    });
  });

  group('switch_', () {
    testWidgets('mostra o valor e alterna ao tocar', (tester) async {
      bool? recebido;
      await pumpEasy(
        tester,
        Tela(
          child: Toggle(
            type: ToggleType.switch_,
            value: false,
            onChanged: (v) => recebido = v,
          ),
        ),
      );
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      await tester.tap(find.byType(Switch));
      expect(recebido, isTrue);
    });
  });

  group('radio', () {
    testWidgets('mostra selecionado quando value == groupValue',
        (tester) async {
      await pumpEasy(
        tester,
        Tela(
          child: Toggle<String>(
            type: ToggleType.radio,
            value: 'pix',
            groupValue: 'pix',
            onChanged: (_) {},
          ),
        ),
      );
      final radio = tester.widget<Radio<String>>(find.byType(Radio<String>));
      expect(radio.value, radio.groupValue);
    });

    testWidgets('tocar chama onChanged com o value desta opção',
        (tester) async {
      String? selecionado;
      await pumpEasy(
        tester,
        Tela(
          child: Toggle<String>(
            type: ToggleType.radio,
            value: 'cartao',
            groupValue: 'pix',
            onChanged: (v) => selecionado = v,
          ),
        ),
      );
      await tester.tap(find.byType(Radio<String>));
      expect(selecionado, 'cartao');
    });

    testWidgets('duas opções formam um grupo coerente', (tester) async {
      String selecionado = 'pix';
      await pumpEasy(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            return Tela(
              child: Column(
                children: [
                  Toggle<String>(
                    type: ToggleType.radio,
                    value: 'pix',
                    groupValue: selecionado,
                    onChanged: (v) => setState(() => selecionado = v),
                  ),
                  Toggle<String>(
                    type: ToggleType.radio,
                    value: 'cartao',
                    groupValue: selecionado,
                    onChanged: (v) => setState(() => selecionado = v),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final radios = find.byType(Radio<String>);
      await tester.tap(radios.at(1));
      await tester.pump();

      final atualizados = tester.widgetList<Radio<String>>(radios).toList();
      expect(atualizados[0].groupValue, 'cartao');
      expect(atualizados[1].groupValue, 'cartao');
    });
  });
}
