import 'package:flutter/widgets.dart';

import 'breakpoints.dart';
import 'responsive_resolver.dart';
import 'responsive_value.dart';

/// Escolhe uma subárvore pela largura disponível do pai.
///
/// Diferentemente de consultar a viewport, adapta corretamente cards, painéis
/// laterais e outros conteúdos com largura restrita. [breakAt] permite usar
/// limiares locais sem espalhar `LayoutBuilder` pelas telas.
class Responsive extends StatelessWidget {
  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.breakAt,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  /// Breakpoints usados somente por esta composição. O padrão é
  /// [Breakpoints.standard].
  final Breakpoints? breakAt;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolver = ResponsiveResolver(
          breakpoints: breakAt ?? Breakpoints.standard,
        );
        return resolver.pick(
          constraints.maxWidth,
          ResponsiveValue<Widget>(
            mobile: mobile,
            tablet: tablet,
            desktop: desktop,
          ),
        );
      },
    );
  }
}
