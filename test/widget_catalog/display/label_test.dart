import 'package:easy_ui/src/theme_layer/theme_layer.dart';
import 'package:easy_ui/src/widget_catalog/display/label.dart';
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  const spec = LabelStyleSpec();

  group('labelStyleFor', () {
    test('title: maior, negrito e cor de texto', () {
      final style = labelStyleFor(
        tokens: testTokens,
        spec: spec,
        type: LabelType.title,
      );
      expect(style.fontSize, closeTo(14 * 1.75, 1e-9));
      expect(style.fontWeight, FontWeight.w700);
      expect(style.color, testTokens.textColor);
    });

    test('caption: menor e com cor de texto secundário', () {
      final style = labelStyleFor(
        tokens: testTokens,
        spec: spec,
        type: LabelType.caption,
      );
      expect(style.fontSize, closeTo(14 * 0.85, 1e-9));
      expect(style.color, testTokens.mutedTextColor);
    });

    test('error usa a cor de erro', () {
      final style = labelStyleFor(
        tokens: testTokens,
        spec: spec,
        type: LabelType.error,
      );
      expect(style.color, testTokens.errorColor);
    });

    test('a escala vem do pack e a fonte vem do tema', () {
      final tokens = testTokens.copyWith(fontFamily: 'Poppins');
      final style = labelStyleFor(
        tokens: tokens,
        spec: const LabelStyleSpec.compact(),
        type: LabelType.title,
      );
      expect(style.fontSize, closeTo(14 * 1.4, 1e-9));
      expect(style.fontFamily, 'Poppins');
    });
  });

  group('Label', () {
    testWidgets('renderiza o texto com o estilo do tipo', (tester) async {
      await pumpEasy(
        tester,
        const Tela(child: Label(type: LabelType.title, text: 'Login')),
      );
      final text = tester.widget<Text>(find.text('Login'));
      expect(text.style?.fontSize, closeTo(24.5, 1e-9));
      expect(text.style?.color, testTokens.textColor);
    });

    testWidgets('usa a escala do pack ativo', (tester) async {
      await pumpEasy(
        tester,
        const Tela(child: Label(type: LabelType.title, text: 'Login')),
        pack: const StylePack(name: 'denso', label: LabelStyleSpec.compact()),
      );
      final text = tester.widget<Text>(find.text('Login'));
      expect(text.style?.fontSize, closeTo(19.6, 1e-9));
    });

    testWidgets('maxLines aplica reticências', (tester) async {
      await pumpEasy(
        tester,
        const Tela(child: Label(text: 'texto', maxLines: 1)),
      );
      final text = tester.widget<Text>(find.text('texto'));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });
}
