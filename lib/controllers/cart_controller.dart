import 'package:get/get.dart';

class CartController extends GetxController {

  /// id menu -> qty
  final items = <String, int>{}.obs;

  /// tambah item
  void add(Map<String, dynamic> item) {
    final id = item['id'].toString();

    if (items.containsKey(id)) {
      items[id] = items[id]! + 1;
    } else {
      items[id] = 1;
    }

    items.refresh();
  }

  /// kurangi item
  void remove(String id) {

    if (!items.containsKey(id)) return;

    if (items[id]! > 1) {
      items[id] = items[id]! - 1;
    } else {
      items.remove(id);
    }

    items.refresh();
  }

  /// jumlah item
  int qtyOf(String id) {
    return items[id] ?? 0;
  }

  /// total semua item
  int get totalItems {
    return items.values.fold(0, (sum, e) => sum + e);
  }
}