import 'package:get/get.dart';
import '../core/services/supabase_services.dart';
import '../routes/app_routes.dart';

class SplashController extends GetxController {
  final service = SupabaseService();

  @override
  void onInit() {
    super.onInit();
    checkAuth();
  }

  Future<void> checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = service.supabase.auth.currentUser;

    if (user == null) {
      Get.offAllNamed(Routes.login);
      return;
    }

    Get.offAllNamed(Routes.home);
  }
}