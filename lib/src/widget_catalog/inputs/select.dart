import 'package:flutter/material.dart';

import '../../theme_layer/theme_layer.dart';
import 'input_decoration_builder.dart';
import 'select_option.dart';

/// Campo de seleção: DropdownButton (seleção única) ou um diálogo com
/// caixas de marcação (seleção múltipla), com a mesma decoração visual do
/// `InputField`.
///
/// ```dart
/// Select<String>.single(
///   options: [SelectOption('sp', 'São Paulo'), SelectOption('rj', 'Rio de Janeiro')],
///   value: estado,
///   onChanged: (v) => setState(() => estado = v),
/// )
///
/// Select<String>.multi(
///   options: [SelectOption('tela', 'Tela'), SelectOption('escultura', 'Escultura')],
///   values: tecnicas,
///   onChanged: (v) => setState(() => tecnicas = v),
/// )
/// ```
class Select<T> extends StatelessWidget {
  /// Seleção única: [value] é o selecionado (ou `null`) e [onChanged]
  /// recebe o novo valor.
  const Select.single({
    super.key,
    required this.options,
    this.value,
    required ValueChanged<T?> onChanged,
    this.hint,
    this.enabled = true,
  })  : _isMulti = false,
        _onSingleChanged = onChanged,
        values = const [],
        _onMultiChanged = null;

  /// Seleção múltipla: [values] são os selecionados e [onChanged] recebe a
  /// nova lista.
  const Select.multi({
    super.key,
    required this.options,
    this.values = const [],
    required ValueChanged<List<T>> onChanged,
    this.hint,
    this.enabled = true,
  })  : _isMulti = true,
        _onMultiChanged = onChanged,
        value = null,
        _onSingleChanged = null;

  final List<SelectOption<T>> options;
  final T? value;
  final List<T> values;
  final String? hint;
  final bool enabled;

  final bool _isMulti;
  final ValueChanged<T?>? _onSingleChanged;
  final ValueChanged<List<T>>? _onMultiChanged;

  String _labelFor(T value) {
    return options.firstWhere((o) => o.value == value).label;
  }

  Future<void> _openMultiPicker(BuildContext context, ThemeTokens tokens) async {
    final selecao = Set<T>.of(values);
    final resultado = await showDialog<Set<T>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return SimpleDialog(
              backgroundColor: tokens.surfaceColor,
              children: [
                for (final option in options)
                  CheckboxListTile(
                    value: selecao.contains(option.value),
                    title: Text(
                      option.label,
                      style: TextStyle(color: tokens.textColor),
                    ),
                    activeColor: tokens.primaryColor,
                    onChanged: (marcado) {
                      setState(() {
                        if (marcado ?? false) {
                          selecao.add(option.value);
                        } else {
                          selecao.remove(option.value);
                        }
                      });
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(selecao),
                      child: Text(
                        'OK',
                        style: TextStyle(color: tokens.primaryColor),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    if (resultado != null) {
      _onMultiChanged!(options.map((o) => o.value).where(resultado.contains).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final pack = StylePackScope.of(context);
    final decoration = buildInputDecoration(tokens: tokens, pack: pack, hint: hint);
    final textStyle = TextStyle(
      color: tokens.textColor,
      fontSize: tokens.baseFontSize,
      fontFamily: tokens.fontFamily,
    );

    if (_isMulti) {
      final texto = values.isEmpty ? (hint ?? '') : values.map(_labelFor).join(', ');
      return InkWell(
        onTap: enabled ? () => _openMultiPicker(context, tokens) : null,
        child: InputDecorator(
          decoration: decoration,
          isEmpty: values.isEmpty,
          child: Text(
            texto,
            style: values.isEmpty
                ? TextStyle(color: tokens.mutedTextColor, fontFamily: tokens.fontFamily)
                : textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: decoration,
      dropdownColor: tokens.surfaceColor,
      style: textStyle,
      iconEnabledColor: tokens.mutedTextColor,
      onChanged: enabled ? _onSingleChanged : null,
      items: [
        for (final option in options)
          DropdownMenuItem(value: option.value, child: Text(option.label)),
      ],
    );
  }
}
