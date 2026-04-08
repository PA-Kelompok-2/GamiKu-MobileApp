import 'package:get/get.dart';
import '../core/services/supabase_services.dart';

class MenuC extends GetxController {
  final SupabaseService service = SupabaseService();

  var menus = <Map<String, dynamic>>[].obs;
  var categories = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  RxString selectedCategory = ''.obs;

  /// menyimpan semua menu asli
  List<Map<String, dynamic>> allMenus = [];

  @override
  void onInit() {
    fetchMenus();
    fetchCategories();
    super.onInit();
  }

  /// ========================
  /// FETCH MENUS
  /// ========================
  Future<void> fetchMenus() async {
    try {
      isLoading.value = true;

      final data = await service.getMenus();

      final mappedMenus = data.map((e) {
        return {
          'id': e['id'],
          'name': e['name'],
          'price': e['price'],
          'image_url': e['image_url'],
          'category_id': e['category_id'],
          'cat': e['categories']?['name'] ?? 'unknown',
        };
      }).toList();

      menus.value = mappedMenus;
      allMenus = mappedMenus;
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

  /// ========================
  /// SEARCH MENU
  /// ========================
  void searchMenu(String query) {
    if (query.isEmpty) {
      menus.value = allMenus;
      return;
    }

    final filtered = allMenus.where((menu) {
      final name = menu['name'].toString().toLowerCase();
      final cat = menu['cat'].toString().toLowerCase();

      return name.contains(query.toLowerCase()) ||
          cat.contains(query.toLowerCase());
    }).toList();

    menus.value = filtered;
  }

  /// ========================
  /// FETCH CATEGORIES
  /// ========================
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

  /// ========================
  /// ADD MENU
  /// ========================
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

  /// ========================
  /// UPDATE MENU
  /// ========================
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

  /// ========================
  /// DELETE MENU
  /// ========================
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
      Get.snackbar(
        'Error',
        'Gagal update status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
