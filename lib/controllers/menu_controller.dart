import 'package:get/get.dart';
import '../core/services/supabase_services.dart';

class MenuC extends GetxController {
  final SupabaseService service = SupabaseService();

  var menus = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchMenus();
    super.onInit();
  }

  Future<void> fetchMenus() async {
    try {
      isLoading.value = true;

      final data = await service.getMenus();

      menus.value = data.map((e) {
        return {
          'id': e['id'],
          'name': e['name'],
          'price': e['price'],
          'image_url': e['image_url'],
          'cat': e['categories']?['name'] ?? 'unknown',
        };
      }).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch menus: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMenu({
    required String name,
    required int price,
    required String imageUrl,
    required int categoryId,
  }) async {
    try {
      await service.addMenu(
        name: name,
        price: price,
        imageUrl: imageUrl,
        categoryId: categoryId,
      );

      Get.snackbar('Success', 'Menu berhasil ditambahkan');

      await fetchMenus();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add menu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateMenu({
    required dynamic id,
    required String name,
    required int price,
    required String imageUrl,
    required int categoryId,
  }) async {
    try {
      await service.updateMenu(
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
        categoryId: categoryId,
      );

      Get.snackbar('Success', 'Menu berhasil diupdate');

      await fetchMenus();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update menu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteMenu(dynamic id) async {
    try {
      await service.deleteMenu(id);

      Get.snackbar('Success', 'Menu berhasil dihapus');

      await fetchMenus();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete menu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}