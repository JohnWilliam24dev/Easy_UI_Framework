import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../unit_system/unit_system.dart';
import 'alignment_mapper.dart';

/// Como o [LayoutEngine] organiza os filhos.
enum LayoutDirection {
  /// Um abaixo do outro (Column).
  vertical,

  /// Lado a lado (Row).
  horizontal,

  /// Sobrepostos (Stack).
  layered,
}

/// Declara o tamanho de um filho no eixo principal do [LayoutEngine].
///
/// - `px`, `vw`, `vh`, `pct`: o filho ocupa exatamente esse tamanho;
/// - `fr`: o filho divide o espaço restante com os demais `fr`.
///
/// Precisa ser filho direto do [LayoutEngine] para ter efeito. Em
/// [LayoutDirection.layered] o tamanho é ignorado.
class LayoutItem extends StatelessWidget {
  const LayoutItem({super.key, required this.size, required this.child});

  final Dimension size;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Motor bruto de layout por trás do `Div`.
///
/// Escolhe internamente entre Column, Row e Stack a partir de [direction],
/// converte as unidades declarativas em pixels e resolve `fr` sem exigir
/// `Expanded`/`Flexible` do desenvolvedor.
///
/// Observações:
/// - usa `LayoutBuilder` para conhecer o pai (necessário para `pct` e `fr`),
///   portanto não suporta consultas de dimensão intrínseca (ex: dentro de
///   `IntrinsicHeight`);
/// - `fr` só divide espaço quando o eixo principal é limitado; em eixo
///   ilimitado (ex: dentro de um scroll) o filho mantém seu tamanho natural.
class LayoutEngine extends StatelessWidget {
  const LayoutEngine({
    super.key,
    required this.children,
    this.direction = LayoutDirection.vertical,
    this.align = Alignment.topLeft,
    this.gap,
    this.width,
    this.height,
  })  : assert(gap is! Fr, 'gap não pode ser Fr.'),
        assert(width is! Fr, 'width não pode ser Fr.'),
        assert(height is! Fr, 'height não pode ser Fr.');

  final List<Widget> children;
  final LayoutDirection direction;

  /// Alinhamento do conteúdo dentro do motor. Em Column/Row vira
  /// main/cross axis alignment; em Stack é o alinhamento dos filhos.
  final Alignment align;

  /// Espaço entre filhos consecutivos (ignorado em `layered`).
  final Dimension? gap;

  /// Largura do motor. `null` deixa o pai decidir.
  final Dimension? width;

  /// Altura do motor. `null` deixa o pai decidir.
  final Dimension? height;

  /// Precisão usada para converter o fator do `fr` no `flex` inteiro do
  /// Flutter (permite fatores como 1.5).
  static const int _flexPrecision = 1000;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final base = UnitContext.of(context);
        final widthContext = base.withParentExtent(constraints.maxWidth);
        final heightContext = base.withParentExtent(constraints.maxHeight);

        final resolvedWidth = width?.resolve(widthContext);
        final resolvedHeight = height?.resolve(heightContext);

        // Extensão real disponível para o conteúdo, já respeitando as
        // restrições do pai (um SizedBox não pode passar do que o pai permite).
        final innerWidth = resolvedWidth != null
            ? constraints.constrainWidth(resolvedWidth)
            : constraints.maxWidth;
        final innerHeight = resolvedHeight != null
            ? constraints.constrainHeight(resolvedHeight)
            : constraints.maxHeight;

        final content = _buildContent(base, innerWidth, innerHeight);

        if (resolvedWidth == null && resolvedHeight == null) return content;
        return SizedBox(
          width: resolvedWidth,
          height: resolvedHeight,
          child: content,
        );
      },
    );
  }

  Widget _buildContent(UnitContext base, double innerWidth, double innerHeight) {
    if (direction == LayoutDirection.layered) {
      return Stack(
        alignment: align,
        children: [
          for (final child in children)
            if (child is LayoutItem) child.child else child,
        ],
      );
    }

    final vertical = direction == LayoutDirection.vertical;
    final mainExtent = vertical ? innerHeight : innerWidth;
    final mainContext = base.withParentExtent(mainExtent);
    final canFlex = mainExtent.isFinite;
    final gapExtent = gap?.resolve(mainContext) ?? 0;

    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0 && gapExtent > 0) {
        items.add(
          vertical ? SizedBox(height: gapExtent) : SizedBox(width: gapExtent),
        );
      }
      items.add(_sizeChild(children[i], mainContext, vertical, canFlex));
    }

    final mainAlign = mainAxisFromAlignment(vertical ? align.y : align.x);
    final crossAlign = crossAxisFromAlignment(vertical ? align.x : align.y);

    return vertical
        ? Column(
            mainAxisAlignment: mainAlign,
            crossAxisAlignment: crossAlign,
            children: items,
          )
        : Row(
            mainAxisAlignment: mainAlign,
            crossAxisAlignment: crossAlign,
            children: items,
          );
  }

  Widget _sizeChild(
    Widget child,
    UnitContext mainContext,
    bool vertical,
    bool canFlex,
  ) {
    if (child is! LayoutItem) return child;

    final size = child.size;
    if (size is Fr) {
      // Em eixo ilimitado não existe "espaço restante": mantém o tamanho natural.
      if (!canFlex) return child.child;
      final flex = math.max(1, (size.factor * _flexPrecision).round());
      return Expanded(flex: flex, child: child.child);
    }

    final extent = size.resolve(mainContext);
    return vertical
        ? SizedBox(height: extent, child: child.child)
        : SizedBox(width: extent, child: child.child);
  }
}
