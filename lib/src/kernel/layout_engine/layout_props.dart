import 'package:flutter/widgets.dart';

import '../unit_system/dimension.dart';
import 'layout_engine.dart' show LayoutDirection, LayoutDirectionValue;
import 'layout_position.dart';

/// Propriedades de composição compartilhadas por widgets que usam layout.
///
/// Mantém os widgets do catálogo consistentes sem fazer o Kernel depender de
/// tema ou de widgets de negócio. [direction] também aceita um
/// [ResponsiveDirection] para trocar a direção pela largura disponível do pai.
@immutable
class LayoutProps {
  const LayoutProps({
    this.direction = LayoutDirection.vertical,
    this.position,
    this.align = Alignment.topLeft,
    this.gap,
    this.runGap,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.maxHeight,
    this.padding,
    this.fill = false,
    this.scrollable = false,
    this.stackBelow,
  }) : assert(gap is! Fr, 'gap não pode ser Fr.'),
       assert(runGap is! Fr, 'runGap não pode ser Fr.'),
       assert(width is! Fr, 'width não pode ser Fr.'),
       assert(height is! Fr, 'height não pode ser Fr.'),
       assert(minWidth is! Fr, 'minWidth não pode ser Fr.'),
       assert(maxWidth is! Fr, 'maxWidth não pode ser Fr.'),
       assert(maxHeight is! Fr, 'maxHeight não pode ser Fr.'),
       assert(padding is! Fr, 'padding não pode ser Fr.'),
       assert(stackBelow == null || stackBelow > 0, 'stackBelow deve ser > 0.');

  /// [LayoutDirection] fixa ou valor responsivo por largura do pai.
  final LayoutDirectionValue direction;
  final LayoutPosition? position;
  final Alignment align;
  final Dimension? gap;
  final Dimension? runGap;
  final Dimension? width;
  final Dimension? height;
  final Dimension? minWidth;
  final Dimension? maxWidth;
  final Dimension? maxHeight;
  final Dimension? padding;
  final bool fill;
  final bool scrollable;

  /// Abaixo desta largura, organiza os filhos verticalmente; acima, lado a
  /// lado. É um atalho para o padrão mais frequente de telas responsivas.
  final double? stackBelow;
}
