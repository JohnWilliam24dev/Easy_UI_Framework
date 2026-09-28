// ignore_for_file: prefer_const_constructors

import 'package:easy_ui/src/kernel/unit_system/unit_system.dart';
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';

void main() {
  const context = UnitContext(viewport: Size(400, 800), parentExtent: 300);

  group('conversão em pixels', () {
    test('px devolve o próprio valor', () {
      expect(12.px.resolve(context), 12);
    });

    test('vw é porcentagem da largura da viewport', () {
      expect(50.vw.resolve(context), 200);
      expect(100.vw.resolve(context), 400);
    });

    test('vh é porcentagem da altura da viewport', () {
      expect(10.vh.resolve(context), 80);
      expect(100.vh.resolve(context), 800);
    });

    test('vw e vh acompanham mudanças de viewport', () {
      const wide = UnitContext(viewport: Size(1200, 600));
      expect(50.vw.resolve(wide), 600);
      expect(50.vh.resolve(wide), 300);
    });

    test('pct é porcentagem da extensão do pai', () {
      expect(50.pct.resolve(context), 150);
      expect(100.pct.resolve(context), 300);
    });

    test('pct sem pai (ou com pai infinito) lança StateError', () {
      const semPai = UnitContext(viewport: Size(400, 800));
      const infinito = UnitContext(
        viewport: Size(400, 800),
        parentExtent: double.infinity,
      );
      expect(() => 50.pct.resolve(semPai), throwsStateError);
      expect(() => 50.pct.resolve(infinito), throwsStateError);
    });

    test('fr não converte isoladamente e é flexível', () {
      expect(() => 1.fr.resolve(context), throwsUnsupportedError);
      expect(1.fr.isFlexible, isTrue);
      expect(1.px.isFlexible, isFalse);
    });

    test('fr exige fator positivo', () {
      expect(() => Fr(0), throwsAssertionError);
      expect(() => Fr(-1), throwsAssertionError);
    });
  });

  group('extensões em num', () {
    test('criam as dimensões corretas', () {
      expect(200.px, const Px(200));
      expect(50.vw, const Vw(50));
      expect(100.vh, const Vh(100));
      expect(30.pct, const Percent(30));
      expect(2.5.fr, const Fr(2.5));
    });

    test('igualdade considera tipo e valor', () {
      expect(50.vw, isNot(50.vh));
      expect(50.vw, isNot(60.vw));
      expect(50.vw.hashCode, 50.vw.hashCode);
    });
  });
}
