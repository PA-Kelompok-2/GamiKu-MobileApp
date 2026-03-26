import 'package:get/get.dart';
import '../services/supabase_services.dart';

class AuthController extends GetxController {
  final service = SupabaseService();

  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await service.login(email, password);

      final role = await service.getUserRole();

      if (role == 'owner') {
        Get.offAllNamed('/owner');
      } else if (role == 'karyawan') {
        Get.offAllNamed('/karyawan');
      } else {
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Login Gagal', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await service.logout();
    Get.offAllNamed('/login');
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      isLoading.value = true;

      final res = await service.register(email, password);

      final user = res.user;

      if (user != null) {
        await service.insertProfile(id: user.id, email: email, name: name);
      }

      Get.back();
      Get.snackbar('Success', 'Akun berhasil dibuat');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await service.supabase.auth.resetPasswordForEmail(email);
      Get.snackbar('Success', 'Link reset password dikirim ke email');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
