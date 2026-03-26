import 'package:get/get.dart';
import '../services/supabase_services.dart';

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
      print('Error fetch menu: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
