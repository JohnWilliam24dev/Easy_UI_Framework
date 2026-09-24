import 'package:flutter/widgets.dart';

import '../../kernel/kernel.dart';
import '../../theme_layer/theme_layer.dart';

/// Grade responsiva para elementos de tamanho uniforme (ex: cards de
/// pedidos). Não é masonry/Pinterest — os itens têm altura consistente.
///
/// Resolve o overflow comum do `GridView` nativo (causado por
/// `childAspectRatio` fixo que não acompanha a largura da tela):
///
/// 1. mede a largura disponível;
/// 2. calcula o número de colunas por interpolação suave entre [minCell]
///    (colunas no menor breakpoint) e [maxCell] (colunas no maior),
///    sem saltos discretos;
/// 3. cada célula usa [cellRatio] (largura:altura) para a altura.
///
/// Não existe widget `Cell`: os filhos são widgets normais do catálogo
/// (tipicamente `Card`).
///
/// Por padrão o Grid se ajusta ao conteúdo (`shrinkWrap`) para caber dentro
/// de uma `Tela(scrollable: true)`; use [scrollable] para ele rolar sozinho.
///
/// ```dart
/// Grid(minCell: 3, maxCell: 6, cellRatio: 1.2, children: [Card(...), ...])
/// ```
class Grid extends StatelessWidget {
  const Grid({
    super.key,
    required this.children,
    required this.minCell,
    required this.maxCell,
    this.cellRatio = 1,
    this.gap,
    this.scrollable = false,
    this.breakpoints,
  })  : assert(minCell > 0, 'minCell deve ser > 0.'),
        assert(maxCell >= minCell, 'maxCell deve ser >= minCell.'),
        assert(cellRatio > 0, 'cellRatio deve ser > 0.');

  final List<Widget> children;
  final int minCell;
  final int maxCell;
  final double cellRatio;
  final Dimension? gap;
  final bool scrollable;

  /// Breakpoints usados na interpolação. Padrão: `Breakpoints.standard`.
  final Breakpoints? breakpoints;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);
    final resolver = ResponsiveResolver(breakpoints: breakpoints ?? Breakpoints.standard);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = resolver.interpolateInt(
          width,
          atMin: minCell,
          atMax: maxCell,
        );
        final gapPx = (gap ?? Px(pack.space(tokens, 2)))
            .resolve(UnitContext.of(context, parentExtent: width));

        return GridView.builder(
          shrinkWrap: !scrollable,
          physics: scrollable ? null : const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: cellRatio,
            mainAxisSpacing: gapPx,
            crossAxisSpacing: gapPx,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
