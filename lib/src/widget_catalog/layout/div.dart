import 'package:flutter/widgets.dart';

import '../../kernel/kernel.dart';
import '../../theme_layer/theme_layer.dart';

/// Contêiner de layout: no lugar de Container + Row/Column/Stack + Padding +
/// Align, um único widget.
///
/// - [direction]: `vertical` (padrão), `horizontal` ou `layered`;
/// - [align]: alinhamento do conteúdo *dentro* do Div;
/// - [position]: onde o próprio Div fica *dentro do pai*;
/// - [gap]: espaço entre filhos. Se omitido, vem do tema:
///   `2 x baseSpacing x spacingScale` do `StylePack` ativo (use `0.px` para
///   remover);
/// - [width] / [height]: aceitam `px`, `vw`, `vh` e `pct`;
/// - para filhos com tamanho relativo (`fr`), envolva-os em `LayoutItem`.
///
/// ```dart
/// Div(
///   position: LayoutPosition.center,
///   width: 50.vw,
///   children: [Label(text: 'Oi'), Button(text: 'Ok')],
/// )
/// ```
class Div extends StatelessWidget {
  const Div({
    super.key,
    this.children = const <Widget>[],
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
       assert(padding is! Fr, 'padding não pode ser Fr.');

  final List<Widget> children;

  /// Direção fixa ou [ResponsiveDirection] para a largura disponível do pai.
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
  final double? stackBelow;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);

    final layout = LayoutProps(
      direction: direction,
      position: position,
      align: align,
      gap: gap ?? Px(pack.space(tokens, 2)),
      runGap: runGap,
      width: width,
      height: height,
      minWidth: minWidth,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      padding: padding,
      fill: fill,
      scrollable: scrollable,
      stackBelow: stackBelow,
    );

    return LayoutEngine(
      direction: layout.direction,
      position: layout.position,
      align: layout.align,
      gap: layout.gap,
      runGap: layout.runGap,
      width: layout.width,
      height: layout.height,
      minWidth: layout.minWidth,
      maxWidth: layout.maxWidth,
      maxHeight: layout.maxHeight,
      padding: layout.padding,
      fill: layout.fill,
      scrollable: layout.scrollable,
      stackBelow: layout.stackBelow,
      children: children,
    );
  }
}
