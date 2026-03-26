import 'package:get/get.dart';
import '../services/supabase_services.dart';

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

    if (user == null) return;

    final role = await service.getUserRole();

    if (role == 'owner') {
      Get.offAllNamed('/owner');
    } else if (role == 'karyawan') {
      Get.offAllNamed('/karyawan');
    } else {
      Get.offAllNamed('/home');
    }
  }
}
