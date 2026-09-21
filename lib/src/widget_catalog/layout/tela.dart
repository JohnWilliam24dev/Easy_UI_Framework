import 'package:flutter/material.dart';

import '../../kernel/kernel.dart';
import '../../theme_layer/theme_layer.dart';

/// Tela do app: Scaffold + SafeArea + fundo do tema.
///
/// - [padding]: margem interna uniforme (`px`, `vw` ou `vh`; `pct` não é
///   suportado aqui). Se omitido, vem do tema: `2 x baseSpacing x
///   spacingScale`. Use `0.px` para encostar nas bordas;
/// - [scrollable]: envolve o conteúdo em rolagem vertical.
///
/// Ainda não tem `appBar`; entra junto da primeira tela que precisar dele.
class Tela extends StatelessWidget {
  const Tela({
    super.key,
    required this.child,
    this.scrollable = false,
    this.padding,
  });

  final Widget child;
  final bool scrollable;
  final Dimension? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);

    final resolvedPadding = (padding ?? Px(pack.space(tokens, 2)))
        .resolve(UnitContext.of(context));

    Widget content = Padding(
      padding: EdgeInsets.all(resolvedPadding),
      child: child,
    );
    if (scrollable) {
      content = SingleChildScrollView(child: content);
    }

    return Scaffold(
      backgroundColor: tokens.backgroundColor,
      body: SafeArea(child: content),
    );
  }
}
