/// Níveis de elevação (sombra) semânticos, independentes de widget.
enum ElevationLevel {
  none(0),
  subtle(2),
  medium(6),
  high(12);

  const ElevationLevel(this.dp);

  /// Elevação em pixels lógicos, para quem monta a sombra.
  final double dp;
}
