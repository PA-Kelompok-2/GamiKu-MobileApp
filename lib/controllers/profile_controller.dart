import 'package:get/get.dart';
import '../core/services/supabase_services.dart';

class ProfileController extends GetxController {
  final service = SupabaseService();

  final name = ''.obs;
  final email = ''.obs;
  final role = ''.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;

      final user = service.supabase.auth.currentUser;

      if (user == null) {
        name.value = 'Guest User';
        email.value = '';
        role.value = 'guest';
        return;
      }

      final data = await service.getProfile();

      name.value =
          (data?['name'] ?? user.email?.split('@').first ?? 'User').toString();

      email.value =
          (data?['email'] ?? user.email ?? '').toString();

      role.value =
          (data?['role'] ?? 'customer').toString();
    } catch (e) {
      name.value = 'User';
      email.value = '';
      role.value = 'customer';
    } finally {
      isLoading.value = false;
    }
  }
}