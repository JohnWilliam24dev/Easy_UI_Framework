import 'package:easy_ui/src/kernel/layout_engine/layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mainAxisFromAlignment mapeia início, centro e fim', () {
    expect(mainAxisFromAlignment(-1), MainAxisAlignment.start);
    expect(mainAxisFromAlignment(-0.2), MainAxisAlignment.center);
    expect(mainAxisFromAlignment(0), MainAxisAlignment.center);
    expect(mainAxisFromAlignment(0.2), MainAxisAlignment.center);
    expect(mainAxisFromAlignment(1), MainAxisAlignment.end);
  });

  test('crossAxisFromAlignment mapeia início, centro e fim', () {
    expect(crossAxisFromAlignment(-1), CrossAxisAlignment.start);
    expect(crossAxisFromAlignment(0), CrossAxisAlignment.center);
    expect(crossAxisFromAlignment(0.5), CrossAxisAlignment.end);
  });

  test('Alignment.center e topLeft convertem como esperado', () {
    expect(mainAxisFromAlignment(Alignment.center.y), MainAxisAlignment.center);
    expect(crossAxisFromAlignment(Alignment.center.x),
        CrossAxisAlignment.center);
    expect(mainAxisFromAlignment(Alignment.topLeft.y), MainAxisAlignment.start);
    expect(crossAxisFromAlignment(Alignment.topLeft.x),
        CrossAxisAlignment.start);
  });
}
