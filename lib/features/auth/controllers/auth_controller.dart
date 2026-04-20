import 'package:get/get.dart';
import 'package:application_gamiku/controllers/profile_controller.dart';
import 'package:application_gamiku/routes/app_routes.dart';
import '../../../core/services/supabase_services.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../controllers/menu_controller.dart';

class AuthController extends GetxController {
  final service = SupabaseService();

  final isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final res = await service.login(email, password);
      if (res.user == null) {
        showErrorSnackbar(
          "Login Gagal",
          "Email atau password salah.",
        );
        return;
      }

      final profile = await service.getProfile();
      role.value = profile?['role'] ?? 'pembeli';
      print("=== ROLE SET TO: ${role.value} ===");
      // ↑ ini otomatis trigger ever() di MenuC, tidak perlu fetchMenus() manual lagi

      await Get.find<ProfileController>().loadProfile();

      Get.offAllNamed(Routes.home);
    } catch (e) {
      showErrorSnackbar(
        "Login Gagal",
        "Tidak dapat login. Periksa email dan password.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await service.logout();

    final profileC = Get.find<ProfileController>();
    profileC.name.value = 'Guest User';
    profileC.email.value = '';
    profileC.role.value = 'guest';
    profileC.isLoading.value = false;

    Get.offAllNamed(Routes.home);
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      isLoading.value = true;

      final normalizedEmail = email.trim().toLowerCase();
      final normalizedName = name.trim();

      final res = await service.register(normalizedEmail, password);
      final user = res.user;

      if (user != null) {
        await service.insertProfile(
          id: user.id,
          email: normalizedEmail,
          name: normalizedName,
        );
      }

      showSuccessSnackbar(
        "Registrasi Berhasil",
        "Akun berhasil dibuat. Silakan login.",
      );

      Get.offAllNamed(Routes.login);
    } catch (e) {
      String pesan = "Registrasi gagal.";

      if (e.toString().contains("user_already_exists")) {
        pesan = "Email sudah terdaftar. Silakan gunakan email lain.";
      }

      showErrorSnackbar("Registrasi Gagal!", pesan);
    } finally {
      isLoading.value = false;
    }
  }
}