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
    this.width,
    this.height,
  })  : assert(gap is! Fr, 'gap não pode ser Fr.'),
        assert(width is! Fr, 'width não pode ser Fr.'),
        assert(height is! Fr, 'height não pode ser Fr.');

  final List<Widget> children;
  final LayoutDirection direction;
  final LayoutPosition? position;
  final Alignment align;
  final Dimension? gap;
  final Dimension? width;
  final Dimension? height;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);

    return LayoutEngine(
      direction: direction,
      position: position,
      align: align,
      gap: gap ?? Px(pack.space(tokens, 2)),
      width: width,
      height: height,
      children: children,
    );
  }
}
