import 'dart:math' as math;

import 'dimension.dart';
import 'unit_context.dart';

/// Resolve uma lista de dimensões (trilhas) em pixels, dividindo o espaço
/// restante entre as trilhas `fr`.
///
/// Algoritmo (mesma ideia do CSS Grid):
/// 1. resolve as trilhas fixas (`px`, `vw`, `vh`, `%`);
/// 2. desconta trilhas fixas e espaçamentos do espaço disponível;
/// 3. reparte o que sobrou proporcionalmente ao fator de cada `fr`.
///
/// Se as trilhas fixas já estouram o espaço, as `fr` recebem 0.
abstract final class TrackSolver {
  static List<double> solve(
    List<Dimension> tracks, {
    required double available,
    required UnitContext context,
    double gap = 0,
  }) {
    if (!available.isFinite || available < 0) {
      throw ArgumentError.value(
        available,
        'available',
        'O espaço disponível deve ser finito e >= 0.',
      );
    }

    // `%` nas trilhas é relativo ao espaço disponível do contêiner.
    final trackContext = context.withParentExtent(available);
    final totalGap = gap * math.max(0, tracks.length - 1);
    final sizes = List<double>.filled(tracks.length, 0);

    var fixedTotal = 0.0;
    var frTotal = 0.0;
    for (var i = 0; i < tracks.length; i++) {
      final track = tracks[i];
      if (track is Fr) {
        frTotal += track.factor;
      } else {
        sizes[i] = track.resolve(trackContext);
        fixedTotal += sizes[i];
      }
    }

    if (frTotal > 0) {
      final remaining = math.max(0.0, available - fixedTotal - totalGap);
      for (var i = 0; i < tracks.length; i++) {
        final track = tracks[i];
        if (track is Fr) {
          sizes[i] = remaining * track.factor / frTotal;
        }
      }
    }
    return sizes;
  }
}
