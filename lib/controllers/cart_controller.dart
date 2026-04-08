import 'package:get/get.dart';
import '../features/models/order_model.dart';

class CartController extends GetxController {
  var cart = <String, Map<String, dynamic>>{}.obs;

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
    if ((cart[id]?['qty'] ?? 0) > 1) {
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

  int qtyOf(String id) => cart[id]?['qty'] ?? 0;

  int get totalItems => cart.values.fold(0, (s, e) => s + (e['qty'] as int));

  int get subtotal => 
  cart.values.fold(0, (s, e) => s + (e['price'] as int) * (e['qty'] as int));

  static const int serviceFee = 2000;

  int get grandTotal => subtotal + serviceFee;  

  List<OrderItem> get entries {
    return cart.values.map((e) {
      return OrderItem(
        id: e['id'],
        name: e['name'],
        emoji: e['emoji'],
        price: e['price'],
        qty: e['qty'],
      );
    }).toList();
  }
}
