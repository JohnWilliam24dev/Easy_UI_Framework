// ignore_for_file: prefer_const_constructors

import 'package:easy_ui/src/kernel/responsive/responsive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = ResponsiveResolver();

  group('breakpoints', () {
    test('classifica larguras nas bordas', () {
      expect(resolver.sizeFor(0), ScreenSize.mobile);
      expect(resolver.sizeFor(599.9), ScreenSize.mobile);
      expect(resolver.sizeFor(600), ScreenSize.tablet);
      expect(resolver.sizeFor(1023.9), ScreenSize.tablet);
      expect(resolver.sizeFor(1024), ScreenSize.desktop);
      expect(resolver.sizeFor(3000), ScreenSize.desktop);
    });

    test('aceita breakpoints customizados', () {
      const custom = ResponsiveResolver(
        breakpoints: Breakpoints(tabletMin: 500, desktopMin: 900),
      );
      expect(custom.sizeFor(550), ScreenSize.tablet);
      expect(custom.sizeFor(900), ScreenSize.desktop);
    });

    test('rejeita configuração inválida', () {
      expect(
        () => Breakpoints(tabletMin: 1000, desktopMin: 500),
        throwsAssertionError,
      );
      expect(
        () => Breakpoints(interpolationStart: 800, interpolationEnd: 400),
        throwsAssertionError,
      );
    });
  });

  group('interpolação (faixa padrão 360 a 1440)', () {
    test('devolve as pontas nos limites', () {
      expect(resolver.interpolate(360, atMin: 3, atMax: 6), 3);
      expect(resolver.interpolate(1440, atMin: 3, atMax: 6), 6);
    });

    test('interpola linearmente no meio', () {
      expect(resolver.interpolate(900, atMin: 3, atMax: 6), closeTo(4.5, 1e-9));
      expect(
        resolver.interpolate(630, atMin: 3, atMax: 6),
        closeTo(3.75, 1e-9),
      );
    });

    test('não extrapola fora da faixa', () {
      expect(resolver.interpolate(200, atMin: 3, atMax: 6), 3);
      expect(resolver.interpolate(2560, atMin: 3, atMax: 6), 6);
    });

    test('interpolateInt arredonda para o inteiro mais próximo', () {
      expect(resolver.interpolateInt(360, atMin: 3, atMax: 6), 3);
      expect(resolver.interpolateInt(630, atMin: 3, atMax: 6), 4);
      expect(resolver.interpolateInt(900, atMin: 3, atMax: 6), 5);
      expect(resolver.interpolateInt(1440, atMin: 3, atMax: 6), 6);
    });

    test('a contagem de colunas nunca decresce ao alargar a tela', () {
      var anterior = 0;
      for (var w = 300.0; w <= 1600; w += 10) {
        final colunas = resolver.interpolateInt(w, atMin: 3, atMax: 6);
        expect(colunas, greaterThanOrEqualTo(anterior));
        anterior = colunas;
      }
    });
  });

  group('ResponsiveValue', () {
    test('usa o valor declarado para cada tamanho', () {
      const v = ResponsiveValue<int>(mobile: 1, tablet: 2, desktop: 3);
      expect(v.resolve(ScreenSize.mobile), 1);
      expect(v.resolve(ScreenSize.tablet), 2);
      expect(v.resolve(ScreenSize.desktop), 3);
    });

    test('faz fallback: desktop -> tablet -> mobile', () {
      const soMobile = ResponsiveValue<int>(mobile: 1);
      expect(soMobile.resolve(ScreenSize.tablet), 1);
      expect(soMobile.resolve(ScreenSize.desktop), 1);

      const semDesktop = ResponsiveValue<int>(mobile: 1, tablet: 2);
      expect(semDesktop.resolve(ScreenSize.desktop), 2);
    });

    test('pick resolve a partir da largura', () {
      const v = ResponsiveValue<String>(mobile: 'a', desktop: 'c');
      expect(resolver.pick(500, v), 'a');
      expect(resolver.pick(800, v), 'a');
      expect(resolver.pick(1200, v), 'c');
    });
  });
}
