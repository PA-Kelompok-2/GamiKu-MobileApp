import 'package:get/get.dart';
import 'package:application_gamiku/controllers/profile_controller.dart';
import 'package:application_gamiku/routes/app_routes.dart';
import '../../../core/services/supabase_services.dart';
import '../../../core/utils/app_snackbar.dart';

class AuthController extends GetxController {
  final service = SupabaseService();

  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final res = await service.login(email, password);

      if (res.user == null) {
        showErrorSnackbar(
          "Login Gagal",
          "Email atau password salah."
        );
        return;
      }

      Get.put(ProfileController());

      await Future.delayed(const Duration(milliseconds: 200));

      Get.offAllNamed(
        Routes.home
      );
    } catch (e) {
      showErrorSnackbar(
        "Login Gagal",
        "Tidak dapat login. Periksa email dan password."
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await service.logout();
    Get.delete<ProfileController>();

    Get.offNamed(Routes.login); 
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

      Get.back();

      showSuccessSnackbar(
        "Registrasi Berhasil",
        "Akun berhasil dibuat"
      );
    } catch (e) {
      String pesan = "Registrasi gagal.";

      if (e.toString().contains("user_already_exists")) {
        pesan = "Email sudah terdaftar. Silakan gunakan email lain.";
      }

      showErrorSnackbar(
        "Registrasi Gagal!",
        pesan,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
