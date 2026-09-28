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
            // Baixo o bastante para caber título + selo mesmo com 2 colunas
            // numa tela estreita (celular ou janela redimensionada).
            cellRatio: 1.5,
            children: [
              OrderSummaryCard(label: 'Pendente', count: 13, color: BadgeColor.warning),
              OrderSummaryCard(label: 'Em produção', count: 12, color: BadgeColor.info),
              OrderSummaryCard(label: 'Concluído', count: 12, color: BadgeColor.success),
            ],
          ),
          _FiltrosPedidos(
            status: _status,
            somentePendentes: _somentePendentes,
            onStatusChanged: (novo) {
              _status = novo;
              _aplicarFiltro();
            },
            onSomentePendentesChanged: (v) {
              _somentePendentes = v;
              _aplicarFiltro();
            },
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

/// Filtro de status + toggle "Só pendentes". Lado a lado em telas largas;
/// empilhado em telas estreitas, para o texto do toggle nunca disputar
/// espaço demais com o Select e estourar a largura (visto num teste com a
/// janela bem estreita). Usa `Breakpoints`/`ScreenSize` do próprio Kernel —
/// exatamente o mecanismo de responsividade que o framework promete resolver
/// sozinho, sem `MediaQuery` manual.
class _FiltrosPedidos extends StatelessWidget {
  const _FiltrosPedidos({
    required this.status,
    required this.somentePendentes,
    required this.onStatusChanged,
    required this.onSomentePendentesChanged,
  });

  final OrderStatus? status;
  final bool somentePendentes;
  final ValueChanged<OrderStatus?> onStatusChanged;
  final ValueChanged<bool> onSomentePendentesChanged;

  @override
  Widget build(BuildContext context) {
    final select = Select<OrderStatus?>.single(
      options: _filtros,
      value: status,
      hint: 'Status',
      onChanged: onStatusChanged,
    );
    final toggle = Div(
      direction: LayoutDirection.horizontal,
      align: Alignment.centerLeft,
      children: [
        Toggle(
          type: ToggleType.switch_,
          value: somentePendentes,
          onChanged: onSomentePendentesChanged,
        ),
        const Label(type: LabelType.caption, text: 'Só pendentes'),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compacta =
            Breakpoints.standard.sizeFor(constraints.maxWidth) == ScreenSize.mobile;

        if (compacta) {
          return Div(children: [select, toggle]);
        }
        return Div(
          direction: LayoutDirection.horizontal,
          children: [
            LayoutItem(size: 2.fr, child: select),
            LayoutItem(size: 1.fr, child: toggle),
          ],
        );
      },
    );
  }
}
