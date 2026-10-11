import 'package:flutter/widgets.dart';

/// Calcula e aplica rolagem automática próxima às bordas de uma área.
///
/// A velocidade cresce linearmente à medida que o ponteiro se aproxima da
/// borda. A classe não conhece drag-and-drop: pode ser usada por qualquer
/// lista ou painel rolável.
class EdgeAutoScroller {
  const EdgeAutoScroller({this.activationDistance = 48, this.maxStep = 18})
    : assert(activationDistance > 0),
      assert(maxStep > 0);

  final double activationDistance;
  final double maxStep;

  /// Delta vertical para [pointer] dentro de [bounds]. Retorna zero fora da
  /// zona de ativação ou quando o ponteiro está fora da área.
  double deltaFor(Offset pointer, Rect bounds) {
    if (!bounds.contains(pointer)) return 0;
    final fromTop = pointer.dy - bounds.top;
    if (fromTop < activationDistance) {
      return -maxStep * (1 - fromTop / activationDistance);
    }
    final fromBottom = bounds.bottom - pointer.dy;
    if (fromBottom < activationDistance) {
      return maxStep * (1 - fromBottom / activationDistance);
    }
    return 0;
  }

  /// Aplica um passo de rolagem, respeitando os limites do controller.
  void scrollBy(ScrollController controller, double delta) {
    if (!controller.hasClients || delta == 0) return;
    final position = controller.position;
    final target = (position.pixels + delta)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (target != position.pixels) controller.jumpTo(target);
  }
}
