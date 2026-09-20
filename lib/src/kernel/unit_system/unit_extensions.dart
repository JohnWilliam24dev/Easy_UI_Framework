import 'dimension.dart';

/// Açúcar sintático para criar [Dimension]s a partir de números.
///
/// ```dart
/// 200.px   // pixels fixos
/// 50.vw    // 50% da largura da viewport
/// 100.vh   // 100% da altura da viewport
/// 30.pct   // 30% do elemento pai
/// 1.fr     // 1 fração do espaço restante
/// ```
///
/// Observação: o Dart não permite `%` como nome de getter, por isso a
/// porcentagem do pai é `.pct`. Como são getters, não podem ser usados em
/// contextos `const`.
extension UnitNumExtension on num {
  Px get px => Px(toDouble());
  Vw get vw => Vw(toDouble());
  Vh get vh => Vh(toDouble());
  Percent get pct => Percent(toDouble());
  Fr get fr => Fr(toDouble());
}
