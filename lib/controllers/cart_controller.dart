import 'package:get/get.dart';

import '../features/models/order_model.dart';

class CartController extends GetxController {
  static const int serviceFee = 2000;

  final RxMap<String, Map<String, dynamic>> cart =
      <String, Map<String, dynamic>>{}.obs;

  void add(Map<String, dynamic> item) {
    final String id = item['id'].toString();

    if (cart.containsKey(id)) {
      cart[id]!['qty'] += 1;
    } else {
      cart[id] = {
        'id': item['id'],
        'name': item['name'] ?? 'Unknown',
        'price': item['price'] ?? 0,
        'emoji': item['emoji'] ?? '🍽️',
        'qty': 1,
      };
    }

    cart.refresh();
  }

  void remove(String id) {
    final int currentQty = cart[id]?['qty'] ?? 0;

    if (currentQty > 1) {
      cart[id]!['qty'] -= 1;
    } else {
      cart.remove(id);
    }

    cart.refresh();
  }

  void clear() {
    cart.clear();
    cart.refresh();
  }

  int qtyOf(String id) {
    return cart[id]?['qty'] ?? 0;
  }

  int get totalItems {
    return cart.values.fold(
      0,
      (sum, item) => sum + (item['qty'] as int),
    );
  }

  int get subtotal {
    return cart.values.fold(
      0,
      (sum, item) => sum + (item['price'] as int) * (item['qty'] as int),
    );
  }

  int get grandTotal {
    return subtotal + serviceFee;
  }

  List<OrderItem> get entries {
    return cart.values.map((item) {
      return OrderItem(
        id: item['id'],
        name: item['name'],
        emoji: item['emoji'],
        price: item['price'],
        qty: item['qty'],
      );
    }).toList();
  }
}