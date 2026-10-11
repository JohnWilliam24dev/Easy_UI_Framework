import 'package:flutter/animation.dart' show Curve, Curves;
import 'package:flutter/widgets.dart' show immutable;

@immutable
class MotionStyleSpec {
  const MotionStyleSpec({
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOut,
    this.stagger = const Duration(milliseconds: 45),
  });
  final Duration duration, stagger;
  final Curve curve;
  @override
  bool operator ==(Object other) =>
      other is MotionStyleSpec &&
      other.duration == duration &&
      other.curve == curve &&
      other.stagger == stagger;
  @override
  int get hashCode => Object.hash(duration, curve, stagger);
}
