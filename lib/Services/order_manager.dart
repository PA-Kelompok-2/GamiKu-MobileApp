import '../models/order_model.dart';

class OrderManager {
  static final OrderManager _instance = OrderManager._internal();
  static OrderManager get instance => _instance;
  OrderManager._internal();

  final List<Order> _orders = [];
  int _nextId = 1;

  List<Order> get orders => List<Order>.unmodifiable(_orders);

  void addOrder({
    required List<OrderItem> cartEntries,
    required String tableNote,
    required String orderNote,
  }) {
    final now = DateTime.now();
    final order = Order(
      id: 'ORD-${_nextId.toString().padLeft(4, '0')}',
      items: cartEntries
          .map(
            (e) => OrderItem(
              name: e.name,
              emoji: e.emoji,
              price: e.price,
              qty: e.qty,
            ),
          )
          .toList(),
      tableNote: tableNote,
      orderNote: orderNote,
      createdAt: now,
    );

    _orders.insert(0, order);
    _nextId++;
  }

  void updateStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].status = newStatus;
    }
  }

  void clear() {
    _orders.clear();
    _nextId = 1;
  }
}
