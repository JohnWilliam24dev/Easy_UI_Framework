import 'package:easy_ui/src/kernel/environment/view_insets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lê os insets do sistema via MediaQuery', (tester) async {
    EdgeInsets? lido;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 280)),
        child: Builder(
          builder: (context) {
            lido = viewInsetsOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(lido, const EdgeInsets.only(bottom: 280));
  });

  testWidgets('sem MediaQuery devolve zero', (tester) async {
    EdgeInsets? lido;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          lido = viewInsetsOf(context);
          return const SizedBox();
        },
      ),
    );
    expect(lido, EdgeInsets.zero);
  });
}
