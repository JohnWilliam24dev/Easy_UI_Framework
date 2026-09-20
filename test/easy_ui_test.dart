import 'package:easy_ui/easy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('barrel exporta as unidades declarativas', () {
    expect(50.vw, const Vw(50));
    expect(100.vh, const Vh(100));
    expect(30.pct, const Percent(30));
    expect(200.px, const Px(200));
    expect(1.fr, const Fr(1));
  });
}
