import 'package:flutter/widgets.dart';

import '../display/list_item.dart';
import '../feedback/empty_state.dart';
import '../layout/section.dart';

class Field<T> {
  const Field(this.label, this.value);
  final String label;
  final String Function(T item) value;
}

/// Lista CRUD composicional. A persistência continua no repositório do app.
class ResourceList<T> extends StatelessWidget {
  const ResourceList({
    super.key,
    required this.title,
    required this.items,
    required this.fields,
    this.description,
    this.onTap,
    this.emptyBuilder,
  });
  final String title;
  final String? description;
  final List<T> items;
  final List<Field<T>> fields;
  final ValueChanged<T>? onTap;
  final WidgetBuilder? emptyBuilder;
  @override
  Widget build(BuildContext context) => Section(
    title: title,
    subtitle: description,
    child: items.isEmpty
        ? (emptyBuilder?.call(context) ?? const EmptyState())
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final primary = fields.first;
              return ListItem(
                title: primary.value(item),
                subtitle: fields
                    .skip(1)
                    .map((field) => '${field.label}: ${field.value(item)}')
                    .join(' · '),
                onTap: onTap == null ? null : () => onTap!(item),
              );
            },
          ),
  );
}
