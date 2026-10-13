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
    this.modal = const ModalStyleSpec(),
    this.nav = const NavStyleSpec(),
    this.kanban = const KanbanStyleSpec(),
    this.listItem = const ListItemStyleSpec(),
    this.motion = const MotionStyleSpec(),
    this.spacingScale = 1,
  }) : assert(spacingScale > 0, 'spacingScale deve ser > 0.');

  /// Pack usado quando não há nenhum `StylePackScope` acima na árvore.
  static const StylePack standard = StylePack(name: 'standard');

  /// Superfícies translúcidas, inputs arredondados e espaçamento arejado.
  static const StylePack glass = StylePack(
    name: 'glass',
    inputText: InputStyleSpec.rounded(radius: 16),
    button: ButtonStyleSpec.pill(),
    card: CardStyleSpec.glass(),
    spacingScale: 1.15,
  );

  /// Aparência compacta para fluxos internos, tabelas e operações densas.
  static const StylePack operational = StylePack(
    name: 'operational',
    inputText: InputStyleSpec.underline(),
    button: ButtonStyleSpec.compact(),
    card: CardStyleSpec.flat(),
    label: LabelStyleSpec.compact(),
    spacingScale: 0.8,
  );

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
    ModalStyleSpec modal = const ModalStyleSpec(),
    NavStyleSpec nav = const NavStyleSpec(),
    KanbanStyleSpec kanban = const KanbanStyleSpec(),
    ListItemStyleSpec listItem = const ListItemStyleSpec(),
    MotionStyleSpec motion = const MotionStyleSpec(),
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
      modal: modal,
      nav: nav,
      kanban: kanban,
      listItem: listItem,
      motion: motion,
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
    if (name == glass.name) return glass;
    if (name == operational.name) return operational;
    throw ArgumentError.value(
      name,
      'name',
      'StylePack não definido. Definidos: ${definedNames.join(', ')}.',
    );
  }

  /// Nomes dos packs disponíveis.
  static List<String> get definedNames => <String>[
    standard.name,
    glass.name,
    operational.name,
    ..._registry.keys,
  ];

  /// Remove todos os packs definidos (só para testes).
  @visibleForTesting
  static void clearRegistry() => _registry.clear();

  final String name;
  final InputStyleSpec inputText;
  final ButtonStyleSpec button;
  final CardStyleSpec card;
  final LabelStyleSpec label;
  final ModalStyleSpec modal;
  final NavStyleSpec nav;
  final KanbanStyleSpec kanban;
  final ListItemStyleSpec listItem;
  final MotionStyleSpec motion;

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
        other.modal == modal &&
        other.nav == nav &&
        other.kanban == kanban &&
        other.listItem == listItem &&
        other.motion == motion &&
        other.spacingScale == spacingScale;
  }

  @override
  int get hashCode => Object.hash(
    name,
    inputText,
    button,
    card,
    label,
    modal,
    nav,
    kanban,
    listItem,
    motion,
    spacingScale,
  );

  @override
  String toString() => 'StylePack($name)';
}
