import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:application_gamiku/controllers/profile_controller.dart';
import 'package:application_gamiku/routes/app_routes.dart';
import '../../../core/services/supabase_services.dart';
import '../../../core/constants/app_colors.dart';


class AuthController extends GetxController {
  final service = SupabaseService();

  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final res = await service.login(email, password);

      if (res.user == null) {
        Get.snackbar(
          "Login Gagal",
          "Email atau password salah.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.black,
          icon: const Icon(
            Icons.cancel,
            color: Colors.red,
            size: 28,
          ),
          borderColor: Colors.red,
          borderWidth: 1,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      Get.put(ProfileController());
      Get.offAllNamed(Routes.home);

    } catch (e) {
      Get.snackbar(
        "Login Gagal",
        "Tidak dapat login. Periksa email dan password.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        icon: const Icon(
          Icons.cancel,
          color: Colors.red,
          size: 28,
        ),
        borderColor: Colors.red,
        borderWidth: 1,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await service.logout();
    Get.delete<ProfileController>();
    Get.offAllNamed(Routes.login);
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
        await service.insertProfile(
          id: user.id,
          email: email,
          name: name,
        );
      }

      Get.back();

      Get.snackbar(
        "Registrasi Berhasil",
        "Akun berhasil dibuat",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
        borderColor: Colors.green,
        borderWidth: 1,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      String pesan = "Registrasi gagal.";

      if (e.toString().contains("user_already_exists")) {
        pesan = "Email sudah terdaftar. Silakan gunakan email lain.";
      }

      Get.snackbar(
        "Registrasi Gagal!",
        pesan,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Color(0xFFFFE5E5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            color: Colors.red,
            size: 22,
          ),
        ),
        borderColor: Colors.red,
        borderWidth: 1,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> resetPassword(String email) async {
    try {
      await service.supabase.auth.resetPasswordForEmail(email);

      Get.snackbar(
        'Berhasil',
        'Link reset password telah dikirim ke email',
        backgroundColor: AppColors.tagGreen,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(20),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat mengirim reset password',
        backgroundColor: AppColors.splashRed,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(20),
      );
    }
  }
}
