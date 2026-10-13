import 'package:easy_ui/src/kernel/responsive/responsive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('escolhe a subárvore pela largura do pai', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Responsive(
          mobile: SizedBox(key: Key('mobile')),
          desktop: SizedBox(key: Key('desktop')),
          breakAt: Breakpoints(tabletMin: 400, desktopMin: 700),
        ),
      ),
    );
    expect(find.byKey(const Key('mobile')), findsOneWidget);

    await tester.binding.setSurfaceSize(const Size(1200, 600));
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Responsive(
          mobile: SizedBox(key: Key('mobile')),
          desktop: SizedBox(key: Key('desktop')),
          breakAt: Breakpoints(tabletMin: 400, desktopMin: 700),
        ),
      ),
    );
    expect(find.byKey(const Key('desktop')), findsOneWidget);
  });
}
