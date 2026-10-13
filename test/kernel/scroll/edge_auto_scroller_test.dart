import 'package:easy_ui/src/kernel/scroll/scroll.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scroller = EdgeAutoScroller(activationDistance: 40, maxStep: 20);
  const bounds = Rect.fromLTWH(0, 100, 200, 300);

  test('calcula velocidade proporcional perto das bordas', () {
    expect(scroller.deltaFor(const Offset(50, 100), bounds), -20);
    expect(scroller.deltaFor(const Offset(50, 120), bounds), -10);
    expect(scroller.deltaFor(const Offset(50, 380), bounds), 10);
    expect(scroller.deltaFor(const Offset(50, 250), bounds), 0);
  });

  test('não ativa fora da área', () {
    expect(scroller.deltaFor(const Offset(50, 99), bounds), 0);
    expect(scroller.deltaFor(const Offset(50, 401), bounds), 0);
  });
}
