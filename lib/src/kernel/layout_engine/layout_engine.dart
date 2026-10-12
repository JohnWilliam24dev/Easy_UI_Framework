import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../responsive/breakpoints.dart' show ScreenSize;
import '../responsive/responsive_resolver.dart';
import '../responsive/responsive_value.dart';
import '../unit_system/unit_system.dart';
import 'alignment_mapper.dart';
import 'layout_position.dart';

/// Como o [LayoutEngine] organiza os filhos.
enum LayoutDirection implements LayoutDirectionValue {
  /// Um abaixo do outro (Column).
  vertical,

  /// Lado a lado (Row).
  horizontal,

  /// Sobrepostos (Stack).
  layered,

  /// Filhos em linhas que quebram quando não há mais espaço horizontal.
  wrap,
}

/// Direção fixa ([LayoutDirection]) ou adaptada à largura do pai
/// ([ResponsiveDirection]). Tipo selado: o compilador recusa qualquer outro.
sealed class LayoutDirectionValue {}

/// Direção que muda conforme o [ScreenSize] da largura disponível do pai.
/// Tablet cai para mobile e desktop cai para tablet quando não declarados.
///
/// ```dart
/// Div(direction: ResponsiveDirection(mobile: LayoutDirection.vertical, desktop: LayoutDirection.horizontal))
/// ```
@immutable
final class ResponsiveDirection implements LayoutDirectionValue {
  const ResponsiveDirection({required this.mobile, this.tablet, this.desktop});

  final LayoutDirection mobile;
  final LayoutDirection? tablet;
  final LayoutDirection? desktop;

  LayoutDirection resolve(ScreenSize size) => ResponsiveValue<LayoutDirection>(
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  ).resolve(size);
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
/// - [position] posiciona o próprio motor dentro do pai; quando definida, o
///   motor se ajusta ao conteúdo no eixo principal (a menos que `width`/
///   `height` sejam declarados), senão ocuparia o pai inteiro e a posição
///   não teria efeito visível;
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

  final List<Widget> children;

  /// Direção fixa ou uma [ResponsiveDirection] resolvida pela largura do pai.
  final LayoutDirectionValue direction;

  /// Onde o motor fica dentro do pai. `null` deixa o pai decidir.
  final LayoutPosition? position;

  /// Alinhamento do conteúdo dentro do motor. Em Column/Row vira
  /// main/cross axis alignment; em Stack é o alinhamento dos filhos.
  final Alignment align;

  /// Espaço entre filhos consecutivos (ignorado em `layered`).
  final Dimension? gap;
  final Dimension? runGap;

  /// Largura do motor. `null` deixa o pai decidir.
  final Dimension? width;

  /// Altura do motor. `null` deixa o pai decidir.
  final Dimension? height;
  final Dimension? minWidth;
  final Dimension? maxWidth;
  final Dimension? maxHeight;
  final Dimension? padding;
  final bool fill;
  final bool scrollable;
  final double? stackBelow;

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
        final resolvedMinWidth = minWidth?.resolve(widthContext);
        final resolvedMaxWidth = maxWidth?.resolve(widthContext);
        final resolvedMaxHeight = maxHeight?.resolve(heightContext);
        final resolvedPadding = padding?.resolve(widthContext) ?? 0;
        final resolvedDirection = _resolveDirection(constraints.maxWidth);

        // Extensão real disponível para o conteúdo, já respeitando as
        // restrições do pai (um SizedBox não pode passar do que o pai permite).
        final availableWidth = resolvedMaxWidth == null
            ? constraints.maxWidth
            : math.min(constraints.maxWidth, resolvedMaxWidth);
        final availableHeight = resolvedMaxHeight == null
            ? constraints.maxHeight
            : math.min(constraints.maxHeight, resolvedMaxHeight);
        final innerWidth = resolvedWidth != null
            ? constraints.constrainWidth(resolvedWidth)
            : availableWidth;
        final innerHeight = resolvedHeight != null
            ? constraints.constrainHeight(resolvedHeight)
            : availableHeight;

        Widget content = _buildContent(
          base,
          innerWidth - (resolvedPadding * 2),
          innerHeight - (resolvedPadding * 2),
          resolvedDirection,
        );
        if (resolvedPadding > 0) {
          content = Padding(
            padding: EdgeInsets.all(resolvedPadding),
            child: content,
          );
        }
        if (scrollable) {
          content = SingleChildScrollView(child: content);
        }

        Widget result = content;
        if (resolvedWidth != null || resolvedHeight != null) {
          result = SizedBox(
            width: resolvedWidth,
            height: resolvedHeight,
            child: content,
          );
        }

        if (resolvedMinWidth != null ||
            resolvedMaxWidth != null ||
            resolvedMaxHeight != null) {
          result = ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: resolvedMinWidth ?? 0,
              maxWidth: resolvedMaxWidth ?? double.infinity,
              maxHeight: resolvedMaxHeight ?? double.infinity,
            ),
            child: result,
          );
          result = Align(alignment: Alignment.topCenter, child: result);
        }

        final placement = position;
        if (placement == null) return result;
        return Align(alignment: placement.alignment, child: result);
      },
    );
  }

  LayoutDirection _resolveDirection(double parentWidth) {
    if (stackBelow != null) {
      return parentWidth < stackBelow!
          ? LayoutDirection.vertical
          : LayoutDirection.horizontal;
    }
    return switch (direction) {
      final LayoutDirection fixed => fixed,
      final ResponsiveDirection responsive => responsive.resolve(
        const ResponsiveResolver().sizeFor(parentWidth),
      ),
    };
  }

  Widget _buildContent(
    UnitContext base,
    double innerWidth,
    double innerHeight,
    LayoutDirection resolvedDirection,
  ) {
    if (resolvedDirection == LayoutDirection.layered) {
      return Stack(
        alignment: align,
        children: [
          for (final child in children)
            if (child is LayoutItem) child.child else child,
        ],
      );
    }

    if (resolvedDirection == LayoutDirection.wrap) {
      final widthContext = base.withParentExtent(innerWidth);
      final gapExtent = gap?.resolve(widthContext) ?? 0;
      final runGapExtent = runGap?.resolve(widthContext) ?? gapExtent;
      return Wrap(
        spacing: gapExtent,
        runSpacing: runGapExtent,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final child in children) _sizeWrapChild(child, widthContext),
        ],
      );
    }

    final vertical = resolvedDirection == LayoutDirection.vertical;
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

    final mainSize = position == null ? MainAxisSize.max : MainAxisSize.min;
    final mainAlign = mainAxisFromAlignment(vertical ? align.y : align.x);
    final crossAlign = fill
        ? CrossAxisAlignment.stretch
        : crossAxisFromAlignment(vertical ? align.x : align.y);

    return vertical
        ? Column(
            mainAxisSize: mainSize,
            mainAxisAlignment: mainAlign,
            crossAxisAlignment: crossAlign,
            children: items,
          )
        : Row(
            mainAxisSize: mainSize,
            mainAxisAlignment: mainAlign,
            crossAxisAlignment: crossAlign,
            children: items,
          );
  }

  Widget _sizeWrapChild(Widget child, UnitContext widthContext) {
    if (child is! LayoutItem || child.size is Fr) {
      return child is LayoutItem ? child.child : child;
    }
    return SizedBox(
      width: child.size.resolve(widthContext),
      child: child.child,
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
