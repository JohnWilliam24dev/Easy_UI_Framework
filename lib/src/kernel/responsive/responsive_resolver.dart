import 'package:flutter/widgets.dart';

import 'breakpoints.dart';
import 'responsive_value.dart';

/// Toda a lógica de responsividade do framework.
///
/// As camadas acima nunca leem `MediaQuery` para decidir layout: pedem ao
/// resolver, seja passando uma largura (métodos puros, fáceis de testar) ou
/// um `BuildContext`.
@immutable
class ResponsiveResolver {
  const ResponsiveResolver({this.breakpoints = Breakpoints.standard});

  final Breakpoints breakpoints;

  /// [ScreenSize] correspondente a uma largura.
  ScreenSize sizeFor(double width) => breakpoints.sizeFor(width);

  /// [ScreenSize] da viewport atual.
  ScreenSize sizeOf(BuildContext context) {
    return sizeFor(MediaQuery.sizeOf(context).width);
  }

  /// Valor de um [ResponsiveValue] para a largura informada.
  T pick<T>(double width, ResponsiveValue<T> value) {
    return value.resolve(sizeFor(width));
  }

  /// Interpola linearmente entre [atMin] e [atMax] conforme [width] varia de
  /// `interpolationStart` a `interpolationEnd`. Fora da faixa, o valor fica
  /// preso nas pontas (sem extrapolar).
  double interpolate(
    double width, {
    required double atMin,
    required double atMax,
  }) {
    final span = breakpoints.interpolationEnd - breakpoints.interpolationStart;
    final t = ((width - breakpoints.interpolationStart) / span)
        .clamp(0.0, 1.0)
        .toDouble();
    return atMin + (atMax - atMin) * t;
  }

  /// Igual a [interpolate], mas arredondando para inteiro (ex: nº de colunas).
  int interpolateInt(
    double width, {
    required int atMin,
    required int atMax,
  }) {
    return interpolate(
      width,
      atMin: atMin.toDouble(),
      atMax: atMax.toDouble(),
    ).round();
  }
}
