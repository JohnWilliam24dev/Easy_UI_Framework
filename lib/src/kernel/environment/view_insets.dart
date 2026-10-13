import 'package:flutter/widgets.dart';

/// Áreas da tela ocupadas pelo sistema (ex: teclado aberto).
///
/// Fica no Kernel porque apenas ele lê `MediaQuery`. Sem `MediaQuery` acima
/// na árvore, devolve [EdgeInsets.zero].
EdgeInsets viewInsetsOf(BuildContext context) {
  return MediaQuery.maybeViewInsetsOf(context) ?? EdgeInsets.zero;
}
