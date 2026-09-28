import 'package:flutter/widgets.dart';

/// Contexto necessário para converter dimensões declarativas em pixels reais.
///
/// Carrega o tamanho da viewport (usado por `vw` e `vh`) e a extensão do pai
/// no eixo em que a unidade está sendo aplicada (usada por `%`).
///
/// Apenas o Kernel lê `MediaQuery`; as camadas acima recebem valores prontos.
@immutable
class UnitContext {
  const UnitContext({required this.viewport, this.parentExtent});

  /// Cria o contexto lendo a viewport atual via `MediaQuery`.
  factory UnitContext.of(BuildContext context, {double? parentExtent}) {
    return UnitContext(
      viewport: MediaQuery.sizeOf(context),
      parentExtent: parentExtent,
    );
  }

  /// Tamanho da viewport, em pixels lógicos.
  final Size viewport;

  /// Extensão do elemento pai no eixo de aplicação, em pixels lógicos.
  ///
  /// `null` (ou infinito) quando o pai não impõe limite nesse eixo.
  final double? parentExtent;

  /// Cópia deste contexto com outra extensão de pai.
  UnitContext withParentExtent(double? extent) {
    return UnitContext(viewport: viewport, parentExtent: extent);
  }
}
