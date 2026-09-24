import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import 'order.dart';

/// Card de um pedido: avatar do cliente, nome, valor e status — mostra
/// Avatar, Badge, Icon e Divider juntos.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final Order order;

  BadgeColor get _badgeColor => switch (order.status) {
        OrderStatus.pending => BadgeColor.warning,
        OrderStatus.inProgress => BadgeColor.info,
        OrderStatus.done => BadgeColor.success,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Div(
        children: [
          Div(
            direction: LayoutDirection.horizontal,
            align: Alignment.centerLeft,
            children: [
              Avatar(name: order.cliente, size: AvatarSize.sm),
              LayoutItem(
                size: 1.fr,
                child: Label(type: LabelType.subtitle, text: order.cliente),
              ),
              Badge(text: order.status.label, color: _badgeColor),
            ],
          ),
          const Divider(),
          Div(
            direction: LayoutDirection.horizontal,
            align: Alignment.centerLeft,
            children: [
              const Icon(Icons.attach_money),
              Label(
                type: LabelType.body,
                text: 'R\$ ${order.valor.toStringAsFixed(2)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
