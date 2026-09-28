import 'package:easy_ui/src/kernel/environment/platform_brightness.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lê o brilho da plataforma via MediaQuery', (tester) async {
    Brightness? lido;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(platformBrightness: Brightness.dark),
        child: Builder(
          builder: (context) {
            lido = platformBrightnessOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(lido, Brightness.dark);
  });

  testWidgets('sem MediaQuery devolve claro', (tester) async {
    Brightness? lido;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          lido = platformBrightnessOf(context);
          return const SizedBox();
        },
      ),
    );
    expect(lido, Brightness.light);
  });
}
