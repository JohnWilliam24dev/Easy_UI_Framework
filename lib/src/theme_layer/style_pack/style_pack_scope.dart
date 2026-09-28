import 'package:flutter/widgets.dart';

import 'style_pack.dart';

/// Propaga qual [StylePack] está ativo em uma subárvore.
///
/// Os widgets do catálogo consultam o pack ativo automaticamente; não é
/// preciso declarar estilo em cada widget. Escopos aninhados: vale o mais
/// próximo.
class StylePackScope extends InheritedWidget {
  const StylePackScope({super.key, required this.pack, required super.child});

  /// Usa um pack registrado com `StylePack.define`.
  factory StylePackScope.named(
    String name, {
    Key? key,
    required Widget child,
  }) {
    return StylePackScope(
      key: key,
      pack: StylePack.byName(name),
      child: child,
    );
  }

  final StylePack pack;

  /// Pack ativo, ou `StylePack.standard` se não houver escopo acima.
  static StylePack of(BuildContext context) {
    return maybeOf(context) ?? StylePack.standard;
  }

  /// Pack do escopo mais próximo, ou `null` se não houver.
  static StylePack? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StylePackScope>()?.pack;
  }

  @override
  bool updateShouldNotify(StylePackScope oldWidget) => pack != oldWidget.pack;
}
