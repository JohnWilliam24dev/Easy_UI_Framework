import 'package:flutter/foundation.dart' show immutable;

import 'unit_context.dart';

/// Tamanho declarativo. Representa um valor acompanhado de sua unidade.
///
/// Subtipos: [Px], [Vw], [Vh], [Percent] e [Fr]. Use as extensões em `num`
/// (`200.px`, `50.vw`, `100.vh`, `30.pct`, `1.fr`) para criá-los.
@immutable
sealed class Dimension {
  const Dimension();

  /// `true` quando a dimensão não tem tamanho próprio e divide o espaço
  /// restante com as demais (caso do [Fr]).
  bool get isFlexible => false;

  /// Converte a dimensão em pixels lógicos.
  double resolve(UnitContext context);
}

/// Pixels lógicos fixos.
final class Px extends Dimension {
  const Px(this.value);

  final double value;

  @override
  double resolve(UnitContext context) => value;

  @override
  bool operator ==(Object other) => other is Px && other.value == value;

  @override
  int get hashCode => Object.hash(Px, value);

  @override
  String toString() => '${value}px';
}

/// Porcentagem da largura da viewport.
final class Vw extends Dimension {
  const Vw(this.value);

  final double value;

  @override
  double resolve(UnitContext context) => context.viewport.width * value / 100;

  @override
  bool operator ==(Object other) => other is Vw && other.value == value;

  @override
  int get hashCode => Object.hash(Vw, value);

  @override
  String toString() => '${value}vw';
}

/// Porcentagem da altura da viewport.
final class Vh extends Dimension {
  const Vh(this.value);

  final double value;

  @override
  double resolve(UnitContext context) => context.viewport.height * value / 100;

  @override
  bool operator ==(Object other) => other is Vh && other.value == value;

  @override
  int get hashCode => Object.hash(Vh, value);

  @override
  String toString() => '${value}vh';
}

/// Porcentagem do elemento pai, no eixo em que é aplicada.
///
/// Exige um pai com extensão finita; caso contrário [resolve] lança
/// [StateError] (não há como calcular "% de infinito").
final class Percent extends Dimension {
  const Percent(this.value);

  final double value;

  @override
  double resolve(UnitContext context) {
    final parent = context.parentExtent;
    if (parent == null || !parent.isFinite) {
      throw StateError(
        'Percent ($value%) precisa de um pai com tamanho finito no eixo em '
        'que foi aplicado (ex: dentro de um scroll o eixo é ilimitado). '
        'Use px, vw ou vh nesse caso.',
      );
    }
    return parent * value / 100;
  }

  @override
  bool operator ==(Object other) => other is Percent && other.value == value;

  @override
  int get hashCode => Object.hash(Percent, value);

  @override
  String toString() => '$value%';
}

/// Fração do espaço disponível, dividida entre todas as dimensões `fr` do
/// mesmo grupo, depois de descontados os tamanhos fixos (como o `fr` do CSS
/// Grid).
///
/// Não converte em pixels isoladamente: a distribuição é feita por quem
/// conhece o grupo (`TrackSolver`, `LayoutEngine`).
final class Fr extends Dimension {
  const Fr(this.factor) : assert(factor > 0, 'O fator de Fr deve ser > 0.');

  final double factor;

  @override
  bool get isFlexible => true;

  @override
  double resolve(UnitContext context) {
    throw UnsupportedError(
      'Fr não converte em pixels isoladamente. Use TrackSolver ou envolva o '
      'filho em LayoutItem dentro de um LayoutEngine.',
    );
  }

  @override
  bool operator ==(Object other) => other is Fr && other.factor == factor;

  @override
  int get hashCode => Object.hash(Fr, factor);

  @override
  String toString() => '${factor}fr';
}
