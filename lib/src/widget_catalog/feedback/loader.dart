import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';
import '../display/label.dart';
import '../layout/div.dart';

/// Onde o [Loader] aparece.
enum LoaderMode {
  /// Ocupa o espaço do widget (ex: dentro de um `Center` no lugar do
  /// conteúdo enquanto ele carrega).
  inline,

  /// Cobre toda a área do `Stack` mais próximo com um véu e bloqueia
  /// toques. **Só funciona como filho direto de um `Stack`** — coloque o
  /// conteúdo normal como primeiro filho e o `Loader` depois, condicionado
  /// ao estado de carregamento.
  overlay,
}

/// Indicador de carregamento: `CircularProgressIndicator` na cor primária
/// do tema, com uma mensagem opcional.
///
/// ```dart
/// // Dentro do conteúdo normal:
/// Center(child: Loader())
///
/// // Bloqueando a tela toda enquanto salva:
/// Stack(
///   children: [
///     conteudo,
///     if (salvando) const Loader(mode: LoaderMode.overlay, message: 'Salvando...'),
///   ],
/// )
/// ```
class Loader extends StatelessWidget {
  const Loader({super.key, this.mode = LoaderMode.inline, this.message});

  final LoaderMode mode;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final content = Div(
      align: Alignment.center,
      gap: 12.px,
      children: [
        CircularProgressIndicator(color: tokens.primaryColor),
        if (message != null) Label(type: LabelType.caption, text: message!),
      ],
    );

    if (mode == LoaderMode.inline) return Center(child: content);

    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          // Véu na própria cor de fundo do tema: escurece/clareia sem
          // depender de saber se o tema ativo é claro ou escuro.
          color: tokens.backgroundColor.withValues(alpha: 0.75),
          child: Center(child: content),
        ),
      ),
    );
  }
}
