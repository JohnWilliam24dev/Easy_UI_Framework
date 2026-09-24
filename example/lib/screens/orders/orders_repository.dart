import 'order.dart';

/// Dados de exemplo (em memória, no lugar de uma API de verdade).
final List<Order> _todosOsPedidos = List.generate(37, (i) {
  final status = OrderStatus.values[i % OrderStatus.values.length];
  return Order(
    id: i + 1,
    cliente: 'Cliente ${i + 1}',
    valor: 80.0 + (i * 15 % 300),
    status: status,
  );
});

/// Busca uma página de pedidos, opcionalmente filtrada por [status].
/// Assinatura compatível com `DataSource<Order>` do `DataList`.
Future<List<Order>> fetchOrders(
  int page,
  int limit, {
  OrderStatus? status,
}) async {
  await Future<void>.delayed(const Duration(milliseconds: 150));
  final filtrados = status == null
      ? _todosOsPedidos
      : _todosOsPedidos.where((p) => p.status == status).toList();
  final start = page * limit;
  if (start >= filtrados.length) return const [];
  final end = (start + limit).clamp(0, filtrados.length);
  return filtrados.sublist(start, end);
}
