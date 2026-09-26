import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import 'order.dart';
import 'order_card.dart';
import 'order_summary_card.dart';
import 'orders_repository.dart';

const List<SelectOption<OrderStatus?>> _filtros = [
  SelectOption(null, 'Todos os status'),
  SelectOption(OrderStatus.pending, 'Pendente'),
  SelectOption(OrderStatus.inProgress, 'Em produção'),
  SelectOption(OrderStatus.done, 'Concluído'),
];

/// Lista de pedidos: demonstra `Grid` (cards de resumo), `Select`, `Toggle`,
/// `DataList` com paginação server-side e filtro, e `Card`/`Avatar`/`Badge`/
/// `Icon`/`Divider` dentro de cada item.
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  OrderStatus? _status;
  bool _somentePendentes = false;

  // A cada mudança de filtro, uma nova key recria o DataList do zero
  // (ele mesmo não sabe re-filtrar uma busca em andamento).
  Key _listKey = UniqueKey();

  OrderStatus? get _statusEfetivo => _somentePendentes ? OrderStatus.pending : _status;

  void _aplicarFiltro() => setState(() => _listKey = UniqueKey());

  @override
  Widget build(BuildContext context) {
    return Tela(
      child: Div(
        children: [
          Div(
            direction: LayoutDirection.horizontal,
            align: Alignment.centerLeft,
            children: [
              LayoutItem(
                size: 1.fr,
                child: const Label(type: LabelType.title, text: 'Pedidos'),
              ),
              Button(text: 'Voltar', variant: ButtonVariant.ghost, onPressed: widget.onBack),
            ],
          ),
          const Grid(
            minCell: 2,
            maxCell: 3,
            cellRatio: 2,
            children: [
              OrderSummaryCard(label: 'Pendente', count: 13, color: BadgeColor.warning),
              OrderSummaryCard(label: 'Em produção', count: 12, color: BadgeColor.info),
              OrderSummaryCard(label: 'Concluído', count: 12, color: BadgeColor.success),
            ],
          ),
          Div(
            direction: LayoutDirection.horizontal,
            children: [
              LayoutItem(
                size: 2.fr,
                child: Select<OrderStatus?>.single(
                  options: _filtros,
                  value: _status,
                  hint: 'Status',
                  onChanged: (novo) {
                    _status = novo;
                    _aplicarFiltro();
                  },
                ),
              ),
              LayoutItem(
                size: 1.fr,
                child: Div(
                  direction: LayoutDirection.horizontal,
                  align: Alignment.centerLeft,
                  children: [
                    Toggle(
                      type: ToggleType.switch_,
                      value: _somentePendentes,
                      onChanged: (v) {
                        _somentePendentes = v;
                        _aplicarFiltro();
                      },
                    ),
                    const Label(type: LabelType.caption, text: 'Só pendentes'),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          LayoutItem(
            size: 1.fr,
            child: DataList<Order>(
              key: _listKey,
              limit: 10,
              source: (page, limit) => fetchOrders(page, limit, status: _statusEfetivo),
              itemBuilder: (context, order) => OrderCard(order: order),
            ),
          ),
        ],
      ),
    );
  }
}
