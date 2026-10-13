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
    this.minCellWidth,
    this.cellHeight,
  }) : assert(minCell > 0, 'minCell deve ser > 0.'),
       assert(maxCell >= minCell, 'maxCell deve ser >= minCell.'),
       assert(cellRatio > 0, 'cellRatio deve ser > 0.'),
       _itemCount = null,
       _itemBuilder = null;

  final List<Widget> children;
  final int minCell;
  final int maxCell;
  final double cellRatio;
  final Dimension? gap;
  final bool scrollable;

  /// Breakpoints usados na interpolação. Padrão: `Breakpoints.standard`.
  final Breakpoints? breakpoints;

  /// Grade que calcula automaticamente a quantidade de colunas a partir da
  /// largura mínima desejada para cada célula.
  const Grid.fit({
    super.key,
    required this.children,
    required this.minCellWidth,
    this.cellHeight,
    this.gap,
    this.scrollable = false,
  }) : minCell = 1,
       maxCell = 1,
       cellRatio = 1,
       breakpoints = null,
       _itemCount = null,
       _itemBuilder = null,
       assert(
         minCellWidth == null || minCellWidth > 0,
         'minCellWidth deve ser > 0.',
       );

  final double? minCellWidth;
  final double? cellHeight;

  /// Versão preguiçosa do Grid: cria somente os itens visíveis.
  const Grid.builder({
    super.key,
    required int itemCount,
    required NullableIndexedWidgetBuilder itemBuilder,
    required this.minCell,
    required this.maxCell,
    this.cellRatio = 1,
    this.gap,
    this.scrollable = false,
    this.breakpoints,
  }) : children = const <Widget>[],
       _itemCount = itemCount,
       _itemBuilder = itemBuilder,
       minCellWidth = null,
       cellHeight = null,
       assert(itemCount >= 0, 'itemCount deve ser >= 0.'),
       assert(minCell > 0, 'minCell deve ser > 0.'),
       assert(maxCell >= minCell, 'maxCell deve ser >= minCell.'),
       assert(cellRatio > 0, 'cellRatio deve ser > 0.');

  final int? _itemCount;
  final NullableIndexedWidgetBuilder? _itemBuilder;
  int get _resolvedItemCount => _itemCount ?? children.length;
  Widget _buildItem(BuildContext context, int index) {
    final builder = _itemBuilder;
    return builder == null ? children[index] : builder(context, index)!;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);
    final resolver = ResponsiveResolver(
      breakpoints: breakpoints ?? Breakpoints.standard,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gapPx = (gap ?? Px(pack.space(tokens, 2))).resolve(
          UnitContext.of(context, parentExtent: width),
        );
        final fit = minCellWidth;
        if (fit != null) {
          final columns = ((width + gapPx) / (fit + gapPx)).floor().clamp(
            1,
            99,
          );
          return GridView.builder(
            shrinkWrap: !scrollable,
            physics: scrollable ? null : const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: cellHeight == null
                ? SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: gapPx,
                    crossAxisSpacing: gapPx,
                  )
                : SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: cellHeight,
                    mainAxisSpacing: gapPx,
                    crossAxisSpacing: gapPx,
                  ),
            itemCount: _resolvedItemCount,
            itemBuilder: _buildItem,
          );
        }
        final columns = resolver.interpolateInt(
          width,
          atMin: minCell,
          atMax: maxCell,
        );

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
          itemCount: _resolvedItemCount,
          itemBuilder: _buildItem,
        );
      },
    );
  }
}
