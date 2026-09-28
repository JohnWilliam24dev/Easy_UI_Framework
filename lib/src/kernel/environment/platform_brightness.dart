import 'package:flutter/widgets.dart';

/// Brilho (claro/escuro) preferido pela plataforma.
///
/// Fica no Kernel porque apenas ele lê `MediaQuery`. Sem `MediaQuery` acima
/// na árvore, devolve [Brightness.light].
Brightness platformBrightnessOf(BuildContext context) {
  return MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
}
