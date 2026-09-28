import 'package:flutter/foundation.dart' show immutable, visibleForTesting;

import '../tokens/theme_tokens.dart';
import 'specs/specs.dart';

/// Conjunto coerente de variantes visuais aplicadas a vários widgets de uma
/// vez: a "pele" de uma parte do app (ex: área do cliente vs. área
/// operacional do ERP).
///
/// ```dart
/// StylePack.define(
///   name: 'cliente_convidativo',
///   inputText: InputStyleSpec.rounded(radius: 16, elevation: ElevationLevel.subtle),
///   button: ButtonStyleSpec.pill(),
///   spacingScale: 1.2,
/// );
/// ```
///
/// Um pack não conhece widgets do catálogo nem cores; apenas descreve
/// especificações de estilo que o catálogo consome.
@immutable
class StylePack {
  const StylePack({
    required this.name,
    this.inputText = const InputStyleSpec.outline(),
    this.button = const ButtonStyleSpec(),
    this.card = const CardStyleSpec(),
    this.label = const LabelStyleSpec(),
    this.spacingScale = 1,
  }) : assert(spacingScale > 0, 'spacingScale deve ser > 0.');

  /// Pack usado quando não há nenhum `StylePackScope` acima na árvore.
  static const StylePack standard = StylePack(name: 'standard');

  static final Map<String, StylePack> _registry = <String, StylePack>{};

  /// Cria e registra um pack pelo [name]. Definir o mesmo nome de novo
  /// substitui o anterior (útil com hot reload). O nome `standard` é
  /// reservado.
  static StylePack define({
    required String name,
    InputStyleSpec inputText = const InputStyleSpec.outline(),
    ButtonStyleSpec button = const ButtonStyleSpec(),
    CardStyleSpec card = const CardStyleSpec(),
    LabelStyleSpec label = const LabelStyleSpec(),
    double spacingScale = 1,
  }) {
    assert(name.isNotEmpty, 'O nome do StylePack não pode ser vazio.');
    assert(
      name != standard.name,
      'O nome "${standard.name}" é reservado ao pack padrão.',
    );
    final pack = StylePack(
      name: name,
      inputText: inputText,
      button: button,
      card: card,
      label: label,
      spacingScale: spacingScale,
    );
    _registry[name] = pack;
    return pack;
  }

  /// Busca um pack registrado com [define] (ou o `standard`).
  static StylePack byName(String name) {
    final pack = _registry[name];
    if (pack != null) return pack;
    if (name == standard.name) return standard;
    throw ArgumentError.value(
      name,
      'name',
      'StylePack não definido. Definidos: ${definedNames.join(', ')}.',
    );
  }

  /// Nomes dos packs disponíveis.
  static List<String> get definedNames =>
      <String>[standard.name, ..._registry.keys];

  /// Remove todos os packs definidos (só para testes).
  @visibleForTesting
  static void clearRegistry() => _registry.clear();

  final String name;
  final InputStyleSpec inputText;
  final ButtonStyleSpec button;
  final CardStyleSpec card;
  final LabelStyleSpec label;

  /// Multiplicador do espaçamento base: acima de 1 fica mais arejado
  /// (convidativo), abaixo de 1 mais denso (operacional).
  final double spacingScale;

  /// [steps] unidades de espaçamento, já escaladas por este pack.
  double space(ThemeTokens tokens, [double steps = 1]) {
    return tokens.baseSpacing * steps * spacingScale;
  }

  @override
  bool operator ==(Object other) {
    return other is StylePack &&
        other.name == name &&
        other.inputText == inputText &&
        other.button == button &&
        other.card == card &&
        other.label == label &&
        other.spacingScale == spacingScale;
  }

  @override
  int get hashCode =>
      Object.hash(name, inputText, button, card, label, spacingScale);

  @override
  String toString() => 'StylePack($name)';
}
