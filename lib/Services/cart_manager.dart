import 'package:get/get.dart';
import '../constants/menu_data.dart';
import '../models/order_model.dart';

class CartController extends GetxController {
  var cart = <String, int>{}.obs;

  void add(String name) {
    cart[name] = (cart[name] ?? 0) + 1;
  }

  void remove(String name) {
    if ((cart[name] ?? 0) > 1) {
      cart[name] = cart[name]! - 1;
    } else {
      cart.remove(name);
    }
  }

  void clear() => cart.clear();

  int qtyOf(String name) => cart[name] ?? 0;

  int get totalItems => cart.values.fold(0, (s, q) => s + q);

  /// 🔥 SUBTOTAL (MASIH PAKE MENU DATA)
  int get subtotal {
    int total = 0;

    for (final entry in cart.entries) {
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
    return cart.entries.map((e) {
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
