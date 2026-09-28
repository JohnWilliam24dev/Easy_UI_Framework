import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

/// Pack próprio do card de resumo: bem menos padding que o pack ativo da
/// tela, para caber com folga na altura enxuta do `Grid` — independente de
/// qual `StylePack` (cliente/erp) estiver ativo por fora.
final StylePack _compacto = StylePack.define(
  name: 'resumo_pedidos_compacto',
  card: const CardStyleSpec(radius: 12, paddingSteps: 1),
);

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
    return StylePackScope(
      pack: _compacto,
      child: Card(
        child: Div(
          align: Alignment.center,
          // Gap fixo (não escala com o pack ativo): mantém o card baixo
          // mesmo quando o StylePack de fora usa spacingScale > 1.
          gap: 4.px,
          children: [
            Label(type: LabelType.title, text: '$count'),
            color == null
                ? Label(type: LabelType.caption, text: label)
                : Badge(text: label, color: color!),
          ],
        ),
      ),
    );
  }
}
