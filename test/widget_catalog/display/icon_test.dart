import 'package:easy_ui/src/widget_catalog/display/icon.dart' as easy;
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart' as flutter;
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  testWidgets('tamanho e cor padrão vêm do tema', (tester) async {
    await pumpEasy(tester, easy.Icon(Icons.search).let((i) => Tela(child: i)));
    final icon = tester.widget<flutter.Icon>(find.byType(flutter.Icon));
    expect(icon.size, closeTo(14 * 1.5, 1e-9));
    expect(icon.color, testTokens.textColor);
  });

  testWidgets('size e color são respeitados', (tester) async {
    await pumpEasy(
      tester,
      Tela(
        child: easy.Icon(
          Icons.star,
          size: 40,
          color: (tokens) => tokens.primaryColor,
        ),
      ),
    );
    final icon = tester.widget<flutter.Icon>(find.byType(flutter.Icon));
    expect(icon.size, 40);
    expect(icon.color, testTokens.primaryColor);
  });
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
