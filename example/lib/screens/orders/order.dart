/// Status de um pedido do ateliê.
enum OrderStatus { pending, inProgress, done }

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
        OrderStatus.pending => 'Pendente',
        OrderStatus.inProgress => 'Em produção',
        OrderStatus.done => 'Concluído',
      };
}

/// Um pedido de exemplo.
class Order {
  const Order({
    required this.id,
    required this.cliente,
    required this.valor,
    required this.status,
  });

  final int id;
  final String cliente;
  final double valor;
  final OrderStatus status;
}
