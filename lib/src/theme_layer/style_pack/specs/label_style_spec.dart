import 'package:flutter/widgets.dart' show FontWeight, immutable;

/// Escala tipográfica dos textos (`Label`). Os fatores multiplicam o
/// `baseFontSize` do tema.
@immutable
class LabelStyleSpec {
  const LabelStyleSpec({
    this.titleScale = 1.75,
    this.subtitleScale = 1.25,
    this.bodyScale = 1,
    this.captionScale = 0.85,
    this.titleWeight = FontWeight.w700,
    this.subtitleWeight = FontWeight.w600,
  });

  /// Escala reduzida, para telas densas.
  const LabelStyleSpec.compact()
      : titleScale = 1.4,
        subtitleScale = 1.15,
        bodyScale = 1,
        captionScale = 0.8,
        titleWeight = FontWeight.w700,
        subtitleWeight = FontWeight.w600;

  final double titleScale;
  final double subtitleScale;
  final double bodyScale;
  final double captionScale;
  final FontWeight titleWeight;
  final FontWeight subtitleWeight;

  @override
  bool operator ==(Object other) {
    return other is LabelStyleSpec &&
        other.titleScale == titleScale &&
        other.subtitleScale == subtitleScale &&
        other.bodyScale == bodyScale &&
        other.captionScale == captionScale &&
        other.titleWeight == titleWeight &&
        other.subtitleWeight == subtitleWeight;
  }

  @override
  int get hashCode => Object.hash(
        titleScale,
        subtitleScale,
        bodyScale,
        captionScale,
        titleWeight,
        subtitleWeight,
      );
}
