import 'package:flutter/widgets.dart' show BuildContext;

/// Contrato genérico: "resolver um valor `T` dado um contexto".
///
/// O Kernel não sabe o que é tema nem `StylePack`; apenas define esta
/// interface. A Theme Layer (camada 2) a implementa concretamente, o que
/// preserva a regra de dependência (o Kernel nunca conhece o conceito de tema).
abstract interface class StyleResolver<T> {
  T resolve(BuildContext context);
}
