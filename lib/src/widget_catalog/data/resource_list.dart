import 'dart:async';

import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../actions/button.dart';
import '../actions/icon_action.dart';
import '../display/list_item.dart';
import '../feedback/empty_state.dart';
import '../feedback/modal.dart';
import '../inputs/form/validators.dart';
import '../layout/section.dart';

class Field<T> {
  const Field(this.label, this.value);
  final String label;
  final String Function(T item) value;
}

/// Cadastro CRUD controlado: lista, editor validado e exclusão confirmada.
class ResourceList<T> extends StatelessWidget {
  const ResourceList({
    super.key,
    required this.title,
    required this.items,
    required this.fields,
    this.description,
    this.editor,
    this.initialValuesFor,
    this.onSave,
    this.onDelete,
    this.canDelete,
    this.deleteBlockedMessage,
    this.newLabel = 'Novo',
    this.editLabel = 'Editar',
    this.deleteLabel = 'Excluir',
    this.emptyBuilder,
    this.onTap,
  });

  final String title;
  final String? description;
  final List<T> items;
  final List<Field<T>> fields;
  final List<Widget> Function(T? item)? editor;
  final Map<String, Object?> Function(T item)? initialValuesFor;
  final FutureOr<void> Function(FormValues values, T? existing)? onSave;
  final FutureOr<void> Function(T item)? onDelete;
  final bool Function(T item)? canDelete;
  final String? Function(T item)? deleteBlockedMessage;
  final String newLabel, editLabel, deleteLabel;
  final WidgetBuilder? emptyBuilder;
  final ValueChanged<T>? onTap;

  bool get _canEdit => editor != null && onSave != null;

  Future<void> _openEditor(BuildContext context, T? item) async {
    final makeEditor = editor;
    final save = onSave;
    if (makeEditor == null || save == null) return;
    await Modal.form<void>(
      context,
      title: item == null ? newLabel : editLabel,
      initialValues: item == null
          ? const <String, Object?>{}
          : (initialValuesFor?.call(item) ?? const <String, Object?>{}),
      adaptive: true,
      fields: (_) => makeEditor(item),
      onSubmit: (values) async {
        await save(values, item);
        return;
      },
    );
  }

  Future<void> _delete(BuildContext context, T item) async {
    final allowed = canDelete?.call(item) ?? true;
    if (!allowed) {
      final message = deleteBlockedMessage?.call(item);
      if (message != null) await Modal.alert(context, title: message);
      return;
    }
    final confirmed = await Modal.confirm(
      context,
      title: '$deleteLabel ${fields.first.value(item)}?',
      message: 'Esta ação não pode ser desfeita.',
      confirmText: deleteLabel,
      destructive: true,
    );
    if (confirmed == true) await onDelete!(item);
  }

  @override
  Widget build(BuildContext context) => Section(
    title: title,
    subtitle: description,
    action: _canEdit
        ? Button(
            text: newLabel,
            icon: Icons.add,
            onPressed: () => _openEditor(context, null),
          )
        : null,
    child: items.isEmpty
        ? (emptyBuilder?.call(context) ??
              EmptyState(
                action: _canEdit
                    ? Button(
                        text: newLabel,
                        onPressed: () => _openEditor(context, null),
                      )
                    : null,
              ))
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListItem(
                title: fields.first.value(item),
                subtitle: fields
                    .skip(1)
                    .map((field) => '${field.label}: ${field.value(item)}')
                    .join(' · '),
                trailing: _canEdit || onDelete != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_canEdit)
                            IconAction(
                              icon: Icons.edit_outlined,
                              tooltip: editLabel,
                              onPressed: () => _openEditor(context, item),
                            ),
                          if (onDelete != null)
                            IconAction(
                              icon: Icons.delete_outline,
                              tooltip: deleteLabel,
                              onPressed: () => _delete(context, item),
                            ),
                        ],
                      )
                    : null,
                onTap: onTap == null ? null : () => onTap!(item),
              );
            },
          ),
  );
}
