import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart';

/// Card de resumo (contagem) usado no topo da lista de pedidos — mostra o
/// `Grid` acomodando cards de tamanho uniforme.
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.label,
    required this.count,
    this.color,
  });

  final String label;
  final int count;
  final BadgeColor? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Div(
        align: Alignment.center,
        children: [
          Label(type: LabelType.title, text: '$count'),
          color == null
              ? Label(type: LabelType.caption, text: label)
              : Badge(text: label, color: color!),
        ],
      ),
    );
  }
}
