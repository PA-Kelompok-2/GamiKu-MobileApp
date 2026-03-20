import '../constants/menu_data.dart';
import '../models/order_model.dart';

class CartManager {
  CartManager._();
  static final CartManager instance = CartManager._();

  final Map<String, int> _qty = {};

  void add(String name) {
    _qty[name] = (_qty[name] ?? 0) + 1;
  }

  void remove(String name) {
    if ((_qty[name] ?? 0) > 1) {
      _qty[name] = _qty[name]! - 1;
    } else {
      _qty.remove(name);
    }
  }

  void clear() => _qty.clear();

  int qtyOf(String name) => _qty[name] ?? 0;

  int get totalItems => _qty.values.fold(0, (s, q) => s + q);

  int get subtotal {
    int total = 0;
    for (final entry in _qty.entries) {
      final item = MenuData.items.firstWhere(
        (m) => m['name'] == entry.key,
        orElse: () => {'price': 0},
      );

      total += (item['price'] as int) * entry.value;
    }
    return total;
  }

  static const int serviceFee = 2000;

  int get grandTotal => subtotal + serviceFee;

  List<OrderItem> get entries {
    return _qty.entries.map((e) {
      final item = MenuData.items.firstWhere(
        (m) => m['name'] == e.key,
        orElse: () => {'name': e.key, 'price': 0, 'emoji': '🍽️'},
      );

      return OrderItem(
        name: e.key,
        emoji: item['emoji'] as String,
        price: item['price'] as int,
        qty: e.value,
      );
    }).toList();
  }
}
