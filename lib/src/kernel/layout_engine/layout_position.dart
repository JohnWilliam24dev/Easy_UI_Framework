import 'package:flutter/widgets.dart' show Alignment;

/// Posição do próprio [LayoutEngine] em relação ao pai.
///
/// Diferente de `align`, que alinha o conteúdo *dentro* do motor, `position`
/// decide onde o motor fica *dentro do pai*.
///
/// As bordas (`top`, `bottom`, `left`, `right`) centralizam no outro eixo:
/// `right` cola na direita e fica no meio da altura; `top` cola no topo e
/// fica no meio da largura. Para os cantos use `topLeft`, `topRight`,
/// `bottomLeft` e `bottomRight`.
enum LayoutPosition {
  center(Alignment.center),
  top(Alignment.topCenter),
  bottom(Alignment.bottomCenter),
  left(Alignment.centerLeft),
  right(Alignment.centerRight),
  topLeft(Alignment.topLeft),
  topRight(Alignment.topRight),
  bottomLeft(Alignment.bottomLeft),
  bottomRight(Alignment.bottomRight);

  const LayoutPosition(this.alignment);

  /// Alinhamento equivalente dentro do pai.
  final Alignment alignment;
}
