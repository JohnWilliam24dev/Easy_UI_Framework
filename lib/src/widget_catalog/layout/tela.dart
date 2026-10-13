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
    this.title,
    this.onBack,
    this.actions = const <Widget>[],
    this.background,
    this.maxWidth,
  });

  final Widget child;
  final bool scrollable;
  final Dimension? padding;
  final String? title;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final Widget? background;
  final Dimension? maxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);

    final resolvedPadding = (padding ?? Px(pack.space(tokens, 2))).resolve(
      UnitContext.of(context),
    );

    final hasHeader = title != null || onBack != null || actions.isNotEmpty;
    Widget pageChild = child;
    if (hasHeader) {
      pageChild = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                ),
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      color: tokens.headingColor,
                      fontSize: tokens.baseFontSize * 1.4,
                      fontFamily: tokens.fontFamily,
                    ),
                  ),
                ),
              ...actions,
            ],
          ),
          if (scrollable) child else Expanded(child: child),
        ],
      );
    }
    Widget content = Padding(
      padding: EdgeInsets.all(resolvedPadding),
      child: pageChild,
    );
    final maximum = maxWidth?.resolve(UnitContext.of(context));
    if (maximum != null) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maximum),
          child: content,
        ),
      );
    }
    if (scrollable) {
      content = SingleChildScrollView(child: content);
    }

    final body = SafeArea(child: content);
    return Scaffold(
      backgroundColor: tokens.backgroundColor,
      body: background == null
          ? body
          : Stack(fit: StackFit.expand, children: [background!, body]),
    );
  }
}
