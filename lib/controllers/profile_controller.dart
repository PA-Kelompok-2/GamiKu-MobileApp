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

    final user = service.supabase.auth.currentUser;

    if (user == null) {
      name.value = "Guest User";
      role.value = "customer";
      isLoading.value = false;
      return;
    }

    final data = await service.getProfile();

    if (data != null) {
      name.value = data['name'] ?? 'User';
      role.value = data['role'] ?? 'customer';
    }

    isLoading.value = false;
  }
}
