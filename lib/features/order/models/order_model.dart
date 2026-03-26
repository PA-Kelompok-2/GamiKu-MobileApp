class OrderItem {
  final String id;
  final String name;
  final String emoji;
  final int price;
  int qty;

  OrderItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.qty,
  });

  int get subtotal => price * qty;

  Map<String, dynamic> toMap() => {
    'name': name,
    'emoji': emoji,
    'price': price,
    'qty': qty,
  };
}

enum OrderStatus { menunggu, diproses, siap, selesai }

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.menunggu:
        return 'Menunggu';
      case OrderStatus.diproses:
        return 'Diproses';
      case OrderStatus.siap:
        return 'Siap';
      case OrderStatus.selesai:
        return 'Selesai';
    }
  }

  OrderStatus? get next {
    switch (this) {
      case OrderStatus.menunggu:
        return OrderStatus.diproses;
      case OrderStatus.diproses:
        return OrderStatus.siap;
      case OrderStatus.siap:
        return OrderStatus.selesai;
      case OrderStatus.selesai:
        return null;
    }
  }

  String get nextLabel {
    switch (this) {
      case OrderStatus.menunggu:
        return '▶ Proses';
      case OrderStatus.diproses:
        return '✓ Tandai Siap';
      case OrderStatus.siap:
        return '✓ Selesai';
      case OrderStatus.selesai:
        return '';
    }
  }
}

class Order {
  final String id;
  final String tableNote;
  final String orderNote;
  final List<OrderItem> items;
  final DateTime createdAt;
  OrderStatus status;

  Order({
    required this.id,
    required this.tableNote,
    required this.orderNote,
    required this.items,
    required this.createdAt,
    this.status = OrderStatus.menunggu,
  });

  int get total => items.fold(0, (s, i) => s + i.subtotal);
  int get totalQty => items.fold(0, (s, i) => s + i.qty);

  String get timeLabel {
    final h = createdAt.hour.toString().padLeft(2, '0');
    final m = createdAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
