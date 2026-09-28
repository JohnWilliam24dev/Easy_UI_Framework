import 'package:flutter/material.dart' show Checkbox, Radio, Switch;
import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';

/// Comportamento visual do [Toggle].
enum ToggleType { checkbox, switch_, radio }

/// Unificação de Checkbox, Switch e Radio num único widget, controlada por
/// [type]. As cores vêm sempre dos tokens.
///
/// - `checkbox` e `switch_`: [value] é o estado atual (`bool`) e
///   [onChanged] recebe o novo estado;
/// - `radio`: [value] é o valor **desta** opção, [groupValue] é o valor
///   selecionado no grupo, e [onChanged] é chamado com [value] quando esta
///   opção é escolhida. Várias opções com o mesmo tipo `T` e o mesmo
///   [groupValue] formam um grupo.
///
/// ```dart
/// Toggle(type: ToggleType.switch_, value: ativo, onChanged: (v) => ...)
/// Toggle(type: ToggleType.checkbox, value: aceito, onChanged: (v) => ...)
/// Toggle<String>(type: ToggleType.radio, value: 'pix',
///     groupValue: metodo, onChanged: (v) => ...)
/// ```
class Toggle<T> extends StatelessWidget {
  const Toggle({
    super.key,
    this.type = ToggleType.checkbox,
    required this.value,
    this.groupValue,
    required this.onChanged,
    this.enabled = true,
  }) : assert(
          type == ToggleType.radio || value is bool,
          'checkbox e switch_ exigem value do tipo bool.',
        );

  final ToggleType type;
  final T value;

  /// Só usado quando [type] é `radio`.
  final T? groupValue;

  final ValueChanged<T>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final handler = enabled ? onChanged : null;

    return switch (type) {
      ToggleType.checkbox => Checkbox(
          value: value as bool,
          onChanged: handler == null
              ? null
              : (v) => handler(v as T),
          activeColor: tokens.primaryColor,
          checkColor: tokens.onPrimaryColor,
        ),
      ToggleType.switch_ => Switch(
          value: value as bool,
          onChanged: handler == null
              ? null
              : (v) => handler(v as T),
          activeThumbColor: tokens.onPrimaryColor,
          activeTrackColor: tokens.primaryColor,
        ),
      // `groupValue`/`onChanged` diretos no Radio foram descontinuados a
      // favor de um `RadioGroup` ancestral em versões recentes do Flutter,
      // mas o pubspec deste pacote ainda suporta SDKs anteriores a isso.
      // ignore: deprecated_member_use
      ToggleType.radio => Radio<T>(
          value: value,
          // ignore: deprecated_member_use
          groupValue: groupValue,
          // ignore: deprecated_member_use
          onChanged: handler == null
              ? null
              : (v) {
                  if (v != null) handler(v);
                },
          activeColor: tokens.primaryColor,
        ),
    };
  }
}
