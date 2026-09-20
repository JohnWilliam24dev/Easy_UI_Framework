import 'package:easy_ui/src/theme_layer/style_pack/specs/specs.dart';
import 'package:flutter/widgets.dart' show FontWeight;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputStyleSpec', () {
    test('rounded é outline com raio maior por padrão', () {
      const rounded = InputStyleSpec.rounded();
      expect(rounded.kind, InputStyleKind.outline);
      expect(rounded.radius, 16);
      expect(const InputStyleSpec.outline().radius, 8);
    });

    test('rounded aceita raio e elevação', () {
      const spec = InputStyleSpec.rounded(
        radius: 24,
        elevation: ElevationLevel.subtle,
      );
      expect(spec.radius, 24);
      expect(spec.elevation, ElevationLevel.subtle);
    });

    test('underline não tem raio nem elevação', () {
      const spec = InputStyleSpec.underline();
      expect(spec.kind, InputStyleKind.underline);
      expect(spec.radius, 0);
      expect(spec.elevation, ElevationLevel.none);
    });

    test('filled tem o tipo filled', () {
      expect(const InputStyleSpec.filled().kind, InputStyleKind.filled);
    });

    test('igualdade por valor', () {
      expect(const InputStyleSpec.rounded(), const InputStyleSpec.rounded());
      expect(
        const InputStyleSpec.rounded(),
        isNot(const InputStyleSpec.underline()),
      );
    });
  });

  group('ButtonStyleSpec', () {
    test('pill tem raio de pílula e é maior que compact', () {
      const pill = ButtonStyleSpec.pill();
      const compact = ButtonStyleSpec.compact();
      expect(pill.radius, ButtonStyleSpec.pillRadius);
      expect(pill.minHeight, greaterThan(compact.minHeight));
      expect(pill.horizontalPadding, greaterThan(compact.horizontalPadding));
    });

    test('padrão e igualdade', () {
      const padrao = ButtonStyleSpec();
      expect(padrao.fontWeight, FontWeight.w600);
      expect(padrao, const ButtonStyleSpec());
      expect(padrao, isNot(const ButtonStyleSpec.pill()));
    });
  });

  group('CardStyleSpec e LabelStyleSpec', () {
    test('card plano não tem elevação', () {
      expect(const CardStyleSpec.flat().elevation, ElevationLevel.none);
      expect(const CardStyleSpec().elevation, ElevationLevel.subtle);
    });

    test('label compacto tem escala menor que a padrão', () {
      const padrao = LabelStyleSpec();
      const compacto = LabelStyleSpec.compact();
      expect(compacto.titleScale, lessThan(padrao.titleScale));
      expect(compacto, isNot(padrao));
    });
  });

  test('ElevationLevel cresce com o nível', () {
    expect(ElevationLevel.none.dp, 0);
    expect(ElevationLevel.subtle.dp, lessThan(ElevationLevel.medium.dp));
    expect(ElevationLevel.medium.dp, lessThan(ElevationLevel.high.dp));
  });
}
