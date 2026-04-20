import 'package:get/get.dart';
import '../core/services/supabase_services.dart';
import '../routes/app_routes.dart';
import '../features/auth/controllers/auth_controller.dart';

class SplashController extends GetxController {
  final service = SupabaseService();

  @override
  void onInit() {
    super.onInit();
    checkAuth();
  }

  Future<void> checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = service.currentUser;

    if (user == null) {
      // Belum login → ke halaman login
      Get.offAllNamed(Routes.login);
      return;
    }

    // Sudah login → ambil role dulu, BARU ke home
    final profile = await service.getProfile();
    final role = profile?['role'] ?? 'pembeli';

    // Set role di AuthController supaya MenuC bisa fetch
    final authC = Get.find<AuthController>();
    authC.role.value = role;

    Get.offAllNamed(Routes.home);
  }
}
