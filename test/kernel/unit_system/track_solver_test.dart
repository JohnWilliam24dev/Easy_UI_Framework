import 'package:easy_ui/src/kernel/unit_system/unit_system.dart';
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';

void main() {
  const context = UnitContext(viewport: Size(400, 800));

  test('reparte o restante proporcionalmente entre fr', () {
    final sizes = TrackSolver.solve(
      [200.px, 1.fr, 3.fr],
      available: 1000,
      context: context,
    );
    expect(sizes, [200, 200, 600]);
  });

  test('desconta o gap entre as trilhas', () {
    final sizes = TrackSolver.solve(
      [200.px, 1.fr, 3.fr],
      available: 1000,
      context: context,
      gap: 10,
    );
    // 1000 - 200 - (2 gaps * 10) = 780 -> 195 e 585
    expect(sizes, [200, 195, 585]);
  });

  test('fr aceita fatores fracionários', () {
    final sizes = TrackSolver.solve(
      [1.5.fr, 0.5.fr],
      available: 400,
      context: context,
    );
    expect(sizes, [300, 100]);
  });

  test('pct nas trilhas é relativo ao espaço disponível', () {
    final sizes = TrackSolver.solve(
      [50.pct, 1.fr],
      available: 400,
      context: context,
    );
    expect(sizes, [200, 200]);
  });

  test('vw e vh nas trilhas usam a viewport', () {
    final sizes = TrackSolver.solve(
      [25.vw, 1.fr],
      available: 1000,
      context: context,
    );
    expect(sizes, [100, 900]);
  });

  test('trilhas fixas que estouram o espaço deixam fr com 0', () {
    final sizes = TrackSolver.solve(
      [800.px, 1.fr],
      available: 500,
      context: context,
    );
    expect(sizes, [800, 0]);
  });

  test('sem fr, apenas resolve as trilhas fixas', () {
    final sizes = TrackSolver.solve(
      [100.px, 10.vw],
      available: 500,
      context: context,
    );
    expect(sizes, [100, 40]);
  });

  test('lista vazia devolve lista vazia', () {
    expect(
      TrackSolver.solve(const [], available: 500, context: context),
      isEmpty,
    );
  });

  test('espaço disponível inválido lança ArgumentError', () {
    expect(
      () => TrackSolver.solve(
        [1.fr],
        available: double.infinity,
        context: context,
      ),
      throwsArgumentError,
    );
    expect(
      () => TrackSolver.solve([1.fr], available: -1, context: context),
      throwsArgumentError,
    );
  });
}
