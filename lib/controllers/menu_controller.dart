import 'package:get/get.dart';
import '../core/services/supabase_services.dart';
import '../../../core/utils/app_snackbar.dart';

class MenuC extends GetxController {
  final SupabaseService service = SupabaseService();

  /// STATE
  var menus = <Map<String, dynamic>>[].obs;
  var categories = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  RxString selectedCategory = 'Semua'.obs;

  List<Map<String, dynamic>> allMenus = [];

  /// ================= RESET (FIX LOGOUT) =================
  void resetMenu() {
    selectedCategory.value = "Semua";

    menus.clear();
    allMenus.clear();

    isLoading.value = false;
  }

  /// ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    fetchMenus();
    fetchCategories();
  }

  /// ================= FETCH MENUS =================
  Future<void> fetchMenus() async {
    try {
      isLoading.value = true;

      final data = await service.getMenus();

      /// 🔥 HANDLE NULL / EMPTY
      if (data == null || data.isEmpty) {
        menus.clear();
        allMenus.clear();
        return;
      }

      final mappedMenus = data.map<Map<String, dynamic>>((e) {
        return {
          'id': e['id'],
          'name': e['name'],
          'price': e['price'],
          'image_url': e['image_url'],
          'category_id': e['category_id'],
          'cat': e['categories']?['name'] ?? 'unknown',
        };
      }).toList();

      allMenus = mappedMenus;
      menus.value = List.from(allMenus); // 🔥 copy biar aman

    } catch (e) {
      menus.clear();
      allMenus.clear();

      showErrorSnackbar(
        'Error',
        'Failed to fetch menus: $e',
      );
    } finally {
      isLoading.value = false; // 🔥 WAJIB biar gak stuck
    }
  }

  /// ================= FILTER =================
  void applyFilter(String query) {
    final q = query.toLowerCase();

    final filtered = allMenus.where((menu) {
      final name = menu['name'].toString().toLowerCase();
      final cat = menu['cat'].toString().toLowerCase();
      final selectedCat = selectedCategory.value.toLowerCase();

      /// 🔍 PRIORITAS SEARCH
      if (q.isNotEmpty) {
        return name.contains(q);
      }

      /// 📂 SEMUA
      if (selectedCat == "semua" || selectedCat.isEmpty) {
        return true;
      }

      /// 📂 FILTER CATEGORY
      return cat == selectedCat;
    }).toList();

    menus.value = filtered;
  }

  /// ================= FILTER CATEGORY =================
  void filterByCategory(String category) {
    selectedCategory.value = category;

    if (category == "Semua" || category.isEmpty) {
      menus.value = List.from(allMenus);
      return;
    }

    final filtered =
        allMenus.where((menu) => menu['cat'] == category).toList();

    menus.value = filtered;
  }

  /// ================= FETCH CATEGORY =================
  Future<void> fetchCategories() async {
    try {
      final data = await service.getCategories();
      categories.value = data;
    } catch (e) {
      showErrorSnackbar(
        'Error',
        'Failed to fetch categories: $e',
      );
    }
  }

  /// ================= ADD MENU =================
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
      showErrorSnackbar(
        'Error',
        'Failed to add menu: $e',
      );
    }
  }

  /// ================= UPDATE MENU =================
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
      showErrorSnackbar(
        'Error',
        'Failed to update menu: $e',
      );
    }
  }

  /// ================= DELETE MENU =================
  Future<void> deleteMenu(dynamic id) async {
    try {
      await service.deleteMenu(id);

      menus.removeWhere((m) => m['id'] == id);

      await fetchMenus();

      showSuccessSnackbar('Success', 'Menu berhasil dihapus');
    } catch (e) {
      showErrorSnackbar(
        'Error',
        'Failed to delete menu: $e',
      );
    }
  }

  /// ================= UPDATE AVAILABILITY =================
  Future<void> updateAvailability(String id, bool isAvailable) async {
    try {
      await service.updateMenuAvailability(id, isAvailable);

      final index =
          menus.indexWhere((m) => m['id'].toString() == id);

      if (index != -1) {
        menus[index] = {
          ...menus[index],
          'is_available': isAvailable,
        };

        menus.refresh();
      }
    } catch (e) {
      showErrorSnackbar(
        'Error',
        'Gagal update status: $e',
      );
    }
  }
}