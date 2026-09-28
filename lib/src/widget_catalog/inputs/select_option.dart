import 'package:flutter/foundation.dart' show immutable;

/// Uma opção de um [Select]: o valor real e o rótulo exibido.
@immutable
class SelectOption<T> {
  const SelectOption(this.value, this.label);

  final T value;
  final String label;

  @override
  bool operator ==(Object other) {
    return other is SelectOption<T> &&
        other.value == value &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(value, label);
}
