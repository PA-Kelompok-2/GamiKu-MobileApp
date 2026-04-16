import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:application_gamiku/controllers/profile_controller.dart';
import 'package:application_gamiku/routes/app_routes.dart';
import '../../../core/services/supabase_services.dart';

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
          icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
          borderColor: Colors.red,
          borderWidth: 1,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      Get.put(ProfileController());

      await Future.delayed(const Duration(milliseconds: 200));

      Get.offNamed(
        Routes.home
      );
    } catch (e) {
      Get.snackbar(
        "Login Gagal",
        "Tidak dapat login. Periksa email dan password.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
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

    Get.offNamed(Routes.login); // 🔥 wajib offAll di sini
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

      Get.snackbar(
        "Registrasi Berhasil",
        "Akun berhasil dibuat",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        icon: const Icon(Icons.check_circle, color: Colors.green),
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
          child: const Icon(Icons.close, color: Colors.red, size: 22),
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
}
