import 'package:get/get.dart';
import '../core/services/supabase_services.dart';

class MenuC extends GetxController {
  final SupabaseService service = SupabaseService();

  var menus = <Map<String, dynamic>>[].obs;
  var categories = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchMenus();
    fetchCategories();
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
          'category_id': e['category_id'],
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

  Future<void> fetchCategories() async {
    try {
      final data = await service.getCategories();
      categories.value = data;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addMenu({
    required String name,
    required int price,
    required String imageUrl,
    required String categoryId,
  }) async {
    try {
      await service.addMenu(
        name: name,
        price: price,
        imageUrl: imageUrl,
        categoryId: categoryId,
      );

      await fetchMenus();
      menus.refresh();

      Get.snackbar('Success', 'Menu berhasil ditambahkan');
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
    required String categoryId,
  }) async {
    try {
      await service.updateMenu(
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
        categoryId: categoryId,
      );

      await fetchMenus();
      menus.refresh();

      Get.snackbar('Success', 'Menu berhasil diupdate');
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

      menus.removeWhere((m) => m['id'] == id);
      menus.refresh();

      await fetchMenus();

      Get.snackbar('Success', 'Menu berhasil dihapus');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete menu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  Future<void> updateAvailability(String id, bool isAvailable) async {
  try {
    await service.updateMenuAvailability(id, isAvailable);
    final index = menus.indexWhere((m) => m['id'].toString() == id);
    if (index != -1) {
      menus[index] = {...menus[index], 'is_available': isAvailable};
      menus.refresh();
    }
  } catch (e) {
    Get.snackbar('Error', 'Gagal update status: $e',
        snackPosition: SnackPosition.BOTTOM);
    }
  }
} 

