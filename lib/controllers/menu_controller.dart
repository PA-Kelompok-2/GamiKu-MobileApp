import 'package:get/get.dart';
import '../core/services/supabase_services.dart';
import '../../../core/utils/app_snackbar.dart';
import '../features/auth/controllers/auth_controller.dart';

class MenuC extends GetxController {
  final SupabaseService service = SupabaseService();

  var menus = <Map<String, dynamic>>[].obs;
  var categories = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  RxString selectedCategory = 'Semua'.obs;

  List<Map<String, dynamic>> allMenus = [];

  void resetMenu() {
    selectedCategory.value = "Semua";
    menus.clear();
    allMenus.clear();
    isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();

    final authC = Get.find<AuthController>();

    if (authC.role.value.isNotEmpty) {
      fetchMenus();
    }

    ever(authC.role, (role) {
      if (role.isNotEmpty) {
        fetchMenus();
      } else {
        resetMenu();
      }
    });
  }

  Future<void> fetchMenus() async {
    try {
      isLoading.value = true;

      final data = await service.getMenus();

      final mappedMenus = data.map<Map<String, dynamic>>((e) {
        return {
          'id': e['id'].toString(),
          'name': e['name'],
          'price': e['price'],
          'image_url': e['image_url'],
          'category_id': e['category_id'],
          'cat': e['categories']?['name'] ?? 'unknown',
          'is_available': e['is_available'] ?? true,
        };
      }).toList();

      final authC = Get.find<AuthController>();

      final filteredMenus = mappedMenus.where((m) {
        if (authC.role.value == 'pembeli') {
          return m['is_available'] == true;
        }
        return true;
      }).toList();

      allMenus = filteredMenus;
      menus.value = List.from(allMenus);
      update();
    } catch (e) {
      menus.clear();
      allMenus.clear();
      showErrorSnackbar('Error', 'Failed to fetch menus: $e');
    } finally {
      isLoading.value = false; // ← INI YANG BIKIN LOADING BERHENTI
    }
  }

  void applyFilter(String query) {
    final q = query.toLowerCase();

    final filtered = allMenus.where((menu) {
      final name = menu['name'].toString().toLowerCase();
      final cat = menu['cat'].toString().toLowerCase();
      final selectedCat = selectedCategory.value.toLowerCase();

      if (q.isNotEmpty) {
        return name.contains(q);
      }

      if (selectedCat == "semua" || selectedCat.isEmpty) {
        return true;
      }

      return cat == selectedCat;
    }).toList();

    menus.value = filtered;
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;

    if (category == "Semua" || category.isEmpty) {
      menus.value = List.from(allMenus);
      return;
    }

    final filtered = allMenus.where((menu) => menu['cat'] == category).toList();

    menus.value = filtered;
  }

  Future<void> fetchCategories() async {
    try {
      final data = await service.getCategories();
      categories.value = data;
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to fetch categories: $e');
    }
  }

  Future<void> addMenu({
    required String name,
    required int price,
    String? imageUrl,
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
      showSuccessSnackbar('Success', 'Menu berhasil ditambahkan');
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to add menu: $e');
    }
  }

  Future<void> updateMenu({
    required dynamic id,
    required String name,
    required int price,
    String? imageUrl,
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
      showSuccessSnackbar('Success', 'Menu berhasil diupdate');
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to update menu: $e');
    }
  }

  Future<void> deleteMenu(dynamic id) async {
    try {
      await service.deleteMenu(id);
      menus.removeWhere((m) => m['id'] == id);
      await fetchMenus();
      showSuccessSnackbar('Success', 'Menu berhasil dihapus');
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to delete menu: $e');
    }
  }

  Future<void> updateAvailability(String id, bool isAvailable) async {
    try {
      // 🔥 TAMBAH INI
      final cleanId = id.toString().trim();

      // 1. Update DB
      await service.updateMenuAvailability(cleanId, isAvailable);

      // 2. Update state lokal (menus)
      final index = menus.indexWhere((m) => m['id'].toString() == cleanId);
      if (index != -1) {
        menus[index] = {
          ...menus[index],
          'is_available': isAvailable,
        };
      }

      // 3. Update allMenus
      final allIndex = allMenus.indexWhere((m) => m['id'].toString() == cleanId);
      if (allIndex != -1) {
        allMenus[allIndex]['is_available'] = isAvailable;
      }

      // 4. Refresh UI
      menus.refresh();

    } catch (e) {
      showErrorSnackbar('Error', 'Gagal update status: $e');
    }
  }
}
