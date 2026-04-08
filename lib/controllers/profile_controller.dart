// lib/controllers/profile_controller.dart
import 'package:get/get.dart';
import '../core/services/supabase_services.dart';

class ProfileController extends GetxController {
  final service = SupabaseService();
  
  var name = ''.obs;
  var role = ''.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    final data = await service.getProfile();
    if (data != null) {
      name.value = data['name'] ?? '-';
      role.value = data['role'] ?? '-';
    }
    isLoading.value = false;
  }
}